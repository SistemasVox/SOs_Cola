#!/bin/sh

# Adiciona a tarefa de reinicialização no cron
echo "0 6 * * * /sbin/reboot" >> /etc/crontabs/root

# Habilita e inicia o serviço cron
/etc/init.d/cron enable
/etc/init.d/cron start

# Verifica se a tarefa foi adicionada
echo "Verificando as tarefas cron atuais:"
cat /etc/crontabs/root

echo "Auto reboot configurado para todos os dias às 6:00 AM. :D"


# Se ja tiver o arquivo 
crontab -e
0 6 * * * reboot
crontab -l

