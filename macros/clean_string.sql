{% macro clean_string(column_n, default_v="Unkown") %}

    case
        when lower(trim({{ column_n }})) in ('', 'null', 'n/a', 'none', '-')
        then '{{default_v}}'
        when {{ column_n }} is null
        then '{{ default_v}}'
        else trim({{ column_n }})

    end

{% endmacro %}
