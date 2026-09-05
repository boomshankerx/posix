#!/usr/bin/env bash

BASE=~/tools
[[ -d $BASE ]] || mkdir $BASE
(
cd $BASE
# Linux
# ln -s /usr/share/peass/linpeas/linpeas.sh .
# ln -s /usr/share/peass/linpeas/linpeas_linux_amd64 linpeas

# Windows
# ln -s /usr/share/peass/winpeas .
# ln -s /usr/share/peass/winpeas/winPEAS.ps1 .
# ln -s /usr/share/peass/winpeas/winPEASx64.exe .
# ln -s /usr/share/peass/winpeas/winPEASx86.exe .
ln -s /usr/share/sharphound/SharpHound.exe .
ln -s /usr/share/sharphound/SharpHound.ps1 .
ln -s /usr/share/windows-binaries .
ln -s /usr/share/windows-resources .
ln -s /usr/share/windows-resources/ncat/ncat.exe .
ln -s /usr/share/windows-resources/mimikatz .
ln -s /usr/share/windows-resources/mimikatz/x64/mimikatz.exe .
ln -s /usr/share/windows-resources/powersploit/Recon/PowerView.ps1 .

echo "Installing PrivescCheck"
curl -#LO https://github.com/itm4n/PrivescCheck/releases/latest/download/PrivescCheck.ps1 .

# Sysinternals
echo "Installing SysinternalsSuite"
curl -#LO https://download.sysinternals.com/files/SysinternalsSuite.zip
unzip -o SysinternalsSuite.zip PsExec64.exe

# Chisel
VER=$(curl -s https://api.github.com/repos/jpillora/chisel/releases/latest | jq -r .tag_name | sed 's/v//')
echo "Installing chisel version $VER"
curl -#LO https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_windows_amd64.zip
curl -#LO https://github.com/jpillora/chisel/releases/download/v${VER}/chisel_${VER}_linux_amd64.gz
gunzip -f chisel_${VER}_linux_amd64.gz
mv chisel_${VER}_linux_amd64 chisel
chmod +x chisel
unzip -o chisel_${VER}_windows_amd64.zip
rm -f chisel_${VER}_windows_amd64.zip

#Kerbrute
VER=$(curl -s https://api.github.com/repos/ropnop/kerbrute/releases/latest | jq -r .tag_name | sed 's/v//')
echo "Installing kerbrute version $VER"
curl -#LO https://github.com/ropnop/kerbrute/releases/download/v${VER}/kerbrute_linux_amd64
chmod +x kerbrute_linux_amd64
mv kerbrute_linux_amd64 ~/.local/bin/kerbrute

# ligolo-ng
VER=$(curl -s https://api.github.com/repos/nicocha30/ligolo-ng/releases/latest | jq -r .tag_name | sed 's/v//')
echo "Installing ligolo-ng version $VER"
curl -#LO "https://github.com/nicocha30/ligolo-ng/releases/download/v{$VER}/ligolo-ng_agent_${VER}_linux_amd64.tar.gz"
curl -#LO "https://github.com/nicocha30/ligolo-ng/releases/download/v{$VER}/ligolo-ng_agent_${VER}_windows_amd64.zip"
tar -xzf ligolo-ng_agent_${VER}_linux_amd64.tar.gz agent
chmod +x agent
rm -f ligolo-ng_agent_${VER}_linux_amd64.tar.gz
unzip -o ligolo-ng_agent_${VER}_windows_amd64.zip agent.exe
rm -f ligolo-ng_agent_${VER}_windows_amd64.zip

# === peass-ng ===
VER=$(curl -s https://api.github.com/repos/peass-ng/PEASS-ng/releases/latest | jq -r .tag_name | sed 's/v//')
echo "Installing peass-ng version $VER"
curl -#LO https://github.com/peass-ng/PEASS-ng/releases/download/$VER/linpeas.sh
curl -#L https://github.com/peass-ng/PEASS-ng/releases/download/$VER/linpeas_linux_amd64 -o linpeas
curl -#LO https://github.com/peass-ng/PEASS-ng/releases/download/$VER/winPEAS.bat
curl -#LO https://github.com/peass-ng/PEASS-ng/releases/download/$VER/winPEASx64.exe
curl -#LO https://github.com/peass-ng/PEASS-ng/releases/download/$VER/winPEASx64_ofs.exe
chmod +x linpeas

#socat
curl -#LO "https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat"
chmod +x socat
curl -\# "https://sourceforge.net/projects/unix-utils/files/socat/1.7.3.2/socat-1.7.3.2-1-x86_64.zip/download" -o "socat.exe" 
chmod +x socat.exe

)
