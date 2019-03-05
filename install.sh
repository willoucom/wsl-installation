#! /bin/bash
set -e

DIR="$(dirname "$(readlink -f -- "${0}")")"
cd "$DIR"
export PATH=~/.local/bin/:$PATH

# Update linux
sudo apt-get update
sudo apt-get upgrade -y

# Install minimal python requirements
sudo apt-get install -y \
    python-minimal \
    python-pip

# Update pip and install ansible
pip install pip --upgrade
pip install ansible 

# Run ansible
cd ansible 
chmod +x run.sh
./run.sh
