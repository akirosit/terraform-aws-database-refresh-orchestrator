# Terraform Module 

This is a Terraform module for deploying the database refresh orchestrator on AWS.

## How to Use This Module

Basic Example :

```hcl
module "refresh_efs" {
  source = "akirosit/efs-refresh-orchestrator/aws"

  efs_to_refresh = {
    "app" = {
      SourceEFSName = aws_efs_file_system.prod.creation_token
      EFSName       = aws_efs_file_system.preprod.creation_token
      EFSArn        = aws_efs_file_system.preprod.arn
      Encrypted     = true
      KmsKeyId      = aws_kms_alias.efs_preprod.arn
    }
  }
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databases_to_refresh"></a> [databases\_to\_refresh](#input\_databases\_to\_refresh) | n/a | <pre>map(object({<br>    SourceCluster            = string<br>    SourceClusterArn         = string<br>    SourceDBSubnetGroup      = string<br>    SourceDBSubnetGroupArn   = string<br>    SourceDBSecurityGroupArn = string<br>    SourceDBKmsKeyId         = string<br>    Cluster                  = string<br>    ClusterArn               = string<br>    ClusterInstance          = string<br>    ClusterInstanceArn       = string<br>    ParameterGroup           = string<br>    DBSubnetGroup            = string<br>    DBSubnetGroupArn         = string<br>    DBSecurityGroup          = string<br>    DBSecurityGroupArn       = string<br>    DbInstanceClass          = string<br>    KmsKeyId                 = string<br>  }))</pre> | n/a | yes |
| <a name="input_post_sql_scripts"></a> [post\_sql\_scripts](#input\_post\_sql\_scripts) | The post SQL scripts to be executed | <pre>map(object({<br>    path = string<br>  }))</pre> | n/a | yes |
| <a name="input_private_subnets_ids"></a> [private\_subnets\_ids](#input\_private\_subnets\_ids) | The private subnets IDs (where lambda functions will be deployed) | `list(string)` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | Existing SNS topic ARN to send notifications | `string` | `null` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The VPC CIDR (where lambda functions will be deployed) | `any` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC ID (where lambda functions will be deployed) | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_lambda"></a> [iam\_role\_lambda](#output\_iam\_role\_lambda) | n/a |
| <a name="output_iam_role_step_function"></a> [iam\_role\_step\_function](#output\_iam\_role\_step\_function) | n/a |
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
| [aws_iam_policy.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.step_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_function_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_layer_version.layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [aws_s3_bucket.refresh_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.lambda_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.lambda_functions_hash](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.post_sql_scripts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
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
| [aws_iam_policy_document.assume_from_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_from_step_functions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.step_function_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
