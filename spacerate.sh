#!/bin/bash

# Check if two filenames are provided as arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 <file1> <file2>"
  exit 1
fi

# Read the two file names from command-line arguments
file1="$1"
file2="$2"



# Function to compare two files and display the differences
compare_files() {
  local file1="$1"
  local file2="$2"

  echo "SIZE NAME"

  # Create associative arrays to store directory sizes from both files
  declare -A dir_sizes1
  declare -A dir_sizes2

  # Read the first file and store directory sizes
  while read -r size dir; do
    dir_sizes1["$dir"]=$size
  done < "$file1"

  # Read the second file and store directory sizes
  while read -r size dir; do
    dir_sizes2["$dir"]=$size
  done < "$file2"

  # Compare directory sizes and display the differences
  for dir in "${!dir_sizes1[@]}"; do
    size1="${dir_sizes1[$dir]}"
    size2="${dir_sizes2[$dir]}"

    if [ -z "$size2" ]; then
      # Directory is present in file1 but not in file2
      echo "$size1 $dir REMOVED"
    else
      # Directory is present in both files
      size_diff=$((size2 - size1))
      echo "$size_diff $dir"
    fi
  done

  # Check for directories present in file2 but not in file1
  for dir in "${!dir_sizes2[@]}"; do
    if [ -z "${dir_sizes1[$dir]}" ]; then
      echo "${dir_sizes2[$dir]} $dir NEW"
    fi
  done
}

# Call the compare_files function with the two input files
compare_files "$file1" "$file2"
