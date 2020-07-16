import boto3

athena_client = boto3.client('athena')


def handle(event, context):
    for execution_id in event['QueryExecutionIds']:
        response = athena_client.get_query_execution(QueryExecutionId=execution_id)
        state = response['QueryExecution']['Status']['State']
        if state != 'SUCCEEDED':
            return {'AthenaState': state}
    return {'AthenaState': 'SUCCEEDED'}
