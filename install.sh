#! /bin/bash
set -e

DIR="$(dirname "$(readlink -f -- "${0}")")"
cd "$DIR"
export PATH=~/.local/bin/:$PATH

# Update package list
sudo apt-get update

# Install minimal python requirements
sudo apt-get install -y \
    python-minimal \
    python-pip

# Install ansible
pip install ansible 

# Fix permissions
find . -type d -exec chmod 775 {} \;
find . -type f -exec chmod 644 {} \;

# Run ansible
cd ansible 
chmod +x run.sh
./run.sh
