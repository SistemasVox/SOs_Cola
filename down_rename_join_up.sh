#!/bin/bash

# Definir função de manipulador de sinais
function on_sigint {
    echo -e "\n\nO download foi interrompido pelo usuário."
    exit 1
}

# Configurar o manipulador de sinais para o sinal SIGINT (Ctrl + C)
trap on_sigint SIGINT

url="https://dadosabertos.rfb.gov.br/CNPJ/"
echo "URL: $url"

# Criar um diretório para armazenar os arquivos zip
dir="zip"
if [ ! -d "$dir" ]
then
    mkdir "$dir"
fi

# Criar um diretório para armazenar os arquivos csv
csv_dir="csv"
if [ ! -d "$csv_dir" ]
then
    mkdir "$csv_dir"
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
	if unzip -q "$filename" -d "$csv_dir"; then
		for csv_file in "$csv_dir"/*.ESTABELE; do
			if [[ -f "$csv_file" ]]; then
				new_filename="${csv_file%.ESTABELE}.csv"
				mv "$csv_file" "$new_filename"
			fi
		done
	else
		echo -e "\nErro ao abrir o arquivo $filename"
		continue
	fi

done

# Verificar se pelo menos um arquivo csv foi descompactado
if ! ls "$csv_dir"/*.csv >/dev/null 2>&1; then
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
find "$csv_dir" -name '*.csv' -type f -print0 | sort -z | xargs -0 head -n 1 > "$csv_file"
tail -n +2 "$csv_dir"/*.csv >> "$csv_file"

echo -e "\nArquivo $csv_file criado com sucesso!!!!\n\n"

# Perguntar ao usuário se ele deseja importar o arquivo csv para o banco de dados
while true; do
    read -r -p "Deseja importar o arquivo $csv_file para o banco de dados? [s/N] " sn
    case $sn in
        [Ss]* ) 
        mysqlimport --user=username --password=password --local --fields-terminated-by=';' --lines-terminated-by='\n' database nome_da_tabela "${dir}/uniao.csv";
        echo -e "\nArquivo $csv_file importado para o banco de dados com sucesso!";
		# Excluir os diretórios zip e csv
		echo -e "\nExcluindo diretórios zip e csv..."
		rm -rf "$dir" "$csv_dir"
		break;;
        [Nn]* ) exit;;
        * ) echo "Por favor responda sim (s) ou não (N).";;
    esac
done
