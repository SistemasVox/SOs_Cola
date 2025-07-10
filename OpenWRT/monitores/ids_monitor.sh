#!/bin/sh
# ==============================================================
#  File: /root/scripts/ids_monitor.sh
#  Desc: Intrusion-Detection log monitor for OpenWRT
# ==============================================================

# === CONFIGURAÇÕES GERAIS =====================================
DEBUG=false                     # true = logs detalhados
INTERVAL=60                     # segundos entre varreduras
EXPIRE_DAYS=30                  # TTL para histórico

DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0" .sh)"

WHATSAPP_SCRIPT="$DIR/send_whatsapp.sh"
DB_PATH="$DIR/${SCRIPT_NAME}.db"
LOG_FILE="$DIR/${SCRIPT_NAME}.log"
# ==============================================================


# === FUNÇÃO DE LOG DE DEPURAÇÃO ===============================
debug_log() {
    $DEBUG && echo "[DEBUG] $*" | tee -a "$LOG_FILE"
}
# ==============================================================


# === DETECÇÃO DE INTERFACE ====================================
get_iface() {
    local mac="$1" ip="$2" iface

    # 1) Wi-Fi (wlanX)
    iface=$(for w in $(iw dev | awk '$1=="Interface"{print $2}'); do
                iw dev "$w" station dump | grep -qi "$mac" && { echo "$w"; break; }
            done)
    [ -n "$iface" ] && { echo "$iface"; return; }

    # 2) ip neigh (evita br-lan)
    iface=$(ip neigh show "$ip" 2>/dev/null | awk '$3!="br-lan"{print $3; exit}')
    [ -n "$iface" ] && { echo "$iface"; return; }

    # 3) bridge fdb (se utilitário existir)
    if command -v bridge >/dev/null; then
        iface=$(bridge fdb show | awk -v mac="$(echo "$mac" | tr A-Z a-z)" \
               '$1==mac && $4=="master"{print $3; exit}')
        [ -n "$iface" ] && { echo "$iface"; return; }
    fi

    # 4) fallback
    iface=$(ip neigh show "$ip" 2>/dev/null | awk '{print $3; exit}')
    echo "${iface:-unknown}"
}

ensure_iface() {
    local ifname="$1"
    sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO interfaces(name) VALUES('$ifname');"
    sqlite3 "$DB_PATH" "SELECT id FROM interfaces WHERE name='$ifname';"
}
# ==============================================================


# === ENVIO DE NOTIFICAÇÃO =====================================
send_notification() {
    # $1 mac  $2 ip  $3 host  $4 iface  $5 status(0/1)  $6 change_time
    local status_word; [ "$5" -eq 1 ] && status_word="online" || status_word="offline"

    # ----- mensagem completa (log + WhatsApp) ------------------
    local msg="🚨 Status alterado!
Data/Hora: $6
Interface: $4
MAC: $1
IP:  $2
Nome: $3
Status: $status_word"
    # -----------------------------------------------------------

    # -> Arquivo de log (completo)
    echo "$msg" >> "$LOG_FILE"

    # -> Console (resumido)
    echo "[$6] $status_word $3 ($1) via $4"

    # -> WhatsApp
    "$WHATSAPP_SCRIPT" "$msg"
}
# ==============================================================


# === CRIAÇÃO / UPGRADE DO BANCO ===============================
initialize_db() {
sqlite3 "$DB_PATH" >/dev/null <<'SQL'
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = MEMORY;

CREATE TABLE IF NOT EXISTS interfaces (
    id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE
);

CREATE TABLE IF NOT EXISTS devices (
    mac TEXT PRIMARY KEY,
    name TEXT,
    description TEXT
) WITHOUT ROWID;

CREATE TABLE IF NOT EXISTS current_status (
    mac          TEXT PRIMARY KEY REFERENCES devices(mac) ON DELETE CASCADE,
    interface_id INTEGER REFERENCES interfaces(id),
    ip           TEXT,
    hostname     TEXT,
    status       INTEGER NOT NULL,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS status_logs (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    mac          TEXT,
    interface_id INTEGER,
    ip           TEXT,
    hostname     TEXT,
    status       INTEGER NOT NULL,
    ts           DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_status_logs_mac_ts
          ON status_logs(mac, ts DESC);
CREATE INDEX IF NOT EXISTS idx_current_status_status
          ON current_status(status);
SQL
}
# ==============================================================


# === UPSERT DE STATUS =========================================
upsert_current_status() {
    local mac=$1 status=$2 ip=$3 host=$4 iface_name=$5
    local change_time
    change_time=$(date "+%Y-%m-%d %H:%M:%S")

    sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO devices(mac) VALUES('$mac');"

    local iface_id
    iface_id=$(ensure_iface "$iface_name")

    local changed
    changed=$(sqlite3 -noheader "$DB_PATH" <<SQL
BEGIN;
INSERT INTO current_status (mac, interface_id, ip, hostname, status)
VALUES ('$mac', $iface_id, '$ip', '$host', $status)
ON CONFLICT(mac) DO UPDATE
    SET interface_id=$iface_id,
        ip='$ip',
        hostname='$host',
        status=$status,
        updated_at=CURRENT_TIMESTAMP
    WHERE current_status.status <> $status;
SELECT changes();
COMMIT;
SQL
)

    if [ "$changed" -gt 0 ]; then
        sqlite3 "$DB_PATH" \
           "INSERT INTO status_logs (mac, interface_id, ip, hostname, status, ts) \
            VALUES ('$mac', $iface_id, '$ip', '$host', $status, '$change_time');"
        send_notification "$mac" "$ip" "$host" "$iface_name" "$status" "$change_time"
    fi
}
# ==============================================================


# === LIMPEZA DE LOGS ANTIGOS ==================================
clean_old_logs() {
    sqlite3 "$DB_PATH" \
        "DELETE FROM status_logs \
         WHERE ts < DATE('now','-${EXPIRE_DAYS} days');"
}
# ==============================================================


# === LOOP PRINCIPAL ===========================================
monitor_loop() {
    [ ! -f "$DB_PATH" ] && { debug_log "📁 Criando banco…"; initialize_db; }

    while :; do
        debug_log "🔍 Lendo leases DHCP…"
        awk '{print $2,$3,$4}' /tmp/dhcp.leases | while read -r mac ip host; do
            iface_name=$(get_iface "$mac" "$ip")
            upsert_current_status "$mac" 1 "$ip" "$host" "$iface_name"
        done

        for mac in $(sqlite3 "$DB_PATH" \
                     "SELECT mac FROM current_status WHERE status = 1;"); do
            grep -qi "$mac" /tmp/dhcp.leases || {
                iface_name=$(sqlite3 "$DB_PATH" \
                    "SELECT name FROM interfaces \
                     WHERE id=(SELECT interface_id FROM current_status WHERE mac='$mac');")
                upsert_current_status "$mac" 0 "" "" "$iface_name"
            }
        done

        clean_old_logs
        debug_log "✅ Loop concluído; dormindo ${INTERVAL}s"
        sleep "$INTERVAL"
    done
}
# ==============================================================


echo "🚀 IDS monitor iniciado (intervalo ${INTERVAL}s)" | tee -a "$LOG_FILE"
monitor_loop
