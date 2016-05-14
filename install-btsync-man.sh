#!/usr/bin/env bash

echo "Installing BTsync"
aws s3 cp s3://$BUCKET_PUPPET/BitTorrent-Sync_x64.tar.gz /tmp/BitTorrent-Sync_x64.tar.gz
tar xzvf /tmp/BitTorrent-Sync_x64.tar.gz -C /usr/sbin btsync
mkdir -p /var/run/btsync && mkdir -p /mnt/sync/folders && mkdir -p /mnt/sync/config
groupadd btsync
create-sync-config.sh $SECRET

echo "syncing mounting ${SYNC_DIR}"
btsync --config /etc/btsync.conf