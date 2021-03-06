export EDITOR=vim
export NCURSES_NO_UTF8_ACS=1

# COMMON
alias c=cat
alias df='df -h'
alias du='du -hc'
alias e=echo

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
alias aar='sudo apt autoremove'
alias ag='sudo apt'
alias ai='sudo apt install -y'
alias au='sudo apt update'
alias auf='sudo apt update && sudo apt full-upgrade -y'
alias auu='sudo apt update && sudo apt upgrade -y'
####
