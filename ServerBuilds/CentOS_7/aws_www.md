# CentOS 7 Server

## Configuration

### Users

`sudo passwd centos`

### Additional Repositories

`rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7`
`rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm`
`yum remove cronie-anacron`
`yum install epel-release centos-release-scl-rh scl-utils`
`yum clean all`
`yum update`
`yum install vim git wget tmux ntp cronie-noanacron logrotate yum-plugin-security setools policycoreutils-python unzip firewalld`


### Time & Date

`timedatectl set-timezone America/New_York`
`systemctl enable ntpd`
`systemctl start ntpd`


## Security


### Firewall

`firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 22 -j ACCEPT`
`firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 80 -j ACCEPT`
`firewall-cmd --permanent --direct --add-rule ipv4 filter INPUT 0 -p tcp --dport 443 -j ACCEPT`
`firewall-cmd --reload`


## Web

### Nginx

`yum install nginx`
`systemctl enable nginx`
`systemctl start nginx`


### PHP

`yum install php55 php-mysqlnd php-fpm ImageMagick-last`

Edit `/etc/php.ini`

    disable_functions = show_source, system, shell_exec, passthru, exec, phpinfo, proc_open, proc_nice
    expose_php = Off
    allow_url_fopen = Off
    cgi.fix_pathinfo=0
    date.timezone = America/New_York

`mv /etc/php-fpm.d/www.conf{,.bak}`
`systemctl enable php-fpm`
`systemctl start php-fpm`


## Applications

### Dokuwiki

`mkdir /var/www/html/com-franklybrad-wiki`
`wget -P /tmp/ http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz`
`tar -xzf /tmp/dokuwiki-stable.tgz -C /var/www/html/com-franklybrad-wiki/`

`semanage fcontext -a -t httpd_sys_rw_content_t "/var/www/html/com-franklybrad-wiki(/.*)?"`
`restorecon -R -v /var/www/html/com-franklybrad-wiki`

Edit `/etc/php-fpm.d/com-franklybrad-wiki.conf`

    [com-franklybrad-wiki]
    listen = /var/run/php-fpm/com-franklybrad-wiki.sock
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    user = bfrank
    group = bfrank
    pm = dynamic
    pm.max_children = 50
    pm.start_servers = 5
    pm.min_spare_servers = 5
    pm.max_spare_servers = 35
    ;pm.max_requests = 500
    pm.status_path = /status
    ping.path = /ping
    ;ping.response = pong
    request_terminate_timeout = 120s
    request_slowlog_timeout = 5s
    slowlog = /var/log/php-fpm/www-slow.log
    ;rlimit_files = 1024
    ;rlimit_core = 0
    ;catch_workers_output = yes
    security.limit_extensions = .php

`mkdir /var/log/nginx/com-franklybrad-wiki`
`touch /var/log/nginx/com-franklybrad-wiki/{error,access}.log`

