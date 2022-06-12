export EDITOR=vim
export NCURSES_NO_UTF8_ACS=1

#
# ALIAS
#

# APT
alias ag='sudo apt'
alias ai='sudo apt install -y'
alias au='sudo apt update'
alias auf='sudo apt update && sudo apt full-upgrade -y'
alias aur='sudo apt autoremove -y'
alias auu='sudo apt update && sudo apt upgrade -y'
alias uuu='auf && aur'
alias sc='systemctl'

# COMMON
alias c=cat
alias df='df -h'
alias du='du -hc'
alias e='echo'
alias lf='less +F'
alias psa='ps auxf'

# EXPRESSVPN
alias vc='expressvpn connect'
alias vcs='expressvpn connect smart'
alias vd='expressvpn disconnect'
alias vs='expressvpn status'

# SUBLIME TEXT
#alias sub=subl

# TMUXINATOR
alias mux=tmuxinator
. ~/.tmuxinator/tmuxinator.zsh

# VIM
alias v='vim'
alias vi='gvim'


#
# FUNCTIONS
#

# Remove hash comments from file and output to stdout
decomment (){
    [[ -z "$1" ]] || sed '/^\s*#/d;/^$/d' "$1"
}

# Copy file to clipboard
clip() {
    if [[ -f "$1" ]]; then
        cat "$1"
        cat "$1" | xclip -sel c
    fi
}

# Copy empty string to file
empty (){
    [[ -f "$1" ]] && echo '' > $1
}

# Reset files and folders to default permissions
reset_permissions(){
    find . -type f -exec chmod 664 {} \; -print
    find . -type d -exec chmod 775 {} \; -print
}

