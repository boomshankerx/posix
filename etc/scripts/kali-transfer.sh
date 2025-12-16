#!/usr/bin/env zsh

BASE=~/transfer
[[ -d $BASE ]] || mkdir $BASE
(
cd $BASE
# Linux
ln -s /usr/share/peass/linpeas/linpeas.sh
ln -s /usr/share/peass/linpeas/linpeas_linux_amd64 linpeas
# curl -LO# https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
# curl -LO# https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
# curl -LO# https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32
# curl -LO# https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64
#
# Windows
ln -s /usr/share/peass/winpeas/winPEAS.ps1
ln -s /usr/share/peass/winpeas/winPEASx64.exe
ln -s /usr/share/peass/winpeas/winPEASx86.exe
ln -s /usr/share/windows-binaries
ln -s /usr/share/windows-resources
ln -s /usr/share/windows-resources/mimikatz
ln -s /usr/share/windows-resources/mimikatz/x64/mimikatz.exe
ln -s /usr/share/windows-resources/powersploit/Recon/PowerView.ps1
# curl -LO# https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
# curl -LO# https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
# curl -LO# https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
# curl -LO# https://raw.githubusercontent.com/peass-ng/PEASS-ng/refs/heads/master/winPEAS/winPEASps1/winPEAS.ps1
# curl -LO# https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1

# Chisel
VER="1.11.3"
curl -LO# https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_windows_amd64.zip
curl -LO# https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_linux_amd64.gz
gunzip chisel_${VER}_linux_amd64.gz
mv chisel_${VER}_linux_amd64 chisel
chmod +x chisel
unzip chisel_${VER}_windows_amd64.zip
rm -f chisel_${VER}_windows_amd64.zip
)
