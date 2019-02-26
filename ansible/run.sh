#! /bin/bash
set -e

DIR="$(dirname `readlink -f -- ${0}`)"
cd $DIR

export PATH=~/.local/bin/:$PATH

ansible-galaxy install --roles-path galaxy -r requirements.yml
ansible-playbook playbook.yml
