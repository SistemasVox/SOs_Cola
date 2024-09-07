#!/bin/sh
# ============================================================
# Tutorial para Criar Script de Limpeza de Logs e Arquivos .txt
# ============================================================

# ## Introdução:
# Esse script tutorial guiará você pelos passos para criar um script 
# que apaga todos os arquivos .log e .txt no diretório `/root/home/monitores/`
# quando o seu roteador iniciar.

# ### 1. Criação do Script:
# - Navegue até o diretório onde os scripts de inicialização estão localizados:

cd /etc/init.d/

# - Crie um novo arquivo de script chamado `limpa_logs.sh`:

touch limpa_logs.sh

# - Abra o arquivo para edição:

nano /etc/init.d/limpa_logs.sh

# ### 2. Conteúdo do Script:
# - Dentro do arquivo, insira o seguinte código:

#!/bin/sh /etc/rc.common
# Script para apagar arquivos .log e .txt na inicialização

START=99

start() {
    echo "Apagando arquivos .log e .txt do diretório /root/home/monitores/"
    rm -f /root/home/monitores/*.log /root/home/monitores/*.txt
}

# ### 3. Permissão de Execução:
# - Após salvar o arquivo, dê permissão de execução ao script:

chmod +x /etc/init.d/limpa_logs.sh

# ### 4. Habilitar o Script na Inicialização:
# - Para que o script seja executado automaticamente na inicialização, use o comando:

/etc/init.d/limpa_logs.sh enable

# ### 5. Verificação:
# - Agora, sempre que o roteador for reiniciado, os arquivos `.log` e `.txt` no diretório `/root/home/monitores/` serão apagados.

# **Fim do Tutorial**
# Para qualquer dúvida ou modificação, consulte este script! :)


Prompt:

"Crie um script Shell que sirva como tutorial interativo. O script deve conter comentários explicativos para cada passo, como em um guia, enquanto os comandos Shell reais devem estar prontos para execução. O tutorial deve guiar o usuário na criação e configuração de um script, alternando entre explicações em comentários e blocos de código executável."


nano /etc/init.d/limpa_logs.sh

#!/bin/sh /etc/rc.common
# Script para apagar arquivos .log e .txt na inicialização

START=99

start() {
    echo "Apagando arquivos .log e .txt do diretório /root/home/monitores/"
    rm -f /root/home/monitores/*.log /root/home/monitores/*.txt
}

chmod +x /etc/init.d/limpa_logs.sh

/etc/init.d/limpa_logs.sh enable
