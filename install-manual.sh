
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

sudo mkdir /var/www/admin/filemanager
cd /var/www/admin/filemanager
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

sudo cp -r /tmp/wp-serverstack/admin/* /var/www/admin
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
sudo cp /tmp/wp-serverstack/nginx/nginx.conf /etc/nginx/
sudo cp /tmp/wp-serverstack/nginx/sites-available/default /etc/nginx/sites-available/
sudo cp /tmp/wp-serverstack/nginx/snippets/* /etc/nginx/snippets/
sudo cp /tmp/wp-serverstack/html/* /var/www/html
#Edit website name
#change website.com to your domain.com
sudo sed -i "s/example.com/website.com/g" /etc/nginx/sites-available/default
sudo sed -i "s/example.com/website.com/g" /etc/nginx/snippets/ssl-example.com.conf
#change admin to your subdomain
sudo sed -i "s/tools/admin/g" /etc/nginx/sites-available/default
#change website to your domain
sudo mv /etc/nginx/snippets/ssl-example.com.conf /etc/nginx/snippets/ssl-website.com.conf
#Make cache directory
sudo mkdir /etc/nginx/cache
sudo chown -R www-data:www-data /etc/nginx/cache
sudo chmod -R g+w /etc/nginx/cache
#Restart nginx for changes to take place
sudo service nginx restart

########## Configure Mariadb ###############

#change db_name to Database Name
#change db_user to Database User
#change db_pass to Database Password
sudo mysql_secure_installation
-> #type root password twice
sudo mysql -u root
-> #type root password
-> CREATE DATABASE db_name;
-> CREATE USER 'db_user'@'localhost' IDENTIFIED BY 'db_pass';
#if you want to grant global permission
-> GRANT ALL ON * . * TO 'db_user'@'localhost';
#if you want to grant permission to one database
-> GRANT ALL ON db_name.* TO 'db_user'@'localhost' IDENTIFIED BY 'db_pass' WITH GRANT OPTION;
-> FLUSH PRIVILEGES;
-> EXIT;

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
sudo cp /tmp/wp-serverstack/php/php.ini /etc/php/7.2/fpm/
sudo service php7.2-fpm restart

########## Add FTP USER ####################

#change ftpuser to Username for FTP
#change ftppass to Password for FTP
sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/ftpuser --gecos "User" ftpuser
sudo echo "ftpuser:ftppass" | chpasswd
sudo usermod -a -G www-data ftpuser
sudo usermod -g www-data ftpuser
sudo chown -R www-data:www-data /var/www
sudo chmod -R g+w /var/www

########## FTP Config ######################

#change ftpuser to Username for FTP
sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/vsftpdserverkey.pem -out /etc/ssl/certs/vsftpdcertificate.pem -days 365
sudo mv /etc/vsftpd.conf /etc/vsftpd.conf.old
sudo cp /tmp/wp-serverstack/vsftpd/vsftpd.conf /etc/
sudo echo "ftpuser" | sudo tee -a /etc/vsftpd.userlist
#change 127.0.0.1 to your ip
sudo sed -i "s/<ip_address>/127.0.0.1/g" /etc/vsftpd.conf
sudo service vsftpd restart

########## Admin Folder Password ######################

#change adminname to Username for Admin Panel
#change adminpass to Password for Admin Panel
sudo sh -c "echo -n 'adminname:' >> /var/www/admin/.htpasswd"
sudo sh -c "openssl passwd -apr1 'adminpass' >> /var/www/admin/.htpasswd"
cat /var/www/admin/.htpasswd
