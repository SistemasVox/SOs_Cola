# Atualizar a lista de pacotes disponíveis no OpenWRT
opkg update

# Instalar o bash no OpenWRT
opkg install bash

# Criar o arquivo de histórico de comandos
touch /root/.bash_history

# Configurar permissões para o arquivo de histórico
chmod 600 /root/.bash_history

# Definir a variável de ambiente HISTFILE para usar o arquivo de histórico criado
export HISTFILE=/root/.bash_history

# Definir o tamanho máximo do histórico na memória
export HISTSIZE=1000

# Definir o tamanho máximo do arquivo de histórico no disco
export HISTFILESIZE=2000

# Opcional: Adicionar as configurações de histórico ao arquivo .bashrc para que sejam aplicadas automaticamente em cada sessão
echo 'export HISTFILE=/root/.bash_history' >> ~/.bashrc
echo 'export HISTSIZE=1000' >> ~/.bashrc
echo 'export HISTFILESIZE=2000' >> ~/.bashrc

# Opcional: Adicionar uma configuração para salvar o histórico após cada comando
echo 'PROMPT_COMMAND="history -a; $PROMPT_COMMAND"' >> ~/.bashrc

# Opcional: Alterar o shell padrão para bash no arquivo /etc/passwd
# Nota: Requer edição manual. Encontre a linha que começa com 'root' e substitua '/bin/ash' por '/bin/bash'.
vi /etc/passwd

# Opcional: Adicionar o comando para iniciar o bash automaticamente ao abrir uma nova sessão de terminal
echo 'exec /bin/bash' >> /etc/profile
