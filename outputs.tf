output "sentinelrole" {
    value = aws_iam_role.this.arn
}

output "sqsurl" {
  value = aws_sqs_queue.sqs_queue.url
}