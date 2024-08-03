#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 [-l] [-t timestamp]"
    exit 1
}

# Function to find the latest file in S3 bucket
find_latest_file() {
    aws --profile vukw-s3 s3 ls s3://vukw-1e2df75b/gandlf_dp/ | sort | awk '{print $4}'
}

# Function to download and unpack a file from S3
download_and_unpack() {
    local s3_path=$1
    local filename=$(basename "$s3_path")

    # Download the file
    echo "Downloading $s3_path..."
    aws --profile vukw-s3 s3 cp "$s3_path" .

    # Unpack the file
    echo "Unpacking $filename..."
    tar -xzvf "$filename"

    # Clean up the tar file
    rm "$filename"
}

# Check if the -l or -t flag is provided
download_logs_only=false
specified_timestamp=""
while getopts "lt:" opt; do
    case $opt in
        l)
            download_logs_only=true
            ;;
        t)
            specified_timestamp=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

# Build the grep template
template_prefix=".*"
if [ -n "$specified_timestamp" ]; then
    template_prefix=".*_${specified_timestamp}"
fi

# Determine the full template
if $download_logs_only; then
    file_template="${template_prefix}_logs\.tar\.gz$"
else
    file_template="${template_prefix}_full\.tar\.gz$"
fi

# Find the latest file
latest_files=$(find_latest_file)
latest_file=$(echo "$latest_files" | grep ${file_template} | tail -1)

# Check if a file was found
if [ -z "$latest_file" ]; then
    echo "No files matching the template found in S3."
    exit 1
fi

echo "Latest file found: $latest_file"
# Construct the S3 path
s3_path="s3://vukw-1e2df75b/gandlf_dp/$latest_file"

# Print the timestamp of the latest result found
timestamp=$(echo "$s3_path" | grep -oP '\d{10}')
echo "Latest result timestamp: $timestamp"

# Download and unpack the latest file
download_and_unpack "$s3_path"

echo "Done."
