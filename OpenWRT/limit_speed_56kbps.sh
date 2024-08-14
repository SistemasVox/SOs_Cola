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

# Cria a classe filha com limite de 56kbit para toda a interface
tc class add dev wlan1-1 parent 1:1 classid 1:10 htb rate 56kbit

# Comentários:
# Para instalar o pacote 'tc', use o comando: opkg update
# Em seguida, instale o pacote 'tc' com o comando: opkg install tc
