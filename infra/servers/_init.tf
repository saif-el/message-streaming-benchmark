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

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../base/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}
