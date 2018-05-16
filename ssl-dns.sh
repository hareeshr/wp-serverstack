########## Variables ####################

#default website
WEBSITE="example.com"
#default admin subwebsite
ADMINSD="tools"


########## Issue Key by DNS Challenge #################

# DNS Challenge
certbot -d $WEBSITE -d www.$WEBSITE -d $ADMINSD.$WEBSITE --manual --preferred-challenges dns certonly
# give TXT record for all three domains with given name and value pair

if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
    cd /etc/ssl/certs
    openssl dhparam -out dhparam.pem 4096
fi
