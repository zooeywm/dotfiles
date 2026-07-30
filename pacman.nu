#!/usr/bin/env -S nu --stdin

const MANIFEST = {
    # 社交
    telegram-desktop: "telegram"
    QQ: { packages: ["linuxqq-nt-bwrap"], manager: "paru", desc: "QQ (sandbox)" }
    wechat: { packages: ["wechat-universal-bwrap"], manager: "paru", desc: "WeChat (sandbox)" }
    wemeet: { packages: ["wemeet-wayland-screenshare-git"], manager: "paru", desc: "WeMeet (sandbox)" }
    feishu: { packages: ["feishu-bin"], manager: "paru", desc: "Feishu" }

    # OS
    qemu-full: "QEMU"
    ventoy-bin: { manager: "paru", desc: "ventoy" }
    podman: ""

    # kernel
    linux-headers: ""
    sof-firmware: "Audio card firmware"
    # vulkan-intel: "vulkan 的 intel 驱动"
    mkinitcpio-firmware: { manager: "paru", desc: "get rid of the annoying 'WARNING: Possibly missing firmware for module:' messages" }
    pipewire: { packages: [ "pipewire", "wireplumber", "pipewire-pulse", "pipewire-alsa", "pipewire-jack", "pipewire-v4l2" ], desc: "audio" }
    chrony: "Time sync daemon"

    # PL
    gdb: "GNU debugger"
    lldb: "LLVM debugger"
    mold: "modern linker"
    wild: "rust linker"
    rustup: "管理 rust 工具链"
    tokei: "统计代码"
    gcc: "GNU 的 C/C++工具链"
    ast-grep: "匹配搜索 tree-sitter"
    cargo-binutils: { manager: "cargo", desc: "Rust 二进制工具" }
    lua-language-server: "lua language server"
    stylua: "lua 格式化器"
    tombi: "toml 语言工具"
    shfmt: "bash/zsh 格式化器"
    gopls: "Go 语言服务器"
    yaml-language-server: { manager: "npm" }
    vscode-json-language-server: { manager: "npm", packages: ["vscode-langservers-extracted"] }
    volar: { manager: "npm", packages: ["@vue/language-server"] }
    biome: "前端格式化器"
    prettier: { manager: "npm", packages: ["prettier", "@prettier/plugin-xml"], desc: "前端格式化器" }
    mise: "管理语言工具链"
    bash-language-server: { manager: "npm" }
    sccache: "编译缓存"
    clang: { packages: ["clang", "llvm"], desc: "C/C++工具链" }
    typescript: { manager: "npm", packages: ["typescript", "typescript-language-server"] }
    vtsls: { manager: "npm", packages: ["@vtsls/language-server"], desc: "typescript语言服务器" }
    tailwindcss: { manager: "npm", packages: ["@tailwindcss/language-server"], desc: "tailwindcss语言服务器" }
    oxfmt: { manager: "npm", packages: ["oxfmt"] }
    typst: { packages: ["typst", "tinymist", "typstyle"] }
    tree-sitter-cli: "安装 tree-sitter 解析器"
    uv: "Python package manager written in rust"
    ruff: "python 格式化器"
    basedpyright: { manager: "uv", desc: "python 语言服务器" }
    strace: "Bin stack trace"
    astro-ls: { manager: "npm", packages: ["@astrojs/language-server"] desc: "AstroJS 的语言服务器", }
    qt6-languageserver: "qt6 languageserver"
    slint-lsp-bin: { manager: "paru", desc: "slint lsp" }

    # desktop
    qt-theme: { packages: ["qt6ct", "qt5ct", "kvantum"] }
    # wezterm: { packages: ["wezterm-git"], desc: "现代终端模拟器" }
    sddm: "会话管理器"
    dolphin: { packages: ["dolphin", "ffmpegthumbs", "kdegraphics-thumbnailers"], desc: "KDE 文件管理器" }
    spectacle: "KDE 截图"
    fcitx: { packages: ["fcitx5-im", "fcitx5-chinese-addons", "fcitx5-pinyin-zhwiki"], desc: "小企鹅输入法" }
    zen-browser: "Browser using the firefox core vertical label bar"
    # dbeaver: "PostgreSQL 客户端"
    sqlitebrowser: "SQLite 客户端"
    nerd-fonts: {
      packages: [
        "ttf-jetbrains-mono",
        "ttf-firacode-nerd",
        "ttf-nerd-fonts-symbols",
        "ttf-nerd-fonts-symbols-mono"
      ],
      desc: "终端字体（最小集合）"
    }
    noto-fonts: {
      packages: [
        "noto-fonts",
        "noto-fonts-cjk",
        "noto-fonts-emoji"
      ],
      desc: "基础字体（拉丁 + CJK + emoji）"
    }
    polkit-kde-agent: "Authorization Panel"
    polkit: "Policy kit"
    bluez: "Bluetooth kernel"
    bluez-utils: "Bluetooth cli"
    overskride: "Bluetooth GUI"
    kalker: { manager: "paru", desc: "Terminal calculator" }
    libreoffice-fresh-zh-cn: "doc, xml, ppt"

    # shell
    nushell: "结构化 shell"
    atuin: "历史命令"
    starship: "装饰提示符"
    zoxide: "瞬移"
    zellij: "终端复用器"
    bash-completion: "bash 补全"
    zsh: { packages: ["zsh", "zsh-completions"], desc: "zsh 及额外补全包" }

    # filesystem
    xdg-user-dirs: "规范目录"
    eza: "高级 ls"
    rsync: "超级复制"
    parallel-disk-usage: "磁盘空间统计"
    yazi: { packages: ["yazi", "jq", "ffmpegthumbnailer", "unarchiver", "ueberzugpp"], desc: "终端文件管理器" }
    resvg: "for yazi SVG preview"
    gparted: "分区 GUI"
    exfatprogs: "exfat 格式化工具"
    squashfs-tools: "高压缩率只读文件系统"

    # utility
    man: { packages: ["man-db", "man-pages"], desc: "手册" }
    less: "pager"
    bat: "高级 cat"
    choose: "高级 cut"
    dos2unix: "改变文本的平台"
    enca: "检查文件编码"
    fd: "搜索文件"
    jaq: "高级 jq"
    jless: "json 阅读器"
    ripgrep: "正则匹配行"
    ripgrep-all: "万能正则匹配行"
    sd: "高级 sed"
    skim: "模糊搜索.rs"
    fzf: "模糊搜索.go"
    tree: "树视图"
    protobuf: "ProtocolBuffers"
    navi: "命令速查"
    pastel: "调色板"
    hyperfine: "竞争测试"
    pueue: "守护大任务"
    hexyl: "hex 查看器"
    libtree: "程序的库依赖树视图"
    halp: "命令行选项标准化检验"
    terminus-font: "Outer terminal font"
    neovim: "editor"
    neovide: "neovim gui"
    zed: "Zed Editor"
    plocate: "locate 的并行版本"
    ripdrag: { packages: ["ripdrag-git"], desc: "准备拖拽" }
    d2: "diagram tool"

    # git
    lazygit: "git TUI"
    difftastic: "语言 diff"
    git-cliff: "变更日志生成器"
    gitoxide: "锈化 git"
    git-filter-repo: "过滤 git 项目"
    # jujutsu: "新一代 VCS"
    # lazyjj: "jujutsu TUI"
    # gitlogue: "git 重现动画"

    # data
    7zip: "7z"
    unrar: "解压 RAR"
    zip: { packages: ["zip", "unzip"] }
    qbittorrent: "下载种子"
    dufs: "文件服务器"

    # media
    imagemagick: "图片瑞士军刀"
    mpv: "看视频"
    yt-dlp: "下载 Youtube 视频"
    dagtoc: { packages: ["dagtoc-bin"], manager: "paru", desc: "操作 PDF 目录" }
    pandoc: { packages: ["pandoc-bin"], desc: "LaTex 渲染器" }
    kid3-qt: "编辑音乐标签"
    espeak: { packages: ["espeak-ng"], desc: "Ebook speaker" }
    mupdf-tools: "PDF 工具箱"
    gwenview: "看图"
    zathura: { packages: ["zathura", "zathura-pdf-mupdf"], desc: "PDF 阅读器" }
    webp-pixbuf-loader: "GDK 的 webp 支持"
    inkscape: "操作矢量图"
    poppler: "`pdftoppm -png`将 PDF 转成图片"
    viu: "终端看图"
    doxx: "docx TUI",

    # language
    pdf2zh: { manager: "uv", desc: "智能布局留存翻译 PDF" }

    # monitor
    acpi: "电池信息"
    bandwhich: "监测网络带宽"
    bottom: "高级 top"
    # light: "调节亮度"
    pamixer: "调节音量"
    procs: "查看进程"
    wiremix: "音量面板"
    dysk: "统计分区大小"
    erdtree: "体积伴随文件树"
    macchina: "系统信息"
    udisk: { packages: ["udisks2", "udiskie"], desc: "Usb device auto mount" }
    cyme: "usb 设备查看"
    qpwgraph: "音频设备拓扑图"

    # network
    # networkmanager: { packages: [ "networkmanager", "stalonetray", "network-manager-applet"] }
    inetutils: "telnet"
    gping: "图形化 ping"
    traceroute: "路由显形"
    lsof: "监测端口"
    flclash: "飞越长城"
    openssh: "ssh"
    xh: "Friendly and fast tool for sending HTTP requests"
    rustscan: "扫描端口"

    # show
    asciinema: "录制命令行视频"
    screenkey: "按键回显"
    # obs-studio: "流录制"

    # cargo
    cargo-shear: { manager: "cargo", desc: "检查无用依赖" }
    cargo-nextest: { manager: "cargo", desc: "检查无用依赖" }
    cargo-msrv: "最旧可用 rustc 版本"
    cargo-expand: "展开宏"
    cargo-edit: "编辑依赖"
    cargo-supply-chain: "依赖元信息"
    cargo-deny: "分析依赖"
    cargo-audit: { packages: ["cargo-audit", "cargo-auditable"], desc: "审计" }
    cargo-depgraph: "依赖图"
    cargo-update: "更新 cargo 安装的应用"
    cargo-cache: "管理缓存"
    cargo-zigbuild: "无痛链接指定版本 glibc"
    cargo-wizard: "编译配置"
    cargo-binstall: "下载 crate 的二进制"
    cargo-get: { manager: "cargo", desc: "读取 Cargo.toml 信息" }
    cargo-workspace-unused-pub: {
        packages: ["https://github.com/cpg314/cargo-workspace-unused-pub.git"]
        manager: "cargo:src"
        desc: "检查工作空间未使用的 pub 项"
    }
    cargo-insta: "懒人测试"
    cargo-autoinherit: { manager: "cargo", desc: "一键收束工作空间下的依赖" }
    cargo-bloat: "查看依赖的空间占用情况"

    # arch
    nvrs: { manager: "paru", packages: ["nvrs-bin"], desc: "检查包版本" }
    pacman-contrib: "打包工具箱"
    aurpublish: "打包钩子"
    alhp-keyrings: { manager: "paru", packages: ["alhp-keyring", "alhp-mirrorlist"], desc: "alhp-keyrings" }
    pacfiles: "pacfiles is a pacman -F alternative that runs blazingly fast"

    # amd
    amd-ucode: "AMD CPU driver"
    xf86-video-amdgpu: "AMD GPU video accelerator"

    # misc
    v4l2loopback-dkms: "Virtual camera with screen"
    rclone: "Net Drive Synchronization"
    libfido2: "ssh-agent dependency"
    genact: "Linux 领域大神"
    ngrok: { manager: "paru", desc: "内网穿透"}

    # niri
    niri: "卷轴桌面"
    xwayland-satellite: "新一代wayland到X11的适配器"
    libnotify: "通知"
    satty: "编辑图片"
    alsa-ucm-conf: "ALSA接线图"
    alsa-firmware: "ALSA固件"
    brightnessctl: "亮度调节"
    # awww: "壁纸上屏"
    cliphist: "剪贴板历史"
    matugen: "材料设计颜色生成"
    dgop: "资源信息监控"
    quickshell: ""
    dms-shell: { packages: ["dms-shell-niri", "cups-pk-helper"], desc: "极致 quickshell" }
    wl-clipboard: "Wayland Clipboard"
    # waybar: "Status bar"
    grim: "Screen cut"
    slurp: "Screen area cut"
    wl-screenrec-git: "rust wayland screen recorder"
    # wf-recorder: "cpp wayland screen recorder"
    # hyprland: { packages: [ "hyprland", "hyprlock", "hypridle", "cpio", "xdg-desktop-portal-hyprland", "qt5-wayland", "hyprsunset", "hyprpolkitagent", "hyprpicker" ] }
    xdg-desktop-portal-gnome: ""
    xdg-desktop-portal-gtk: ""
    qt6-multimedia-ffmpeg: ""
    rofi: "Menu"
    binary: "Binary Calculator"
    # https://github.com/casualsnek/waydroid_script
    # waydroid: { packages: [ "lzip", "waydroid" ]}

    # AI
    codex: {
        packages: ["openai-codex"],
        desc: "Codex",
    },
    llmfit: {
        packages: ["llmfit-bin"],
        manager: "paru",
        desc: "根据需求找模型",
    },
    ## pi
    pi: {
        packages: ["@earendil-works/pi-coding-agent"],
        manager: "pnpm",
        desc: "agent核",
    },
    pi-web-access: {
        packages: ["npm:pi-web-access"],
        manager: "pi",
        desc: "上网工具",
    },
    pi-permission-system: {
        packages: ["npm:@gotgenes/pi-permission-system"],
        manager: "pi",
        desc: "权限管理",
    },
    pi-fff: {
        packages: ["npm:@ff-labs/pi-fff"],
        manager: "pi",
        desc: "搜索工具",
    },
    pi-skills: {
        packages: ["npm:@spences10/pi-skills"],
        manager: "pi",
        desc: "技能管理",
    },
    pi-tool-display: {
        packages: ["npm:pi-tool-display"],
        manager: "pi",
        desc: "美化工具输出",
    },
    pi-anycopy: {
        packages: ["npm:pi-anycopy"],
        manager: "pi",
        desc: "复制会话历史",
    },
    pi-btw: {
        packages: ["npm:@narumitw/pi-btw"],
        manager: "pi",
        desc: "临时提问",
    },
    rpiv-ask-user-question: {
        packages: ["npm:@juicesharp/rpiv-ask-user-question"],
        manager: "pi",
        desc: "结构化问卷",
    },
    pi-codex-conversion: {
        packages: ["npm:@howaboua/pi-codex-conversion"],
        manager: "pi",
        desc: "pi的codex实现",
    },
    plannotator: {
        packages: ["npm:@plannotator/pi-extension"],
        manager: "pi",
        desc: "review代码",
    },
    # pi-cursor-sdk: {
    #     packages: ["npm:pi-cursor-sdk"],
    #     manager: "pi",
    #     desc: "Cursor桥接层",
    # },
}

