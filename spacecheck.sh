#!/bin/bash

while true; do
    clear
    echo "Spacecheck Menu"
    echo "1. Visualizar espaço ocupado por todos os arquivos"
    echo "2. Visualizar espaço ocupado por arquivos com base na expressão regular"
    echo "3. Visualizar espaço ocupado por arquivos com base na data de modificação"
    echo "4. Visualizar espaço ocupado por arquivos com base no tamanho mínimo"
    echo "5. Sair"

    read -p "Escolha uma opção: " option

    case $option in
        1)
            # Opção para visualizar espaço ocupado por todos os arquivos
            ./spacecheck.sh
            ;;
        2)
            # Opção para visualizar espaço ocupado com base na expressão regular
            read -p "Digite a expressão regular: " regex
            ./spacecheck.sh -n "$regex"
            ;;
        3)
            # Opção para visualizar espaço ocupado com base na data de modificação
            read -p "Digite a data máxima de modificação (YYYY-MM-DD): " date
            ./spacecheck.sh -d "$date"
            ;;
        4)
            # Opção para visualizar espaço ocupado com base no tamanho mínimo
            read -p "Digite o tamanho mínimo (em bytes): " size
            ./spacecheck.sh -s "$size"
            ;;
        5)
            # Opção para sair do menu
            echo "Saindo do programa."
            exit
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            ;;
    esac

    read -p "Pressione Enter para continuar..."
done
