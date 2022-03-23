resource "aws_cloudtrail" "default" {
  name                          = var.trailName
  s3_bucket_name                = var.trailBucket
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  kms_key_id                    = aws_kms_key.primary.arn
  depends_on = [
    aws_s3_bucket.cloudtrailbucket,
    aws_kms_key.primary
  ]
}


resource "aws_s3_bucket" "cloudtrailbucket" {
  bucket = var.trailBucket
  depends_on = [
    aws_kms_key.primary
  ]
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.primary.id
        sse_algorithm     = "aws:kms"
      }
      bucket_key_enabled = "false"
    }
  }
  object_lock_configuration {
    object_lock_enabled = "Enabled"
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": [
                "arn:aws:s3:::${var.trailBucket}"
            ]
        },
        {
            "Sid": "AWSCloudTrailWriteAccount",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.trailBucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control",
                    "AWS:SourceArn" : "arn:aws:cloudtrail:ap-southeast-1:${data.aws_caller_identity.current.account_id}:trail/${var.trailName}"
                }
            }
        },
        {
            "Sid" : "AWSCloudTrailWriteOrganization",
            "Effect" : "Allow",
            "Principal" : {
                "Service" : "cloudtrail.amazonaws.com"
            },
            "Action" : "s3:PutObject",
            "Resource" : "arn:aws:s3:::${var.trailBucket}/AWSLogs/${data.aws_organizations_organization.myorg.id}/*",
            "Condition" : {
                "StringEquals" : {
                    "s3:x-amz-acl" : "bucket-owner-full-control",
                    "AWS:SourceArn" : "arn:aws:cloudtrail:ap-southeast-1:${data.aws_caller_identity.current.account_id}:trail/${var.trailName}"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket                  = aws_s3_bucket.cloudtrailbucket.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}