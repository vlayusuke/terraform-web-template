import boto3
import os
import logging
from datetime import datetime, timedelta, timezone

ECS_MAINTENANCE_TIME = int(os.environ['ECS_MAINTENANCE_TIME'])  # 実行したい時間（日本時間 24時間表記）
EXECUTE_LAMBDA_ARN = os.environ['EXECUTE_LAMBDA_ARN']
SCHEDULER_ROLE_ARN = os.environ['SCHEDULER_ROLE_ARN']

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ecs = boto3.client('ecs')
scheduler = boto3.client('scheduler')
JST = timezone(timedelta(hours=9))


def get_service_name_from_task(cluster_arn, task_arn):
    """
    タスクARNから所属するサービス名を特定する
    """
    try:
        response = ecs.describe_tasks(
            cluster=cluster_arn,
            tasks=[task_arn]
        )

        if not response['tasks']:
            logger.warning(f"No task found for ARN: {task_arn}")
            return None

        # Extract service name from the 'group' field (format: 'service:service-name')
        group = response['tasks'][0].get('group', '')
        if group.startswith('service:'):
            return group.replace('service:', '')

        logger.warning(f"Group field does not contain service name: {group}")
        return None

    except Exception as e:
        logger.error(f"Error describing tasks: {e}")
        return None


def calculate_next_execution_time(hour_jst):
    """
    次の指定時刻（日本時間）を計算し、Scheduler用のUTC ISO文字列を返す
    """
    now_jst = datetime.now(JST)

    # Create a datetime object for the target time today in JST
    target_jst = now_jst.replace(hour=hour_jst, minute=0, second=0, microsecond=0)

    # If the target time has already passed today, schedule for the next day
    if target_jst <= now_jst:
        target_jst += timedelta(days=1)

    # Report the target time in UTC for Scheduler
    utc_time = target_jst.astimezone(timezone.utc)

    # Format: YYYY-MM-DDTHH:MM:SS
    return utc_time.strftime('%Y-%m-%dT%H:%M:%S')


def lambda_handler(event, context):
    logger.info(f"Received event: {event}")

    affected_entities = event.get('detail', {}).get('affectedEntities', [])
    if not affected_entities:
        logger.info("No affected entities found in the event. Termination.")
        return {"status": "no_entities"}

    # Execute at the specified time (ECS_MAINTENANCE_TIME) in JST, converted to UTC ISO format for Scheduler
    scheduled_at_iso = calculate_next_execution_time(ECS_MAINTENANCE_TIME)
    logger.info(f"Next maintenance window (UTC): {scheduled_at_iso}")

    for entity in affected_entities:
        task_arn = entity.get('entityValue')
        if not task_arn or 'task' not in task_arn:
            continue

        logger.info(f"Processing Task: {task_arn}")

        # 1. Extract cluster name from Task ARN (format: arn:aws:ecs:region:account-id:task/cluster-name/task-id)
        try:
            cluster_name = task_arn.split('/')[1]
        except IndexError:
            logger.error(f"Invalid Task ARN format: {task_arn}")
            continue

        # 2. Extract service name from the task ARN using ECS API
        service_name = get_service_name_from_task(cluster_name, task_arn)
        if not service_name:
            continue

        # 3. Generate schedule name (service name + execution date)
        # Even if multiple tasks for the same service are scheduled for retirement, they will be consolidated under one schedule name
        target_date_str = scheduled_at_iso.split('T')[0].replace('-', '')
        schedule_name = f"Restart-{service_name}-{target_date_str}"

        logger.info(f"Creating/Updating schedule: {schedule_name} for service: {service_name}")

        try:
            # Create or update the schedule for the target service. If a schedule with the same name already exists, it will be overwritten.
            scheduler.create_schedule(
                Name=schedule_name,
                ScheduleExpression=f"at({scheduled_at_iso})",
                Target={
                    'Arn': EXECUTE_LAMBDA_ARN,
                    'RoleArn': SCHEDULER_ROLE_ARN,
                    'Input': f'{{"cluster": "{cluster_name}", "service": "{service_name}"}}'
                },
                ActionAfterCompletion='DELETE', # 実行完了後にスケジュールを自動削除
                FlexibleTimeWindow={'Mode': 'OFF'}
            )
            logger.info(f"Schedule created: {schedule_name}")

        except scheduler.exceptions.ConflictException:
            # Even if a schedule with the same name already exists, it means a restart has already been scheduled for this service, so we can skip creating a new schedule.
            logger.info(f"Schedule {schedule_name} already exists. Skipping.")
        except Exception as e:
            logger.error(f"Failed to create schedule: {e}")

    return {"status": "success"}
