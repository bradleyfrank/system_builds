# FireflyIII Install

```bash
# Create ZFS datasets
zfs create nas0/appdata/firefly
zfs create nas0/db/firefly
zfs create nas0/cache/firefly

# Create a Docker network for Firefly <-> MariaDB
docker network create firefly

# Make dataset sub-folders
mkdir /nas0/appdata/firefly/export
mkdir /nas0/appdata/firefly/upload

cd /srv/home-server/apps/firefly && docker-compose up -d
```