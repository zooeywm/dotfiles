#!/usr/bin/env -S nu --stdin

use std/log

# 部署用户配置：把仓库里的文件 symlink / hard-link 到目标位置。
#   ./deploy.nu                  正常部署（文件链接 + 启用用户级 systemd 单元）
#   ./deploy.nu --dry-run        只看会做什么，不落盘
#   ./deploy.nu --prune          顺带清掉指向本仓库的失效链接（文件已从仓库删除/改名）
#   sudo ./deploy.nu root        镜像 root/ 到 /、按当前根分区动态写 bootloader 条目，
#                                并应用主机状态（用户组、服务、timer、电源、nftables、udev）
def main [--dry-run (-n), --prune] {
    let results = (
        [
        ]
        | target shell ~/.config/shell
        | target clangd ~/.config/clangd
        | target navi ~/.local/share/navi/cheats
        | target zsh/zshenv ~/.zshenv
        | target zsh/zshrc ~/.config/zsh/.zshrc
        | target zsh/p10k.zsh -p ~/.config/zsh
        | target rofi/config ~/.config/rofi
        | target rofi/themes ~/.local/share/rofi/themes
        # hard-link on
        | target gtk/gtk-3.0 ~/.config/gtk-3.0 -h
        | target gtk/gtk-4.0 ~/.config/gtk-4.0 -h
        | target Xresources ~/.Xresources -h
        # hard-link off
        | target bin -p ~/.local
        | target cargo ~/.cargo
        | target fcitx5/config ~/.config/fcitx5
        | target fcitx5/share ~/.local/share/fcitx5
        | target ssh ~/.ssh
        | target codex ~/.codex
        # | target Templates -p ~
        | targets [
            starship.toml fish nushell dunst presenterm niri swaylock dms xdg-desktop-portal
            LazyVim neovide wezterm kitty alacritty zellij yazi git git-cliff
            gitui lazygit zathura mpv gdb pip.conf macchina paru
            mise atuin uv jj zed nix systemd
        ] ~/.config
        | targets [
            fontconfig mimeapps.list
        ] ~/.config -h
        | targets [memo applications] ~/.local/share
        | each {|item| deploy-item $item --dry-run=$dry_run }
    )

    let prune_result = (if $prune {
        prune-broken --dry-run=$dry_run
    } else {
        { pruned: 0, failed: [] }
    })

    # 用户级 systemd 单元（文件由上面的部署链接到 ~/.config/systemd/user 后启用）
    let user_units = ['ssh-agent.service' 'dms.service' 'openrazer-daemon.service']
    for unit in $user_units {
        if $dry_run {
            log info $"[dry-run] user unit: enable ($unit)"
            continue
        }
        let r = (^systemctl --user enable --now $unit | complete)
        if $r.exit_code == 0 {
            log info $"user unit: enabled ($unit)"
        } else {
            log warning $"user unit: ($unit) skipped: ($r.stderr | str trim)"
        }
    }

    let linked = ($results | each {|r| $r.linked } | math sum)
    let failed = (($results | each {|r| $r.failed } | flatten) ++ $prune_result.failed)
    log info $"linked: ($linked), pruned: ($prune_result.pruned), failed: ($failed | length)"
    if ($failed | length) > 0 {
        for f in $failed {
            log error $f
        }
        exit 1
    }
}

# 把 root/ 镜像到 /，然后应用主机状态（服务、timer、电源、防火墙、udev）。
def 'main root' [--dry-run (-n)] {
    if (not $dry_run) and ((^id -u | str trim) != '0') {
        log error "root 部署会写入 /etc、/boot 等目录，请用 sudo 运行：sudo ./deploy.nu root"
        exit 1
    }
    mirror-root --dry-run=$dry_run
    apply-host-state --dry-run=$dry_run
}

# root/ 镜像到 /（root/etc、root/boot、root/usr ...）。
# 当前根文件系统所在设备的 UUID（LVM/ext4/btrfs 通用）。
def root-fs-uuid [] {
    let dev = (^findmnt -no SOURCE / | str trim)
    if ($dev | is-empty) { return '' }
    (^lsblk -no UUID $dev | str trim)
}

