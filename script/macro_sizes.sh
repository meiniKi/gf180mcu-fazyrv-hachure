#!/bin/bash

export BASE_PATH=".."

macronames=(
    "frv_1"
    "frv_2"
    "frv_4"
    "frv_8"
    "frv_4ccx"
    "frv_1bram"
    "frv_8bram"
)

if [ -z "$BASE_PATH" ] || [ ! -d "$BASE_PATH/macros" ]; then
    echo "Error: BASE_PATH is not set correctly or the directory '$BASE_PATH/macros' does not exist."
    echo "Please update the BASE_PATH variable in this script."
    exit 1
fi

for macroname in "${macronames[@]}"; do
    metrics_file="$BASE_PATH/macros/$macroname/final/metrics.csv"

    echo "Processing: $macroname"
    
    if [ -f "$metrics_file" ]; then
        grep "design__die__bbox" "$metrics_file"
    else
        echo "Warning: Metrics file not found at '$metrics_file'"
    fi
    echo ""
done