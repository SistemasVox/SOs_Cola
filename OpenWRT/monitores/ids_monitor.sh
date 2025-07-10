#!/bin/sh
# ==============================================================
#  File: /root/scripts/ids_monitor.sh
#  Desc: Intrusion-Detection log monitor for OpenWRT
# ==============================================================

# === CONFIG ===================================================
DEBUG=false
INTERVAL=60
EXPIRE_DAYS=30

DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$(basename "$0" .sh)"

WHATSAPP_SCRIPT="$DIR/send_whatsapp.sh"
DB_PATH="$DIR/${SCRIPT_NAME}.db"
LOG_FILE="$DIR/${SCRIPT_NAME}.log"
# ==============================================================


debug_log() { $DEBUG && echo "[DEBUG] $*" | tee -a "$LOG_FILE"; }

# --- escapa apóstrofos para uso em SQL ------------------------
sql_quote() { printf "%s" "$1" | sed "s/'/''/g"; }
# ==============================================================


# === DETECÇÃO DE INTERFACE ====================================
get_iface() {
    local mac="$1" ip="$2" iface
    iface=$(for w in $(iw dev | awk '$1=="Interface"{print $2}'); do
               iw dev "$w" station dump | grep -qi "$mac" && { echo "$w"; break; }
           done)
    [ -n "$iface" ] && { echo "$iface"; return; }
    iface=$(ip neigh show "$ip" 2>/dev/null | awk '$3!="br-lan"{print $3; exit}')
    [ -n "$iface" ] && { echo "$iface"; return; }
    if command -v bridge >/dev/null; then
        iface=$(bridge fdb show | awk -v mac="$(echo "$mac" | tr A-Z a-z)" \
               '$1==mac && $4=="master"{print $3; exit}')
        [ -n "$iface" ] && { echo "$iface"; return; }
    fi
    iface=$(ip neigh show "$ip" 2>/dev/null | awk '{print $3; exit}')
    echo "${iface:-unknown}"
}

ensure_iface() {
    local ifname="$1"
    sqlite3 "$DB_PATH" "INSERT OR IGNORE INTO interfaces(name) VALUES('$(sql_quote "$ifname")');"
    sqlite3 "$DB_PATH" "SELECT id FROM interfaces WHERE name='$(sql_quote "$ifname")';"
}
# ==============================================================


send_notification() {
    local status_word; [ "$5" -eq 1 ] && status_word="online" || status_word="offline"
    local msg="🚨 Status alterado!
Data/Hora: $6
Interface: $4
MAC: $1
IP:  $2
Nome: $3
Status: $status_word"

    echo "$msg" >> "$LOG_FILE"
    echo "[$6] $status_word $3 ($1) via $4"
    "$WHATSAPP_SCRIPT" "$msg"
}
# ==============================================================


initialize_db() {
sqlite3 "$DB_PATH" >/dev/null <<'SQL'
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = MEMORY;
CREATE TABLE IF NOT EXISTS interfaces (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE);
CREATE TABLE IF NOT EXISTS devices (mac TEXT PRIMARY KEY, name TEXT, description TEXT) WITHOUT ROWID;
CREATE TABLE IF NOT EXISTS current_status (
    mac TEXT PRIMARY KEY REFERENCES devices(mac) ON DELETE CASCADE,
    interface_id INTEGER REFERENCES interfaces(id),
    ip TEXT, hostname TEXT, status INTEGER NOT NULL,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS status_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    mac TEXT, interface_id INTEGER, ip TEXT, hostname TEXT,
    status INTEGER NOT NULL, ts DATETIME DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS idx_status_logs_mac_ts ON status_logs(mac, ts DESC);
CREATE INDEX IF NOT EXISTS idx_current_status_status ON current_status(status);
SQL
}
# ==============================================================


upsert_current_status() {
    local mac="$1" status="$2" ip="$3" host="$4" iface_name="$5"
    local change_time; change_time=$(date "+%Y-%m-%d %H:%M:%S")

    local host_q; host_q=$(sql_quote "$host")
    sqlite3 "$DB_PATH" \
      "INSERT INTO devices(mac,name) VALUES('$mac','$host_q')
       ON CONFLICT(mac) DO UPDATE SET name=excluded.name;"

    local iface_id; iface_id=$(ensure_iface "$iface_name")

    local ip_q; ip_q=$(sql_quote "$ip")
    local changed
    changed=$(sqlite3 -noheader "$DB_PATH" <<SQL
BEGIN;
INSERT INTO current_status (mac, interface_id, ip, hostname, status)
VALUES ('$mac', $iface_id, '$ip_q', '$host_q', $status)
ON CONFLICT(mac) DO UPDATE
    SET interface_id=$iface_id,
        ip='$ip_q',
        hostname='$host_q',
        status=$status,
        updated_at=CURRENT_TIMESTAMP
    WHERE current_status.status <> $status;
SELECT changes();
COMMIT;
SQL
)

    if [ "$changed" -gt 0 ]; then
        sqlite3 "$DB_PATH" \
          "INSERT INTO status_logs (mac, interface_id, ip, hostname, status, ts)
           VALUES ('$mac', $iface_id, '$ip_q', '$host_q', $status, '$change_time');"
        send_notification "$mac" "$ip" "$host" "$iface_name" "$status" "$change_time"
    fi
}
# ==============================================================


clean_old_logs() {
    sqlite3 "$DB_PATH" \
        "DELETE FROM status_logs
         WHERE ts < DATE('now','-${EXPIRE_DAYS} days');"
}
# ==============================================================


need_schema() {
    sqlite3 "$DB_PATH" \
        "SELECT 1 FROM sqlite_master WHERE type='table' AND name='current_status';" |
        grep -q 1 || return 0
    return 1
}
# ==============================================================


monitor_loop() {
    [ ! -f "$DB_PATH" ] || need_schema && { debug_log "📁 (Re)criando schema…"; initialize_db; }

    while :; do
        debug_log "🔍 Varredura DHCP…"
        awk '{print $2,$3,$4}' /tmp/dhcp.leases | while read -r mac ip host; do
            iface_name=$(get_iface "$mac" "$ip")
            upsert_current_status "$mac" 1 "$ip" "$host" "$iface_name"
        done

        for mac in $(sqlite3 "$DB_PATH" \
                     "SELECT mac FROM current_status WHERE status=1;"); do
            grep -qi "$mac" /tmp/dhcp.leases || {
                IFS='|' read ip host iface_name <<EOF
$(sqlite3 -separator '|' "$DB_PATH" \
 "SELECT ip,hostname,(SELECT name FROM interfaces WHERE id=interface_id)
  FROM current_status WHERE mac='$mac';")
EOF
                upsert_current_status "$mac" 0 "$ip" "$host" "$iface_name"
            }
        done

        clean_old_logs
        debug_log "✅ Dormindo ${INTERVAL}s"
        sleep "$INTERVAL"
    done
}
# ==============================================================


echo "🚀 IDS monitor iniciado (intervalo ${INTERVAL}s)" | tee -a "$LOG_FILE"
monitor_loop
