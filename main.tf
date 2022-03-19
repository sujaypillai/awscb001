# 3.64.0 version provides MRK
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.64.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# Singapore
provider "aws" {
  region = "ap-southeast-1"
}

# Sydney
provider "aws" {
  alias  = "secondary"
  region = "ap-southeast-2"
}

# Jakarta
# Terraform AWS Provider v3.70.0 release will use AWS SDK v1.42.23 which adds  
# ap-southeast-3 to the list of regions for the standard AWS partition.
# https://github.com/hashicorp/terraform-provider-aws/issues/22252
provider "aws" {
  alias  = "tertiary"
  region = "ap-southeast-3"
  skip_region_validation = true
}


resource "aws_kms_key" "primary" {
  description         = "CMK for AWS CB Blog"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.kms.json
  multi_region        = true
}

resource "aws_kms_alias" "alias" {
  target_key_id = aws_kms_key.primary.id
  name          = format("alias/%s", lower("AWS_CB_CMK"))
}

resource "aws_kms_replica_key" "secondary" {
  provider = aws.secondary

  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = aws_kms_key.primary.arn
}

resource "aws_kms_replica_key" "tertiary" {
  provider = aws.tertiary

  description             = "Multi-Region replica key"
  deletion_window_in_days = 7
  primary_key_arn         = aws_kms_key.primary.arn
}

data "aws_iam_policy_document" "kms" {
  # Allow root users full management access to key
  statement {
    effect = "Allow"
    actions = [
      "kms:*"
    ]

    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"] 
    }
  }

  # Allow other accounts limited access to key
  statement {
    effect = "Allow"
    actions = [
      "kms:CreateGrant",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]

    # AWS account IDs that need access to this key
    principals {
      type        = "AWS"
      identifiers = var.account_ids
    }
  }
}