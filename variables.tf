variable "account_ids" {
  description = "List of account IDs allowed to utilise key."
  default     = ["435811830822"]
}

variable "trailName" {
  description = "AWS CloudTrail Name"
  default     = "awscbtrail"
}

variable "trailBucket" {
  description = "AWS CloudTrail Bucket to store log data"
  default     = "awscbcloudtrail"
}