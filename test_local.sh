#!/bin/bash

function=$1
./mfa.sh "serverless invoke local -f $function" $2
