# Version générique des variables pour le module de refresh de base de données
# Ce fichier remplace variables.tf

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

# Variables minimales nécessaires pour le module
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

# Variables pour le bucket S3 (optionnelles)
variable "create_s3_bucket" {
  description = "Create S3 bucket for lambda functions"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the bucket s3 created within this module or existing S3 name for lambda functions"
  type        = string
  default     = null
}

# Variables pour SNS (optionnelles)
variable "sns_topic_arn" {
  description = "Existing SNS topic ARN to send notifications"
  type        = string
  default     = null
}

# Variables conservées comme demandé
variable "rotate_database_exclude_characters" {
  description = "Exclude characters from password"
  type        = string
  default     = "/@\"'\\"
}

variable "eks_role_arn" {
  description = "EKS role ARN assumed by Step Function to run mysqldump/restore job"
  type        = string
  default     = ""
}

variable "use_jsonata_template" {
  description = "Use jsonata template to deploy step function"
  type        = bool
  default     = false
}