import random

import boto3
from botocore.config import Config


def _create_message():
    return random.randbytes(1024)


class KinesisProducer:

    def __init__(self, kinesis_config: dict):
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
        self._message_counter = 0

    def produce(self):
        records = []
        for _ in range(500):
            records.append(
                {
                    "Data": _create_message(),
                    "PartitionKey": str(self._message_counter)
                }
            )
            self._message_counter += 1

        response = self._client.put_records(
            StreamName=self._stream,
            Records=records,
        )
        return response


def produce_indefinitely(kinesis_config: dict):
    producer = KinesisProducer(kinesis_config)
    while True:
        producer.produce()
