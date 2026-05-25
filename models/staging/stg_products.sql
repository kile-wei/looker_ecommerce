with source as (
    select * from {{ source('thelook_ecommerce', 'products') }}
),

renamed as (
    select
        -- 1. Keys
        id as product_id,
        distribution_center_id,
        
        -- 2. Product Details
        {{clean_string('name')}} as name,
        {{clean_string('brand')}} as brand,
        {{clean_string('category')}} as category,
        {{clean_string('department')}} as department,
        {{clean_string('sku')}} as sku,
        
        -- 3. Pricing
        cost,
        retail_price
        
    from source
)

select * from renamed