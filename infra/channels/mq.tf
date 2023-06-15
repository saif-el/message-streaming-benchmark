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
#    type        = "direct"
#    durable     = false
#    auto_delete = true
#  }
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
#resource "rabbitmq_binding" "main_to_cg1_queues" {
#  for_each         = { for q in rabbitmq_queue.cg1_queues : q.name => q }
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.main.name
#  destination      = each.key
#  destination_type = "queue"
#  routing_key      = each.key
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
#resource "rabbitmq_binding" "main_to_cg2_queues" {
#  for_each         = { for q in rabbitmq_queue.cg2_queues : q.name => q }
#  vhost            = rabbitmq_vhost.aws_mq.name
#  source           = rabbitmq_exchange.main.name
#  destination      = each.key
#  destination_type = "queue"
#  routing_key      = each.key
#}
