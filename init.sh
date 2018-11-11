# Variables
OPERATOR_VERSION=1.13.0

# Install key yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

# Install dependencies
sudo apt-get update
sudo apt-get -y install git

# Install n
# TODO(ca): check below error
curl -L https://git.io/n-install | bash

# Install node 8.12.0 version
n 8.12.0 # -> init.sh:3: init.sh: n: not found (check /home/pi/n folder)

# Install dependencies
sudo apt-get -y install tmux zsh yarn autoconf rpi-update vim neovim yarn jq

# Refresh bashrc file
source .bashrc

# Install ohmyzsh
# TODO(ca): add n script to .zshrc file
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Create ssh key for use in github
ssh-keygen -t rsa -b 4096 -C "wisebot@wisegrowth.app"

# Enable sudo with node and npm
sudo ln -s "/home/pi/n/bin/node" "/usr/local/bin/node"
sudo ln -s "/home/pi/n/bin/npm" "/usr/local/bin/npm"

# To use wisebot-ble without sudo
sudo setcap cap_net_raw+eip $(eval readlink -f `which node`)

# Refresh bashrc file
source .bashrc

# Create wisebot folders
mkdir .config
mkdir .config/wisebot
mkdir .config/wisebot/logs
mkdir .config/wisebot-core
mkdir .config/wisebot-tunnel
mkdir .config/wisebot-storage
mkdir .wisebot
mkdir .wisebot/logs

# Create base wisebot file
touch .config/wisebot/config.json
echo "{}" > .config/wisebot/config.json

# Create log files
touch .wisebot/logs/ble.log
touch .wisebot/logs/button.log
touch .wisebot/logs/core.log
touch .wisebot/logs/led.log
touch .wisebot/logs/network-operator.log
touch .wisebot/logs/operator.log
touch .wisebot/logs/script.log
touch .wisebot/logs/ssh-tunnel.log
touch .wisebot/logs/storage.log
touch .wisebot/logs/storage-tunnel.log

# Download latest operator version
# TODO: check this file exists
wget https://s3.us-west-2.amazonaws.com/wisebot-operator-releases/operator-1.13.0

# Change operator binary name
# TODO(ca): check this file exists
mv ./operator-1.13.0 ./operator
chmod +x operator

# Download latest wisebot-script version
# TODO(ca): should use ssh git repo
git clone https://github.com/wisegrowth/wisebot-script.git

# Run wisebot-script
# TODO(ca): should call command without
sudo ./wisebot-script/wisebot-script

# Remove wisebot-script folder
rm -rf ./wisebot-script

# Reloading services
sudo systemctl daemon-reload

# Create Wisebot, get result values and save this in config.json file
curl -H 'Content-Type: application/json' \
    -X POST https://wg-api-production.wisegrowth.app/wisebots?userId=admin \
    -d '{"type": "wisebot-grow-v1"}' | jq '{id: .meta.wisebot.id, keys: .meta.wisebot.keys, ble: .meta.wisebot.ble}' > created_config.json

# Merge created wisebot config file with wisebot system .config/wisebot/config.json
jq -s '.[0] * .[1]' created_config.json .config/wisebot/config.json > .config/wisebot/new_config.json

# Remove created wisebot config.json file
rm created_config.json

# Change SSH port to 5555
sudo cat /etc/ssh/sshd_config | sed 's/\#Port\ 22/Port\ 5555/g' > /etc/ssh/sshd_config

# Parse config.json cammelcase to snake case
cat .config/wisebot/new_config.json | \
    sed 's/publicKey/public_key/g' | \
    sed 's/privateKey/private_key/g' | \
    sed 's/certificateId/certificate_id/g' | \
    sed 's/getNetworksUUID/get_networks_UUID/g' | \
    sed 's/closeConnectionUUID/close_connection_UUID/g' | \
    sed 's/setNetworkUUID/set_network_UUID/g' | \
    sed 's/serviceUUID/service_UUID/g' > .config/wisebot/config.json

# Remove temporal config file
rm .config/wisebot/new_config.json

# Enabling services
sudo systemctl enable led
sudo systemctl enable operator
sudo systemctl enable network-operator
sudo systemctl enable storage-tunnel
sudo systemctl enable ssh-tunnel
sudo systemctl enable button

# Reboot SO
sudo reboot now