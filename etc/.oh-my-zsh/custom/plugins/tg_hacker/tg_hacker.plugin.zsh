#!/usr/bin/env zsh

#
# VARIABLES
#

export PASSLIST="/usr/share/wordlists/rockyou.txt"
export DIRLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

#
# ALIASES
#

alias hcat='hak_hashcat'
alias hcatshow='hashcat --show'
alias jrock='john --wordlist=$PASSLIST'
alias jshow='john --show'
alias msf=msfconsole
alias tmp='cat $base/tmp'
alias ve='me tun0'
alias vpn='sudo -b openvpn'

#
# FUNCTIONS
#

# Get ip address of local interface default: eth0
me() {
    iface=${1:-"eth0"}
    LHOST=$(ifconfig $iface | grep "inet " | cut -b 9- | cut  -d" " -f2)
    echo -n $LHOST | xclip -selection c
    sed -i "/^LHOST=*/d" tmp
    echo "LHOST=$LHOST" >> tmp
    echo $LHOST
}

# Select target ip:port
focus() {
    IP=${1:-"EMPTY"}
    PORT=${2:-"EMPTY"}
    # Set shell variables
    [[ "$IP" != "EMPTY" ]] && RHOST="$IP"
    [[ "$PORT" != "EMPTY" ]] && RPORT="$PORT"
    # Add target to hosts file as rhost replacing as necessary
    sudo sed -i /rhost$/d /etc/hosts
    echo "$IP rhost" | sudo tee -a /etc/hosts
    # Add variables to sync tmp file 
    sed -i "/^RHOST=*/d" tmp
    echo "RHOST=$RHOST" >> tmp
    sed -i "/^RPORT=*/d" tmp
    echo "RPORT=$RPORT" >> tmp
    echo -e "\$RHOST: ${RHOST:-"NOT SET"}\n\$RPORT: ${RPORT:-"NOT SET"}\n"
}

# Set local callback port
lport() {
    LPORT=${1:-"4444"} 
    sed -i "/^LPORT=*/d" tmp
    echo "LPORT=$LPORT" >> tmp
    echo "LPORT=$LPORT"
}

# Copy rhost to clipboard
rhost() {
    echo -n $RHOST | xclip -selection c
    echo "RHOST=$RHOST"

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

# Sync env variables from tmp file
sync() {
    base=${1:-$(pwd)}
    sed -i "s?^base=.*?base=$base?" $base/tmp
    tmp
    . $base/tmp
    . ~/.oh-my-zsh/custom/plugins/tg_hacker/tg_hacker.plugin.zsh
}

#
# HAK FUNCTIONS
#

# Initialize ctf folder
hak_init() {
    base=${1:-$(pwd)}
    [[ -d $base ]] || mkdir -p $base
    cd $base
    base=$(pwd)
    echo "#!/usr/bin/env zsh" > tmp
    echo "base=$base" >> tmp
    echo "LPORT=4444" >> tmp
    touch notes.txt
}

hak_gobuster(){
    EXT=${1:-php}
    PORT=${2:-80}
    IP=${3:-$RHOST}
    WORDLIST=${3:-$DIRLIST}
    OUTPUT=gobuster.$PORT.txt
    touch $OUTPUT
    gobuster dir -w "$WORDLIST" -u http://"$IP":"$PORT" -o $OUTPUT -x $EXT -t 40
}

hak_hashcat() {
    MODE=${1}
    HASHES=${2:-"hashes.txt"}
    ATTACK=${3:-0}
    WORDLIST=${4:-"$PASSLIST"}
    echo "hashcat -m $MODE -a $ATTACK $HASHES $WORDLIST"
    hashcat -m $MODE -a $ATTACK $HASHES $WORDLIST
}

hak_web() {
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

alias nmap_basic="nmap -v -Pn -n -T4 -oN nmap.basic.txt"
alias nmap_basic_all="nmap -v -Pn -n -T4 -p- -oN nmap.basic.all.txt"
alias nmap_full="sudo nmap -v -Pn -n -T4 -A -oN nmap.full.txt"
alias nmap_full_all="sudo nmap -v -Pn -n -T4 -A -p- -oN nmap.full.all.txt"
alias nmap_rports="nmap -v -Pn -n -sC -sV -p$RPORTS -oN nmap.txt" $RHOST
alias nmap_script="sudo nmap -v -Pn -n -T4 -sC -sV -oN nmap.script.txt"
alias nmap_script_all="sudo nmap -v -Pn -n -T4 -sC -sV -p- -oN nmap.script.all.txt"

nmap_ports(){
    IP=${1:-$ip}
    nmap -v -Pn -T4 -p- $IP -oN nmap.ports.txt
    nmap_parse_ports
}

nmap_parse_ports() {
    FILE=${1:-"nmap.ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    sed -i "/^RPORTS=*/d" tmp
    echo "RPORTS=$RPORTS" >> tmp
    echo "RPORTS=$RPORTS"
}

