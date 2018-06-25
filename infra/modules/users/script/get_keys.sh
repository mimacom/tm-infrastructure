#!/usr/bin/env bash
INPUT=`jq -r .`
USER_NAME=`echo ${INPUT} | jq -r '.user_name'`
AWS_PROFILE=`echo ${INPUT} | jq -r '.aws_profile'`
PUBLIC_KEY_ID=`aws iam list-ssh-public-keys --user-name "${USER_NAME}" --profile ${AWS_PROFILE} | jq -r '.SSHPublicKeys[0].SSHPublicKeyId'`
aws iam get-ssh-public-key \
    --user-name "${USER_NAME}" \
    --ssh-public-key-id "${PUBLIC_KEY_ID}" \
    --encoding SSH \
    --profile mimacom \
    | jq -r ".SSHPublicKey.SSHPublicKeyBody | {user_name: \"${USER_NAME}\", ssh_public_key: .}"

