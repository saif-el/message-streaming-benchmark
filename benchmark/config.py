import os

import requests

num_cpus = os.cpu_count()

kafka_config = {
    "public_endpoints": os.getenv("KAFKA_PUBLIC_ENDPOINTS"),
    "username": os.getenv("KAFKA_USERNAME"),
    "password": os.getenv("KAFKA_PASSWORD"),
    "topic": os.getenv("KAFKA_TOPIC"),
}

rabbitmq_config = {
    "broker_id": os.getenv("RABBITMQ_BROKER_ID"),
    "vhost": os.getenv("RABBITMQ_VHOST"),
    "username": os.getenv("RABBITMQ_USERNAME"),
    "password": os.getenv("RABBITMQ_PASSWORD"),
    "region": os.getenv("RABBITMQ_REGION"),
    "exchange": os.getenv("RABBITMQ_EXCHANGE"),
    "num_queues": int(os.getenv("RABBITMQ_NUM_QUEUES"))
}

kinesis_config = {
    "region": os.getenv("KINESIS_REGION"),
    "stream": os.getenv("KINESIS_STREAM"),
    "stream_arn": os.getenv("KINESIS_STREAM_ARN"),

    # Comment out when running in EC2
    "access_key": os.getenv("AWS_ACCESS_KEY_ID"),
    "secret_key": os.getenv("AWS_SECRET_ACCESS_KEY"),
    "session_token": os.getenv("AWS_SESSION_TOKEN"),
}

sns_config = {
    "region": os.getenv("SNS_REGION"),
    "topic_arn": os.getenv("SNS_TOPIC_ARN"),

    # Comment out when running in EC2
    "access_key": os.getenv("AWS_ACCESS_KEY_ID"),
    "secret_key": os.getenv("AWS_SECRET_ACCESS_KEY"),
    "session_token": os.getenv("AWS_SESSION_TOKEN"),
}


def instance_id():
    return "local"
    try:
        response = requests.get('http://169.254.169.254/latest/meta-data/instance-id')
        return response.text
    except Exception:
        return "local"
