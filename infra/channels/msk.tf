resource "kafka_acl" "topic_admin" {
  resource_name       = "*"
  resource_type       = "Topic"
  acl_principal       = "User:${var.msk_user}"
  acl_host            = "*"
  acl_operation       = "All"
  acl_permission_type = "Allow"
}

resource "kafka_topic" "main" {
  name               = "main_topic"
  replication_factor = 2
  partitions         = var.msk_num_partitions

  depends_on = [kafka_acl.topic_admin]
}
