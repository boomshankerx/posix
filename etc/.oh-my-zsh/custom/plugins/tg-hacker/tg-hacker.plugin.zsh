#!/usr/bin/env zsh

#
# VARIABLES
#

export CONF=~/.tg_hacker
export LIST_COMMON="/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt"
export LIST_MEDIUM="/usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"
export LIST_ROCK="/usr/share/wordlists/rockyou.txt"
export SECLISTS="/usr/share/wordlists/seclists"

#
# ALIASES
#

#alias s='sync'
alias f='focus'
alias hcat='h-hashcat'
alias hcatshow='hashcat --show'
alias hi='h-init'
alias hrock='hydra -VI -P $LIST_ROCK'
alias jrock='john --wordlist=$LIST_ROCK'
alias jshow='john --show'
alias msf=msfconsole
alias ngrok="/opt/ngrok http 80"
alias sshclean='ssh-keygen -R rhost'
alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias ve='me tun0'
alias vpn='sudo -b openvpn'
alias vpnkill='sudo pkill openvpn'
alias vpnshow='pgrep -a openvpn'

#
# GREP
#

alias grep-email='grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"'


#
# FUNCTIONS
#

add-host() {
    HOST=${1:="rhost"}
    IP=${2:-$RHOST}
    sudo sed -i /$HOST$/d /etc/hosts
    echo "$IP $HOST" | sudo tee -a /etc/hosts
}

base() {
    if [[ "$1" == "set" ]]; then
        BASE=$(pwd)
        sed -i "/^BASE=/d" $CONF
        echo "BASE=$BASE" >> $CONF
    fi
    echo $BASE
    cd $BASE
}

clip() {
    FILE=$1
    cat $FILE
    cat $FILE | xclip -selection c
}


# Select target ip:port
focus() {
    IP=${1:-"EMPTY"}
    PORT=${2:-"EMPTY"}
    # Set shell variables
    [[ "$IP" != "EMPTY" ]] && export RHOST="$IP"
    [[ "$PORT" != "EMPTY" ]] && export RPORT="$PORT"
    # Add target to hosts file as rhost replacing as necessary
    add-host
    # Add variables to sync $CONF file 
    sed -i "/export RHOST=*/d" $CONF
    echo "export RHOST=$RHOST" >> $CONF
    sed -i "/export RPORT=*/d" $CONF
    echo "export RPORT=$RPORT" >> $CONF
}

play() {
    CMD=${1:-"info"}
    if [[ $CMD == "info" ]]; then
        cat ~/.oh-my-zsh/custom/plugins/tg-hacker/commands | cut -d "#" -f 1
        return
    fi
    eval $(grep "$CMD" ~/.oh-my-zsh/custom/plugins/tg-hacker/commands | cut -d "#" -f 2 )
} 

