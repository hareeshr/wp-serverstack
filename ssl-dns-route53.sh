########## Variables ####################

#"$DIR/path/to/file"
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#default website
WEBSITE="example.com"
#default admin subwebsite
ADMINSD="tools"
#default origin subwebsite
ORIGINSD="origin"
#default origin subwebsite
R53ACCK="origin"
#default origin subwebsite
R53ACCS="origin"


for i in "$@"
do
case $i in
    -w=*|--website=*)
    WEBSITE="${i#*=}"
    shift
    ;;
    -asd=*|--adminsd=*)
    ADMINSD="${i#*=}"
    shift
    ;;
    -osd=*|--originsd=*)
    ORIGINSD="${i#*=}"
    shift
    ;;
    -rak=*|--r53-access-key=*)
    R53ACCK="${i#*=}"
    shift
    ;;
    -ras=*|--r53-access-secret=*)
    R53ACCS="${i#*=}"
    shift
    ;;

    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
    # unknown option
    ;;
esac
done
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

sudo cp "$DIR"/certbot-route53/* /etc/letsencrypt/
sudo sed -i "s/route53_access_key/$R53ACCK/g" /etc/letsencrypt/lexicon-provider_route53.sh
sudo sed -i "s/route53_access_secret/$R53ACCS/g" /etc/letsencrypt/lexicon-provider_route53.sh

sudo chown root:root /etc/letsencrypt/lexicon-*.sh
sudo chmod 0700 /etc/letsencrypt/lexicon-*.sh

sudo certbot certonly --manual \
--manual-public-ip-logging-ok \
--manual-auth-hook "/etc/letsencrypt/lexicon-provider_route53.sh create" \
--manual-cleanup-hook "/etc/letsencrypt/lexicon-provider_route53.sh delete" \
--preferred-challenges dns \
-d $WEBSITE -d www.$WEBSITE -d $ADMINSD.$WEBSITE -d $ORIGINSD.$WEBSITE
