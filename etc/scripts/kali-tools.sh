#!/usr/bin/env zsh

BASE=~/tools
[[ -d $BASE ]] || mkdir $BASE
(
cd $BASE
# Linux
ln -s /usr/share/peass/linpeas/linpeas.sh
ln -s /usr/share/peass/linpeas/linpeas_linux_amd64 linpeas

# Windows
ln -s /usr/share/peass/winpeas/winPEAS.ps1
ln -s /usr/share/peass/winpeas/winPEASx64.exe
ln -s /usr/share/peass/winpeas/winPEASx86.exe
ln -s /usr/share/sharphound/SharpHound.exe
ln -s /usr/share/sharphound/SharpHound.ps1
ln -s /usr/share/windows-binaries
ln -s /usr/share/windows-resources
ln -s /usr/share/windows-resources/ncat/ncat.exe
ln -s /usr/share/windows-resources/mimikatz
ln -s /usr/share/windows-resources/mimikatz/x64/mimikatz.exe
ln -s /usr/share/windows-resources/powersploit/Recon/PowerView.ps1
curl -LOs https://github.com/itm4n/PrivescCheck/releases/latest/download/PrivescCheck.ps1

# Sysinternals
curl -LOs https://download.sysinternals.com/files/SysinternalsSuite.zip
unzip SysinternalsSuite.zip PsExec64.exe

# Chisel
VER=$(curl -s https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r .tag_name | sed 's/v//')
curl -LOs https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_windows_amd64.zip
curl -LOs https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_linux_amd64.gz
gunzip chisel_${VER}_linux_amd64.gz
mv chisel_${VER}_linux_amd64 chisel
chmod +x chisel
unzip chisel_${VER}_windows_amd64.zip
rm -f chisel_${VER}_windows_amd64.zip

# ligolo-ng
VER=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | jq -r .tag_name | sed 's/v//')
curl -LOs "https://github.com/nicocha30/ligolo-ng/releases/download/v{$VER}/ligolo-ng_agent_${VER}_linux_amd64.tar.gz"
curl -LOs "https://github.com/nicocha30/ligolo-ng/releases/download/v{$VER}/ligolo-ng_agent_${VER}_windows_amd64.zip"

tar -xzf ligolo-ng_agent_${VER}_linux_amd64.tar.gz agent
chmod +x agent
rm -f ligolo-ng_agent_${VER}_linux_amd64.tar.gz
unzip ligolo-ng_agent_${VER}_windows_amd64.zip agent.exe
rm -f ligolo-ng_agent_${VER}_windows_amd64.zip
)
