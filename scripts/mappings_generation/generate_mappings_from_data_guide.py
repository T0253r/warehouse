import duckdb
import os

def generate_seed_csvs(input_csv_path, output_dir):
    # 1. Connect to an in-memory DuckDB instance
    conn = duckdb.connect()
    
    # 2. Ensure the output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # We read the CSV using all_varchar=True. This prevents DuckDB from assuming
    # integer codes are floats (which prevents '1' from becoming '1.0')
    read_csv_expr = f"read_csv_auto('{input_csv_path}', all_varchar=true)"
    
    # 3. Find all distinct field names that have code/label mappings
    query_fields = f"""
        SELECT DISTINCT TRIM("field name") AS field_name
        FROM {read_csv_expr}
        WHERE "field name" IS NOT NULL
          AND "code/format" IS NOT NULL
          AND "label" IS NOT NULL
    """
    
    # Fetch list of fields to process
    fields = conn.execute(query_fields).fetchall()
    
    # 4. Generate a distinct CSV file for each field
    for (field_name,) in fields:
        # Clean up the field name for file and column naming 
        # (e.g., 'Weather conditions' -> 'weather_conditions')
        clean_name = field_name.replace(' ', '_').replace('/', '_').lower()
        
        output_file = os.path.join(output_dir, f"seed_{clean_name}.csv")
        
        # 5. Extract distinct mappings and export directly to CSV natively using DuckDB
        export_query = f"""
            COPY (
                SELECT DISTINCT
                    TRIM("code/format") AS {clean_name}_code,
                    TRIM("label") AS {clean_name}_label
                FROM {read_csv_expr}
                WHERE TRIM("field name") = '{field_name}'
                  AND "code/format" IS NOT NULL
                  AND "label" IS NOT NULL
                ORDER BY 
                    -- Sort numerically if possible, otherwise alphabetically
                    TRY_CAST(TRIM("code/format") AS INTEGER) NULLS LAST, 
                    TRIM("code/format")
            ) TO '{output_file}' (HEADER, DELIMITER ',')
        """
        
        conn.execute(export_query)
        
    print(f"Successfully generated {len(fields)} seed CSVs in '{output_dir}'!")

if __name__ == "__main__":
    # Input file path
    input_file = "/home/t0253r/Studia/hurtownie/warehouse/data/data_guide/dft-road-casualty-statistics-road-safety-open-dataset-data-guide-2024.csv"
    
    # Output directory - Added a subfolder so it doesn't flood your base seeds directory
    output_dir = "/home/t0253r/Studia/hurtownie/warehouse/pipeline/dbt_project/seeds/dft_mappings"
    
    generate_seed_csvs(input_file, output_dir)