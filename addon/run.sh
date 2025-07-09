#!/usr/bin/with-contenv bash
# shellcheck shell=bash
set -e
CONFIG_PATH=/data/options.json
SMB_SHARE=$(jq -r '.smb_share' "$CONFIG_PATH")
MOUNT_POINT=$(jq -r '.mount_point' "$CONFIG_PATH")
USERNAME=$(jq -r '.username' "$CONFIG_PATH")
PASSWORD=$(jq -r '.password' "$CONFIG_PATH")
LOCAL_BACKUP_PATH=$(jq -r '.local_path' "$CONFIG_PATH")
STARTUP_DELAY=$(jq -r '.startup_delay' "$CONFIG_PATH")
export SMB_SHARE MOUNT_POINT USERNAME PASSWORD LOCAL_BACKUP_PATH STARTUP_DELAY

/usr/local/bin/truenas_backup.sh
