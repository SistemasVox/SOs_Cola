#!/bin/bash
# <tr><td valign="top"><img src="/icons/compressed.gif" alt="[   ]"></td><td><a href="Estabelecimentos0.zip">Estabelecimentos0.zip</a>  </td><td align="right">2023-02-14 09:54  </td><td align="right">902M</td><td>&nbsp;</td></tr>
# Verifica se há pelo menos 20 GB de espaço livre
SPACE_AVAILABLE=$(df -h | awk '$NF=="/"{printf "%d", $4}')
if [ "$SPACE_AVAILABLE" -lt 20 ]; then
  echo -e "\nNão há espaço suficiente para executar o script att.sh"
  echo -e "\nEspaço livre indisponível: $SPACE_AVAILABLE GB."
  exit 1
fi

# Executa o script att.sh
echo -e "\nTudo certo espaço livre disponível: $SPACE_AVAILABLE GB.\n"
./att.sh

# Cria o arquivo datas.txt caso ele não exista
if [ ! -e datas.txt ]; then
    echo "O arquivo datas.txt não existe. Criando novo arquivo vazio."
    touch datas.txt
fi

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
    echo -e "\nNão foi necessário atualizar pois as datas são as mesma."
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
    echo -e "\nNão foi necessário atualizar pois as datas são as mesma."
fi

rm "$temp_file" # remove o arquivo temporário

