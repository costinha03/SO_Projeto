#!/bin/bash

directory="."
regex=".*"
min_size=0
max_date=""
reverse_sort="false"
limit=99999
sort_by_name="false"
output_file="spacecheck_$(date +'%Y%m%d%H%M%S').txt" 

# Obter a data atual
build_date=$(date +'%Y%m%d')

# Função para calcular os tamanhos das pastas
calculate_folder_sizes() {
  local search_directory="$1"

  find "$search_directory" -type f | grep -E "$regex" | xargs -I {} dirname {} | sort -u | while read -r folder; do
    folder_size=$(du -s "$folder" 2>/dev/null | cut -f1)
    if [ -z "$folder_size" ]; then
      folder_size=0
    fi
    if [ "$folder_size" -ge "$min_size" ]; then
      echo "$folder_size $folder"
    fi
  done
}

# Função para exibir "NA" se o tamanho for indefinido (vazio)
print_size() {
  local size="$1"
  if [ -z "$size" ]; then
    echo "NA"
  else
    echo "$size"
  fi
}

while getopts "n:d:s:ral:" opt; do
  case $opt in
    n)
      regex="$OPTARG"
      ;;
    d)
      max_date="$OPTARG"
      ;;
    s)
      min_size="$OPTARG"
      ;;
    r)
      reverse_sort="true"
      ;;
    a)
      sort_by_name="true"
      ;;
    l)
      limit="$OPTARG"
      ;;
    \?)
      usage
      ;;
  esac
done
shift $((OPTIND-1))

# Verificar o diretório
if [ "$1" ]; then
  directory="$1"
fi


# Cabeçalho
header="SIZE NAME $build_date"
if [ "$reverse_sort" == "true" ]; then
  header="$header -r"
fi
if [ "$sort_by_name" == "true" ]; then
  header="$header -a"
fi
if [ "$regex" != ".*" ]; then
  header="$header -n $regex"
fi
if [ -n "$max_date" ]; then
  header="$header -d $max_date"
fi
if [ "$min_size" -ne 0 ]; then
  header="$header -s $min_size"
fi
if [ "$limit" -ne 99999 ]; then
  header="$header -l $limit"
fi

printf "%s %s\n" "$header" "$directory"




# Tamanhos das pastas
if [ "$sort_by_name" == "true" ]; then
  calculate_folder_sizes "$directory" | sort -k2 | head -n "$limit" | tee "$output_file"
else
  if [ "$reverse_sort" == "true" ]; then
    calculate_folder_sizes "$directory" | sort -n | head -n "$limit"  | tee "$output_file"

  else
    calculate_folder_sizes "$directory" | sort -n -r | head -n "$limit" | tee "$output_file"

  fi
fi

