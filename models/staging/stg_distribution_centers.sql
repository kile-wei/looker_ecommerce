with
    source as (select * from {{ source("thelook_ecommerce", "distribution_centers") }}),

    renamed as (
        select
            -- 1. Primary Key
            id as distribution_center_id,
            name,
            latitude,
            longitude,
            distribution_center_geom

        from source
    )

select *
from renamed
