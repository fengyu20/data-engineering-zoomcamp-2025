## Question 3. Connecting to the Kafka server
import json
from kafka import KafkaProducer

def json_serializer(data):
    return json.dumps(data).encode('utf-8')

server = 'redpanda-1:29092'

producer = KafkaProducer(
    bootstrap_servers=[server],
    value_serializer=json_serializer
)

print(producer.bootstrap_connected())

## Question 4: Sending the Trip Data
from time import time
import pandas as pd

t0 = time()

columns = [
    'lpep_pickup_datetime',
    'lpep_dropoff_datetime',
    'PULocationID',
    'DOLocationID',
    'passenger_count',
    'trip_distance',
    'tip_amount'
]

df = pd.read_csv('/opt/src/green_tripdata_2019-10.csv', usecols=columns)

# The topic was created in the Question 2
topic_name = 'green_tripdata'

for _, row in df.iterrows():
    message = row.to_dict()
    producer.send(topic_name, value=message)

producer.flush()
t1 = time()
took = t1 - t0
print("Time taken:", took)