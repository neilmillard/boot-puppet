#!/usr/bin/env bash

echo "Installing BTsync"
aws s3 cp s3://$BUCKET_PUPPET/BitTorrent-Sync_x64.tar.gz /tmp/BitTorrent-Sync_x64.tar.gz
tar xzvf /tmp/BitTorrent-Sync_x64.tar.gz -C /usr/sbin btsync

groupadd btsync
create-sync-config.sh $SECRET
mkdir -p /var/run/btsync && mkdir /mnt/sync/folders && mkdir /mnt/sync/config && mkdir -p /etc/btsync

echo "syncing mounting ${SYNC_DIR}"
btsync --config /etc/btsync/config.json