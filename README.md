# Benchmarking message streaming solutions on AWS

This repository contains the code to deploy and benchmark various AWS-managed message
streaming solutions, namely:
* Amazon SNS/SQS
* Amazon Kinesis Data Streams
* Amazon MSK (Kafka)
* Amazon MQ (RabbitMQ)

TODO: add more information on benchmark design.

## Setup infra

The infra will be created primarily using Terraform. But it has to be done in two
phases. This is because the current AWS provider (v5.0.0) for Terraform does not support
cluster deployment of Amazon MQ (for RabbitMQ). So, we will first register the default
VPC and networking setup:

```bash
cd infra
terraform init
terraform apply                           \
    -target=aws_default_vpc.vpc           \
    -target=aws_default_subnet.subnet_az1 \
    -target=aws_default_subnet.subnet_az2 \
    -target=aws_default_subnet.subnet_az3 \
    -target=aws_default_security_group.sg
```

Once this apply is successful, we need to create an Amazon MQ (for RabbitMQ) cluster in
the AWS console. Make sure to select "Cluster deployment" with "Private access" and
configure it to use the VPC, subnets and security-group that we created in the previous
step.

TODO: talk about how MQ cluster needs to be created before we can setup the provider
      and create exchanges and queues

TODO: talk about how MSK cluster needs to be created and made publicly accessible before
      we can setup the provider and create exchanges.
