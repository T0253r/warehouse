import pandas as pd
import yaml
import math

def generate_yaml_schema(input_csv_path, output_yml_path):
    # 1. Read the CSV file
    df = pd.read_csv(input_csv_path)
    
    # Clean up column names in case there is trailing whitespace
    df.columns = df.columns.str.strip()
    
    # 2. Initialize the base structure
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
    
    # 3. Group by 'table' (sort=False keeps the original order of the CSV)
    for table_name, table_group in df.groupby("table", sort=False):
        table_dict = {
            "name": table_name,
            "columns": []
        }
        
        # 4. Group by 'field name' within each table
        for field_name, field_group in table_group.groupby("field name", sort=False):
            # Fill NaNs with empty strings to make checking easier
            field_group = field_group.fillna("")
            
            # Find the description (which sits in the 'note' column)
            notes = field_group["note"].loc[field_group["note"] != ""]
            description = str(notes.iloc[0]).strip() if len(notes) > 0 else ""
            
            column_dict = {"name": field_name}
            
            if description:
                column_dict["description"] = description
                
            # 5. Collect allowed_values mapping [code/format] -> [label]
            allowed_values = {}
            for _, row in field_group.iterrows():
                code = str(row["code/format"]).strip()
                label = str(row["label"]).strip()
                
                # If both exist, this row defines a mapping
                if code and label:
                    # Clean up numeric codes (e.g., '1.0' -> 1) for prettier YAML
                    try:
                        if float(code).is_integer():
                            code_key = int(float(code))
                        else:
                            code_key = float(code)
                    except ValueError:
                        code_key = code # Fallback to string if it's text
                        
                    allowed_values[code_key] = label
                    
            # Only add meta and allowed_values if there's mapping data available
            if allowed_values:
                column_dict["meta"] = {
                    "allowed_values": allowed_values
                }
                
            table_dict["columns"].append(column_dict)
            
        tables_list.append(table_dict)
        
    # 6. Custom Dumper to indent list items (-) properly (a standard convention for dbt schemas)
    class IndentedDumper(yaml.Dumper):
        def increase_indent(self, flow=False, indentless=False):
            return super(IndentedDumper, self).increase_indent(flow, False)

    # 7. Write out the YAML file
    with open(output_yml_path, "w", encoding="utf-8") as f:
        yaml.dump(
            schema, 
            f, 
            Dumper=IndentedDumper, 
            default_flow_style=False, # Forces block style (not inline JSON style)
            sort_keys=False,          # Preserves our column insertion order
            allow_unicode=True        # Preserves special characters
        )
    
    print(f"Successfully generated '{output_yml_path}'!")

if __name__ == "__main__":
    # Change these filenames if your local files are named differently
    input_file = "/home/t0253r/Studia/hurtownie/duck_warehouse/data/data_guide/dft-road-casualty-statistics-road-safety-open-dataset-data-guide-2024.csv"
    output_file = "/home/t0253r/Studia/hurtownie/duck_warehouse/pipeline/scripts/generated_schema.yml"
    
    generate_yaml_schema(input_file, output_file)