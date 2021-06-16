# State file to S3
terraform {
  backend "s3" {
    encrypt = true
    bucket = "assessment-bucket-150621"
    key    = "assessment/assessment-backend-key"
    region = "us-east-1"
  }
}