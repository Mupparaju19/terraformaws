
Static Website Hosting on AWS using Terraform

This repository contains the Terraform code to set up a static website on AWS using S3 for website hosting, EC2 for access, IAM roles and policies for permissions, and a Bucket Policy to allow public access to the website.

Overview

This project demonstrates how to:
	•	Create an EC2 instance.
	•	Configure an S3 bucket to host a static website.
	•	Set the necessary IAM roles and policies for accessing S3 from EC2.
	•	Apply an S3 bucket policy to make the website publicly accessible.

Requirements

Before using this Terraform code, you need:
	•	An AWS account.
	•	Terraform installed (v0.12 or later).
	•	An AWS IAM user with appropriate permissions (e.g., AdministratorAccess).

Project Structure

.
├── main.tf          # Contains Terraform configuration for S3, EC2, IAM, and policies.
└── README.md        # This file, explaining the project.

Getting Started

1. Clone the Repository

To get started with the project, clone this repository to your local machine:

git clone https://github.com/Mupparaju19/websiteaws.git
cd websiteaws

2. Configure AWS Credentials

Make sure your AWS credentials are configured. If you’re using the AWS CLI, you can configure them by running:

aws configure

Enter your AWS Access Key, Secret Key, and default region (us-west-2).

3. Initialize Terraform

To initialize the Terraform working directory and download the necessary provider plugins, run:

terraform init

4. Preview the Changes

Before applying the changes, you can preview what Terraform will do by running:

terraform plan

5. Apply the Terraform Configuration

To create the infrastructure, run:

terraform apply

Terraform will ask for confirmation to proceed. Type yes to apply the changes.

6. Access the Static Website

After the infrastructure is created, your static website will be accessible via a URL like:

http://<your-bucket-name>.s3-website-<region>.amazonaws.com

For example:

http://my-static-website-bucket-unique12345.s3-website-us-west-2.amazonaws.com

Resources Created
	•	S3 Bucket: A bucket named my-static-website-bucket-unique12345 is created for hosting the static website. The bucket is configured for static website hosting, with index.html as the default document and error.html for error handling.
	•	EC2 Instance: A simple EC2 instance is created with a security group that allows inbound traffic on ports 22 (SSH) and 80 (HTTP).
	•	IAM Role & Policy: An IAM role is created for the EC2 instance with an IAM policy allowing access to the S3 bucket.
	•	S3 Bucket Policy: A public access policy is applied to allow public access to the website.

How It Works
	1.	S3 Bucket: The bucket is configured to serve as a static website using S3 Website Hosting.
	2.	EC2 Instance: The EC2 instance is created with a security group to allow HTTP and SSH access. The instance is also configured with an IAM role that allows it to access the S3 bucket.
	3.	IAM Role & Policy: An IAM role is created and attached to the EC2 instance, granting it access to the S3 bucket for reading objects (such as index.html and error.html).
	4.	S3 Bucket Policy: The bucket policy allows public read access to the objects in the bucket, making the static website publicly available.

Cleaning Up

To clean up and remove all resources created by this Terraform configuration, run:

terraform destroy

Terraform will prompt for confirmation. Type yes to delete the resources.

Notes
	•	Ensure that your S3 bucket name is globally unique. If the specified bucket name already exists, you will need to choose a different one.
	•	The website is publicly accessible. Ensure you handle any sensitive data appropriately and consider enabling additional security features if necessary.

