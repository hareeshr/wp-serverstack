
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
