#!/bin/bash

set -euo pipefail

readonly jdk='jdk-10.0.2'
readonly jdkdir="/usr/local/jdk"
readonly jdkurl="http://download.oracle.com/otn-pub/java/jdk/10.0.2+13/19aef61b38124481863b1413dce1855f/${jdk}_linux-x64_bin.tar.gz"
readonly matsim='matsim-0.10.1'
readonly matsimurl="https://github.com/matsim-org/matsim/releases/download/$matsim/$matsim.zip"
readonly matsimdir='/home/vagrant/'
function install_tools(){
    apt-get install -yq curl unzip xorg
}

function install_jdk(){
    # curl -L -b "oraclelicense=a" -O 'http://download.oracle.com/otn-pub/java/jdk/10.0.2+13/19aef61b38124481863b1413dce1855f/jdk-10.0.2_linux-x64_bin.tar.gz'
    [[ -f "$HOME/$jdk.tgz" ]] || curl -sSL -b "oraclelicense=a" -o "$HOME/$jdk.tgz" "$jdkurl"
    mkdir -p "$jdkdir"
    [[ -e "$jdkdir/$jdk/javac" ]] || tar zxf "$HOME/$jdk.tgz" -C "$jdkdir"
    update-alternatives --install "/usr/bin/java" "java" "$jdkdir/$jdk/bin/java" 1500
    update-alternatives --install "/usr/bin/javac" "javac"   "$jdkdir/$jdk/bin/javac" 1500
    update-alternatives --install "/usr/bin/javaws" "javaws" "$jdkdir/$jdk/bin/javaws" 1500
}

function install_matsim(){
    [[ -f "$HOME/$matsim.zip" ]] || curl -sSL -o "$HOME/$matsim.zip"  "$matsimurl"
    [[ -d "$matsimdir/$matsim" ]] || unzip "$matsim.zip"
}


install_tools
install_jdk
install_matsim
