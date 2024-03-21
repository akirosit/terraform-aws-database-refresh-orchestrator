locals {
  post_sql_scripts_bucket_prefix = "post-sql-scripts"
}

resource "aws_s3_object" "post_sql_scripts" {
  for_each = var.post_sql_scripts
  bucket   = local.refresh_bucket_id
  key      = "${local.post_sql_scripts_bucket_prefix}/${each.key}.sql"
  source   = each.value.path
  etag     = filemd5(each.value.path)
}