# Major-Project
# Summary


The sample ranges from date **2020-02-25** to **2022-8-20**.

|Member	| Size Downloaded | All Samples No | Exe Sample No.| Family Classified|
--------|------------------|---------------|----------------|------------------|
|sudarshan|21 GB|54963|29057|26081|
|daju|110 GB|314974|106931|94993|
|petu|160 GB|220346|122352|109941|

### Total Classified Malware Samples: 231015
---

## Families

### Unique families count: 870

- Out of which **33** has more than 1000 samples.


|No of Samples| Family|
----------|----------
|1652|Adware.Neoreklami|
|2705|Amadey|
|2783|ArkeiStealer|
|2672|AsyncRAT|
|4896|AveMariaRAT|
|1192|AZORult|
|1765|CobaltStrike|
|2380|CoinMiner|
|1764|DCRat|
|1667|FormBook|
|5441|GandCrab|
|5665|GCleaner|
|1720|Gozi|
|5027|GuLoader|
|1673|IcedID|
|8761|Loki|
|2114|MassLogger|
|4501|NanoCore|
|1167|NetWire|
|3934|njrat|
|2503|QuakBot|
|2386|RaccoonStealer|
|1213|RecordBreaker|
|4865|RemcosRAT|
|7591|Smoke| Loader
|7612|SnakeKeylogger|
|1396|Stop|
|1276|Tofsee|
|3858|TrickBot|
|36038| AgentTesla|
|14933| Formbook|
|43725| Heodo|
|16587| RedLineStealer|

# Data Collection

