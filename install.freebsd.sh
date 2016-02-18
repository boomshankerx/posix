#!/usr/local/bin/bash

function base {
	pkg install -y bash
	pkg install -y bind99
	pkg install -y git
	pkg install -y portmaster
	pkg install -y rsync
	pkg install -y samba43
	pkg install -y taskwarrior
	pkg install -y vim-lite
	base_config
}

function base_config {
		sed -i "" /##CUSTOM##/,/####/d /etc/rc.conf 
		cat conf/freebsd/rc.conf | tee /etc/rc.conf
}

function config {
		chsh -s bash
		sed -i "" /##CUSTOM##/,/####/d /etc/profile 
		cat conf/freebsd/profile.txt | tee -a /etc/profile

		sed -i "" /##CUSTOM##/,/####/d ~/.bash_aliases
		cat conf/bash_aliases.txt | tee -a ~/.bash_aliases

		sed -i "" /##FREEBSD##/,/####/d ~/.bash_aliases
		cat conf/freebsd/bash_aliases.txt | tee -a ~/.bash_aliases

		sed -i "" /##CUSTOM##/,/####/d ~/.bash_profile
		cat conf/freebsd/bash_profile.txt | tee -a ~/.bash_profile
		
		sed -i "" /##CUSTOM##/,/####/d ~/.bashrc
		cat conf/freebsd/bashrc.txt | tee -a ~/.bashrc

		sed -i "" -e "s/#UseDNS yes/UseDNS no/" /etc/ssh/sshd_config

		#LINKS
		function link {
			[[ -h $2 ]] || ln -s $1 $2
		}

		link /etc ~/etc
		link /etc/rc.conf ~/rc.conf
		link /etc/rc.d ~/r
		link /usr/local/etc ~/localetc
		link /usr/local/etc/rc.d ~/e
		link /usr/local/etc/smb.conf ~/smb.conf
		link /mnt/data/repos/ ~/repos
}

function samba {
	sed -i "" -e 's/workgroup =.*/workgroup = TECHG/' -e 's/server string =.*/server string = server/' /usr/local/etc/smb.conf
}

echo $@

for opts in $@
do
	case $opts in
		"base")
			base;;
		"config")
			config;;
		"devel")
			devel;;
	esac
done

		