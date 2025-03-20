from pyflink.datastream import StreamExecutionEnvironment
from pyflink.table import EnvironmentSettings, DataTypes, TableEnvironment, StreamTableEnvironment
from pyflink.common.watermark_strategy import WatermarkStrategy
from pyflink.common.time import Duration

# Create a sink table: -> PosgreSQL
def create_events_aggregated_sink(t_env):
    table_name = 'processed_events_aggregated'
    sink_ddl = f"""
        CREATE TABLE {table_name} (
            PULocationID INT,
            DOLocationID INT,
            lpep_pickup_datetime TIMESTAMP(3),
            lpep_dropoff_datetime TIMESTAMP(3),
            num_hits BIGINT,
            PRIMARY KEY (PULocationID, DOLocationID, lpep_pickup_datetime, lpep_dropoff_datetime) NOT ENFORCED
        ) WITH (
            'connector' = 'jdbc',
            'url' = 'jdbc:postgresql://postgres:5432/postgres',
            'table-name' = '{table_name}',
            'username' = 'postgres',
            'password' = 'postgres',
            'driver' = 'org.postgresql.Driver'        
        );
        """
    t_env.execute_sql(sink_ddl)
    return table_name

# Create a Kafka source table: Kafka -> Flink
def create_events_source_kafka(t_env):
    table_name = "events"
    # Update the topic name
    # Precision of the timestamp is in milliseconds (3 decimal places)
    source_ddl = f"""
        CREATE TABLE {table_name} (
            lpep_pickup_datetime TIMESTAMP(3),
            lpep_dropoff_datetime TIMESTAMP(3),
            PULocationID INT,
            DOLocationID INT,
            WATERMARK for lpep_dropoff_datetime as lpep_dropoff_datetime - INTERVAL '5' SECOND
        ) WITH (
            'connector' = 'kafka',
            'properties.bootstrap.servers' = 'redpanda-1:29092',
            'topic' = 'green_tripdata',
            'scan.startup.mode' = 'earliest-offset',
            'properties.auto.offset.reset' = 'earliest',
            'format' = 'json'
        );
        """
    t_env.execute_sql(source_ddl)
    return table_name


def log_aggregation():
    # Set up the execution environment
    env = StreamExecutionEnvironment.get_execution_environment()
    env.enable_checkpointing(30 * 1000)
    env.set_parallelism(1)

    # Set up the table environment
    settings = EnvironmentSettings.new_instance().in_streaming_mode().build()
    t_env = StreamTableEnvironment.create(env, environment_settings=settings)


    try:
        # Create Kafka table
        source_table = create_events_source_kafka(t_env)
        aggregated_table = create_events_aggregated_sink(t_env)

        t_env.execute_sql(f"""
            INSERT INTO processed_events_aggregated
            SELECT
                PULocationID,
                DOLocationID,
                MIN(lpep_pickup_datetime) AS lpep_pickup_datetime,  
                MAX(lpep_dropoff_datetime) AS lpep_dropoff_datetime,
                count(*) AS num_hits                        
            FROM events
            GROUP BY
                PULocationID,
                DOLocationID,
                SESSION(lpep_dropoff_datetime, INTERVAL '5' MINUTE);
        """).wait()

    except Exception as e:
        print("Writing records from Kafka to JDBC failed:", str(e))


if __name__ == '__main__':
    log_aggregation()