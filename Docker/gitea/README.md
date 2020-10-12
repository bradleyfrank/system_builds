# Gitea Install

```bash
# Firewall to open custom SSH port
ufw allow 322
ufw enable

# Create ZFS datasets
zfs create nas0/appdata/gitea
zfs create nas0/db/gitea

# Create a local account for the Gitea container to use
groupadd --gid 10100 git
useradd \
  --comment "Gitea user for SSH" \
  --shell /usr/sbin/nologin \
  --create-home \
  --uid 10100 \
  --gid 10100 \
  git

# Generate a SSH key for local authentication to Gitea
sudo ssh-keygen \
  -u git \
  -f /home/git/.ssh/id_rsa.pub \
  -t rsa \
  -b 4096 \
  -C "Gitea Host Key"

# Symlink the Gitea user's authorized_keys to the local account
ln -s \
  /nas0/appdata/gitea/git/.ssh/authorized_keys \
  /home/git/.ssh/authorized_keys

# Add the local user's SSH key to the Gitea user's authorized_keys
echo "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty $(cat /home/git/.ssh/id_rsa.pub)" >> /nas0/appdata/gitea/git/.ssh/authorized_keys

# Create a script to pass through the SSH connection to the container
mkdir -p /app/gitea
ln -s /srv/home-server/apps/gitea/bin/gitea /app/gitea/gitea
chmod +x /srv/home-server/apps/gitea/bin/gitea

# Create a Docker network for Gitea <-> MariaDB
docker network create gitea
```

External steps:
* Port forward 322 to this server
* Add the following to local `~/.ssh/config`:
  ```
  Host gitea.francopuccini.casa
    Port 322
  ```