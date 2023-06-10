terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      (var.benchmark_tag_key) = var.benchmark_tag_value
    }
  }
}

data "aws_caller_identity" "current" {}