# Set local callback port
lport() {
    LPORT=${1:-"4444"} 
    if [[ -f $CONF ]]; then
        sed -i "/export LPORT=*/d" $CONF
        echo "export LPORT=$LPORT" >> $CONF
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
    if [[ -f $CONF ]]; then
        sed -i "/export LHOST=*/d" $CONF
        echo "export LHOST=$LHOST" >> $CONF
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

# Sync env variables from $CONF file
sync() {
    if [[ ! -f $CONF ]]; then
        h-init
    fi
    cat $CONF
    . $CONF
    . ~/.oh-my-zsh/custom/plugins/tg-hacker/tg-hacker.plugin.zsh
    cd $BASE
}

#
# HAK FUNCTIONS
#

# Initialize ctf folder
h-init() {
    BASE=${1:-$(pwd)}
    [[ -d $BASE ]] || mkdir -p $BASE
    cd $BASE
    BASE=$(pwd)
    echo "#!/usr/bin/env zsh" > $CONF 
    echo "BASE=$BASE" >> $CONF
    echo "export LPORT=4444" >> $CONF
    ve
    touch notes.txt
}

h-enum4linux() {
    OUTPUT=enum4linux.$RHOST
    enum4linux-ng $RHOST -oA $OUTPUT 
}

h-ffuf(){
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    WORDLIST=${3:-$LIST_COMMON}
    OUTPUT=ffuf.$IP-$PORT.txt
    touch $OUTPUT
    ffuf -w $WORDLIST -u http://$HOST:$PORT/FUZZ -o $OUTPUT -of csv -c 
}

h-gobuster(){
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    WORDLIST=${3:-$LIST_COMMON}
    OUTPUT=gobuster.$IP-$PORT.txt
    touch $OUTPUT
    echo "gobuster dir -t 50 -o $OUTPUT -w $WORDLIST -u http://$HOST:$PORT -x html,php,txt,js,css,py"
    gobuster dir -t 50 -o $OUTPUT -w "$WORDLIST" -u http://"$HOST":"$PORT" -x html,php,txt,js,css,py
}

h-hashcat() {
    ATTACK=${1:-0}
    MODE=${2:-0}
    HASHES=${3:-hashes.txt}
    WORDLIST=${4:-"$LIST_ROCK"}
    OUTPUT="hashcat.txt"
    echo "hashcat -a $ATTACK -m $MODE -o $OUTPUT $HASHES $WORDLIST"
    hashcat -a $ATTACK -m $MODE -o $OUTPUT $HASHES $WORDLIST
}

h-hashcatshow() {
    ATTACK=${1:-0}
    MODE=${2:-0}
    HASHES=${3:-"hashes.txt"}
    WORDLIST=${4:-"$LIST_ROCK"}
    OUTPUT="hashcat.txt"
    echo "hashcat --show -m $MODE $HASHES"
    hashcat --show -m $MODE $HASHES
}

h-ssh() {
    sshclean
    ssh "$@"
}

h-web() {
    PORT=${1:-80}
    IP=${2:-$RHOST}
    OUTPUT=nikto.txt
    touch $OUTPUT
    whatweb -v -a 3 "$IP:$PORT" | tee whatweb.txt 
    nikto -host "$IP" -port "$PORT" -output $OUTPUT -Format txt
}

#
# NMAP
#

alias nmap-="sudo nmap -v -Pn -n -T4"
alias nmap-arp="sudo nmap -v -n -sn -PR"
alias nmap-basic-all="sudo nmap -v -Pn -n -T4 -p- -oN nmap.basic.all.txt"
alias nmap-basic="sudo nmap -v -Pn -n -T4 -oN nmap.basic.txt"
alias nmap-discover="sudo nmap -v -sn"
alias nmap-full-all="sudo nmap -v -n -T4 -A -p- -oN nmap.full.all.txt"
alias nmap-full="sudo nmap -v -n -T4 -A -oN nmap.full.txt"
alias nmap-script-all="sudo nmap -v -Pn -n -T4 -sC -sV -p- -oN nmap.script.all.txt"
alias nmap-script="sudo nmap -v -Pn -n -T4 -sC -sV -oN nmap.script.txt"

nmap-ports(){
    IP=${1:-"$RHOST"}
    sudo nmap -v -Pn -T4 -oN nmap.ports.txt $IP 
    nmap-parse-ports
}

nmap-parse-ports() {
    FILE=${1:-"nmap.ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    sed -i "/^export RPORTS=*/d" $CONF
    echo "export RPORTS=$RPORTS" >> $CONF
    echo "RPORTS=$RPORTS"
}

#
# METASPLOIT
#

msf-handle() {
    payloads=("linux/x64/meterpreter/reverse_tcp" "linux/x64/shell_reverse_tcp" "linux/x86/meterpreter/reverse_tcp" "linux/x86/shell_reverse_tcp" "windows/meterpreter/reverse_tcp" "windows/x64/meterpreter/reverse_tcp")
    select PAYLOAD in "${payloads[@]}"; do
        echo "msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;'"
        msfconsole -x "use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;"
        break;
    done
}
