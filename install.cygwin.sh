#!/bin/bash
#cygwin

function install_bash {
    # Setup bashrc
    echo "** Configuring bash..."
    #[[ -z `grep "LC_COLLATE" /etc/profile` ]] && echo 'export LC_COLLATE=C' | sudo tee -a /etc/profile
    touch ~/.bash_aliases
    sed -i '/##CUSTOM##/,/####/d' ~/.bash_aliases
    cat conf/bash.aliases.txt >> ~/.bash_aliases
    sed -i '/##CYGWIN##/,/####/d' ~/.bash_aliases
    cat conf/cygwin.aliases.txt | tee -a ~/.bash_aliases
    sed -i '/##CYGWIN##/,/####/d' ~/.profile
    cat conf/cygwin.profile.txt | tee -a ~/.profile
    sed -i '/##CYGWIN##/,/####/d' ~/.bash_profile
    cat conf/cygwin.profile.txt | tee -a ~/.bash_profile

    [ -f ~/.bashrc ] || cp conf/bash.bashrc.txt ~/.bashrc
    [ -f ~/.profile ] || cp conf/bash.profile.txt ~/.profile

    [ -L ~/r ] || ln -s /cygdrive/r/ ~/r
    [ -L ~/w ] || ln -s /cygdrive/w/ ~/work
    [ -L ~/dropbox ] || ln -s /cygdrive/c/Users/lorne/Dropbox/ ~/dropbox
}

# PROCESS ARGUMENTS

function showhelp {
    echo "USAGE install.ubuntu [-u] [options]
    Options
    =======
    bash    : bash configuration
    "
}

if [ "$1" == "-u" ]; then
    sudo apt-get update
fi

[ $# == 0 ] && showhelp
for arg in $@
do
    case $arg in
        "bash")       install_bash;;
    esac
done

