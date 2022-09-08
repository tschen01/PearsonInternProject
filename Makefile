.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo " "
	@echo "  where <target> is one of:"
	@echo "    - help               		- display this help message"
	@echo "    - build/<option>     		- build code artifacts; choices: validate lambda (default all)"
	@echo "    - deploy/<option>      		- package and deploy; choices: package deploy_to_aws (default all)"
	@echo "    - test/<option>      		- run tests; choices: test/purgedivvy test/debugcli test/cli test/localinvoke test/localinvokedev test/localinvokedivvydev (default all)"
	@echo "    - clean              		- clean temp/generated files"
	@echo "    - run                		- build and run API Gateway locally (not supported yet)"

.PHONY: build
build: build/validate build/lambda
build/validate:
	@echo "Running validations..."
	ci/build/validate-lambda.sh
	ci/build/validate-api-gateway.sh

build/lambda:
	@echo "Running build.sh"
	ci/build/build.sh

.PHONY: clean
clean:
	if [ -d utils/dist ]; then rm -rf utils/dist; fi
	if [ -d .aws-sam ]; then rm -rf .aws-sam; fi
	rm -f package.yaml

.PHONY: deploy
deploy: deploy/package deploy/deploy_to_aws
deploy/package:
	@echo "Running package.sh"
	ci/deploy/package.sh

deploy/deploy_to_aws:
	@echo "Running deploy.sh"
	ci/deploy/deploy.sh

.PHONY: test
test: test/purgedivvy test/debugcli test/cli test/clidev test/cliprod test/localinvoke test/localinvokeddev # test/localinvokeprod
test/purgedivvy:
	@echo "Running CLI to purgy divvy without adding joiners on localhost"
	(tests/synchronize-ldap-divvy.sh --purge_divvy --no-add_joiners)

test/cli:
	@echo "Running CLI test with defaults on localhost"
	(tests/synchronize-ldap-divvy.sh)

test/clidev:
	@echo "Running CLI test with defaults on divvy dev"
	(tests/synchronize-ldap-divvy.sh --divvy_base_url https://pearsonedu-dev.customer.divvycloud.com)

test/cliprod:
	@echo "Running CLI test with defaults on divvy production"
	(tests/synchronize-ldap-divvy.sh --divvy_base_url https://pearsonedu.customer.divvycloud.com)

test/debugcli:
	@echo "Running CLI test with defaults in localhost"
	(LOG_LEVEL=debug bash -c tests/synchronize-ldap-divvy.sh)

test/localinvoke:
	@echo "Validating lambda"
	./ci/build/validate-lambda.sh
	@echo "Running sam local invoke DivvyGroupsRolesSyncFunction -e events/development_test_maximal.json --env-vars env.json"
	(sam local invoke DivvyGroupsRolesSyncFunction --region us-east-1 --event events/localhost_test_maximal.json --env-vars env.json)

test/localinvokedev:
	@echo "Validating lambda"
	./ci/build/validate-lambda.sh
	@echo "Running sam local invoke DivvyGroupsRolesSyncFunction -e events/divvydev_test_minimal.json --env-vars env.json"
	(sam local invoke DivvyGroupsRolesSyncFunction --region us-east-1 --docker-network host --event events/divvydev_test_minimal.json --env-vars env.json --debug)

.PHONY: run
run:
	@echo "Launching local API gateway (not supported yet)"
	#./local/start-api-gateway.sh
