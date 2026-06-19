{% macro map_id(table_name, field_name, source_column=none) %}
    {%- if source_column is none -%}
        {%- set source_column = field_name -%}
    {%- endif -%}
    (
        select label 
        from {{ ref('seed_data_guide') }} 
        where "table" = '{{ table_name }}' 
          and "field name" = '{{ field_name }}' 
          and "code/format" = cast({{ source_column }} as varchar)
    )
{% endmacro %}
