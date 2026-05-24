with source as (
    select * from {{ source('thelook_ecommerce', 'inventory_items') }}
),

renamed as (
    select
        -- 1. Keys
        id as inventory_item_id,
        product_id,
        product_distribution_center_id as distribution_center_id,
        
        -- 2. Denormalized Product Details
        {{clean_string('product_name')}} as inbound_product_name,
        {{clean_string('product_brand')}} as inbound_product_brand,
        {{clean_string('product_category')}} as inbound_product_category,
        {{clean_string('product_department')}} as inbound_product_department,
        {{clean_string('product_sku')}} as inbound_product_sku,
        
        -- 3. 财务与库存状态 (Financials & Status)
        cost,
        product_retail_price as inbound_product_retail_price,
        
        -- 4. Timestamps
        created_at as created_at_utc,
        sold_at as sold_at_utc
        
    from source
)

select * from renamed