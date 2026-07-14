with src as (
    select *
    from (
        values
            (1, '2026-01-10', 125.50),
            (2, '2026-01-11', 49.99),
            (3, '2026-01-11', 250.00)
    ) as t(order_id, order_date, order_amount)
)

select
    cast(order_id as integer) as order_id,
    cast(order_date as date) as order_date,
    cast(order_amount as double) as order_amount
from src
