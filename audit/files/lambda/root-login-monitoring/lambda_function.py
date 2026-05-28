import os
import json
import base64
import gzip
import logging
from urllib import request

logger = logging.getLogger()
logger.setLevel(logging.INFO)

hook_url = os.environ['hook_url']
account_name = os.environ['account_name']

headers = {
    "Content-Type": "application/json"
}


def lambda_handler(event, context):
    logger.info('event =' + str(event))

    decoded_data = base64.b64decode(event['awslogs']['data'])
    json_data = json.loads(gzip.decompress(decoded_data))

    for log in json_data['logEvents']:
        message = json.loads(log['message'])
        event_time = message["eventTime"]
        source_ip_addr = message["sourceIPAddress"]

        send_text = """
        <!channel>
        {event_time}にrootユーザーでのログインを検知しました。
        当該アカウントは `{account_name}` です。
        接続元IPアドレスは `{source_ip_addr}` です。
        """.format(
            event_time = event_time,
            account_name = account_name,
            source_ip_addr = source_ip_addr,
        )

        params = {
            'text': send_text
        }

        req = request.Request(hook_url, json.dumps(params).encode(), headers, method='POST')

        with request.urlopen(req) as res:
            content = res.read()
            logger.info(content)

    return
