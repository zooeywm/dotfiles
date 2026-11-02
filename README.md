## About

My dotfiles for Arch Linux

These files are managed by [deploy.nu](./deploy.nu).

Distribute the files to specified locations in file system via:

```bash
# For user
$ ./deploy.nu              # symlink/hard-link everything
$ ./deploy.nu --dry-run    # preview only, no writes
$ ./deploy.nu --prune      # also remove links into this repo whose source file was deleted

# For root (root/ mirrors /, copied with rsync)
$ sudo ./deploy.nu root --dry-run   # preview
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

Manager priority: pacman (official / archlinuxcn) first. A package that only
exists in the AUR does not count as "pacman already has it": such tools stay
in their native manager (cargo / uv / bun) instead of an AUR build; AUR is
only used for programs with no native-manager equivalent. Every sync/audit
validates each cargo/uv/bun entry against the official repositories (trying
`@scope/name` → `scope-name` and `_` → `-` name variants) and refuses to run
while an official-repository package exists for it. Node is managed by mise
(project-level versions); JS globals use bun; npm/pnpm are not used. The
manifest must cover every explicitly installed package — an undeclared
package is offered for removal on sync.

## How this repo maps to the machine

`~/.dotfiles` is the single source of truth. Three layers, applied in order:

1. **Packages** → `./pacman.nu` — installs what the TOML manifests declare,
   offers to remove what is installed but undeclared.
2. **User config** → `./deploy.nu` — the `pf` / `pfs` lists symlink or
   hard-link each `./<tool>` directory to `~/.config/<tool>` (or `~/<file>`).
3. **Root system** → `sudo ./deploy.nu root` — `root/` mirrors `/`
   (`root/boot`, `root/etc`, `root/usr`), then host state is applied:
   services on/off, timers, power profile, nftables reload and udev reload.
   `--dry-run` previews both.

Workflow: edit dotfiles → `./pacman.nu` → `./deploy.nu` →
`sudo ./deploy.nu root`. The machine converges to the repo; anything
configured out-of-band is not reproducible and should be moved here.

Files worth knowing:

- `root/etc/nftables.conf` — host firewall (`inet archwm`).
- `root/etc/NetworkManager/conf.d/wifi_backend.conf` — `wifi.backend=iwd`.
- `root/etc/systemd/{journald,coredump}.conf.d/` — size caps.
- `root/etc/udev/rules.d/99-battery.rules` +
  `root/usr/local/bin/on_battery_change.sh` — AC plug/unplug switches the
  power profile.
- `root/etc/sddm.conf.d/zz-theme.conf` — `sugar-candy` SDDM theme.
- `systemd/user/ssh-agent.service` — one long-lived SSH agent
  (`SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket`); never start an agent
  from `zshenv`.

Stack choices:

- Firewall: native `nftables`.
- Wi-Fi: `iwd` as the NetworkManager backend; `wpa_supplicant` is installed
  only as a NetworkManager dependency, with its service disabled.
- Boot loader: `systemd-boot`.
- Scheduling: systemd timers (`fstrim`, `paccache`).
- Power: `power-profiles-daemon`, `acpi-cpufreq` + `schedutil`, zswap pool
  configured via kernel cmdline.
- Desktop: niri + DMS; `sddm` is the display manager, `polkit-kde-agent` the
  only polkit agent, `xwaylandvideobridge` provides XWayland screen capture.
  The KDE framework libraries these need are `breeze-icons`, `kirigami`,
  `kirigami-addons`, `kwallet`, `kwindowsystem`, `kpipewire`,
  `qqc2-desktop-style`.
- Package state: fully declared in `system/packages/*.toml`; `pacman.nu` is
  the only package authority (it installs declared packages and removes
  undeclared ones).

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
