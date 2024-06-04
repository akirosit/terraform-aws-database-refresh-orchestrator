# Purpose: Create an S3 bucket to store the lambda functions

resource "aws_s3_bucket" "refresh_bucket" {
  count         = var.create_s3_bucket ? 1 : 0
  bucket        = var.s3_bucket_name == null ? null : var.s3_bucket_name
  bucket_prefix = var.s3_bucket_name == null ? local.name : null
  force_destroy = true
}

locals {
  refresh_bucket_id = var.s3_bucket_name == null ? aws_s3_bucket.refresh_bucket[0].id : var.s3_bucket_name
  lambdas_path      = "${path.module}/lambdas"
  lambdas_s3_path   = "lambdas/${local.current_region}/${var.app_name}-${var.env_name}"
  lambda_local_functions = {
    for lambda_name, lambda in local.lambda_functions :
    lambda_name => lambda if lambda.type == "file"
  }
  lambda_github_functions = {
    for lambda_name, lambda in local.lambda_functions :
    lambda_name => lambda if lambda.type == "github_file"
  }
}

#
# layers
#
resource "null_resource" "pip_install" {
  for_each = toset(local.lambda_layers)
  triggers = {
    shell_hash = "${sha256(file("${local.lambdas_path}/layers/${each.key}/requirements.txt"))}"
  }
  # https://github.com/jpadilla/pyjwt/issues/800
  # https://repost.aws/fr/knowledge-center/lambda-python-package-compatible
  provisioner "local-exec" {
    command = <<EOT
    python3 -m pip --isolated \
    install -r ${local.lambdas_path}/layers/${each.key}/requirements.txt \
    --platform manylinux2014_aarch64 \
    --implementation cp \
    --python-version ${local.python_version_short} \
    --only-binary=:all: --upgrade \
    -t ${local.lambdas_path}/layers/${each.key}/python
    EOT
  }
}

data "archive_file" "lambda_layers" {
  for_each    = null_resource.pip_install
  type        = "zip"
  source_dir  = "${local.lambdas_path}/layers/${each.key}/"
  output_path = "${local.lambdas_path}/layers/${each.key}.zip"
}

#
# github functions
#
data "github_repository_file" "lambda_functions" {
  for_each   = local.lambda_github_functions
  repository = each.value.repository
  branch     = each.value.branch
  file       = each.value.path
}

output "lambda_github" {
  value = data.github_repository_file.lambda_functions
}

#
# local functions
#
data "archive_file" "lambda_functions" {
  for_each                = local.lambda_functions
  type                    = "zip"
  source_file             = each.value.type == "file" ? each.value.path : null
  source_content          = each.value.type == "github_file" ? data.github_repository_file.lambda_functions[each.key].content : null
  source_content_filename = each.value.type == "github_file" ? "${each.key}.py" : null
  output_file_mode        = "0666"
  output_path             = "${local.lambdas_path}/${each.key}.zip"
}

resource "aws_s3_object" "lambda_functions" {
  for_each = data.archive_file.lambda_functions
  bucket   = local.refresh_bucket_id
  key      = "${local.lambdas_s3_path}/${each.key}.zip"
  source   = each.value.output_path
  etag     = each.value.output_md5
}

resource "aws_s3_object" "lambda_functions_hash" {
  for_each = data.archive_file.lambda_functions
  bucket   = local.refresh_bucket_id
  key      = "${local.lambdas_s3_path}/${each.key}.zip.base64sha256"
  content  = each.value.output_base64sha256
}

