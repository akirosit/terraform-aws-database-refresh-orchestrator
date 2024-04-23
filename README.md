# Terraform Module 

This is a Terraform module for deploying the database refresh orchestrator on AWS.

## How to Use This Module

Basic Example :

```hcl
module "refresh_database" {
  source = "akirosit/database-refresh-orchestrator/aws"

  # Network informations
  vpc_id              = "vpc-XXX"
  vpc_cidr            = "10.42.0.0/16"
  private_subnets_ids = [ "subnet-xxx", "subnet-yyy"] # used for lambda deployment

  # Main informations
  source_cluster                = "aurora-prod"
  delete_old_cluster            = false
  rename_cluster                = false
  refresh_cluster               = "aurora-preprod"
  refresh_instance_class        = "r5.large"
  refresh_cluster_already_exist = true

  # S3 Bucket
  # For refresh inputs and SQL scripts
  create_s3_bucket                         = false
  s3_bucket_name                           = "refresh-xxx"
  put_step_function_input_json_files_on_s3 = true

  # PRE Restore
  # SQL Scripts
  run_pre_sql_scripts = true
  old_database_name   = "old_db_name"
  pre_sql_scripts = {
    "script_before.sql"
      path = "sql_scripts/script_before.sql"
    }
  }

  # POST Restore
  # SQL Scripts
  run_post_sql_scripts = true
  database_name        = "db_name"
  post_sql_scripts = {
    "script_after.sql"
      path = "sql_scripts/script_after.sql"
    }
  }

  # Manage MySQL User
  # with Secret Manager
  rotate_database_users_secrets = true
  database_users_secrets = [
    {
      Username       = "mysql_username"
      SecretId       = "/app/env/aurora-preprod/mysql_username"
      SourceSecretId = "/app/env/aurora-prod/mysql_username"
    }
  ]

  # Tags
  app_name = "refresh"
  env_name = "preprod"
  tags = {
    Name            = "efs-1"
    CostCenter      = "CCXXYYY"
  }
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |
| <a name="provider_github"></a> [github](#provider\_github) | ~> 6.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name | `string` | n/a | yes |
| <a name="input_create_s3_bucket"></a> [create\_s3\_bucket](#input\_create\_s3\_bucket) | Create S3 bucket to put lambdas, sql scripts and step function input json files | `bool` | `false` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database name | `string` | n/a | yes |
| <a name="input_database_users_secrets"></a> [database\_users\_secrets](#input\_database\_users\_secrets) | Database users secrets IDs | <pre>list(object({<br>    Username       = string<br>    SecretId       = string<br>    SourceSecretId = string<br>  }))</pre> | `[]` | no |
| <a name="input_delete_old_cluster"></a> [delete\_old\_cluster](#input\_delete\_old\_cluster) | Delete old cluster after refresh | `bool` | `false` | no |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted) | New/refresh cluster is encrypted | `bool` | `false` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Environment name | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS key to encrypt new/refresh cluster | `string` | `null` | no |
| <a name="input_master_user_kms_key_id"></a> [master\_user\_kms\_key\_id](#input\_master\_user\_kms\_key\_id) | KMS key use to encrypt Cluster Maser User credentials | `string` | `null` | no |
| <a name="input_old_database_name"></a> [old\_database\_name](#input\_old\_database\_name) | Old database name | `string` | n/a | yes |
| <a name="input_post_sql_scripts"></a> [post\_sql\_scripts](#input\_post\_sql\_scripts) | The post SQL scripts to be executed | <pre>map(object({<br>    path = string<br>  }))</pre> | n/a | yes |
| <a name="input_pre_sql_scripts"></a> [pre\_sql\_scripts](#input\_pre\_sql\_scripts) | The pre SQL scripts to be executed on old cluster (that will be deleted/restored) | <pre>map(object({<br>    path = string<br>  }))</pre> | n/a | yes |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | The private subnets IDs (where lambda functions will be deployed) | `list(string)` | n/a | yes |
| <a name="input_put_step_function_input_json_files_on_s3"></a> [put\_step\_function\_input\_json\_files\_on\_s3](#input\_put\_step\_function\_input\_json\_files\_on\_s3) | Push or not step function input json files to S3 bucket | `bool` | `false` | no |
| <a name="input_refresh_cluster"></a> [refresh\_cluster](#input\_refresh\_cluster) | The cluster to be refreshed/created | `string` | n/a | yes |
| <a name="input_refresh_cluster_already_exist"></a> [refresh\_cluster\_already\_exist](#input\_refresh\_cluster\_already\_exist) | The cluster to be refreshed/created already exist | `bool` | `true` | no |
| <a name="input_refresh_instance_class"></a> [refresh\_instance\_class](#input\_refresh\_instance\_class) | The instance class of the cluster to be refreshed/created | `string` | `null` | no |
| <a name="input_rename_cluster"></a> [rename\_cluster](#input\_rename\_cluster) | Rename the cluster after refresh | `bool` | `true` | no |
| <a name="input_restore_type"></a> [restore\_type](#input\_restore\_type) | Restore type: 'from-snapshot' or 'fast-clone' | `string` | `"from-snapshot"` | no |
| <a name="input_rotate_database_users_secrets"></a> [rotate\_database\_users\_secrets](#input\_rotate\_database\_users\_secrets) | Rotate database users secrets | `bool` | `false` | no |
| <a name="input_run_post_sql_scripts"></a> [run\_post\_sql\_scripts](#input\_run\_post\_sql\_scripts) | Run post SQL scripts on new/refreshed cluster | `bool` | `false` | no |
| <a name="input_run_pre_sql_scripts"></a> [run\_pre\_sql\_scripts](#input\_run\_pre\_sql\_scripts) | Run pre SQL scripts on old cluster (that will be deleted/restored) | `bool` | `false` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the bucket s3 created within this module or existing S3 name to put lambdas, sql scripts and step function input json files | `string` | `null` | no |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Existing SNS topic ARN to send notifications | `string` | `null` | no |
| <a name="input_source_cluster"></a> [source\_cluster](#input\_source\_cluster) | The source cluster to be refreshed | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The VPC CIDR (where lambda functions will be deployed) | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID (where lambda functions will be deployed) | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_lambda"></a> [iam\_role\_lambda](#output\_iam\_role\_lambda) | n/a |
| <a name="output_iam_role_step_function"></a> [iam\_role\_step\_function](#output\_iam\_role\_step\_function) | n/a |
| <a name="output_refresh_bucket_id"></a> [refresh\_bucket\_id](#output\_refresh\_bucket\_id) | n/a |
| <a name="output_state_machine_name"></a> [state\_machine\_name](#output\_state\_machine\_name) | n/a |
| <a name="output_step_function_dynamodb_arn"></a> [step\_function\_dynamodb\_arn](#output\_step\_function\_dynamodb\_arn) | n/a |
| <a name="output_step_function_json_files"></a> [step\_function\_json\_files](#output\_step\_function\_json\_files) | n/a |
| <a name="output_step_function_sns_arn"></a> [step\_function\_sns\_arn](#output\_step\_function\_sns\_arn) | n/a |
| <a name="output_vpc_security_group_for_lambda"></a> [vpc\_security\_group\_for\_lambda](#output\_vpc\_security\_group\_for\_lambda) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamodbTable](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.rds_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_function_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.refresh_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.refresh_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_lambda_permission.allow_secrets_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.refresh_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.lambda_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.lambda_functions_hash](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.post_sql_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.pre_sql_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.step_function_json_input](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.step_function_json_input_hash](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.lambda_https_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.lambda_mysql_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.mysql_from_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sfn_state_machine.refresh_env](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | resource |
| [aws_sns_topic.refresh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [local_file.step_function_json_input](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.pip_install](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [archive_file.lambda_functions](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.lambda_layers](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_db_instance.refresh_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_db_instance.source_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_instance) | data source |
| [aws_db_subnet_group.refresh_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |
| [aws_db_subnet_group.source_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/db_subnet_group) | data source |
| [aws_iam_policy_document.assume_from_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_from_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_from_step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_rds_cluster.refresh_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster) | data source |
| [aws_rds_cluster.source_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_cluster) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_security_group.refresh_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [aws_security_group.source_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_group) | data source |
| [github_repository_file.lambda_functions](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository_file) | data source |
