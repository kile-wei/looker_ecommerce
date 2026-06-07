-- ==========================================
-- 1. Import CTEs
-- ==========================================
with order_items as (
    select * from {{ ref('stg_order_items') }}
),

inventory_items as (
    select * from {{ ref('stg_inventory_items') }}
),

-- ==========================================
-- 2. Logical CTEs
-- ==========================================
joined_and_calculated as (
    select
        -- Keys
        oi.order_item_id,
        oi.order_id,
        oi.user_id,
        oi.product_id,
        oi.inventory_item_id,
        ii.distribution_center_id as distribution_center_id,
        
        -- Status & Timestamps
        oi.status,
        oi.created_at_utc,
        oi.shipped_at_utc,
        oi.delivered_at_utc,
        oi.returned_at_utc,
        
        -- Financials
        oi.sale_price,
        ii.cost as inventory_cost,

        --inbound information
        ii.created_at_utc as inbound_created_at_utc,
        ii.inbound_product_retail_price,
        
        -- margin calculation
        oi.sale_price - coalesce(ii.cost, 0) as item_gross_margin

    from order_items as oi
    left join inventory_items as ii
        on oi.inventory_item_id = ii.inventory_item_id
)

-- ==========================================
-- 3. Final Select
-- ==========================================
select * from joined_and_calculated