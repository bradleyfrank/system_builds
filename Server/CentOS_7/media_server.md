# Media Server

## Installation

1.  Download NetInstall ISO: [http://mirrors.seas.harvard.edu/centos/7/isos/x86_64/](http://mirrors.seas.harvard.edu/centos/7/isos/x86_64/ "http://mirrors.seas.harvard.edu/centos/7/isos/x86_64/")

2.  Create bootable USB:

    1.  `diskutil list`
    2.  `diskutil unmountDisk /dev/diskN`
    3.  `sudo dd if=/path/to/CentOS.iso of=/dev/diskN`

3.  Install:

    1.  Enable network
    2.  Installation source: [http://mirrors.seas.harvard.edu/centos/7/os/x86_64/](http://mirrors.seas.harvard.edu/centos/7/os/x86_64/ "http://mirrors.seas.harvard.edu/centos/7/os/x86_64/")
    3.  Software selection: Minimal
    4.  Installation destination
    5.  Make **root** password
    6.  Create user account with administrator privileges


## Housekeeping

### Update Packages

`rpm –import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7`  
`rpm –import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7`  
`yum erase NetworkManager cronie-anacron`  
`yum update`  
`yum install cifs-utils cronie-noanacron epel-release git logrotate ntp policycoreutils-python setools unzip vim wget yum-cron yum-plugin-security yum-plugin-versionlock deltarpm lsof bind-utils`


### Date and Time

`systemctl enable ntpd`  
`ntpdate pool.ntp.org`  
`systemctl start ntpd`


## Networking

Source: [http://wiki.centos.org/FAQ/CentOS7](http://wiki.centos.org/FAQ/CentOS7 "http://wiki.centos.org/FAQ/CentOS7")


### Interfaces

Edit `/etc/sysconfig/network-scripts/ifcfg-enp2s0`

  DEVICE="enp2s0"
  NAME="enp2s0"
  TYPE="Ethernet"
  BOOTPROTO="static"
  IPADDR="192.168.1.10"
  PREFIX="24"
  GATEWAY="192.168.1.1"
  ONBOOT="yes"


### Configure DNS

Edit `/etc/resolv.conf`

  search usenet.franklybrad.com.
  nameserver 192.168.1.1
  nameserver 8.8.8.8
  nameserver 8.8.4.4

Edit `/etc/hosts`

  192,168.1.10  titan.usenet.franklybrad.com titan
  192.168.1.20  neptune.usenet.franklybrad.com neptune


### Commit Changes

`hostnamectl set-hostname titan.usenet.franklybrad.com`  
`systemctl restart network`


### CIFS

`mkdir -p /mnt/nfs/{videos,scratch,backups}`

Edit `/root/.cifs`

  username=sabnzbd
  password=

`chmod 400 /root/.cifs`

Edit `/etc/fstab`

  \\neptune\Videos /mnt/nfs/videos cifs uid=sabnzbd,gid=sabnzbd,rw,credentials=/root/.cifs,_netdev 0 0
  \\neptune\Scratch /mnt/nfs/scratch cifs uid=sabnzbd,gid=sabnzbd,rw,credentials=/root/.cifs,_netdev 0 0
  \\neptune\Server /mnt/nfs/backups cifs uid=sabnzbd,gid=sabnzbd,rw,credentials=/root/.cifs,_netdev 0 0

`mount -a`


## Security

### Auto-Patching

Edit `/etc/cron.daily/yum-security.cron`

  #!/bin/sh
  yum update-minimal --security -y

`chmod 755 /etc/cron.daily/yum-security.cron`


### SSH

`mkdir /home/bfrank/.ssh && chmod 700 /home/bfrank/.ssh`  
`cat /home/bfrank/id_rsa.pub » /home/bfrank/.ssh/authorized_keys`  
`chmod 600 /home/bfrank/.ssh/authorized_keys`

Edit `/etc/ssh/sshd_config`

  PasswordAuthentication no
  PermitRootLogin no

`systemctl restart sshd`


### Firewall

`systemctl stop firewalld`  
`systemctl disable firewalld`


### SSL Certs

Sources:

* [https://github.com/Sonarr/Sonarr/wiki/SSL](https://github.com/Sonarr/Sonarr/wiki/SSL "https://github.com/Sonarr/Sonarr/wiki/SSL")

* [http://www.datadad.com.au/2014/04/custom-ssl-sabnzbd-sickbeard/](http://www.datadad.com.au/2014/04/custom-ssl-sabnzbd-sickbeard/ "http://www.datadad.com.au/2014/04/custom-ssl-sabnzbd-sickbeard/")



### Backups

`yum install rsnapshot`

Edit `/etc/rsnapshot.conf`

  snapshot_root   /mnt/nfs/backups/
  ...
  #interval       hourly  6
  interval        daily   7
  interval        weekly  4
  interval        monthly 6
  ...
  backup          /home/sabnzbd               titan.usenet.franklybrad.com/

`rsnapshot configtest`

Edit `/etc/cron.daily/rsnapshot.cron`

  #!/bin/sh
  rsnapshot daily

Edit `/etc/cron.weekly/rsnapshot.cron`

  #!/bin/sh
  rsnapshot weekly

Edit `/etc/cron.monthly/rsnapshot.cron`

  #!/bin/sh
  rsnapshot monthly


## SABnzbd

Sources:

* [https://forums.sabnzbd.org/viewtopic.php?t=4305](https://forums.sabnzbd.org/viewtopic.php?t=4305 "https://forums.sabnzbd.org/viewtopic.php?t=4305")

`groupadd sabnzbd`  
`adduser -g sabnzbd -m -s /sbin/nologin sabnzbd`

`wget https://dl.dropboxusercontent.com/u/14500830/SABnzbd/RHEL-CentOS/SABnzbd-7.repo -O /etc/yum.repos.d/SABnzbd-7.repo`  
`yum clean all && yum install SABnzbd`

`cp /home/bfrank/sabnzbd.ini /home/sabnzbd/.sabnzbd/`

`systemctl enable SABnzbd@sabnzbd.service`  
`systemctl start SABnzbd@sabnzbd.service`


## Sonarr

Sources:

* [https://github.com/Sonarr/Sonarr/wiki/CentOS-6](https://github.com/Sonarr/Sonarr/wiki/CentOS-6 "https://github.com/Sonarr/Sonarr/wiki/CentOS-6")

* [https://github.com/Sonarr/Sonarr/wiki/Fedora-20](https://github.com/Sonarr/Sonarr/wiki/Fedora-20 "https://github.com/Sonarr/Sonarr/wiki/Fedora-20")

* [https://github.com/Sonarr/Sonarr/wiki/Autostart-on-Linux](https://github.com/Sonarr/Sonarr/wiki/Autostart-on-Linux "https://github.com/Sonarr/Sonarr/wiki/Autostart-on-Linux")

* [https://www.elleryweber.com/posts/2014/143](https://www.elleryweber.com/posts/2014/143 "https://www.elleryweber.com/posts/2014/143")

* [https://github.com/Sonarr/Sonarr/wiki/Backup-and-Restore](https://github.com/Sonarr/Sonarr/wiki/Backup-and-Restore "https://github.com/Sonarr/Sonarr/wiki/Backup-and-Restore")

### Mono and prerequisites

`wget http://download.opensuse.org/repositories/home:/tpokorra:/mono/CentOS_CentOS-7/home:tpokorra:mono.repo -O /etc/yum.repos.d/mono.repo`  
`rpm –import http://download.opensuse.org/repositories/home:/tpokorra:/mono/CentOS_CentOS-7/repodata/repomd.xml.key`  
`yum clean all && yum install gettext libmediainfo libzen mediainfo mono-opt mono-opt-devel sqlite.x86_64`  
`ln -s /opt/mono/bin/mono /bin`

### Install

`wget http://download.sonarr.tv/v2/master/mono/NzbDrone.master.tar.gz -O /tmp/sonarr.tar.gz`  
`tar -xzf /tmp/sonarr.tar.gz -C /opt/`  
`chown -R sabnzbd:sabnzbd /opt/NzbDrone`

### Configure

Edit: `/usr/lib/systemd/system/sonarr.service`

  [Unit]
  Description=Sonarr Daemon
  After=syslog.target network.target

  [Service]
  User=sabnzbd
  Group=sabnzbd

  Type=simple
  ExecStart=/opt/mono/bin/mono /opt/NzbDrone/NzbDrone.exe -nobrowser -data /opt/NzbDrone
  TimeoutStopSec=20

  [Install]
  WantedBy=multi-user.target

`systemctl enable sonarr.service`  
`systemctl start sonarr.service`  
`systemctl status sonarr.service`

### Restore from backup

`systemctl stop sonarr.service`

`rm -rf /home/sabnzbd/.config/NzbDrone`  
`mkdir /home/sabnzbd/.config/NzbDrone && chown sabnzbd:sabnzbd /home/sabnzbd/.config/NzbDrone`  
`unzip /home/bfrank/nzbdrone_backup.zip -d /home/sabnzbd/.config/NzbDrone`  

`systemctl start sonarr.service`  


## Plex

Sources:

* [https://support.plex.tv/hc/en-us/articles/201370363-Move-an-Install-to-Another-System](https://support.plex.tv/hc/en-us/articles/201370363-Move-an-Install-to-Another-System "https://support.plex.tv/hc/en-us/articles/201370363-Move-an-Install-to-Another-System")

* [https://support.plex.tv/hc/en-us/articles/200288586-Installation](https://support.plex.tv/hc/en-us/articles/200288586-Installation "https://support.plex.tv/hc/en-us/articles/200288586-Installation")

`wget https://downloads.plex.tv/plex-media-server/0.9.11.17.986-269b82b/plexmediaserver-0.9.11.17.986-269b82b.x86_64.rpm` _(check version)_  
`yum localinstall plexmediaserver-0.9.11.17.986-269b82b.x86_64.rpm`

`systemctl enable plexmediaserver`  
`systemctl start plexmediaserver`



