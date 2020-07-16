import boto3
import os

glue_client = boto3.client('glue')
CRAWLER_NAME = os.environ['CRAWLER_NAME']


def handle(event, context):
    response = glue_client.get_crawler(Name=CRAWLER_NAME)['Crawler']
    return {'CrawlerState': response['State'], 'CrawlerStatus': response['LastCrawl']['Status'],
            'year': event['year'], 'month': event['month'], 'day': event['day']}
