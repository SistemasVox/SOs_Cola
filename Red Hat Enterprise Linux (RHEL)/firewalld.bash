#!/bin/bash

# Script de Configuração do Firewalld para Servidor Fedora
# Este script configura o firewalld com serviços e portas comuns para um servidor Fedora.
# IMPORTANTE: Revise cuidadosamente cada regra antes de aplicar para garantir que atenda às suas necessidades de segurança.

# Ativar firewalld
# Isso garante que o firewalld esteja rodando e configurado para iniciar no boot
echo "Ativando e habilitando o firewalld..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Adicionar serviços
# Cada serviço representa um conjunto predefinido de regras para aplicações específicas
echo "Adicionando serviços à zona FedoraServer..."
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=cockpit        # Interface web para administração do sistema
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=custom--8008   # Serviço personalizado na porta 8008
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=dhcpv6-client  # Cliente DHCPv6 para configuração de IP automática
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=http           # Tráfego web não criptografado (porta 80)
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=https          # Tráfego web criptografado (porta 443)
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=jellyfin       # Servidor de mídia Jellyfin
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=mountd         # Serviço de montagem NFS
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=nfs            # Network File System
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=rpc-bind       # Remote Procedure Call bind
sudo firewall-cmd --zone=FedoraServer --permanent --add-service=ssh            # Secure Shell para acesso remoto

# Adicionar portas
# Abrindo portas específicas para serviços que não têm um serviço predefinido
echo "Adicionando portas à zona FedoraServer..."
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=80/tcp    # HTTP alternativo
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=443/tcp   # HTTPS alternativo
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=3306/tcp  # MySQL/MariaDB
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=5432/tcp  # PostgreSQL
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=18000/tcp # Porta personalizada (ajuste conforme necessário)
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=2049/tcp  # NFS
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=111/tcp   # RPC
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=8080/tcp  # Proxy HTTP alternativo
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=4040/tcp  # Porta personalizada (ajuste conforme necessário)
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=32400/tcp # Plex Media Server
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=5201/tcp  # iPerf3 (teste de rede)
sudo firewall-cmd --zone=FedoraServer --permanent --add-port=5201/udp  # iPerf3 (teste de rede UDP)

# Recarregar as regras do firewalld
# Isso aplica todas as mudanças feitas
echo "Recarregando as regras do firewalld..."
sudo firewall-cmd --reload

# Verificar a configuração
# Lista todas as regras aplicadas para revisão
echo "Verificando a configuração atual..."
sudo firewall-cmd --zone=FedoraServer --list-all

# Comandos úteis para manutenção (comentados para referência futura)
echo "Comandos úteis para manutenção (para uso futuro):"
echo "# Listar zonas ativas:"
echo "# sudo firewall-cmd --get-active-zones"
echo "# Listar todas as regras na zona FedoraServer:"
echo "# sudo firewall-cmd --zone=FedoraServer --list-all"

# Exemplo de teste com regras temporárias (comentado para segurança)
echo "# Para testar regras temporárias (não permanentes), você pode usar:"
echo "# sudo firewall-cmd --zone=FedoraServer --add-rich-rule='rule family=\"ipv4\" source address=0.0.0.0/0 accept'"
echo "# E para remover:"
echo "# sudo firewall-cmd --zone=FedoraServer --remove-rich-rule='rule family=\"ipv4\" source address=0.0.0.0/0 accept'"

# Examinando logs (comentado para referência)
echo "# Para examinar os logs do firewalld, use:"
echo "# sudo journalctl -u firewalld"

echo "Configuração do firewall concluída. Por favor, revise as regras aplicadas acima."