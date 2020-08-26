import boto3
import os
from datetime import datetime, timedelta
import pytz

glue_client = boto3.client('glue')
CRAWLER_NAME = os.environ['CRAWLER_NAME']


def handle(event, context):
    timezone = pytz.timezone('Europe/Brussels')
    yesterday = datetime.now(timezone) - timedelta(days=1)
    response = glue_client.start_crawler(Name=CRAWLER_NAME)
    return {'response': response, 'year': event.get('year', yesterday.year), 'month': event.get('month', yesterday.month), 'day': event.get('day', yesterday.day)}
