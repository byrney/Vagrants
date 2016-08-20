#!/bin/bash

for pkg in nodejs npm ; do
	dpkg-query -l $pkg 2> /dev/null | grep -qE '^ii' || apt-get install -y $pkg
done

if [[ ! -f /usr/bin/node ]] ; then
    ( cd /usr/bin && ln -s nodejs node )
fi


