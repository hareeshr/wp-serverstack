
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
