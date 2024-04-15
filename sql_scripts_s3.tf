locals {
  post_sql_scripts_bucket_prefix = "sql-scripts/${local.current_region}/${var.app_name}-${var.env_name}"
}

resource "aws_s3_object" "post_sql_scripts" {
  for_each = var.post_sql_scripts
  bucket   = local.refresh_bucket_id
  key      = "${local.post_sql_scripts_bucket_prefix}/${each.key}"
  content  = templatefile(each.value.path, local.step_function_input)
  etag     = filemd5(each.value.path)
}

resource "aws_s3_object" "pre_sql_scripts" {
  for_each = var.pre_sql_scripts
  bucket   = local.refresh_bucket_id
  key      = "${local.post_sql_scripts_bucket_prefix}-old/${each.key}"
  content  = templatefile(each.value.path, local.step_function_input)
  etag     = filemd5(each.value.path)
}