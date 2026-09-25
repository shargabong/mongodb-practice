import pika
import json
import time
from pymongo import MongoClient

def main():
    mongo_client = MongoClient("mongodb://localhost:27017/")
    db = mongo_client["logs"]
    events_collection = db["events"]

    connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
    channel = connection.channel()

    channel.queue_declare(queue='dev_logs', durable=True)

    print("Чтение логов из MongoDB и публикация RabbitMQ...")

    logs = events_collection.find().limit(100)

    count = 0
    for log in logs:
        log['_id'] = str(log['_id'])
        if 'timestamp' in log:
            log['timestamp'] = str(log['timestamp'])

        message = json.dumps(log, ensure_ascii=False)

        channel.basic_publish(
            exchange='',
            routing_key='dev_logs',
            body=message,
            properties=pika.BasicProperties(
                delivery_mode=2,
            )
        )
        count += 1
    
    print(f"Успешно отправлено {count} логов в очередь RabbitMQ.")
    connection.close()

if __name__ == "__main__":
    main()