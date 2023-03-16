#!/bin/bash

# informações de acesso ao banco de dados
db_host="XXX.XXX.XXX.XXX"
db_user="XXXXXX_XXXXX"
db_password="XXXXXXXXXXX"
db_name="XXXXXX_XXXXXX"
table_name="XXXXXXXXX"

# Obter o caminho absoluto do arquivo CSV
csv_path="$PWD/uniao.csv"
echo -e "\nCaminho absoluto do arquivo CSV: $csv_path"

# Função para testar a conexão com o banco de dados
test_db_connection() {
    if mysql --host="$db_host" --user="$db_user" --password="$db_password" --execute="use $db_name" >/dev/null 2>&1; then
        echo -e "\nConexão com o banco de dados estabelecida com sucesso!"
        return 0
    else
        echo -e "\nNão foi possível estabelecer uma conexão com o banco de dados."
        return 1
    fi
}

# Função para verificar se a tabela existe no banco de dados
check_table_existence() {
    if mysql --host="$db_host" --user="$db_user" --password="$db_password" --execute="use $db_name; describe $table_name" >/dev/null 2>&1; then
        echo -e "\nA tabela $table_name existe no banco de dados.\n"
        return 0
    else
        echo -e "\nA tabela $table_name não existe no banco de dados.\n"
        return 1
    fi
}

# Perguntar ao usuário se ele deseja importar o arquivo csv para o banco de dados
while true; do
    read -r -p "Deseja importar o arquivo $csv_path para o banco de dados? [s/N] " sn
    case $sn in
        [Ss]* )
            # Verificar se o arquivo existe e tem permissão de acesso
            if [ -e "$csv_path" ]; then
                # Testar a conexão com o banco de dados
                if test_db_connection; then
                    # Verificar se a tabela existe no banco de dados
                    if check_table_existence; then
                        # Importar o arquivo csv para o banco de dados
						#tr '\r\n' '\n' < "$csv_path" > "$csv_path"

                        #mysql --host="$db_host" --user="$db_user" --password="$db_password" -e "USE $db_name; DROP TABLE $table_name; CREATE TABLE $table_name (cnpj VARCHAR(14), ordem_cnpj VARCHAR(4), dv_cnpj VARCHAR(2), id_matriz_filial VARCHAR(1), nome VARCHAR(150), situacao VARCHAR(2), data_situacao VARCHAR(8), motivo_situacao VARCHAR(3), nome_cidade VARCHAR(50), pais VARCHAR(50), data_inicio VARCHAR(8), cnae_principal VARCHAR(7), cnae_secundaria VARCHAR(7), tipo_logradouro VARCHAR(20), logradouro VARCHAR(60), numero VARCHAR(6), complemento VARCHAR(20), bairro VARCHAR(50), cep VARCHAR(8), uf VARCHAR(2), municipio VARCHAR(50), ddd_1 VARCHAR(2), telefone_1 VARCHAR(9), ddd_2 VARCHAR(2), telefone_2 VARCHAR(9), ddd_fax VARCHAR(2), fax VARCHAR(9), email VARCHAR(115), situacao_especial VARCHAR(2), data_situacao_especial VARCHAR(8)) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; LOAD DATA LOCAL INFILE '$csv_path' INTO TABLE $table_name FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\\\\' LINES TERMINATED BY '\r\n';"
						
						mysql --host="$db_host" --user="$db_user" --password="$db_password" -e "USE $db_name; TRUNCATE TABLE $table_name; LOAD DATA LOCAL INFILE '$csv_path' INTO TABLE $table_name FIELDS TERMINATED BY ';' ENCLOSED BY '\"' LINES TERMINATED BY '\n'; DELETE FROM empresas WHERE ordem_cnpj IS NULL;"
	

						
						#mysql --host="$db_host" --user="$db_user" --password="$db_password" -e "USE $db_name; DROP TABLE $table_name; CREATE TABLE $table_name (cnpj VARCHAR(255), ordem_cnpj VARCHAR(255), dv_cnpj VARCHAR(255), id_matriz_filial VARCHAR(255), nome VARCHAR(255), situacao VARCHAR(255), data_situacao VARCHAR(255), motivo_situacao VARCHAR(255), nome_cidade VARCHAR(255), pais VARCHAR(255), data_inicio VARCHAR(255), cnae_principal VARCHAR(255), cnae_secundaria VARCHAR(255), tipo_logradouro VARCHAR(255), logradouro VARCHAR(255), numero VARCHAR(255), complemento VARCHAR(255), bairro VARCHAR(255), cep VARCHAR(255), uf VARCHAR(255), municipio VARCHAR(255), ddd_1 VARCHAR(255), telefone_1 VARCHAR(255), ddd_2 VARCHAR(255), telefone_2 VARCHAR(255), ddd_fax VARCHAR(255), fax VARCHAR(255), email VARCHAR(255), situacao_especial VARCHAR(255), data_situacao_especial VARCHAR(255)) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; LOAD DATA LOCAL INFILE '$csv_path' INTO TABLE $table_name FIELDS TERMINATED BY ';' ENCLOSED BY '\"' ESCAPED BY '\\\\' LINES TERMINATED BY '\r\n';"


                        echo -e "\nArquivo $csv_path importado para o banco de dados com sucesso!"
                        break
                    else
                        echo -e "\nA tabela $table_name não existe no banco de dados."
                    fi
                fi
            else
                echo -e "\nO arquivo $csv_path não existe ou você não tem permissão de acesso."
            fi
            ;;
        [Nn]* ) exit;;
        * ) echo -e "\nPor favor responda sim (s) ou não (N).";;
    esac
done
