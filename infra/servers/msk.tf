resource "aws_cloudwatch_log_group" "msk_log_group" {
  name = "message-streaming-benchmark-msk-logs"
}

resource "aws_msk_configuration" "benchmark_config" {
  kafka_versions = ["3.4.0"]
  name           = "message-streaming-benchmark-cluster-config"

  server_properties = <<PROPERTIES
allow.everyone.if.no.acl.found = false
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = "message-streaming-benchmark-cluster"
  kafka_version          = "3.4.0"
  number_of_broker_nodes = 3

  configuration_info {
    arn      = aws_msk_configuration.benchmark_config.arn
    revision = aws_msk_configuration.benchmark_config.latest_revision
  }

  broker_node_group_info {
    instance_type = var.msk_broker_instance_type

    storage_info {
      ebs_storage_info {
        volume_size = 128
      }
    }

    client_subnets = [
      data.terraform_remote_state.base.outputs.subnet_az1_id,
      data.terraform_remote_state.base.outputs.subnet_az2_id,
      data.terraform_remote_state.base.outputs.subnet_az3_id,
    ]
    security_groups = [data.terraform_remote_state.base.outputs.sg_id]
    connectivity_info {
      public_access {
         type = "DISABLED"
        # type = "SERVICE_PROVIDED_EIPS"
      }
    }
  }

  client_authentication {
    unauthenticated = false
    sasl {
      scram = true
      iam   = true
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_log_group.name
      }
    }
  }
}


locals {
  account_id = data.aws_caller_identity.current.account_id
  msk_creds = {
    username = var.msk_user
    password = var.msk_password
  }
}

resource "aws_secretsmanager_secret" "msk_auth_secret" {
  name       = "AmazonMSK_message-streaming-1"
  kms_key_id = data.terraform_remote_state.base.outputs.kms_id
}

resource "aws_secretsmanager_secret_version" "msk_auth_secret_version" {
  secret_id     = aws_secretsmanager_secret.msk_auth_secret.id
  secret_string = jsonencode(local.msk_creds)
}

resource "aws_msk_scram_secret_association" "msk_auth_secret_association" {
  cluster_arn     = aws_msk_cluster.msk_cluster.arn
  secret_arn_list = [aws_secretsmanager_secret.msk_auth_secret.arn]

  depends_on = [aws_secretsmanager_secret_version.msk_auth_secret_version]
}

data "aws_iam_policy_document" "msk_auth_secret_policy_doc" {
  statement {
    sid    = "AWSKafkaResourcePolicy"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["kafka.amazonaws.com"]
    }

    actions   = ["secretsmanager:getSecretValue"]
    resources = [aws_secretsmanager_secret.msk_auth_secret.arn]
  }
}

resource "aws_secretsmanager_secret_policy" "msk_auth_secret_policy" {
  secret_arn = aws_secretsmanager_secret.msk_auth_secret.arn
  policy     = data.aws_iam_policy_document.msk_auth_secret_policy_doc.json
}

resource "aws_iam_role" "msk_instance_role" {
  name = "message-streaming-benchmark-msk-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "message-streaming-benchmark-msk-policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "kafka-cluster:Connect",
            "kafka-cluster:AlterCluster",
            "kafka-cluster:DescribeCluster"
          ],
          "Resource" : [
            "arn:aws:kafka:${var.region}:${local.account_id}:cluster/${aws_msk_cluster.msk_cluster.cluster_name}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kafka-cluster:*_topic",
            "kafka-cluster:WriteData",
            "kafka-cluster:ReadData"
          ],
          "Resource" : [
            "arn:aws:kafka:${var.region}:${local.account_id}:topic/${aws_msk_cluster.msk_cluster.cluster_name}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kafka-cluster:AlterGroup",
            "kafka-cluster:DescribeGroup"
          ],
          "Resource" : [
            "arn:aws:kafka:${var.region}:${local.account_id}:group/${aws_msk_cluster.msk_cluster.cluster_name}/*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_instance_profile" "msk_bastion_host_profile" {
  name = "message-streaming-benchmark-msk-bastion-host-profile"
  role = aws_iam_role.msk_instance_role.name
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_security_group" "msk_bastion_host_sg" {
  name   = "message-streaming-benchmark-msk-bastion-host-sg"
  vpc_id = data.terraform_remote_state.base.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "message-streaming-benchmark-msk-bastion-host-sg"
  }
}

resource "aws_instance" "msk_bastion_host" {
  ami                  = data.aws_ami.amazon_linux_2.id
  iam_instance_profile = aws_iam_instance_profile.msk_bastion_host_profile.name
  security_groups      = [aws_security_group.msk_bastion_host_sg.name]
  instance_type        = "t3.micro"

  user_data_replace_on_change = true
  user_data                   = <<-EOL
  #!/bin/bash -xe

  sudo yum -y install java-11
  wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.13-3.4.0.tgz
  tar -xzf kafka_2.13-3.4.0.tgz

  cd kafka_2.13-3.4.0/libs
  wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.1/aws-msk-iam-auth-1.1.1-all.jar

  cd ../bin
  echo "security.protocol=SASL_SSL" >> client.properties
  echo "sasl.mechanism=AWS_MSK_IAM" >> client.properties
  echo "sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;" >> client.properties
  echo "sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler" >> client.properties

  ./kafka-acls.sh --bootstrap-server ${aws_msk_cluster.msk_cluster.bootstrap_brokers_sasl_iam} --command-config client.properties --add --allow-principal User:${var.msk_user} --operation All --cluster '*'
  EOL

  tags = {
    Name = "message-streaming-benchmark-msk-bastion-host"
  }
}

resource "aws_vpc_security_group_ingress_rule" "msk_bastion_host_rule" {
  security_group_id = data.terraform_remote_state.base.outputs.sg_id

  referenced_security_group_id = aws_security_group.msk_bastion_host_sg.id
  ip_protocol                  = "-1"
}
