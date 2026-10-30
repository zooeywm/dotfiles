#!/usr/bin/env bash
# Reproducible host state for archwm (batch A/B tuning).
# File-based configs live in ./root (deploy with: sudo ./deploy.nu root).
# This script applies the non-file state: service on/off, timers, power, firewall.
#
# Usage: sudo ~/.dotfiles/system/apply.sh
set -euo pipefail

echo ':: boot: do not block on network-online (Samba server stays enabled)'
systemctl disable --now NetworkManager-wait-online.service

echo ':: wireless: iwd is the NetworkManager backend (root/etc/NetworkManager)'
systemctl enable --now iwd.service
systemctl disable wpa_supplicant.service 2>/dev/null || true

echo ':: redundant services'
systemctl disable --now systemd-timesyncd.service  # chronyd is the NTP client
systemctl disable --now flclash-helper.service 2>/dev/null || true
# legacy power stack (packages removed; guards kept for older hosts)
systemctl disable --now tuned.service 2>/dev/null || true
systemctl disable --now cpupower.service 2>/dev/null || true
# cronie removed in favour of systemd timers
systemctl disable --now cronie.service 2>/dev/null || true

echo ':: timers'
systemctl enable --now fstrim.timer
systemctl enable --now paccache.timer

echo ':: power profile (power-profiles-daemon is the only power tool)'
powerprofilesctl set balanced || true
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > "$f" 2>/dev/null || true
done

# Runtime only; persisted via kernel cmdline: zswap.max_pool_percent=35
if [[ -w /sys/module/zswap/parameters/max_pool_percent ]]; then
    echo 35 > /sys/module/zswap/parameters/max_pool_percent || true
fi

echo ':: firewall: nftables (deny public inbound, keep trusted LAN / tailnet)'
systemctl disable --now ufw.service 2>/dev/null || true
nft -f /etc/nftables.conf
systemctl enable nftables.service
nft list chain inet archwm input

echo ':: reload udev rules'
udevadm control --reload-rules

echo ':: done'
