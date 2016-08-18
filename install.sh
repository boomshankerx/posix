#!/usr/bin/env bash

#release=`lsb_release -r | egrep -o '[0-9]+.[0-9]+'`
#major=`echo ${release%.*}`
#minor=`echo ${release#*.}`
#echo $release
#echo $major
#echo $minor

home=`pwd`
echo $home
lsb_release -a

function install_config {
    echo "** Installing common scripts..."
    [ -d ~/scripts ] || mkdir ~/scripts
    [ -L ~/s ] || ln -s ~/scripts ~/s
    cp -r scripts/ ~/scripts/

    #SSH
    [ -d ~/.ssh ] || mkdir ~/.ssh
    cp common/conf/authorized_keys.txt ~/.ssh/authorized_keys

    #BASH
    echo "** Installing config files"
    touch ~/.bash_aliases
    sed -i /##CUSTOM##/,/####/d ~/.bash_aliases
    cat common/bash_aliases.txt >> ~/.bash_aliases
    sed -i /##DEBIAN##/,/####/d ~/.bash_aliases
    cat debian/bash_aliases.txt >> ~/.bash_aliases

    [ -f ~/.bashrc ]    || cp ubuntu/bashrc.txt ~/.bashrc
    [ -f ~/.gitconfig ] || cp common/gitconfig.txt ~/.gitconfig
    [ -f ~/.profile ]   || cp common/bash.profile.txt ~/.profile

    cp common/terminator-solarized/config ~/.config/terminator/
}

function install_base {
    echo "** Installing base software..."
    sudo apt-get -y install git 
    sudo apt-get -y install exuberant-ctags
    sudo apt-get -y install rsync
    sudo apt-get -y install sudo
    sudo apt-get -y install tmux

    if [[ -z $DISPLAY ]]; then
        sudo apt-get -y install vim-nox
    else
        sudo apt-get -y install gitk git-gui
        sudo apt-get -y install terminator
        sudo apt-get -y install vim-gtk
    fi
}

function install_chrome {
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
    sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
    sudo apt-get update 
    sudo apt-get install google-chrome-stable
}

function install_dev {
    echo "** Installing development packages..."
    sudo apt-get -y install csstidy
    sudo apt-get -y install tidy
}

function install_docker {
   curl -sSL https://get.docker.com/ | sh 
}

function install_gui {
    sudo apt-get -y install docky
    sudo apt-get -y install gnome-do
}

function install_net {
    echo "** Installing network packages..."
    sudo apt-get -y install wireshark
    sudo apt-get -y install kismet
    sudo apt-get -y install nmap
    sudo apt-get -y install zenmap
}

function sub_samba {
    # Samba
    echo "** Installing samba..."
    sudo apt-get install samba
    sudo apt-get install smbfs
    sudo apt-get install winbind
    sudo sed -i.bak 's/files mdns4_minimal/files wins mdns4_minimal/' /etc/nsswitch.conf
    sudo sed -i.bak 's/workgroup = .*/workgroup = TECHG/' /etc/samba/smb.conf
}   

function install_vmware {
    #sudo apt-get install dkms build-essential
    sudo apt-get -y install open-vm-tools 
    if [[ -n $DISPLAY ]]; then
        sudo apt-get -y install open-vm-tools-desktop 
    fi
}

function install_zsh {
    sudo apt-get -y install zsh
    sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    #sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    touch ~/.oh-my-zsh/custom/techg.zsh
    sed -i /##DEBIAN##/,/####/d ~/.oh-my-zsh/custom/techg.zsh
    cat conf/debian/bash_aliases.txt >> ~/.oh-my-zsh/custom/techg.zsh
}

function init {
    install_base
    install_zsh
    install_config
}

# PROCESS ARGUMENTS

function showhelp {
    echo "USAGE install.ubuntu [-u] [options]
    Options
    =======
    base    : base packages
    chrome  : configure chrome ppa and install
    config  : base configuration
    dev     : development packages
    docker  : install docker
    init    : run base, bash, zsh
    net     : network tools
    vmware  : install vmware tools
    zsh     : install oh-my-zsh"
}

if [ "$1" == "-u" ]; then
    sudo apt-get update
fi

[ $# == 0 ] && showhelp
for arg in $@
do
    case $arg in
        "base")       install_base;;
        "chrome")     install_chrome;;
        "config")     install_config;;
        "dev")        install_dev;;
        "docker")     install_docker;;
        "init")       init;;
        "net")        install_net;;
        "vmware")     install_vmware;;
        "zsh")        install_zsh;;
    esac
done

