# Terraform-Azure

## terraform init
The terraform init command initializes a working directory containing Terraform configuration files.

## terraform plan
The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure. By default, when Terraform creates a plan it:
    - Reads the current state of any already-existing remote objects to make sure that the Terraform state is up-to-date.
    - Compares the current configuration to the prior state and noting any differences.
    - Proposes a set of change actions that should, if applied, make the remote objects match the configuration.

## terraform apply
The terraform apply command executes the actions proposed in a Terraform plan.

## terraform destroy
The terraform destroy command is a convenient way to destroy all remote objects managed by a particular Terraform configuration.
