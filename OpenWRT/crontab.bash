# Tutorial: Configurando Cron no OpenWRT

# 1. Verificar se o cron está instalado
which crontab

# 2. Verificar se o nano está instalado (opcional)
which nano

# 3. Instalar nano se não estiver instalado (opcional)
opkg update
opkg install nano

# 4. Definir nano como editor padrão (opcional)
export EDITOR=nano

# 5. Abrir o crontab para edição
# Use este comando se quiser usar o editor padrão:
crontab -e

# Ou use este comando para editar com nano especificamente:
EDITOR=nano crontab -e

# 6. Adicionar a seguinte linha ao arquivo crontab:
# 0 * * * * /bin/sh /home/monitores/exporta_dados_mariadb.sh

# 7. Verificar as alterações no crontab
crontab -l

# 8. Reiniciar o serviço cron
/etc/init.d/cron restart

# 9. Verificar permissões do script
ls -l /home/monitores/exporta_dados_mariadb.sh

# 10. Se necessário, adicionar permissões de execução ao script
chmod +x /home/monitores/exporta_dados_mariadb.sh

# Dicas adicionais:

# Para editar o crontab de outro usuário (requer privilégios de root):
# crontab -u [username] -e

# Para remover todas as tarefas cron do usuário atual:
# crontab -r