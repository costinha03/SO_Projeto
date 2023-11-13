#!/bin/bash

sorting_order="default" 
header_printed=false

# opções da linha de comando
while getopts "ra" option; do
  case $option in
    r)
      # Se a opção -r foi fornecida, a ordem de classificação será inversa
      sorting_order="reverse"
      ;;
    a)
      # Se a opção -a foi fornecida, a ordem de classificação será alfabética
      sorting_order="alphabetical"
      ;;
    *)
      # Se uma opção inválida foi fornecida, mensagem de erro
      echo "Uso: $0 [-r] [-a] <file1> <file2>"
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

# Verifica o número de argumentos
if [ $# -ne 2 ]; then
  echo "Uso: $0 [-r] [-a] <file1> <file2>"
  exit 1
fi

# Atribui argumentos a variaveis 
file1="$1"
file2="$2"

# Cabeçalho
echo "SIZE NAME"

# Função para comparar os tamanhos de diretórios em dois ficheiros
compare_files() {
  # Declara arrays para armazenar os tamanhos de diretórios
  declare -A dir_sizes1 
  declare -A dir_sizes2 

  # tamanhos do primeiro ficheiro
  while read -r size dir; do
    dir_sizes1["$dir"]=$size
  done < "$file1"  

  # tamanhos do segundo ficheiro
  while read -r size dir; do
    if [ -n "$size" ] && [ -n "$dir" ]; then # Verifica se a linha não está vazia
      dir_sizes2["$dir"]=$size # Adiciona o tamanho do diretório ao array
    fi
  done < "$file2" 

  # Compara e imprime as diferenças nos tamanhos dos diretórios
  for dir in "${!dir_sizes1[@]}"; do
    size1="${dir_sizes1[$dir]}"
    size2="${dir_sizes2[$dir]}"

    if [ -z "$size2" ]; then # Se o diretório não existe no segundo ficheiro
      echo "-$size1 $dir REMOVED" # Se o diretório foi removido
    else
      size_diff=$((size2 - size1))
      echo "$size_diff $dir"
    fi
  done

  # Verifica diretórios adicionados no segundo ficheiro
  for dir in "${!dir_sizes2[@]}"; do
    size1="${dir_sizes1[$dir]}"
    size2="${dir_sizes2[$dir]}" 

    if [ -z "${dir_sizes1[$dir]}" ]; then # Se o diretório não existe no primeiro ficheiro
      echo "${dir_sizes2[$dir]} $dir NEW" # Se o diretório foi adicionado
    fi
  done
}

# Verifica a ordem de classificação e chama a função compare_files
if [ "$sorting_order" == "reverse" ]; then
  compare_files "$file1" "$file2" | tac
elif [ "$sorting_order" == "alphabetical" ]; then
  compare_files "$file1" "$file2" | sort -k2
else
  compare_files "$file1" "$file2"
fi
