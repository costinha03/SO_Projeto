#!/bin/bash

input="$@"
directory="." 
regex=".*" 
min_size=0
max_date=""
reverse_sort="false"
limit=99999
sort_by_name="false"
output_file="spacecheck_$(date +'%Y%m%d%H%M%S')" # Nome do arquivo de saída

# Obter a data atual
build_date=$(date +'%Y%m%d')

calculate_folder_sizes() {
  local search_directory="$1" # Diretório para pesquisar

  # Encontre todas as pastas no diretório
  find "$search_directory" -type d 2>/dev/null |
  while read -r folder; # Para cada pasta
  do
    # Verifica a permissão de leitura na pasta
    if [ -r "$folder" ]; then
      # Filtrar os arquivos que correspondem ao regex e foram modificados antes da data máxima
      local matching_files=$(find "$folder" -type f -mtime +$(( ( $(date +%s) - $(date -d "$max_date" +%s) ) / 86400 )) 2>/dev/null | grep -E "$regex")

      if [ -n "$matching_files" ]; then
        folder_size=0

        # Calcular o tamanho da pasta considerando a expressão regular
        while IFS= read -r file; do 
          size=$(du -b "$file" 2>/dev/null | awk '{print $1}') # Obter o tamanho do arquivo
          folder_size=$((folder_size + size)) # Somar o tamanho do arquivo ao tamanho da pasta
        done <<< "$matching_files" # Passar os arquivos correspondentes para o loop

        if [ "$folder_size" -ge "$min_size" ]; then
          echo "$folder_size $folder" # Imprimir o tamanho e o nome da pasta
        fi
      else
        # Se não houver arquivos que atendam aos critérios, defina o tamanho da pasta como 0
        if [ "$min_size" -eq 0 ]; then
          echo "0 $folder"
        fi
      fi
    else
      echo "NA $folder" # Permissão recusada
    fi
  done
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
      usage # Remove $opt from usage
      ;;
  esac
done
shift $((OPTIND-1))

# Verificar o diretório
if [ "$1" ]; then 
  directory="$1" 
fi

printf "SIZE NAME %s %s\n" "$build_date" "$input" # Imprimir o cabeçalho

# Tamanhos das pastas
if [ "$sort_by_name" == "true" ]; then # Se a ordem for alfabética
  calculate_folder_sizes "$directory" |  # Calcular os tamanhos das pastas
  sort -k2 | # Ordenar por nome
  head -n "$limit" |  # Obter as primeiras linhas
  tee "$output_file"  # Salvar a saída em um arquivo
else
  if [ "$reverse_sort" == "true" ]; then # Se a ordem for inversa
    calculate_folder_sizes "$directory" | # Calcular os tamanhos das pastas
    sort -n | # Ordenar por tamanho
    head -n "$limit"  |  # Obter as primeiras linhas
    tee "$output_file" # Salvar a saída em um arquivo
  else
    calculate_folder_sizes "$directory" | # Calcular os tamanhos das pastas
    sort -n -r | # Ordenar por tamanho em ordem inversa
    head -n "$limit" | # Obter as primeiras linhas
    tee "$output_file" # Salvar a saída em um arquivo
  fi
fi