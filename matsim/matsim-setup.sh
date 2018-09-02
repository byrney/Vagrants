#!/bin/bash

set -euo pipefail


function install_deps(){
    apt-get update && apt-get install -yq curl unzip xorg xfce4
}

function install_tools(){
    apt-get update && apt-get install -yq neovim nano tmux ntp
}

function install_jdk(){
    declare -r jdk='jdk1.8.0_181'
    declare -r jdkdir="/usr/local/jdk"
    declare -r jdkurl="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz"
    [[ -f "$HOME/$jdk.tgz" ]] || curl -sSL --fail -b "oraclelicense=a" -o "$HOME/$jdk.tgz" "$jdkurl"
    mkdir -p "$jdkdir"
    [[ -e "$jdkdir/$jdk/javac" ]] || tar zxf "$HOME/$jdk.tgz" -C "$jdkdir"
    update-alternatives --install "/usr/bin/java" "java" "$jdkdir/$jdk/bin/java" 1500
    update-alternatives --install "/usr/bin/javac" "javac"   "$jdkdir/$jdk/bin/javac" 1500
    update-alternatives --install "/usr/bin/javaws" "javaws" "$jdkdir/$jdk/bin/javaws" 1500
}

function install_matsim(){
    declare -r matsim='matsim-0.10.1'
    declare -r matsimurl="https://github.com/matsim-org/matsim/releases/download/$matsim/$matsim.zip"
    declare -r matsimdir='/home/vagrant/'
    [[ -f "$HOME/$matsim.zip" ]] || curl -sSL -o "$HOME/$matsim.zip"  "$matsimurl"
    [[ -d "$matsimdir/$matsim" ]] || unzip "$HOME/$matsim.zip" && chown -R vagrant:vagrant "/home/vagrant/$matsim"
}

function install_via(){
    declare -r via='Via-1.8.2'
    declare -r viaurl='https://www.simunto.com/data/via-1.8.2/via-linux.zip'
    [[ -f "$HOME/$via.zip" ]] || curl -sSL -o "$HOME/$via.zip" --fail "$viaurl"
    [[ -d "$via" ]] || unzip "$HOME/$via.zip" && chown -R vagrant:vagrant "/home/vagrant/$via"
}

install_deps && \
install_tools && \
install_jdk && \
install_matsim && \
install_via

