# For Copy/Paste purpose

############################################
############## Installation ################
############################################

sudo apt-get update
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install certbot -y
sudo apt install python-pip -y
sudo pip install dns-lexicon
sudo pip install dns-lexicon[route53]


############################################
############## Configuration ###############
############################################

sudo cp /tmp/wp-serverstack/certbot-route53/* /etc/letsencrypt/
#replace akey with your AWS access key
sudo sed -i "s/route53_access_key/akey/g" /etc/letsencrypt/lexicon-provider_route53.sh
#replace skey with your AWS access secret
sudo sed -i "s/route53_access_secret/skey/g" /etc/letsencrypt/lexicon-provider_route53.sh

sudo chown root:root /etc/letsencrypt/lexicon-*.sh
sudo chmod 0700 /etc/letsencrypt/lexicon-*.sh

#replace website.com with your domain name
sudo certbot certonly --manual \
--manual-public-ip-logging-ok \
--manual-auth-hook "/etc/letsencrypt/lexicon-provider_route53.sh create" \
--manual-cleanup-hook "/etc/letsencrypt/lexicon-provider_route53.sh delete" \
--preferred-challenges dns \
-d website.com -d www.website.com -d tools.website.com -d origin.website.com
