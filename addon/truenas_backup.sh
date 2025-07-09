#!/bin/bash
# Simple script to back up data via SMB from a TrueNAS share.
# Credentials and paths can be provided via environment variables so that
# Home Assistant add-ons or other wrappers can supply them through a web UI.

set -e

SMB_SHARE="${SMB_SHARE:-//truenas.local/backup}"        # SMB share path
MOUNT_POINT="${MOUNT_POINT:-/tmp/truenas_backup_mount}"  # Temporary mount point
USERNAME="${USERNAME:-youruser}"                         # SMB username
PASSWORD="${PASSWORD:-yourpassword}"                     # SMB password
# Local path to store backups
LOCAL_BACKUP_PATH="${LOCAL_BACKUP_PATH:-/path/to/local/backup}"
STARTUP_DELAY="${STARTUP_DELAY:-120}"

if [ "$STARTUP_DELAY" -gt 0 ]; then
  echo "Waiting $STARTUP_DELAY seconds for TrueNAS to boot..."
  sleep "$STARTUP_DELAY"
fi

mkdir -p "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
  mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" \
    -o username="$USERNAME",password="$PASSWORD",rw
fi

# Example rsync command copying from the SMB share to a local path.
# Destination controlled via the LOCAL_BACKUP_PATH variable.
rsync -av "$MOUNT_POINT/" "$LOCAL_BACKUP_PATH/"

umount "$MOUNT_POINT"
