provider "aws" {
  region = "us-west-2"
}

variable "vpc_id" {
  default = "vpc-08f03d3aaae22a835"  # Replace with your VPC ID
}

# Create a Security Group for the EC2 instance in the correct VPC
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

# Create the EC2 instance
resource "aws_instance" "example" {
  ami           = "ami-00c257e12d6828491"  # Replace with the AMI ID you want to use (Check AWS Console)
  instance_type = "t2.micro"
  key_name      = "annis"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = "subnet-0860dff92ea555839"  # Replace with your subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "MyAWSInstance"
  }
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}

# Create the S3 Bucket
resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket-unique12345"  # Replace with a unique bucket name

  tags = {
    Name        = "MyStaticWebsiteBucket"
    Environment = "Dev"
  }
}

# Disable Block Public Access for the S3 Bucket
resource "aws_s3_bucket_public_access_block" "static_website_block" {
  bucket = aws_s3_bucket.static_website.bucket

  block_public_acls   = false
  block_public_policy = false
}

# Configure the S3 Bucket for Website Hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_website.bucket
  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Use AWS CLI to Upload Files to S3 from GitHub (fix for wget issue)
resource "null_resource" "download_github_files" {
  provisioner "local-exec" {
    command = <<EOT
      curl -o index.html https://raw.githubusercontent.com/Mupparaju19/websiteaws/main/index.html
      curl -o error.html https://raw.githubusercontent.com/Mupparaju19/websiteaws/main/error.html
      aws s3 cp index.html s3://${aws_s3_bucket.static_website.bucket}/index.html
      aws s3 cp error.html s3://${aws_s3_bucket.static_website.bucket}/error.html
    EOT
  }

  depends_on = [aws_s3_bucket.static_website]
}

# Create the IAM Policy that allows EC2 to access S3 bucket
resource "aws_iam_policy" "ec2_s3_access" {
  name        = "EC2S3AccessPolicy"
  description = "Policy that allows EC2 instances to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

# Create the IAM Role for EC2 and attach the policy to the role
resource "aws_iam_role" "ec2_role" {
  name               = "EC2RoleWithS3Access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the IAM Policy to the EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_access.arn
}

# Create the S3 Bucket Policy to allow public access to the objects
resource "aws_s3_bucket_policy" "static_website_policy" {
  bucket = aws_s3_bucket.static_website.bucket  # Referencing the S3 bucket created

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.static_website.bucket}/*"  # Dynamically use the bucket name
      }
    ]
  })
}

