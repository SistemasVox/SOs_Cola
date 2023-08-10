#!/bin/bash

# Caminho para o arquivo de configuração do PAM do Cockpit
PAM_CONFIG="/etc/pam.d/cockpit"

# Verificar se o script está sendo executado como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script deve ser executado como root" 
   exit 1
fi

# Verificar se o arquivo existe
if [ ! -f "$PAM_CONFIG" ]; then
  echo "Arquivo $PAM_CONFIG não encontrado!"
  exit 1
fi

# Fazer um backup do arquivo original
cp "$PAM_CONFIG" "$PAM_CONFIG.bak"
echo "Backup do arquivo original criado como $PAM_CONFIG.bak"

# Verificar se a linha já está comentada
if grep -q "# auth       required     pam_listfile.so item=user sense=deny file=/etc/cockpit/disallowed-users onerr=succeed" "$PAM_CONFIG"; then
  echo "A configuração já está atualizada."
  exit 0
fi

# Comentar a linha na configuração do PAM
sed -i 's/auth       required     pam_listfile.so item=user sense=deny file=\/etc\/cockpit\/disallowed-users onerr=succeed/# &/' "$PAM_CONFIG"

# Reiniciar o Cockpit
systemctl restart cockpit

echo "Configuração do Cockpit atualizada com sucesso."
