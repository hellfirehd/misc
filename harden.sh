#!/bin/bash
# Basic Centos 7 Hardening 

if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
fi

yum makecache fast
yum update -y
yum install -y epel-release yum-utils bind-utils net-tools wget vim nano screen chrony unzip open-vm-tools gcc
yum clean all

systemctl stop NetworkManager.service
systemctl disable NetworkManager.service

chkconfig network on
service network start

echo "search dkw.io" > /etc/resolv.conf && \
echo "nameserver 1.1.1.1" >> /etc/resolv.conf && \
echo "nameserver 1.0.0.1" >> /etc/resolv.conf

adapter=`ip link | awk -F'[: ]+' '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}'`
if ! grep -qi 'NM_CONTROLLED="\?NO"\?' "/etc/sysconfig/network-scripts/ifcfg-$adapter"; then
  echo "Adding NM_CONTROLLED=\"NO\" to $adapter"
  echo "NM_CONTROLLED=\"no\"" >> /etc/sysconfig/network-scripts/ifcfg-$adapter
fi

echo "Setting Time Zone to America/Vancouver"
timedatectl set-timezone America/Vancouver
echo "Removed default time servers..."
sed -i -e '/^server/d' /etc/chrony.conf
echo "... and added timelord.provisiondata.net"
sed -i -e '1i\server timelord.provisiondata.net iburst' /etc/chrony.conf

systemctl enable chronyd
systemctl restart chronyd

echo "Restrict /root directory to root user"
chmod 700 /root
mkdir /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDw30/LCkj1kuqsmLy2KIUSWlLqG0tO80xIwCA1uC4vho/ezl8dH72Dp+OHBnhmzWJ2uxN51vuc2DMfCeTOCuyi8jzkMNmnZPE8kJpQKnuOWGkYDhdmIl/ATpb8kUhzFjP+nqC9VayB3sJXldC18Wvu4ltiUQ1MsDIJeb/SM3ZGF/EnH9x0LdfC3CAg37FD30bWInN9qDo9dhEZSQYyC3dH5XhazvUXkvezi/IRbpeG0z8SD7i33zuqV1f9rqXnI4iKKcTMf8Idn7uzdpp6CnSmnM1/HrzQTa7Fo/BDCvRrnmhBZfVbXA5xbEUsIRDpAejEa0K6SWqnNngUcBEQdABsZIj0BMi9QAS6Ca2bKI6MH3PbhgywOrx3Tk3KPQtpD1d7U8yvJakOFGM4DG4314Y8SXYmx7f9jfwSihAONw3ZYG5QefOQQoaIVphUomtikmC3UWH54L/OvaBVmd/gUpfy/WUUGzOwlroO3/FQ8mcv4fHcRot4OoURrHbSKHlmZEFAgyXZGEVF1k1nO3CDoYxfgWdopp9HCZbnrAAQh5fzIPiAdPNM2rR2Bajuv8XhRAHN44UkJetdUvZPm+dx7eMtLCtsH8XbqVIKiOb+o9NgTDeVax0lO/xaA3tSTrqCBnFfVUDzeWZxkvOC9/203hisVoAZ5tqbJQESKGn9ax2O/Q== d@dkw.io" > /root/.ssh/authorized_keys
chmod 600 -R /root/.ssh

echo "Restrict cron to root and /etc/cron.allow"
touch /etc/cron.allow
chmod 600 /etc/cron.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
echo "Restrict at to root and /etc/at.allow"
touch /etc/at.allow
chmod 600 /etc/at.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/at.deny

echo "You should reboot this server before doing anything else."
