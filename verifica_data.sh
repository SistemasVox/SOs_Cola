#!/bin/bash

# Cria o arquivo datas.txt caso ele não exista
touch datas.txt

# Obtém as datas dos estabelecimentos
curl -s https://dadosabertos.rfb.gov.br/CNPJ/ | grep -Po 'Estabelecimentos.*?\K\d{4}-\d{2}-\d{2}' | sort | uniq > novas_datas.txt

# Compara as novas datas com as armazenadas no arquivo datas.txt
if ! cmp -s novas_datas.txt datas.txt; then
    # As datas são diferentes, executa o script att.sh
    echo -e "\nAs datas dos estabelecimentos foram atualizadas. Executando o script att.sh..."
    ./att.sh
    # Substitui o arquivo datas.txt pelas novas datas
    mv novas_datas.txt datas.txt
    echo -e "\nArquivo datas.txt atualizado."
else
    echo -e "\nAs datas dos estabelecimentos não foram atualizadas."
fi

# Obtém as datas dos estabelecimentos e as compara com as do arquivo datas.txt
temp_file=$(mktemp) # cria um arquivo temporário
curl -s https://dadosabertos.rfb.gov.br/CNPJ/ | grep -Po 'Estabelecimentos.*?\K\d{4}-\d{2}-\d{2}' > "$temp_file" # salva as datas em um arquivo temporário
if ! cmp -s "$temp_file" datas.txt; then
    # As datas são diferentes, executa o script att.sh
    echo -e "\nAs datas dos estabelecimentos foram atualizadas. Executando o script att.sh..."
    ./att.sh
    # Substitui o arquivo datas.txt pelas novas datas
    mv "$temp_file" datas.txt
    echo -e "\nArquivo datas.txt atualizado."
else
    echo -e "\nAs datas dos estabelecimentos não foram atualizadas."
fi

rm "$temp_file" # remove o arquivo temporário