# 用当前机器实际的 root UUID 渲染 bootloader 条目。
def render-boot-entry [uuid: string] {
    open 'root/boot/loader/entries/arch.conf'
    | str replace --regex 'root=UUID=[0-9a-fA-F-]+' $"root=UUID=($uuid)"
}

# 生成 /boot/loader/entries/arch.conf：模板来自仓库，UUID 取当前机器。
def apply-boot-entry [--dry-run] {
    let dest = '/boot/loader/entries/arch.conf'
    let uuid = (root-fs-uuid)
    if ($uuid | is-empty) {
        log error 'cannot detect root filesystem UUID'
        exit 1
    }
    let desired = (render-boot-entry $uuid)
    let current = (if ($dest | path exists) { open --raw $dest | str trim } else { '' })
    if (($desired | str trim) == $current) {
        log info "boot entry: up to date"
        return
    }
    if $dry_run {
        log info $"[dry-run] update ($dest) root UUID=($uuid)"
        return
    }
    $desired | save --force $dest
    ^chmod 644 $dest
    log info $"boot entry: updated ($dest) root UUID=($uuid)"
}

def mirror-root [--dry-run] {
    if (which rsync | is-empty) {
        if $dry_run {
            log info "rsync not found; dry-run unavailable, would run: cp -r root/* /"
        } else {
            for src in (ls root | get name) {
                cp -r $src /
            }
        }
        apply-boot-entry --dry-run=$dry_run
        return
    }

    let rsync_args = (if $dry_run { ['-rlptD' '-n'] } else { ['-rlptD'] })
    let r = (^rsync ...$rsync_args --modify-window=2 --itemize-changes         --exclude=boot/loader/entries/arch.conf root/ / | complete)
    if $r.exit_code != 0 {
        log error $"rsync failed: ($r.stderr | str trim)"
        exit 1
    }
    let changed = (
        $r.stdout
        | lines
        | where {|l| ($l | str starts-with '>') or ($l | str starts-with 'c') }
    )
    if ($changed | is-empty) {
        log info "root: up to date"
    } else {
        $changed | each {|l| log info $l } | ignore
    }

    apply-boot-entry --dry-run=$dry_run
}

