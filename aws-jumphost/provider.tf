provider "aws" {
  region = var.aws_region 

  # Uncomment and configure the following section to enable remote state storage in S3
  #
  # backend "s3" {
  #   bucket         = "your-s3-bucket-name"       # Replace with your S3 bucket name
  #   key            = "path/to/your/terraform.tfstate" # Replace with the path within the bucket to store the state file
  #   region         = "eu-west-1"                 # Replace with the region where your S3 bucket is located
  #   dynamodb_table = "your-dynamodb-table-name"  # Replace with your DynamoDB table name for state locking
  #   encrypt        = true                        # Enable encryption at rest
  # }
}

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "eu-west-1" 
}