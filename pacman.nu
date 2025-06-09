#!/usr/bin/env -S nu --stdin

const MANIFEST = {
    # 社交
    QQ: { packages: ["linuxqq-nt-bwrap"], manager: "paru" },
    telegram: { packages: ["telegram-desktop"], },
    wechat: { packages: ["wechat"], manager: "paru", },
    wemeet: { packages: ["wemeet-bin"], manager: "paru", },
    feishu: { packages: ["feishu-bin"], manager: "paru", },

    # OS
    QEMU: { packages: ["qemu-full"], },
    ventoy: "制作镜像盘",
    podman: "容器运行时",

    # kernel
    mkinitcpio-firmware: { manager: "paru", desc: "get rid of the annoying 'WARNING: Possibly missing firmware for module:' messages" },
    sof-firmware: "Audio card firmware",
    linux-headers: "内核头文件",
    pipewire: { packages: [ "pipewire", "wireplumber", "pipewire-pulse", "pipewire-alsa", "pipewire-jack", "pipewire-v4l2" ], desc: "音频系统" },
    chrony: "Time sync daemon",

    # PL
    gdb: "GNU 调试器",
    neovim: "editor",
    neovide: "neovim gui",
    lldb: "LLVM 调试器",
    mold: "现代链接器",
    rust-script: "rust 脚本解释器",
    rustup: "管理 rust 工具链",
    tokei: "统计代码",
    gcc: "GNU 的 C/C++工具链",
    ast-grep: "匹配搜索 tree-sitter"
    cargo-binutils: { manager: "cargo", desc: "Rust 二进制工具" },
    lua-language-server: "lua language server",
    stylua: "lua 格式化器",
    taplo-cli: "toml 语言工具",
    shfmt: "bash/zsh 格式化器",
    gopls: "Go 语言服务器",
    yaml-language-server: { manager: "npm" },
    volar: { manager: "npm", packages: ["@vue/language-server"] },
    prettier: { manager: "npm", packages: ["prettier", "@prettier/plugin-xml"], desc: "前端格式化器" },
    biome: "前端格式化器"
    mise: "管理语言工具链",
    bash-language-server: { manager: "npm" },
    sccache: "编译缓存",
    kondo: "扫除编译产物",
    cargo-flamegraph: "绘制火焰图及 cargo 配套插件",
    clang: { packages: ["clang", "llvm"], desc: "C/C++工具链" },
    slint-lsp: { manager: "cargo", desc: "slint lsp" },
    plocate: "locate 的并行版本",
    pacfiles: { manager: "cargo", desc: "pacfiles is a pacman -F alternative that runs blazingly fast" },
    typescript: { manager: "npm", packages: ["typescript", "typescript-language-server"] },
    typst: { packages: ["typst", "tinymist", "typstyle"], },
    tree-sitter-cli: "安装 tree-sitter 解析器",
    uv: "Python package manager written in rust",
    ruff: "python 格式化器",
    basedpyright: { manager: "uv", desc: "python 语言服务器", },
    strace: "Bin stack trace",
    qt6-languageserver: "qt6 languageserver"
    astro-ls: {
        manager: "npm",
        packages: ["@astrojs/language-server"]
        desc: "AstroJS 的语言服务器",
    },

    # desktop
    xdg-user-dirs: "规范目录",
    qt-theme: { packages: ["qt6ct", "qt5ct", "kvantum"] },
    kitty: "kitty",
    wezterm: { packages: ["wezterm-git"], desc: "现代终端模拟器" },
    dolphin: { packages: ["dolphin", "ffmpegthumbs", "kdegraphics-thumbnailers"], desc: "KDE 文件管理器" },
    spectacle: "KDE 截图",
    fcitx: { packages: ["fcitx5-im", "fcitx5-chinese-addons", "fcitx5-pinyin-zhwiki"], desc: "小企鹅输入法" },
    nerd-fonts: "书呆子字体",
    noto-fonts: { packages: [ "noto-fonts", "noto-fonts-emoji", "noto-fonts-extra", "noto-fonts-cjk" ], desc: "零豆腐块字体" },
    polkit-kde-agent: "Authorization Panel",
    polkit: "Policy kit",
    bluez: "Bluetooth kernel",
    bluez-utils: "Bluetooth cli",
    overskride: { manager: "paru", desc: "Bluetooth GUI" },
    kalker: { manager: "paru", desc: "Terminal calculator" }

    ## wayland
    # wl-clipboard: "剪贴板",
    # cliphist: "剪贴板历史",
    copyq: "wayland 剪贴板客户端"
    swww: "Wallpaper engine",
    waybar: "Status bar",
    grim: "Screen cut",
    slurp: "Screen area cut",
    wl-screenrec: { packages: ["wl-screenrec-git"], desc: "wayland screen recorder" },
    dunst: "Notify channel",
    satty: { manager: "paru", desc: "Screen cut editor" },
    hyprland: { packages: [ "hyprland", "hyprlock", "hypridle", "cpio", "xdg-desktop-portal-hyprland", "qt5-wayland", "hyprsunset", "hyprpolkitagent", "hyprpicker" ] },
    rofi: "Menu",

    # clients
    zen-browser: "Browser using the firefox core vertical label bar",
    # dbeaver: "PostgreSQL 客户端",
    sqlitebrowser: "SQLite 客户端",
    wps: { packages: [ "wps-office-cn", "wps-office-mui-zh-cn", "ttf-wps-fonts", "wps-office-fonts" ], manager: "paru", desc: "WPS 本体+中文语言包+符号字体+中文常用字体" },

    # shell
    nushell: "结构化 shell",
    # mcfly: "历史命令",
    atuin: "历史命令",
    starship: "装饰提示符",
    zoxide: "瞬移",
    zellij: "终端复用器",
    bash-completion: "bash 补全",
    zsh: { packages: ["zsh", "zsh-completions"], desc: "zsh 及额外补全包" },
    terminus-font: "Outer terminal font",
    halp: "命令行选项标准化检验",
    aichat: "LLM CLI",

    # filesystem
    eza: "高级 ls",
    rsync: "超级复制",
    parallel-disk-usage: "磁盘空间统计",
    yazi: { packages: ["yazi-git", "jq", "ffmpegthumbnailer", "unarchiver", "ueberzugpp"], desc: "终端文件管理器" },
    resvg: { manager: "paru", desc: "for yazi SVG preview" }
    gparted: "分区 GUI",
    exfatprogs: "exfat 格式化工具",
    # conceal: { packages: ["conceal-bin"], manager: "paru", desc: "垃圾回收站" },

    # utility
    man: { packages: ["man-db", "man-pages"], desc: "手册" },
    less: "pager",
    bat: "高级 cat",
    choose: "高级 cut",
    dos2unix: "改变文本的平台",
    enca: "检查文件编码",
    fd: "搜索文件",
    jaq: "高级 jq",
    jless: "json 阅读器",
    ripgrep: "正则匹配行",
    ripgrep-all: "万能正则匹配行",
    sd: "高级 sed",
    skim: "模糊搜索.rs",
    fzf: "模糊搜索.go",
    tree: "树视图",
    protobuf: "ProtocolBuffers",
    navi: "命令速查",
    pastel: "调色板",
    hyperfine: "竞争测试",
    pueue: "守护大任务",
    hexyl: "hex 查看器",
    libtree: "程序的库依赖树视图",

    # git
    # gitui: "git TUI",
    lazygit: "git TUI",
    difftastic: "语言 diff",
    git-cliff: "变更日志生成器",
    gitoxide: "锈化 git",
    git-filter-repo: "过滤 git 项目",
    serie: "分支树",

    # data
    p7zip: "7z",
    unrar: "解压 RAR",
    zip: { packages: ["zip", "unzip"] },
    qbittorrent: "下载种子",

    # media
    imagemagick: "图片瑞士军刀",
    mpv: "看视频",
    viu: "终端看图",
    yt-dlp: "下载 Youtube 视频",
    dagtoc: { packages: ["dagtoc-bin"], manager: "paru", desc: "操作 PDF 目录" },
    pandoc: { packages: ["pandoc-bin"], desc: "LaTex 渲染器" },
    kid3-qt: "编辑音乐标签",
    espeak: { packages: ["espeak-ng"], desc: "Ebook speaker" },
    mupdf-tools: "PDF 工具箱",
    gwenview: "看图",
    zathura: { packages: ["zathura", "zathura-pdf-mupdf"], desc: "PDF 阅读器" },
    webp-pixbuf-loader: "GDK 的 webp 支持",
    inkscape: "操作矢量图",

    # language
    pot-translation: "一站式翻译",
    didyoumean: { packages: ["didyoumean-bin"], manager: "paru", desc: "纠正英文单词" },
    # pdf2zh: { manager: "uv", desc: "智能布局留存翻译PDF" },

    # monitor
    acpi: "电池信息",
    bandwhich: "监测网络带宽",
    bottom: "高级 top",
    light: "调节亮度",
    brightnessctl: "Adjust lightness",
    pamixer: "调节音量",
    procs: "查看进程",
    wiremix: "音量面板",
    dysk: "统计分区大小",
    erdtree: "体积伴随文件树",
    macchina: "系统信息",
    udisk: { packages: ["udisks2", "udiskie"], desc: "Usb device auto mount" },

    # network
    networkmanager: { packages: [ "networkmanager", "stalonetray", "network-manager-applet"] },
    gping: "图形化 ping",
    traceroute: "路由显形",
    lsof: "监测端口",
    # v2raya: "飞越长城",
    clash-verge: "飞越长城",
    openssh: "ssh",
    xh: "Friendly and fast tool for sending HTTP requests"
    rustscan: "扫描端口"

    # show
    asciinema: "录制命令行视频",
    # screenkey: "按键回显",
    obs-studio: "流录制",

    # cargo
    cargo-generate: "项目模板",
    cargo-shear: {
        manager: "cargo",
        desc: "检查无用依赖",
    },
    cargo-msrv: "最旧可用 rustc 版本",
    cargo-expand: "展开宏",
    cargo-edit: "编辑依赖",
    cargo-supply-chain: "依赖元信息",
    cargo-deny: "分析依赖",
    cargo-audit: { packages: ["cargo-audit", "cargo-auditable"], desc: "审计" },
    cargo-depgraph: "依赖图",
    cargo-update: "更新 cargo 安装的应用",
    cargo-cache: { manager: "cargo", desc: "管理缓存" },
    cargo-zigbuild: "无痛链接指定版本 glibc",
    cargo-wizard: { manager: "cargo", desc: "编译配置" },
    cargo-binstall: "下载 crate 的二进制",
    cargo-get: { manager: "cargo", desc: "读取 Cargo.toml 信息" },
    cargo-workspace-unused-pub: {
        packages: ["https://github.com/cpg314/cargo-workspace-unused-pub.git"],
        manager: "cargo:src",
        desc: "检查工作空间未使用的 pub 项",
    },
    cargo-insta: "懒人测试",
    cargo-bloat: "查看依赖的空间占用情况",

    # arch
    nvrs: { manager: "paru", packages: ["nvrs-bin"], desc: "检查包版本" },
    pacman-contrib: "打包工具箱",
    aurpublish: "打包钩子",
    archlinuxcn-keyring: "",

    # amd
    mesa-vdpau: "Gpu video accelerator",
    amd-ucode: "AMD CPU driver",
    xf86-video-amdgpu: "AMD GPU video accelerator",

    # misc
    vmware-workstation: { manager: "paru", desc: "vmware workstation" }
    v4l2loopback-dkms: "Virtual camera with screen",
    rclone: "Net Drive Synchronization"
    libfido2: "ssh-agent dependency"
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
        'cargo:src': [],
        npm: [],
        uv: [],
    }
    for it in $manifest {
        let packages = $it.packages? | default [$it.name]
        let mgr = $it.manager? | default 'pacman'

        let subtbl = $tbl | get $mgr | append $packages
        $tbl = $tbl | upsert $mgr $subtbl
    }

    try {
        if $paru != null {
            paru -Sy --needed ...$tbl.pacman ...$tbl.paru
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

    if $cargo != null {
        for p in $tbl.'cargo:src' {
            try {
                cargo install --git $p
            }
        }
    }

    try {
        if $uv != null {
            uv tool install ...$tbl.uv
        }
    }
}
