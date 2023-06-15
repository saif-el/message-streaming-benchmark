import ssl
from concurrent.futures import ThreadPoolExecutor
from urllib.parse import quote_plus

import pika


def queues(consumer_group, num_queues):
    qs = []
    for x in range(num_queues):
        qs.append(f"{consumer_group}_queue_{x}")
    return qs


class RabbitMQConsumer:

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

    def consume(self, queue):
        def cb(_ch, _method, _properties, _body):
            pass

        self._channel.basic_consume(queue=queue, on_message_callback=cb, auto_ack=True)
        self._channel.start_consuming()

    def close(self):
        self._channel.close()
        self._connection.close()


def consume_until_exhaustion(rabbitmq_config):
    def consume(queue):
        consumer = RabbitMQConsumer(rabbitmq_config)
        consumer.consume(queue)
        consumer.close()

    consumer_group = rabbitmq_config.get("consumer_group")
    num_queues = rabbitmq_config.get("num_queues")
    executor = ThreadPoolExecutor(max_workers=num_queues)
    for queue in queues(consumer_group, num_queues):
        executor.submit(consume, queue)
