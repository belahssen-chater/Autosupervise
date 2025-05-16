import unittest
from unittest.mock import patch, MagicMock
import json
from kafka_producer import create_topic, send_test_data, KAFKA_BROKER, TOPIC_NAME

class TestKafkaProducer(unittest.TestCase):
    @patch('kafka_producer.KafkaAdminClient')
    def test_create_kafka_topic(self, mock_admin_client):
        """Test Kafka topic creation"""
        mock_admin_instance = MagicMock()
        mock_admin_client.return_value = mock_admin_instance

        create_topic()

        mock_admin_instance.create_topics.assert_called_once()
        mock_admin_instance.close.assert_called_once()

    @patch('kafka_producer.KafkaProducer')
    @patch('builtins.open', new_callable=unittest.mock.mock_open, read_data=json.dumps({
        "timestamp": "2025-05-13T12:00:00Z",
        "level": "info",
        "message": "Sample log message",
        "host": "localhost",
        "source": "test_source"
    }))
    def test_send_data_to_kafka(self, mock_open, mock_kafka_producer):
        """Test sending data to Kafka"""
        mock_producer_instance = MagicMock()
        mock_kafka_producer.return_value = mock_producer_instance

        send_test_data()

        mock_open.assert_called_once_with('test.json', 'r')
        mock_producer_instance.send.assert_called_once_with(
            TOPIC_NAME,
            {
                "timestamp": "2025-05-13T12:00:00Z",
                "level": "info",
                "message": "Sample log message",
                "host": "localhost",
                "source": "test_source"
            }
        )
        mock_producer_instance.flush.assert_called_once()
        mock_producer_instance.close.assert_called_once()

if __name__ == '__main__':
    unittest.main()