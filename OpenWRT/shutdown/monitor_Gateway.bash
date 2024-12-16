#!/bin/bash

# ========================================
# Configurações Iniciais
# ========================================
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "$0" | cut -d'.' -f1)"
LOG_FILE="$DIR/${SCRIPT_NAME}.log"
FAILURE_COUNT=0
FAILURE_LIMIT=5
DELAY_START=30
# GATEWAY=$(ip route | grep default | awk '{print $3}')
GATEWAY=$(ip -4 route show dev br-lan | grep -m 1 "src" | awk '{print $7}')
WHATSAPP_SCRIPT="$DIR/send_whatsapp.sh"

# ========================================
# Funções Auxiliares
# ========================================
log_message() {
    local message="$1"
    # Verifica tamanho do arquivo de log e recria se maior que 4MB
    if [ -f "$LOG_FILE" ] && [ $(wc -c < "$LOG_FILE") -gt $((4 * 1024 * 1024)) ]; then
        echo "Arquivo de log excedeu 4MB. Criando novo log." > "$LOG_FILE"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

envia_whatsapp() {
    local mensagem="$1"
    bash "$WHATSAPP_SCRIPT" "$mensagem"
}

# ========================================
# Inicialização do Script
# ========================================
log_message "Script iniciado. Aguardando $DELAY_START segundos antes de monitorar."
sleep $DELAY_START

# Verifica se o gateway foi identificado
if [ -z "$GATEWAY" ]; then
    log_message "Erro: Gateway não encontrado. Verifique sua conexão de rede."
    exit 1
fi
log_message "Gateway identificado: $GATEWAY"

# ========================================
# Ciclo de Monitoramento
# ========================================
while true; do
    if ping -c 1 -W 1 "$GATEWAY" > /dev/null 2>&1; then
        # Sucesso no ping
        if [ $FAILURE_COUNT -ne 0 ]; then
            log_message "Conexão restabelecida com o gateway."
            envia_whatsapp "Conexão com o gateway $GATEWAY foi restabelecida."
        fi
        FAILURE_COUNT=0
    else
        # Falha no ping
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        log_message "Falha no ping ao gateway ($FAILURE_COUNT/$FAILURE_LIMIT)."
        if [ $FAILURE_COUNT -ge $FAILURE_LIMIT ]; then
            log_message "Limite de falhas atingido. Reiniciando o sistema."
            envia_whatsapp "Falha na conexão com o gateway $GATEWAY. Reiniciando o sistema."
            shutdown -f
            exit 0
        fi
    fi
    sleep 1
done

# ========================================
# Comandos usados para criação do Script
# ip -4 route show | grep -m 1 "default via" | awk '{print $3}'
# ip -4 route show
# ========================================