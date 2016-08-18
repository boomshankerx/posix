#!/usr/local/bin/bash

# BACKUP CONFIG
date="`date +%F_%H%M%S`"
temp='/tmp/config'
path="/mnt/data/backup/_server/$date" 
mkdir $temp
[ -d $path ] || mkdir $path

cd /etc ; tar -zcf $temp/etc.tgz *
cd /usr/local/etc ; tar -zcf  $temp/localetc.tgz *
cd /root ; tar -zcf $temp/root.tgz ./
cp -vr $temp/ $path/
rm -fr $temp

