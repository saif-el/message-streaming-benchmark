import boto3
from botocore.config import Config

from benchmark.config import kafka_config, rabbitmq_config, kinesis_config, sns_config
from benchmark.producers import kafka, rabbitmq, kinesis, sns
from benchmark.utils.concurrent import run_mp


def produce_to_kafka():
    run_mp(kafka.produce_indefinitely, kafka_config)


def produce_to_rabbitmq():
    run_mp(rabbitmq.produce_many, rabbitmq_config)


def produce_to_kinesis():
    run_mp(kinesis.produce_indefinitely, kinesis_config)


def produce_to_sns():
    sns_config["num_threads_per_process"] = 16
    run_mp(sns.produce_indefinitely, sns_config)
