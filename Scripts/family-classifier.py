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