#resource "rabbitmq_vhost" "aws_mq" {
#  name = "main"
#}
#
#resource "rabbitmq_permissions" "tf_permissions" {
#  user  = "admin"
#  vhost = rabbitmq_vhost.aws_mq.name
#
#  permissions {
#    configure = ".*"
#    write     = ".*"
#    read      = ".*"
#  }
#}
#
#resource "rabbitmq_exchange" "main" {
#  name  = "main_exchange"
#  vhost = rabbitmq_permissions.tf_permissions.vhost
#
#  settings {
#    type        = "fanout"
#    durable     = false
#    auto_delete = true
#  }
#}
#
#resource "rabbitmq_exchange" "cg1" {
#  name  = "cg1_exchange"
#  vhost = rabbitmq_permissions.tf_permissions.vhost
#
#  settings {
#    type        = "default"
#    durable     = false
#    auto_delete = true
#  }
#}
#
#resource "rabbitmq_binding" "main_to_cg1" {
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.main.name
#  destination      = rabbitmq_exchange.cg1.name
#  destination_type = "exchange"
#  routing_key      = "#"
#}
#
#resource "rabbitmq_exchange" "cg2" {
#  name  = "cg2_exchange"
#  vhost = rabbitmq_permissions.tf_permissions.vhost
#
#  settings {
#    type        = "default"
#    durable     = false
#    auto_delete = true
#  }
#}
#
#resource "rabbitmq_binding" "main_to_cg2" {
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.main.name
#  destination      = rabbitmq_exchange.cg2.name
#  destination_type = "exchange"
#  routing_key      = "#"
#}
#
#resource "rabbitmq_queue" "cg1_queues" {
#  count = var.mq_num_queues
#  name  = "cg1_queue_${count.index}"
#  vhost = rabbitmq_permissions.tf_permissions.vhost
#
#  settings {
#    durable     = true
#    auto_delete = false
#  }
#}
#
#resource "rabbitmq_binding" "cg1_to_queues" {
#  for_each         = { for q in rabbitmq_queue.cg1_queues : q.name => q }
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.cg1.name
#  destination      = each.key
#  destination_type = "queue"
#  routing_key      = "#"
#}
#
#resource "rabbitmq_queue" "cg2_queues" {
#  count = var.mq_num_queues
#  name  = "cg2_queue_${count.index}"
#  vhost = rabbitmq_permissions.tf_permissions.vhost
#
#  settings {
#    durable     = true
#    auto_delete = false
#  }
#}
#
#resource "rabbitmq_binding" "cg2_to_queues" {
#  for_each         = { for q in rabbitmq_queue.cg2_queues : q.name => q }
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.cg2.name
#  destination      = each.key
#  destination_type = "queue"
#  routing_key      = "#"
#}
