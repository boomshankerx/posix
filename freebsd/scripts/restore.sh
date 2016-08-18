#!/bin/bash

if [[ -z $1 ]]; then
	echo "Please provide backup directory path..."
	exit
fi

rm -fr ~/restore

mkdir ~/restore
mkdir ~/restore/etc
mkdir ~/restore/root
mkdir ~/restore/localetc

tar -zxvf $1/etc.tgz -C ~/restore/etc/
tar -zxvf $1/root.tgz -C ~/restore/root/
tar -zxvf $1/localetc.tgz -C ~/restore/localetc/

