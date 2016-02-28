#!/bin/bash

user=${1:?"Username required"}
pubkey=${2:?"ssh public key required"}

# create the user if not exists
grep -q  "^$user:" /etc/passwd  || useradd -m --shell /bin/bash "$user" || exit 9

su "$user" <<EOF

if [[ ! -d /home/$user/.ssh ]] ; then
    echo "SSH Keys"
    ssh-keygen -q -f "/home/$user/.ssh/id_rsa" -P ""
fi
if [[ ! -f /home/$user/.ssh/authorized_keys ]] ; then
    echo "authorized_keys"
    echo "$pubkey" >> "/home/$user/.ssh/authorized_keys"
fi
if [[ ! -d /home/$user/Config ]] ; then
    cd "/home/$user" || exit 5
    git clone 'https://github.com/byrney/Config.git'
    cd "/home/$user/Config" || exit 9
    bash install.sh rob.cfg
    vim -T dumb +PluginInstall +qall | grep installed
fi
EOF

