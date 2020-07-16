#!/bin/bash

function=$1
input=$2
./mfa.sh "serverless invoke local -f $function -p $input" $3
