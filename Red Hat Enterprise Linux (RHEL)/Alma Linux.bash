sudo dnf install epel-release
sudo dnf install cockpit
sudo dnf install cockpit-storaged
sudo systemctl enable --now cockpit.socket
sudo systemctl restart cockpit


sudo yum install setroubleshoot-server
sudo systemctl start setroubleshootd
sudo systemctl enable setroubleshootd



sudo dnf install epel-release
sudo dnf check-update
sudo dnf install cockpit-*
sudo systemctl enable --now cockpit.socket

dnf search cockpit-
sudo dnf clean all
sudo rm /etc/yum.repos.d/jellyfin.repo

# Docker

sudo dnf install -y dnf-utils
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce --nobest -y
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker
sudo dnf install docker-compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

[root@:P ~]# cat /home/marcelo/jellyfin/docker-compose.yml
version: '3.8'
services:
  jellyfin:
    image: jellyfin/jellyfin
    user: "976:976"
    volumes:
      - /home/marcelo/jellyfin/config:/config
      - /home/marcelo/jellyfin/media:/media
      - /mnt/marcelo/videos:/videos # Adicione esta linha
    ports:
      - 8096:8096


docker-compose down
docker-compose up -d
systemctl restart docker

sudo chmod -R 777 /home/marcelo/jellyfin/config

id marcelo
chown marcelo:marcelo /home/marcelo/jellyfin/media
docker-compose logs jellyfin





netstat -tuln | grep 8096

sudo firewall-cmd --add-port=8096/tcp --permanent
sudo firewall-cmd --reload
http://000.50.198.224:8096


