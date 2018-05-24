########## Issue Key by DNS Challenge #################

# change example.com to your domain and tools to your admin subdomain
certbot -d example.com -d www.example.com -d tools.example.com -d origin.example.com --manual --preferred-challenges dns certonly
# give TXT record for all three domains with given name and value pair

#if dhparam.pem file not created run this
#this will take a very long time
cd /etc/ssl/certs
openssl dhparam -out dhparam.pem 4096
