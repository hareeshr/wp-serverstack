########## Variables ####################

#"$DIR/path/to/file"
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

#default website
WEBSITE="example.com"
#default admin subwebsite
ADMINSD="tools"
#default origin subwebsite
ORIGINSD="origin"
#default IP address
IP="127.0.0.1"

#default db root password
DB_ROOTP="rootpass"
#default db user
DB_USER="db_user"
#default db name
DB_NAME="db_name"
#default db user password
DB_PASS="db_pass"
#default global db access - not implemented
DB_GLOB=false

#default ftp user
FTP_USER="ftpuser"
#default ftp password
FTP_PASS="ftppass"

#default admin user
ADMIN_USER="adminname"
#default admin pass
ADMIN_PASS="adminpass"

for i in "$@"
do
case $i in
    -w=*|--website=*)
    WEBSITE="${i#*=}"
    shift
    ;;
    -ip=*|--ip=*)
    IP="${i#*=}"
    shift
    ;;


    -dbrp=*|--dbrootpass=*)
    DB_ROOTP="${i#*=}"
    shift
    ;;
    -dbu=*|--dbuser=*)
    DB_USER="${i#*=}"
    shift
    ;;
    -dbn=*|--dbname=*)
    DB_NAME="${i#*=}"
    shift
    ;;
    -dbp=*|--dbpass=*)
    DB_PASS="${i#*=}"
    shift
    ;;
    -dbg=*|--dbglobal=*)
    DB_GLOB="${i#*=}"
    shift
    ;;


    -ftpu=*|--ftpuser=*)
    FTP_USER="${i#*=}"
    shift
    ;;
    -ftpp=*|--ftppass=*)
    FTP_PASS="${i#*=}"
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
    -au=*|--adminuser=*)
    ADMIN_USER="${i#*=}"
    shift
    ;;
    -ap=*|--adminpass=*)
    ADMIN_PASS="${i#*=}"
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

########## Update all Packages ##############

sudo apt-get update
sudo apt-get upgrade -y

########## Required #########################

sudo apt-get install git-core
sudo apt-get install unzip

########## Admin Folder #####################

sudo mkdir /var/www
sudo mkdir /var/www/html
sudo mkdir /var/www/admin

############################################
############## Installation ################
############################################

########## Install NGINX ###################

sudo apt-get install nginx -y

########## Adjust Firewall #################

#sudo ufw allow 'Nginx Full'

########## Install MariaDb #################

sudo apt-get install mariadb-server mariadb-client -y

########## Install PHP7.2 ##################

sudo apt-get install software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update
sudo apt-get install php7.2-fpm php7.2-common php7.2-mbstring php7.2-xmlrpc php7.2-gd php7.2-xml php7.2-mysql php7.2-cli php7.2-zip php7.2-curl php7.2-gd -y

########## Install VSFTPD ##################

sudo apt-get install vsftpd -y

########## Install PHPMYADMIN ##############

