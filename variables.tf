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
variable "source_cluster" {
  description = "The source cluster to be refreshed"
  type        = string
}

variable "restore_type" {
  description = "Restore type: 'from-snapshot' or 'fast-clone'"
  type        = string
  default     = "from-snapshot"
}

variable "delete_old_cluster" {
  description = "Delete old cluster after refresh"
  type        = bool
  default     = false
}

variable "rename_old_cluster" {
  description = "Rename old cluster after refresh"
  type        = bool
  default     = false
}

variable "rename_cluster" {
  description = "Rename the cluster after refresh"
  type        = bool
  default     = true
}

variable "refresh_cluster" {
  description = "The cluster to be refreshed/created"
  type        = string
}

variable "refresh_cluster_already_exist" {
  description = "The cluster to be refreshed/created already exist"
  type        = bool
  default     = true
}

variable "refresh_instance_class" {
  description = "The instance class of the cluster to be refreshed/created"
  type        = string
  default     = null
}

variable "aurora_serverless_min_capacity" {
  description = "Aurora Serverless min capacity"
  type        = number
  default     = 0.5
}

variable "aurora_serverless_max_capacity" {
  description = "Aurora Serverless max capacity"
  type        = number
  default     = 2
}

variable "run_pre_sql_scripts" {
  description = "Run pre SQL scripts on old cluster (that will be deleted/restored)"
  type        = bool
  default     = false
}

variable "pre_sql_scripts" {
  description = "The pre SQL scripts to be executed on old cluster (that will be deleted/restored)"
  type = map(object({
    path = string
  }))
}
variable "old_database_name" {
  description = "Old database name"
  type        = string
}

variable "run_post_sql_scripts" {
  description = "Run post SQL scripts on new/refreshed cluster"
  type        = bool
  default     = false
}

variable "post_sql_scripts" {
  description = "The post SQL scripts to be executed"
  type = map(object({
    path = string
  }))
}

variable "rotate_database_users_secrets" {
  description = "Rotate database users secrets"
  type        = bool
  default     = false
}

variable "rotate_database_exclude_characters" {
  description = "Exclude characters from password"
  type        = string
  default     = "/@\"'\\"
}

variable "jdbc_options" {
  description = "JDBC options to include in jdbcUrl connection string in the mysql user secret"
  type        = string
  default     = ""
}

variable "database_users_secrets" {
  description = "Database users secrets IDs"
  type = list(object({
    Username       = string
    SecretId       = string
    SourceSecretId = string
  }))
  default = []
}

variable "database_name" {
  description = "Database name"
  type        = string
}

variable "run_mysqldump_old_cluster" {
  description = "Run MySQL dump on old cluster"
  type        = bool
  default     = false
}

variable "mysql_tables" {
  description = "MySQL Tables to dump/restore"
  type = list(object({
    Database = string
    Table    = string
  }))
  default = []
}

variable "eks_role_arn" {
  description = "EKS role ARN assumed by Step Function to run mysqldump/restore job"
  type        = string
  default     = ""
}

variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = ""
}

variable "eks_namespace" {
  description = "EKS namespace"
  type        = string
  default     = ""
}

variable "eks_node_selector" {
  description = "EKS node selector"
  type        = map(string)
  default     = {}
}

variable "eks_tolerations" {
  description = "EKS tolerations"
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "efs_name" {
  description = "EFS name - PV claim name to store dump files"
  type        = string
  default     = ""
}

variable "run_mysqlimport_cluster" {
  description = "Run MySQL import on new/refreshed cluster"
  type        = bool
  default     = false
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

variable "encrypted" {
  description = "New/refresh cluster is encrypted"
  default     = false
}

variable "kms_key_id" {
  description = "KMS key to encrypt new/refresh cluster"
  type        = string
  default     = null
}

variable "master_user_kms_key_id" {
  description = "KMS key use to encrypt Cluster Maser User credentials"
  type        = string
  default     = null
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "env_name" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}