#!/usr/bin/env zsh

#
# VARIABLES
#

export LIST_DIR_L="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-large-directories.txt"
export LIST_DIR_M="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-directories.txt"
export LIST_DIR_S="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-small-directories.txt"
export LIST_FILES_M="/usr/share/wordlists/seclists/Discovery/Web-Content/raft-medium-files.txt"
export LIST_PW_L="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-1000000.txt"
export LIST_PW_M="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-100000.txt"
export LIST_PW_S="/usr/share/wordlists/seclists/Passwords/xato-net-10-million-passwords-10000.txt"
export LIST_ROCK="/usr/share/wordlists/rockyou.txt"
export LIST_SECLISTS="/usr/share/wordlists/seclists"
export TG_CONF=~/.tg-hacker

#
# ALIASES
#

#alias ngrok="ngrok http 80"
alias _strip='tr -d "[:space:]"'
alias cc="cyberchef"
alias hcat="tg-hashcat"
alias hcati="hashcat --hash-info"
alias hcats="hashcat -hh | grep"
alias help-tg-hacker='less ~/.oh-my-zsh/custom/plugins/tg-hacker/tg-hacker.plugin.zsh'
alias hi="tg-init"
alias hrock="hydra -VI -P $LIST_ROCK"
alias jrock="john --wordlist=$LIST_ROCK"
alias jshow="john --show"
alias lg="sudo ligolo-proxy --selfcert"
alias mee="tg-ip-external"
alias msf="msfconsole -x 'setg LHOST tun0;'"
alias msfl="msfconsole -x 'setg LHOST eth0;'"
alias p="~/.oh-my-zsh/custom/plugins/tg-hacker/play.py"
alias s='sync'
alias t='rhost'
alias sshc='ssh-keygen -R'
alias sshclean='ssh-keygen -R rhost && ssh'
alias t1="tree -L 1"
alias t2="tree -L 2"
alias t3="tree -L 3"
alias te="me wg0"
alias transfer="ls ~/tools;serve 80 ~/tools"
alias var="tg-setlocal"
alias ve="me tun0"
alias we="me wg0"
alias wesng="/opt/wesng/wes.py -c --definitions /opt/wesng/definitions.zip systeminfo.txt"
alias x="xclip -selection clipboard"

# --- Docker Alias
alias rustscan="docker run -it --rm --name rustscan rustscan/rustscan:latest"
alias jwt-tool='docker run -it --network "host" --rm -v "${PWD}:/tmp" -v "${HOME}/.jwt_tool:/root/.jwt_tool" ticarpi/jwt_tool'

#
# FIND
#

alias find-cap="getcap -r / 2>/dev/null"
alias find-sgid="find / -type f -perm -2000 -ls 2>/dev/null"
alias find-suid="find / -type f -perm -4000 -ls 2>/dev/null"
alias find-sguid="find / -type f -perm -6000 -ls 2>/dev/null"
alias find-sudo="sudo -l"

#
# GREP
#

alias grep-domain='grep -E -o "([a-z0-9-]{2,24})+\.(ca|com|org|info|net)"'
alias grep-email='grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b"'
alias grep-ip='grep -E -o "(2[0-4][0-9]|25[0-5]|1?[0-9]?[0-9])[.](2[0-4][0-9]|25[0-5]|1?[0-9]?[0-9])[.](2[0-4][0-9]|25[0-5]|1?[0-9]?[0-9])[.](2[0-4][0-9]|25[0-5]|1?[0-9]?[0-9])"'

#
# HELPERS
#

