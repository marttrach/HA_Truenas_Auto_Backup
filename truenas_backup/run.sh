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
WOL_MAC=$(jq -r '.wol_mac // ""' "$CONFIG_PATH")
WOL_BROADCAST=$(jq -r '.wol_broadcast // "255.255.255.255"' "$CONFIG_PATH")
WOL_PORT=$(jq -r '.wol_port // 9' "$CONFIG_PATH")
TRIGGER_TIME=$(jq -r '.trigger_time // "02:00:00"' "$CONFIG_PATH")
export TRUENAS_HOST SMB_SHARE MOUNT_POINT USERNAME PASSWORD LOCAL_BACKUP_PATH STARTUP_DELAY LOG_LEVEL VERIFY_SHUTDOWN WATCHDOG WOL_MAC WOL_BROADCAST WOL_PORT TRIGGER_TIME

while true; do
  now=$(date +%s)
  target=$(date -d "$(date +%F) $TRIGGER_TIME" +%s)
  if [ "$target" -le "$now" ]; then
    target=$(date -d "tomorrow $TRIGGER_TIME" +%s)
  fi
  end=$((target - now))
  for ((i=0; i<end; i++)); do
    if read -r -t 1 cmd; then
      if [ "$cmd" = "run" ]; then
        /usr/local/bin/truenas_backup.sh
      fi
    fi
  done
  /usr/local/bin/truenas_backup.sh
done
