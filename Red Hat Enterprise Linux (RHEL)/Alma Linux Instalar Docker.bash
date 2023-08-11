#!/bin/bash

# Instalar Docker
sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce --nobest -y
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

# Instalar Docker Compose
sudo dnf install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Criar diretórios para configuração e mídia do Jellyfin
mkdir -p /home/marcelo/jellyfin/config
mkdir -p /home/marcelo/jellyfin/media

# Permissões para diretórios
sudo chmod -R 777 /home/marcelo/jellyfin/config
sudo chown marcelo:marcelo /home/marcelo/jellyfin/media

# Arquivo docker-compose.yml
cat <<EOL > /home/marcelo/jellyfin/docker-compose.yml
version: '3.8'
services:
  jellyfin:
    image: jellyfin/jellyfin
    user: 1000:1000
    volumes:
      - /home/marcelo/jellyfin/config:/config
      - /home/marcelo/jellyfin/media:/media
    ports:
      - 8096:8096
EOL

# Iniciar Jellyfin
cd /home/marcelo/jellyfin
docker-compose down
docker-compose up -d
systemctl restart docker

# Firewall
sudo firewall-cmd --add-port=8096/tcp --permanent
sudo firewall-cmd --reload

# Mensagem final
echo "Jellyfin está rodando em http://198.50.198.224:8096"
