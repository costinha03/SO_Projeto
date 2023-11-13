#!/bin/bash


sorting_order="default"

# Parse command-line options
while getopts "ra" option; do # Obter as opções da linha de comando -r e -a
  case $option in
    r)
      sorting_order="reverse" # ordem inversa
      ;;
    a)
      sorting_order="alphabetical" # ordem alfabética
      ;;
    *)
      echo "Usage: $0 [-r] [-a] <file1> <file2>" # Se a opção for diferente de -r e -a, imprima a mensagem de erro
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))


if [ $# -ne 2 ]; then # Se o número de argumentos for diferente de 2, imprima a mensagem de erro (ne = not equal)
  echo "Usage: $0 [-r] [-a] <file1> <file2>" # Se a opção for diferente de -r e -a, imprima a mensagem de erro
  exit 1
fi

# Lê dois arquivos vindo dos argumentos da linha de comando
file1="$1"
file2="$2"

# Função para comparar os arquivos
compare_files() {

  declare -A dir_sizes1 
  declare -A dir_sizes2 


  while read -r size dir; do # Lê o primeiro arquivo e armazena os tamanhos dos diretórios
    dir_sizes1["$dir"]=$size # Armazena o tamanho do diretório no array associativo dir_sizes1
  done < "$file1"  

  while read -r size dir; do # Lê o segundo arquivo e armazena os tamanhos dos diretórios
    dir_sizes2["$dir"]=$size # Armazena o tamanho do diretório no array associativo dir_sizes2
  done < "$file2"

  echo "SIZE NAME" #imprime o cabeçalho
  
  for dir in "${!dir_sizes1[@]}"; do # Percorre o array associativo dir_sizes1
    size1="${dir_sizes1[$dir]}" # Armazena o tamanho do diretório no array associativo dir_sizes1
    size2="${dir_sizes2[$dir]}" # Armazena o tamanho do diretório no array associativo dir_sizes2

    if [ -z "$size2" ]; then
      # Diretorio presente apenas no primeiro arquivo
      echo "$size1 $dir REMOVED" # Imprime o tamanho do diretório e o nome do diretório com a mensagem REMOVED
    else
      # Diretorio presente em ambos os arquivos
      size_diff=$((size2 - size1)) # Calcula a diferença entre os tamanhos dos diretórios (size2 - size1)
      echo "$size_diff $dir" # Imprime a diferença entre os tamanhos dos diretórios e o nome do diretório
    fi
  done

  # Diretorios presentes apenas no segundo arquivo
  for dir in "${!dir_sizes2[@]}"; do # Percorre o array associativo dir_sizes2
    if [ -z "${dir_sizes1[$dir]}" ]; then # Se o tamanho do diretório for vazio (não presente no primeiro arquivo)
      echo "${dir_sizes2[$dir]} $dir NEW" # Imprime o tamanho do diretório e o nome do diretório com a mensagem NEW
    fi
  done
}

# Chama a função compare_files e ordena os diretórios de acordo com a opção escolhida (default, ordem inversa ou ordem alfabética)
if [ "$sorting_order" == "reverse" ]; then # Se a ordem for inversa
  compare_files "$file1" "$file2" | sort -rn # Ordena os diretórios em ordem inversa e imprime o tamanho e o nome do diretório
elif [ "$sorting_order" == "alphabetical" ]; then # Se a ordem for alfabética
  compare_files "$file1" "$file2" | sort -k2 # Ordena os diretórios em ordem alfabética e imprime o tamanho e o nome do diretório
else
# Se a ordem for padrão
  compare_files "$file1" "$file2" # Imprime o tamanho e o nome do diretório 
fi

