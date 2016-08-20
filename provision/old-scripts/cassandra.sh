#!/bin/bash

function setup() {

    #
    # Install cassandra from datastax
    #
    lst=/etc/apt/sources.list.d/cassandra.sources.list
    if [[ ! -f "$lst" ]] ; then
        curl --silent -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
        echo "deb http://debian.datastax.com/community stable main" > "$lst"
        apt-get update
    fi

    for pkg in dsc30 ; do
        dpkg-query -l $pkg &> /dev/null || apt-get install -y $pkg
    done

}

setup
