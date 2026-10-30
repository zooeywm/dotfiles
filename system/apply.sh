#!/usr/bin/env bash
# Reproducible host state for archwm (batch A/B tuning).
# File-based configs live in ./root (deploy with: sudo ./deploy.nu root).
# This script applies the non-file state: service on/off, timers, power, firewall.
#
# Usage: sudo ~/.dotfiles/system/apply.sh
set -euo pipefail

echo ':: boot: do not block on network-online (Samba server stays enabled)'
systemctl disable --now NetworkManager-wait-online.service

echo ':: redundant services'
systemctl disable --now iwd.service              # NetworkManager uses wpa_supplicant
systemctl disable --now tuned.service            # p-p-d is authoritative
systemctl disable --now cpupower.service         # conflicts with p-p-d
systemctl disable --now systemd-timesyncd.service # chronyd is the NTP client
systemctl disable --now flclash-helper.service 2>/dev/null || true

echo ':: timers'
systemctl enable --now fstrim.timer
systemctl enable --now paccache.timer

echo ':: power profile'
powerprofilesctl set balanced || true
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
    echo schedutil > "$f" 2>/dev/null || true
done

# Runtime only; persist with kernel cmdline: zswap.max_pool_percent=35
if [[ -w /sys/module/zswap/parameters/max_pool_percent ]]; then
    echo 35 > /sys/module/zswap/parameters/max_pool_percent || true
fi

echo ':: firewall (deny public inbound, keep trusted LAN / tailnet)'
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
ufw default allow routed
ufw allow in on lo
ufw allow from 10.100.0.0/22 comment 'LAN (tingyu)'
ufw allow from 192.168.0.0/16 comment 'LAN (home)'
ufw allow from 172.16.0.0/12 comment 'LAN (private)'
ufw allow in on tailscale0 comment 'Tailscale'
ufw allow 41641/udp comment 'Tailscale direct'
ufw allow in on Meta comment 'Clash TUN'
ufw allow in on virbr0 comment 'libvirt NAT'
ufw allow 68/udp comment 'DHCP client'
ufw --force enable
ufw status verbose

echo ':: reload udev rules'
udevadm control --reload-rules

echo ':: done'
