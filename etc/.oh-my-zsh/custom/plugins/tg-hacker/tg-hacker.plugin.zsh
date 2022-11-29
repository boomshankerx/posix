#!/usr/bin/env zsh

#
# VARIABLES
#

export LIST_COMMON="/usr/share/wordlists/seclists/Discovery/Web-Content/common.txt"
export LIST_MEDIUM="/usr/share/wordlists/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"
export LIST_PW_100K="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-100000.txt"
export LIST_PW_10K="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-10000.txt"
export LIST_PW_1M="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-1000000.txt"
export LIST_ROCK="/usr/share/wordlists/rockyou.txt"
export LIST_SECLISTS="/usr/share/wordlists/seclists"
export TG_CONF=~/.tg_hacker

#
# ALIASES
#

#alias ngrok="ngrok http 80"
alias _strip='tr -d "[:space:]"'
alias f="focus"
alias hcat="tg-hashcat"
alias hcatshow="tg-hashcatshow"
alias hi="tg-init"
alias hrock="hydra -VI -P $LIST_ROCK"
alias jrock="john --wordlist=$LIST_ROCK"
alias jshow="john --show"
alias msf="msfconsole -x 'setg LHOST tun0;'"
alias p="~/.oh-my-zsh/custom/plugins/tg-hacker/play.py"
alias s='sync'
alias sshclean='ssh-keygen -R rhost && ssh'
alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias ve="me tun0"
alias vpn="sudo -b openvpn"
alias vpnkill="sudo pkill openvpn"
alias vpnshow="pgrep -a openvpn"
alias wesng="/opt/wesng/wes.py -c --definitions /opt/wesng/definitions.zip systeminfo.txt"
alias x="xclip -selection clipboard"

#
# FIND
#

alias find-cap="getcap -r / 2>/dev/null"
alias find-suid="find / -type f -perm -4000 -ls 2>/dev/null"
alias find-sgid="find / -type f -perm -2000 -ls 2>/dev/null"
alias find-sguid="find / -type f -perm /6000 -ls 2>/dev/null"
alias find-sudo="sudo -l"

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

del-host(){
    HOST="$1"
    sudo sed -i /$HOST$/d /etc/hosts
}

base() {
    if [[ "$1" == "set" ]]; then
        BASE=$(pwd)
        tg-setvar BASE "$BASE"
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
    # Add variables to sync $TG_CONF file 
    tg-setvar RHOST "$RHOST"
    tg-setvar RPORT "$RPORT"
}

# Set local callback port
lport() {
    LPORT=${1:-"4444"}
    tg-setvar LPORT "$LPORT"
    echo "LPORT: $LPORT"
}

listen() {
    [[ -n "$1" ]] && lport "$1"
    nc -lvnp $LPORT
}

listen-rlwrap(){
    [[ -n "$1" ]] && lport "$1"
    rlwrap nc -lvnp $LPORT
}

listen-file() {
    [[ -n "$1" ]] &&  nc -lvp $LPORT > $1
}

# Get ip address of local interface default: eth0
me() {
    iface=${1:-"eth0"}
    export LHOST=$(ifconfig $iface | grep "inet " | cut -b 9- | cut  -d" " -f2)
    echo -n $LHOST | xclip -selection clipboard
    echo "LHOST: $LHOST"
    tg-setvar LHOST "$LHOST"
}

