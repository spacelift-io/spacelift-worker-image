# Rotate launcher logs so long-lived workers cannot fill the root volume.
# copytruncate is required: the launcher (and the AWS CloudWatch agent) keep
# these files open, so a rename-and-create rotate would not free disk.

if command -v dnf >/dev/null 2>&1; then
  sudo dnf install -y logrotate
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get -y install logrotate
else
  echo "No supported package manager found to install logrotate" >&2
  exit 1
fi

sudo tee /etc/logrotate.d/spacelift >/dev/null <<'EOF'
/var/log/spacelift/*.log {
    daily
    maxsize 100M
    rotate 5
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
EOF

if [ -f /usr/lib/systemd/system/logrotate.timer ] || [ -f /lib/systemd/system/logrotate.timer ]; then
  sudo systemctl enable --now logrotate.timer
fi
