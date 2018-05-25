
## Advanced LEMP Server-Stack for use with Full Site Delivery CDN

This simple script installs a LEMP stack on your server.

The server stack:
- Fast CGI Cache at the front caching all dynamic pages
- Nginx server used as its just awesome
- PHP 7.2
- MariaDB for database
- Ubuntu 16.04 running the show

#### Prerequisites

- Install git
```
sudo apt-get install git-core
```
- Open Network Ports - 21(SFTP), 22(SSH), 80(HTTP), 443(HTTPS), 5062(For Admin Panel), 40000:42000(Passive Connection for FTP)

#### Full Site Delivery CDN

This Setup is tested with Google CDN and Amazon CloudFront CDN.

#### How to install
```
sudo git clone https://github.com/hareeshr/wp-serverstack
sudo chmod 755 wp-serverstack/install.sh
sudo ./wp-serverstack/install.sh
```

Note: To install manually(Interactive mode):
- clone this repository
- open -manual.sh file and copy-paste blocks of code with relevant changes in ssh client

#### Parameters
The script uses several parameters to setup your server
for example: the website name, FTP username, Database Name

| Option | Type | Description | Default Value
| ------ | ------ | ----- | ----- |
| -w or --website | String | Website name | example.com |
| -ip or --ip | String | Public IP Address | 127.0.0.1 |
| -dbrp or --dbrootpass | String | Database root password | rootpass |
| -dbu or --dbuser  | String | Database Username | db_user |
| -dbn or --dbname  | String | Database name | db_name |
| -dbp or --dbpass  | String | Database Password | db_pass |
| -dbg or --dbglobal  | Boolean | Database Global Access - Do the user have access to all databases? | false |
| -ftpu or --ftpuser  | String | FTP Username | ftpuser |
| -ftpp or --ftppass  | String | FTP Password | ftppass |
| -asd or --adminsd  | String | Admin SubDomain | tools |
| -au or --adminuser  | String | Admin Username | adminname |
| -ap or --adminpass  | String | Admin Password | adminpass |
| -osd or --originsd  | String | Origin SubDomain for CDN | origin |


**Installation Example**
```
./install.sh -w=example.com ip=127.0.0.1 -ftpu=MYFTP -ftpp=MYPASS
```

#### What are installed?

- NGINX
- PHP 7.2
- MariaDb
- VsFTPd
- phpMyAdmin
- Adminer
- Basic File Manager
- Net2FTP
- Simple Control Panel

#### Simple Control Panel

Control panel can be accessed by
https://ip:5062
or
https:tools.example.com:5062

Control Panel is secured by Basic HTTP Authentication.
The user credentials are set using the parameters Admin Username and Password(or use default username password which is obviously not secure).

#### Let's encrypt/Certbot

Use ssl-dns-route53.sh to install certbot and issue SSL certificates automatically by DNS challenge with AWS Route53 Integration.
This requires a IAM user with valid Access Key and Secret having access to AmazonRoute53FullAccess Policy

**Usage Example**
```
./ssl-dns-route53.sh -w=example.com -rak=access_key -ras=access_secret
```

**Parameters**

| Option | Type | Description | Default Value
| ------ | ------ | ----- | ----- |
| -w or --website | String | Website name | example.com |
| -asd or --adminsd  | String | Admin SubDomain | tools |
| -osd or --originsd  | String | Origin SubDomain for CDN | origin |
| -rak or --r53-access-key  | String | AWS Access Key | Null |
| -ras= or --r53-access-secret  | String | AWS Access Secret | Null |

For other DNS services use ssl-dns.sh with same parameters as above (excluding AWS credentials). In this method, you'll be asked to manually add TXT record for your domains and subdomains for verification.

You may also use ssl-dns-route53-manual.sh and ssl-dns-manual.sh files to copy paste to SSH console manually to have more control.

**Certbot Renewal**

Only route53 method is eligible to renew as the other method is a manual process.
You can test run renewal by running
```
certbot renew --dry-run
```

If the test run is success, you can now actually renew the certificates
```
certbot -q renew --renew-hook 'service nginx reload'
```

You may also add this to your crontab to run the renewal script periodically
```
#open crontab
crontab -e
#select 2 to select nano
#add the following to the bottom and save - CTLR+X
30 2 * * 1 certbot -q renew --renew-hook 'service nginx reload'
```

#### Useful SSH Commands

| Option | Description |
| ------ | ------ |
| sudo netstat -plnt | Check running ports |
| sudo rm file | remove file |
| sudo rm -d folder/ | remove directory |
| sudo rm -d -rf folder/ | remove directory recursively |
| sudo cp inifile destfolder/ | copy file |
| sudo cp -r inifolder/* destfolder/ | copy recursively |
| sudo unzip myzip.zip | unzip file |
| sudo zip -r myfiles.zip folder | zip folder recursively |
| du -m filename | size of filename |
| wget -c remotefile | download remote file |
| wget -c remotefile -O renamefile | download remote file and rename |
| sudo chown -R www-data:www-data /var/www | set owner user and group of folder |
| sudo chmod -R g+w /var/www | grant permission |
| tail -f /var/log/nginx/error.log | nginx error log |
| >/var/log/nginx/error.log | empty nginx error log |
| crontab -l | list all cronjob |
| crontab -e | open crontab file |
| sudo rm -d -rf /etc/nginx/cache | purge cache |
| certbot certificates | list all ssl certificates |
| certbot delete --cert-name website.com | delete ssl certificate for website.com |
| certbot renew --dry-run | test run SSL renewal script |

```
#run SSL renewal script
certbot -q renew --renew-hook 'service nginx reload'

#cronjob
crontab -e
30 2 * * 1 certbot -q renew --renew-hook 'service nginx reload'

#nginx service commands
sudo systemctl status nginx.service
sudo systemctl stop nginx.service
sudo systemctl start nginx.service
sudo systemctl restart nginx.service
sudo systemctl enable nginx.service

#PHP service commands
sudo systemctl status php7.2-fpm
sudo systemctl stop php7.2-fpm
sudo systemctl start php7.2-fpm
sudo systemctl restart php7.2-fpm
sudo systemctl enable php7.2-fpm

#MySQL service commands
sudo systemctl status mysql.service
sudo systemctl stop mysql.service
sudo systemctl start mysql.service
sudo systemctl restart mysql.service
sudo systemctl enable mysql.service

#VsFTPd service commands
sudo systemctl status vsftpd.service
sudo systemctl stop vsftpd.service
sudo systemctl start vsftpd.service
sudo systemctl restart vsftpd.service
sudo systemctl enable vsftpd.service
```
