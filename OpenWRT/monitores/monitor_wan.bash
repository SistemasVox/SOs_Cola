#!/bin/sh

### CONFIGURAÇÕES ###
INTERFACE="eth0.2"                 # nome lógico da interface WAN (eth0.2)
INTERVALO1=3                       # segundos da 1ª medição
INTERVALO2=2                       # segundos da 2ª medição
MAX_RX=40                          # Mbit/s de referência para download
MAX_TX=20                          # Mbit/s de referência para upload
LIM_PCT=90                         # % de MAX_* para alertar
DEBUG=false                        # exibir mensagens no console (true/false)
LOCKFILE="/tmp/monitor_${INTERFACE}.lock"
DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME=$(basename "$0")
LOGFILE="${DIR}/${SCRIPT_NAME}.txt"

# Função para log
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="[$timestamp] $1"
    
    # Adicionar ao arquivo de log
    echo "$message" >> "$LOGFILE"
    
    # Exibir no console se DEBUG=true
    if [ "$DEBUG" = "true" ]; then
        echo "$message"
    fi
}

# Verificação da interface
if [ ! -e "/sys/class/net/${INTERFACE}/statistics/rx_bytes" ]; then
    log_message "❌ Interface '$INTERFACE' não encontrada ou estatísticas não disponíveis"
    exit 1
fi

# Teste de leitura das estatísticas
TEST_RX=$(cat /sys/class/net/${INTERFACE}/statistics/rx_bytes 2>/dev/null)
TEST_TX=$(cat /sys/class/net/${INTERFACE}/statistics/tx_bytes 2>/dev/null)
if [ -z "$TEST_RX" ] || [ -z "$TEST_TX" ]; then
    log_message "❌ Não foi possível ler estatísticas da interface '$INTERFACE'"
    exit 1
fi

log_message "✅ Interface '$INTERFACE' verificada com sucesso"
log_message "   RX inicial: $TEST_RX bytes"
log_message "   TX inicial: $TEST_TX bytes"

# evita múltiplas instâncias
exec 200>"$LOCKFILE"
flock -n 200 || { log_message "🔒 Já em execução!"; exit 1; }

### FUNÇÕES ###
calc_rate() {
    # $1 = rx ou tx; $2 = intervalo
    local ini fim bytes_path="/sys/class/net/${INTERFACE}/statistics/${1}_bytes"
    
    # Leitura com tratamento de erro
    ini=$(cat "$bytes_path" 2>/dev/null) || return 1
    sleep "$2"
    fim=$(cat "$bytes_path" 2>/dev/null) || return 1
    
    # Se ambos são números, calcula a taxa
    if [ "$ini" -eq "$ini" ] 2>/dev/null && [ "$fim" -eq "$fim" ] 2>/dev/null; then
        # converte para Mbit/s com precisão
        echo "scale=2; (($fim - $ini)*8)/($2*1000000)" | bc
    else
        return 1
    fi
}

# Função para formatar porcentagem com 2 casas decimais
format_percent() {
    echo "scale=2; $1" | bc | awk '{printf "%.2f", $0}'
}

send_alert() {
    local msg="$1"
    log_message "🚨 Enviando alerta..."
    "$DIR/send_whatsapp.sh" "$msg"
    log_message "✅ Alerta enviado"
}

### LOOP PRINCIPAL ###
log_message "Iniciando monitoramento de ${INTERFACE}..."