# 应用非文件的主机状态：服务开关、timer、电源、nftables、udev。
def apply-host-state [--dry-run] {
    let steps = [
        { desc: "disable NetworkManager-wait-online", optional: false, run: { ^systemctl disable --now NetworkManager-wait-online.service } }
        { desc: "enable iwd", optional: false, run: { ^systemctl enable --now iwd.service } }
        { desc: "disable wpa_supplicant", optional: false, run: { ^systemctl disable --now wpa_supplicant.service } }
        { desc: "disable systemd-timesyncd", optional: false, run: { ^systemctl disable --now systemd-timesyncd.service } }
        { desc: "enable fstrim.timer", optional: false, run: { ^systemctl enable --now fstrim.timer } }
        { desc: "enable paccache.timer", optional: false, run: { ^systemctl enable --now paccache.timer } }
        { desc: "power profile balanced", optional: true, run: { ^powerprofilesctl set balanced } }
        { desc: "firewall reload (nftables)", optional: false, run: { ^nft -f /etc/nftables.conf } }
        { desc: "enable nftables", optional: false, run: { ^systemctl enable nftables.service } }
        { desc: "reload udev rules", optional: false, run: { ^udevadm control --reload-rules } }
        # --- 桌面/基础服务（新机也要保持开启）---
        { desc: "enable NetworkManager", optional: false, run: { ^systemctl enable --now NetworkManager.service } }
        { desc: "enable sddm", optional: false, run: { ^systemctl enable --now sddm.service } }
        { desc: "enable chronyd", optional: false, run: { ^systemctl enable --now chronyd.service } }
        { desc: "enable power-profiles-daemon", optional: false, run: { ^systemctl enable --now power-profiles-daemon.service } }
        { desc: "enable udisks2", optional: false, run: { ^systemctl enable --now udisks2.service } }
        { desc: "enable bluetooth", optional: true, run: { ^systemctl enable --now bluetooth.service } }
        { desc: "enable libvirtd", optional: true, run: { ^systemctl enable --now libvirtd.service } }
        { desc: "enable libvirt-guests", optional: true, run: { ^systemctl enable --now libvirt-guests.service } }
        { desc: "enable nix-daemon", optional: true, run: { ^systemctl enable --now nix-daemon.service } }
        { desc: "enable sshd", optional: true, run: { ^systemctl enable --now sshd.service } }
        { desc: "enable smb", optional: true, run: { ^systemctl enable --now smb.service } }
        { desc: "enable cups", optional: true, run: { ^systemctl enable --now cups.service } }
        { desc: "enable dnsmasq (libvirt)", optional: true, run: { ^systemctl enable --now dnsmasq.service } }
        { desc: "enable tailscaled", optional: true, run: { ^systemctl enable --now tailscaled.service } }
        { desc: "enable todeskd", optional: true, run: { ^systemctl enable --now todeskd.service } }
        { desc: "enable clash-verge-service", optional: true, run: { ^systemctl enable --now clash-verge-service.service } }
        { desc: "enable man-db.timer", optional: true, run: { ^systemctl enable --now man-db.timer } }
        { desc: "enable libvirt-win11-net-auto-switch.timer", optional: true, run: { ^systemctl enable --now libvirt-win11-net-auto-switch.timer } }
    ]

    let optional_runtime = ["scaling governor schedutil", "zswap max_pool_percent=35"]
    mut failed = []
    for s in $steps {
        if $dry_run {
            log info $"[dry-run] host: ($s.desc)"
            continue
        }
        let r = (do $s.run | complete)
        if $r.exit_code == 0 {
            log info $"host: ($s.desc)"
        } else if $s.optional {
            log warning $"host: ($s.desc) ignored: ($r.stderr | str trim)"
        } else {
            $failed = ($failed | append $"($s.desc): ($r.stderr | str trim)")
        }
    }

    # 用户组：由软件包（sysusers）创建，这里补齐成员关系。
    let user_groups = ['wheel' 'audio' 'input' 'kvm' 'render' 'video' 'libvirt' 'sambashare' 'openrazer']
    # 目标用户：sudo 下取 SUDO_USER，直接以用户运行则取自己
    let user = (if (($env.SUDO_USER? | default '') | is-not-empty) { $env.SUDO_USER } else { ^id -un | str trim })
    for g in $user_groups {
        let grp = (^getent group $g | complete)
        if $grp.exit_code != 0 {
            log warning $"group: ($g) 不存在，跳过（对应软件包还没装？）"
            continue
        }
        let has = (^id -nG $user | complete | get stdout | str trim | split row ' ' | any {|x| $x == $g })
        if $has {
            continue
        }
        if $dry_run {
            log info $"[dry-run] group: add ($user) -> ($g)"
            continue
        }
        let r = (^gpasswd -a $user $g | complete)
        if $r.exit_code == 0 {
            log info $"group: added ($user) -> ($g)"
        } else {
            $failed = ($failed | append $"group ($g): ($r.stderr | str trim)")
        }
    }

    if $dry_run {
        for d in $optional_runtime {
            log info $"[dry-run] host: ($d)"
        }
        return
    }

    set-schedutil
    set-zswap

    let chain = (^nft list chain inet archwm input | complete)
    if $chain.exit_code == 0 {
        print $chain.stdout
    }

    if ($failed | length) > 0 {
        for f in $failed {
            log error $f
        }
        exit 1
    }
}

def set-schedutil [] {
    for f in (^find /sys/devices/system/cpu -maxdepth 2 -name scaling_governor | lines) {
        try {
            "schedutil" | save --force $f
        } catch {}
    }
}

def set-zswap [] {
    let p = '/sys/module/zswap/parameters/max_pool_percent'
    if ($p | path exists) {
        try {
            "35" | save --force $p
        } catch {}
    }
}

# prepare
# 向部署列表追加一个目标：仓库里的 src -> 目标位置 dest。
#   --place (-p)：dest 是一个目录，把 src 按相对路径放进该目录
#   --hard  (-h)：硬链接而不是符号链接
def target [
    src: string,
    --place (-p),
    dest: string,
    --hard (-h),
] {
    let self = $in

    $self
    | append {
        src: $src,
        dest: $dest,
        place: $place,
        hard: $hard,
    }
}

