--- external yellow trip data
create or replace external table `iconic-heading-449916-n9.trips_data_all.external_yellow_tripdata`
options (
  format = 'csv',
  uris = [
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2020-*.csv.gz',
    'gs://dezoomcamp-nytaxi/yellow_tripdata_2019-*.csv.gz'
  ]
);

--- external green trip data
create or replace external table `iconic-heading-449916-n9.trips_data_all.external_green_tripdata`
options (
  format = 'csv',
  uris = [
    'gs://dezoomcamp-nytaxi/green_tripdata_2020-*.csv.gz',
    'gs://dezoomcamp-nytaxi/green_tripdata_2019-*.csv.gz'
  ]
);


--- external fhv trip data
create or replace external table `iconic-heading-449916-n9.trips_data_all.external_fhv_tripdata`
options (
  format = 'csv',
  uris = [
    'gs://dezoomcamp-nytaxi/fhv_tripdata_2019-*.csv.gz'
  ]
);

--- create native table
create or replace table `iconic-heading-449916-n9.trips_data_all.fhv_tripdata`
as(
  select * from `iconic-heading-449916-n9.trips_data_all.external_fhv_tripdata`
);

create or replace table `iconic-heading-449916-n9.trips_data_all.green_tripdata`
as(
  select * from `iconic-heading-449916-n9.trips_data_all.external_green_tripdata`
);

create or replace table `iconic-heading-449916-n9.trips_data_all.yellow_tripdata`
as(
  select * from `iconic-heading-449916-n9.trips_data_all.external_yellow_tripdata`
);


--- check the number of records
select count(*) from `iconic-heading-449916-n9.trips_data_all.fhv_tripdata`;
select count(*) from `iconic-heading-449916-n9.trips_data_all.green_tripdata`;
select count(*) from `iconic-heading-449916-n9.trips_data_all.yellow_tripdata`;