# dashboard/app.py
import streamlit as st
import duckdb
import pandas as pd

st.set_page_config(page_title="STATS19 Data Preview", layout="wide")
st.title("UK STATS19 Accident Warehouse Insights")
st.write("Previewing staged data directly from DuckDB before mart models are built.")

# Maintain a lightweight cached connection to the read-only DuckDB file
@st.cache_resource
def get_connection():
    return duckdb.connect('/home/t0253r/Studia/hurtownie/duck_warehouse/data/duck_warehouse.duckdb', read_only=True)

con = get_connection()

# Create layout with two columns for our first set of charts
col1, col2 = st.columns(2)

with col1:
    st.subheader("Total Collisions by Year")
    # Query stg_dft__collisions for a yearly trend
    yearly_collisions = con.execute("""
        SELECT 
            collision_year, 
            COUNT(collision_key) as total_collisions 
        FROM stg_dft__collisions 
        GROUP BY 1 
        ORDER BY 1
    """).arrow()
    
    st.line_chart(yearly_collisions, x='collision_year', y='total_collisions')

with col2:
    st.subheader("Collisions by Severity")
    # Map the severity codes based on _dft__sources.yml
    severity = con.execute("""
        SELECT 
            CASE collision_severity 
                WHEN 1 THEN 'Fatal' 
                WHEN 2 THEN 'Serious' 
                WHEN 3 THEN 'Slight' 
                ELSE 'Unknown' 
            END as severity_level,
            COUNT(*) as count 
        FROM stg_dft__collisions 
        GROUP BY 1
    """).df()
    
    # Setting index makes the bar chart use the text labels correctly on the x-axis
    st.bar_chart(severity.set_index('severity_level'))

st.divider()

col3, col4 = st.columns(2)

with col3:
    st.subheader("Collisions by Day of Week")
    # Map the day of week codes based on _dft__sources.yml
    dow_collisions = con.execute("""
        SELECT 
            CASE day_of_week
                WHEN 1 THEN 'Sunday'
                WHEN 2 THEN 'Monday'
                WHEN 3 THEN 'Tuesday'
                WHEN 4 THEN 'Wednesday'
                WHEN 5 THEN 'Thursday'
                WHEN 6 THEN 'Friday'
                WHEN 7 THEN 'Saturday'
                ELSE 'Unknown'
            END as day,
            COUNT(*) as total_collisions
        FROM stg_dft__collisions
        GROUP BY 1, day_of_week
        ORDER BY day_of_week
    """).df()
    
    st.bar_chart(dow_collisions.set_index('day'))

with col4:
    st.subheader("Casualties by Class")
    # Query stg_dft__casualties to see casualty breakdown
    casualty_class = con.execute("""
        SELECT 
            CASE casualty_class
                WHEN 1 THEN 'Driver or rider'
                WHEN 2 THEN 'Passenger'
                WHEN 3 THEN 'Pedestrian'
                ELSE 'Unknown'
            END as class_type,
            COUNT(*) as total_casualties
        FROM stg_dft__casualties
        GROUP BY 1
    """).df()
    
    st.bar_chart(casualty_class.set_index('class_type'))