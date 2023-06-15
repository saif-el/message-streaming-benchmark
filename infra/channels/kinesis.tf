resource "aws_kinesis_stream" "main_stream" {
  name             = "message-streaming-benchmark-stream"
  shard_count      = var.kinesis_num_shards
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  kms_key_id = data.terraform_remote_state.base.outputs.kms_id

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
}

resource "aws_iam_role" "kinesis_rw_access_role" {
  name = "message-streaming-benchmark-kinesis-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name   = "message-streaming-benchmark-kinesis-policy"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : "kinesis:*",
            "Resource" : [
              aws_kinesis_stream.main_stream.arn
            ]
          }
        ]
      }
    )
  }
}
