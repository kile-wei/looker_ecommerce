{{
  config(
    materialized='table',
    cluster_by=['country', 'user_id']
  )
}}
-- Grain: one row per registered user
-- Primary key: user_id
-- Purpose: user-level lifetime value mart for acquisition, cohort, repeat purchase, and customer value analysis.
-- Notes:
--   - Includes both purchasing and non-purchasing registered users.
--   - LTV windows are calculated relative to each user's first_order_time.

with users_purchase as (
    select * from {{ ref("int_user_order_metrics") }}
),

final as (
    select
            user_id,

            -- basic personal information
            to_hex(sha256(cast(email as string))) as user_email_hash,
            age,
            gender,

            -- geographic information
            country,
            state,
            city,

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