#!/usr/bin/env bash

# Enable unattended security upgrades on Debian.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

DEFAULT="/etc/apt/apt.conf.d/50unattended-upgrades"
OVERRIDE="/etc/apt/apt.conf.d/52unattended-upgrades"

apt-get update
apt-get install -y unattended-upgrades apt-listchanges

sed '/^\s*\/\//d; /^\s*$/d' "$DEFAULT" > "$OVERRIDE"

cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

unattended-upgrade --dry-run >/dev/null

systemctl enable --now apt-daily.timer apt-daily-upgrade.timer

echo "Auto-updates enabled. Override file: $OVERRIDE"
echo "Logs: /var/log/unattended-upgrades/"