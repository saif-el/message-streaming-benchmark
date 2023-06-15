import random

import confluent_kafka

from benchmark import config


def _get_producer_config(kafka_config: dict):
    return {
        'bootstrap.servers': kafka_config.get("public_endpoints"),
        'security.protocol': 'SASL_SSL',
        'sasl.mechanism': 'SCRAM-SHA-512',
        'sasl.username': kafka_config.get("username"),
        'sasl.password': kafka_config.get("password"),

        'client.id': config.instance_id(),
        'acks': 'all',
    }


def _create_message():
    return random.randbytes(1024)


class KafkaProducer:

    def __init__(self, kafka_config: dict):
        self._conf = _get_producer_config(kafka_config)
        self._producer = confluent_kafka.Producer(self._conf)
        self._topic = kafka_config.get("topic")
        self._key_counter = 0

    def produce(self):
        self._producer.produce(self._topic, _create_message(), str(self._key_counter))
        self._key_counter += 1
        if self._key_counter == 1000:
            self._key_counter = 0
            self._producer.flush()


def produce_indefinitely(kafka_config):
    producer = KafkaProducer(kafka_config)
    while True:
        producer.produce()
