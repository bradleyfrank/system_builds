# CentOS 6 LAMP Server

## Installation

*   Net install URL: [http://mirrors.seas.harvard.edu/centos/6/os/x86_64/](http://mirrors.seas.harvard.edu/centos/6/os/x86_64/ "http://mirrors.seas.harvard.edu/centos/6/os/x86_64/")

*   **Minimal** > Select **Base** sub-category

*   Remove unnecessary packages in **Base** sub-category

## Configuration

### Networking

`vim /etc/sysconfig/network-scripts/ifcfg-eth0`

```
DEVICE="eth0"
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
NETMASK="255.255.255.0"
IPADDR="192.168.1.100"
USERCTL="no"
```

`vim /etc/resolv.conf`

```
search franklybrad.com.
nameserver 192.168.1.1
nameserver 8.8.8.8
nameserver 8.8.4.4
```

`vim /etc/sysconfig/network`

```
NETWORKING=yes
HOSTNAME=pluto.franklybrad.com
GATEWAY=192.168.1.1
```

`vim /etc/hosts`

```
192.168.1.100 saturn.franklybrad.com saturn
192.168.1.20  neptune.franklybrad.com neptune
```

`service network restart`


### Time & Date

`chkconfig --level 345 ntpd on`
`ntpdate pool.ntp.org`
`service ntpd start`


### Users

`groupadd webadmin`
`useradd -G webadmin bfrank`
`passwd bfrank`
`visudo`

```
root	  ALL=(ALL)	ALL
bfrank	ALL=(ALL)	ALL
```

### Repositories

`rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6`
`rpm --import https://fedoraproject.org/static/0608B895.txt`
`rpm --import http://rpms.famillecollet.com/RPM-GPG-KEY-remi`
`rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt`
`rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB`

`rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm`
`rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm`
`rpm -ivh http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el6.rf.x86_64.rpm`

`wget -P /etc/yum.repos.d/ http://fedora-sabnzbd.dyndns.org/SABnzbd/RHEL-CentOS/SABnzbd-6.repo`
`vim /etc/yum.repos.d/MariaDB.repo`

```
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/5.5/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
```

`vim /etc/yum.repos.d/CentOS-Base.repo`

```
[base]
name=CentOS-$releasever - Base
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=os
#baseurl=http://mirror.centos.org/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
exclude=php* mysql*

[updates]
name=CentOS-$releasever - Updates
mirrorlist=http://mirrorlist.centos.org/?release=$releasever&arch=$basearch&repo=updates
#baseurl=http://mirror.centos.org/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6
exclude=php* mysql*
```

`vim /etc/yum.repos.d/remi.repo`

```
[remi]
name=Les RPM de remi pour Enterprise Linux $releasever - $basearch
# baseurl=http://rpms.famillecollet.com/enterprise/$releasever/remi/$basearch/
mirrorlist=http://rpms.famillecollet.com/enterprise/$releasever/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
failovermethod=priority
```

`vim /etc/yum.repos.d/rpmforge.repo`

```
[rpmforge]
name = RHEL $releasever - RPMforge.net - dag
baseurl = http://apt.sw.be/redhat/el6/en/$basearch/rpmforge
mirrorlist = http://mirrorlist.repoforge.org/el6/mirrors-rpmforge
# mirrorlist = file:///etc/yum.repos.d/mirrors-rpmforge
enabled = 1
protect = 0
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
gpgcheck = 1
```

`yum clean all`
`yum update`
`yum install acl git unzip cronie-noanacron logwatch logrotate cifs-utils fail2ban yum-plugin-security setools policycoreutils-python`
`yum erase cronie-anacron`


## Security

### SSH

`mkdir /home/bfrank/.ssh`
`touch /home/bfrank/.ssh/authorized_keys`
`chmod 700 /home/bfrank/.ssh`
`chmod 600 /home/bfrank/.ssh/authorized_keys`
`restorecon -R /home/bfrank/.ssh`
`chown -R bfrank:bfrank /home/bfrank/.ssh`
`vim /etc/ssh/sshd_config`

```
Port 1632
PermitRootLogin no
RSAAuthentication yes
PubkeyAuthentication yes
PasswordAuthentication no
```

### Firewall

`iptables -P INPUT ACCEPT`
`iptables -F`
`iptables -A INPUT -i lo -j ACCEPT`
`iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT`
`iptables -A INPUT -p tcp --dport 1632 -j ACCEPT # SSH`
`iptables -A INPUT -p tcp --dport 80 -j ACCEPT # HTTP`
`iptables -A INPUT -p tcp --dport 443 -j ACCEPT # HTTPS`
`iptables -A INPUT -p tcp --dport 9090 -j ACCEPT # SABNZBD`
`iptables -A INPUT -p tcp --dport 8989 -j ACCEPT # NZBDRONE`
`iptables -A INPUT -p tcp --dport 32400 -j ACCEPT # PLEX`
`iptables -P INPUT DROP`
`iptables -P FORWARD DROP`
`iptables -P OUTPUT ACCEPT`
`service iptables save`
`service iptables restart`
`service sshd restart`


### Monitoring

`vim /etc/logwatch/conf/logwatch.conf`

```
MailTo = bfrank
Detail = High
```

### NFS Mounts

`mkdir -p /mnt/nfs/{videos,scratch}
vim /root/.cifs`

```
username=bfrank
password=[password]
```

`chown root:root /root/.cifs`
`chmod 600 /root/.cifs`
`vim /etc/fstab`

```
root /    ext4 defaults,acl 1 1
srv  /srv ext4 defaults,acl 1 1
\\neptune\Videos /mnt/nfs/videos cifs uid=bfrank,gid=bfrank,rw,credentials=/root/.cifs,_netdev 0 0
\\neptune\Scratch /mnt/nfs/scratch cifs uid=bfrank,gid=bfrank,rw,credentials=/root/.cifs,_netdev 0 0
```

`mount -ao remount /`
`mount -ao remount /srv`


### Backups

`yum install rsnapshot`
`cp /usr/share/doc/rsnapshot-1.3.1/utils/backup_mysql.sh /usr/local/bin/`
`chmod 755 /usr/local/bin/backup_mysql.sh`
`mkdir /srv/rsnapshot`
`vim /etc/rsnapshot.conf`

```
snapshot_root   /srv/rsnapshot/

interval        daily   7
interval        weekly  4
interval        monthly 6

backup          /home/bfrank                            saturn/
backup          /etc/                                   saturn/
backup          /var/                                   saturn/
backup          /srv/                                   saturn/
backup_script   /usr/local/bin/backup_mysql.sh          saturn/mariadb/
```

`rsnapshot configtest`
`crontab -e`

```
MAILTO=bfrank
0 1 * * * yum -y --security --cve --bugfixes update
0 5 * * * rsync -a --delete /home/rsnapshot/ neptune:/volume1/Server/snapshots/
0 3 * * * rsnapshot daily
0 2 * * 1 rsnapshot weekly
0 1 1 * * rsnapshot monthly
```

`ssh-keygen -t rsa -C "root@saturn.franklybrad.com"`
`scp /root/.ssh/id_rsa.pub root@neptune:~/`


## Web Services

### Apache

`yum install httpd mod_evasive mod_ssl`
`vim /etc/httpd/conf.d/mod_evasive.conf`

```
DOSWhitelist   127.0.0.1
DOSWhitelist   192.168.1.*
```

`semanage fcontext -a -t httpd_sys_content_t "/srv/www(/.*)?"
restorecon -R -v /srv/www
mkdir /srv/www/{com-franklybrad-www,com-franklybrad-beta}
chown bfrank:webadmin /srv/www/com-franklybrad*`
`chkconfig --levels 345 httpd on`
`service httpd start`
`setfacl -m g:webadmin:rwx /var/www/html`
`chmod g+s /var/www/html`
`wget -P /var/www/html/ http://www.sourceopen.com/favicon.ico`
`vim /var/www/html/robots.txt`

```
User-Agent: *
```

`cp /etc/httpd/conf/httpd.conf{,.orig}`
`vim /etc/httpd/conf/httpd.conf`

```
ServerAdmin bradley.frank@gmail.com
ServerName www.franklybrad.com:80

ServerSignature Off
ServerTokens Prod

DocumentRoot "/srv/www"

Options -Indexes FollowSymLinks
AllowOverride All

# AddType application/x-tar .tgz
AddType application/x-httpd-php .html

# Use name-based virtual hosting.

NameVirtualHost *:80
NameVirtualHost *:443
```

`vim /etc/httpd/conf.d/com-franklybrad-www.conf`

```
ServerAdmin bradley.frank@gmail.com
DocumentRoot /srv/www/com-franklybrad-www
ServerName www.franklybrad.com

ErrorLog  /srv/www/com-franklybrad-www/logs/error_log

RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_URI} !(\.png|\.jpg|\.gif|\.jpeg|\.css|\.otf)$Misplaced &
RewriteRule ^/articles/(.+)/? /index.html?c=articles&p=$1     [PT,NC,L]
```

`vim /etc/httpd/conf.d/security.conf`

```
Header always append X-Frame-Options SAMEORIGIN
TraceEnable Off
ServerSignature Off
ServerTokens ProductOnly
Header add Strict-Transport-Security: "max-age=31536000; includeSubDomains"
Header add X-Content-Type-Options: nosniff
Header add X-XSS-Protection: "1; mode=block"
```

### SSL Certificates

`cd ~`
`openssl genrsa -des3 -out ca.key 4096`
`openssl rsa -in ca.key -out ca.key.insecure`
`mv ca.key ca.key.secure`
`mv ca.key.insecure ca.key`
`openssl req -new -key ca.key -out ca.csr`
`openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt`
`cp ca.crt /etc/pki/tls/certs/`
`cp {ca.csr,ca.key*} /etc/pki/tls/private/`
`rm /etc/pki/tls/cert.pm`
`ln -s /etc/pki/tls/certs/ca.crt /etc/pki/tls/cert.pm`
`restorecon -RvF /etc/pki`
`vim /etc/httpd/conf.d/ssl.conf`

```
SSLCertificateFile      /etc/pki/tls/certs/ca.crt
SSLCertificateKeyFile   /etc/pki/tls/private/ca.key
```

### PHP

`yum install php php-gd php-mbstring php-mcrypt php-xml php-pspell php-mysqlnd ImageMagick-last`
`cp /etc/php.ini{,.orig}`
`touch /var/log/httpd/php_error_log`
`vim /etc/php.ini`

```
disable_functions = show_source, system, shell_exec, passthru, exec, phpinfo, proc_open, proc_nice
expose_php = Off
log_errors = On
error_log = /var/log/httpd/php_error_log
allow_url_fopen = Off
date.timezone = America/New_York
```

### MariaDB

`yum install MariaDB-server MariaDB-client`
`service mysql stop`
`mv /var/lib/mysql/* /srv/mariadb/`
`rmdir /var/lib/mysql`
`ln -s /srv/mariadb /var/lib/mysql`
`semanage fcontext -a -t mysqld_db_t "/srv/mariadb(/.*)?"`
`restorecon -R -v /srv/mariadb`
`chown -R mysql:mysql /srv/mariadb`
`vim /etc/my.cnf`

```
[client]
socket = /srv/mariadb/mysql.sock

[mysqld]
bind-address = 127.0.0.1
datadir = /srv/mariadb
socket = /srv/mariadb/mysql.sock
```

`chkconfig mysql --levels 345 on`
`service mysql start`
`mysql_secure_installation`
`rm /var/lib/mysql`
`mysql -u root -p`

`mysql> RENAME USER 'root'@'localhost' to 'dbadmin'@'localhost';`
`mysql> RENAME USER 'root'@'127.0.0.1' to 'dbadmin'@'127.0.0.1';`
`mysql> RENAME USER 'root'@'::1' to 'dbadmin'@'::1';`
`mysql> FLUSH PRIVILEGES;`
`mysql> quit`

`vim /root/.my.cnf`

```
[client]
user = dbadmin
password = [password]
host = localhost
```

`chmod 0600 /root/.my.cnf`


## Web Applications

### phpMyAdmin

`yum install phpMyAdmin xorg-x11-server-Xorg xorg-x11-auth`
`mv /etc/httpd/conf.d/phpMyAdmin.conf{,.orig}`
`vim /etc/httpd/conf.d/phpMyAdmin.conf`

        DocumentRoot "/usr/share/phpMyAdmin/"
        ServerName maria.franklybrad.com
    
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
    
        DocumentRoot "/usr/share/phpMyAdmin/"
        ServerName maria.franklybrad.com
        
        Order Deny,Allow
        Deny from All
        Allow from 192.168.1.1/24
    
        SSLEngine on
        SSLCertificateFile      /etc/pki/tls/certs/ca.crt
        SSLCertificateKeyFile   /etc/pki/tls/private/ca.key

`mysql -u mariadmin -p`
`mysql> GRANT USAGE ON mysql.* TO 'pma'@'localhost' IDENTIFIED BY '[pma-password]';`
`mysql> GRANT SELECT (`
 `Host, User, Select_priv, Insert_priv, Update_priv, Delete_priv,`
 `Create_priv, Drop_priv, Reload_priv, Shutdown_priv, Process_priv,`
 `File_priv, Grant_priv, References_priv, Index_priv, Alter_priv,`
 `Show_db_priv, Super_priv, Create_tmp_table_priv, Lock_tables_priv,`
 `Execute_priv, Repl_slave_priv, Repl_client_priv`
 `) ON mysql.user TO 'pma'@'localhost';`
`mysql> GRANT SELECT ON mysql.db TO 'pma'@'localhost';`
`mysql> GRANT SELECT ON mysql.host TO 'pma'@'localhost';`
`mysql> GRANT SELECT (Host, Db, User, Table_name, Table_priv, Column_priv) ON mysql.tables_priv TO 'pma'@'localhost';`
`mysql> source /usr/share/phpMyAdmin/examples/create_tables.sql`
`mysql> GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'pma'@'localhost';`
`mysql> quit`


*   Blowfish Generator: [http://www.question-defense.com/tools/phpmyadmin-blowfish-secret-generator](http://www.question-defense.com/tools/phpmyadmin-blowfish-secret-generator "http://www.question-defense.com/tools/phpmyadmin-blowfish-secret-generator")

`cp /etc/phpMyAdmin/config.inc.php{,.orig}`
`vim /etc/phpMyAdmin/config.inc.php`

```
$cfg['blowfish_secret'] = '[passphrase]';

/* User used to manipulate with storage */
$cfg['Servers'][$i]['controlhost'] = '';
$cfg['Servers'][$i]['controluser'] = 'pma';
$cfg['Servers'][$i]['controlpass'] = '[pma-password]';

/* Storage database and tables */
$cfg['Servers'][$i]['pmadb'] = 'phpmyadmin';
$cfg['Servers'][$i]['bookmarktable'] = 'pma__bookmark';
$cfg['Servers'][$i]['relation'] = 'pma__relation';
$cfg['Servers'][$i]['table_info'] = 'pma__table_info';
$cfg['Servers'][$i]['table_coords'] = 'pma__table_coords';
$cfg['Servers'][$i]['pdf_pages'] = 'pma__pdf_pages';
$cfg['Servers'][$i]['column_info'] = 'pma__column_info';
$cfg['Servers'][$i]['history'] = 'pma__history';
$cfg['Servers'][$i]['table_uiprefs'] = 'pma__table_uiprefs';
$cfg['Servers'][$i]['tracking'] = 'pma__tracking';
$cfg['Servers'][$i]['designer_coords'] = 'pma__designer_coords';
$cfg['Servers'][$i]['userconfig'] = 'pma__userconfig';
$cfg['Servers'][$i]['recent'] = 'pma__recent';
```

`vim /etc/sshd/sshd_config`

```
# X11Forwarding no
X11Forwarding yes

vim /etc/sshd/ssh_config

Host *
ForwardX11 yes
GSSAPIAuthentication yes
Compression yes
```

### AWStats

`yum install awstats`
`cp /etc/httpd/conf.d/awstats.conf{,.orig}`
`mv /etc/awstats/awstats.localhost.localdomain.conf /etc/awstats/awstats.www.franklybrad.com.conf`
`rm /etc/awstats/awstats.saturn.franklybrad.com.conf`
`vim /etc/awstats/awstats.www.franklybrad.com.conf`

```
SiteDomain="franklybrad.com"
HostAliases="franklybrad.com localhost 127.0.0.1 REGEX[^.*franklybrad.com$]"
BuildReportFormat=xhtml
SkipFiles="robots.txtfavicon.ico$"
```

`vim /etc/httpd/conf.d/awstats.conf`

    Options None
    AllowOverride None
    Order deny,allow
    Deny from all
    Allow from 192.168.1.1/24
    Allow from 127.0.0.1


`mv /etc/logrotate.d/httpd ~/httpd.orig`
`mkdir /var/log/httpd/archive`
`vim /etc/logrotate.d/httpd`

```
/var/log/httpd/*log {
     missingok
     daily
     rotate 7
     olddir /var/log/httpd/archive
     sharedscripts
     prerotate
          /usr/share/awstats/wwwroot/cgi-bin/awstats.pl -update -config=www.franklybrad.com
     endscript
     postrotate
          /sbin/service httpd reload > /dev/null 2>/dev/null || true
     endscript
}
```

`/usr/share/awstats/wwwroot/cgi-bin/awstats.pl -update -config=www.franklybrad.com`


*   [http://www.franklybrad.com/awstats/awstats.pl?config=www.franklybrad.com](http://www.franklybrad.com/awstats/awstats.pl?config=www.franklybrad.com "http://www.franklybrad.com/awstats/awstats.pl?config=www.franklybrad.com")

### DokuWiki

`yum install dokuwiki dokuwiki-selinux`
`cp /etc/httpd/conf.d/dokuwiki.conf{,.conf.orig}`
`vim /etc/httpd/conf.d/dokuwiki.conf`

```
Alias /wiki /usr/share/dokuwiki
     Options +FollowSymLinks
     Order Allow,Deny
     Allow from all
```

`wget -P /usr/share/dokuwiki/lib/plugins/ http://github.com/downloads/cpjobling/plugin-cli/plugin-cli.zip`
`unzip -d /usr/share/dokuwiki/lib/plugins/ /usr/share/dokuwiki/lib/plugins/plugin-cli.zip`
`mv /usr/share/dokuwiki/lib/plugins/{plugin-cli,cli}`
`rm -f /usr/share/dokuwiki/lib/plugins/plugin-cli.zip`
`mv /etc/dokuwiki/local.php{,.orig}`
`vim /etc/dokuwiki/local.php`

*Incomplete.*

