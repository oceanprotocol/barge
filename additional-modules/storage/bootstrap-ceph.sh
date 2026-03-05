#!/bin/bash
set -e

BOOTSTRAP_MARKER=/var/lib/ceph/.bootstrapped

if [ -f "$BOOTSTRAP_MARKER" ]; then
  echo "Ceph already bootstrapped, starting supervisor..."
  exec /usr/bin/supervisord -n
fi

echo "Bootstrapping Ceph..."

FSID=$(uuidgen)
HOST_IP=127.0.0.1

# ----------------------------------------------------
# Required runtime directories
# ----------------------------------------------------
mkdir -p /var/run/ceph
mkdir -p /var/lib/ceph/tmp
chown -R ceph:ceph /var/run/ceph /var/lib/ceph/tmp

# ----------------------------------------------------
# Create ceph.conf
# ----------------------------------------------------
cat <<EOF >/etc/ceph/ceph.conf
[global]
fsid = $FSID
mon initial members = a
mon host = $HOST_IP
public network = 0.0.0.0/0
cluster network = 0.0.0.0/0
osd objectstore = bluestore
EOF

# ----------------------------------------------------
# Create monmap
# ----------------------------------------------------
echo "Creating monmap..."
monmaptool --create --add a $HOST_IP --fsid $FSID --clobber /etc/ceph/monmap

# ----------------------------------------------------
# Create keyrings
# ----------------------------------------------------
echo "Creating keyrings..."
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin
ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon.
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

# ----------------------------------------------------
# Initialize MON
# ----------------------------------------------------
echo "Initializing mon..."
ceph-mon --mkfs -i a --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
chown -R ceph:ceph /var/lib/ceph/mon/ceph-a

# ----------------------------------------------------
# Initialize OSD
# ----------------------------------------------------
echo "Initializing OSD..."
OSD_UUID=$(uuidgen)

ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-0/keyring --gen-key -n osd.0
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/osd/ceph-0/keyring

cp /etc/ceph/ceph.conf /var/lib/ceph/osd/ceph-0/
cp /etc/ceph/monmap /var/lib/ceph/osd/ceph-0/

chown -R ceph:ceph /var/lib/ceph/osd/ceph-0

echo "Mkfs OSD..."
sudo -u ceph ceph-osd -i 0 --mkfs --osd-uuid $OSD_UUID --no-mon-config

# ----------------------------------------------------
# Initialize MGR
# ----------------------------------------------------
echo "Initialize MGR..."
ceph-authtool --create-keyring /var/lib/ceph/mgr/ceph-a/keyring --gen-key -n mgr.a
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/mgr/ceph-a/keyring
chown -R ceph:ceph /var/lib/ceph/mgr/ceph-a

# ----------------------------------------------------
# Start MON + MGR + OSD temporarily to create pools
# ----------------------------------------------------
echo "Starting MON/MGR/OSD temporarily for pool creation..."
ceph-mon -i a --foreground &
sleep 3
ceph-mgr -i a &
sleep 3
ceph-osd -i 0 &
sleep 5

# ----------------------------------------------------
# Create RGW pools
# ----------------------------------------------------
echo "Creating RGW pools..."
ceph osd pool create default.rgw.meta 1
ceph osd pool create default.rgw.log 1
ceph osd pool create default.rgw.control 1
ceph osd pool create default.rgw.buckets.data 1
ceph osd pool create default.rgw.buckets.index 1

# ----------------------------------------------------
# Create default S3 user
# ----------------------------------------------------
echo "Creating default S3 user..."

ACCESS_KEY="ocean123"
SECRET_KEY="ocean123secret"

radosgw-admin user create \
  --uid="ocean" \
  --display-name="Ocean Test User" \
  --access-key="$ACCESS_KEY" \
  --secret-key="$SECRET_KEY" \
  >/tmp/s3-user.json

# ----------------------------------------------------
# Create test bucket
# ----------------------------------------------------
echo "Creating test bucket..."
radosgw-admin bucket create --bucket="test-bucket" --uid="ocean"

# ----------------------------------------------------
# Print credentials
# ----------------------------------------------------
echo "==============================================="
echo " Default S3 Credentials"
echo "-----------------------------------------------"
echo " Access Key: $ACCESS_KEY"
echo " Secret Key: $SECRET_KEY"
echo " Endpoint:   http://localhost:7480"
echo " Bucket:     test-bucket"
echo "==============================================="

# ----------------------------------------------------
# Stop temporary daemons
# ----------------------------------------------------
killall ceph-mon || true
killall ceph-mgr || true
killall ceph-osd || true
sleep 2

# ----------------------------------------------------
# Mark bootstrap complete and start supervisor
# ----------------------------------------------------
touch "$BOOTSTRAP_MARKER"
echo "Starting supervisor..."
exec /usr/bin/supervisord -n