# Atualizar a lista de pacotes e instalar o vsftpd (Very Secure FTP Daemon)
# Isso garante que temos a versão mais recente do vsftpd disponível
opkg update && opkg install vsftpd

# Criar diretório FTP e definir as permissões
# Isso cria o diretório principal para o FTP e define o usuário 'ftp' como proprietário
mkdir -p /mnt/sda1/ftp
chown -R ftp:ftp /mnt/sda1/ftp

# Configurar o vsftpd
# Criamos um novo arquivo de configuração com as seguintes opções:
cat << EOF > /etc/vsftpd.conf
background=YES          # Executa o vsftpd em segundo plano
listen=YES              # O vsftpd escuta conexões IPv4
anonymous_enable=NO     # Desativa o acesso anônimo para maior segurança
local_enable=YES        # Permite login de usuários locais
write_enable=YES        # Permite operações de escrita no servidor FTP
local_umask=002         # Define a umask para novos arquivos (permite leitura/escrita para grupo)
check_shell=NO          # Desativa a verificação de shell (útil para usuários FTP sem shell válido)
session_support=NO      # Desativa o suporte a sessões PAM
user_config_dir=/etc/vsftpd_user_conf  # Diretório para configurações específicas de usuários
local_root=/mnt/sda1/ftp               # Define o diretório raiz para usuários locais
EOF

# Gerenciar o serviço vsftpd
# Iniciamos o serviço, habilitamos para iniciar no boot e reiniciamos para aplicar as configurações
/etc/init.d/vsftpd start
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd restart

# Adicionar usuário FTP ao sistema
# Criamos uma entrada no /etc/passwd para o usuário 'ftp' e definimos uma senha
echo 'ftp:x:1001:1001:FTP User:/mnt/sda1/ftp:/bin/false' >> /etc/passwd
passwd ftp

# Remover entrada antiga do usuário FTP (se existir) e reiniciar o serviço
# Isso evita conflitos com possíveis entradas antigas do usuário 'ftp'
sed -i '/^ftp:x:55:55:ftp:\/home\/ftp:\/bin\/false/d' /etc/passwd && /etc/init.d/vsftpd restart

# Configurar permissões do diretório FTP
# Garantimos que o usuário 'ftp' é o proprietário e definimos as permissões corretas
chown -R ftp:ftp /mnt/sda1/ftp
chmod -R 755 /mnt/sda1/ftp

# Verificar configurações
# Listamos as permissões do diretório FTP e o espaço em disco disponível
ls -ld /mnt/sda1/ftp
df -h /mnt/sda1

# Nota: Certifique-se de que /mnt/sda1 é o dispositivo correto para seu ambiente.
# Para maior segurança, considere:
# - Limitar o acesso por IP no firewall
# - Usar FTP sobre SSL/TLS (FTPS) para criptografar as transferências
# - Regularmente atualizar o vsftpd e o sistema operacional