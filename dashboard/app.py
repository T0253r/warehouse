# dashboard/app.py
import streamlit as st
import duckdb
import polars as pl

st.set_page_config(page_title="STATS19 Data Preview", layout="wide")
st.title("UK STATS19 Accident Warehouse Insights")
st.write("Previewing cross-granularity metrics using the newly built dimensional star schema.")

# Maintain a lightweight cached connection to the read-only DuckDB file
@st.cache_resource
def get_connection():
    return duckdb.connect('/home/t0253r/Studia/hurtownie/warehouse/data/duck_warehouse.duckdb', read_only=True)

con = get_connection()

# --- TOP ROW: Standard Grain Queries ---
col1, col2 = st.columns(2)

with col1:
    st.subheader("Total Collisions by Year")
    # Standard Level 1 Join
    yearly_collisions = con.execute("""
        SELECT 
            d.collision_year, 
            COUNT(f.collision_key) as total_collisions 
        FROM fct_collision f
        JOIN dim_date d ON f.date_key = d.date_key
        GROUP BY 1 
        ORDER BY 1
    """).pl()
    
    st.line_chart(yearly_collisions, x='collision_year', y='total_collisions')

with col2:
    st.subheader("Casualties by Severity")
    # Standard Level 2 Join (Querying Dim directly for pure entity stats)
    severity = con.execute("""
        SELECT 
            CASE casualty_severity 
                WHEN 1 THEN 'Fatal' 
                WHEN 2 THEN 'Serious' 
                WHEN 3 THEN 'Slight' 
                ELSE 'Unknown' 
            END as severity_level,
            COUNT(*) as casualty_count 
        FROM dim_casualty 
        GROUP BY 1
    """).pl()
    
    st.bar_chart(severity, x='severity_level', y='casualty_count')

st.divider()

# --- BOTTOM ROW: Cross-Granularity Showcases ---
st.write("### Cross-Granularity Analysis")
st.write("Showcasing the power of Factless Fact tables to bridge different grains.")
st.write("") # Spacer

col3, col4 = st.columns(2)

with col3:
    st.subheader("Casualties by Weather Condition")
    st.caption("Level 2 Casualty ➔ Factless Fact ➔ Fact Collision ➔ Level 1 Condition")
    
    # Cross-granularity: Linking casualties up to the collision's overall weather
    weather_casualties = con.execute("""
        SELECT 
            CASE dc.weather_conditions
                WHEN 1 THEN 'Fine (no high winds)'
                WHEN 2 THEN 'Raining (no high winds)'
                WHEN 3 THEN 'Snowing (no high winds)'
                WHEN 4 THEN 'Fine + high winds'
                WHEN 5 THEN 'Raining + high winds'
                WHEN 6 THEN 'Snowing + high winds'
                WHEN 7 THEN 'Fog or mist'
                ELSE 'Other/Unknown'
            END as weather,
            COUNT(fci.casualty_key) as total_casualties
        FROM fct_casualty_involvement fci
        JOIN fct_collision fc ON fci.collision_key = fc.collision_key
        JOIN dim_condition dc ON fc.condition_key = dc.condition_key
        GROUP BY 1
    """).pl()
    
    st.bar_chart(weather_casualties, x='weather', y='total_casualties')

with col4:
    st.subheader("Casualties by Vehicle Point of Impact")
    st.caption("Level 2 Casualty ➔ Factless Fact ➔ Fact Vehicle ➔ Level 2 Dynamics")
    
    # Cross-granularity: Linking casualties directly to the specific vehicle dynamics
    impact_casualties = con.execute("""
        SELECT 
            CASE dcd.first_point_of_impact
                WHEN 0 THEN 'Did not impact'
                WHEN 1 THEN 'Front'
                WHEN 2 THEN 'Back'
                WHEN 3 THEN 'Offside (Right)'
                WHEN 4 THEN 'Nearside (Left)'
                ELSE 'Other/Unknown'
            END as impact_point,
            COUNT(fci.casualty_key) as total_casualties
        FROM fct_casualty_involvement fci
        JOIN fct_vehicle_involvement fvi ON fci.vehicle_key = fvi.vehicle_key
        JOIN dim_collision_dynamics dcd ON fvi.dynamics_key = dcd.dynamics_key
        GROUP BY 1
    """).pl()
    
    st.bar_chart(impact_casualties, x='impact_point', y='total_casualties')