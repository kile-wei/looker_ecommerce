-- ==========================================
-- 1. Import CTEs
-- ==========================================
with
    order_items as (select * from {{ ref("int_order_joined_items") }}),

    users as (select * from {{ ref("stg_users") }}),

    orders as (select * from {{ ref("stg_orders") }}),

    products as (select * from {{ ref("stg_products") }}),

    distribution_centers as (select * from {{ ref("stg_distribution_centers") }}),

    joined_and_calculated as (
        select
            oi.order_item_id,
            oi.order_id,
            oi.user_id,
            oi.product_id,
            oi.inventory_item_id,
            oi.distribution_center_id,

            oi.status,
            oi.shipped_at_utc,
            oi.delivered_at_utc,
            oi.returned_at_utc,

            oi.sale_price,
            oi.inventory_cost,

            oi.inbound_created_at_utc,
            oi.inbound_product_retail_price,

            oi.item_gross_margin,

            -- user information
            u.first_name as user_first_name,
            u.last_name as user_last_name,
            u.email as user_email,
            u.age as user_age,
            u.gender as user_gender,
            u.country as user_country,
            u.state as user_state,
            u.city as user_city,
            u.street_address as user_street_address,
            u.postal_code as user_postal_code,
            u.latitude as user_latitude,
            u.longitude as user_longitude,
            u.user_geom as user_geom,
            u.traffic_source as user_traffic_source,
            u.created_at_utc as user_created_at_utc,

            --order information
            o.num_of_item as order_num_of_item,
            o.created_at_utc as order_created_at_utc,

            --product information
            p.name as product_name,
            p.brand as product_brand,
            p.category as product_category,
            p.department as product_department,
            p.sku as product_sku,

            --distirbution center information
            dc.name as distribution_center_name,
            dc.latitude as distribution_center_latitude,
            dc.longitude as distribution_center_longitude,
            dc.distribution_center_geom
        from order_items as oi
        left join users as u
        on oi.user_id = u.user_id
        left join orders as o
        on oi.order_id = o.order_id
        left join products as p
        on oi.product_id = p.product_id
        left join distribution_centers as dc
        on oi.distribution_center_id = dc.distribution_center_id
    )

select *
from joined_and_calculated
