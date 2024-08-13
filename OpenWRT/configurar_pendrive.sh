#!/bin/sh

# 1. Atualizar a lista de pacotes
echo "Atualizando a lista de pacotes..."
opkg update

# 2. Instalar os pacotes necessários
echo "Instalando pacotes necessários..."
opkg install block-mount kmod-fs-ext4 kmod-usb-storage e2fsprogs kmod-usb-ohci kmod-usb-uhci fdisk

# 3. Verificar os dispositivos de armazenamento
echo "Verificando dispositivos de armazenamento..."
block info

# Espera o usuário confirmar o dispositivo correto (por exemplo, /dev/sda1)
echo "Por favor, confirme o dispositivo (ex: /dev/sda1):"
read DEVICE

# 4. Transferir o conteúdo do /overlay para o pendrive
echo "Transferindo o conteúdo do /overlay para $DEVICE..."
mount $DEVICE /mnt
tar -C /overlay -cvf - . | tar -C /mnt -xf -
umount /mnt

# 5. Gerar e configurar o fstab
echo "Configurando o fstab..."
block detect > /etc/config/fstab
sed -i s/option$'\t'enabled$'\t'\'0\'/option$'\t'enabled$'\t'\'1\'/ /etc/config/fstab
sed -i s#/mnt/$(basename $DEVICE)#/overlay# /etc/config/fstab
cat /etc/config/fstab

# 6. Montar o pendrive como /overlay
echo "Montando $DEVICE como /overlay..."
mount $DEVICE /overlay

# 7. Reiniciar o roteador
echo "Reiniciando o roteador..."
reboot

# 8. Após o reboot, o script não continuará. Verifique o status com df -h manualmente.
echo "Após o reboot, execute df -h para verificar se a configuração foi aplicada corretamente."
