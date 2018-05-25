########## Variables ####################

#default website
WEBSITE="example.com"
#default admin subwebsite
ADMINSD="tools"
#default origin subwebsite
ORIGINSD="origin"


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

    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
    # unknown option
    ;;
esac
done


########## Issue Key by DNS Challenge #################

# DNS Challenge
certbot -d $WEBSITE -d www.$WEBSITE -d $ADMINSD.$WEBSITE -d $ORIGINSD.$WEBSITE --manual --preferred-challenges dns certonly
# give TXT record for all three domains with given name and value pair

if [ ! -f /etc/ssl/certs/dhparam.pem ]; then
    cd /etc/ssl/certs
    openssl dhparam -out dhparam.pem 4096
fi
