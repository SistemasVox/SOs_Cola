#AssaultCube <============================
# O erro indica que o comando make não está sendo encontrado. Isso significa que você precisa instalar o pacote base-devel, que contém as ferramentas de compilação necessárias.

sudo pacman -S base-devel
pamac build assaultcube-client
#Unico comando.
sudo pacman -S base-devel assaultcube-client

#XFCE plugins <============================
sudo pamac install xfce4-*-plugin
sudo pamac install -S xfce4-*-plugin

#Memoria Swap <============================
# Descubra o UUID da sua partição swap. Você pode fazer isso com o comando lsblk -f ou blkid. Suponha que sua partição swap tenha o UUID XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX.
sudo lsblk -f
sudo nano /etc/fstab
UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX none swap defaults 0 0
UUID=9575a928-d41d-4481-95eb-1485fe3c1a5e none swap defaults 0 0

#Pamac AUR (Arch User Repository)  <============================
# O erro que você está enfrentando ao executar sudo pamac update --force-refresh parece estar relacionado a problemas na leitura dos dados do AUR (Arch User Repository) pelo Pamac.

# Limpe o cache do Pamac:
sudo rm -r /var/cache/pamac

# Atualize a lista de pacotes e o Pamac:
sudo pamac update --force-refresh
sudo pamac upgrade

# Suporte aos Flatpaks no Manjaro  <============================
sudo pacman -S flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.gimp.GIMP
flatpak run org.gimp.GIMP
# Sinta-se à vontade para instalar e testar outros aplicativos Flatpak do Flathub. A lista completa está disponível no site Flathub: https://flathub.org/apps

echo $XDG_DATA_DIRS
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/marcelo/.local/share/flatpak/exports/share"

# AUR (Arch User Repository) usando o yay, que é um AUR helper.  <============================
sudo pacman -S yay
yay -S whatsapp-for-linux

# GRUB_DEFAULT  <============================
sudo nano /etc/default/grub
GRUB_DEFAULT="3"
sudo update-grub

# JDK (Java Development Kit)  <============================
sudo pacman -S jdk-openjdk
export JAVA_HOME=/usr/lib/jvm/default
export PATH=$PATH:$JAVA_HOME/bin
source ~/.bashrc   # ou source ~/.zshrc se estiver usando o Zsh

sudo pamac build android-studio

# Code::Blocks  <============================
sudo yay -S xterm
# Vá para "Settings" (Configurações) no menu principal e escolha "Environment" (Ambiente).
xfce4-terminal -x
# Ou
sudo pacman -S gnome-terminal
gnome-terminal -x

