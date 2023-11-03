#!/bin/bash

directory="."
regex=".*"
min_size=0
max_date=""
sort_flag=""
limit=99999

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

while getopts "n:d:s:ra:l:" opt; do
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

# Verificar o diretório
if [ "$1" ]; then
  directory="$1"
fi

# Cabeçalho
printf "SIZE NAME %s" "$build_date"
if [ "$sort_flag" == "-r" ]; then
  printf " -r"
elif [ "$sort_flag" == "-a" ]; then
  printf " -a"
fi
if [ "$regex" != ".*" ]; then
  printf " -n %s" "$regex"
fi
if [ -n "$max_date" ]; then
  printf " -d %s" "$max_date"
fi
if [ "$min_size" -ne 0 ]; then
  printf " -s %s" "$min_size"
fi
if [ "$limit" -ne 99999 ]; then
  printf " -l %s" "$limit"
fi

printf " %s\n" "$directory"

# Tamanhos das pastas
# Modifique a chamada da função calculate_folder_sizes para usar a ordenação padrão (decrescente)
if [ "$sort_flag" == "-r" ]; then
  calculate_folder_sizes "$directory" | sort -n | head -n "$limit"
else
  calculate_folder_sizes "$directory" | sort -n -r | head -n "$limit"
fi
