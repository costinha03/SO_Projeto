#!/bin/bash

sorting_order="default"
header_printed=false

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

shift $((OPTIND - 1))

if [ $# -ne 2 ]; then
  echo "Usage: $0 [-r] [-a] <file1> <file2>"
  exit 1
fi

file1="$1"
file2="$2"

# Ensure header is always printed first
echo "SIZE NAME"

compare_files() {
  declare -A dir_sizes1 
  declare -A dir_sizes2 

  while read -r size dir; do
    dir_sizes1["$dir"]=$size
  done < "$file1"  

  while read -r size dir; do
    # Check if the line contains two fields before assigning values
    if [ -n "$size" ] && [ -n "$dir" ]; then
      dir_sizes2["$dir"]=$size
    fi
  done < "$file2"

  for dir in "${!dir_sizes1[@]}"; do
    size1="${dir_sizes1[$dir]}"
    size2="${dir_sizes2[$dir]}"

    if [ -z "$size2" ]; then
      echo "-$size1 $dir REMOVED"
    else
      size_diff=$((size2 - size1))
      echo "$size_diff $dir"
    fi
  done

  for dir in "${!dir_sizes2[@]}"; do
    size1="${dir_sizes1[$dir]}"
    size2="${dir_sizes2[$dir]}"

    if [ -z "${dir_sizes1[$dir]}" ]; then
      echo "${dir_sizes2[$dir]} $dir NEW"
    fi
  done
}

if [ "$sorting_order" == "reverse" ]; then
  compare_files "$file1" "$file2" | tac
elif [ "$sorting_order" == "alphabetical" ]; then
  compare_files "$file1" "$file2" | sort -k2
else
  compare_files "$file1" "$file2"
fi
