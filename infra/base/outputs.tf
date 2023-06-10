output "vpc_id" {
  value = aws_default_vpc.vpc.id
}

output "subnet_az1_id" {
  value = aws_default_subnet.subnet_az1.id
}

output "subnet_az2_id" {
  value = aws_default_subnet.subnet_az2.id
}

output "subnet_az3_id" {
  value = aws_default_subnet.subnet_az3.id
}

output "sg_id" {
  value = aws_default_security_group.sg.id
}

output "kms_id" {
  value = aws_kms_key.kms.id
}
