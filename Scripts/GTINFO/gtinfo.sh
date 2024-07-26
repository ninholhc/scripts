#!/bin/bash

# Informações
echo "GTINFO - SEMED"
echo "Desenvolvido por Aldenízio dos S. Silva"
echo "ti.semed.ssal@hotmail.com / ti.semed.ssal@gmail.com"
echo "gtinfosemed.ieducativa.com.br"

# Atualizar o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Definir senha para o usuário root
root_password="#G3st40d3t1$"  # substitua "sua_senha_secreta" pela senha desejada
echo "Definindo a senha para o usuário root..."
echo "root:$root_password" | sudo chpasswd

# Alterar o DNS da interface local
interface="eth0" # substitua pelo nome da sua interface, como 'eth0' ou 'ens33'
dns1="208.67.222.123"  # DNS primário
dns2="208.67.220.123"  # DNS secundário

echo "Alterando DNS para $dns1 e $dns2 na interface $interface..."
sudo bash -c "cat << EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  ethernets:
    $interface:
      dhcp4: yes
      nameservers:
        addresses:
          - $dns1
          - $dns2
EOF"

# Aplicar as configurações do netplan
sudo netplan apply

echo "Script concluído com sucesso!"
