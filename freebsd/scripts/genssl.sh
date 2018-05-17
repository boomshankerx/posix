#!/usr/local/bin/bash

cd /root
mkdir sslCA
chmod -R 700 sslCA
cd sslCA
mkdir certs newcerts private
echo 1000 > serial
touch index.txt


openssl req -new -x509 -days 365 -extensions v3_ca -keyout private/cakey.pem -out ca.crt -config /etc/ssl/openssl.cnf
openssl req -new -nodes -out techgsolutions.req -keyout private/techgsolutions.key -config /etc/ssl/openssl.cnf
openssl ca -config /etc/ssl/openssl.cnf -out techgsolutions.crt -infiles techgsolutions.req 
