#!/bin/bash


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

# Função para calcular os tamanhos das pastas
calculate_folder_sizes() {
  local search_directory="$1" # Diretório para pesquisar

  # Encontre os arquivos que correspondem ao regex e foram modificados antes da data máxima
  find "$search_directory" -type f -mtime +$(( ( $(date +%s) - $(date -d "$max_date" +%s) ) / 86400 )) | # 86400 = 60*60*24 = número de segundos em um dia
  grep -E "$regex" | # Filtrar os arquivos que correspondem à expressão regular
  xargs -I {} dirname {} | # Obter o nome da pasta 
  sort -u |  # Remover os duplicados
  while read -r folder; # Para cada pasta
  do
    folder_size=$(du -s "$folder" 2>/dev/null | cut -f1) # Obter o tamanho da pasta 
    if [ -z "$folder_size" ]; then # Se o tamanho da pasta for indefinido (vazio), defina-o como 0
      folder_size=0
    fi
    if [ "$folder_size" -ge "$min_size" ]; then # Se o tamanho da pasta for maior ou igual ao tamanho mínimo (ge = greater or equal)
      echo "$folder_size $folder" # Imprimir o tamanho e o nome da pasta
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

while getopts "n:d:s:ral:" opt; do # Obter as opções da linha de comando
  case $opt in
    n)
      regex="$OPTARG" # expressão regular
      ;;
    d)
      max_date="$OPTARG" # data máxima
      ;;
    s)
      min_size="$OPTARG" # size minimo da pasta
      ;;
    r)
      reverse_sort="true" # ordem inversa
      ;;
    a)
      sort_by_name="true" # ordem alfabetica
      ;;
    l)
      limit="$OPTARG" # limite de linhas
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
header="SIZE NAME $build_date" # Cabeçalho padrão
if [ "$reverse_sort" == "true" ]; then # Se a ordem for inversa, adicione "-r" ao cabeçalho
  header="$header -r"
fi
if [ "$sort_by_name" == "true" ]; then # Se a ordem for alfabética, adicione "-a" ao cabeçalho
  header="$header -a"
fi
if [ "$regex" != ".*" ]; then # Se a expressão regular for diferente de ".*", adicione "-n" ao cabeçalho
  header="$header -n $regex"
fi
if [ -n "$max_date" ]; then # Se a data máxima não for vazia, adicione "-d" ao cabeçalho
  header="$header -d $max_date"
fi
if [ "$min_size" -ne 0 ]; then # Se o tamanho mínimo for diferente de 0, adicione "-s" ao cabeçalho
  header="$header -s $min_size"
fi
if [ "$limit" -ne 99999 ]; then # Se o limite for diferente de 99999, adicione "-l" ao cabeçalho
  header="$header -l $limit"
fi

printf "%s %s\n" "$header" "$directory" # Imprimir o cabeçalho

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
