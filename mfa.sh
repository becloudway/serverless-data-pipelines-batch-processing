#!/bin/bash

# set this to you personal mfa url
arn=arn:aws:iam::343030928329:mfa/sam

# gets secure session information from aws
response=$(aws sts get-session-token --serial-number $arn --token-code $2)

# set variables for secure session
export AWS_ACCESS_KEY_ID=$(jq -r '.Credentials.AccessKeyId' <<< "$response")
export AWS_SECRET_ACCESS_KEY=$(jq -r '.Credentials.SecretAccessKey' <<< "$response")
export AWS_SESSION_TOKEN=$(jq -r '.Credentials.SessionToken' <<< "$response")

# execute given command
$1
