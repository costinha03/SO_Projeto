#!/bin/bash

# Função que calcula o tamanho dos arquivos que correspondem à expressão regular
calculate_size() {
  local dir="$1"
  local regex="$2"

  find "$dir" -type f -name "$regex" -exec du -b {} + | awk '{s+=$1} END {print s}'
}

# Verificar se o número de argumentos é válido
if [ "$#" -ne 3 ]; then
  echo "Uso: $0 -n <expressão-regular> <diretório>"
  exit 1
fi

# Verificar se a opção é -n
if [ "$1" != "-n" ]; then
  echo "Opção inválida. Use -n para especificar a expressão regular."
  exit 1
fi

# Atribuir a expressão regular e o diretório a variáveis
regex="$2"
dir="$3"

# Verificar se o diretório existe
if [ ! -d "$dir" ]; then
  echo "O diretório especificado não existe."
  exit 1
fi

# Chamar a função para calcular o tamanho dos arquivos
size=$(calculate_size "$dir" "$regex")

# Exibir os resultados
echo "SIZE NAME $(date +"%Y%m%d") -n $regex $dir"
echo "$size $dir"
