#!/usr/bin/env bash
echo "BASH_VERSION=${BASH_VERSION}"

# Where this script lives
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RESTAPI_DIR=$(realpath "$SCRIPT_DIR/../..")

# Bring in command line arguments
. "${SCRIPT_DIR}/setup_build_env_argbash.sh"

# set -xv

# Run this script by sourcing it, not by running it directly

if [ -z "${CLOUDABILITY_HOME}" ]; then
  echo "You must set CLOUDABILITY_HOME to point to your git clone of slater api"
  return 1
else
  cd "${CLOUDABILITY_HOME}"
  source venv/bin/activate
fi

if [ "${_arg_use_xray}" == "on" ]; then
  export AWS_XRAY_CONTEXT_MISSING="LOG_ERROR"   # disables xray decoration for local testing
  export AWS_XRAY_SDK_ENABLED=True              # disables xray decoration for local testing
else
  export AWS_XRAY_CONTEXT_MISSING="LOG_ERROR"   # disables xray decoration for local testing
  export AWS_XRAY_SDK_ENABLED=False             # disables xray decoration for local testing
fi

if [ "${_arg_use_ec2}" == "on" ]; then
  export AWS_SHARED_CREDENTIALS_FILE=/dev/null  # point aws api to aws-runas --ec2, not ~/.aws/credentials|config
else
  unset AWS_SHARED_CREDENTIALS_FILE
fi

echo "xray=${_arg_use_xray}"
echo "ec2=${_arg_use_ec2}"