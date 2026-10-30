## About

My dotfiles for Arch Linux

These files are managed by [deploy.nu](./deploy.nu).

Distribute the files to specified locations in file system via:

```bash
# For user
$ ./deploy.nu

# For root
$ sudo ./deploy.nu root
```

## My Toolkit

### Shell

- Login shell: [zsh](https://wiki.archlinux.org/title/zsh)

- Prompt: [powerlevel10k](https://github.com/romkatv/powerlevel10k)

### Desktop

- Windows manager: [niri](https://github.com/YaLTeR/niri) + [dms](https://danklinux.com/)

### Terminal

- Terminal emulator: [kitty](https://sw.kovidgoyal.net/kitty/)

- Terminal file manager: [yazi](https://yazi-rs.github.io)

### Editor

- If not coding Java: **neovim** (via [LazyVim](https://www.lazyvim.org))

## Introduction To Some Directories

[_root_](./root) - Root dotfiles.

[_LazyVim_](./LazyVim) - Lazyvim config.

[_shell_](./shell) - Holds the common configuration of **bash** and **zsh**.

[_navi_](./navi) - The self-made cheat sheets of [navi](https://github.com/denisidoro/navi).

[_scripts_](./scripts) - The shell scripts. Most of them are written in [nushell](https://www.nushell.sh).

[_memo_](./memo) - The memos of my memo tool `scripts/mm`.

[_atuin_](./atuin) - ✨ Magical shell history [atuin](https://github.com/atuinsh/atuin).

[_bin_](./bin) - Bin utils.

[_dunst_](./dunst) - Lightweight and customizable notification daemon [dunst](https://github.com/dunst-project/dunst).

[_mise_](./mise) - Dev tools, env vars, task runner [mise](https://github.com/jdx/mise).

[_uv_](./uv) - An extremely fast Python package and project manager, written in Rust. [uv](https://github.com/astral-sh/uv).

## Packages

Everything installed is declared in [system/packages](./system/packages):

- `system.toml` — system core (kernel, boot, base runtime)
- `drivers.toml` — drivers / firmware / hardware support
- `others.toml` — everything else (pacman/AUR + cargo + uv + bun + rustup)

[pacman.nu](./pacman.nu) reads them and converges the machine:

```bash
$ ./pacman.nu              # sync: install missing, ask before removing undeclared
$ ./pacman.nu audit        # report drift only (exit 1 when out of sync)
$ ./pacman.nu --dry-run    # show the plan without touching anything
$ ./pacman.nu export       # dump the current machine as TOML (bootstrap)
```

Manager priority: pacman (official / archlinuxcn / AUR via paru) first.
Every sync/audit validates each cargo/uv/bun entry against the pacman repos
and the AUR, also trying the `@scope/name` → `scope-name`, `_` → `-`, and
`-git`/`-bin` package-name variants, and refuses to run while such a
declaration exists. Node is managed by mise (project-level versions); JS
globals use bun; npm/pnpm are not used. The manifest must cover every
explicitly installed package — an undeclared package is offered for removal
on sync.

## How this repo maps to the machine

`~/.dotfiles` is the single source of truth. Four layers, applied in order:

1. **Packages** → `./pacman.nu` — installs what the TOML manifests declare,
   offers to remove what is installed but undeclared.
2. **User config** → `./deploy.nu` — the `pf` / `pfs` lists symlink or
   hard-link each `./<tool>` directory to `~/.config/<tool>` (or `~/<file>`).
3. **Files under `/`** → `sudo ./deploy.nu root` — `root/` mirrors `/` and is
   copied over it (`root/boot`, `root/etc`, `root/usr`).
4. **Host state** → `sudo ~/.dotfiles/system/apply.sh` — services on/off,
   timers, power profile, nftables reload and the legacy purge list in
   `system/packages-remove.txt` (orphan sweep).

Workflow: edit dotfiles → `./pacman.nu` → `./deploy.nu` →
`sudo ./deploy.nu root` → `sudo ./system/apply.sh`. The machine converges to
the repo; anything configured out-of-band is not reproducible and should be
moved here.

Files worth knowing:

- `root/etc/nftables.conf` — host firewall (`inet archwm`).
- `root/etc/NetworkManager/conf.d/wifi_backend.conf` — `wifi.backend=iwd`.
- `root/etc/systemd/{journald,coredump}.conf.d/` — size caps.
- `root/etc/udev/rules.d/99-battery.rules` +
  `root/usr/local/bin/on_battery_change.sh` — AC plug/unplug switches the
  power profile.
- `root/etc/sddm.conf.d/zz-theme.conf` — `maya` theme (Plasma themes are gone).
- `systemd/user/ssh-agent.service` — one long-lived SSH agent
  (`SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket`); never start an agent
  from `zshenv`.

Stack choices (Arch Wiki, current tools over legacy ones):

- Firewall: native `nftables`, not `ufw`/iptables-nft.
- Wi-Fi: `iwd` as the NetworkManager backend, not `wpa_supplicant` (still
  installed as a hard dependency of `networkmanager`, but unused).
- Boot loader: `systemd-boot` only; leftover GRUB files and EFI entry removed.
- Scheduling: systemd timers only; `cronie` removed.
- Power: `power-profiles-daemon` only; `tuned`, `cpupower`, `cpupower-gui`
  removed.
- Desktop: niri + DMS only; KDE Plasma (`plasma-meta` and its apps) removed.
  Kept on purpose: `sddm` (display manager), `polkit-kde-agent` (only polkit
  agent) and `xwaylandvideobridge` (XWayland screen capture, needs kpipewire).
  The remaining KDE packages are only framework libraries these need
  (`breeze-icons`, `kirigami`, `kirigami-addons`, `kwallet`, `kwindowsystem`,
  `kpipewire`, `qqc2-desktop-style`).

Machine-specific manual steps (host dependent, not committed):

- `/etc/fstab`: root ext4 is mounted with `rw,noatime`.
- Hibernation: no `resume=` kernel parameter is configured.
- `amd_pstate=active` is not usable on this machine (firmware exposes no ACPI
  CPPC tables), so it stays on `acpi-cpufreq` + `schedutil`.
- Persistent zswap pool is configured in `root/boot/loader/entries/arch.conf`
  (`zswap.max_pool_percent=35`), deployed with `sudo ./deploy.nu root`.
- Firewall: `nftables.conf` trusts LANs `10.100.0.0/22`, `192.168.0.0/16`,
  `172.16.0.0/12`, `tailscale0`, `virbr0`, `Meta` (Clash TUN); ToDesk may fall
  back to relay.
