import boto3
import logging
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

ecs = boto3.client('ecs')


def lambda_handler(event, context):

    # get payload from EventBridge Scheduler
    cluster = event.get('cluster')
    service = event.get('service')

    if not cluster or not service:
        logger.error(f"[ERROR] Missing parameters. Cluster: {cluster}, Service: {service}")
        return {"status": "error", "message": "Missing parameters"}

    try:
        # ececute force deployment (rolling update)
        logger.info(f"Attempting to update service: {service} in cluster: {cluster}")

        response = ecs.update_service(
            cluster=cluster,
            service=service,
            forceNewDeployment=True
        )

        logger.info(f"Successfully updated service: {service} in cluster: {cluster}")
        logger.info(f"Deployment ID: {response['service']['deployments'][0]['id']}")

        return {
            "status": "success",
            "cluster": cluster,
            "service": service
        }

    except ClientError as e:

        # Error from AWS API
        error_code = e.response['Error']['Code']
        error_message = e.response['Error']['Message']
        logger.error(f"AWS ClientError [{error_code}]: {error_message}")

        # If retry is needed, raise the exception; otherwise, return an error response
        raise e

    except Exception as e:

        # Other unexpected errors
        logger.error(f"Unexpected error: {str(e)}")
        raise e
