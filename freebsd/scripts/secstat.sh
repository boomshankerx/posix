#!/usr/local/bin/bash
#echo -e "\n### AUTH LOGS ###"
#cat /var/log/auth.log

echo -e "### FAIL2BAN LOGS ###"
cat /var/log/fail2ban.log

echo -e "\n### BLACKLIST ###"
cat /etc/pf.blacklist

echo -e "\n### FAIL2BAN ###"
pfctl -t fail2ban  -T show

echo -e "\n### BLACKLIST ###"
pfctl -t blacklist -T show
