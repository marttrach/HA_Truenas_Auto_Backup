#!/bin/bash
# Simple script to back up data via SMB from a TrueNAS share.
# Adjust SMB credentials and paths to suit your environment.

set -e

SMB_SHARE="//truenas.local/backup"      # SMB share path
MOUNT_POINT="/tmp/truenas_backup_mount"  # Temporary mount point
USERNAME="youruser"                     # SMB username
PASSWORD="yourpassword"                 # SMB password

mkdir -p "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
  mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" \
    -o username="$USERNAME",password="$PASSWORD",rw
fi

# Example rsync command copying from the SMB share to a local path.
# Replace "/path/to/local/backup" with your desired destination.
rsync -av "$MOUNT_POINT/" /path/to/local/backup/

umount "$MOUNT_POINT"
