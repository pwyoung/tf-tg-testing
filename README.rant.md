# Purpose
The folder structure from ../aws/accounts and below
is designed to support Terragrunt's way of specifying
overrides. That is:
  - A folder structure that generally reflects the physical environments
  - A config file per directory that overrides the elements that differ at that level.

Rant:
- I really liked Hiera with Puppet and the way they managed modules to achieve this without
  forcing a particular folder structure. However, this approach is more necessary since
  the Terraform AWS Provider's design practically forces it (for legacy reasons).
- Per https://github.com/hashicorp/terraform/issues/16967#issuecomment-1063328148
  Terraform/Hashicorp seems to prefer having a directory in the terraform code per AWS Region
  even though other providers, like Google do not require it, and
  other providers, like Helm/K8S providers, would benefit from "count/foreach" in the Provider statement.
