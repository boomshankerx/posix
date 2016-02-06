#/usr/local/bin/bash

find /usr/local/etc/ -type d -exec chmod -v 755 {} \;
find /usr/local/etc/ -type f -exec chmod -v 644 {} \;
chmod -v 755 /usr/local/etc/rc.d/*

#chown root:wheel		/mnt/ 
chown -R lorne:files 		/mnt/data/documents
chown -R lorne:files 		/mnt/data/backup
chown -R lorne:files 		/mnt/data/diskimages
chown -R lorne:files 		/mnt/data/pictures
chown -R lorne:files 		/mnt/data/repos
chown -R lorne:files 		/mnt/data/work

chown -R www:www		 		/mnt/data/www
chown -R munin:munin		/mnt/data/www/munin

chown -R mysql:mysql		/mnt/data/db

find /mnt/data/www -type d -exec chmod -v 775 {} \;
find /mnt/data/www -type f -exec chmod -v 774 {} \;
