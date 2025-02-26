
import pyspark
from pyspark.sql import SparkSession


## Question 1: Install Spark and PySpark
my_spark = SparkSession.builder.getOrCreate()
my_spark.sparkContext.setLogLevel("ERROR")

print(my_spark.version)


## Question 2: Yellow October 2024

df = my_spark.read.parquet('yellow_tripdata_2024-10.parquet')
df_reparted = df.repartition(4)
df_reparted.write.mode('overwrite').parquet('yellow_tripdata_2024-10_partitioned')

## Question 3: Count records
### Approach 1: Using Spark SQL
df_reparted.createOrReplaceTempView("trips_data")

select_oct15 = "select count(1) from trips_data where cast(tpep_pickup_datetime as date) = '2024-10-15'"

count_oct15_sql = my_spark.sql(select_oct15).show()

### Approach 2: Using Pandas - not suitable for big datasets
import pandas as pd

# df_pandas = df.toPandas()
# df_pandas['tpep_pickup_datetime'] = pd.to_datetime(df_pandas['tpep_pickup_datetime'])
# count_oct15_pandas = df_pandas[df_pandas['tpep_pickup_datetime'].dt.date == pd.to_datetime('2024-10-15').date()].shape[0]

# print("Count for 2024-10-15:", count_oct15_pandas)


## Question 4: Longest trip

# check the column type to see if we can use it directly

df_reparted.printSchema()

from pyspark.sql.functions import col, unix_timestamp

df_reparted = df_reparted.withColumn(
    "trip_duration_hours", 
    (unix_timestamp("tpep_dropoff_datetime") - unix_timestamp("tpep_pickup_datetime")) / 3600
)

# update with the new column
df_reparted.createOrReplaceTempView("trips_data")

### Approach 1: Using Spark SQL Query
select_longest_query = "select max(trip_duration_hours) from trips_data"

longest_trip = my_spark.sql(select_longest_query).show()
           
### Approach 2: Using Aggregating Function
from pyspark.sql.functions import max

df_reparted.agg(max("trip_duration_hours")).show()


## Question 6: Least frequent pickup location zone
df_reparted.createOrReplaceTempView("trips_data")

taxi_zone_df = my_spark.read.option("header", True).csv('taxi_zone_lookup.csv')

taxi_zone_df.createOrReplaceTempView("taxi_zone")

# check the schema
taxi_zone_df.printSchema()

### Approach 1: Using Spark SQL Query

least_frequent_query = """
    select Zone, count(*) as num_trips from taxi_zone
    right join trips_data on taxi_zone.LocationID = trips_data.PULocationID
    group by Zone
    order by num_trips asc
"""

least_frequent_zone = my_spark.sql(least_frequent_query).show()



### Approach 2: Using PySpark internal Function
df_with_pickup_location = df_reparted.join(taxi_zone_df, df_reparted["PULocationID"] == taxi_zone_df["LocationID"], how="left")

df_with_pickup_location.groupBy("Zone").count().orderBy("count").show(1)


## Question 5: Spark UI Check
import time

time.sleep(300)
my_spark.stop()