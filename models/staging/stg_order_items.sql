with source as (
    select * from {{ source('thelook_ecommerce', 'order_items') }}
),

renamed as (
    select
        -- 1. Keys
        id as order_item_id,
        order_id,
        user_id,
        product_id,
        inventory_item_id,
        
        -- 2. Item Details
        {{clean_string('status')}} as status,
        sale_price,
        
        -- 3. Timestamps
        created_at as created_at_utc,
        shipped_at as shipped_at_utc,
        delivered_at as delivered_at_utc,
        returned_at as returned_at_utc
        
    from source
)

select * from renamed