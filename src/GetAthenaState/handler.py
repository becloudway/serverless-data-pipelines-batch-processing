import boto3
import os

athena_client = boto3.client('athena')
QUERY = os.environ['QUERY']
DB = os.environ['DB']
CATALOG = os.environ['CATALOG']
WORKGROUP = os.environ['WORKGROUP']
OUTPUT = os.environ['OUTPUT']


def handle(event, context):
    response = athena_client.get_query_execution(QueryExecutionId=event.QueryExecutionId)
    return {'AthenaState': response['QueryExecution']['Status']['State']}
