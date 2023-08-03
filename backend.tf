terraform {
  backend "s3" {
    bucket         = "techonlin"
    key            = "terraform.tfstate"
    region         = "us-west-2" # replace with your bucket region
    dynamodb_table = "mytable"
    encrypt        = true
    workspace_key_prefix = "terraform-state"
  }
}