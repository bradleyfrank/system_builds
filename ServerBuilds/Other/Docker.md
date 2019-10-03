# Docker Server

## System Configuration

### Networking

```
hostnamectl set-hostname app-server.francopuccini.casa
nmcli con add type ethernet con-name main ifname em1 ip4 192.168.1.5/24 gw4 192.168.1.1
nmcli con mod main ipv4.dns "192.168.1.1 8.8.8.8 8.8.4.4"
nmcli con up main
```

### Time & Date

```
systemctl enable chronyd && systemctl restart chronyd
timedatectl set-timezone America/New_York
chronyc makestep
```

### Packages

```
yum update -y
yum install -y epel-release centos-release-scl
yum install -y \
	bind-utils \
	cifs-utils \
	cronie-noanacron \
	device-mapper-persistent-data \
	docker-compose \
	git \
	glances \
	htop \
	lvm2 \
	mdadm \
	ncdu \
	nmap \
	ntp \
	pciutils \
	perf \
	policycoreutils-python \
	python34 \
	rh-git29-git \
	setools \
	strace \
	unzip \
	vim \
	wget \
	yum-plugin-security \
	yum-utils
yum remove -y cronie-anacron
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

### SSH

```
systemctl enable sshd && systemctl start sshd
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
# upload ssh keys
sed -i \
	-e 's/#PermitRootLogin yes/PermitRootLogin no/' \
	-e 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

### Firewall

```
systemctl enable firewalld && systemctl start firewalld
firewall-cmd --permanent --add-service=http --add-service=https --add-service=ssh
firewall-cmd --reload
```

### Raid & LVM

```
# find additional drives; fill in for X and Y
lsblk -no NAME,SIZE
sdx="sdX" && sdy="sdY"
parted -s /dev/$sdx mklabel GPT && parted -s /dev/$sdy mklabel GPT
parted -s /dev/$sdx mkpart primary 2048s 100% && parted -s /dev/$sdy mkpart primary 2048s 100%
parted -s /dev/$sdx set 1 raid on && parted -s /dev/$sdy set 1 raid on
```

```
yes | mdadm -Cv /dev/md/raid1 /dev/${sdx}1 /dev/${sdy}1 --level=1 --raid-devices=2
```
```
pvcreate /dev/md/raid1
# appdata volumes
vgcreate appdata /dev/md/raid1
lvcreate -L 10G -n plex appdata
lvcreate -L 100G -n nextcloud appdata
lvcreate -L 50G -n docker appdata
lvcreate -L 5G -n traefik appdata
lvcreate -L 5G -n transmission appdata
# userdata volumes
vgcreate userdata /dev/md/raid1
lvcreate -L 250G -n bt_downloads userdata
lvcreate -L 5G -n bt_watch userdata
```

```
appdata_vols=(plex nextcloud traefik transmission)
userdata_vols=(bt_downloads bt_watch)
# special format docker
mkfs -t xfs -n ftype=1 /dev/mapper/appdata-docker
# format volumes
for lv in "${appdata_vols[@]}"; do mkfs -t xfs /dev/mapper/appdata-"$lv"; done
for lv in "${userdata_vols[@]}"; do mkfs -t xfs /dev/mapper/userdata-"$lv"; done
```

### Users

```
adduser plex --system --user-group --shell /sbin/nologin --home-dir /srv/plex --no-create-home
```

### Mount Points

```
mkdir -p /srv/{media,plex,nextcloud,traefik} /var/lib/docker
```

```
cat << EOF > /srv/.nas-media
username=plex
password=$password
EOF
chmod 400 /srv/.nas-media
```

```
cat << EOF >> /etc/fstab
\\192.168.1.20\Plex /srv/media cifs uid=plex,gid=plex,credentials=/srv/.nas-media,_netdev 0 0
UUID=$(lsblk /dev/appdata/plex -no UUID) /srv/plex xfs defaults 0 0
UUID=$(lsblk /dev/appdata/nextcloud -no UUID) /srv/nextcloud xfs defaults 0 0
UUID=$(lsblk /dev/appdata/traefik -no UUID) /srv/traefik xfs defaults 0 0
UUID=$(lsblk /dev/appdata/docker -no UUID) /var/lib/docker xfs defaults 0 0
EOF
```

```
mount -a
```

## Containers

### Installation

```
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable docker && systemctl start docker
```

### Setup

```
docker volume create portainer_data
docker volume create nextcloud_db
docker network create web
```

```
git clone git@github.com:bradleyfrank/docker-server.git /opt/compose
```

```
touch /srv/traefik/acme.json && chmod 600 /srv/traefik/acme.json
```