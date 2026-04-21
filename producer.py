import pandas as pd
from kafka import KafkaProducer
import json
import time

try:
    df = pd.read_csv('../data/superstore.csv')
except:
    df = pd.read_csv('../data/superstore.csv', encoding='latin1')
    
producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

for _, row in df.head(100).iterrows():
    producer.send('sales_topic', row.to_dict())
    print("Sent:", row['Order ID'])
    time.sleep(0.1)