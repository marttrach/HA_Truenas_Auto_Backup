#!/bin/bash
# shellcheck shell=bash
set -e

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# Align container timezone with Home Assistant system timezone
if [ -n "$TZ" ] && [ -f "/usr/share/zoneinfo/$TZ" ]; then
  ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
fi

ha_call() {
  local path="$1" data="$2"
  curl -s -H "Authorization: Bearer $SUPERVISOR_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data" "http://supervisor/core/api/services/$path" >/dev/null
}

ha_wol() {
  if [ -n "$WOL_MAC" ]; then
    log "Sending WOL via Home Assistant for $WOL_MAC"
    ha_call "wake_on_lan/send_magic_packet" \
      "{\"mac\": \"$WOL_MAC\", \"broadcast_address\": \"$WOL_BROADCAST\", \"broadcast_port\": $WOL_PORT}"
  fi
}

ha_shutdown() {
  log "Triggering shutdown via Home Assistant"
  ha_call "rest_command/shutdown_truenas" "{}"
}

check_host() {
  if ping -c 1 -W 15 "$TRUENAS_HOST" >/dev/null 2>&1; then
    log "TrueNAS $TRUENAS_HOST reachable"
  else
    log "Warning: TrueNAS $TRUENAS_HOST unreachable"
  fi
}

run_backup() {
  log "$1 backup triggered"
  check_host
  ha_wol
  if /usr/local/bin/truenas_backup.sh 2>&1 | while IFS= read -r line; do log "$line"; done; then
    log "Backup completed"
  else
    log "Backup script failed"
  fi
  if [ "$VERIFY_SHUTDOWN" = "true" ] || [ "$VERIFY_SHUTDOWN" = "1" ]; then
    ha_shutdown
    check_host
  fi
}
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
log "TrueNAS backup service starting"
log "Configuration loaded. Trigger time set to $TRIGGER_TIME"
log "Random log ID $(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)"
if [ ! -x /usr/local/bin/truenas_backup.sh ]; then
  log "Error: /usr/local/bin/truenas_backup.sh not found"
  exit 1
fi
export TRUENAS_HOST SMB_SHARE MOUNT_POINT USERNAME PASSWORD LOCAL_BACKUP_PATH STARTUP_DELAY LOG_LEVEL VERIFY_SHUTDOWN WATCHDOG WOL_MAC WOL_BROADCAST WOL_PORT TRIGGER_TIME

while true; do
  now=$(date +%s)
  target=$(date -d "$(date +%F) $TRIGGER_TIME" +%s)
  if [ "$target" -le "$now" ]; then
    target=$(date -d "tomorrow $TRIGGER_TIME" +%s)
  fi
  end=$((target - now))
  log "Next backup scheduled at $(date -d @"$target" '+%Y-%m-%d %H:%M:%S')"
  for ((i=0; i<end; i++)); do
    if read -r -t 1 cmd; then
      if [ "$cmd" = "run" ]; then
        run_backup "Manual"
      fi
    fi
  done
  run_backup "Scheduled"
done
