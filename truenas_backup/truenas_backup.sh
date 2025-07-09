#!/bin/bash
# Simple script to back up data via SMB from a TrueNAS share.
# Credentials and paths can be provided via environment variables so that
# Home Assistant add-ons or other wrappers can supply them through a web UI.

set -e

# Logging configuration
LOG_LEVEL="${LOG_LEVEL:-info}"

log_level_num() {
  case "$1" in
    none) echo 0 ;;
    error) echo 1 ;;
    warn) echo 2 ;;
    info) echo 3 ;;
    debug) echo 4 ;;
    *) echo 3 ;;
  esac
}

CURRENT_LEVEL=$(log_level_num "$LOG_LEVEL")
log() {
  local level="$1"
  shift
  local level_num
  level_num=$(log_level_num "$level")
  if [ "$CURRENT_LEVEL" -ge "$level_num" ] && [ "$CURRENT_LEVEL" -ne 0 ]; then
    printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$level" "$*"
  fi
}

send_wol() {
  if [ -n "$WOL_MAC" ]; then
    log info "Sending Wake-on-LAN packet to $WOL_MAC"
    python3 - <<EOF
import socket, binascii
mac = "${WOL_MAC}".replace("-", "").replace(":", "")
data = b"FFFFFFFFFFFF" + (mac * 16).encode()
packet = binascii.unhexlify(data.decode())
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.sendto(packet, ("${WOL_BROADCAST}", ${WOL_PORT}))
EOF
  fi
}

# Fallback copy using smbget when mounting SMB share is not permitted
copy_via_smbget() {
  local url="smb://${SMB_SHARE#//}"
  log info "Using smbget fallback to copy from $url"
  mkdir -p "$LOCAL_BACKUP_PATH"
  (cd "$LOCAL_BACKUP_PATH" && smbget -R -u "$USERNAME" -p "$PASSWORD" "$url")
}

TRUENAS_HOST="${TRUENAS_HOST:-}"
SMB_SHARE="${SMB_SHARE:-}"
MOUNT_POINT="${MOUNT_POINT:-/tmp/truenas_backup_mount}"  # Temporary mount point
USERNAME="${USERNAME:-youruser}"                         # SMB username
PASSWORD="${PASSWORD:-yourpassword}"                     # SMB password
# Local path to store backups
LOCAL_BACKUP_PATH="${LOCAL_BACKUP_PATH:-/path/to/local/backup}"
STARTUP_DELAY="${STARTUP_DELAY:-120}"
VERIFY_SHUTDOWN="${VERIFY_SHUTDOWN:-0}"
WATCHDOG="${WATCHDOG:-false}"
WOL_MAC="${WOL_MAC:-}"
WOL_BROADCAST="${WOL_BROADCAST:-255.255.255.255}"
WOL_PORT="${WOL_PORT:-9}"

if [ -z "$TRUENAS_HOST" ] && [ -n "$SMB_SHARE" ]; then
  TRUENAS_HOST=$(echo "$SMB_SHARE" | sed -e 's|^//||' -e 's|/.*$||')
fi
TRUENAS_HOST="${TRUENAS_HOST:-truenas.local}"
SMB_SHARE="${SMB_SHARE:-//${TRUENAS_HOST}/backup}"


# Check if TrueNAS is online
log info "Checking if TrueNAS ($TRUENAS_HOST) is online"
if ping -c 1 "$TRUENAS_HOST" >/dev/null 2>&1; then
  log info "TrueNAS is reachable"
else
  log error "TrueNAS is not reachable"
  exit 1
fi

if [ "$WATCHDOG" = "true" ]; then
  log debug "Watchdog enabled"
fi

send_wol

if [ "$STARTUP_DELAY" -gt 0 ]; then
  log debug "Waiting $STARTUP_DELAY seconds for TrueNAS to boot"
  sleep "$STARTUP_DELAY"
fi

log debug "Creating mount point $MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

if ! mountpoint -q "$MOUNT_POINT"; then
  log info "Mounting SMB share $SMB_SHARE"
  if mount -t cifs "$SMB_SHARE" "$MOUNT_POINT" -o username="$USERNAME",password="$PASSWORD",rw; then
    log info "SMB mount successful"
  else
    log warn "Failed to mount SMB share, falling back to smbget"
    copy_via_smbget || exit 1
    exit 0
  fi
else
  log debug "Mount point already mounted"
fi

# Test read/write access
if touch "$MOUNT_POINT/.rw_test" && rm "$MOUNT_POINT/.rw_test"; then
  log info "Read/write test on SMB share successful"
else
  log error "Read/write test on SMB share failed"
  umount "$MOUNT_POINT"
  exit 1
fi

# Run rsync to copy data from the SMB share
log info "Starting rsync backup"
if rsync -av "$MOUNT_POINT/" "$LOCAL_BACKUP_PATH/"; then
  log info "rsync completed successfully"
else
  log error "rsync encountered errors"
  umount "$MOUNT_POINT"
  exit 1
fi

# Verify that files were copied
remote_count=$(find "$MOUNT_POINT" -type f | wc -l)
local_count=$(find "$LOCAL_BACKUP_PATH" -type f | wc -l)
if [ "$local_count" -ge "$remote_count" ]; then
  log info "Backup verification succeeded ($local_count files)"
else
  log warn "Backup verification mismatch: $remote_count files on source, $local_count on destination"
fi

umount "$MOUNT_POINT"

if [ "$VERIFY_SHUTDOWN" -eq 1 ]; then
  log info "Verifying TrueNAS shutdown"
  for _ in {1..10}; do
    if ping -c 1 "$TRUENAS_HOST" >/dev/null 2>&1; then
      log debug "TrueNAS still online, waiting..."
      sleep 10
    else
      log info "TrueNAS is offline"
      break
    fi
  done
fi
