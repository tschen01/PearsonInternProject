# Slater Cloudability TEST

## Pre-requisites
1. [Install](https://docs.docker.com/get-docker/) Docker for your platform
2. [Install](https://docs.aws.amazon.com/cli/latest/userguide/installing.html) AWS CLI Commands
    - Use region **us-east-1**
3. [Configure](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) your local PC/mac
4. [Install](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) AWS SAM Commands
7. [Install](https://github.com/aws-cloudformation/cfn-python-lint) cfn-lint for sam template
8. [Install](https://pypi.org/project/setupext-janitor) setupext-janitor to clean sdist eggs created during local package setup.py
9. [Install jq](https://stedolan.github.io/jq/download)
10. [Install git-crypt](https://www.agwa.name/projects/git-crypt/)
11. [Install open vpn tunnel, tunnelblick](https://tunnelblick.net/index.html)
12. [Install yq](https://github.com/mikefarah/yq)
13. brew install coreutils
14. brew install bash

## Environment Setup 
```
git clone git@gitlab.com:pearson-cloud-management/cloudability/slater_to_cloudability.git
cd slater_to_cloudability
export CLOUDABILITY_SLATER_HOME=$PWD
python3.8 -m venv venv
source terminal_setup.sh
xraydev
pip install --upgrade pip 
pip install -r requirements.txt
aws-runas governator aws secretsmanager get-secret-value --secret-id "divvycloud/git-crypt-key" | jq .SecretString -r | jq '."git-crypt-key-base64"' -r | base64 -d > /tmp/git-crypt.key 
git-crypt unlock /tmp/git-crypt.key 
```

## Convenient environment re-setup.
```
source terminal_setup.sh # or just put in your .bashrc or .bash_profile
```


## Testing Synchronizer in Four Key Phases
### cleandivvy cli localinvokedev localinvokeprod
1. PyCharm localhost/production testing using test configurations
   ```
   # Edit pycharm test/debugger configurations accordingingly (green arrow and debug symbols)
   ```
4. Build and Run Local Invoke, Pointing to localhost (Not ported to Windows yet)
   ```
   make clean build test/localinvoke
   ```
5. Build and Run Local Invoke, Pointing to Divvy Dev
   ```
   # Rebuild if you change code or template.yaml
   make [clean build] localinvokedev
   ```   
6. Build, Deploy and Test on AWS (run only after success in 2)
   ```
   # Redeploy if you change code or templatey.yaml
   make [clean build] deploy
   # Test via lambda console and $CLOUDABILITY_SLATER_HOME/events/production_test_minimal.json
   ```

## Serverless Application Model (SAM) - TBD

This project contains source code and supporting files for a serverless application that you can deploy with the SAM CLI. It includes the following files and folders.

- lambdas - Code for the application's Lambda function.
- events - Invocation events that you can use to invoke the function.
- tests - Unit tests for the application code. 
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.

## Deploy the sample application

The Serverless Application Model Command Line Interface (SAM CLI) is an extension of the AWS CLI that adds functionality for building and testing Lambda applications. It uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* [Python 3 installed](https://www.python.org/downloads/)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

To build and deploy your application for the first time, run the following in your shell:

```bash
sam build --use-container
sam deploy --guided
```

The first command will build the source of your application. The second command will package and deploy your application to AWS, with a series of prompts:

* **Stack Name**: The name of the stack to deploy to CloudFormation. This should be unique to your account and region, and a good starting point would be something matching your project name.
* **AWS Region**: The AWS region you want to deploy your app to.
* **Confirm changes before deploy**: If set to yes, any change sets will be shown to you before execution for manual review. If set to no, the AWS SAM CLI will automatically deploy application changes.
* **Allow SAM CLI IAM role creation**: Many AWS SAM templates, including this example, create AWS IAM roles required for the AWS Lambda function(s) included to access AWS services. By default, these are scoped down to minimum required permissions. To deploy an AWS CloudFormation stack which creates or modified IAM roles, the `CAPABILITY_IAM` value for `capabilities` must be provided. If permission isn't provided through this prompt, to deploy this example you must explicitly pass `--capabilities CAPABILITY_IAM` to the `sam deploy` command.
* **Save arguments to samconfig.toml**: If set to yes, your choices will be saved to a configuration file inside the project, so that in the future you can just re-run `sam deploy` without parameters to deploy changes to your application.

You can find your API Gateway Endpoint URL in the output values displayed after deployment.

## Use the SAM CLI to build and test locally

Build your application with the `sam build --use-container` command.

```bash
groupsrolessync$ sam build --use-container
```

The SAM CLI installs dependencies defined in `groupsrolessync/requirements.txt`, creates a deployment package, and saves it in the `.aws-sam/build` folder.

Test a single function by invoking it directly with a test event. An event is a JSON document that represents the input that the function receives from the event source. Test events are included in the `events` folder in this project.

Run functions locally and invoke them with the `sam local invoke` command.

```bash
groupsrolessync$ sam local invoke GroupsRolesSyncFunction --event events/production_test_minimal.json
```

The SAM CLI can also emulate your application's API. Use the `sam local start-api` to run the API locally on port 3000.

```bash
groupsrolessync$ sam local start-api
groupsrolessync$ curl http://localhost:3000/synchronize
```

## Tests

Tests are defined in the `tests` folder in this project. Use PIP to install the test dependencies and run tests.

```bash
groupsrolessync$ pip install -r tests/requirements.txt --user
# unit test
groupsrolessync$ python -m pytest tests/unit -v
# integration test, requiring deploying the stack first.
# Create the env variable AWS_SAM_STACK_NAME with the name of the stack we are testing
groupsrolessync$ AWS_SAM_STACK_NAME=<stack-name> python -m pytest tests/integration -v
```

## Cleanup

To delete the sample application that you created, use the AWS CLI. Assuming you used your project name for the stack name, you can run the following:

```bash
aws cloudformation delete-stack --stack-name groupsrolessync
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.
