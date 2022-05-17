# Purpose

This repo is a toy project to explore Terragrunt (TG) and to identify:
- If it is as compelling as some say
- What code/configuration patterns are useful with TG.

# Some Opinions about Terragrunt based on this experiment

Terragrunt is superior to Terraform without it and provides
advantages over vanilla Terraform, Cloud or Enterprise TF.
Reasons:
- Faster execution
  Terragrunt, by design, supports isolating modules by directory in a way that allows you to run
  only one sub-section of dependencies, while pulling in the output from other dependencies without
  requiring that you re-process those dependencies.
- Better reduction of "blast radius"
  If you want to be sure you are only messing with a K8S cluster, and can't affect another system,
  that is EASY to do.
- Better Variable/Include functionality
  Terragrunt adds some nice features for injecting variables (read up on TG and this code).

Terragrunt can be seen as a pre-processor that adds a bunch of things
Terraform should include but doesn't. It has added some things since TG was made,
but not all.

Do not think that TF "workspaces" addresses the things TG does.
Hashicorp even states that workspaces do not address dev/prod config management, for example.

# Details of this code

This code experiments with a single configuration file.
"The" configuration file is in ./_modules/omnibus-module/main.tf

IMO, this pattern has the following tradeoffs:
- PROS:
  - Useful for rapid development
  - Easy to read
- CONS:
  - Does not minimize "blast radius" as much as the conventional method of creating
    a directory structure that reflects the physical resources (especially
    the geography and network) being deployed.

# Code Description

The top-level terragrunt.hcl file is here so that it can be found
and serve as a base path for finding other things.

This allows us to support global/common settings.

The most important of these is the common remote (S3/Dyanmo)
backend for the whole project.

## NOTE
Terragrunt does not require S3, it just defaults to using it.
You can change the way TG manages the backend.

# Running the code

## Basic
git clone <this-repo>
make

## This will do
cd ./multi-cloud/non-prod/multi-region/dev/omnibus && make

The Makefile is designed to be:
- idempotent
- a reference guide on the relevant commands
