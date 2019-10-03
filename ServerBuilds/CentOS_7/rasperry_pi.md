# CentOS on Raspberry Pi

## Download & Install

https://wiki.centos.org/SpecialInterestGroup/AltArch/Arm32/RaspberryPi3

## Setup

1. `passwd`
2. `/usr/local/bin/rootfs-expand`
3. `adduser bfrank`
4. `yum update -y`
5. `sudo sed -i -e 's/SELINUX=permissive/SELINUX=enforcing/' /etc/sysconfig/selinux`
6. `sudo sed -i '$s/$/ selinux=1 enforcing=1/‘ /boot/cmdline.txt`
7. `sudo yum install smartmontools which lsof git vim tmux`

