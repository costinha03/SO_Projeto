#!/bin/bash

# Default sorting order
sorting_order="default"
header_printed_default=false
header_printed_reverse=false
header_printed_alphabetical=false

# Function to print the header if it hasn't been printed for a specific sorting order
print_header() {
  local order="$1"
  if [ "$order" == "default" ] && [ "$header_printed_default" == false ]; then
    echo "SIZE NAME"
    header_printed_default=true
  elif [ "$order" == "reverse" ] && [ "$header_printed_reverse" == false ]; then
    echo "SIZE NAME"
    header_printed_reverse=true
  elif [ "$order" == "alphabetical" ] && [ "$header_printed_alphabetical" == false ]; then
    echo "SIZE NAME"
    header_printed_alphabetical=true
  fi
}

# Parse command-line options
while getopts "ra" option; do
  case $option in
    r)
      sorting_order="reverse"
      ;;
    a)
      sorting_order="alphabetical"
      ;;
    *)
      echo "Usage: $0 [-r] [-a] <file1> <file2>"
      exit 1
      ;;
  esac
done

# Remove the processed options from the argument list
shift $((OPTIND - 1))

# Check if two filenames are provided as arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 [-r] [-a] <file1> <file2>"
  exit 1
fi

# Read the two file names from command-line arguments
file1="$1"
file2="$2"

# Function to compare two files and display the differences
compare_files() {
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

# Call the compare_files function with the two input files and sorting options
if [ "$sorting_order" == "reverse" ]; then
  # Sort directories in reverse order, including the header as the first line if not already printed
  print_header "reverse"
  compare_files "$file1" "$file2" | sort -rn
elif [ "$sorting_order" == "alphabetical" ]; then
  # Sort directories in alphabetical order, including the header as the first line if not already printed
  print_header "alphabetical"
  compare_files "$file1" "$file2" | sort -k2
else
  # Default order (as in the original script), including the header as the first line if not already printed
  print_header "default"
  compare_files "$file1" "$file2"
fi

