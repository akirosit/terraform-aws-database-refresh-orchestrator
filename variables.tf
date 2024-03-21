variable "vpc_id" {
  description = "The VPC ID (where lambda functions will be deployed)"
}

variable "vpc_cidr" {
  description = "The VPC CIDR (where lambda functions will be deployed)"
}

variable "private_subnets_ids" {
  description = "The private subnets IDs (where lambda functions will be deployed)"
  type        = list(string)
}

variable "databases_to_refresh" {
  type = map(object({
    SourceCluster            = string
    SourceClusterArn         = string
    SourceDBSubnetGroup      = string
    SourceDBSubnetGroupArn   = string
    SourceDBSecurityGroupArn = string
    SourceDBKmsKeyId         = string
    Cluster                  = string
    ClusterArn               = string
    ClusterInstance          = string
    ClusterInstanceArn       = string
    ParameterGroup           = string
    DBSubnetGroup            = string
    DBSubnetGroupArn         = string
    DBSecurityGroup          = string
    DBSecurityGroupArn       = string
    DbInstanceClass          = string
    KmsKeyId                 = string
  }))
}

variable "post_sql_scripts" {
  description = "The post SQL scripts to be executed"
  type = map(object({
    path = string
  }))
}

variable "sns_topic_arn" {
  description = "Existing SNS topic ARN to send notifications"
  type        = string
  default     = null
}

variable "create_s3_bucket" {
  description = "Create S3 bucket to put lambdas, sql scripts and step function input json files"
  type        = bool
  default     = false
}
variable "put_step_function_input_json_files_on_s3" {
  description = "Push or not step function input json files to S3 bucket"
  type        = bool
  default     = false
}
variable "s3_bucket_name" {
  description = "Name of the bucket s3 created within this module or existing S3 name to put lambdas, sql scripts and step function input json files"
  type        = string
  default     = null
}
