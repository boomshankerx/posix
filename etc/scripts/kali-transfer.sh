#!/usr/bin/env zsh

BASE=~/transfer
[[ -d $BASE ]] || mkdir $BASE
curl -#L -o $BASE/pspy32         https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32
curl -#L -o $BASE/pspy64         https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
curl -#L -o $BASE/linpeas.sh     https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
curl -#L -o $BASE/winPEAS.bat    https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
curl -#L -o $BASE/winPEASx64.exe https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
curl -#L -o $BASE/winPEASx86     https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
curl -#L -o $BASE/PowerView.ps1  https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1
curl -#L -o $BASE/LinEnum.sh     https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
chmod +x $BASE/*
