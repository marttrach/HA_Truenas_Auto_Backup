#!/bin/bash
# shellcheck shell=bash
set -e
CONFIG_PATH=/data/options.json
TRUENAS_HOST=$(jq -r '.truenas_host // ""' "$CONFIG_PATH")
SMB_SHARE=$(jq -r '.smb_share // ""' "$CONFIG_PATH")
MOUNT_POINT=$(jq -r '.mount_point' "$CONFIG_PATH")
USERNAME=$(jq -r '.username' "$CONFIG_PATH")
PASSWORD=$(jq -r '.password' "$CONFIG_PATH")
LOCAL_BACKUP_PATH=$(jq -r '.local_path' "$CONFIG_PATH")
STARTUP_DELAY=$(jq -r '.startup_delay' "$CONFIG_PATH")
LOG_LEVEL=$(jq -r '.log_level // "info"' "$CONFIG_PATH")
VERIFY_SHUTDOWN=$(jq -r '.verify_shutdown // false' "$CONFIG_PATH")
WATCHDOG=$(jq -r '.watchdog // false' "$CONFIG_PATH")
export TRUENAS_HOST SMB_SHARE MOUNT_POINT USERNAME PASSWORD LOCAL_BACKUP_PATH STARTUP_DELAY LOG_LEVEL VERIFY_SHUTDOWN WATCHDOG

/usr/local/bin/truenas_backup.sh
