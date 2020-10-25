#!/bin/sh
# Run a STunnel service in docker, via:
#       docker run -dit \
#       -v `find /dir/ -name "Google*.zip"`:/data/Google.zip \
#       -p 1636:1636 --name gstunnel \
#       zalgonoise/gstunnel:latest
#
#       docker run -dit \
#       -v `find /dir/ -name "Google*.key"`:/data/stunnel.key \
#       -v `find /dir/ -name "Google*.crt"`:/data/stunnel.crt \
#       -p 1636:1636 --name gstunnel \
#       zalgonoise/gstunnel:latest
#





# Create configuration file for STunnel
# Defaults to Google's G Suite LDAP parameters

cd /etc/stunnel

cat << EOF > stunnel.conf
foreground = yes

setuid = stunnel
setgid = stunnel

socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[${SERVICE:-ldap}]
client = ${CLIENT:-yes}
accept = ${ACCEPT:-1636}
connect = ${CONNECT:-ldap.google.com:636}
cert = /data/stunnel.crt
key = /data/stunnel.key
EOF

# Expects keys to be attached
# Creates directory if they aren't


if ! [ -d /data ]
then
    mkdir /data
    chmod 777 /data
fi

cd /data

# Extracts contents from .zip file if provided

if [ -f /data/*.zip ]
then 
    unzip /data/*.zip 
fi


# Expects certificate in the /data directory
# Generates new crt/key if they aren't there

if ! [ -f /data/*.crt ] || ! [ -f /data/*.key ]
then
    openssl req -x509 -nodes -newkey rsa:2048 -days 3650 -subj '/CN=stunnel' \
                -keyout stunnel.key -out stunnel.crt
    chmod 600 stunnel.pem
else 
    mv /data/*.crt /data/stunnel.crt
    mv /data/*.key /data/stunnel.key

    cp /data/stunnel.crt /usr/local/share/ca-certificates/stunnel.crt 
    update-ca-certificates 2>&/dev/null
fi


# Pushes default config from /etc/stunnel/stunnel.conf
# Unless it's specified when the container is ran (as a parameter)
# e.g.: docker run -dit \
#       -v `find /dir/ -name "Google*.zip"`:/data/Google.zip \
#       -p 1636:1636 \
#       zalgonoise/gstunnel:1.0 /data/stunnel.conf


if [ -z "$@" ]
then
    echo "Starting STunnel with default config"
    sh -c stunnel /etc/stunnel/stunnel.conf 
else
    echo "Starting STunnel with custom config"
    sh -c stunnel "$@" 
fi