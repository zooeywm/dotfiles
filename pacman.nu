#!/usr/bin/env nu

const MANIFEST = {
    # 社交
    QQ: { packages: ["linuxqq-nt-bwrap"], manager: "paru" },
    telegram: { packages: ["telegram-desktop"], },
    wechat: { packages: ["wechat-universal-bwrap"], manager: "paru", },
    wemeet: { packages: ["wemeet-bin"], manager: "paru", },
    feishu: { packages: ["feishu-bin"], manager: "paru", },

    # OS
    QEMU: { packages: ["qemu-full"], },
    ventoy: { manager: "paru", packages: ["ventoy-bin"], desc: "制作镜像盘" },
    podman: "容器运行时",

    # kernel
    mkinitcpio-firmware.manager: "paru",
    sof-firmware: "Audio card firmware",
    linux-headers: "内核头文件",
    pipewire: { packages: [ "pipewire", "wireplumber", "pipewire-pulse", "pipewire-alsa", "pipewire-jack", "pipewire-v4l2" ], desc: "音频系统" },
    ntp: "Time sync daemon",

    # PL
    gdb: "GNU 调试器",
    lldb: "LLVM 调试器",
    mold: "现代链接器",
    rust-script: "rust 脚本解释器",
    rustup: "管理 rust 工具链",
    tokei: "统计代码",
    gcc: "GNU 的C/C++工具链",
    rescript: { manager: "npm", desc: "rescript 工具链" },
    nrm: { manager: "npm", desc: "管理npm镜像源" },
    cargo-binutils: { manager: "cargo", desc: "Rust二进制工具" },
    lua-language-server: "",
    stylua: "lua格式化器",
    taplo-cli: "toml语言工具",
    shfmt: "bash/zsh格式化器",
    gopls: "Go语言服务器",
    yaml-language-server: { manager: "npm" },
    volar: { manager: "npm", packages: ["@vue/language-server"] },
    prettier: { manager: "npm", packages: ["prettier", "@prettier/plugin-xml"], desc: "前端格式化器" },
    mise: { manager: "paru", packages: ["mise-bin"], desc: "管理语言工具链" },
    bash-language-server: { manager: "npm" },
    mlc: { manager: "cargo", desc: "markdown linter" },
    sccache: "编译缓存",
    kondo: "扫除编译产物",
    cargo-flamegraph: "绘制火焰图及cargo配套插件",
    clang: { packages: ["clang", "llvm"], desc: "C/C++工具链" },
    slint-lsp: { manager: "cargo", desc: "slint lsp" },
    typescript: { manager: "npm", packages: ["typescript", "typescript-language-server"] },
    typst: { packages: ["typst", "typstyle-bin"], manager: "paru" },
    tinymist-bin: ""
    tree-sitter-cli: "安装tree-sitter解析器",
    uv: "python项目管理",
    ruff: "python格式化器",
    basedpyright: { manager: "uv", desc: "python语言服务器", },
    hugo: "blog",
    cmake-language-server: "Cmake Language Server",
    strace: "Bin stack trace",
    qt6-languageserver: "qt6 languageserver"

    # desktop
    xdg-user-dirs: "规范目录",
    qt-theme: { packages: ["qt6ct", "qt5ct", "kvantum"] },
    kitty: "kitty",
    wezterm: { packages: ["wezterm-git"], desc: "现代终端模拟器" },
    dolphin: { packages: ["dolphin", "ffmpegthumbs", "kdegraphics-thumbnailers"], desc: "KDE文件管理器" },
    spectacle: "KDE截图",
    fcitx: { packages: ["fcitx5-im", "fcitx5-chinese-addons", "fcitx5-pinyin-zhwiki"], desc: "小企鹅输入法" },
    nerd-fonts: "书呆子字体",
    noto-fonts: { packages: [ "noto-fonts", "noto-fonts-emoji", "noto-fonts-extra", "noto-fonts-cjk" ], desc: "零豆腐块字体" },
    polkit-kde-agent: "Authorization Panel",
    polkit: "Policy kit",
    thunar: { packages: [ "thunar", "tumbler", "webp-pixbuf-loader" ], desc: "File manager" },
    bluez: "Blutooth kernel",
    bluez-utils: "Bluetooth cli",

    ## wayland
    wl-clipboard: "剪贴板",
    cliphist: "剪贴板历史",
    swww: "Wallpaper engine",
    waybar: "Status bar",
    grim: "Screen cut",
    slurp: "Screen area cut",
    wf-recorder: "wayland screen recorder",
    dunst: "Notify channel",
    satty: { manager: "paru", desc: "Screen cut editor" },
    hyprland: { packages: [ "hyprland", "hyprlock", "hypridle", "wlroots", "cpio", "xdg-desktop-portal-hyprland-git", "qt5-wayland" ] },
    rofi-wayland: "Menu",

    # clients
    firefox: "Mozilla firefox",
    dbeaver: "PostgreSQL客户端",
    sqlitebrowser: "SQLite客户端",
    wps: { packages: [ "wps-office-cn", "wps-office-mui-zh-cn", ], manager: "paru", desc: "WPS本体+中文语言包" },

    # shell
    nushell: "结构化shell",
    mcfly: "历史命令",
    starship: "装饰提示符",
    zoxide: "瞬移",
    zellij: "终端复用器",
    bash-completion: "bash补全",
    zsh: { packages: ["zsh", "zsh-completions"], desc: "zsh 及额外补全包" },
    terminus-font: "Outter terminal font",
    
    # filesystem
    eza: "高级ls",
    rsync: "超级复制",
    parallel-disk-usage: "磁盘空间统计",
    yazi: { packages: ["yazi-git", "jq", "ffmpegthumbnailer", "unarchiver"], desc: "终端文件管理器" },
    gparted: "分区GUI",
    exfatprogs: "exfat格式化工具",
    conceal: { packages: ["conceal-bin"], manager: "paru", desc: "垃圾回收站" },

    # utility
    man: { packages: ["man-db", "man-pages"], desc: "手册" },
    less: "pager",
    bat: "高级cat",
    choose: "高级cut",
    dos2unix: "改变文本的平台",
    enca: "检查文件编码",
    fd: "搜索文件",
    jaq: "高级jq",
    jless: "json阅读器",
    ripgrep: "正则匹配行",
    ripgrep-all: "万能正则匹配行",
    sd: "高级sed",
    skim: "模糊搜索.rs",
    fzf: "模糊搜索.go",
    tree: "树视图",
    protobuf: "ProtocolBuffers",
    navi: "命令速查",
    pastel: "调色板",
    hyperfine: "竞争测试",
    pueue: "守护大任务",
    hexyl: "hex查看器",
    libtree: "程序的库依赖树视图",

    # git
    gitui: "git TUI",
    difftastic: "语言diff",
    git-cliff: "变更日志生成器",
    gitoxide: "锈化git",
    git-filter-repo: "过滤git项目",
    serie: "分支树",

    # data
    p7zip: "7z",
    unrar: "解压RAR",
    zip: { packages: ["zip", "unzip"] },
    qbittorrent: "下载种子",

    # media
    imagemagick: "图片瑞士军刀",
    mpv: "看视频",
    viu: "终端看图",
    yt-dlp: "下载Youtube视频",
    dagtoc: { packages: ["dagtoc-bin"], manager: "paru", desc: "操作PDF目录" },
    pandoc: { packages: ["pandoc-bin"], desc: "LaTex渲染器" },
    kid3-qt: "编辑音乐标签",
    krita: "绘画",
    espeak: { packages: ["espeak-ng"], desc: "Ebook speaker" },
    mupdf-tools: "PDF工具箱",
    gwenview: "看图",
    zathura: { packages: ["zathura", "zathura-pdf-mupdf"], desc: "PDF阅读器" },
    webp-pixbuf-loader: "GDK的webp支持",
    inkscape: "操作矢量图",

    # language
    pot-translation: "一站式翻译",
    didyoumean: { packages: ["didyoumean-bin"], manager: "paru", desc: "纠正英文单词" },

    # monitor
    acpi: "电池信息",
    bandwhich: "监测网络带宽",
    bottom: "高级top",
    light: "调节亮度",
    brightnessctl: "Adjust lightness",
    pamixer: "调节音量",
    procs: "查看进程",
    pulsemixer: "音量面板",
    duf: "统计分区大小",
    erdtree: "体积伴随文件树",
    macchina: "系统信息",
    udisk: { packages: ["udisks2", "udiskie"], desc: "Usb device auto mount" },

    # network
    networkmanager: "",
    gping: "图形化ping",
    traceroute: "路由显形",
    lsof: "监测端口",
    v2raya: "飞越长城",
    clash-verge: "飞越长城",
    openssh: "ssh",

    # show
    asciinema: "录制命令行视频",
    screenkey: "按键回显",
    silicon: "代码截图",
    obs-studio: "流录制",

    # cargo
    cargo-generate: "项目模板",
    cargo-machete: "检查无用依赖",
    cargo-msrv: "最旧可用rustc版本",
    cargo-expand: "展开宏",
    cargo-edit: "编辑依赖",
    cargo-supply-chain: "依赖元信息",
    cargo-deny: "分析依赖",
    cargo-audit: { packages: ["cargo-audit", "cargo-auditable"], desc: "审计" },
    cargo-depgraph: "依赖图",
    cargo-update: "更新cargo安装的应用",
    cargo-cache: { manager: "cargo", desc: "管理缓存" },
    cross: { manager: "cargo", desc: "交叉编译" },
    cargo-zigbuild: "无痛链接指定版本glibc",
    cargo-wizard: { manager: "cargo", desc: "编译配置" },
    cargo-binstall: "下载crate的二进制",
    cargo-get: { manager: "cargo", desc: "读取Cargo.toml信息" },

    # arch
    nvchecker: "检查包版本",
    pacman-contrib: "打包工具箱",
    aurpublish: "打包钩子",
    archlinuxcn-keyring: "",

    # amd
    mesa-vdpau: "Gpu video accelerator",
    amd-ucode: "AMD CPU driver",
    xf86-video-amdgpu: "AMD GPU video accelerator",

    # misc
    qalculate-qt: "Calculator",
    vmware-workstation.manager: "paru",
    v4l2loopback-dkms: "Virtual camera with screen",
    rclone: "Net Drive Synchronization"
}

