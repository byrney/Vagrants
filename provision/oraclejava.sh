#!/bin/bash

#
# Install oracle java
#  from here:  http://www.webupd8.org/2012/06/how-to-install-oracle-java-7-in-debian.html
#

lst=/etc/apt/sources.list.d/ppa.sources.list
if [[ ! -f "$lst" ]] ; then
    echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" > $lst
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> $lst
    apt-get update
fi

for pkg in oracle-java7-installer ; do
    dpkg-query -l $pkg &> /dev/null || apt-get install -y $pkg > /dev/null
done


