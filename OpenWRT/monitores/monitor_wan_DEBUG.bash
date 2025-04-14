# # 1) Lista todas as interfaces conhecidas pelo kernel
# ls /sys/class/net

# # 2) Verifica se existe diretório pra eth0.2 (pode ser eth0.2@eth0 também)
# ls -l /sys/class/net | grep eth0.2

# # 3) Exibe detalhes da eth0.2 (se existir)
# ip -d link show eth0.2

# # 4) Testa ler contador de RX manualmente
# cat /sys/class/net/eth0.2/statistics/rx_bytes

# # 5) Testa ler contador de TX manualmente
# cat /sys/class/net/eth0.2/statistics/tx_bytes

# # 6) Roda uma medição simples de 3s pra ver se muda
# ini=$(cat /sys/class/net/eth0.2/statistics/rx_bytes); sleep 3; fim=$(cat /sys/class/net/eth0.2/statistics/rx_bytes); echo $(( (fim-ini)*8/3000000 ))" Mbit/s"

# # 7) Confere se o módulo VLAN está carregado
# lsmod | grep 8021q

# # 8) Se não tiver, carrega o módulo VLAN
# modprobe 8021q

# # 9) Lista todas as VLANs configuradas
# ip -d link show type vlan

# # 10) Vê logs do kernel pra mensagens sobre eth0.2
# dmesg | grep -i eth0.2
