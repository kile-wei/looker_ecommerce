with
    orders as (select * from {{ ref("stg_orders") }}),

    order_items as (select * from {{ ref("stg_order_items") }}),

    users as (select * from {{ ref("stg_users") }}),

    inventory_items as (select * from {{ ref("stg_inventory_items") }}),

    order_items_join_inventory as (
        -- add cost to order item
        select
            oi.order_item_id, oi.order_id, oi.sale_price, oi.inventory_item_id, ii.cost
        from order_items as oi
        left join inventory_items as ii on oi.inventory_item_id = ii.inventory_item_id
    ),

    order_price_cost as (
        -- calculate total price and cost for each order
        select order_id, sum(sale_price) as sale_price, sum(cost) as cost
        from order_items_join_inventory
        group by 1
    ),

    first_order_times as (
        -- calculate the first order time for each user
        select
            user_id,
            order_id,
            min(created_at_utc) over (partition by user_id) as first_order_time,
            created_at_utc,
            num_of_item
        from orders
        where status = 'Complete'
    ),

    first_order_times_price as (
        -- join order_time and price/cost
        select
            fot.user_id,
            fot.order_id,
            fot.first_order_time,
            fot.created_at_utc,
            date_diff(
                fot.created_at_utc, fot.first_order_time, day
            ) as days_from_first_order,
            fot.num_of_item,
            opc.sale_price,
            opc.cost
        from first_order_times as fot
        left join order_price_cost as opc on fot.order_id = opc.order_id
    ),

    users_aggregation as (
        -- aggregate ltv, order numbers, item numbers and margin for each user
        select
            user_id,
            min(first_order_time) as first_order_time,

            -- ltv for different time ranges
            sum(
                if(created_at_utc = first_order_time, sale_price, null)
            ) as first_order_price,
            sum(if(days_from_first_order < 7, sale_price, null)) as ltv_7d,
            sum(if(days_from_first_order < 30, sale_price, null)) as ltv_30d,
            sum(if(days_from_first_order < 90, sale_price, null)) as ltv_90d,
            sum(if(days_from_first_order < 180, sale_price, null)) as ltv_180d,
            sum(if(days_from_first_order < 360, sale_price, null)) as ltv_360d,

            -- margin for different time ranges
            sum(
                if(created_at_utc = first_order_time, sale_price - cost, null)
            ) as first_order_margin,
            sum(
                if(days_from_first_order < 7, sale_price - cost, null)
            ) as ltv_margin_7d,
            sum(
                if(days_from_first_order < 30, sale_price - cost, null)
            ) as ltv_margin_30d,
            sum(
                if(days_from_first_order < 90, sale_price - cost, null)
            ) as ltv_margin_90d,
            sum(
                if(days_from_first_order < 180, sale_price - cost, null)
            ) as ltv_margin_180d,
            sum(
                if(days_from_first_order < 360, sale_price - cost, null)
            ) as ltv_margin_360d,

            -- orders amount
            sum(if(days_from_first_order < 7, 1, null)) as orders_amount_7d,
            sum(if(days_from_first_order < 30, 1, null)) as orders_amount_30d,
            sum(if(days_from_first_order < 90, 1, null)) as orders_amount_90d,
            sum(if(days_from_first_order < 180, 1, null)) as orders_amount_180d,
            sum(if(days_from_first_order < 360, 1, null)) as orders_amount_360d,

            -- number of item
            sum(
                if(created_at_utc = first_order_time, num_of_item, null)
            ) as first_order_num_of_item,
            sum(if(days_from_first_order < 7, num_of_item, null)) as num_of_item_7d,
            sum(if(days_from_first_order < 30, num_of_item, null)) as num_of_item_30d,
            sum(if(days_from_first_order < 90, num_of_item, null)) as num_of_item_90d,
            sum(if(days_from_first_order < 180, num_of_item, null)) as num_of_item_180d,
            sum(if(days_from_first_order < 360, num_of_item, null)) as num_of_item_360d
        from first_order_times_price
        group by 1
    ),

    final as (
        select
            u.user_id,

            -- 2. 基础个人信息
            u.first_name,
            u.last_name,
            u.email,
            u.age,
            u.gender,

            -- 3. 地理位置信息
            u.country,
            u.state,
            u.city,
            u.street_address,
            u.postal_code,
            u.latitude,
            u.longitude,
            u.user_geom,

            -- 4. 来源与系统时间戳
            u.traffic_source,
            u.created_at_utc as user_created_at_utc,
            ua.first_order_time,

            -- ltv for different time ranges
            ua.first_order_price,
            ua.ltv_7d,
            ua.ltv_30d,
            ua.ltv_90d,
            ua.ltv_180d,
            ua.ltv_360d,

            -- margin for different time ranges
            ua.first_order_margin,
            ua.ltv_margin_7d,
            ua.ltv_margin_30d,
            ua.ltv_margin_90d,
            ua.ltv_margin_180d,
            ua.ltv_margin_360d,

            -- orders amount
            ua.orders_amount_7d,
            ua.orders_amount_30d,
            ua.orders_amount_90d,
            ua.orders_amount_180d,
            ua.orders_amount_360d,

            -- number of item
            ua.first_order_num_of_item,
            ua.num_of_item_7d,
            ua.num_of_item_30d,
            ua.num_of_item_90d,
            ua.num_of_item_180d,
            ua.num_of_item_360d
        from users as u
        left join users_aggregation as ua on u.user_id = ua.user_id
    )

select *
from final
