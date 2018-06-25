#!/usr/bin/env bash
INPUT=`jq -r .`
GROUP_NAME=`echo ${INPUT} | jq -r '.group_name'`
AWS_PROFILE=`echo ${INPUT} | jq -r '.aws_profile'`
aws iam get-group --group-name ${GROUP_NAME} --profile ${AWS_PROFILE} | jq -r '.Users[].UserName | [.] | join(",") | {users: .}'