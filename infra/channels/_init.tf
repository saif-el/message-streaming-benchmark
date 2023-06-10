terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    rabbitmq = {
      source = "cyrilgdn/rabbitmq"
    }
    kafka = {
      source = "Mongey/kafka"
    }
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

provider "rabbitmq" {
  endpoint = "https://${data.terraform_remote_state.servers.outputs.mq_broker_id}.mq.${var.region}.amazonaws.com"
  username = var.mq_user
  password = var.mq_password
}

provider "kafka" {
  bootstrap_servers = [
    split(",", data.terraform_remote_state.servers.outputs.msk_bootstrap_server_public_endpoints)[0],
    split(",", data.terraform_remote_state.servers.outputs.msk_bootstrap_server_public_endpoints)[1],
    split(",", data.terraform_remote_state.servers.outputs.msk_bootstrap_server_public_endpoints)[2],
  ]
  tls_enabled     = true
  skip_tls_verify = true
  sasl_mechanism  = "scram-sha512"
  sasl_username   = var.msk_user
  sasl_password   = var.msk_password
}

data "terraform_remote_state" "base" {
  backend = "local"
  config = {
    path = "../base/terraform.tfstate"
  }
}

data "terraform_remote_state" "servers" {
  backend = "local"
  config = {
    path = "../servers/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}
