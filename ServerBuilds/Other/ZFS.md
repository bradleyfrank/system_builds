# ZFS

Remove any existing partitions from the target disks.

```bash
# note the appropriate disk IDs (e.g. ata-WDC...) and device names (e.g. sda, sdb)
ls -l /dev/disk/by-id
# create a new partition table
parted -s /dev/$sdx mklabel GPT
parted -s /dev/$sdy mklabel GPT
```

Create the ZFS pool.

```bash
# mounts the pool to /srv
zpool create -f zpool1 -m /srv mirror $ata1 $ata2
```

Create the ZFS file systems.

```bash
# appdata
zfs create zpool1/appdata
zfs create -o quota=25G zpool1/appdata/nextcloud
zfs create -o quota=10G zpool1/appdata/plex
zfs create -o quota=5G zpool1/appdata/traefik
zfs create -o quota=5G zpool1/appdata/transmission
zfs create -o quota=5G zpool1/appdata/portainer
# userdata
zfs create zpool1/userdata
zfs create -o quota=250G zpool1/userdata/downloads
zfs create -o quota=100G zpool1/userdata/nextcloud
# databases
zfs create zpool1/db
zfs create -o quota=50G zpool1/db/nextcloud
# temp
zfs create zpool1/temp
zfs create zpool1/temp/transcode
```