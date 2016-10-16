#!/bin/bash

. ../lib.sh


APP=Lambda-Monkey-ECR-Janitor

set -x

aws lambda delete-function \
  --function-name ${APP}

aws iam delete-role-policy \
  --role-name ${APP} \
  --policy-name ${APP}

aws iam delete-role \
  --role-name ${APP}

