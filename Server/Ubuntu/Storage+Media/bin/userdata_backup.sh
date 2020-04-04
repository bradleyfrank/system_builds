#!/usr/bin/env bash

_script_name="userdata-backup"
_log_file="/var/log/borg/${_script_name}.log"

_email_address="bradfrank@fastmail.com"
_borg_passphrase="$(</root/.borg-userdata)"

export BORG_REPO="nas:/volume1/BorgBackups/nas0/userdata"
export BORG_PASSPHRASE="$_borg_passphrase"


info() {
  logger -t "$_script_name" "$*"
}

fail_and_exit() {
  info "$*"
  send_email "$_script_name failed"
  exit 1
}

send_email() {
  # Ensure email credentials exist then read in to script
  if [[ ! -r /root/.email-credentials ]]; then
    info "Error: unable to read email credentials"
    return 1
  fi

  # Set email subject line
  local _email_header
  _email_header=$(printf "%s\n" "Subject: $1")

  # Combine subject + body
  printf '%s\n\n%s' "$_email_header" "$(<"$_log_file")" > "$_log_file"

  # Send email with ssmtp
  ssmtp "$_email_address" < "$_log_file"
}


[[ ! -f "$_log_file" ]] && touch "$_log_file"

# Backup plex application and user data
info "Performing backup..."
borg create                           \
    --verbose                         \
    --filter AME                      \
    --list                            \
    --stats                           \
    --show-rc                         \
    --compression lz4                 \
    --exclude-caches                  \
    --remote-path /usr/local/bin/borg \
    ::'{now}'                         \
    /nas0/userdata                    \
    > "$_log_file" 2>&1
_backup_exit=$?

# Check that backup finished successfully
if [[ "$_backup_exit" -gt 0 ]]; then
  fail_and_exit "Error: backup failed"
fi

# Add a blank line for readability
printf '\n' >> "$_log_file"

# Prune to maintain 7 daily, 4 weekly, and 6 monthly backup archives
info "Pruning old backups..."
borg prune                            \
    --list                            \
    --show-rc                         \
    --keep-daily    7                 \
    --keep-weekly   4                 \
    --keep-monthly  6                 \
    --remote-path /usr/local/bin/borg \
    > "$_log_file" 2>&1
_prune_exit=$?

# Check that pruning finished successfully
if [[ "$_prune_exit" -gt 0 ]]; then
  fail_and_exit "Error: pruning failed"
fi

# End of script - email and quit
info "Backup script completed."

send_email "$_script_name completed"