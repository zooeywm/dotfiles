#!/usr/bin/env bash
# 全新 Arch Linux 首次引导：装好仓库脚本所需的最小前置，然后按提示收敛整机。
set -euo pipefail
cd "$(dirname "$0")"

if [[ $EUID -eq 0 ]]; then
  echo "请用普通用户运行（需要 root 时会自己 sudo）" >&2
  exit 1
fi

echo "==> 写入 pacman 仓库配置（含 archlinuxcn）"
sudo install -Dm644 root/etc/pacman.conf /etc/pacman.conf
sudo install -Dm644 root/etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist

echo "==> 信任 archlinuxcn 源并安装前置工具"
sudo pacman -Sy --needed --noconfirm archlinuxcn-keyring
sudo pacman -S --needed --noconfirm paru nushell rsync git

cat <<'TIP'

前置完成。接下来按顺序执行：

  ./pacman.nu sync          # 安装 packages/*.toml 里的全部软件（pacman + AUR）
  sudo ./deploy.nu root     # 部署系统文件：镜像 root/、动态写 bootloader UUID、
                            # 补齐用户组、开启服务/timer
  ./deploy.nu               # 部署用户配置（symlink + 启用用户级 systemd 单元）

最后注销重登一次，让新的组成员关系生效。
TIP
