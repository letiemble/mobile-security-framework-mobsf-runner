#!/usr/bin/env bash

# Get the parameters from the environment variables
input_file=$INPUT_FILE
mobsf_url=$MOBSF_URL
mobsf_apikey=$MOBSF_API_KEY

# Compute the paths
input_folder="$ROOT_FOLDER/input"
output_folder="$ROOT_FOLDER/output"
application_package="$input_folder/$input_file"

echo
echo "Input file    : $application_package"
echo "Output folder : $output_folder"
echo "MobSF URL     : $mobsf_url"
echo

echo "Waiting for MobSF to be ready..."
max_retries=10
retry_count=0
while [ $retry_count -lt $max_retries ]; do
    sleep 5 # Wait for 5 seconds before trying
    curl -m 10 "$mobsf_url" --silent --head --fail --output /dev/null

    if [ $? -eq 0 ]; then
        echo "MobSF is ready"
        break
    else
        echo "Request failed with exit code $?. Retrying..."
        retry_count=$((retry_count + 1))
    fi
done
if [ $retry_count -eq $max_retries ]; then
    echo "MobSF is not ready. Exiting..."
    exit 1
fi

echo
echo "> Uploading target file to MobSF..."
output_file="$output_folder/upload.json"
curl "$mobsf_url/api/v1/upload" --silent -H "X-Mobsf-Api-Key: $mobsf_apikey" -F "file=@$application_package" -o "$output_file"
echo "Parsing JSON response..."
scan_type=$(jq -r ".scan_type" "$output_file")
file_name=$(jq -r ".file_name" "$output_file")
hash=$(jq -r ".hash" "$output_file")
echo "Scan type: $scan_type"
echo "File name: $file_name"
echo "Hash: $hash"

echo
echo "> Performing the scan..."
output_file="$output_folder/scan.json"
curl "$mobsf_url/api/v1/scan" --silent -H "X-Mobsf-Api-Key: $mobsf_apikey" -F "scan_type=$scan_type" -F "file_name=$file_name" -F "hash=$hash" -o "$output_file"
echo "Scan saved to $output_file"

echo
echo "> Retrieving the scoreboard..."
output_file="$output_folder/scoreboard.json"
curl "$mobsf_url/api/v1/scorecard" --silent -H "X-Mobsf-Api-Key: $mobsf_apikey" -F "hash=$hash" -o "$output_file"
echo "Scoreboard saved to $output_file"

echo
echo "> Retrieving the report..."
output_file="$output_folder/report.pdf"
curl "$mobsf_url/api/v1/download_pdf" --silent -H "X-Mobsf-Api-Key: $mobsf_apikey" -F "hash=$hash" -o "$output_file"
echo "Report saved to $output_file"

echo
echo "> Done"
