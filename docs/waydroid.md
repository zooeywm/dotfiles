# Waydroid（Android 容器）现状与后续

> 2026-11-27 安装。目标：在外接屏跑抖音小游戏。
> 结论：**Waydroid 本体可用，但容器网络与抖音 ARM 兼容性未解决**，见下。

## 已安装

| 组件 | 版本 | 来源 |
|---|---|---|
| waydroid | 1.6.3-1 | extra |
| waydroid-image | 20.0_20260927-1 | archlinuxcn（LineageOS 20 / Android 13） |

- 镜像位置：`/usr/share/waydroid-extra/images/{system,vendor}.img`（2.3GB）
- 运行时数据：`/var/lib/waydroid`（约 2.3GB）
- 服务：`waydroid-container.service`（已 enable）
- 初始化命令：`sudo waydroid init -i /usr/share/waydroid-extra/images`

## 已验证可用

- `sudo systemctl start waydroid-container` + `waydroid session start` 正常
- `waydroid show-full-ui` 能在 niri 里开出 Android 13 桌面（GPU: AMD amdgpu，硬件加速正常）
- 内核 `rust_binder` 内建（`CONFIG_ANDROID_BINDER_IPC_RUST=y`），binderfs 由 Waydroid 自动处理
- `waydroid app list` / `waydroid app install`（走 gbinder）可用
- `waydroid prop get/set` 可用（例：`waydroid prop set net.dns1 223.5.5.5`）

## 未解决：容器拿不到 IP（DHCP 不完成）

现象：

```
容器 netns: eth0 UP，但只有 MAC 没有 IP；路由表空
eth0 计数: TX 48 包 / RX 14 包   ← DHCP 发出去、也收到回包
/var/lib/misc/dnsmasq.waydroid0.leases 为空
waydroid status: IP address: UNKNOWN
```

宿主侧一切正常：`waydroid0` = 192.168.240.1/24，dnsmasq 监听 `waydroid0:67`，
nft 规则里 `iifname "waydroid0" udp dport {53,67} accept` 与
`ip saddr 192.168.240.0/24 ... masquerade` 都在。

手工配置可让**内核层**通网（已验证 `ping 223.5.5.5` 4.4ms）：

```bash
init=$(pgrep -P "$(pgrep -f 'lxc-start.*waydroid' | head -1)" | head -1)
N="nsenter -t $init -n --"
$N ip addr add 192.168.240.112/24 dev eth0
$N ip link set eth0 up
$N ip route add default via 192.168.240.1 dev eth0 onlink
$N ip rule add from all lookup main priority 50   # Android 默认 rule 32000 是 unreachable
```

但 **Android 应用层仍然没网**：ConnectivityService 没拿到网络（它依赖 DHCP 完成），
netd 没有 DNS 配置。所以 `adb`（5555 端口开着但 device offline）、应用联网都可能失败。

### 可选的下一条路

1. 触发 Android 自己重跑 DHCP（root）：
   ```bash
   # 清掉手工地址后 down/up，观察 dnsmasq 租约是否出现
   sudo bash /tmp/wd-dhcp-try.sh
   ```
2. 修 adb 后 `adb root`，用 adb 配 DNS、装 APK：
   - 公钥已写入 `/var/lib/waydroid/data/misc/adb/adb_keys`（715 字节）
   - `adb connect 192.168.240.112:5555` 仍 offline，怀疑 adbd 未重读 key 或 SELinux 拦读
3. 放弃应用层联网，仅做本地 APK 安装验证。

## 抖音（未安装）

- 抖音 APK 只有 ARM（`arm64-v8a`），x86_64 镜像需要 `libndk_translation`（AMD）翻译层
- 已知 2026-09 有人用同样路线失败（ARM 转译 + 反调试 + 加密网络栈）：
  https://8loser.github.io/2026/09/16/linux-douyin-waydroid-scrcpy/
- 替代方案（更稳）：scrcpy 投屏手机，抖音原生运行

## 临时脚本（/tmp，重启后消失）

- `/tmp/wd-check.sh`、`/tmp/wd-check2.sh`：容器内网络诊断
- `/tmp/wd-netfix{,2,3}.sh`：静态 IP / 路由 / DNS 尝试
- `/tmp/wd-net-apply.sh`：重新套用静态 IP + 路由（当前有效）
- `/tmp/wd-dhcp-try.sh`：清地址后 down/up，触发 Android 重跑 DHCP

## 清理方式

```bash
sudo systemctl disable --now waydroid-container
sudo pacman -Rns waydroid waydroid-image libgbinder libglibutil python-gbinder
sudo rm -rf /var/lib/waydroid /var/lib/misc/dnsmasq.waydroid0.leases
```
