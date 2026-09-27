{% macro clean_title(column_name) %}
    nullif(
        upper(substr(trim({{ column_name }}), 1, 1)) ||
        lower(substr(trim({{ column_name }}), 2)),
        ''
    )
{% endmacro %}