# 一次把多个 src 追加到同一个 dest 目录（相当于对每个 src 用 target --place）。
def targets [
    srcs: list<string>,
    dest: string
    --hard (-h),
] {
    let self = $in

    $srcs
    | reduce --fold $self {|src, self|
        $self
        | append {
            src: $src,
            dest: $dest,
            place: true,
            hard: $hard,
        }
    }
}

def deploy-item [item: record, --dry-run] {
    let dest = $item.dest | path expand
    if not ($item.src | path exists) {
        let msg = $"($item.src): 源文件不存在"
        log error $msg
        return { linked: 0, failed: [$msg] }
    }

    match ($item.src | path type) {
        file => {
            deploy-file $item.src $dest --place=$item.place --hard=$item.hard --dry-run=$dry_run
        },
        dir if $item.place => {
            place-dir $item.src $dest --hard=$item.hard --dry-run=$dry_run
        },
        dir => {
            deploy-dir $item.src $dest --hard=$item.hard --dry-run=$dry_run
        },
    }
}

def deploy-file [
    src: string,
    dest: path,
    --place,
    --hard,
    --dry-run,
] {
    let dest = if $place {
        if not $dry_run {
            mkdir -v $dest
        }
        $dest | path join ($src | path basename)
    } else {
        if not $dry_run {
            mkdir -v ($dest | path dirname)
        }
        $dest
    }

    link $src $dest --hard=$hard --dry-run=$dry_run
}

def deploy-dir [
    src: string,
    dest: path,
    --hard,
    --dry-run,
] {
    let dest_path = {|p|
        $dest
        | path join (
            $p
            | path strip (pwd) $src
        )
    }

    let entries = (glob $"($src)/**/*")
    let dirs = ($entries | where {|p| ($p | path type) == 'dir' } | each $dest_path)
    if not $dry_run {
        mkdir -v $dest ...$dirs
    }

    let files = ($entries | where {|p| ($p | path type) != 'dir' })
    mut result = { linked: 0, failed: [] }
    for file in $files {
        let dest = (do $dest_path $file)
        let file = ($file | path strip (pwd))
        let r = (link $file $dest --hard=$hard --dry-run=$dry_run)
        $result.linked += $r.linked
        $result.failed = ($result.failed ++ $r.failed)
    }
    $result
}

def place-dir [
    src: string,
    dest: path,
    --hard,
    --dry-run,
] {
    let dest_path = {|p|
        $dest
        | path join (
            $p
            | path strip (pwd) ($src | path dirname)
        )
    }

    let entries = (glob $"($src)/**/*")
    let dirs = ($entries | where {|p| ($p | path type) == 'dir' } | each $dest_path)
    if not $dry_run {
        mkdir -v $dest ...$dirs
    }

    let files = ($entries | where {|p| ($p | path type) != 'dir' })
    mut result = { linked: 0, failed: [] }
    for file in $files {
        let dest = (do $dest_path $file)
        let file = ($file | path strip (pwd))
        let r = (link $file $dest --hard=$hard --dry-run=$dry_run)
        $result.linked += $r.linked
        $result.failed = ($result.failed ++ $r.failed)
    }
    $result
}

def link [
    src: string,
    dest: path,
    --hard,
    --dry-run,
] {
    let srcp = pwd | path join $src

    if $hard {
        if (is-hard-linked $srcp $dest) {
            return { linked: 0, failed: [] }
        }
        if $dry_run {
            if (dest-taken $dest) {
                log info $"[dry-run] replace existing ($dest) with hard link to ($src)"
            } else {
                log info $"[dry-run] hard link ($src) => ($dest)"
            }
            return { linked: 1, failed: [] }
        }
        let r = (^ln --force $srcp $dest | complete)
        if $r.exit_code == 0 {
            log info $"hard link ($src) => ($dest)"
            { linked: 1, failed: [] }
        } else {
            { linked: 0, failed: [$"($src) => ($dest): ($r.stderr | str trim | str substring 0..200)"] }
        }
    } else {
        if (is-linked $srcp $dest) {
            return { linked: 0, failed: [] }
        }
        if $dry_run {
            if (dest-taken $dest) {
                log info $"[dry-run] conflict: ($dest) already exists"
                return { linked: 0, failed: [$"($src) => ($dest): destination already exists"] }
            }
            log info $"[dry-run] link ($src) => ($dest)"
            return { linked: 1, failed: [] }
        }
        let r = (^ln -s $srcp $dest | complete)
        if $r.exit_code == 0 {
            log info $"link ($src) => ($dest)"
            { linked: 1, failed: [] }
        } else {
            { linked: 0, failed: [$"($src) => ($dest): ($r.stderr | str trim | str substring 0..200)"] }
        }
    }
}

