-- approach 1:
-- dbt_project.yml, default value of days_back = 30
-- customize to 7: dbt build --select --vars '{ "days_back": 7 }'
select *
from {{ ref('fact_trips') }}
WHERE DATE(pickup_datetime) >= '2020-12-20' - INTERVAL {{ var("days_back") }} DAY

-- approach 2:
-- no need to configure the yml or use the flag in the command line
-- command line > ENV_VAR > default
-- select *
-- from {{ ref('fact_trips') }}
-- where
-- DATE(pickup_datetime)  >= '2020-12-20' - INTERVAL '{{ var("days_back", env_var("DAYS_BACK", "30")) }}' DAY