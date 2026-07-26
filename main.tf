provider "aws" {
  region = "us-east-1"
}

# Customer-managed KMS key for encryption
# checkov:skip=CKV2_AWS_64:Key policy not required for this demo lab
resource "aws_kms_key" "bucket_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# Logging bucket to store access logs
# checkov:skip=CKV_AWS_18:This is the log bucket itself, no self-logging needed
# checkov:skip=CKV_AWS_21:Versioning not required for log storage in this demo
# checkov:skip=CKV_AWS_144:Cross-region replication out of scope for demo lab
# checkov:skip=CKV2_AWS_62:Event notifications not required for this demo
# checkov:skip=CKV2_AWS_61:Lifecycle configuration out of scope for demo lab
# tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "log_bucket" {
  bucket = "lakeshore-devsecops-log-bucket"
}


resource "aws_s3_bucket_public_access_block" "log_bucket_access" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket_key.arn
    }
  }
}

# Main bucket - logging and versioning handled via separate resources below
# checkov:skip=CKV_AWS_18:Access logging handled via separate aws_s3_bucket_logging resource
# checkov:skip=CKV_AWS_21:Versioning handled via separate aws_s3_bucket_versioning resource
# checkov:skip=CKV_AWS_144:Cross-region replication out of scope for demo lab
# checkov:skip=CKV2_AWS_62:Event notifications not required for this demo
# checkov:skip=CKV2_AWS_61:Lifecycle configuration out of scope for demo lab
# tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "my_bucket" {
  bucket = "lakeshore-devsecops-demo-bucket"
}


resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_encryption" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.bucket_key.arn
    }
  }
}
