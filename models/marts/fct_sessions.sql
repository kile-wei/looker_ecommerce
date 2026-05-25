with
    session_table as (select * from {{ ref("int_sessions_aggregated") }}),

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
            product_at_utc,
            cart_at_utc,
            purchase_at_utc,
            session_end_at_utc,
            session_start_at_utc,

            -- Derived metric: Calculate session duration
            timestamp_diff(
                session_end_at_utc, session_start_at_utc, second
            ) as session_duration_seconds,

            -- Derived metric: Advanced funnel indicator (e.g., high-intent user session / abandoned cart)
            case
                when has_added_to_cart = 1 and has_purchased = 0 then true else false
            end as is_abandoned_cart

        from session_table
    )

select *
from final