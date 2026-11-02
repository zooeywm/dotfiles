# dotfiles

Arch Linux 配置仓库。`~/.dotfiles` 是唯一事实来源：软件包、用户配置、系统文件全部声明在这里，机器向仓库收敛。

| 入口 | 作用 |
|---|---|
| `./bootstrap.sh` | 新机前置：写入 archlinuxcn 源，安装 `paru`/`nushell`/`rsync`/`git` |
| `./pacman.nu` | 按 `packages/*.toml` 收敛软件包（`sync` / `audit` / `export`） |
| `./deploy.nu` | 用户配置 symlink/hard-link 到目标位置，启用用户级 systemd 单元 |
| `sudo ./deploy.nu root` | `root/` 镜像到 `/`，生成 bootloader UUID、补用户组、开服务 |

所有命令都支持 `--dry-run` 预览；`deploy.nu --prune` 额外清理指向仓库的失效链接。

## Fresh install

1. `archinstall` 装好 base 系统，创建用户 `zooeywm` 并加入 `wheel`（其余组由 deploy 处理）
2. `git clone git@github.com:zooeywm/dotfiles.git ~/.dotfiles && cd ~/.dotfiles`
3. `./bootstrap.sh` — 仓库配置 + `paru`/`nushell`/`rsync`/`git`
4. `./pacman.nu sync` — 安装清单里的全部软件
5. `sudo ./deploy.nu root` — 系统文件 + bootloader UUID + 用户组 + 服务
6. `./deploy.nu` — 用户配置 + 用户级单元
7. 注销重登，让组成员关系生效

## 布局

- `packages/` — 软件清单：`system.toml`（内核/启动/基础运行）、`drivers.toml`（驱动/固件）、`others.toml`（其余 pacman/AUR + cargo/uv/bun/rustup）
- `root/` — 系统层，镜像到 `/`（`boot/`、`etc/`、`usr/`）
- 各工具目录 — 部署到 `~/.config/<tool>`（niri、dms、kitty、zsh、nushell、fish、LazyVim 等）
- `systemd/user/` — 仓库自带的用户级单元（`ssh-agent.service`）
- `bin/` — 自用脚本

## 软件包规则

官方仓库（pacman / archlinuxcn）优先；AUR 只用于没有原生管理器等价物的程序。cargo / uv / bun 等原生管理的工具留在原生管理器，Node 由 mise 管，npm/pnpm 不用。清单必须覆盖所有显式安装包，`pacman.nu sync` 会提议删除未声明的包；`audit` 在漂移时退出 1。

## deploy 做了什么

用户层：`target` / `targets` 把 `./<tool>` 链接到 `~/.config/<tool>`（默认 symlink，少数用 `-h` 硬链接）；随后启用 `ssh-agent`、`dms` 等用户单元。

root 层：先 rsync `root/` 到 `/`，然后

- 按当前根分区 UUID 生成 `/boot/loader/entries/arch.conf`（换机/换盘不用手改）
- 补齐用户组：`wheel audio input kvm render video libvirt sambashare openrazer`
- 开启服务与 timer：NetworkManager、iwd、sddm、chronyd、libvirtd、nftables、fstrim、paccache 等
- 重载 nftables/udev、设置 power profile、schedutil 与 zswap

## 关键文件

- `root/etc/nftables.conf` — 防火墙（`inet archwm`）
- `root/etc/NetworkManager/conf.d/wifi_backend.conf` — `wifi.backend=iwd`
- `root/etc/systemd/{journald,coredump}.conf.d/` — 日志体积上限
- `root/etc/udev/rules.d/99-battery.rules` + `root/usr/local/bin/on_battery_change.sh` — 插拔电源切换 power profile
- `root/etc/sddm.conf.d/zz-theme.conf` — `sugar-candy` SDDM 主题
- `systemd/user/ssh-agent.service` — 单例 SSH agent（`SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket`）
- `mimeapps.list` — 默认 chromium、mpv、zathura、WPS 等关联

## 本机相关（不入库）

- `/etc/fstab` 由 archinstall 生成，root ext4 为 `rw,noatime`
- 无休眠：kernel cmdline 不带 `resume=`
- `amd_pstate=active` 不可用（固件无 ACPI CPPC），保持 `acpi-cpufreq` + `schedutil`
