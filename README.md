# Learn Terraform data sources
Follow along [with this Hashicorp tutorial](https://developer.hashicorp.com/terraform/tutorials/configuration-language/data-sources).

## Goals
* Terraform data sources allows
  * importing data into your Terraform configuration

## Prerequisites
* Terraform [v1.2+](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed locally
* AWS account with [associated credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
  * via
    * add in the 'provider' block
    * environment variables
      * 'AWS_ACCESS_KEY_ID'
      * 'AWS_SECRET_ACCESS_KEY'
      * 'AWS_REGION'
    * credential files
      * `aws config` & pass the 'AWS_ACCESS_KEY_ID' & 'AWS_SECRET_ACCESS_KEY'
* [HCP account](https://app.terraform.io/session)
  * to retrieve the terraform_remote_state -- from -- [this IaC repo](https://github.com/dancer1325/terraform-tutorial-data-sources-vpc)
  * TODO:

## How to run?
* `terraform init`
* `terraform plan`
* `terraform apply`
  * Problems:
    * Problem1: Error: Required token could not be found
      * Solution: Uncomment terraform.cloud & Create HCP account TODO:
* `curl $(terraform output -raw lb_url)`
  * Check that you can access to elastic load balancer
* `terraform destroy`

## Notes
* [terraform_remote_state](https://developer.hashicorp.com/terraform/language/state/remote-state-data)
  * allows
    * loading state data -- from -- workspace & organization