# CentOS 7 on MacBook4,1

## Installation

* DVD ISO
* Minimal install
* Standard Security Policy

## Post-Install

### Configuration

1. Set hostname: `hostnamectl set-hostname [hostname]`

### Packages

1. `rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7`
2. `yum install centos-release-scl epel-release`
3. `yum clean all`
4. `yum install kernel-headers kernel-devel gcc wget pciutils NetworkManager NetworkManager-wifi patch vim git wget ntp logwatch logrotate yum-plugin-security setools policycoreutils-python unzip`
5. `yum update`
6. `reboot`

### Time & Date

1. `systemctl enable ntpd`
2. `ntpdate pool.ntp.org`
3. `systemctl start ntpd`

## WiFi Networking

### Build & Load Kernel Module

Ethernet works out of the box. To get wifi working, the Broadcom drivers need to be compiled into a kernel module and loaded.

1. Confirm the Broadcom adapter is present: `lspci | grep Broadcom`

    1. Result: `Network controller: Broadcom Corporation BCM4321 802.11a/b/g/n`
2. Download the Linux STA 64-bit driver: `wget -P /tmp/ http://www.broadcom.com/docs/linux_sta/hybrid-v35_64-nodebug-pcoem-6_30_223_271.tar.gz`
3. Extract the driver:
    1. `mkdir -p /usr/local/src/hybrid-wl`
    2. `cd /usr/local/src/hybrid-wl`
    3. `tar -xzf /tmp/hybrid-v35_64-nodebug-pcoem-6_30_223_271.tar.gz`
    4. `chown -R bfrank:bfrank .`
4. Patch the driver:
    1. `wget -P /tmp/ https://wiki.centos.org/HowTos/Laptops/Wireless/Broadcom?action=AttachFile&do=get&target=wl-kmod-fix-ioctl-handling.patch`
    2. `patch -p1 < /tmp/wl-kmod-fix-ioctl-handling.patch`
    3. `sed -i 's/ >= KERNEL_VERSION(3, 11, 0)/ >= KERNEL_VERSION(3, 10, 0)/' src/wl/sys/wl_cfg80211_hybrid.c`
    4. `sed -i 's/ >= KERNEL_VERSION(3, 15, 0)/ >= KERNEL_VERSION(3, 10, 0)/' src/wl/sys/wl_cfg80211_hybrid.c`
    5. `sed -i 's/ < KERNEL_VERSION(3, 18, 0)/ < KERNEL_VERSION(3, 9, 0)/' src/wl/sys/wl_cfg80211_hybrid.c`
    6. `sed -i 's/ >= KERNEL_VERSION(4, 0, 0)/ >= KERNEL_VERSION(3, 10, 0)/' src/wl/sys/wl_cfg80211_hybrid.c`
5. Compile the driver: `make -C /lib/modules/``uname -r``/build/ M=``pwd``
6. Load the driver:
    1. ``cp -vi /usr/local/src/hybrid-wl/wl.ko /lib/modules/`uname -r`/extra/``

    2. `depmod $(uname -r)`

    3. `modprobe wl`

    4. Blacklist old wireless drivers: `/etc/modprobe.d/blacklist.conf`

      ```
      blacklist bcm43xx
      blacklist b43
      blacklist b43legacy
      blacklist bcma
      blacklist brcmsmac
      blacklist ssb
      blacklist ndiswrapper
      ```

    5. Create bash script to load driver: `/etc/sysconfig/modules/kmod-wl.modules`

      ```
      #!/bin/bash
      
      for M in lib80211 cfg80211 wl; do
          modprobe $M &>/dev/null
      done
      ```

7. `reboot`

### Configure WiFi

1. Start and enable NetworkManager:
    1. `systemctl start NetworkManager`
    2. `systemctl enable NetworkManager`
2. Connect to wifi network:
    1. `nmcli device wifi list`
    2. `nmcli --ask device wifi connect [SSID]`
3. Configure static IP:
    1. `mv /etc/sysconfig/network-scripts/ifcfg-wls4{,.bak}`

    2. `/etc/sysconfig/network-scripts/ifcfg-wls4`

       ```
       TYPE="Ethernet"
       BOOTPROTO=none
       DEFROUTE="yes"
       IPV4_FAILURE_FATAL=yes
       IPV6INIT=no
       IPV6_AUTOCONF="yes"
       IPV6_DEFROUTE="yes"
       IPV6_FAILURE_FATAL="no"
       NAME="wls4"
       ONBOOT="yes"
       NM_CONTROLLED="yes"
       HWADDR=[MAC_ADDRESS]
       IPV6_PEERDNS=yes
       IPV6_PEERROUTES=yes
       UUID=[UUID]
       DNS1=192.168.1.[X]
       DNS2=8.8.8.8
       DNS3=8.8.4.4
       IPADDR=192.168.1.[X]
       PREFIX=24
       GATEWAY=192.168.1.[X]
       ```

4. `systemctl restart NetworkManager`

## References

* https://wiki.centos.org/HowTos/Laptops/Wireless/Broadcom
* http://unix.stackexchange.com/questions/229711/why-cant-this-centos-7-server-see-wifi-connections
* https://www.cyberciti.biz/faq/rhel-redhat-centos-7-change-hostname-command/