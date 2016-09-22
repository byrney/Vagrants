
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update && sudo apt-get install -y binutils gdm git xterm libxml2-dev xorg-dev gfortran
cd $HOME && git clone --recurse-submodules https://github.com/ESP-rCommunity/ESP-rSource.git ESP-rCentral
echo "vagrant ssh -c '  cd $HOME/ESP-rCentral && ./Install -d $HOME --X11 --gcc4 '"