add-host() {
    IP=${1:-$RHOST}
    HOST=${2:="rhost"}
    sudo sed -ir /[[:space:]]${HOST}/d /etc/hosts
    echo "$IP $HOST" | sudo tee -a /etc/hosts > /dev/null
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

# Initialize ctf folder
tg-init() {
    BASE=${1:-$(pwd)}
    [[ -d $BASE ]] || mkdir -p $BASE
    cd $BASE
    BASE=$(pwd)
    tg-setvar BASE $BASE
    touch notes.txt
    touch ./.env
}

tg-setlocal(){
    if [[ $# < 2 ]]; then
        echo "Usage: tg-setlocal VAR VALUE"
        cat ./.env
        return
    fi
    local var="$1"
    local value="$2"
    export $var="$value"
    sed -i "/$var=/d" ./.env
    echo "export $var=$value" >> ./.env
}

tg-setvar(){
    if [[ $# < 2 ]]; then
        echo "Usage: tg-setvar VAR VALUE"
        cat $TG_CONF
        return
    fi
    local var="$1"
    local value="$2"
    sed -i "/$var=/d" $TG_CONF
    echo "export $var=$value" >> $TG_CONF
}

tg-init-config(){
    cat << EOF > $TG_CONF
#!/usr/bin/env zsh
export LHOST=
export LPORT=4444
export RHOST=
export RPORT=
export URL=
export BASE=
EOF
}

#
# Target
#

rhost() {
    if [[ $# > 0 ]]; then
        if [[ "$1" =~ ^https?://* ]] ; then
            echo "URL: $1"
            export URL="$1"
            tg-setvar URL "$1"
        else
            echo "RHOST: $1"
            export RHOST="$1"
            tg-setvar RHOST "$1"
            add-host
        fi
        if [[ "$2" =~ ^[0-9]{1,5}$ ]] ; then
            echo "RPORT: $2"
            export RPORT="$2"
            tg-setvar RPORT "$2"
        fi
    fi
    SUBNET=$(echo -n $RHOST | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\.\)[0-9]*/\10\/24/')
    export RSUB=$SUBNET
    tg-setvar RSUB "$SUBNET"
    echo -n $RHOST | xclip -selection clipboard
    echo $RHOST:$RPORT
    echo $SUBNET
    echo $URL
}

lhost() {
    if [[ $# > 0 ]]; then
        export LHOST=$1
        tg-setvar LHOST "$LHOST"
        if [[ $# == 2 ]]; then
            export LPORT=$2
            tg-setvar LPORT "$LPORT"
        fi
    fi
    echo -n $LHOST | xclip -selection clipboard
    echo "LHOST: $LHOST:$LPORT"
}

# Set local callback port
lport() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: lport LPORT"
        echo "LPORT: $LPORT"
        return
    fi
    export LPORT=$1
    tg-setvar LPORT "$LPORT"
    echo "LPORT: $LPORT"
}

listen() {
    [[ -n "$1" ]] && lport "$1"
    rlwrap nc -lvnp $LPORT
}

listen-rlwrap(){
    [[ -n "$1" ]] && lport "$1"
    rlwrap nc -lvnp $LPORT
}

listen-file() {
    FILE=${1:-""}
    PORT=${2:-$LPORT}
    [[ -n "$1" ]] &&  nc -lvnp $PORT > $FILE
}

# Get ip address of local interface default: eth0
me() {
    if [[ "$1" ]]; then
        dev="$1"
    else
        dev="(eth|ens)[[:digit:]]"
    fi
    LHOST=$(ip a | grep -E "$dev$" | grep "inet " | awk '{ print $2 }' | head -1)

    if [[ -z "$LHOST" ]]; then
        echo "No interface found for $dev"
        return
    fi
    export SUBNET=$(echo -n $LHOST | sed -E 's/[0-9]{1,3}\/([0-9]{1,2})/0\/\1/g')
    export LHOST=$(echo $LHOST | cut -d'/' -f1)
    echo -n $LHOST | xclip -selection clipboard
    tg-setvar LHOST "$LHOST"
    tg-setvar LSUB "$SUBNET"
    echo "$LHOST"
    echo "$SUBNET"
}


# Launch python http server in current folder 
serve() {
    PORT=${1:-80}
    DIR=${2:-$(pwd)}
    echo "Serving files from $DIR"
    if type python3 >/dev/null 2>&1; then
       python3 -m http.server "$PORT" --directory $DIR
    else
       python -m SimpleHTTPServer "$PORT" 
    fi
}

# Sync env variables from $TG_CONF file
sync() {
    . $TG_CONF
    . ~/.oh-my-zsh/custom/plugins/tg-hacker/tg-hacker.plugin.zsh
    cd $BASE
    . ./.env
    clear -x
    if [[ $# > 0 ]]; then
        case "$1" in
            -v) cat $TG_CONF
                cat ./.env
                ;;
        esac
    fi
}

vpn() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: vpn kill|show|FILE"
        pgrep -a openvpn
        return
    fi
    if [[ "$1" ]]; then
        if [[ "$1" == "kill" ]]; then
            pgrep -a openvpn
            sudo pkill openvpn
            return
        fi
        sudo pkill openvpn
        sudo -b openvpn "$1"
    else
        echo "File not found: $1"
    fi
}

#
# FUNCTIONS
#

tg-dirsearch(){
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    WORDLIST=${3:-$LIST_DIR_M}
    EXT=${4:-"php,html,txt"}
    OUTPUT="$HOST-$PORT-dirsearch.txt"
    touch $OUTPUT
    echo "dirsearch  -w \"$WORDLIST\" -o $(pwd)/$OUTPUT -u http://$HOST:$PORT -e $EXT"
    dirsearch -w "$WORDLIST" -o $(pwd)/$OUTPUT -u http://$HOST:$PORT -e $EXT
}

tg-enum4linux() {
    HOST=${1:-$RHOST}
    OUTPUT="$HOST-enum4linux"
    enum4linux-ng $HOST -oY $OUTPUT 
}

tg-ferox(){
    PORT=${1:-80}
    DEPTH=${2:-1}
    WORDLIST=${3:-$LIST_DIR_M}
    EXT=${4:-"php,html,txt,json"}
    HOST=${5:-$RHOST}
    OUTPUT="$HOST-$PORT-ferox.txt"
    touch $OUTPUT
    feroxbuster -d $DEPTH -w "$WORDLIST" -o $(pwd)/$OUTPUT -u http://$HOST:$PORT -x $EXT --no-state 
}

tg-ffuf(){
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    WORDLIST=${3:-$LIST_DIR_M}
    OUTPUT="$HOST-$PORT-ffuf.txt"
    touch $OUTPUT
    ffuf -w $WORDLIST -t 40 -c -u http://$HOST:$PORT/FUZZ -o $OUTPUT -of csv -recursion -recursion-depth 2
}

tg-gobuster(){
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    WORDLIST=${3:-$LIST_DIR_M}
    EXT=${4:-"php,html,txt"}
    OUTPUT="$HOST-$PORT-gobuster.txt"
    touch $OUTPUT
    echo "gobuster dir -t 40 -o $OUTPUT -w $WORDLIST -u http://$HOST:$PORT -x $EXT"
    gobuster dir -t 40 -w "$WORDLIST" -o $OUTPUT -u http://$HOST:$PORT -x $EXT
}

tg-hashcat() {
    MODE=${1:-0}
    HASHES=${2:-"hashes.txt"}
    WORDLIST=${3:-"$LIST_ROCK"}
    OUTPUT="hashcat.txt"
    echo "hashcat -a $ATTACK -m $MODE -o $OUTPUT $HASHES $WORDLIST"
    hashcat -m $MODE -o $OUTPUT $HASHES $WORDLIST
}

tg-hashcatshow() {
    MODE=${1:-0}
    HASHES=${2:-"hashes.txt"}
    OUTPUT="hashcat.txt"
    echo "hashcat --show -m $MODE $HASHES"
    hashcat --show -m $MODE $HASHES
}

tg-hydra() {
}

tg-ssh() {
    sshclean
    ssh "$@"
}

tg-web() {
    PORT=${1:-80}
    HOST=${2:-$RHOST}
    OUTPUT="$HOST-$PORT"
    touch $OUTPUT
    whatweb -v -a 3 "$HOST:$PORT" | tee $OUTPUT-whatweb.txt 
    nikto -host "$HOST" -port "$PORT" -output $OUTPUT-nikto.txt -Format txt
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

nmap-arp()            { sudo nmap -v -n -sn -PR                                   ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-arp.txt }
nmap-basic()          { sudo nmap -v -n -Pn -T4                                   ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-basic.txt } 
nmap-basic-all()      { sudo nmap -v -n -Pn -T4 -p-                               ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-basic-all.txt }
nmap-discover()       { sudo nmap -v -n -T4 -sn -PE                               ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-discover.txt } 
nmap-full()           { sudo nmap -v -n -Pn -T4 -A                                ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-full.txt }
nmap-full-all()       { sudo nmap -v -n -Pn -T4 -A -p-                            ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-full-all.txt }
nmap-script-all()     { sudo nmap -v -n -Pn -T4 -sC -sV -p-                       ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-all.txt }
nmap-script()         { sudo nmap -v -n -Pn -T4 -sC -sV                           ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script.txt }
nmap-script-vuln()    { sudo nmap -v -n -Pn -T4 -sV --script vuln                 ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-vuln.txt }
nmap-script-vulscan() { sudo nmap -v -n -Pn -T4 -sV --script vulscan/vulscan.nse  ${1:-$RHOST} -oN ${1:-$RHOST}-nmap-script-vulscan.txt }
nmap-rust()           { rustscan --accessible -a ${1:-$RHOST} -- -n -Pn -sC -sV -T4 | tee rustscan.txt }

nmap-ports(){
    HOST=${1:-"$RHOST"}
    OPTS=${2:-""}
    sudo nmap -v -Pn -T4 $OPTS -oN nmap-ports.txt $HOST 
    nmap-ports-parse
}

nmap-ports-parse() {
    FILE=${1:-"nmap-ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    tg-setvar RPORTS "$RPORTS"
    echo "RPORTS=$RPORTS"
}

[[ -f $TG_CONF ]] || tg-init-config
source ~/.tg-hacker
