#!/bin/bash

# Definir o tempo limite para a execução
max_execution_time=0

url="https://dadosabertos.rfb.gov.br/CNPJ/"
echo "URL: $url"

# Criar um diretório para armazenar os arquivos zip
dir="zip"
if [ ! -d "$dir" ]
then
    mkdir "$dir"
fi

# Verificar se a URL está corretamente formatada
if ! curl -s --head "$url" | grep -q "200 OK"; then
    echo -e "\nErro: URL mal formatada"
    exit 1
fi

# Exibir todos os links dos arquivos zip relacionados aos estabelecimentos
echo -e "\nLinks dos arquivos zip relacionados aos estabelecimentos:"
curl -s "$url" | awk -F 'href="' '/Estabelecimentos/ && /zip"/ {print $2}' | cut -d '"' -f 1
echo -e "\n"
# Baixar cada arquivo zip
for file in $(curl -s "$url" | awk -F 'href="' '/Estabelecimentos/ && /zip"/ {print $2}' | cut -d '"' -f 1)
do
    filename="$dir/$(basename "$file")"
    if [ -f "$filename" ]
    then
        rm "$filename"
    fi
    echo -e "\nBaixando $file...\n"
    if ! wget -c "$url$file" -O "$filename"; then
        echo -e "\n\nErro ao baixar o arquivo $file"
        continue
    fi

    # Verificar se o arquivo zip foi baixado corretamente
    if [ "$(stat -c%s "$filename")" -lt 1000 ]; then
        echo -e "\nErro: O arquivo $filename parece estar vazio ou incompleto."
        continue
    fi

    # Descompactar o arquivo zip e renomear o arquivo resultante
    if unzip -q "$filename" -d "$dir"; then
        num=1
        for csv_file in "$dir"/*.csv; do
            if [[ -f "$csv_file" ]]; then
                new_filename="${dir}/arq$(printf '%02d' $num).csv"
                mv "$csv_file" "$new_filename"
                ((num++))
            fi
        done
    else
        echo -e "\nErro ao abrir o arquivo $filename"
        continue
    fi
done

# Verificar se pelo menos um arquivo csv foi descompactado
if ! ls "$dir"/*.csv >/dev/null 2>&1; then
    echo -e "\nErro: Não foi possível encontrar nenhum arquivo CSV para unir."
    exit 1
fi

# Unir os arquivos csv
echo -e "\n---- Unindo os arquivos csv..."
csv_file="uniao.csv"
if [ -f "$csv_file" ]
then
    rm "$csv_file"
fi
head -1 "$dir/arq01.csv" > "$csv_file"
cat "$dir/arq*.csv" | tail -n +2 >> "$csv_file"

# Limpar o diretório
echo -e "\n---- Limpando o diretório..."
rm -f "$dir"/*.zip
rm -f "$dir"/*.csv

# Importar os arquivos CSV para o MySQL
# mysqlimport --user=username --password=password --local --fields-terminated-by=';' --lines-terminated-by='\n' database nome_da_tabela "${dir}/uniao.csv"
echo "Processo concluído!"