Edit `/etc/nginx/conf.d/com-franklybrad-wiki.conf`

    server {
        server_name wiki.franklybrad.com;
        listen 80;
        autoindex off;
        client_max_body_size 15M;
        client_body_buffer_size 128k;
        index index.html index.htm index.php doku.php;
        access_log  /var/log/nginx/com-franklybrad-wiki/access.log;
        error_log  /var/log/nginx/com-franklybrad-wiki/error.log;
        root /var/www/html/com-franklybrad-wiki;
    
        location / {
          try_files $uri $uri/ @dokuwiki;
        }
    
        location ~ ^/lib.*\.(gif|png|ico|jpg){
          expires 30d;
        }
    
        location = /robots.txt  { access_log off; log_not_found off; }
        location = /favicon.ico { access_log off; log_not_found off; }
        location ~ /\.          { access_log off; log_not_found off; deny all; }
        location ~ ~          { access_log off; log_not_found off; deny all; }
    
        location @dokuwiki {
          rewrite ^/_media/(.*) /lib/exe/fetch.php?media=$1 last;
          rewrite ^/_detail/(.*) /lib/exe/detail.php?media=$1 last;
          rewrite ^/_export/([^/]+)/(.*) /doku.php?do=export_$1&id=$2 last;
          rewrite ^/(.*) /doku.php?id=$1 last;
        }
    
        location ~ \.php{
          try_files $uri =404;
          fastcgi_pass   unix:/var/run/php-fpm/com-franklybrad-wiki.sock;
          fastcgi_index  index.php;
          fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include /etc/nginx/fastcgi_params;
          fastcgi_param  QUERY_STRING     $query_string;
          fastcgi_param  REQUEST_METHOD   $request_method;
          fastcgi_param  CONTENT_TYPE     $content_type;
          fastcgi_param  CONTENT_LENGTH   $content_length;
          #fastcgi_intercept_errors        on;
          fastcgi_ignore_client_abort     off;
          fastcgi_connect_timeout 60;
          fastcgi_send_timeout 180;
          fastcgi_read_timeout 180;
          fastcgi_buffer_size 128k;
          fastcgi_buffers 4 256k;
          fastcgi_busy_buffers_size 256k;
          fastcgi_temp_file_write_size 256k;
        }
    
        location ~ /(data|conf|bin|inc)/ {
          deny all;
        }
    
        location ~ /\.ht {
          deny all;
        }
    }


### WordPress

`wget https://wordpress.org/latest.tar.gz`
`tar xzf latest.tar.gz`

`mysql -u root -p`

`mysql> CREATE USER 'wordpress'@'%' IDENTIFIED BY '****' ;`
`mysql> GRANT USAGE ON * . * TO 'wordpress'@'%' IDENTIFIED BY '****' WITH MAX_QUERIES_PER_HOUR 0 MAX_CONNECTIONS_PER_HOUR 0 MAX_UPDATES_PER_HOUR 0 MAX_USER_CONNECTIONS 0 ;`
`mysql> CREATE DATABASE IF NOT EXISTS `wordpress` ;`
`mysql> GRANT ALL PRIVILEGES ON `wordpress` . * TO 'wordpress'@'%' ;`
`mysql> REVOKE DROP, ALTER, GRANT OPTION ON `wordpress` . * FROM 'wordpress'@'%' ;`
`mysql> FLUSH PRIVILEGES ;`

`mkdir /var/log/php-fpm/com-franklybrad-blog`
`touch /var/log/php-fpm/com-franklybrad-blog/php-error.log`

Edit `/etc/php-fpm.d/com-franklybrad-blog.conf`

    listen = /var/run/php-fpm/com-franklybrad-blog.sock
    ;listen.allowed_clients =
    listen.owner = nginx
    listen.group = nginx
    listen.mode = 0660
    user = bfrank
    group = bfrank
    pm = dynamic
    pm.max_children = 50
    pm.start_servers = 5
    pm.min_spare_servers = 5
    pm.max_spare_servers = 35
    ;pm.max_requests = 500
    pm.status_path = /status
    ping.path = /ping
    ;ping.response = pong
    request_terminate_timeout = 120s
    request_slowlog_timeout = 5s
    slowlog = /var/log/php-fpm/www-slow.log
    ;rlimit_files = 1024
    ;rlimit_core = 0
    ;catch_workers_output = yes
    security.limit_extensions = .php
    php_admin_value[error_log] = /var/log/php-fpm/com-franklybrad-blog/php-error.log
    php_admin_flag[log_errors] = on
    php_value[session.save_handler] = files
    php_value[session.save_path]    = /var/lib/php/session
    php_value[soap.wsdl_cache_dir]  = /var/lib/php/wsdlcache

`mkdir /var/log/nginx/com-franklybrad-blog/`
`touch /var/log/nginx/com-franklybrad-blog/{error.log,access.log}`

