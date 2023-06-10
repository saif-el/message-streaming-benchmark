resource "aws_sns_topic" "main_topic" {
  name = "message-streaming-benchmark-topic"
}

resource "aws_sqs_queue" "cg1_queue" {
  name                       = "message-streaming-benchmark-cg1-queue"
  kms_master_key_id          = data.terraform_remote_state.base.outputs.kms_id
  visibility_timeout_seconds = 300
}

resource "aws_sqs_queue_policy" "cg1_queue_policy" {
  queue_url = aws_sqs_queue.cg1_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.cg1_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.main_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "cg1_subscription" {
  topic_arn = aws_sns_topic.main_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cg1_queue.arn
}

resource "aws_sqs_queue" "cg2_queue" {
  name                       = "message-streaming-benchmark-cg2-queue"
  kms_master_key_id          = data.terraform_remote_state.base.outputs.kms_id
  visibility_timeout_seconds = 300
}

resource "aws_sqs_queue_policy" "cg2_queue_policy" {
  queue_url = aws_sqs_queue.cg2_queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.cg2_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.main_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_sns_topic_subscription" "cg2_subscription" {
  topic_arn = aws_sns_topic.main_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cg2_queue.arn
}
