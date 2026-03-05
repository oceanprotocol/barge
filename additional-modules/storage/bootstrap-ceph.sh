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

mkdir -p /etc/ceph /var/lib/ceph/mon/ceph-a /var/lib/ceph/osd/ceph-0 /var/lib/ceph/mgr/ceph-a

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

# ----------------------------------------------------
# Initialize OSD
# ----------------------------------------------------
echo "Initializing OSD..."
OSD_UUID=$(uuidgen)
ceph-authtool --create-keyring /var/lib/ceph/osd/ceph-0/keyring --gen-key -n osd.0
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/osd/ceph-0/keyring

cp /etc/ceph/ceph.conf /var/lib/ceph/osd/ceph-0/
cp /etc/ceph/monmap /var/lib/ceph/osd/ceph-0/

echo "Setting permissions..."
mkdir -p /var/lib/ceph/osd/ceph-0
chown -R ceph:ceph /var/lib/ceph/osd/ceph-0 /var/lib/ceph/mon/ceph-a /var/lib/ceph/mgr/ceph-a

mkdir -p /var/run/ceph /var/lib/ceph/tmp
chown -R ceph:ceph /var/run/ceph /var/lib/ceph/tmp

echo "Mkfs OSD..."
sudo -u ceph ceph-osd -i 0 --mkfs --osd-uuid $OSD_UUID --no-mon-config


# ----------------------------------------------------
# Initialize MGR
# ----------------------------------------------------
echo "Initialize MGR..."
ceph-authtool --create-keyring /var/lib/ceph/mgr/ceph-a/keyring --gen-key -n mgr.a
ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/mgr/ceph-a/keyring

touch "$BOOTSTRAP_MARKER"

echo "Starting supervisor..."
exec /usr/bin/supervisord -n