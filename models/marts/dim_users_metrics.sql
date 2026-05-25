with users_purchase as (
    select * from {{ ref("int_users_purchase") }}
),

final as (
    select
            user_id,

            -- basic personal information
            first_name,
            last_name,
            email,
            age,
            gender,

            -- geographic information
            country,
            state,
            city,
            street_address,
            postal_code,
            latitude,
            longitude,
            user_geom,

            -- source and timestamp
            traffic_source,
            user_created_at_utc,
            first_order_time,

            -- ltv for different time ranges
            first_order_price,
            ltv_7d,
            ltv_30d,
            ltv_90d,
            ltv_180d,
            ltv_360d,

            -- margin for different time ranges
            first_order_margin,
            ltv_margin_7d,
            ltv_margin_30d,
            ltv_margin_90d,
            ltv_margin_180d,
            ltv_margin_360d,

            -- orders amount
            orders_amount_7d,
            orders_amount_30d,
            orders_amount_90d,
            orders_amount_180d,
            orders_amount_360d,

            -- number of item
            first_order_num_of_item,
            num_of_item_7d,
            num_of_item_30d,
            num_of_item_90d,
            num_of_item_180d,
            num_of_item_360d
        from users_purchase
)

select * from final