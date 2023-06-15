import random
import ssl
from urllib.parse import quote_plus

import pika


def _create_message():
    return random.randbytes(1024)


class RabbitMQProducer:

    def __init__(self, rabbitmq_config):
        # SSL Context for TLS configuration of Amazon MQ for RabbitMQ
        ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        ssl_context.set_ciphers('ECDHE+AESGCM:!ECDSA')

        url = (
            f"amqps://"
            f"{rabbitmq_config.get('username')}:"
            f"{quote_plus(rabbitmq_config.get('password'))}@"
            f"{rabbitmq_config.get('broker_id')}.mq."
            f"{rabbitmq_config.get('region')}.amazonaws.com:5671/"
            f"{rabbitmq_config.get('vhost')}"
        )
        parameters = pika.URLParameters(url)
        parameters.ssl_options = pika.SSLOptions(context=ssl_context)

        self._connection = pika.BlockingConnection(parameters)
        self._channel = self._connection.channel()
        self._exchange = rabbitmq_config.get("exchange")
        self._num_queues = rabbitmq_config.get("num_queues")
        self._queue_counter = 0

    def _next_routing_key(self):
        self._queue_counter = (self._queue_counter + 1) % self._num_queues
        return f"queue_{self._queue_counter}"

    def produce(self):
        routing_key = self._next_routing_key()
        self._channel.basic_publish(
            exchange=self._exchange,
            routing_key=f"cg1_{routing_key}",
            body=_create_message(),
            mandatory=True
        )
        self._channel.basic_publish(
            exchange=self._exchange,
            routing_key=f"cg2_{routing_key}",
            body=_create_message(),
            mandatory=True
        )

    def close(self):
        self._channel.close()
        self._connection.close()


def produce_many(rabbitmq_config):
    producer = RabbitMQProducer(rabbitmq_config)
    for _ in range(10**4):
        producer.produce()
    producer.close()
