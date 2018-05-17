#!/usr/local/bin/bash

LOG_FILE="/var/log/update.log"

echo -e "Starting Updates: `date`" | tee -a ${LOG_FILE}
echo -e "* Installing security patches..." | tee -a ${LOG_FILE}
/usr/sbin/freebsd-update fetch
/usr/sbin/freebsd-update install

echo -e "* Updating ports tree..." | tee -a ${LOG_FILE}
/usr/sbin/portsnap fetch update

echo -e "* Updating pkg database..." | tee -a ${LOG_FILE}
/usr/sbin/pkg update
