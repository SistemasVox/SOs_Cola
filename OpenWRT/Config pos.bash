opkg update
opkg install nano vim bmon screen htop wget curl adblock luci-app-adblock tcpdump-mini

ls /mnt/data
mkdir -p /mnt/data
chmod 755 /mnt/data
dd if=/dev/zero of=/mnt/data/swapfile bs=1M count=2048
mkswap /mnt/data/swapfile
swapon /mnt/data/swapfile
ls -lh /mnt/data/swapfile
# swap seja ativado automaticamente na inicialização
vi /etc/rc.local
swapon /mnt/data/swapfile &
exit 0

### mkdir -p /mnt/data && chmod 755 /mnt/data && for i in 1 2 3 4; do dd if=/dev/zero of=/mnt/data/swapfile$i bs=1M count=2048 && mkswap /mnt/data/swapfile$i && swapon /mnt/data/swapfile$i && echo "swapon /mnt/data/swapfile$i &" >> /etc/rc.local; done && sed -i '$a exit 0' /etc/rc.local


# swap seja ativado automaticamente na inicialização
vi /etc/fstab
/mnt/data/swapfile none swap sw 0 0

# Verificar o Swap
free
swapon --show

#Se você realmente quiser "limpar" o arquivo de swap, você teria que desligar o swap, remover o arquivo, e recriá-lo. Isso pode ser feito com os seguintes comandos:
swapoff /mnt/data/swapfile
rm /mnt/data/swapfile
dd if=/dev/zero of=/mnt/data/swapfile bs=1M count=8192
mkswap /mnt/data/swapfile
swapon /mnt/data/swapfile


# Install packages
opkg update
opkg install adblock
 
# Provide web interface
opkg install luci-app-adblock
 
# Backup the blocklists
uci set adblock.global.adb_backupdir="/etc/adblock"
 
# Save and apply
uci commit adblock
/etc/init.d/adblock restart

