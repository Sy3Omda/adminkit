#!/bin/bash

# Check if a file was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_zsh_history_file>"
  exit 1
fi

# Create an output file
output_file="converted_$(basename "$1")"
> "$output_file"

# Process each line
while IFS= read -r line; do
  if [[ "$line" =~ ^: ]]; then
    # Extract the timestamp and command
    timestamp=$(echo "$line" | cut -d: -f2)
    command=$(echo "$line" | cut -d';' -f2-)
    # Convert timestamp to human-readable format
    readable_date=$(date -d @"$timestamp" +"%Y-%m-%d %H:%M:%S")
    # Write to output file
    echo "$readable_date; $command" >> "$output_file"
  else
    echo "$line" >> "$output_file"
  fi
done < "$1"

echo "Converted history saved to $output_file"
