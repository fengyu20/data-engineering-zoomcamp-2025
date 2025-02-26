# Homework

## Week 3 
```sql
-- create the external table from downloaded parquet
create or replace external table `iconic-heading-449916-n9.ny_taxi_dataset.external_yellow_tripdata_2024`
options (
  format = 'parquet',
  uris = [
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-01.parquet',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-02.parquet',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-03.parquet',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-04.parquet',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-05.parquet',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2024-06.parquet'
    ]
);

-- create the native table
create or replace table `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`
as(
  select * from `iconic-heading-449916-n9.ny_taxi_dataset.external_yellow_tripdata_2024`
);


-- Q1: count records ->20332093
select 
  count(*) 
from 
  `iconic-heading-449916-n9.ny_taxi_dataset.external_yellow_tripdata_2024`;

-- Q2: amount of data
--- external -> 0MB (appear on the top right corner of the console)
select 
  count(distinct PULocationID)
from
  `iconic-heading-449916-n9.ny_taxi_dataset.external_yellow_tripdata_2024`;

--- materialized -> 155.12MB
select 
  count(distinct PULocationID)
from
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`;


-- Q3: PULocationID, DOLocationID
--- only PULocationID -> 155.12MB
select 
  PULocationID
from 
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`;

--- PULocationID, DOLocationID -> 310.24MB
select 
  PULocationID, DOLocationID
from 
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`;


-- Q4: fare_amount = 0 -> 8333
select 
  count(fare_amount)
from
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`
where
  fare_amount = 0;

-- Q5: partition table
create or replace table `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024_partition`
  partition by date(tpep_dropoff_datetime)
  cluster by VendorID
as(
  select * from `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`
);

-- Q7: distinct VendorIDs
--- materialized table -> 310.24 MB
select 
  distinct VendorID
from
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024`
where
  date(tpep_dropoff_datetime) >='2024-03-01' and date(tpep_dropoff_datetime) <='2024-03-15' ;

--- partitioned table -> 26.84 MB
select 
  distinct VendorID
from
  `iconic-heading-449916-n9.ny_taxi_dataset.yellow_tripdata_2024_partition`
where
  date(tpep_dropoff_datetime) >='2024-03-01' and date(tpep_dropoff_datetime) <='2024-03-15' ;
```
