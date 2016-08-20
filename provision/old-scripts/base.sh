#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if grep -vq London /etc/timezone ; then
    echo "Europe/London" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata
fi


[[ -f /vagrant/sources.list ]] && cp -f /vagrant/sources.list /etc/apt/
if [[ ! -f /tmp/apt_update.done ]] ; then
    apt-get update > /tmp/apt_update.done
fi



for pkg in git vim tmux silversearcher-ag zip ; do
    dpkg-query -l $pkg 2> /dev/null | grep -qE '^ii' || apt-get install -y $pkg
done
