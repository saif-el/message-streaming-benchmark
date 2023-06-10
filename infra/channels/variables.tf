variable "region" {
  default = "ap-southeast-1"
}

variable "benchmark_tag_key" {
  default = "benchmark"
}

variable "benchmark_tag_value" {
  default = "message-streaming"
}

variable "mq_user" {
  type = string
}

variable "mq_password" {
  type = string
}

variable "mq_num_queues" {
  type = number
}

variable "msk_user" {
  type = string
}

variable "msk_password" {
  type = string
}

variable "msk_num_partitions" {
  type = number
}

variable "kinesis_num_shards" {
  type = number
}
