#!/bin/sh

set_variables() {
    REMOTE_HOST="flix.techsuper.com.br"
    REMOTE_DB="network_monitor"
    REMOTE_USER="marcelo"
    REMOTE_PASS="q1w2"
    REMOTE_TABLE="ping_logs"
    
    # Caminho absoluto para o banco de dados SQLite e arquivo de log
    SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
    LOCAL_DB="$SCRIPT_DIR/monitor.db"
    LOG_FILE="$SCRIPT_DIR/sincronizador_bd_2.0.txt"
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    echo "$1"
}

send_whatsapp_notification() {
    if "$SCRIPT_DIR/send_whatsapp.sh" "$1" 2>> "$LOG_FILE"; then
        log_message "Notificação enviada: $1"
    else
        log_message "Erro ao enviar notificação para o WhatsApp."
    fi
}

clear_screen() {
    printf "\033c"
}

check_internet_connection() {
    if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
        log_message "Conexão com a internet detectada."
        return 0
    else
        log_message "Sem conexão com a internet."
        return 1
    fi
}

check_connections() {
    log_message "Verificando conexões..."
    if sqlite3 "$LOCAL_DB" "SELECT name FROM sqlite_master WHERE type='table' AND name='ping_logs';" | grep -q 'ping_logs'; then
        log_message "Conexão com SQLite: OK (Tabela ping_logs existe)"
    else
        log_message "Erro: Tabela ping_logs não encontrada no SQLite ($LOCAL_DB)"
        send_whatsapp_notification "Erro: Tabela ping_logs não encontrada no SQLite"
        exit 1
    fi

    if mysql -h "$REMOTE_HOST" -u "$REMOTE_USER" -p"$REMOTE_PASS" "$REMOTE_DB" -e "DESCRIBE $REMOTE_TABLE;" >/dev/null 2>&1; then
        log_message "Conexão com MariaDB: OK (Tabela $REMOTE_TABLE existe)"
    else
        log_message "Erro: Tabela $REMOTE_TABLE não encontrada no MariaDB"
        send_whatsapp_notification "Erro: Tabela $REMOTE_TABLE não encontrada no MariaDB"
        exit 1
    fi
}

get_last_common_record() {
    local mariadb_last=$(mysql -h "$REMOTE_HOST" -u "$REMOTE_USER" -p"$REMOTE_PASS" "$REMOTE_DB" -se "SELECT data_hora, status FROM $REMOTE_TABLE ORDER BY data_hora DESC, status DESC LIMIT 1")
    if [ -z "$mariadb_last" ]; then
        echo ""
        return
    fi

    local mariadb_date=$(echo "$mariadb_last" | cut -f1)
    local mariadb_status=$(echo "$mariadb_last" | cut -f2)

    local sqlite_record=$(sqlite3 "$LOCAL_DB" "SELECT datetime(data_hora), status FROM ping_logs WHERE data_hora <= '$mariadb_date' ORDER BY data_hora DESC, status DESC LIMIT 1")
    if [ -z "$sqlite_record" ]; then
        echo ""
        return
    fi

    local sqlite_date=$(echo "$sqlite_record" | cut -d'|' -f1)
    local sqlite_status=$(echo "$sqlite_record" | cut -d'|' -f2)

    if [ "$sqlite_date" = "$mariadb_date" ] && [ "$sqlite_status" = "$mariadb_status" ]; then
        echo "$sqlite_date|$sqlite_status"
    else
        echo ""
    fi
}

get_new_records_from_sqlite() {
    local last_date="$1"
    if [ -n "$last_date" ]; then
        sqlite3 "$LOCAL_DB" "SELECT datetime(data_hora) as data_hora, ping_anterior, status FROM ping_logs WHERE data_hora > '$last_date' ORDER BY data_hora ASC"
    else
        sqlite3 "$LOCAL_DB" "SELECT datetime(data_hora) as data_hora, ping_anterior, status FROM ping_logs ORDER BY data_hora ASC"
    fi
}

insert_into_mariadb() {
    local count=0
    while IFS='|' read -r data_hora ping_anterior status; do
        [ -z "$data_hora" ] && continue
        [ -z "$ping_anterior" ] && ping_anterior="NULL"
        [ -z "$status" ] && continue

        local query="INSERT INTO $REMOTE_TABLE (data_hora, ping_anterior, status)
        VALUES ('$data_hora', $ping_anterior, '$status')
        ON DUPLICATE KEY UPDATE ping_anterior = VALUES(ping_anterior), status = VALUES(status);"

        # Inserindo e contando registros inseridos
        if mysql -h "$REMOTE_HOST" -u "$REMOTE_USER" -p"$REMOTE_PASS" "$REMOTE_DB" -e "$query" 2>> "$LOG_FILE"; then
            count=$((count + 1))  # Incrementa para cada sucesso
        else
            log_message "Erro ao inserir: $data_hora | $ping_anterior | $status"
        fi
    done

    echo "$count"  # Retorna o total de registros inseridos
}

perform_sync() {
    log_message "Iniciando sincronização de bancos de dados..."
    local last_common_record=$(get_last_common_record)
    
    if [ -z "$last_common_record" ]; then
        log_message "Nenhum registro comum encontrado. Sincronizando todos os registros do SQLite."
        last_date=""
        last_status=""
    else
        last_date=$(echo "$last_common_record" | cut -d'|' -f1)
        last_status=$(echo "$last_common_record" | cut -d'|' -f2)
        log_message "Último registro comum: Data: $last_date, Status: $last_status"
    fi

    local new_records=$(get_new_records_from_sqlite "$last_date" "$last_status")
    local records_to_sync=$(echo "$new_records" | wc -l)
    records_to_sync=${records_to_sync:-0}
    
    if [ "$records_to_sync" -gt 0 ]; then
        log_message "Registros a serem sincronizados:"
        echo "$new_records" | while IFS='|' read -r data_hora ping_anterior status; do
            log_message "  $data_hora | $ping_anterior | $status"
        done

        # Executa a inserção e recebe o número de registros inseridos
        local inserted=$(echo "$new_records" | insert_into_mariadb)

        if [ "$inserted" -gt 0 ]; then
            log_message "$inserted novos registros foram inseridos no MariaDB."
            send_whatsapp_notification "Sincronização concluída com sucesso. Foram inseridos $inserted novos registros no MariaDB."
        else
            log_message "Nenhum novo registro foi inserido (todos eram duplicados ou houve erro)."
        fi

    else
        log_message "Não há novos registros para sincronizar."
    fi
}


sync_databases() {
    if check_internet_connection; then
        check_connections
        perform_sync
    else
        log_message "Sincronização abortada devido à falta de conexão com a internet."
        send_whatsapp_notification "Sincronização abortada devido à falta de conexão com a internet."
    fi
}

# Início do script
clear_screen
set_variables
sync_databases

# Observações para instalação de dependências no OpenWRT:
# Execute os seguintes comandos para instalar as dependências necessárias:
# 
# opkg update
# opkg install sqlite3-cli mariadb-client iputils-ping grep coreutils-cut coreutils-sed coreutils-readlink curl

# 
# */5 * * * * /bin/sh /root/home/monitores/sincronizador_bd_2.0.sh >> /root/home/monitores/sincronizador_bd_2.0.log 2>&1
# ./send_whatsapp.sh "Sua mensagem aqui"