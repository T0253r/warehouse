import duckdb
import yaml

def generate_yaml_schema(input_csv_path, output_yml_path):
    # 1. Connect to an in-memory DuckDB instance
    conn = duckdb.connect()
    
    # 2. Query, clean, and sort the CSV directly in SQL
    # We use read_csv_auto() and sort by table and field name to build our hierarchy sequentially.
    query = f"""
        SELECT 
            TRIM("table") AS table_name,
            TRIM("field name") AS field_name,
            TRIM("note") AS note,
            TRIM(CAST("code/format" AS VARCHAR)) AS code_format,
            TRIM("label") AS label
        FROM read_csv_auto('{input_csv_path}')
        WHERE "table" IS NOT NULL
        ORDER BY "table", "field name"
    """
    
    # Execute and fetch all rows as tuples
    rows = conn.execute(query).fetchall()
    
    # 3. Initialize the base structure
    schema = {
        "sources": [
            {
                "name": "dft",
                "description": "Raw STATS19 open data downloaded from the DfT.",
                "schema": "main",
                "tables": []
            }
        ]
    }
    
    tables_list = schema["sources"][0]["tables"]
    
    # State-tracking variables for our sequential loop
    current_table_name = None
    current_field_name = None
    current_table_dict = None
    current_column_dict = None

    # 4. Iterate over the sorted flat rows to build the nested dictionaries
    for row in rows:
        # DuckDB returns None for empty CSV cells (SQL NULL)
        t_name = row[0] or ""
        f_name = row[1] or ""
        note = row[2] or ""
        code = row[3] or ""
        label = row[4] or ""
        
        # Table level change
        if t_name != current_table_name:
            current_table_dict = {
                "name": t_name,
                "columns": []
            }
            tables_list.append(current_table_dict)
            current_table_name = t_name
            current_field_name = None # Reset field tracker on new table
            
        # Field level change
        if f_name != current_field_name:
            current_column_dict = {"name": f_name}
            
            # Add description if it exists (grabbing the first non-empty note for this field)
            if note:
                current_column_dict["description"] = note
                
            current_table_dict["columns"].append(current_column_dict)
            current_field_name = f_name
            
        # 5. Collect allowed_values mapping
        if code and label:
            # Ensure the 'meta' and 'allowed_values' dicts exist
            if "meta" not in current_column_dict:
                current_column_dict["meta"] = {"allowed_values": {}}
                
            # Clean up numeric codes (e.g., '1.0' -> 1) for prettier YAML
            try:
                if float(code).is_integer():
                    code_key = int(float(code))
                else:
                    code_key = float(code)
            except ValueError:
                code_key = code # Fallback to string if it's text
                
            current_column_dict["meta"]["allowed_values"][code_key] = label

    # 6. Custom Dumper to indent list items (-) properly 
    class IndentedDumper(yaml.Dumper):
        def increase_indent(self, flow=False, indentless=False):
            return super(IndentedDumper, self).increase_indent(flow, False)

    # 7. Write out the YAML file
    with open(output_yml_path, "w", encoding="utf-8") as f:
        yaml.dump(
            schema, 
            f, 
            Dumper=IndentedDumper, 
            default_flow_style=False, # Forces block style
            sort_keys=False,          # Preserves column insertion order
            allow_unicode=True        # Preserves special characters
        )
    
    print(f"Successfully generated '{output_yml_path}' using DuckDB!")

if __name__ == "__main__":
    input_file = "/home/t0253r/Studia/hurtownie/warehouse/data/data_guide/dft-road-casualty-statistics-road-safety-open-dataset-data-guide-2024.csv"
    output_file = "/home/t0253r/Studia/hurtownie/warehouse/pipeline/scripts/schema_genaration/generated_schema.yml"
    
    generate_yaml_schema(input_file, output_file)