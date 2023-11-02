#!/bin/bash

directory="."
regex=".*"
min_size=0
max_date=""
sort_flag=""
limit=99999

# obter a data atual
build_date=$(date +'%Y%m%d')

# calcular o tamanho de pastas
calculate_folder_sizes() {
  local search_directory="$1"


  find "$search_directory" -type f | grep -E "$regex" | xargs -I {} dirname {} | sort -u | while read -r folder; do
    folder_size=$(du -s "$folder" 2>/dev/null | cut -f1)
    echo "$folder_size $folder"
  done
}

# Função para exibir "NA" 
print_size() {
  local size="$1"
  if [ -z "$size" ]; then 
    echo "NA"
  else
    echo "$size"
  fi
}

while getopts "n:d:s:ra:l:" opt; do # opções
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
      sort_flag="-r"
      ;;
    a)
      sort_flag="-a"
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

# verificar o diretório 
if [ "$1" ]; then
  directory="$1"
fi


# Cabeçalho
# Cabeçalho
printf "SIZE NAME $build_date"
if [ "$sort_flag" == "-r" ]; then
  printf " -r"
elif [ "$sort_flag" == "-a" ]; then
  printf " -a"
fi
if [ "$regex" != ".*" ]; then
  printf " -n %s" "$regex"
fi
if [ "$max_date" != "" ]; then
  printf " -d %s" "$max_date"
fi
if [ "$min_size" != "0" ]; then
  printf " -s %s" "$min_size"
fi
if [ "$limit" -ne 99999 ]; then
  printf " -l %s" "$limit"
fi

printf " %s\n" "$directory"



# tamanhos das pastas
calculate_folder_sizes "$directory" | sort -n $sort_flag | head -n $limit
