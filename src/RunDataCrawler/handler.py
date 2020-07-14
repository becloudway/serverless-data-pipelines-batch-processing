import boto3
import os
import json

glue_client = boto3.client('glue')
CRAWLER_NAME = os.environ['CRAWLER_NAME']


def handle(event, context):
    return glue_client.start_crawler(name=CRAWLER_NAME)
