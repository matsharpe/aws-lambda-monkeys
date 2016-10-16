#!/bin/bash

cd $(dirname $(readlink -f $0))

. ../lib.sh

APP=Lambda-Monkey-ECR-Janitor
SCRIPT=ecr-janitor

set -x

# Create a role for the lambda and apply the policy to it
aws iam create-role \
  --role-name ${APP} \
  --assume-role-policy-document file://role-trust-policy.json

aws iam put-role-policy \
  --role-name ${APP} \
  --policy-name ${APP} \
  --policy-document file://role-policy.json

# Sleep to allow iam to propagate the role
sleep 5

# Package the code for upload
zip code.zip ${SCRIPT}.py

aws lambda create-function \
  --function-name ${APP} \
  --runtime python2.7 \
  --role arn:aws:iam::${ACCOUNT_NUM}:role/${APP} \
  --handler ${SCRIPT}.lambda_handler \
  --publish \
  --zip-file fileb://code.zip

rm code.zip

# Sleep to allow lambda to propagate the new function internally.
sleep 5

aws lambda update-function-configuration \
  --function-name ${APP} \
  --timeout 120

# Setup Schedule
aws events put-rule \
  --name ${APP} \
  --schedule-expression "cron(0 4 * * ? *)"

aws lambda add-permission \
    --statement-id "${APP}_statement" \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn arn:aws:events:${AWS_DEFAULT_REGION}:${ACCOUNT_NUM}:rule/${APP} \
    --function-name function:${APP}

aws events put-targets \
  --rule ${APP} \
  --targets "{ \"Id\": \"Id${ACCOUNT_NUM}\", \"Arn\": \"arn:aws:lambda:${AWS_DEFAULT_REGION}:${ACCOUNT_NUM}:function:${APP}\" }"

# Set up logging group and add 14 day expiry
aws logs create-log-group --log-group-name /aws/lambda/${APP}
aws logs put-retention-policy --log-group-name /aws/lambda/${APP} --retention-in-days 14
