output "mq_broker_id" {
  value = var.mq_broker_id
}

output "msk_bootstrap_server_public_endpoints" {
  value = aws_msk_cluster.msk_cluster.bootstrap_brokers_public_sasl_scram
}
