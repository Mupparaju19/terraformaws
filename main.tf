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
