variable "account_ids" {
  description = "List of account IDs allowed to utilise key."
  default     = []
}

variable "trailName" {
  description = "AWS CloudTrail Name"
  default     = "awscbtrail"
}

variable "trailBucket" {
  description = "AWS CloudTrail Bucket to store log data"
  default     = "awscbcloudtrail"
}

variable "trailQueueName" {
  description = "AWS SQS Queue Name to write messages for Sentinel"
  default     = "awscbcloudtrailqueue"
}