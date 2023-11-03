#!/bin/bash

csv_file="../Label/all_exe_labelled.csv"  # Replace with the path to your CSV file
output_file="families_with_less_than_500_entries.txt"

# Use awk to extract the 'family' column and sort it
awk -F ',' '{print $3}' "$csv_file" | sort > sorted_families.txt

# Use uniq to count the occurrences of each family
uniq -c sorted_families.txt > family_counts.txt

# Filter families with less than 500 entries and save them to the output file
awk '$1 < 500 {print $2}' family_counts.txt > "$output_file"

# Clean up temporary files
rm sorted_families.txt family_counts.txt

echo "Family names with less than 500 entries saved to '$output_file'."
