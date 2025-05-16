from kafka import KafkaAdminClient, KafkaProducer
from kafka.admin import NewTopic
import json

KAFKA_BROKER = "kafka:9092"
TOPIC_NAME = "test_topic"

def create_topic():
    """Create a Kafka topic."""
    admin_client = KafkaAdminClient(bootstrap_servers=KAFKA_BROKER)
    topic = NewTopic(name=TOPIC_NAME, num_partitions=1, replication_factor=1)
    admin_client.create_topics(new_topics=[topic], validate_only=False)
    admin_client.close()

def send_test_data():
    """Send test data to Kafka."""
    producer = KafkaProducer(
        bootstrap_servers=KAFKA_BROKER,
        value_serializer=lambda v: json.dumps(v).encode('utf-8')
    )
    with open('test.json', 'r') as file:
        data = json.load(file)
        producer.send(TOPIC_NAME, data)
    producer.flush()
    producer.close()