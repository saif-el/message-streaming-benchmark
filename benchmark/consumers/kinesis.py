import time

import boto3
from botocore.config import Config


class KinesisConsumer:

    def __init__(self, kinesis_config: dict, shard_id: str):
        config = Config(
            region_name=kinesis_config.get("region"),
            signature_version='v4',
        )
        session = boto3.session.Session()
        if "access_key" in kinesis_config and kinesis_config["access_key"] is not None:
            self._client = session.client(
                "kinesis",
                config=config,
                aws_access_key_id=kinesis_config["access_key"],
                aws_secret_access_key=kinesis_config["secret_key"],
                aws_session_token=kinesis_config["session_token"]
            )
        else:
            self._client = session.client("kinesis", config=config)
        self._stream = kinesis_config.get("stream")
        self._stream_arn = kinesis_config.get("stream_arn")
        self._shard_id = shard_id
        self.shard_iterator = self._client.get_shard_iterator(
            StreamName=self._stream,
            ShardId=self._shard_id,
            ShardIteratorType='TRIM_HORIZON',
        ).get("ShardIterator")

    def consume(self):
        response = self._client.get_records(
            ShardIterator=self.shard_iterator,
            Limit=1000,
        )
        if "NextShardIterator" in response:
            self.shard_iterator = response.get("NextShardIterator")
        return response


def consume_indefinitely(kinesis_config: dict, shard_id):
    consumer = KinesisConsumer(kinesis_config, shard_id)
    while consumer.shard_iterator:
        consumer.consume()
        time.sleep(1.0)
