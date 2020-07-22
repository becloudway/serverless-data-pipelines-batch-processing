# Serverless data pipelines - Batch processing
This is an implementation of the batch processing state machine for the serverless data pipeline for Flanders traffic analysis.
See [becloudway/serverless-data-pipelines](https://github.com/becloudway/serverless-data-pipeline) for more information on the general scope of the project.

# Architecture
![State machine](img/statemachine.png)

The state machine consists of 4 tasks (RunDataCrawler, GetCrawlerState, RunETLInsertAthena and CheckAthenaState), 
combined with wait and choice states.

**RunDataCrawler**

Runs the data crawler that explores the event history data contained in the delivery bucket.

**GetCrawlerState**

Gets the state of the data crawler in order to be able to check that the state of the crawler is 'SUCCEEDED' before 
moving on to the execution of the Athena ETL query.

**RunETLInsertAthena**

Runs the Athena ETL insert queries, which perform the following:
* Computation of aggregate values and traffic jam indicator
* Selection of relevant information
* Repartitioning of data by event time (year, month, day)

**GetAthenaState**

Gets the states of the executed Athena queries in order to be able to check that all queries succeeded.

# Instruction
When MFA is enabled for the current AWS account, the following variables have to be exported for correct authorization 
before running a cli command: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`. These variables can be 
obtained with the command `aws sts get-session-token --serial-number <account-arn> --token-code <mfa-code>`. 
A bash script `mfa.sh` is provided which automates this process. This script requires the library `jq` to be installed,
which is used to parse the returned json from the get-session-token command. Also make sure to replace the arn variable
with your own account arn. The script can be used as follows: `./mfa.sh "<cli-command>" <mfa-code>`.

# Data
The Athena ETL queries process the historical event data that is contained within the S3 delivery bucket.
This is what the processed data looks like:

| uniqueid | recordtimestamp | currentspeed | bezettingsgraad | previousspeed | trafficjamindicator | trafficintensityclass2 | trafficintensityclass3 | trafficintensityclass4 | trafficintensityclass5 | speeddiffindicator | avgspeed2minutes   | avgspeed10minutes  |
| -------- | --------------- | ------------ | --------------- | ------------- | ------------------- | ---------------------- | ---------------------- | ---------------------- | ---------------------- | ------------------ | ------------------ | ------------------ |
| 37       | 1594684800      | 49.75        | 1               |               | 0                   | 1                      | 0                      | 0                      | 1                      | 0                  | 49.75              | 49.75              |
| 37       | 1594684860      | 77.75        | 2               | 49.75         | 0                   | 1                      | 3                      | 0                      | 1                      | 1                  | 63.75              | 63.75              |
| 37       | 1594684920      | 75.0         | 4               | 77.75         | 0                   | 0                      | 2                      | 1                      | 2                      | 0                  | 67.5               | 67.5               |
| 37       | 1594684980      | 73.5         | 1               | 75.0          | 0                   | 1                      | 1                      | 0                      | 1                      | 0                  | 75.41666666666667  | 69.0               |
| 37       | 1594685040      | 28.5         | 0               | 73.5          | 0                   | 0                      | 1                      | 0                      | 0                      | -1                 | 59.0               | 60.9               |
| 37       | 1594685100      | 54.0         | 3               | 28.5          | 0                   | 0                      | 1                      | 0                      | 2                      | 1                  | 52.0               | 59.75              |
| 37       | 1594685160      | 73.0         | 2               | 54.0          | 0                   | 1                      | 2                      | 0                      | 1                      | 0                  | 51.833333333333336 | 61.642857142857146 |

The processed data contains useful information for visualizations (in e.g. Quicksight).