import confluent_kafka

from benchmark import config


def _get_consumer_config(kafka_config: dict):
    return {
        'bootstrap.servers': kafka_config.get("public_endpoints"),
        'security.protocol': 'SASL_SSL',
        'sasl.mechanism': 'SCRAM-SHA-512',
        'sasl.username': kafka_config.get("username"),
        'sasl.password': kafka_config.get("password"),

        'client.id': config.instance_id(),
        'group.id': kafka_config.get("consumer_group"),
        'session.timeout.ms': 5000,
        'enable.auto.commit': True,
        'auto.commit.interval.ms': 1000,
        'auto.offset.reset': 'earliest'
    }


class KafkaConsumer:

    def __init__(self, kafka_config):
        self._conf = _get_consumer_config(kafka_config)
        self._consumer = confluent_kafka.Consumer(self._conf)
        self._consumer.subscribe([kafka_config.get("topic")])

    def consume(self):
        messages = self._consumer.consume(1000)
        return messages


def consume_indefinitely(kafka_config):
    consumer = KafkaConsumer(kafka_config)
    while True:
        consumer.consume()
