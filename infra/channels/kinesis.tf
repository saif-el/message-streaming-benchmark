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