# 删除指向本仓库、但目标已不存在的 symlink（文件已从仓库删除/改名）。
def prune-broken [--dry-run] {
    let repo = (pwd)
    let dirs = [
        ($env.HOME | path join '.config')
        ($env.HOME | path join '.local/bin')
        ($env.HOME | path join '.local/state')
        ($env.HOME | path join '.local/share/memo')
        ($env.HOME | path join '.local/share/applications')
        ($env.HOME | path join '.local/share/navi/cheats')
        ($env.HOME | path join '.local/share/rofi/themes')
        ($env.HOME | path join '.local/share/fcitx5')
        ($env.HOME | path join '.cargo')
        ($env.HOME | path join '.ssh')
        ($env.HOME | path join '.codex')
    ]

    mut result = { pruned: 0, failed: [] }
    mut removed = []
    let scans = ($dirs | each {|d| { dir: $d, depth: 8 } })
    let all_scans = ($scans | append { dir: ($env.HOME | path join ''), depth: 1 })
    for scan in $all_scans {
        let d = $scan.dir
        if not ($d | path exists) {
            continue
        }
        for l in (^find $d -maxdepth $scan.depth -xtype l err> /dev/null | lines) {
            let t = (^readlink $l | str trim)
            if not ($t | str starts-with $repo) {
                continue
            }
            if $dry_run {
                log info $"[dry-run] prune ($l) -> ($t)"
                $result.pruned += 1
                $removed = ($removed | append { path: $l, root: $d })
            } else {
                let r = (^rm --force $l | complete)
                if $r.exit_code == 0 {
                    log info $"prune ($l)"
                    $result.pruned += 1
                    $removed = ($removed | append { path: $l, root: $d })
                } else {
                    $result.failed = ($result.failed | append $"prune ($l): ($r.stderr | str trim)")
                }
            }
        }
    }

    # 删掉 prune 之后变空的目录：只沿被删链接的父目录向上，不碰扫描根目录本身
    mut pending_dirs = []
    for item in $removed {
        let root = ($item.root | path expand)
        mut d = ($item.path | path dirname)
        while (($d | path expand) != $root) and ($d | path exists) {
            let entries = (^find $d -mindepth 1 -maxdepth 1 err> /dev/null | lines)
            let gone_links = ($removed | where {|r| (($r.path | path dirname | path expand) == ($d | path expand)) } | length)
            let gone_dirs = ($pending_dirs | where {|p| (($p | path dirname | path expand) == ($d | path expand)) } | length)
            if (($entries | length) - $gone_links - $gone_dirs) > 0 {
                break
            }
            if $dry_run {
                log info $"[dry-run] rmdir empty ($d)"
                $pending_dirs = ($pending_dirs | append $d)
            } else {
                let r = (^rmdir $d | complete)
                if $r.exit_code != 0 {
                    break
                }
                log info $"rmdir empty ($d)"
            }
            $d = ($d | path dirname)
        }
    }

    $result
}

def dest-taken [dest: path]: nothing -> bool {
    ((^test -e $dest | complete).exit_code == 0) or ((^test -L $dest | complete).exit_code == 0)
}

def is-linked [src: path, dest: path]: nothing -> bool {
    try {
        $src == (realpath $dest)
    } catch {
        false
    }
}

def is-hard-linked [src: path, dest: path]: nothing -> bool {
    let f = {|p| stat --printf '%d:%i' $p err> /dev/null }
    try {
        (do $f $src) == (do $f $dest)
    } catch {
        false
    }
}

def 'path strip' [...prefix: string] {
    $in | path relative-to ($prefix | path join)
}
