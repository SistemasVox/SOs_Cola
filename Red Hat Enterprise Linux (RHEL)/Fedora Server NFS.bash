#!/bin/bash

# Instala os utilitários NFS
sudo dnf install nfs-utils -y

# Habilita e inicia o serviço rpcbind
sudo systemctl enable rpcbind
sudo systemctl start rpcbind

# Cria o diretório onde o sistema de arquivos NFS será montado
sudo mkdir -p /mnt/marcelo/videos

# Monte o sistema de arquivos NFS
sudo mount -t nfs -o rw,sync 192.168.1.1:/home/marcelo/videos /mnt/marcelo/videos

# Mude a propriedade do diretório montado para o usuário jellyfin
sudo chown -R jellyfin:jellyfin /mnt/marcelo/videos

# Nota: Para desmontar o sistema de arquivos NFS quando terminar, use:
# sudo umount /mnt/marcelo/videos

#!/bin/bash

# Instala os utilitários NFS
sudo dnf install nfs-utils -y

# Habilita e inicia o serviço rpcbind
sudo systemctl enable rpcbind
sudo systemctl start rpcbind

# Define o usuário para o qual você quer mapear o UID e GID
user="jellyfin"

# Obtém o UID e GID do usuário especificado
uid=$(id -u $user)
gid=$(id -g $user)

# Cria o diretório onde o sistema de arquivos NFS será montado
sudo mkdir -p /mnt/marcelo/videos

# Monte o sistema de arquivos NFS com as opções especificadas
sudo mount -t nfs -o rw,sync,anonuid=$uid,anongid=$gid 192.168.1.1:/home/marcelo/videos /mnt/marcelo/videos

# Nota: Para desmontar o sistema de arquivos NFS quando terminar, use:
# sudo umount /mnt/marcelo/videos


#!/bin/bash

# Instala os utilitários NFS
sudo dnf install nfs-utils -y

# Habilita e inicia o serviço rpcbind
sudo systemctl enable rpcbind
sudo systemctl start rpcbind

# Cria o diretório onde o sistema de arquivos NFS será montado
sudo mkdir -p /mnt/marcelo/videos

# Adiciona a entrada ao /etc/fstab para montagem automática
echo "192.168.1.1:/home/marcelo/videos /mnt/marcelo/videos nfs defaults 0 0" | sudo tee -a /etc/fstab

# Monta todos os sistemas de arquivos listados em /etc/fstab
sudo mount -a



#!/bin/bash

# Faz um backup do arquivo de configuração atual
sudo cp /etc/exports /etc/exports.backup

# Abre o arquivo de configuração
sudo nano /etc/exports

# Adicione ou altere a linha abaixo no arquivo de configuração para restringir o acesso aos IPs especificados
# /home/marcelo/videos 192.168.1.10(rw,sync,no_root_squash) 192.168.1.20(rw,sync,no_root_squash)

# Salve o arquivo e saia do editor (no nano, CTRL + O para salvar, CTRL + X para sair)

# Recarregue a configuração do NFS para aplicar as alterações
sudo exportfs -ra

# Fim do script



#!/bin/bash

# Defina o proprietário do diretório para o usuário jellyfin
sudo chown -R jellyfin:jellyfin /home/marcelo/videos

# Defina as permissões para leitura e escrita para o proprietário
sudo chmod -R 770 /home/marcelo/videos

# Fim do script

