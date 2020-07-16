import boto3

athena_client = boto3.client('athena')


def handle(event, context):
    response = athena_client.get_query_execution(QueryExecutionId=event['QueryExecutionId'])
    return {'AthenaState': response['QueryExecution']['Status']['State']}
