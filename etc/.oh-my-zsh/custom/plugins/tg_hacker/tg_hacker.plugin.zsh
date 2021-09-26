#!/usr/bin/env zsh

#
# VARIABLES
#

export PASSLIST="/usr/share/wordlists/rockyou.txt"
export DIRLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

#
# ALIASES
#

alias dlcu='tpl certutil'
alias dlps='tpl ps_dl'
alias hcat='hak_hashcat'
alias hcatshow='hashcat --show'
alias jrock='john --wordlist=$PASSLIST'
alias jshow='john --show'
alias msf=msfconsole
alias msf_linux_meterpreter_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload linux/x86/meterpreter/reverse_tcp; run;'"
alias msf_linux_shell_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload linux/x86/shell_reverse_tcp; run;'"
alias msf_linux_x64_meterpreter_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload linux/x64/meterpreter/reverse_tcp; run;'"
alias msf_linux_x64_shell_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload linux/x64/shell_reverse_tcp; run;'"
alias msf_win_meterpreter_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload windows/meterpreter/reverse_tcp; run;'"
alias msf_win_shell_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload windows/shell_reverse_tcp; run;'"
alias msf_win_x64_shell_reverse_tcp="msfconsole -x 'use exploit/multi/handler; set LHOST $LHOST; set LPORT $LPORT; set payload windows/x64/shell_reverse_tcp; run;'"
alias ncl='nc -lvnp $LPORT'
alias s='sync'
alias sshclean='ssh-keygen -R rhost'
alias tmp='cat $base/tmp'
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

# Select target ip:port
focus() {
    IP=${1:-"EMPTY"}
    PORT=${2:-"EMPTY"}
    # Set shell variables
    [[ "$IP" != "EMPTY" ]] && export RHOST="$IP"
    [[ "$PORT" != "EMPTY" ]] && export RPORT="$PORT"
    # Add target to hosts file as rhost replacing as necessary
    #sudo sed -i /rhost$/d /etc/hosts
    #echo "$IP rhost" | sudo tee -a /etc/hosts
    add_host
    # Add variables to sync tmp file 
    sed -i "/export RHOST=*/d" tmp
    echo "export RHOST=$RHOST" >> tmp
    sed -i "/export RPORT=*/d" tmp
    echo "export RPORT=$RPORT" >> tmp
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
    if [[ -f $base/tmp ]]; then
        sed -i "/LPORT=*/d" tmp
        echo "LPORT=$LPORT" >> tmp
    fi
    echo "LPORT: $LPORT"
}

# Get ip address of local interface default: eth0
me() {
    iface=${1:-"eth0"}
    export LHOST=$(ifconfig $iface | grep "inet " | cut -b 9- | cut  -d" " -f2)
    echo -n $LHOST | xclip -selection c
    if [[ -f $base/tmp ]]; then
        sed -i "/export LHOST=*/d" tmp
        echo "export LHOST=$LHOST" >> tmp
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

# Sync env variables from tmp file
sync() {
    base=${1:-$(pwd)}
    if [[ -f $base/tmp ]]; then
        sed -i "/^base=/d" $base/tmp
        echo "base=$base" >> $base/tmp
        tmp
        . $base/tmp
    fi
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
    echo "export LPORT=4444" >> tmp
    touch notes.txt
}

hak_ffuf(){
    PORT=${1:-80}
    IP=${2:-$RHOST}
    WORDLIST=${3:-$DIRLIST}
    OUTPUT=ffuf.$PORT.txt
    touch $OUTPUT
    ffuf -w $DIRLIST -u http://$RHOST:$PORT/FUZZ
}

hak_gobuster(){
    EXT=${1:-php}
    PORT=${2:-80}
    IP=${3:-$RHOST}
    WORDLIST=${3:-$DIRLIST}
    OUTPUT=gobuster.$PORT.txt
    touch $OUTPUT
    gobuster dir -w "$WORDLIST" -u http://"$IP":"$PORT" -o $OUTPUT -x $EXT -t 50
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

alias nmap_basic="sudo nmap -vv -Pn -n -T4 -oN nmap.basic.txt"
alias nmap_basic_all="sudo nmap -vv -Pn -n -T4 -p- -oN nmap.basic.all.txt"
alias nmap_full="sudo nmap -vv -n -T4 -A -oN nmap.full.txt"
alias nmap_full_all="sudo nmap -vv -n -T4 -A -p- -oN nmap.full.all.txt"
alias nmap_scan_ports="sudo nmap -vv -Pn -n -sC -sV -p$RPORTS -oN nmap.txt $RHOST"
alias nmap_script="sudo nmap -vv -Pn -n -T4 -sC -sV -oN nmap.script.txt"
alias nmap_script_all="sudo nmap -vv -Pn -n -T4 -sC -sV -p- -oN nmap.script.all.txt"

nmap_get_ports(){
    IP=${1:-$ip}
    sudo nmap -vv -Pn -T4 -p- $IP -oN nmap.ports.txt
    nmap_parse_ports
}

nmap_parse_ports() {
    FILE=${1:-"nmap.ports.txt"} 
    RPORTS=$(cat $FILE | grep -P '^\d+' | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
    sed -i "/^export RPORTS=*/d" tmp
    echo "export RPORTS=$RPORTS" >> tmp
    echo "RPORTS=$RPORTS"
}

