#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -m <model_path>"
    exit 1
}

# Parse command-line arguments
while getopts "f:m:" opt; do
    case $opt in
        f)
            model_yaml_file=$OPTARG
            ;;
        m)
            model_path=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the model_path is provided
if [ -z "$model_path" ]; then
    usage
fi
if [ -z "$model_yaml_file" ]; then
    usage
fi

# Generate timestamp and define S3 paths
timestamp=$(date +%m%d%H%M%S)
light_s3_path="s3://vukw-1e2df75b/gandlf_dp/${model_path}_${timestamp}_light.tar.gz"
full_s3_path="s3://vukw-1e2df75b/gandlf_dp/${model_path}_${timestamp}_full.tar.gz"
logs_s3_path="s3://vukw-1e2df75b/gandlf_dp/${model_path}_${timestamp}_logs.tar.gz"

# Run the GaNDLF command
gandlf run -c $model_yaml_file -i labels_imagenette_3_train.csv -m "$model_path" -t -d cuda -rt |& tee -a log.txt

# Create tar.gz of the model and logs
tar -czf ${model_path}_full.tar.gz "$model_path"
tar --exclude="${model_path}/0/*_initial.pth.tar" \
    --exclude="${model_path}/0/*_latest.pth.tar" \
    --exclude="${model_path}/1/*_initial.pth.tar" \
    --exclude="${model_path}/1/*_latest.pth.tar" \
    -czf ${model_path}_light.tar.gz "$model_path"
eval "shopt -s globstar; tar -czvf ${model_path}_logs.tar.gz ${model_path}/**/*.csv log.txt"

# Print and upload the output and logs to S3
echo "Output S3 path: $full_s3_path"
aws s3 cp "${model_path}_full.tar.gz" "$full_s3_path"
echo "Light S3 path: $light_s3_path"
aws s3 cp "${model_path}_light.tar.gz" "$light_s3_path"
echo "Logs S3 path: $logs_s3_path"
aws s3 cp "${model_path}_logs.tar.gz" "$logs_s3_path"

echo "Done."
