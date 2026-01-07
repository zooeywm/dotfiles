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

[*root*](./root) - Root dotfiles.

[*LazyVim*](./LazyVim) - Lazyvim config.

[*shell*](./shell) - Holds the common configuration of **bash** and **zsh**.

[*navi*](./navi) - The self-made cheat sheets of [navi](https://github.com/denisidoro/navi).

[*scripts*](./scripts) - The shell scripts. Most of them are written in [nushell](https://www.nushell.sh).

[*memo*](./memo) - The memos of my memo tool `scripts/mm`.

[*atuin*](./atuin) - ✨ Magical shell history [atuin](https://github.com/atuinsh/atuin).

[*bin*](./bin) - Bin utils.

[*dunst*](./dunst) - Lightweight and customizable notification daemon [dunst](https://github.com/dunst-project/dunst).

[*mise*](./mise) - Dev tools, env vars, task runner [mise](https://github.com/jdx/mise).

[*uv*](./uv) - An extremely fast Python package and project manager, written in Rust. [uv](https://github.com/astral-sh/uv).

## Favorite Applications

I record my favorite applications in [pacman.nu](./pacman.nu).

Install with command: `./pacman.nu`
