#!/bin/sh
# requires environment variables
#BUCKET_PUPPET - name of the bucket with the puppet manifests/modules
#ROLE          - role name of server
#SYNC_DIR      - Directory for BTSync
#SECRET        - Secret for BTSync

exec 1>/var/log/boot.log 2>&1
set -x

REGION="`/opt/aws/bin/ec2-metadata -z | grep -Po "(us|sa|eu|ap)-(north|south|central)?(east|west)?-[0-9]+"`"

yum -y update
yum -y install git gcc augeas-devel ruby-devel 
 
cd /root
rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
yum install -y puppet

echo "Setup AWS Config for aws cmd - Uses IAM role"  
mkdir /root/.aws
wget --output-document=/root/.aws/config https://s3-eu-west-1.amazonaws.com/${BUCKET_PUPPET}/config

mkdir -p $SYNC_DIR
echo "Installing BTsync"
aws s3 cp s3://$BUCKET_PUPPET/BitTorrent-Sync_x64.tar.gz /tmp/BitTorrent-Sync_x64.tar.gz
tar xzvf /tmp/BitTorrent-Sync_x64.tar.gz -C /usr/sbin btsync
mkdir -p /var/run/btsync && mkdir -p /mnt/sync/folders && mkdir -p /mnt/sync/config
aws s3 cp s3://$BUCKET_PUPPET/run_sync /opt/run_sync
chmod +x /opt/run_sync

echo "syncing mounting ${SYNC_DIR}"
/opt/run_sync $SECRET

echo "Copying puppet module bundle"
aws s3 cp s3://$BUCKET_PUPPET/modules.tgz /root/modules.tgz
tar xzvf /root/modules.tgz -C /etc/puppet

echo "Copy puppet base and site config"
aws s3 sync --delete s3://$BUCKET_PUPPET/base /etc/puppet/
aws s3 cp s3://$BUCKET_PUPPET/$ROLE/site.pp /root/site.pp

echo "running puppet apply"
/usr/bin/puppet apply /root/site.pp
