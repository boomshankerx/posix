#!/usr/bin/env zsh
#
# VARIABLES
#
export LISTDIR="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"
export LISTPASS="/usr/share/wordlists/rockyou.txt"

#
# ALIASES
#

#alias me='echo $(ifconfig eth0 | grep "inet " | cut -b 9- | cut  -d" " -f2) | xclip -selection c'
#alias ve='echo $(ifconfig tun0 | grep "inet " | cut -b 9- | cut  -d" " -f2) | xclip -selection c'
alias msf=msfconsole
alias nmap_basic="sudo nmap -v -Pn -n -T4 -sC -sV -oN nmap.basic.txt"
alias nmap_full="sudo nmap -v -Pn -n -T4 -A -oN nmap.full.txt"
alias nmap_full_all="sudo nmap -v -Pn -n -T4 -p- -A -oN nmap.full.all.txt"
alias tmp='cat $base/tmp'
alias ve='me tun0'
alias vpn='sudo -b openvpn'

#
# FUNCTIONS
#

me() {
    iface=${1:-"eth0"}
    export me=$(ifconfig $iface | grep "inet " | cut -b 9- | cut  -d" " -f2)
    echo -n $me | xclip -selection c
    sed -i "/^me=*/d" tmp
    echo "me=$me" >> tmp
    echo $me
}

focus() {
    ip=${1:-"EMPTY"}
    port=${2:-"EMPTY"}
    [[ "$ip" != "EMPTY" ]] && RHOST="$ip"
    [[ "$port" != "EMPTY" ]] && RPORT="$port"
    sed -i "/^ip=*/d" tmp
    echo "ip=$ip" >> tmp
    sed -i "/^RHOST=*/d" tmp
    echo "RHOST=$RHOST" >> tmp
    sed -i "/^RPORT=*/d" tmp
    echo "RPORT=$RPORT" >> tmp
    echo -e "\$RHOST: ${RHOST:-"NOT SET"}\n\$RPORT: ${RPORT:-"NOT SET"}\n"
}

rhost() {
    echo -n $RHOST | xclip -selection c
    echo $RHOST
}

sync() {
    base=${1:-$(pwd)}
    sed -i "s?^base=.*?base=$base?" $base/tmp
    . $base/tmp
}

hak_ctf() {
    base=${1:-$(pwd)}
    [[ -d $base ]] || md -p $base
    cd $base
    hak_init
}

hak_init() {
    echo "#!/usr/bin/env zsh" > tmp
    base=$(pwd)
    echo "base=$base" >> tmp
    touch notes.txt
}

hak_gobuster(){
    EXT=${1:-php}
    PORT=${2:-80}
    IP=${3:-$RHOST}
    WORDLIST=${3:-"/usr/share/wordlists/dirbuster/directory-list-2.3-small.txt"}
    OUTPUT=gobuster.txt
    touch $OUTPUT
    gobuster dir -w "$WORDLIST" -u http://"$IP":"$PORT" -o $OUTPUT -x $EXT
}

hak_nikto() {
    PORT=${1:-80}
    IP=${2:-$RHOST}
    OUTPUT=nikto.txt
    touch $OUTPUT
    whatweb -a 3 "$IP"
    nikto -host "$IP" -port "$PORT" -output $OUTPUT -Format txt
}

nmap_ports(){
    IP=${1:-$ip}
    PORTS=$(nmap -Pn $IP | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//); echo $PORTS
    nmap -v -Pn -n -sC -sV -p$PORTS -oN nmap.txt $IP
}

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
