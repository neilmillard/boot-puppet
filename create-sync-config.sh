#!/bin/bash
# Pass Key/Secret as 1st Arg
# e.g. create-sync-config.sh MYSECRETKEY
mkdir -p /mnt/sync
chown root:btsync /mnt/sync
chmod 2775 /mnt/sync
mkdir -p /mnt/sync/config
chown root:btsync /mnt/sync/config
chmod 2775 /mnt/sync/config

mkdir -p $SYNC_DIR
chmod 2775 $SYNC_DIR
if [ $DATAUSER ] ; then
  sudo usermod -a -G btsync $DATAUSER
  chown ${DATAUSER}:btsync $SYNC_DIR
else
  chown root:btsync $SYNC_DIR
fi

SECRET="${@}"
: ${SECRET:=$(btsync --generate-secret)}
echo "Starting btsync with secret: $SECRET"
echo "Syncing folder: $SYNC_DIR"

echo "{
    \"device_name\": \"Sync Server\",
    \"listening_port\": 55555,
    \"storage_path\": \"/mnt/sync/config\",
    \"pid_file\": \"/var/run/btsync/btsync.pid\",
    \"check_for_updates\": false,
    \"use_upnp\": false,
    \"agree_to_EULA\": \"yes\",
    \"download_limit\": 0,
    \"upload_limit\": 0,
    \"shared_folders\": [
        {
            \"secret\": \"$SECRET\",
            \"dir\": \"$SYNC_DIR\",
            \"use_relay_server\": true,
            \"use_tracker\": true,
            \"search_lan\": true,
            \"use_sync_trash\": false
        }
    ]
}" > /etc/btsync/config.json