sudo mkdir /var/www/admin/phpmyadmin
cd /var/www/admin/phpmyadmin
sudo wget -c https://files.phpmyadmin.net/phpMyAdmin/4.8.0.1/phpMyAdmin-4.8.0.1-english.zip -O phpmyadmin.zip
sudo unzip phpmyadmin.zip
sudo mv phpMyAdmin-4.8.0.1-english/* .
sudo rm phpmyadmin.zip
sudo rm -r phpMyAdmin-4.8.0.1-english
cd /

########## Install Adminer #################

sudo mkdir /var/www/admin/adminer
cd /var/www/admin/adminer
sudo wget -c https://www.adminer.org/latest-en.php -O index.php
cd /

########## Install File manager ############

sudo mkdir /var/www/admin/filemanger
cd /var/www/admin/filemanger
sudo git clone https://github.com/prasathmani/tinyfilemanager
sudo mv tinyfilemanager/tinyfilemanager.php index.php
sudo rm -r tinyfilemanager
cd /

########## Install Net2FTP #################

sudo mkdir /var/www/admin/net2ftp
cd /var/www/admin/net2ftp
sudo wget -c http://www.net2ftp.com/download/net2ftp_v1.1.zip -O net2ftp.zip
sudo unzip net2ftp.zip
sudo mv net2ftp_v1.1/files_to_upload/* .
sudo rm net2ftp.zip
sudo rm -r net2ftp_v1.1
cd /

########## Custom Admin Panel ######################

sudo cp -r "$DIR"/admin/* /var/www/admin
sudo echo "<?php phpinfo();?>" | sudo tee -a /var/www/admin/phpinfo.php

########## Lets Encrypt Installation #################

sudo apt-get update
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install certbot -y


############################################
############## Configuration ###############
############################################


########## Configure Nginx #################

#Backup old config files
sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.old
#Copy new config files
sudo cp "$DIR"/nginx/nginx.conf /etc/nginx/
sudo cp "$DIR"/nginx/sites-available/default /etc/nginx/sites-available/
sudo cp "$DIR"/nginx/snippets/* /etc/nginx/snippets/
sudo cp "$DIR"/html/* /var/www/html
#Edit website name
sudo sed -i "s/example.com/$WEBSITE/g" /etc/nginx/sites-available/default
sudo sed -i "s/tools/$ADMINSD/g" /etc/nginx/sites-available/default
sudo sed -i "s/origin/$ORIGINSD/g" /etc/nginx/sites-available/default
sudo sed -i "s/example.com/$WEBSITE/g" /etc/nginx/snippets/ssl-example.com.conf
sudo mv /etc/nginx/snippets/ssl-example.com.conf /etc/nginx/snippets/ssl-"$WEBSITE".conf
#Make cache directory
sudo mkdir /etc/nginx/cache
sudo chown -R www-data:www-data /etc/nginx/cache
sudo chmod -R g+w /etc/nginx/cache
#Restart nginx for changes to take place
sudo service nginx restart

########## Configure Mariadb ###############

sudo echo -e "\n\n$DB_ROOTP\n$DB_ROOTP\n\n\n\n\n " | mysql_secure_installation
sudo mysql -u root -p=$DB_ROOTP <<_EOF_
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
FLUSH PRIVILEGES;
_EOF_

if [ "$DB_GLOB" = true ] ; then
  sudo mysql -u root -p=$DB_ROOTP <<_EOF_
GRANT ALL ON * . * TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
_EOF_
else
  sudo mysql -u root -p=$DB_ROOTP <<_EOF_
GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS' WITH GRANT OPTION;
FLUSH PRIVILEGES;
_EOF_
fi

########## Download WordPress ##############

cd /var/www/html/
sudo wget -c https://wordpress.org/latest.zip -O wordpress.zip
sudo unzip wordpress.zip
sudo mv wordpress/* .
sudo rm wordpress.zip
sudo rm -r wordpress
cd /

########## Php Config ######################

sudo mv /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/php.ini.old
sudo cp "$DIR"/php/php.ini /etc/php/7.2/fpm/
sudo service php7.2-fpm restart

########## Add FTP USER ####################

sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/$FTP_USER --gecos "User" $FTP_USER
sudo echo "$FTP_USER:$FTP_PASS" | chpasswd
sudo usermod -a -G www-data $FTP_USER
sudo usermod -g www-data $FTP_USER
sudo chown -R www-data:www-data /var/www
sudo chmod -R g+w /var/www

########## FTP Config ######################

sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/vsftpdserverkey.pem -out /etc/ssl/certs/vsftpdcertificate.pem -days 365
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.old
sudo cp "$DIR"/vsftpd/vsftpd.conf /etc/
sudo echo "$FTP_USER" | sudo tee -a /etc/vsftpd.userlist
sudo sed -i "s/<ip_address>/$IP/g" /etc/vsftpd.conf
sudo service vsftpd restart

########## Admin Folder Password ######################

sudo sh -c "echo -n '$ADMIN_USER:' >> /var/www/admin/.htpasswd"
sudo sh -c "openssl passwd -apr1 '$ADMIN_PASS' >> /var/www/admin/.htpasswd"
cat /var/www/admin/.htpasswd
