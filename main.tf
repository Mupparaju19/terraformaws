provider "aws" {
  region = "us-west-2"  # Change this to your preferred AWS region
}

resource "aws_instance" "example" {
  ami           = "ami-00c257e12d6828491"  # Replace with the AMI ID you want to use (Check AWS Console)
  instance_type = "t2.micro"  # You can change this to any other instance type as needed (e.g., t2.small, t3.medium, etc.)

  key_name = "annis"  # Replace with your EC2 key pair name for SSH access

  tags = {
    Name = "MyAWSInstance"  # You can change the Name tag to whatever you prefer
  }

  # Optional: Configure security groups to allow SSH access (Port 22)
  security_groups = ["default"]

  # Optional: Set up a specific subnet (if you have VPC setup with subnets)
  subnet_id = "subnet-0860dff92ea555839"  # Replace with your subnet ID

  # Optional: If you need to attach a public IP to your instance
  associate_public_ip_address = true
}

output "instance_id" {
  value = aws_instance.example.id
}

output "public_ip" {
  value = aws_instance.example.public_ip
}
# Create the S3 Bucket
resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket"  # Replace with your desired bucket name

  tags = {
    Name        = "MyStaticWebsiteBucket"
    Environment = "Dev"
  }
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

# Download the HTML files from GitHub and upload them to S3
resource "null_resource" "download_github_files" {
  provisioner "local-exec" {
    command = <<EOT
      # Download files from GitHub repository
      wget https://raw.githubusercontent.com/Mupparaju19/terraformaws/main/index.html -O index.html
      wget https://raw.githubusercontent.com/Mupparaju19/terraformaws/main/error.html -O error.html

      # Upload to S3
      aws s3 cp index.html s3://${aws_s3_bucket.static_website.bucket}/index.html
      aws s3 cp error.html s3://${aws_s3_bucket.static_website.bucket}/error.html
    EOT
  }

  depends_on = [aws_s3_bucket.static_website]
}
# Create the IAM Policy that allows EC2 to access the S3 bucket
resource "aws_iam_policy" "ec2_s3_access" {
  name        = "EC2S3AccessPolicy"
  description = "Policy that allows EC2 instances to access S3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::my-static-website-bucket/*"
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
