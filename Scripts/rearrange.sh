#!/bin/bash

# Replace 'input.csv' with the path to your CSV file
csv_file="final_labelled.csv"
# Replace 'Families' with the desired name for the parent directory
parent_directory="Families"

# Check if the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo "CSV file not found: $csv_file"
    exit 1
fi

# Read the CSV file line by line and process each row
while IFS=, read -r filename date family_name; do
    # Skip header row (if it exists)
    if [ "$filename" == "Filename_Header" ]; then
        continue
    fi

    # Check if any of the columns is empty or contains spaces
    # if [ -z "$filename" ] || [ -z "$date" ] || [ -z "$family_name" ] || \
    #    [[ "$filename" != "${filename%[[:space:]]*}" ]] || \
    #    [[ "$date" != "${date%[[:space:]]*}" ]] || \
    #    [[ "$family_name" != "${family_name%[[:space:]]*}" ]]; then
    #     echo "Invalid row: '$filename', '$date', '$family_name'"
    #     continue
    # fi

    # Check if the file exists in the date folder before moving it
    if [ -f "$date/$filename" ]; then
        # Create a directory for the family if it doesn't exist
        if [ ! -d "$parent_directory/$family_name" ]; then
            mkdir -p "$parent_directory/$family_name"
        fi

        # Move the file from the date format folder to the family folder
        mv "$date/$filename" "$parent_directory/$family_name/"
    else
        echo "File not found: '$date/$filename'"
    fi
done < "$csv_file"

echo "File organization completed!"
