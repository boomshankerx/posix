export EDITOR=vim
export NCURSES_NO_UTF8_ACS=1

#
# ALIASES
#

# COMMON
alias b=bat
alias c=cat
alias df='df -h'
alias du1='du -hcd1 | sort -h'
alias du='du -hc'
alias e='echo'
alias free="free -h"
alias gogh='bash -c  "$(wget -qO- https://git.io/vQgMr)"'
alias j='jobs'
alias jk='kill %'
alias lf='less +F'
alias nv='nvim'
alias psa='ps auxf'
alias pw='pwgen -s 16 1'
alias pw32='pwgen -s 32 1'
alias r='sudo -E vim'
alias rs="sudo xrandr --output Virtual-1 --auto"
alias sb=subl
alias se='sudo -E'
alias v='vim'
alias vi='gvim'
alias vr='sudo -E vim'
alias x="clip"
alias xc='xclip -selection clipboard'

# DEBIAN
alias ag='sudo apt'
alias ai='sudo apt install -y'
alias au='sudo apt update'
alias auf='sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y'
alias aar='sudo apt autoremove -y'
alias auu='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias uuu='auf && aar'
alias sc='sudo systemctl'
alias scdr='sudo systemctl daemon-reload'

# DOCKER
alias dcit='docker compose exec -it'
alias dcupl='docker compose up -d && docker compose logs -f'
alias dc='docker compose'
alias de='docker exec -it'
alias dip='docker image prune'
alias dipa='docker image prune -a'
alias dpsl='docker ps --format "table {{.ID}}\t{{.Names}}" | tail -n +2 | sort -k2'
alias dpsp='docker ps --format "table {{.Names}},{{.Ports}}"'
alias dpss='docker ps | less -S'
dpspp (){
    dpsp | awk -F'[ ,]' '/->/{split($1, name, ","); container=name[1]; for(i=2; i<=NF; i++) if($i ~ /->/) {split($i, ports, "->"); split(ports[1], ext, ":"); port=ext[length(ext)]; if (!seen[container,port]++) ports_array[container] = ports_array[container] (ports_array[container]?",":"") port}} END {for (c in ports_array) print c ": " ports_array[c]}' | sort
}
alias bind-reload="docker exec -it bind9 rndc reload"

#FZF
export FZF_DEFAULT_COMMAND='find . -type f'
alias f='fzf'
alias fb='bat $(fzf)'
alias fc='cat $(fzf)'
alias fp='fzf --preview "bat {1}"'
alias fps='ps aux | fzf'
alias fv='fzf --print0 | xargs -0 -o vim -O'

#POSIX
alias pconf='~/posix/posix config'
alias psync='~/posix/posix sync'
alias px='posix'

# TMUX
alias mux=tmuxinator
alias ta='tmux attach -t'
alias xx='tmux kill-server'
. ~/.tmuxinator/tmuxinator.zsh

# HELP
alias help-git="alias | grep git"
alias help-tmux="less ~/.tmux.conf"

#
# FUNCTIONS
#

# Auto-activate when cd'ing into a directory with a venv
function cd() {
    builtin cd "$@"
    if [ -d ".venv" ]; then
        source .venv/bin/activate
    fi
}

# Copy file to clipboard
clip() {
    if [[ -f "$1" ]]; then
        printf '%s' "$(cat "$1")" | xclip -selection clipboard
        # cat "$1" | xclip -selection clipboard
        cat "$1"
    fi

}

# Remove hash comments from file and output to stdout
decomment (){
    [[ -z "$1" ]] || sed '/^\s*#/d;/^$/d' "$1"
}

# Copy empty string to file
empty(){
    [[ -f "$1" ]] && echo '' > "$1"
}

tg-ip-external(){
    ip=$(curl -s http://api.ipify.org)
    echo $ip
    echo $ip | xclip -selection clipboard
}

tg-ip(){
    tg-ipfull | cut -d'|' -f1 | cut -d'/' -f1
}

tg-ipdev(){
  dev=$1
  ip="$(ip a | grep $dev | grep inet | awk '{print $2}' | cut -d'/' -f1)"
  echo $ip
}

tg-ipfull(){
    local dev=""
    dev="$(ip a | egrep -o '\btun[0-9]+' | head -1)"
    if [[ -z $dev ]]; then
        dev="$(ip a | egrep -o '\bwg[0-9]+' | head -1)"
    fi
    if [[ -z $dev ]]; then
        dev="$(ip a | egrep -o '\beth[0-9]+' | head -1)"
    fi
    if [[ -z $dev ]]; then
        dev="$(ip a | egrep -o '\bens[0-9]+' | head -1)"
    fi
  ip="$(ip a | grep $dev | grep inet | awk '{print $2}')|$dev"
  echo $ip
}

# Reset files and folders to default permissions
reset_permissions(){
    find . -type f -exec chmod 664 {} \; -print
    find . -type d -exec chmod 775 {} \; -print
}
reset_owner(){
    sudo chown -R $USER:$USER .
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
