######################### SECRETS FOR USE IN RUNNING INSTANCES #########################

locals {
  mq_creds = {
    username = var.mq_user
    password = var.mq_password
  }
}

resource "aws_secretsmanager_secret" "mq_auth_secret" {
  name = "AmazonMQ_message-streaming-1"
}

resource "aws_secretsmanager_secret_version" "mq_auth_secret_version" {
  secret_id     = aws_secretsmanager_secret.mq_auth_secret.id
  secret_string = jsonencode(local.mq_creds)
}
