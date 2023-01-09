#!/usr/bin/env zsh

[[ -d ~/transfer ]] || mkdir ~/transfer
cd ~/transfer
curl -O https://github.com/DominicBreuker/pspy/releases/download/latest/pspy32
curl -O https://github.com/DominicBreuker/pspy/releases/download/latest/pspy64
curl -O https://github.com/carlospolop/PEASS-ng/releases/download/latest/linpeas.sh
curl -O https://github.com/carlospolop/PEASS-ng/releases/download/latest/winPEAS.bat
curl -O https://github.com/carlospolop/PEASS-ng/releases/download/latest/winPEASx64.bat
curl -O https://github.com/carlospolop/PEASS-ng/releases/download/latest/winPEASx86.bat
curl -O https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
