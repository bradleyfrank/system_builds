# Mac Webstack

1. `brew tap homebrew/php`
2. `brew install dnsmasq nginx php71`
3. `echo "conf-dir=/usr/local/etc/dnsmasq.d/,*.conf" >> /usr/local/etc/dnsmasq.conf`
4. `ln -s ~/Development/sysconfigs/dnsmasq/local.conf /usr/local/etc/dnsmasq.d/local.conf`
5. `sudo mkdir /etc/resolver`
6. `sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'`
7. `sed -i'' -e 's/^daemonize.*/daemonize = yes/' /usr/local/etc/php/7.1/php-fpm.conf`
8. `sudo brew services start dnsmasq nginx php71`