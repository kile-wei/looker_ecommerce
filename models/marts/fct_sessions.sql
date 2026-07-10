{{
  config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='session_id',
    partition_by={
      "field": "session_start_date",
      "data_type": "date",
      "granularity": "day"
    },
    cluster_by=['traffic_source', 'user_id']
  )
}}

-- Grain: one row per session
-- Primary key: session_id
-- Incremental strategy: merge on session_id
-- Partition: session_start_date
-- Cluster: traffic_source, user_id

with
    session_table as (
        select * from {{ ref("int_sessions_aggregated") }}
        
        {% if is_incremental() %}
        where session_end_at_utc >= (
          select timestamp_sub(
              coalesce(max(session_end_at_utc), timestamp('1900-01-01')),
              interval 3 day
          )
          from {{ this }}
              )
        {% endif %}
    ),

    final as (
        select
            session_id,
            user_id,
            browser,
            traffic_source,
            city,
            state,

            -- Inherit all funnel statuses and timestamps
            has_viewed_home,
            has_viewed_department,
            has_viewed_product,
            has_added_to_cart,
            has_purchased,
            has_cancelled,
            home_at_utc,
            department_at_utc,
            product_at_utc,
            cart_at_utc,
            purchase_at_utc,
            session_end_at_utc,
            session_start_at_utc,
            date(session_start_at_utc) as session_start_date,

            -- Derived metric: Calculate session duration
            timestamp_diff(
                session_end_at_utc, session_start_at_utc, second
            ) as session_duration_seconds,

            -- Derived metric: Advanced funnel indicator (e.g., high-intent user session / abandoned cart)
            case
                when has_added_to_cart = 1 and has_purchased = 0 then true else false
            end as is_abandoned_cart,

            events_in_session

        from session_table
    )

select *
from final