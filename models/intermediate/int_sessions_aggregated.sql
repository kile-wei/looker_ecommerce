with
    events as (select * from {{ ref("stg_events") }}),

    aggregated as (
        select
            session_id,

            -- Get the first not null values for each session
            {{ first_not_null_value("user_id", "created_at_utc") }} as user_id,
            {{ first_not_null_value("browser", "created_at_utc") }} as browser,
            {{ first_not_null_value("traffic_source", "created_at_utc") }}
            as traffic_source,
            {{ first_not_null_value("city", "created_at_utc") }} as city,
            {{ first_not_null_value("state", "created_at_utc") }} as state,

            -- Funnel factors
            max(case when event_type = 'home' then 1 else 0 end) as has_viewed_home,
            max(
                case when event_type = 'department' then 1 else 0 end
            ) as has_viewed_department,
            max(
                case when event_type = 'product' then 1 else 0 end
            ) as has_viewed_product,
            max(case when event_type = 'cart' then 1 else 0 end) as has_added_to_cart,
            max(case when event_type = 'purchase' then 1 else 0 end) as has_purchased,
            max(case when event_type = 'cancel' then 1 else 0 end) as has_cancelled,

            -- Funnel timestamp
            min(case when event_type = 'home' then created_at_utc end) as home_at_utc,
            min(
                case when event_type = 'department' then created_at_utc end
            ) as department_at_utc,
            min(case when event_type = 'product' then created_at_utc end) as product_at_utc,
            min(case when event_type = 'cart' then created_at_utc end) as cart_at_utc,
            min(case when event_type = 'purchase' then created_at_utc end) as purchase_at_utc,

            -- Session period data
            min(created_at_utc) as session_start_at_utc,
            max(created_at_utc) as session_end_at_utc,
            count(distinct event_id) as events_in_session

        from events
        group by session_id
    )

select *
from aggregated
