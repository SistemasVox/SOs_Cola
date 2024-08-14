#!/bin/sh

# Verifica se o pacote 'tc' está instalado
if ! tc -V >/dev/null 2>&1; then
    echo "O pacote 'tc' não está instalado. Tentando instalar..."
    opkg update
    opkg install tc
fi

# Cria a raiz qdisc
tc qdisc add dev wlan1-1 root handle 1: htb default 10

# Cria a classe pai
tc class add dev wlan1-1 parent 1: classid 1:1 htb rate 100mbit

# Cria a classe filha com limite de 1mbit
tc class add dev wlan1-1 parent 1:1 classid 1:10 htb rate 1mbit
# tc class add dev wlan1-1 parent 1:1 classid 1:10 htb rate 512kbit

# Cria o filtro para o endereço MAC
tc filter add dev wlan1-1 parent 1: protocol ip prio 1 u32 match u16 0x0800 0xFFFF at -2 match u16 0xBEDB 0xFFFF at -4 match u32 0xF16ED290 0xFFFFFFFF at -8 flowid 1:10

# Comentários:
# Para instalar o pacote 'tc', use o comando: opkg update
# Em seguida, instale o pacote 'tc' com o comando: opkg install tc
# O endereço MAC que estamos limitando é: BE:DB:F1:6E:D2:90
# O endereço MAC é dividido em duas partes para o comando 'match': 0xBEDB e 0xF16ED290
# 'match u16 0x0800 0xFFFF at -2' corresponde ao tipo de protocolo IP
# 'match u16 0xBEDB 0xFFFF at -4' e 'match u32 0xF16ED290 0xFFFFFFFF at -8' correspondem ao endereço MAC
