#!/usr/bin/bash
# Switch power profile when AC state changes (invoked by udev, see 99-battery.rules).
# Installed from ~/.dotfiles/root/usr/local/bin/on_battery_change.sh

set -u

ac_state() {
    local f
    for f in /sys/class/power_supply/AC*/online; do
        [[ -r $f ]] || continue
        cat "$f"
        return 0
    done
    echo 0
}

if [[ $(ac_state) == 1 ]]; then
    powerprofilesctl set balanced >/dev/null 2>&1 || true
    echo 500 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null || true
else
    powerprofilesctl set power-saver >/dev/null 2>&1 || true
    echo 1500 > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null || true
fi

# Keep AMDGPU DPM on auto; the platform profile drives the clocks.
for f in /sys/class/drm/card*/device/power_dpm_force_performance_level; do
    echo auto > "$f" 2>/dev/null || true
done
