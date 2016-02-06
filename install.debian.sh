#!/usr/bin/env bash

function init {
    #ALIASES
	touch ~/.bash_aliases
	sed -i /##CUSTOM##/,/####/d ~/.bash_aliases
	cat conf/bash.aliases.txt >> ~/.bash_aliases
	sed -i /##DEBIAN##/,/####/d ~/.bash_aliases
	cat conf/debian.aliases.txt >> ~/.bash_aliases

    #BASHRC
    cp conf/bashrc.default.txt ~/.bashrc
}

function install_base {
    sudo apt-get -y install ctags
    sudo apt-get -y install curl
    sudo apt-get -y install git
    sudo apt-get -y install rsync
    sudo apt-get -y install vim-nox
}

function install_docker {
   curl -sSL https://get.docker.com/ | sh 
}

function install_vmtools {
    sudo apt-get -y install dkms build-essential
}

function update {
    sudo apt-get update
}

function config_user {
    #add user to sudoers group
    useradd lorne
    usermod -aG sudo lorne 
}

# PROCESS ARGUMENTS

function showhelp {
	echo "Usage: install.debian [options]
	user
    vm
	"
}

if [[ $1 == "-u" || $1 == "--update" ]]; then
    update
fi

init;
install_base;

[ $# == 0 ] && showhelp
for arg in $@; do
    case $arg in
        "user")
            config_user;;
        "vm")
            install_vmtools;;
    esac
done
