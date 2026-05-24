with sessions as (
    select * from {{ ref('fct_sessions')}}
)

select 
    *
from sessions
where
    session_end_at_utc < session_start_at_utc

    or (
        product_at_utc is not null
        and home_at_utc is not null
        and product_at_utc < home_at_utc
    )

    or (
        cart_at_utc is not null
        and product_at_utc is not null
        and cart_at_utc < product_at_utc
    )

    or (
        purchase_at_utc is not null
        and cart_at_utc is not null
        and purchase_at_utc < cart_at_utc
    )