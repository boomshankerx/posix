#!/usr/local/bin/bash

LOG_FILE="/var/log/update.log"

echo "Starting Updates: `date`" | tee -a ${LOG_FILE}
echo "* Installing security  patches..." | tee -a ${LOG_FILE}
/usr/sbin/freebsd-update fetch
/usr/sbin/freebsd-update install | tee -a ${LOG_FILE}

echo "* Updating ports tree..." | tee -a ${LOG_FILE}
/usr/sbin/portsnap cron update

echo -e "* Updating pkg database..." | tee -a ${LOG_FILE}
/usr/sbin/pkg update
