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

## Favorite Applications

I record my favorite applications in [pacman.nu](./pacman.nu).

Install with command: `./pacman.nu`

## System configuration

Host-level configuration is reproducible:

- `root/` mirrors `/` and is deployed with `sudo ./deploy.nu root`. It holds
  journald/coredump size caps, the udev battery rule
  (`99-battery.rules`) and `/usr/local/bin/on_battery_change.sh`.
- `system/apply.sh` applies the non-file state (disabled services, timers,
  power profile, ufw rules): `sudo ~/.dotfiles/system/apply.sh`.
- `systemd/user/ssh-agent.service` provides a single long-lived SSH agent
  (`SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket`), deployed via
  `./deploy.nu` — never start an agent from `zshenv`.

Machine-specific manual steps (host dependent, not committed):

- `/etc/fstab`: root ext4 is mounted with `rw,noatime`.
- Hibernation: no `resume=` kernel parameter is configured.
- `amd_pstate=active` is not usable on this machine (firmware exposes no ACPI
  CPPC tables), so it stays on `acpi-cpufreq` + `schedutil`.
- Persistent zswap pool is configured in `root/boot/loader/entries/arch.conf`
  (`zswap.max_pool_percent=35`), deployed with `sudo ./deploy.nu root`.
- Firewall assumes trusted LANs `10.100.0.0/22`, `192.168.0.0/16`,
  `172.16.0.0/12` and the tailnet; ToDesk may fall back to relay.