def main [
    --managers (-M): string = 'all',
] {
    let managers = if $managers == 'all' {
        [
            'paru'
            'npm'
            'cargo-binstall'
            'cargo'
            'uv'
            'pnpm'
            'pi'
        ]
    } else {
        $managers | split row ','
    }

    let manifest = $MANIFEST
        | items {|k, v|
            if ($v | describe) == 'string' {
                {
                    name: $k,
                    desc: $v,
                }
            } else {
                {
                    name: $k,
                    ...$v
                }
            }
        }

    let paru = which paru | get -o 0.path
    let cargo = which cargo | get -o 0.path
    let cargo_binstall = which cargo-binstall | get -o 0.path
    let npm = which npm | get -o 0.path
    let uv = which uv | get -o 0.path
    let pnpm = which pnpm | get -o 0.path
    let pi = which pi | get -o 0.path

    mut tbl = {
        pacman: [],
        paru: [],
        cargo: [],
        'cargo:src': [],
        npm: [],
        uv: [],
        pnpm: [],
        pi: [],
    }

    for it in $manifest {
        let packages = $it.packages? | default [$it.name]
        let mgr = $it.manager? | default 'pacman'

        let subtbl = $tbl | get $mgr | append $packages
        $tbl = $tbl | upsert $mgr $subtbl
    }


    # Arch package
    if ('paru' in $managers) and ($paru != null) {
        if (($tbl.pacman | length) > 0) or (($tbl.paru | length) > 0) {
            ^$paru -Sy --needed ...$tbl.pacman ...$tbl.paru
        }
    } else {
        if ($tbl.pacman | length) > 0 {
            sudo pacman -Sy --needed ...$tbl.pacman
        }
    }


    # npm
    if ('npm' in $managers) and ($npm != null) and (($tbl.npm | length) > 0) {
        ^$npm install -g ...$tbl.npm
    }


    # cargo binstall
    if ('cargo-binstall' in $managers) and ($cargo_binstall != null) and (($tbl.cargo | length) > 0) {
        ^$cargo_binstall ...$tbl.cargo
    }


    # cargo source
    if ('cargo' in $managers) and ($cargo != null) {
        for p in $tbl.'cargo:src' {
            ^$cargo install --git $p
        }
    }


    # uv
    if ('uv' in $managers) and ($uv != null) {
        for p in $tbl.uv {
            ^$uv tool install $p
        }
    }


    # pnpm
    if ('pnpm' in $managers) and ($pnpm != null) {
        for p in $tbl.pnpm {
            ^$pnpm install -g --ignore-scripts $p
        }
    }


    # pi extensions
    if ('pi' in $managers) and ($pi != null) {
        for p in $tbl.pi {
            ^$pi install $p
        }
    }
}
