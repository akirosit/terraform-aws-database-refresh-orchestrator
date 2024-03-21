# Description: This file is used to create SNS topic used to send notification messages fron the step function

resource "aws_sns_topic" "refresh" {
  count = var.sns_topic_arn == null ? 1 : 0
  name  = local.name_cc
}

locals {
  sns_topic_arn = var.sns_topic_arn == null ? aws_sns_topic.refresh[0].arn : var.sns_topic_arn
}