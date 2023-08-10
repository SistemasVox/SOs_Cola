#!/bin/bash

# Verificar se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 
   exit 1
fi

# Criar o usuário "marcelo"
useradd marcelo

# Definir a senha para "marcelo"
echo "Por favor, insira a senha para o usuário 'marcelo':"
passwd marcelo

# Adicionar "marcelo" ao grupo "wheel"
usermod -aG wheel marcelo

# Verificar se o grupo "wheel" está configurado corretamente no sudoers
WHEEL_CONFIG=$(grep '^%wheel' /etc/sudoers | grep 'ALL=(ALL)')

if [[ -z "$WHEEL_CONFIG" ]]; then
  echo "Adicionando configuração do grupo 'wheel' ao arquivo sudoers..."
  echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers
else
  echo "A configuração do grupo 'wheel' já está correta."
fi

echo "Usuário 'marcelo' criado e configurado com sucesso."