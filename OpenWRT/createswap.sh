#!/bin/sh

# Criar diretório se não existir
mkdir -p /mnt/data
chmod 755 /mnt/data

# Criar os arquivos de swap
for i in 1 2 3 4; do
  dd if=/dev/zero of=/mnt/data/swapfile$i bs=1M count=2048
  mkswap /mnt/data/swapfile$i
  swapon /mnt/data/swapfile$i
  echo "swapon /mnt/data/swapfile$i &" >> /etc/rc.local
done

# Listar arquivos
ls -lh /mnt/data/swapfile*

# Inserir "exit 0" ao final de /etc/rc.local
sed -i '$a exit 0' /etc/rc.local
