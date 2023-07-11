provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}
############ Creating a Random String ############
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 
############ Creating an S3 Bucket ############ 
resource "aws_s3_bucket" "bucket" {
  bucket = "whizbucket-${random_string.random.result}"
  force_destroy = true
}
resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
