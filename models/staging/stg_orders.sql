with source as (
    select * from {{ source('thelook_ecommerce', 'orders') }}
),

renamed as (
    select
        -- 1. Keys
        order_id,
        user_id,
        
        -- 2. Order Details
        {{clean_string('status')}} as status,
        {{clean_string('gender')}} as gender,
        num_of_item,
        
        -- 3. Timestamps
        created_at as created_at_utc,
        shipped_at as shipped_at_utc,
        delivered_at as delivered_at_utc,
        returned_at as returned_at_utc
        
    from source
)

select * from renamed