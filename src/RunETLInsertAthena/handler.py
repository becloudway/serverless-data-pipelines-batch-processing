import boto3
import os

athena_client = boto3.client('athena')
QUERY = os.environ['QUERY']
DB = os.environ['DB']
CATALOG = os.environ['CATALOG']
WORKGROUP = os.environ['WORKGROUP']
OUTPUT = os.environ['OUTPUT']


def handle(event, context):
    finished_query = QUERY.format(year=event['year'], month=event['month'], day=event['day'])
    response = athena_client.start_query_execution(
        QueryString=finished_query,
        QueryExecutionContext={'Database': DB, 'Catalog': CATALOG},
        ResultConfiguration={'OutputLocation': OUTPUT}
    )
    return response
