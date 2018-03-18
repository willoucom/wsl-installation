#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# function
asksure() {
echo -n "Are you sure (Y/N)? "
while read -r -n 1 -s answer; do
  if [[ $answer = [YyNn] ]]; then
    [[ $answer = [Yy] ]] && retval=0
    [[ $answer = [Nn] ]] && retval=1
    break
  fi
done

echo # just a final linefeed, optics...

return $retval
}

# get os version
OS=`. /etc/os-release; echo $ID`

echo "This will install some tools into your WSL ${OS}"
if asksure; then
  echo "Installation"
else
  exit 1
fi

# update linux
apt-get update
apt-get upgrade -y

echo "***** Install Basic Tools *****"
apt-get install -y \
  curl \
  git \
  lsb-release \
  unzip \
  wget \
  zsh 

# Install docker 
if ! which docker > /dev/null; then
  echo "***** Docker Installation *****"
  apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg2 \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/${OS}/gpg | apt-key add -
  add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/${OS} \
   $(lsb_release -cs) \
   stable"
  apt-get update
  apt-get install -y docker-ce docker-compose
fi

# Add to sudoers without password
echo "%sudo   ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo

# Create starter script
echo "***** Starter script Installation *****"
cat > /home/${SUDO_USER}/.wsl-starter <<- EOM
echo "Starting, please wait..."
# Export docker host for docker for windows
export DOCKER_HOST=tcp://0.0.0.0:2375

# Bind custom mount points to fix Docker for Windows and WSL differences:
for f in /mnt/*; do
    if [ -d \$f ]; then
        f=\$(basename \$f)
        sudo mkdir -p /\$f
        sudo mount --bind /mnt/\$f /\$f
    fi
done

# Start zsh
if [ -t 1 ]; then
  clear
  exec zsh
fi
EOM
chown ${SUDO_USER}: /home/${SUDO_USER}/.wsl-starter

# Add starter script to .bashrc
if ! grep wsl-starter /home/${SUDO_USER}/.bashrc > /dev/null; then
  echo "***** Install Starter Script *****"
  cat >> /home/${SUDO_USER}/.bashrc <<- EOM
if [ -f ~/.wsl-starter ]; then
  . ~/.wsl-starter
fi
EOM
fi

if [ ! -d /home/${SUDO_USER}/.oh-my-zsh ]; then
  echo "***** OhMyZsh *****"
  sudo -u ${SUDO_USER} bash << EOF
curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
EOF
fi