def main [] {
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

    let paru = try { which paru | get 0 | get path }
    let cargo = try { which cargo | get 0 | get path }
    let cargo_bin = try { which cargo-binstall | get 0 | get path }
    let npm = try { which npm | get 0 | get path }
    let uv = try { which uv | get 0 | get path }

    mut tbl = {
        pacman: [],
        paru: [],
        cargo: [],
        # 'cargo:src': [],
        npm: [],
        uv: [],
    }
    for it in $manifest {
        let packages = try { $it.packages } | default [$it.name]
        let mgr = try { $it.manager } | default 'pacman'

        let subtbl = $tbl | get $mgr | append $packages
        $tbl = $tbl | upsert $mgr $subtbl
    }

    try {
        if $paru != null {
            paru -Sy --needed ...$tbl.paru
        } else {
            pacman -Sy --needed ...$tbl.pacman
        }
    }

    try {
        if $npm != null {
            npm install -g ...$tbl.npm
        }
    }

    try {
        if $cargo_bin != null {
            cargo binstall ...$tbl.cargo
        }
    }

    # try {
    #     if $cargo != null {
    #         cargo install ...$tbl.'cargo:src'
    #     }
    # }

    try {
        if $uv != null {
            uv tool install ...$tbl.uv
        }
    }
}