# Copy rhost to clipboard
rhost() {
    echo -n $RHOST | xclip -selection clipboard
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

# Sync env variables from $TG_CONF file
sync() {
    . $TG_CONF
    . ~/.oh-my-zsh/custom/plugins/tg-hacker/tg-hacker.plugin.zsh
    cd $BASE
    clear
    [[ "$1" == "-v" ]] && cat $TG_CONF
}

#
# FUNCTIONS
#

tg-dirsearch(){
    IP=${1:-$RHOST}
    PORT=${2:-80}
    EXT=${3:-"php,html,txt"}
    WORDLIST=${4:-$LIST_MEDIUM}
    OUTPUT="$IP-$PORT-dirsearch.txt"
    touch $OUTPUT
    echo "dirsearch  -w \"$WORDLIST\" -o $(pwd)/$OUTPUT -u http://$IP:$PORT -e $EXT"
    dirsearch -w "$WORDLIST" -o $(pwd)/$OUTPUT -u http://$IP:$PORT -e $EXT
}

tg-enum4linux() {
    IP=${1:-$RHOST}
    OUTPUT="$IP-enum4linux"
    enum4linux-ng $IP -oY $OUTPUT 
}

tg-ffuf(){
    IP=${1:-$RHOST}
    PORT=${2:-80}
    WORDLIST=${3:-$LIST_MEDIUM}
    OUTPUT="$IP-$PORT-ffuf.txt"
    touch $OUTPUT
    ffuf -w $WORDLIST -t 40 -c -u http://$IP:$PORT/FUZZ -o $OUTPUT -of csv -recursion -recursion-depth 2
}

tg-gobuster(){
    IP=${1:-$RHOST}
    PORT=${2:-80}
    EXT=${3:-"php,html,txt"}
    WORDLIST=${4:-$LIST_MEDIUM}
    OUTPUT="$IP-$PORT-gobuster.txt"
    touch $OUTPUT
    echo "gobuster dir -t 40 -o $OUTPUT -w $WORDLIST -u http://$IP:$PORT -x $EXT"
    gobuster dir -t 40 -w "$WORDLIST" -o $OUTPUT -u http://$IP:$PORT -x $EXT
}

tg-hashcat() {
    ATTACK=${1:-0}
    MODE=${2:-0}
    HASHES=${3:-"hashes"}
    WORDLIST=${4:-"$LIST_ROCK"}
    OUTPUT="hashcat.txt"
    echo "hashcat -a $ATTACK -m $MODE -o $OUTPUT $HASHES $WORDLIST"
    hashcat -a $ATTACK -m $MODE -o $OUTPUT $HASHES $WORDLIST
}

tg-hashcatshow() {
    MODE=${1:-0}
    HASHES=${2:-"hashes"}
    OUTPUT="hashcat.txt"
    echo "hashcat --show -m $MODE $HASHES"
    hashcat --show -m $MODE $HASHES
}

# Initialize ctf folder
tg-init() {
    BASE=${1:-$(pwd)}
    [[ -d $BASE ]] || mkdir -p $BASE
    cd $BASE
    BASE=$(pwd)
    tg-setvar BASE $BASE
    touch notes.txt
}

tg-init-config(){
    cat << EOF > $TG_CONF
#!/usr/bin/env zsh
export LHOST=
export LPORT=4444
export RHOST=
export RPORT=
export BASE=
EOF
}

tg-setvar(){
    if [[ $# < 2 ]]; then
        echo "Wrong args"
    fi
    local var="$1"
    local value="$2"
    sed -i "/$var=/d" $TG_CONF
    echo "export $var=$value" >> $TG_CONF
}

tg-ssh() {
    sshclean
    ssh "$@"
}

tg-web() {
    PORT=${1:-80}
    IP=${2:-$RHOST}
    OUTPUT="$IP-nikto.txt"
    touch $OUTPUT
    whatweb -v -a 3 "$IP:$PORT" | tee $IP.whatweb.txt 
    nikto -host "$IP" -port "$PORT" -output $OUTPUT -Format txt
}

#
# METASPLOIT
#

msfhandle() {
    payloads=( \
        "linux/x64/meterpreter/reverse_tcp" \
        "linux/x64/shell_reverse_tcp" \
        "linux/x86/meterpreter/reverse_tcp" \
        "linux/x86/shell_reverse_tcp" \
        "windows/shell_reverse_tcp"
        "windows/meterpreter/reverse_tcp" \
        "windows/x64/meterpreter/reverse_tcp" \
        "windows/x64/shell_reverse_tcp" \
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

alias nmap-="sudo nmap -v -n -Pn"

nmap-arp()            { sudo nmap -vv -n -sn -PR                                   ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-arp.txt }
nmap-basic()          { sudo nmap -vv -n -Pn -T4                                   ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-basic.txt } 
nmap-basic-all()      { sudo nmap -vv -n -Pn -T4 -p-                               ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-basic-all.txt }
nmap-discover()       { sudo nmap -vv -n -T4 -sn -PE                               ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-discover.txt } 
nmap-full()           { sudo nmap -vv -n -Pn -T4 -A                                ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-full.txt }
nmap-full-all()       { sudo nmap -vv -n -Pn -T4 -A -p-                            ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-full-all.txt }
nmap-script()         { sudo nmap -vv -n -Pn -T4 -sC -sV                           ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-txt }
nmap-script-all()     { sudo nmap -vv -n -Pn -T4 -sC -sV -p-                       ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-all.txt }
nmap-script-vuln()    { sudo nmap -vv -n -Pn -T4 -sV --script vuln                 ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-vuln.txt }
nmap-script-vulscan() { sudo nmap -vv -n -Pn -T4 -sV --script vulscan/vulscan.nse  ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-vulscan.txt }

nmap-ports(){
    IP=${1:-"$RHOST"}
    PORTS=${2:-""}
    sudo nmap -vv -Pn -T4 $PORTS -oN nmap-ports.txt $IP 
    nmap-parse-ports
}

nmap-ports-parse() {
    FILE=${1:-"nmap-ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    tg-setvar RPORTS "$RPORTS"
    echo "RPORTS=$RPORTS"
}

[[ -f $TG_CONF ]] || tg-init-config
