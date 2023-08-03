#!/bin/bash

# Define the source folder containing the zip files
source_folder="zips"

# Create a directory to store extracted files
extracted_dir="extracted_files"
mkdir -p "$extracted_dir"

# Initialize CSV file
csv_file="file_info.csv"

csv_file="file_info.csv"

# Check if the CSV file already exists
if [ -f "$csv_file" ]; then
    echo "CSV file already exists."
else
    echo "File,Date" > "$csv_file"
fi
# Extract zip files
for file in "$source_folder"/*.zip; do
    echo "hello"
    
    folder_name=$(basename "${file%.*}")
    unzip -q -P infected "$file" -d "$extracted_dir/$folder_name"
    
    # Add file names and dates to the CSV file
    find "$extracted_dir/$folder_name" -type f -printf "%P,%TY-%Tm-%Td\n" >> "$csv_file"
    
    # Delete non-.exe files in the extracted folder
    find "$extracted_dir/$folder_name" -type f ! -name "*.exe" -delete
    
    # Delete the extracted zip file
    rm "$file"
  
done