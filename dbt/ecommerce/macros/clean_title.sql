{% macro clean_title(column_name) %}
    nullif(
        upper(substr(trim(cast({{ column_name }} as varchar)), 1, 1)) ||
        lower(substr(trim(cast({{ column_name }} as varchar)), 2)),
        ''
    )
{% endmacro %}
