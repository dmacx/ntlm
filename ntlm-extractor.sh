#!/usr/bin/env bash

#
#
#### BSD version, uses b64decode instead of base64 -d -i
#
# (c) david.macphail@acsn.co.uk 
# v0.1 BSD
#
####
#
#
# Usage: ./ntlm.sh [hostname or IP] [port] [-ssl]
#
#

# set up main function as seperate file to keep s_client output to a minimum
 
cat > main.sh <<EOF
#!/usr/bin/env/ bash 
echo -e -n "GET / HTTP/1.0\r\nAuthorization: NTLM TlRMTVNTUAABAAAAB4IIogAAAAAAAAAAAAAAAAAAAAAFASgKAAAADw==\r\nConnection: close\r\n\r\n\r\n" | nc -w 10 \$1 \$2  | grep "WWW-Authenticate:" | tail -n1 | awk '{print \$3}' | base64 -d -i |  tr -cd '\001\002\003\005\006\016\017\005\004\40-\176' |tee ${1}.full | sed 's/\(^.*'\$(printf '\1')'\)\(.*\)\('\$(printf '\4')'.*$\)/\2/'  | tr -cd "[:alnum:].$" |tee ${1}.full.sanitised > rslt
#(echo -e -n "GET / HTTP/1.0\r\nAuthorization: NTLM TlRMTVNTUAABAAAAB4IIogAAAAAAAAAAAAAAAAAAAAAFASgKAAAADw==\r\nConnection: close\r\n\r\n\r\n"; sleep 10) | openssl s_client -connect \$1:\$2 -quiet  | grep "WWW-Authenticate:" | tail -n1 | awk '{print \$3}' | base64 -d -i |  tr -cd '\001\002\006\016\005\40-\176' |tee ${1}.full | tr -cd "[:alnum:].$" |tee ${1}.full.sanitised| 's/\(^.*'\$(printf '\1')'\)\(.*\)\('\$(printf '\4')'.*$\)/\2/' > rslt
sed -e 's/\(^.*'\$(printf '\17')'\)\(.*\)\('\$(printf '\2')'.*$\)/\2/' ${1}.full | tr -cd "[:alnum:][:punct:]"> ${1}.ADDomain
sed -e 's/\(^.*'\$(printf '\0\3\0')'\)\(.*$\)\('\$(printf '\0\0\0\0')'.*$\)/\2/' ${1}.full |  tr -cd "[:alnum:][:punct:]" > ${1}.FQDNsuffix
exit 0
EOF
chmod +x main.sh
sh main.sh $1 $2 >/dev/null 2>&1
#rm main.sh
echo -ne "The WWW-Authenticate response from the server (decoded and sanitised) was \n";cat ${1}.full.sanitised;echo -ne ", which suggests that the machine name is ";cat rslt
echo -ne "NetBIOS / AD Domain is ";cat ${1}.ADDomain |  tr -cd '\40-\176'; echo -en '\n'
echo -ne "FQDN suffix is ";cat  ${1}.FQDNsuffix | tr -cd '\40-\176'; echo -en '\n'
#rm -f main.sh ${1}.full rslt
exit 0

