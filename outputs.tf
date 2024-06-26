output "iam_role_lambda" {
  value = aws_iam_role.lambda.arn
}

output "iam_role_step_function" {
  value = aws_iam_role.step_function.arn
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.refresh_env.arn
}

output "state_machine_name" {
  value = aws_sfn_state_machine.refresh_env.name
}

output "step_function_json_files_local_path" {
  value = local_file.step_function_json_input.filename
}

output "step_function_json_files_s3_path" {
  value = {
    for app_name, object in aws_s3_object.step_function_json_input :
    app_name => "s3://${object.bucket}/${object.key}"
  }
}

output "step_function_dynamodb_arn" {
  value = aws_dynamodb_table.dynamodbTable.arn
}

output "step_function_sns_arn" {
  value = local.sns_topic_arn
}

output "refresh_bucket_id" {
  value = local.refresh_bucket_id
}