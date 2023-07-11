provider "aws" {
    region     = "${var.region}"
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
}						
#In the above code, you are defining the provider as aws.

#Next, we want to tell Terraform to create a S3 bucket.

#Since the bucket name must be unique across all existing bucket names in Amazon S3, let us also creating a random string and an S3 bucket with public access block settings.

#Paste the below content into the main.tf file after the provider.

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
############ Creating Bucket Public Access Block ############
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}			
#task 5: Upload an image file in s3 bucket in main.tf file
#In this task we are going to upload an image file in S3 bucket 

#Firstly you will create a new folder to place the image file. 

#To create a folder, click on the Create folder icon present on the left side panel under your folder called task_10096

#Name the folder as image

#Now click on this link to download the zip file to your local,extract the zip file.

#Place the Whizlabs.png image file inside the newly created folder called image
# Upload an object
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.id
  key    = "whizlabs.png"
  source = "image/whizlabs.png"
  etag = filemd5("image/whizlabs.png")
}			

#Task 6: Create a S3 bucket policy in main.tf file
#In this task we are going to create a S3 bucket policy to make the objects publicly accessible

#To Create a bucket policy add another block just below the upload object code in main.tf file

#Creating Bucket Policy
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:list*",
        "s3:get*",
        "s3:putobject"
        ],
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}		
#Task 7: Create a CloudFront Distribution in main.tf file
#In this task, you will create a CloudFront Distribution pointed to Amazon S3 bucket origin 

#To create a CloudFront Distribution add another block just below the bucket policy creation code in main.tf file
# Create Cloudfront distribution
locals {
  s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }
  enabled         = true
  is_ipv6_enabled = true
  comment         = "whiz-cloudfront"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 10
    max_ttl                = 20
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}			
