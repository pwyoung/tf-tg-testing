# This facilitates development

.PHONY=default FORCE clean check plan apply
.PHONY+=show-plan show-apply-log update
.PHONY+=clean-all check-aws remove-backend show-state

# Force make to run targets sequentially
.NOTPARALLEL:

# default shell (for push/pop etc)
SHELL=/bin/bash

# The first target will be called by 'make' with no args.
# Name it 'default' for readability.
default: apply

################################################################################
# These are convenience targets, not called by default
################################################################################

# This forces a target to run even if there is a file in the local dir with the 
# name of the target. Also, this is good for readability
FORCE:

format: FORCE
	cd ../../.. && terraform fmt -recursive # Terragrunt is not great at this
	terragrunt hclfmt ./terragrunt.hcl

# TG does not clean up its backend
#   https://github.com/gruntwork-io/terragrunt/issues/250
clean-all: clean
	rm -rf ./.terraform
	rm -f ./.terraform.lock.hcl
	rm -f ./terraform.tfstate*


check-aws: FORCE
	$(info Check that the AWS ClI is working, and which user is connecting)
	aws sts get-caller-identity | jq .

remove-backend: FORCE
	rm backend.tf

show-state: FORCE
	echo "Showing current state and saving to ~/.tf-show-state without colors, since they hose some editors"
	terragrunt show -json -no-color terraform.tfstate  | jq . | tee ~/.tf-show-state.json

show-plan: FORCE
	echo "Showing plan (with colors to highlight changes)"
	terragrunt show .tfplan # Show colors to highlight changes
	terragrunt show .tfplan -no-color > ~/.tf-plan.log # For review in an editor

show-apply-log: FORCE
	echo "Showing results of the last apply"
	cat ~/.tf-apply.log

# Leave this as a reminder to NEVER manually run "terragrunt init" since it will
# wipe out terragrunt's cache and lose track of resources it already created.
#
#init: 
#	$(TG) init # 'terraform init' is safe to run at any time, but not 'terragrunt init'

# This is necessary if the module source (contents or paths) are changed
update: FORCE
	terragrunt get -update

################################################################################
# Targets called by default 'make'  runs
################################################################################
clean: FORCE
	time terragrunt destroy -auto-approve 2>&1 | tee ~/.tf-destroy.log
	rm -f .tfplan

check: FORCE
	terragrunt validate
	terraform fmt -check || echo 'Run "terraform fmt" to standardize your files so that this will not fail'

plan: check
#	terragrunt plan -out=.tfplan
	terragrunt run-all plan -out=.tfplan

apply: plan
	time terragrunt apply .tfplan --terragrunt-log-level debug --terragrunt-debug 2>&1 | tee ~/.tf-apply.log
	cat ./terragrunt-debug.tfvars.json | jq . # Show vars actually used
