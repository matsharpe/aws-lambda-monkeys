#!/bin/bash

# Edit if you prefer a different region for your lambdas
export AWS_DEFAULT_REGION=eu-west-1


# Check pre-reqs are satisfied

# aws-cli installed?
if [ ! -x "$(which aws)" ]; then
  echo "Please install and configure aws-cli"
  exit 1
fi

# Basic connectivity and permissions check (save output for later)
export GET_USER=$(aws iam get-user)
if [ $? -ne 0 ]; then
  echo "Your configured aws keys don't seem to have a lot of permissions or there was a connectivity issue"
  exit 1
fi

# Check for python with json library
if [ ! -x "$(which python)" ]; then
  echo "Please install python"
  exit 1
fi

python -c 'import json' > /dev/null
if [ $? -ne 0 ]; then
  echo "Please install the Python json library"
  exit 1
fi

# Work out the account number of the currently configured AWS account from the previous get-user
# We need this for various lambda and permissions related calls later
export ACCOUNT_NUM=$(python -c "import json,os; print json.loads(os.environ.get('GET_USER'))['User']['Arn'].split(':')[4];")
if [ $? -ne 0 ]; then
  echo "Could not call determine AWS account number from 'aws iam get-user'"
  exit 1
fi

echo Running with region ${AWS_DEFAULT_REGION} on account number ${ACCOUNT_NUM}.

