locals {
  post_sql_scripts_bucket_prefix = "post-sql-scripts"
}

resource "aws_s3_object" "post_sql_scripts" {
  for_each = var.post_sql_scripts
  bucket   = aws_s3_bucket.refresh_bucket.id
  key      = "${local.post_sql_scripts_bucket_prefix}/${each.key}.sql"
  source   = each.value.path
  etag     = filemd5(each.value.path)
}