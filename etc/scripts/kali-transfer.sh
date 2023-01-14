#!/usr/bin/env zsh

[[ -d ~/transfer ]] || mkdir ~/transfer
cd ~/transfer
curl -#LO https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32
curl -#LO https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
curl -#LO https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
curl -#LO https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
curl -#LO https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
curl -#LO https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
curl -#LO https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
