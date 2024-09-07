#!/bin/sh
# Lista os pacotes instalados e salva no arquivo pacotes_instalados.txt
opkg list-installed > /root/home/pacotes_instalados.txt

# Filtra apenas os nomes dos pacotes (sem versões) e salva no arquivo pacotes_nomes.txt
opkg list-installed | awk '{print $1}' > /root/home/pacotes_nomes.txt

# Coloca os nomes dos pacotes em uma única linha, separados por espaço, e salva no arquivo pacotes_nomes.txt
opkg list-installed | awk '{print $1}' | tr '\n' ' ' > /root/home/pacotes_nomes_install.txt

# opkg update
# opkg install
