with
    source as (select * from {{ source("thelook_ecommerce", "users") }}),

    renamed as (
        select
            -- 1. Primary Key
            id as user_id,

            -- 2. PII - Personally Identifiable Information
            first_name,
            last_name,
            email,
            age,
            gender,

            -- 3. Location Data
            {{clean_string('country')}} as country,
            {{clean_string('state')}} as state,
            {{clean_string('city')}} as city,
            {{clean_string('street_address', '')}} as street_address,
            {{clean_string('postal_code')}} as postal_code,
            latitude,
            longitude,
            user_geom,

            -- 4. Metadata
            {{clean_string('traffic_source')}} as traffic_source,
            created_at as created_at_utc

        from source
    )

select *
from renamed
