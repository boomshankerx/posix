export EDITOR=vim
export NCURSES_NO_UTF8_ACS=1

#
# ALIASES
#

# COMMON
alias c=cat
alias df='df -h'
alias du='du -hc'
alias du1='du -hcd1 | sort -h'
alias e='echo'
alias lf='less +F'
alias psa='ps auxf'
alias x="clip"

# DEBIAN
alias ag='sudo apt'
alias ai='sudo apt install -y'
alias au='sudo apt update'
alias auf='sudo apt update && sudo apt full-upgrade -y'
alias aar='sudo apt autoremove -y'
alias auu='sudo apt update && sudo apt upgrade -y'
alias uuu='auf && aar'
alias sc='systemctl'

# EXPRESSVPN
alias vc='expressvpn connect'
alias vcs='expressvpn connect smart'
alias vd='expressvpn disconnect'
alias vs='expressvpn status'

# SUBLIME TEXT
alias sb=subl

# TMUXINATOR
alias mux=tmuxinator
. ~/.tmuxinator/tmuxinator.zsh

# VIM
alias v='vim'
alias vi='gvim'

# HELP
alias help-git="alias | grep git"
alias help-tmux="less ~/.tmux.conf"

#
# FUNCTIONS
#

# Copy file to clipboard
clip() {
    if [[ -f $1 ]]; then
        cat $1
        cat $1 | xclip -selection clipboard
    fi
}

# Remove hash comments from file and output to stdout
decomment (){
    [[ -z "$1" ]] || sed '/^\s*#/d;/^$/d' "$1"
}

# Copy empty string to file
empty(){
    [[ -f "$1" ]] && echo '' > $1
}

tg-ip(){
    tg-ipfull | cut -d'|' -f1 | cut -d'/' -f1

}
tg-ipfull(){
  local dev=""
  dev="$(ip a | egrep -o '\btun[0-9]+' | head -1)"
  if [[ -z $dev ]]; then
      dev="$(ip a | egrep -o '\beth[0-9]+' | head -1)"
    if [[ -z $dev ]]; then
        dev="$(ip a | egrep -o '\bens[0-9]+' | head -1)"
    fi
  fi
  ip="$(ip a | grep $dev | grep inet | awk '{print $2}')|$dev"
  echo $ip
}

# Reset files and folders to default permissions
reset_permissions(){
    find . -type f -exec chmod 664 {} \; -print
    find . -type d -exec chmod 775 {} \; -print
}

# Mount disk image with multiple partitions on loop device
los() (
  img="$1"
  dev="$(sudo losetup --show -f -P "$img")"
  echo "$dev"
  for part in "$dev"?*; do
    if [ "$part" = "${dev}p*" ]; then
      part="${dev}"
    fi
    dst="/mnt/$(basename "$part")"
    echo "$dst"
    sudo mkdir -p "$dst"
    sudo mount "$part" "$dst"
  done
)

losd() (
  dev="/dev/loop$1"
  for part in "$dev"?*; do
    if [ "$part" = "${dev}p*" ]; then
      part="${dev}"
    fi
    dst="/mnt/$(basename "$part")"
    sudo umount "$dst"
  done
  sudo losetup -d "$dev"
)
