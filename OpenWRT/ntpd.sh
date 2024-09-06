#!/bin/bash

# Atualizar os pacotes
opkg update

# Instalar o servidor NTP e o cliente NTP
opkg install ntpd
opkg install ntpclient

# Exibir o conteúdo do arquivo de configuração do sistema
cat /etc/config/system

# Reiniciar o serviço NTP
/etc/init.d/sysntpd restart

# Verificar os logs relacionados ao NTP
logread | grep ntp

# Verificar se o processo NTP está em execução
ps | grep ntpd

# Parar o serviço NTP
/etc/init.d/sysntpd stop

# Iniciar o serviço NTP
/etc/init.d/sysntpd start

# Exibir a data e hora atual
date

# Sincronizar manualmente o relógio com um servidor NTP brasileiro
ntpclient -h a.st1.ntp.br -s

# Abrir o editor para configurar uma tarefa cron (pressione Ctrl+X para sair, Y para salvar)
EDITOR=nano crontab -e

# Adicione a seguinte linha no editor crontab para sincronização automática a cada 5 minutos
# */5 * * * * /usr/bin/ntpclient -h a.st1.ntp.br -s


/*
	Eu quero um script com apenas os comandos e comentários, sem a lógica de execução automática, permitindo que o usuário execute manualmente na ordem desejada. 
*/