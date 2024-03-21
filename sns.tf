# Description: This file is used to create SNS topic used to send notification messages fron the step function

resource "aws_sns_topic" "refresh" {
  count = var.sns_topic_arn ? 0 : 1
  name  = local.name_cc
}

locals {
  sns_topic_arn = var.sns_topic_arn ? var.sns_topic_arn : aws_sns_topic.refresh[0].arn
}