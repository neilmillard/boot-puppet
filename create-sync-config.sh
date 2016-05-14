#!/bin/bash
mkdir -p $SYNC_DIR
chown root:btsync $SYNC_DIR
chmod 2775 $SYNC_DIR

if [ $USER ] ; then
  sudo usermod -a -G btsync $USER
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
    \"download_limit\": 0,
    \"upload_limit\": 0,
    \"shared_folders\": [
        {
            \"secret\": \"$SECRET\",
            \"dir\": \"$SYNC_DIR\",
            \"use_relay_server\": true,
            \"use_tracker\": true,
            \"use_dht\": false,
            \"search_lan\": true,
            \"use_sync_trash\": false
        }
    ]
}" > /etc/btsync.conf