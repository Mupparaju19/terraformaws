provider "aws" {
  region = "us-west-2"  # Change this to your desired region
}

resource "aws_s3_bucket" "static_website" {
  bucket = "my-static-website-bucket"  # Replace with your desired bucket name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = "MyStaticWebsiteBucket"
    Environment = "Dev"
  }
}

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
