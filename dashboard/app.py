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
df = con.execute("""
    SELECT 
        EXTRACT(YEAR FROM accident_date) AS collision_year, 
        COUNT(accident_id) as total_accidents 
    FROM fct_placeholder 
    GROUP BY 1 
    ORDER BY 1
""").df()

st.bar_chart(df.set_index('collision_year'))