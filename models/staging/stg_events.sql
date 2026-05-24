with source as (
    select * from {{ source('thelook_ecommerce', 'events') }}
),

renamed as (
    select
        -- 1. Primary Key and Foreign Keys (Keys)
        id as event_id,
        user_id,
        session_id,
        
        -- 2. Event Details
        sequence_number,
        {{clean_string('event_type')}} as event_type,
        uri,
        
        -- 3. Device & Network
        {{clean_string('browser')}} as browser,
        ip_address,
        {{clean_string('traffic_source')}} as traffic_source,
        
        -- 4. Location Data
        {{clean_string('city')}} as city,
        {{clean_string('state')}} as state,
        {{clean_string('postal_code')}} as postal_code,
        
        -- 5. Timestamp
        created_at as created_at_utc
        
    from source
)

select * from renamed