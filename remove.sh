# Restore SSH port
sudo cat /etc/ssh/sshd_config | sed 's/Port\ 5555/\#Port\ 22/g' > /etc/ssh/sshd_config #remove.sh: 2: remove.sh: cannot create /etc/ssh/sshd_config: Permission denied

# Remove log files
rm -rf .wisebot

# Remove wisebot files
rm -rf .config/wisebot
rm -rf .config/wisebot-core
rm -rf .config/wisebot-tunnel
rm -rf .config/wisebot-storage

# Remove operator binary
rm operator

# Remove n
rm -rf n

# Stoping wisebot services
sudo systemctl stop network-operator
sudo systemctl stop operator
sudo systemctl stop led
sudo systemctl stop ssh-tunnel
sudo systemctl stop storage-tunnel

# Remove wisebot daemons
sudo rm /lib/systemd/system/network-operator.service
sudo rm /lib/systemd/system/operator.service
sudo rm /lib/systemd/system/led.service
sudo rm /lib/systemd/system/ssh-tunnel.service
sudo rm /lib/systemd/system/storage-tunnel.service

# Remove wisebots services
sudo rm -rf wisebot-ble
sudo rm -rf wisebot-core
sudo rm -rf wisebot-script
sudo rm -rf wisebot-button
sudo rm -rf wisebot-storage
sudo rm -rf wisebot-cli
sudo rm -rf wisebot-led-indicator
sudo rm -rf wisebot-tunnel
sudo rm -rf network-operator