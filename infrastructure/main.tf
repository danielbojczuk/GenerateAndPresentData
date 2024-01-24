provider "aws" {
  region = "eu-west-1"
   default_tags {
   tags = {
     Environment = terraform.workspace
     Project     = "GenerateAndPresentData"
   }
 }
}

terraform {
  required_version = "~> 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.33.0"
    }
  }
  backend "s3" {
    bucket = "generate-and-presend-data-backend"
    key    = "GenerateAndPresentData"
    region = "eu-west-1"
  }
}