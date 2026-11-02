#!/usr/bin/env bash
# Host runtime state for archwm (everything that is not a file).
#
# ~/.dotfiles is the single source of truth:
#   1. packages      -> ./pacman.nu
#   2. user configs  -> ./deploy.nu
#   3. files under / -> sudo ./deploy.nu root
#   4. host state    -> sudo ./system/apply.sh (this script)
#
# Applies service state, timers, power profile, nftables reload and udev
# rules. Package state is owned by ./pacman.nu only.
#
# Usage: sudo ~/.dotfiles/system/apply.sh
set -euo pipefail

echo ':: boot: do not block on network-online'
systemctl disable --now NetworkManager-wait-online.service

echo ':: wireless: iwd is the NetworkManager backend (root/etc/NetworkManager)'
systemctl enable --now iwd.service
systemctl disable --now wpa_supplicant.service

echo ':: time sync: chrony is the NTP client'
systemctl disable --now systemd-timesyncd.service

echo ':: timers'
systemctl enable --now fstrim.timer
systemctl enable --now paccache.timer

echo ':: power profile (power-profiles-daemon)'
powerprofilesctl set balanced || true
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > "$f" 2>/dev/null || true
done

# Runtime only; persisted via kernel cmdline: zswap.max_pool_percent=35
if [[ -w /sys/module/zswap/parameters/max_pool_percent ]]; then
    echo 35 > /sys/module/zswap/parameters/max_pool_percent || true
fi

echo ':: firewall: nftables (deny public inbound, keep trusted LAN / tailnet)'
nft -f /etc/nftables.conf
systemctl enable nftables.service
nft list chain inet archwm input

echo ':: reload udev rules'
udevadm control --reload-rules

echo ':: done'
