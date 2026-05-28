import os
import json
import logging
from urllib import request

logger = logging.getLogger()
logger.setLevel(logging.INFO)

hook_url = os.environ['hook_url']

headers = {
    "Content-Type": "application/json"
}


def lambda_handler(event, context):
    for record in event['Records']:
        if not "Sns" in record.keys():
            return

        params = {
            'text': record['Sns']['Message']
        }

        req = request.Request(hook_url, json.dumps(params).encode(), headers, method='POST')

        with request.urlopen(req) as res:
            content = res.read()
            logger.info(content)

    return
