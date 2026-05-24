{#
    select event_type, count(1) as cs from {{ ref("stg_events") }} group by 1 order by 2 desc;

    select * from {{ ref("stg_events") }} where event_type = 'purchase' order by rand()
    7e8b7884-eeae-4d05-a00f-8c74bc153489
    5486b000-cdf0-4667-a70c-58c9a81e70d5
    0152c31d-ccbb-4ced-9d32-6bfea06c4339

    select * from {{ ref("stg_events") }} where session_id = '0152c31d-ccbb-4ced-9d32-6bfea06c4339' order by created_at_utc

    select * from my-project-20260419-493813.dbt_bigflagger233_dbt_test__audit.unique_stg_users_email
#}

select * from {{ ref('dim_users_metrics')}}