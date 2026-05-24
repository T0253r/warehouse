# dashboard/app.py
import streamlit as st
import duckdb

st.title("UK STATS19 Accident Warehouse Insights")

# Maintain a lightweight cached connection to the read-only DuckDB file
@st.cache_resource
def get_connection():
    # Update this path to point to where dbt creates your local DuckDB file.
    # Assuming you run Streamlit from the root 'duck_warehouse' directory:
    return duckdb.connect('data/duck_warehouse.db', read_only=True)

con = get_connection()

# Query the table that dbt actually built (fct_placeholder)
# Extract the year from accident_date to match your desired visualization
# Use .arrow() instead of .df()
arrow_table = con.execute("""
    SELECT 
        EXTRACT(YEAR FROM accident_date) AS collision_year, 
        COUNT(accident_id) as total_accidents 
    FROM fct_placeholder 
    GROUP BY 1 
    ORDER BY 1
""").arrow()

# Streamlit can chart Arrow tables directly!
st.bar_chart(arrow_table, x='collision_year', y='total_accidents')