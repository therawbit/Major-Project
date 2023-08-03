#!/bin/bash

start_date="2021-07-25"
end_date="2020-12-23"
save_location="./downloads/"

current_date=$start_date

while [[ $current_date != $end_date ]]; do
    echo 

    # Construct the file name and save path
    file_name="$current_date.zip"
    save_path="$save_location$file_name"
    temp_save_path="$save_path.partial"

    # Check if the file already exists
    if [[ -f $save_path ]]; then
        echo " $current_date File already exists. Skipping download."
    elif [[ -f $temp_save_path ]]; then
        echo " $current_date Partial download detected. Resuming download. "
        wget -c -U "Mozilla/5.0" -O "$temp_save_path" "https://datalake.abuse.ch/malware-bazaar/daily/$file_name"
        mv "$temp_save_path" "$save_path"
    else
        # Download the .zip file with the date as the file name
        wget -U "Mozilla/5.0" -O "$temp_save_path" "https://datalake.abuse.ch/malware-bazaar/daily/$file_name"
        mv "$temp_save_path" "$save_path"

    fi

    current_date=$(date -I -d "$current_date + 1 day")
done

