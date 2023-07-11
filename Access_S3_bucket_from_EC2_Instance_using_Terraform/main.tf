# Create main.tf file and outputs.tf file
#Create a new folder to place the index.html file. To create a folder, click on the Create folder icon present on the left side panel under your folder called task_10003_ec2.



#Name this folder as html. And, press enter.

#Next, download the sample HTML file below and place them inside the newly created folder called html.

#Download index.html

#Or you can manually create an index.html inside the html folder and paste the contents of downloaded files.

#To create main.tf file, click on the File from the menu bar and choose New file

#Press Ctrl + S to save the new file as main.tf and click on the Save button after entering the file name.

#Paste the below content into main.tf file. In below code you are defining aws provider and you will create an S3 Bucket and upload the index.html file into the newly created S3 Bucket.
provider "aws" {
     region     = var.region
     access_key = var.access_key
     secret_key = var.secret_key
}

resource "aws_s3_bucket" "blog" {
    bucket = var.bucket_name
    acl = "private"
}

resource "aws_s3_bucket_object" "object1" {
    for_each = fileset("html/", "*")
    bucket = aws_s3_bucket.blog.id
    key = each.value
    source = "html/${each.value}"
    etag = filemd5("html/${each.value}")
    content_type = "text/html"
}
resource "aws_instance" "web" {
    ami = "ami-02e136e904f3da870"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.web-sg.id]
    iam_instance_profile = aws_iam_instance_profile.SSMRoleForEC2.name
    user_data = <<EOF

    #!/bin/bash
    sudo su
    yum update -y
    yum install httpd -y
    aws s3 cp s3://${aws_s3_bucket.blog.id}/index.html  /var/www/html/index.html
    systemctl start httpd
    systemctl enable httpd
    EOF

  tags = {
    Name = "Whiz-EC2-Instance"
  }
}
#In the above code, you are defining resource block using aws_instance  for creating an Amazon EC2 Instance having AMI ID as mentioned, EC2 Instance type as t2.micro, and IAM role or IAM Instance profile as mentioned in the next step. And, in user_data section, you are installing the HTTPD and copying index.html file from the s3 bucket.

#Add the code for the Security group, authorizing inbound traffic from port 80 and port 443, and outbound traffic from all ports.
resource "aws_security_group" "web-sg" {
  name = "Web-SG"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#Add another block of just below the EC2 Instance creation code, this block of code will create an IAM role having trust permission having use case of EC2 Instance.
resource "aws_iam_role" "SSMRoleForEC2" {
    name = "SSMRoleForEC2"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}
resource "aws_iam_instance_profile" "SSMRoleForEC2" {
    name = "SSMRoleForEC2"
    role = aws_iam_role.SSMRoleForEC2.name
}
#Attach the AWS Managed IAM Policy AmazonSSMManagedInstanceCore and AmazonS3ReadOnlyAccess to the IAM Role created above. This IAM Policy will allow EC2 Instance to use Session Manager for SSH without key pair and to access S3 buckets and its bucket.

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", 
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ])

  role       = aws_iam_role.SSMRoleForEC2.name
  policy_arn = each.value
}
