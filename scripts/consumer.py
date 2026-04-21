from kafka import KafkaConsumer
import json
import mysql.connector
from datetime import datetime

consumer = KafkaConsumer(
    'sales_topic',
    bootstrap_servers='localhost:9092',
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

conn = mysql.connector.connect(
    host='localhost',
    user='root',
    password='secret',
    database='odb',
    port=13306
)

cursor = conn.cursor()

for msg in consumer:
    data = msg.value

    raw_date = data.get('Order Date')
    formatted_date = datetime.strptime(raw_date, '%m/%d/%Y').strftime('%Y-%m-%d')

    cursor.execute("""
        INSERT INTO sales_odb 
        (order_id, order_date, customer_name, city, state, region,
         product_name, category, quantity, sales, profit)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
    """, (
        data.get('Order ID'),
        formatted_date,
        data.get('Customer Name'),
        data.get('City'),
        data.get('State'),
        data.get('Region'),
        data.get('Product Name'),
        data.get('Category'),
        data.get('Quantity'),
        data.get('Sales'),
        data.get('Profit')
    ))

    conn.commit()
    print("Inserted:", data.get('Order ID'))
