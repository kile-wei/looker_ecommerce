with users_metrics as (
    select * from {{ ref('dim_users_metrics')}}
)

select
    *
from users_metrics
where
    -- ==========================================
    -- Rule 1: Cumulative Revenue Check 
    -- (LTV of a longer time window must be >= the previous shorter window)
    -- ==========================================
    -- Use coalesce to handle NULL values 
    -- (e.g., if a user hasn't placed an order or lacks data in certain time windows)
    coalesce(ltv_7d, 0) < coalesce(first_order_price, 0)
    or coalesce(ltv_30d, 0) < coalesce(ltv_7d, 0)
    or coalesce(ltv_90d, 0) < coalesce(ltv_30d, 0)
    or coalesce(ltv_180d, 0) < coalesce(ltv_90d, 0)
    or coalesce(ltv_360d, 0) < coalesce(ltv_180d, 0)

    -- ==========================================
    -- Rule 2: Cumulative Item Count Check
    -- ==========================================
    or coalesce(num_of_item_7d, 0) < coalesce(first_order_num_of_item, 0)
    or coalesce(num_of_item_30d, 0) < coalesce(num_of_item_7d, 0)
    or coalesce(num_of_item_90d, 0) < coalesce(num_of_item_30d, 0)
    or coalesce(num_of_item_180d, 0) < coalesce(num_of_item_90d, 0)
    or coalesce(num_of_item_360d, 0) < coalesce(num_of_item_180d, 0)