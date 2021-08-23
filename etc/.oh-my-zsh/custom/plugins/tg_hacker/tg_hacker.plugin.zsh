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
alias nmap_full="sudo nmap -v -Pn -n -T4 -p- -A -oN nmap.txt"
alias ve='me tun0'
alias vpn='sudo -b openvpn'
alias tmp='cat $base/tmp'

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
    echo -e "\$RHOST: ${RHOST:-"NOT SET"}\n\$RPORT: ${RPORT:-"NOT SET"}\n"
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

hak_web() {
    IP=${1:-$ip}
    PORT=${2:-80}
    WORDLIST=${3:-"/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"}
    # /usr/share/seclists/Discovery/Web_Content/Top1000-RobotsDisallowed.txt
    GOBUSTER_OUTPUT=gobuster.txt
    NIKTO_OUTPUT=nikto.txt
    touch $GOBUSTER_OUTPUT
    touch $NIKTO_OUTPUT
    whatweb -a 3 "$IP"
    gobuster dir -w "$WORDLIST" -u http://"$IP":"$PORT" -o $GOBUSTER_OUTPUT
    nikto -host "$IP" -port "$PORT" -output $NIKTO_OUTPUT -Format txt
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
