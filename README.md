# System Configuration

## Environment

### Aliases

```bash
alias groot='cd $(git rev-parse --show-toplevel)'
alias ll='ls -lAhF --color=auto'
alias lsdev='lsblk -o "NAME,FSTYPE,SIZE,UUID,MOUNTPOINT"'
alias lsip='ip --color address show'
alias lsmnt='mount | column -t'
alias lsps='ps -e --forest -o pid,ppid,user,cmd'
```

## Packages

```bash
glances
ncdu
sysstat
dstat
```

## Monitoring/Logging

```bash
sed -i 's/#Storage=auto/Storage=persistent/' /etc/systemd/journald.conf
systemctl restart systemd-journald.service
```

## Security

* [ ] Disable root SSH authentication
* [ ] Disable password SSH authentication
* [ ] Enable firewall
* [ ] Enable SELinux *enforcing* mode