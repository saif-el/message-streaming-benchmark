import boto3
from botocore.config import Config

from benchmark.utils.concurrent import run_mp, run_mt
from benchmark.config import kafka_config, rabbitmq_config, kinesis_config
from benchmark.consumers import kafka, rabbitmq, kinesis


def consume_from_kafka(consumer_group):
    kafka_config["consumer_group"] = consumer_group
    run_mp(kafka.consume_indefinitely, kafka_config)


def consume_from_rabbitmq(consumer_group):
    rabbitmq_config["consumer_group"] = consumer_group
    rabbitmq_config["num_threads_per_process"] = 2
    run_mp(rabbitmq.consume_until_exhaustion, rabbitmq_config)


def consume_from_kinesis():
    config = Config(
        region_name=kinesis_config.get("region"),
        signature_version='v4',
    )
    session = boto3.session.Session()
    if "access_key" in kinesis_config and kinesis_config["access_key"] is not None:
        kinesis_client = session.client(
            "kinesis",
            config=config,
            aws_access_key_id=kinesis_config["access_key"],
            aws_secret_access_key=kinesis_config["secret_key"],
            aws_session_token=kinesis_config["session_token"]
        )
    else:
        kinesis_client = session.client("kinesis", config=config)

    response = kinesis_client.list_shards(StreamName=kinesis_config.get("stream"))
    shard_ids = []
    if "Shards" in response:
        for obj in response["Shards"]:
            shard_ids.append(obj.get("ShardId"))

    kinesis_config["num_threads_per_process"] = len(shard_ids)
    run_mt(kinesis.consume_indefinitely, kinesis_config, shard_ids)
