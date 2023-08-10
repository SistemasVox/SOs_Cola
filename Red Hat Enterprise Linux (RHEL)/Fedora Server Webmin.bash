#!/bin/bash

# Atualiza os pacotes
sudo dnf update -y

# Instala as dependências do Perl
sudo dnf install -y perl-Digest-MD5 perl-Digest-SHA perl-Net-SSLeay perl-lib perl-open

# Baixa o pacote RPM do Webmin
wget https://prdownloads.sourceforge.net/webadmin/webmin-2.101-1.noarch.rpm

# Instala o pacote RPM do Webmin
sudo rpm -i --nosignature webmin-2.101-1.noarch.rpm

# Habilita e inicia o serviço Webmin
sudo systemctl enable --now webmin

# Muda a porta do Webmin para 18000
sudo sed -i 's/port=10000/port=18000/' /etc/webmin/miniserv.conf
sudo systemctl restart webmin

# Libera as portas 10000 e 18000 no firewall
sudo firewall-cmd --add-port=10000/tcp --permanent
sudo firewall-cmd --add-port=18000/tcp --permanent
sudo firewall-cmd --reload

# Mostra uma mensagem de sucesso
echo "Webmin instalado com sucesso! Acesse https://seu-ip:18000 no navegador."

chmod +x install-webmin.sh
./install-webmin.sh

