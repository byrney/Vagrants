#!/bin/bash

for pkg in xorg dwm ; do
	dpkg-query -l $pkg 2> /dev/null | grep -E '^ii' || apt-get install -y $pkg
done
