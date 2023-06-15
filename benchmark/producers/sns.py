import random
import string

import boto3
from botocore.config import Config


def _create_message(length=1024):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))


class SNSProducer:

    def __init__(self, sns_config: dict):
        config = Config(
            region_name=sns_config.get("region"),
            signature_version='v4',
        )
        session = boto3.session.Session()
        if "access_key" in sns_config and sns_config["access_key"] is not None:
            self._client = session.client(
                "sns",
                config=config,
                aws_access_key_id=sns_config["access_key"],
                aws_secret_access_key=sns_config["secret_key"],
                aws_session_token=sns_config["session_token"]
            )
        else:
            self._client = session.client("sns", config=config)
        self._topic_arn = sns_config.get("topic_arn")
        self._message_counter = 0

    def produce(self):
        messages = []
        for _ in range(10):
            messages.append(
                {
                    'Id': str(self._message_counter),
                    'Message': _create_message(),
                }
            )
            self._message_counter += 1

        response = self._client.publish_batch(
            TopicArn=self._topic_arn,
            PublishBatchRequestEntries=messages
        )
        return response


def produce_indefinitely(sns_config: dict):
    producer = SNSProducer(sns_config)
    while True:
        producer.produce()
