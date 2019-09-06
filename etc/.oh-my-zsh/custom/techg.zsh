export EDITOR=vim
export NCURSES_NO_UTF8_ACS=1

#EXPRESSVPN
alias vc='expressvpn connect'
alias vcs='expressvpn connect smart'
alias vd='expressvpn disconnect'
alias vs='expressvpn status'

#TMUXINATOR
alias mux=tmuxinator
. ~/.tmuxinator/tmuxinator.zsh

#VIM
alias v='vim'
alias vi='gvim'

##FUNCTIONS##
clean (){
    [[ -z "$1" ]] || sed '/^\s*#/d;/^$/d' "$1"
}
####

##DEBIAN##
#APT
alias ag='apt-get'
alias agi='apt install -y'
alias au='apt update'
alias auf='apt update && apt full-upgrade'
alias auu='apt update && apt upgrade'
####
