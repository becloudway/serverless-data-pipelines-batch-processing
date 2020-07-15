import boto3
import os

glue_client = boto3.client('glue')
CRAWLER_NAME = os.environ['CRAWLER_NAME']


def handle(event, context):
    return glue_client.start_crawler(Name=CRAWLER_NAME)
