# This facilitates development

.PHONY=default clean-all clean init plan apply build delete

# Force make to run targets sequentially
.NOTPARALLEL:

# default shell (for push/pop etc)
SHELL=/bin/bash

TG=terragrunt

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
	$(TG) show -json -no-color terraform.tfstate  | jq . | tee ~/.tf-show-state.json

show-plan:
	echo "Showing plan (with colors to highlight changes)"
	$(TG) show .tfplan # Show colors to highlight changes
	$(TG) show .tfplan -no-color > ~/.tf-plan.log # For review in an editor

show-apply-log:
	echo "Showing results of the last apply"
	cat ~/.tf-apply.log

################################################################################
# Targets called by default 'make'  runs
################################################################################

clean:
	time $(TG) destroy -auto-approve 2>&1 | tee ~/.tf-destroy.log
	rm -f .tfplan

#init: 
#	$(TG) init # 'terraform init' is safe to run at any time, but not 'terragrunt init'

# This is necessary if the module source (contents or paths) are changed
update:
	terragrunt get -update

plan: update
	$(TG) validate
	terraform fmt -check || echo 'Run "terraform fmt" to standardize your files so that this will not fail'
	$(TG) plan -out=.tfplan
#	terragrunt run-all plan -out=.tfplan

apply: plan
	time $(TG) apply .tfplan --terragrunt-log-level debug --terragrunt-debug 2>&1 | tee ~/.tf-apply.log
	cat ./terragrunt-debug.tfvars.json | jq . # Show vars actually used
