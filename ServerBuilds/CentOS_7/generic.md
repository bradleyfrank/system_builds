# CentOS 7 Server


## Networking

`hostnamectl set-hostname frankflix.plex.franklybrad.com`

```
TYPE="Ethernet"
DEVICE="<name>"
BOOTPROTO=none
DEFROUTE="yes"
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
NAME="<name>"
ONBOOT="yes"
NM_CONTROLLED="yes"
HWADDR=<mac>
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
UUID=<uuid>
DNS1=192.168.1.X
DNS2=8.8.8.8
DNS3=8.8.4.4
IPADDR=192.168.1.X
PREFIX=24
GATEWAY=192.168.1.X
```

`systemctl stop NetworkManager`
`systemctl restart network`


## Packages

`yum update`
`yum remove NetworkManager cronie-anacron`
`yum clean all`
`yum install epel-release centos-release-scl`
`yum install git vim htop perf strace nmap ntp pciutils cronie-noanacron wget yum-plugin-security setools policycoreutils-python unzip logwatch bind-utils cifs-utils openldap-clients nss-pam-ldapd`


## Time & Date

`systemctl enable ntpd`
`ntpdate pool.ntp.org`
`systemctl start ntpd`


## CIFS

`mkdir -p /srv/{media,backups}`

`/root/.cifs`

	username=plex
	password=<password>

`chmod 400 /root/.cifs`

`/etc/fstab`

	\\192.168.1.20\Plex		/srv/media	cifs	uid=plex,gid=plex,credentials=/root/.cifs,_netdev   0 0

`mount -a`


## SSH

`touch ~/.ssh/authorized_keys`
`chmod 600 ~/.ssh/authorized_keys`

`/etc/ssh/sshd_config`

	Port 2232
	PermitRootLogin no
	PasswordAuthentication no

`semanage port -a -t ssh_port_t -p tcp 2232`
`systemctl restart sshd`


## Firewall

`systemctl enable firewalld`
`systemctl start firewalld`
`firewall-cmd --permanent --zone=public --add-port=2232/tcp`
`firewall-cmd --permanent --zone=public --add-port=32400/tcp`
`firewall-cmd --reload`


## Monitoring

`/etc/logwatch/conf/logwatch.conf`

	MailTo = bfrank
	Detail = High