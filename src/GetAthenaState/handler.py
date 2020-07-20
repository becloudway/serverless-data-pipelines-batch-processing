import boto3

athena_client = boto3.client('athena')


def handle(event, context):
    response = athena_client.batch_get_query_execution(QueryExecutionIds=event['QueryExecutionIds'])
    for execution in response['QueryExecutions']:
        state = execution['Status']['State']
        if state != 'SUCCEEDED':
            return {'AthenaState': state, 'QueryExecutionId': execution['QueryExecutionId']}
    if len(response['UnprocessedQueryExecutionIds']) > 0:
        return {'AthenaState': 'FAILED'}
    return {'AthenaState': 'SUCCEEDED'}
