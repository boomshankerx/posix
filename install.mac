#!/bin/bash

home=`pwd`
echo $home

function install_brew {
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew install caskroom/cask/brew-cask
}

function install_apps {
    brew install bash-completion
    brew install git
    brew install macvim
    brew install markdown
    brew install vim

    brew cask install bettertouchtool
    brew cask install caffeine
    brew cask install dropbox
    brew cask install evernote
    brew cask install google-drive
    brew cask install iterm2
    brew cask install keepassx
    brew cask install quicksilver
    brew cask install teamviewer
    brew cask install textexpander
    brew cask install thunderbird
    brew cask install tunnelblick
    brew cask install vlc
}

function install_settings {
# Setup bash
	echo "*** Writing general settings..."
	touch ~/.bash_aliases
	sed -i '' /##CUSTOM##/,/####/d ~/.bash_aliases
	cat conf/bash.aliases.txt >> ~/.bash_aliases
	sed -i '' /##MAC##/,/####/d ~/.bash_aliases
    cat conf/mac.bash_aliases.txt >> ~/.bash_aliases

    cp -v conf/mac.bash_profile.txt ~/.bash_profile
    cp -v conf/mac.bashrc.txt ~/.bashrc

    cp -v conf/gitconfig.txt ~/.gitconfig
}

function install_vim {
    cd ../vim
    . install
    cd $home
}

#####################
# Process Arguments #
#####################

function showhelp {
	echo "The following commands are available...  
    apps     : Install common apps via brew
    brew     : Install homebrew and Brew Cask
    settings : Install bash settings
    vim      : Install vim settings
    "
}


[ $# == 0 ] && showhelp
for arg in $@
do
	case $arg in
        "apps"     ) install_apps;;
        "brew"     ) install_brew;;
		"settings" ) install_settings;;
        "vim"      ) install_vim;;
	esac
done