The data was collected from [Malware Bazaar](https://datalake.abuse.ch/malware-bazaar/daily/)

The script used for downloading the zip of raw malware samples.

```bash
# grabber.sh

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

```

The script for extracting the zip files and making a csv with the name and date.
```bash
# extract.sh

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
```

- The family of the malwares extracted was labelled by the following script.

```python
import requests
import os
import csv
import concurrent.futures

url = "https://mb-api.abuse.ch/api/v1/"
session = requests.Session()
def get_signature(hash_value):
    data = {'query': 'get_info', 'hash': hash_value}
    response = session.post(url, data=data)
    try:
        if response.json()['query_status'] == "ok":
            signature = response.json()['data'][0]['signature']
            return signature
        else:
            return None
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")
        return None
    except (KeyError, ValueError) as e:
        print(f"Error decoding JSON response: {e}")
        return None


def process_row(row):
    file_name, date = row
    hash_value = os.path.splitext(os.path.basename(file_name))[0]
    signature = get_signature(hash_value)
    if signature is not None:
        row.append(signature)
        return row
    else:
    	return ""

# Read the last processed file name from a resume file
resume_file = 'resume.txt'
last_processed_number = 1
if os.path.exists(resume_file):
    with open(resume_file, 'r') as resume:
        last_processed_number = int(resume.read().strip())

# Read the CSV file
with open('file_details.csv', 'r') as csv_file, open('final.csv', 'a', newline='') as output_file:
    csv_reader = csv.reader(csv_file)
    csv_writer = csv.writer(output_file)

    rows = list(csv_reader)
    total_rows = len(rows)
    rows_to_process = rows[last_processed_number:]

    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        results = executor.map(process_row, rows_to_process)

        for i, result in enumerate(results, last_processed_number + 1):
            csv_writer.writerow(result)

            # Write the processed row number to the resume file
            with open(resume_file, 'w') as resume:
                resume.write(str(i))
            print(f"Processed row {i}/{total_rows}")

print("Processing complete!")
```

We then decided to go with the following 5 families.
    - Amadey
    - Loki
    - SmokeLoader
    - SnakeKeylogger
    - njrat

We also added a 6th class as non-malicious whose sample was downloaded from [here](https://github.com/iosifache/DikeDataset/tree/main/files/benign)

```bash
svn checkout https://github.com/iosifache/DikeDataset/trunk/files/benign
```

We then rearranged all the malware samples into their respective family directory using the following script:

```bash
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
```

- We then deleted the malware family whose total sample 500 samples.

## Feature Extraction

- The main feature for our model is the assembly of the malware.

- Objdump was used to extract the assembly from the samples.
- The script used for mass disassembly is :

```bash

#disassemble.sh

#!/bin/bash

# Sections to disassemble
sections=".data .text .rsrc .rdata .bss .tls .idata .edata .reloc .BSS .CODE .Pav"

# Loop through all the .exe files in the current directory
for exe_file in *.exe; do
    # Create an assembly file for each .exe without the "_all_sections" portion
    assembly_file="${exe_file%.exe}_all_sections.asm"
    new_assembly_file="${exe_file%.exe}.asm"

    # Loop through all the specified sections and disassemble them
    for section in $sections; do
        text=$(objdump -j "$section" -D "${exe_file}" -M intel | awk '/Disassembly/ { found=1 } found' | tail -n +2);

        # Use sed to remove the colon and ellipsis
        text=$(echo "$text" | sed -e 's/://g' -e 's/\.\.\.//g')

        # Use awk to prefix each line with the current section name
        text=$(echo "$text" | awk -v section="$section" '{print section ":" $1, $2, $3, $4, $5, $6, $7, $8, $9}')

        echo "$text" | tail -n +3 >> ${new_assembly_file};

    done
        #Remove .exe file
    
        rm "$exe_file"
done
```
The features for the classification are the frequency count of various opcode, registers, section size and the file size.

- .text:
- .Pav:
- .idata:
- .data:
- .bss:
- .rdata:
- .edata:
- .rsrc:
- .tls:
- .reloc:
- .BSS:
- .CODE
- jmp
- mov
- retf
- push
- pop
- xor
- retn
- nop
- sub
- inc
- dec
- add
- imul
- xchg
- or
- shr
- cmp
- call
- shl
- ror
- rol
- jnb
- jz
- rtn
- lea
- movzx
- edx
- esi
- eax
- ebx
- ecx
- edi
- ebp
- esp
- eip
- size


For this we made a custom count vectorizer from bash as the default one was very slow and would not process large number of files.

```bash
#!/bin/bash

# Create a header for the CSV file if it doesn't exist
if [ ! -f result.csv ]; then
  echo "ID,.text:,.Pav:,.idata:,.data:,.bss:,.rdata:,.edata:,.rsrc:,.tls:,.reloc:,.BSS:,.CODE,jmp,mov,retf,push,pop,xor,retn,nop,sub,inc,dec,add,imul,xchg,or,shr,cmp,call,shl,ror,rol,jnb,jz,rtn,lea,movzx,edx,esi,eax,ebx,ecx,edi,ebp,esp,eip" > result.csv
fi

# Define an array of field names
fields=("ID" ".text:" ".Pav:" ".idata:" ".data:" ".bss:" ".rdata:" ".edata:" ".rsrc:" ".tls:" ".reloc:" ".BSS:" ".CODE" "jmp" "mov" "retf" "push" "pop" "xor" "retn" "nop" "sub" "inc" "dec" "add" "imul" "xchg" "or" "shr" "cmp" "call" "shl" "ror" "rol" "jnb" "jz" "rtn" "lea" "movzx" "edx" "esi" "eax" "ebx" "ecx" "edi" "ebp" "esp" "eip")

# Create or initialize the parsed files list
parsed_files_file="parsed_files.txt"
touch "$parsed_files_file"

# Iterate through all text files in the current directory
for file in *.asm; do
  # Check if the file has been parsed already
  if grep -Fxq "$file" "$parsed_files_file"; then
    echo "Skipping $file (already parsed)"
  else
    # Process the file
    echo -n "$file," >> result.csv
    for field in "${fields[@]}"; do
      echo -n "$(cat "$file" | grep "$field" | wc -l)," >> result.csv
    done
    echo "" >> result.csv

    # Add the filename to the list of parsed files
    echo "$file" >> "$parsed_files_file"
  fi
done
```

