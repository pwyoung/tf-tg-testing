# This facilitates development

.PHONY=default clean-all clean init plan apply build delete

# Force make to run targets sequentially
.NOTPARALLEL:

# default shell (for push/pop etc)
SHELL=/bin/bash

# Support easy switching between terraform and terragrunt here
#TF=terraform
#TF=terragrunt -lock=false
TF=TF_VAR_master_password=Password123 terragrunt

default: apply

################################################################################
# These are convenience targets, not called by default
################################################################################

format:
	cd ../../.. && terraform fmt -recursive # Terragrunt is not great at this
	terragrunt hclfmt ./terragrunt.hcl

# TG does not clean up its backend
#   https://github.com/gruntwork-io/terragrunt/issues/250
clean-all: clean
	rm -rf ./.terraform
	rm -f ./.terraform.lock.hcl
	rm -f ./terraform.tfstate*


check-aws:
	$(info Check that the AWS ClI is working, and which user is connecting)
	aws sts get-caller-identity | jq .

remove-backend:
	rm backend.tf

show-state:
	echo "Showing current state and saving to ~/.tf-show-state without colors, since they hose some editors"
	$(TF) show -json -no-color terraform.tfstate  | jq . | tee ~/.tf-show-state.json

show-plan:
	echo "Showing plan (with colors to highlight changes)"
	$(TF) show .tfplan # Show colors to highlight changes
	$(TF) show .tfplan -no-color > ~/.tf-plan.log # For review in an editor

show-apply-log:
	echo "Showing results of the last apply"
	cat ~/.tf-apply.log

test: apply
	. ../../../tools/util.sh && _ssh hostname

test-only:
	. ../../../tools/util.sh && _ssh hostname

################################################################################
# Targets called by default 'make'  runs
################################################################################

clean:
	if [ -e .terraform ]; then time $(TF) destroy -auto-approve 2>&1 | tee ~/.tf-destroy.log; fi
	rm -f .tfplan


validate:
	$(TF) validate # This errors with
#  Error: Missing required argument
#  The argument "region" is required, but was not set.
#
#
#	TERRAGRUNT_DISABLE_INIT=true terragrunt run-all validate # This will prompt for region


# Per https://www.terraform.io/cli/commands/init
#   "It is safe to run this command multiple times"
init: validate
	terraform fmt -check || echo 'Run "terraform fmt" to standardize your files so that this will not fail'
	$(TF) init

plan: init
	$(TF) plan -out=.tfplan
#	terragrunt run-all plan -out=.tfplan

apply: plan
	time $(TF) apply .tfplan 2>&1 | tee ~/.tf-apply.log # Keep a log of the 'apply' operation
