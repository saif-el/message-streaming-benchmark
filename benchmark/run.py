#!/usr/bin/env python3

import argparse

from benchmark.consumers import (
    consume_from_kafka,
    consume_from_kinesis,
    consume_from_rabbitmq
)
from benchmark.producers import (
    produce_to_kafka,
    produce_to_kinesis,
    produce_to_rabbitmq, produce_to_sns
)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--kafka_producer',
        help='Produce messages to Kafka cluster',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--kafka_consumer',
        help='Consume messages from Kafka cluster',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--rabbitmq_producer',
        help='Produce messages to RabbitMQ cluster',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--rabbitmq_consumer',
        help='Consume messages from RabbitMQ cluster',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--kinesis_producer',
        help='Produce messages to Kinesis stream',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--kinesis_consumer',
        help='Consume messages from Kinesis stream',
        nargs='?',
        default=False
    )
    parser.add_argument(
        '--sns_producer',
        help='Produce messages to SNS topic',
        nargs='?',
        default=False
    )
    args = parser.parse_args()

    if args.kafka_producer is not False:
        produce_to_kafka()
    if args.kafka_consumer is not False and args.kafka_consumer is not None:
        consume_from_kafka(args.kafka_consumer)
    if args.rabbitmq_producer is not False:
        produce_to_rabbitmq()
    if args.rabbitmq_consumer is not False and args.rabbitmq_consumer is not None:
        consume_from_rabbitmq(args.rabbitmq_consumer)
    if args.kinesis_producer is not False:
        produce_to_kinesis()
    if args.kinesis_consumer is not False:
        consume_from_kinesis()
    if args.sns_producer is not False:
        produce_to_sns()
