#!/bin/bash


for pkg in postgresql-9.4 postgresql-client-9.4 ; do
    dpkg-query -l "$pkg" 2> /dev/null | grep -qE '^ii' || apt-get install -y "$pkg"
done

su --command 'createuser -s vagrant' postgres || echo "Vagrant user already exists?"
su --command 'createuser -s root' postgres || echo "Root user already exists?"

