#!/usr/bin/env bash


version=$(curl -I https://github.com/obsidianmd/obsidian-releases/releases/latest | grep location | cut -d'/' -f8 | tr -d 'v' | tr -d '\r\n')
echo $version

url="https://github.com/obsidianmd/obsidian-releases/releases/download/v$version/Obsidian-$version.AppImage"
echo $url

sudo curl -L -o ~/opt/Obsidian.AppImage $url
#sudo chmod +x ~/opt/Obsidian.AppImage

#sudo curl -L -O --output-dir ~/Downloads https://github.com/obsidianmd/obsidian-releases/releases/download/v$version/Obsidian-$version.deb
