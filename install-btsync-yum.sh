#!/usr/bin/env bash

sudo echo "[btsync]
name=BitTorrent Sync \$basearch
baseurl=http://linux-packages.getsync.com/btsync/rpm/\$basearch
enabled=1
gpgcheck=1" >/etc/yum.repos.d/btsync.repo

sudo rpm --import http://linux-packages.getsync.com/btsync/key.asc

sudo yum -y install btsync

bash create-sync-config.sh $SECRET

sudo systemctl start btsync
if [ ! $? -eq 0 ]; then
  sudo service btsync start
fi

# systemd
# sudo systemctl (command) btsync
# where (command) is start,stop,enable,disable or status
# or
# sudo service btsync (command)
# for older sysvinit or upstart