while true; do
    # 1ª medição com tratamento de erro
    rx1=$(calc_rate rx $INTERVALO1)
    if [ $? -ne 0 ]; then
        log_message "⚠️ Erro ao ler estatísticas RX na 1ª medição"
        sleep 5
        continue
    fi
    
    tx1=$(calc_rate tx $INTERVALO1)
    if [ $? -ne 0 ]; then
        log_message "⚠️ Erro ao ler estatísticas TX na 1ª medição"
        sleep 5
        continue
    fi
    
    # Calculando porcentagens
    pct_rx1=$(echo "($rx1/$MAX_RX)*100" | bc -l)
    pct_tx1=$(echo "($tx1/$MAX_TX)*100" | bc -l)
    
    # Formatando porcentagens para 2 casas decimais
    pct_rx1_fmt=$(format_percent "$pct_rx1")
    pct_tx1_fmt=$(format_percent "$pct_tx1")
    
    # Log da 1ª medição
    log_message "Medição 1: DL=${rx1}Mbps (${pct_rx1_fmt}%), UL=${tx1}Mbps (${pct_tx1_fmt}%)"

    # Verificar se DL OU UL ultrapassou o limite
    rx_alerta=$(echo "$pct_rx1 >= $LIM_PCT" | bc -l)
    tx_alerta=$(echo "$pct_tx1 >= $LIM_PCT" | bc -l)
    
    if [ "$rx_alerta" -eq 1 ] || [ "$tx_alerta" -eq 1 ]; then
        # Identificar qual limite foi excedido (ou ambos)
        if [ "$rx_alerta" -eq 1 ]; then
            log_message "⚠️ Download acima do limite na 1ª medição (${rx1}Mbps)"
        fi
        if [ "$tx_alerta" -eq 1 ]; then
            log_message "⚠️ Upload acima do limite na 1ª medição (${tx1}Mbps)"
        fi
        
        log_message "Realizando 2ª medição para confirmação..."
        
        # 2ª medição
        rx2=$(calc_rate rx $INTERVALO2)
        tx2=$(calc_rate tx $INTERVALO2)
        
        # Verificar se a 2ª medição foi bem-sucedida
        if [ -z "$rx2" ] || [ -z "$tx2" ]; then
            log_message "⚠️ Erro ao ler estatísticas na 2ª medição"
            sleep 5
            continue
        fi
        
        pct_rx2=$(echo "($rx2/$MAX_RX)*100" | bc -l)
        pct_tx2=$(echo "($tx2/$MAX_TX)*100" | bc -l)
        
        # Formatando porcentagens para 2 casas decimais
        pct_rx2_fmt=$(format_percent "$pct_rx2")
        pct_tx2_fmt=$(format_percent "$pct_tx2")
        
        log_message "Medição 2: DL=${rx2}Mbps (${pct_rx2_fmt}%), UL=${tx2}Mbps (${pct_tx2_fmt}%)"

        # Verificar novamente na 2ª medição
        rx_alerta2=$(echo "$pct_rx2 >= $LIM_PCT" | bc -l)
        tx_alerta2=$(echo "$pct_tx2 >= $LIM_PCT" | bc -l)
        
        # Se DL ou UL continuar acima do limite na 2ª medição
        if [ "$rx_alerta2" -eq 1 ] || [ "$tx_alerta2" -eq 1 ]; then
            # Determinar quais serviços estão em alerta (para personalizar a mensagem)
            dl_alerta=""
            ul_alerta=""
            
            # Calcular médias para o relatório
            avg_rx=$(echo "scale=2; ($rx1+$rx2)/2" | bc)
            avg_tx=$(echo "scale=2; ($tx1+$tx2)/2" | bc)
            
            # Calculando porcentagens médias
            avg_pct_rx=$(echo "($avg_rx/$MAX_RX)*100" | bc -l)
            avg_pct_tx=$(echo "($avg_tx/$MAX_TX)*100" | bc -l)
            
            # Formatando porcentagens para 2 casas decimais
            avg_pct_rx_fmt=$(format_percent "$avg_pct_rx")
            avg_pct_tx_fmt=$(format_percent "$avg_pct_tx")
            
            # Verificar qual serviço está em alerta após as duas medições
            if [ "$rx_alerta" -eq 1 ] && [ "$rx_alerta2" -eq 1 ]; then
                dl_alerta="⚠️ Download acima de ${LIM_PCT}% do limite!"
            fi
            
            if [ "$tx_alerta" -eq 1 ] && [ "$tx_alerta2" -eq 1 ]; then
                ul_alerta="⚠️ Upload acima de ${LIM_PCT}% do limite!"
            fi
            
            # Data e hora atual para a mensagem
            current_datetime=$(date '+%d/%m/%Y %H:%M')
            
            # Construir mensagem única com quebras de linha usando \n
            msg="🚨 ALERTA DE CONSUMO 🚨\n\n📅 ${current_datetime}\n🌐 Interface: ${INTERFACE}\n⏱ Período: $((INTERVALO1+INTERVALO2)) segundos\n\n📊 TRÁFEGO DETECTADO"
            
            # Adicionar alertas específicos
            if [ -n "$dl_alerta" ]; then
                msg="$msg\n$dl_alerta\n📥 Download: ${avg_rx} Mbit/s (${avg_pct_rx_fmt}% de ${MAX_RX} Mbps)"
            else
                msg="$msg\n📥 Download: ${avg_rx} Mbit/s"
            fi
            
            if [ -n "$ul_alerta" ]; then
                msg="$msg\n$ul_alerta\n📤 Upload: ${avg_tx} Mbit/s (${avg_pct_tx_fmt}% de ${MAX_TX} Mbps)"
            else
                msg="$msg\n📤 Upload: ${avg_tx} Mbit/s"
            fi
            
            # Adicionar detalhes das medições
            msg="$msg\n\n📈 DETALHES DAS MEDIÇÕES\n1ª Medição (${INTERVALO1}s): DL=${rx1}Mbps | UL=${tx1}Mbps\n2ª Medição (${INTERVALO2}s): DL=${rx2}Mbps | UL=${tx2}Mbps"

            send_alert "$msg"
            log_message "🚨 Alerta enviado com detalhes completos!"
        fi
    fi

    sleep $INTERVALO1
done