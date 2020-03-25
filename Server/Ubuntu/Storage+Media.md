# Storage & Media Server

## System Configs

### Networking

```bash
hostnamectl set-hostname deep-thought.francopuccini.casa
```

### SSH

```bash
sed -i \
	-e 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' \
	-e 's/^PasswordAuthentication yes/PasswordAuthentication no/' \
	/etc/ssh/sshd_config
# ssh-copy-id -i ~/.ssh/id_home.pub 192.168.1.40
systemctl restart sshd
```

### Firewall

```bash
ufw default allow outgoing ; ufw default deny incoming
ufw allow ssh && \
  ufw allow http && \
  ufw allow https && \
  ufw allow nfs
ufw enable
ufw logging on
```

### Packages

```bash
apt upgrade -y
apt install -y \
  borgbackup \
  chrony \
  cifs-utils \
  git \
  glances \
  htop \
  linux-tools-generic \
  makepasswd \
  ncdu \
  nmap \
  pciutils \
  ssmtp \
  strace \
  trash-cli \
  tmux \
  unzip \
  vim \
  wget \
  zfsutils-linux 
```

```bash
wget -P /usr/local/bin/ https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
chmod 755 /usr/local/bin/diff-so-fancy
```

### Time & Date

```bash
systemctl start chronyd
timedatectl set-timezone America/New_York
chronyc makestep
```

### Logging

```bash
sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
systemctl restart systemd-journald.service
```

## Data Structure

Remove any existing partitions from the target disks.

```bash
lsblk -o SIZE,TYPE,NAME -I 8 -d
parted -s /dev/sdX mklabel GPT
parted -s /dev/sdY mklabel GPT
...
parted -s /dev/sdN mklabel GPT
```

Get disk identifiers (see [Selecting /dev/ names when creating a pool](https://github.com/openzfs/zfs/wiki/faq#selecting-dev-names-when-creating-a-pool)):

```
ls -lh /dev/disk/by-id/ | grep sd[a-z]$
```

Create striped mirrored VDEVs:

```bash
zpool create -f nas0 \
  mirror \
    ata-Hitachi_HDS5C3020ALA632_ML4220F316DDPK \
    ata-Hitachi_HDS5C3020ALA632_ML4220F317KSSK \
  mirror \
    ata-HGST_HUS724040ALA640_PN1334PBJWZZGS \
    ata-HGST_HDN724040ALE640_PK2338P4H4Y7AC
```

Create the ZFS file systems.

```bash
# appdata
zfs create nas0/appdata
zfs create nas0/appdata/nextcloud
zfs create nas0/appdata/plex
zfs create nas0/appdata/jellyfin
zfs create nas0/appdata/traefik
# userdata
zfs create nas0/userdata
zfs create nas0/userdata/media
zfs create nas0/userdata/family
zfs create nas0/userdata/software
zfs create nas0/userdata/7030726e
# databases
zfs create nas0/db
zfs create nas0/db/nextcloud
# temp
zfs create nas0/temp
zfs create nas0/temp/transcode
# homes
zfs create nas0/homes
zfs create nas0/homes/bfrank
```

## Containers

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
 "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt install -y containerd.io docker-ce docker-ce-cli docker-compose
systemctl enable --now docker
```

```bash
ssh-keygen -t rsa -b 4096 -N "" -C "$(uname -n)" -f /root/.ssh/id_rsa
# add deploy key to repo
mkdir -p /srv/docker && cd /srv/docker
git clone git@github.com:bradleyfrank/container-apps.git
```

```bash
docker network create proxy
docker network create nextcloud
```

### Traefik

```bash
mkdir -p /nas0/appdata/traefik/acme
touch /nas0/appdata/traefik/acme/acme.json
chmod 0600 /nas0/appdata/traefik/acme/acme.json
cd /srv/docker/container-apps/traefik && docker-compose up -d
```

### Nextcloud

```bash
cd /opt/docker/compose/nextcloud && docker-compose up -d
# make Nextcloud aware of https proxy
sed -i \
  -e "/'overwrite.cli.url'/a \  'overwriteprotocol' => 'https'," \
  -e "s/'overwrite.cli.url' => 'http:/'overwrite.cli.url' => 'https:/" \
  /srv/appdata/nextcloud/config/config.php
sudo docker exec -it nextcloud service apache2 restart
```

### Plex

1. Get Plex claim code: https://www.plex.tv/claim
2. Update `plex/docker-compose` with claim code

```bash
cd /opt/docker/compose/plex && docker-compose up -d
```