# Check if at least one argument (YAML file) is passed
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <yaml_files...>"
    exit 1
fi

# Create the output TOML file
echo "[contracts]"

# Process each YAML file passed as an argument
for yaml_file in "$@"; do
    # Extract the chain name from the YAML file (remove the extension)
    chain_name=$(basename "$yaml_file" .yaml)

    # Add the chain-specific section to the TOML file
    echo "[contracts.code_ids.$chain_name]"

    # Parse the YAML file and add the contract names and code_ids to the TOML
    # Use yq to parse the YAML (ensure you have yq installed)
    # Loop through the contract names and extract the code_id
    for contract in $(yq -r 'keys[]' "$yaml_file"); do
        code_id=$(yq -r ".\"$contract\".code_id" "$yaml_file")
        echo "$contract = $code_id"
    done
done
