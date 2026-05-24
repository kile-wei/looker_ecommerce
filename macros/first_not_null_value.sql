{% macro first_not_null_value(column_n, order_v) %}

    (ARRAY_AGG({{ column_n }} IGNORE NULLS ORDER BY {{ order_v }} LIMIT 1))[SAFE_OFFSET(0)]

{% endmacro %}