1.  [Generate salts](https://api.wordpress.org/secret-key/1.1/salt/ "https://api.wordpress.org/secret-key/1.1/salt/")
2.  Set database connection settings
3.  Force SSL

Edit `/var/www/html/com-franklybrad-blog/wp-config.php`

    define('FORCE_SSL_ADMIN', true);

Edit `/etc/nginx/conf.d/com-franklybrad-blog.conf`

    server {
        listen 80;
        server_name blog.franklybrad.com;
        return 301 https://blog.franklybrad.com$request_uri;
    }
    
    server {
        listen 443;
        server_name blog.franklybrad.com;
        root /var/www/html/com-franklybrad-blog;
        index index.php index.html;
    
        # Set access and error log.
        access_log  /var/log/nginx/com-franklybrad-blog/access.log;
        error_log  /var/log/nginx/com-franklybrad-blog/error.log;
    
        # Define SSL certs.
        ssl on;
        ssl_certificate /etc/nginx/ssl/franklybrad.crt;
        ssl_certificate_key /etc/nginx/ssl/franklybrad.key;
    
        # Attempts to match last if rules below fail.
        # http://wiki.nginx.org/HttpCoreModule
        location / {
        	try_files $uri $uri/ /index.php?$args;
        }
    
        # Add trailing slash to */wp-admin requests.
        rewrite /wp-admin$scheme://$host$uri/ permanent;
    
        # Pass all .php files onto a php-fpm/php-fcgi server.
        location ~ [^/]\.php(/|$) {
        	fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        	if (!-f $document_root$fastcgi_script_name) {
        		return 404;
        	}
    
        	# Robust solution for path info security issue;
            # Works with "cgi.fix_pathinfo = 1" in /etc/php.ini
        	include fastcgi.conf;
        	fastcgi_index index.php;
        	fastcgi_pass unix:/var/run/php-fpm/com-franklybrad-blog.sock;
        }
    
        # Prevent access to Apache .htaccess/.htpasswd files.
        location ~ /\.ht {
            deny  all;
        }
    
        # Do not log favicon, robots, or image not found requests.
        location = /favicon.ico {
            log_not_found off;
            access_log off;
        }
    
        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }
    
        location ~* \.(js|css|png|jpg|jpeg|gif|ico){
            expires max;
            log_not_found off;
        }
    
        # http://blog.bigdinosaur.org/wordpress-on-nginx/
        # Help prevent access to not-public areas.
        location ~* wp-admin/includes { deny all; }
        location ~* wp-includes/theme-compat/ { deny all; }
        location ~* wp-includes/js/tinymce/langs/.*\.php { deny all; }
        location /wp-content/ { internal; }
        location /wp-includes/ { internal; }
        location ~* wp-config.php { deny all; }
    
        # Prevent files in the uploads directory from being executed
        # by forcing their MIME type to text/plain.
        location ~* ^/wp-content/uploads/.*.(html|htm|shtml|php|js|swf){
            types { }
            default_type text/plain;
        }
    
        # Redirect 403 errors to 404 error to fool attackers.
        error_page 403 = 404;
    }

`chown -R bfrank:bfrank /var/www/html/com-franklybrad-blog`
`chmod -R 755 /var/www/html/com-franklybrad-blog`
`restorecon -R /var/www/html/com-franklybrad-blog/*`


*   [General WordPress rules](http://codex.wordpress.org/Nginx "http://codex.wordpress.org/Nginx")

*   [Abridged basic setup](http://wiki.nginx.org/WordPress "http://wiki.nginx.org/WordPress")

*   [Installing WordPress](http://codex.wordpress.org/Installing_WordPress "http://codex.wordpress.org/Installing_WordPress")

*   [Hardening WordPress](http://codex.wordpress.org/Hardening_WordPress "http://codex.wordpress.org/Hardening_WordPress")

*   [Secure WordPress with Nginx](http://www.queryadmin.com/854/secure-wordpress-nginx/ "http://www.queryadmin.com/854/secure-wordpress-nginx/")

*   [WordPress over SSL](http://codex.wordpress.org/Administration_Over_SSL "http://codex.wordpress.org/Administration_Over_SSL") and ([Use SSL_FORCE_ADMIN](http://codex.wordpress.org/Version_4.0#Deprecated_2 "http://codex.wordpress.org/Version_4.0#Deprecated_2"))

