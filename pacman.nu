#!/usr/bin/env -S nu --stdin

# pacman.nu — 软件包状态引擎
#
# 本体不写软件，只读清单并收敛系统：
#   packages/system.toml    系统核心（内核/引导/基础运行时）
#   packages/drivers.toml   驱动/固件/硬件支持
#   packages/others.toml    其余软件（pacman + cargo + uv + bun + rustup）
#
# 管理器优先级：pacman（官方/archlinuxcn/AUR）> 其他。非 pacman 声明若在
# pacman 侧存在会被 audit/sync 直接报错。
#
# 用法：
#   ./pacman.nu                 默认 sync：装缺失，逐项询问卸载未声明
#   ./pacman.nu sync [flags]    同上
#   ./pacman.nu update          升级：pacman/AUR 全量 + 原生管理器里清单内的包
#   ./pacman.nu audit           只报告差异，有差异时退出码 1
#   ./pacman.nu export          从当前系统导出清单（TOML 输出到 stdout）
#   ./pacman.nu list            打印合并后的清单
#
# flags: --dry-run(-n) 只打印计划 / --yes(-y) 不询问 / --no-prune 不卸载
#        校验：仅官方仓库/archlinuxcn 已有才报错；AUR 独有的工具仍用 cargo/uv/bun

const MANAGERS = ['pacman' 'cargo' 'uv' 'bun' 'rustup']
const TABLE_MANAGERS = ['pacman' 'cargo' 'uv' 'bun']

# ---------- 清单 ----------

def base-dir [] { $env.FILE_PWD }

def manifest-files [] {
    let dir = ((base-dir) | path join 'packages')
    ['system' 'drivers' 'others'] | each {|n| $dir | path join $"($n).toml" }
}

def load-manifest [] {
    mut out = {pacman: {}, cargo: {}, uv: {}, bun: {}, rustup: []}
    mut seen: list<string> = []
    for f in (manifest-files) {
        if not ($f | path exists) {
            error make {msg: $"清单缺失: ($f)"}
        }
        let doc = (open $f)
        for mgr in ($doc | columns) {
            if $mgr == 'rustup' {
                for tc in ($doc | get rustup | get toolchains) {
                    let key = $"rustup:($tc)"
                    if $key in $seen { error make {msg: $"重复声明: ($key)（($f)）"} }
                    $seen = ($seen | append $key)
                    $out = ($out | upsert rustup ($out.rustup | append $tc))
                }
            } else if $mgr in $TABLE_MANAGERS {
                let tbl = ($doc | get $mgr)
                for name in ($tbl | columns) {
                    let key = $"($mgr):($name)"
                    if $key in $seen { error make {msg: $"重复声明: ($key)（($f)）"} }
                    $seen = ($seen | append $key)
                    $out = ($out | upsert $mgr ($out | get $mgr | insert $name ($tbl | get $name)))
                }
            } else {
                error make {msg: $"未知管理器: ($mgr)（($f)）"}
            }
        }
    }
    $out
}

# ---------- 系统状态 ----------

def installed-pacman [] {
    ^pacman -Qq -e
    | lines
    | where {|x| ($x | str trim | str length) > 0 }
}

def installed-cargo [] {
    ^cargo install --list
    | lines
    | where {|l| ($l | str length) > 0 and not ($l | str starts-with ' ') }
    | each {|l| $l | split row ' v' | first }
}

def installed-uv [] {
    ^uv tool list
    | lines
    | where {|l| ($l | str length) > 0 and not ($l | str starts-with ' ') and not ($l | str starts-with '- ') }
    | each {|l| $l | split row ' ' | first }
}

def installed-bun [] {
    let home = $env.HOME
    let candidates = [
        ($env.BUN_INSTALL? | default '')
        ($home | path join '.cache' '.bun')
        ($home | path join '.bun')
    ] | where {|p| $p != '' }
    let found = (
        $candidates
        | each {|p| $p | path join 'install' 'global' 'package.json' }
        | where {|p| $p | path exists }
    )
    if ($found | is-empty) {
        []
    } else {
        let d = (open ($found | first))
        if ('dependencies' in ($d | columns)) { $d.dependencies | columns } else { [] }
    }
}

def installed-rustup [] {
    ^rustup toolchain list
    | lines
    | where {|l| ($l | str length) > 0 }
    | each {|l| $l | split row ' ' | first | split row '-' | first }
}

def installed-all [] {
    {
        pacman: (installed-pacman)
        cargo: (installed-cargo)
        uv: (installed-uv)
        bun: (installed-bun)
        rustup: (installed-rustup)
    }
}

# ---------- 计划 ----------

def plan [manifest] {
    let installed = (installed-all)
    mut p = {}
    for mgr in $TABLE_MANAGERS {
        let desired = ($manifest | get $mgr | columns)
        let inst = ($installed | get $mgr)
        $p = ($p | insert $mgr {
            install: ($desired | where {|x| not ($x in $inst) })
            remove: ($inst | where {|x| not ($x in $desired) })
        })
    }
    let rd = ($manifest.rustup | uniq)
    let ri = ($installed.rustup | uniq)
    $p = ($p | insert rustup {
        install: ($rd | where {|x| not ($x in $ri) })
        remove: ($ri | where {|x| not ($x in $rd) })
    })
    $p
}

def drift-count [p] {
    $MANAGERS | each {|m|
        ($p | get $m | get install | length) + ($p | get $m | get remove | length)
    } | math sum
}

# ---------- 校验（pacman 优先） ----------

def repo-has [name] {
    (^pacman -Si $name | complete).exit_code == 0
}



def normalize-pkg [name] {
    let parts = ($name | split row '/')
    let base = if ($parts | length) > 1 { $parts | skip 1 | str join '/' } else { $name }
    $base | str replace -a '_' '-'
}

def pkg-candidates [name] {
    let norm = (normalize-pkg $name)
    let scoped = if ($name | str starts-with '@') {
        let parts = ($name | split row '/')
        let scope = (($parts | first) | str replace -a '@' '')
        let inner = ($parts | skip 1 | str join '/')
        $"($scope)-($inner)" | str replace -a '_' '-'
    } else {
        $norm
    }
    ([$name $norm $scoped] | uniq | where {|c| ($c | str length) >= 5 })
}

def validate [manifest] {
    let entries = (['cargo' 'uv' 'bun'] | each {|mgr|
        ($manifest | get $mgr | columns) | each {|n| {mgr: $mgr, name: $n} }
    } | flatten)
    let problems = ($entries | par-each {|e|
        let cands = (pkg-candidates $e.name)
        let repo_hit = ($cands | where {|c| repo-has $c } | first)
        if not ($repo_hit | is-empty) {
            $"($e.mgr):($e.name) ≈ pacman 仓库包 ($repo_hit) → 按 pacman 优先应移入 [pacman]"
        } else {
            null
        }
    } | where {|x| $x != null })
    if ($problems | length) > 0 {
        error make {msg: ($problems | str join '；')}
    }
}

# ---------- 安装 ----------

# 流式执行外部命令：stdout/stderr 直接打到终端，进度条/下载速度可见；
# 返回是否成功（替代会吞掉实时输出的 | complete）。
def run-live [label: string, ...cmd: string]: nothing -> bool {
    try {
        run-external ...$cmd
        true
    } catch {
        let code = ($env.LAST_EXIT_CODE | default '?')
        print $"(ansi red)失败 ($label): exit ($code)(ansi reset)"
        false
    }
}

def install-pacman [names] {
    if ($names | is-empty) { return [] }
    print $"(ansi green)安装 pacman: ($names | str join ' ')(ansi reset)"
    if (run-live 'pacman' ...(['paru' '-S' '--needed' '--noconfirm'] ++ $names)) {
        []
    } else {
        $names
    }
}

def install-cargo [manifest, names] {
    mut failed = []
    for name in $names {
        let meta = ($manifest.cargo | get $name)
        let git = ($meta | get --optional git)
        let pkg = ($meta | get --optional package)
        let locked = (($meta | get --optional locked) | default false)
        # 可选字段：package = "crate 名"（git 仓库含多个二进制时指定）、
        #           locked = true（用 crate 自带 Cargo.lock，避免新依赖编译失败）
        let ok = if not ($git | is-empty) {
            print $"(ansi green)安装 cargo-git: ($name)(ansi reset)"
            let extra = (if ($pkg | is-empty) { [] } else { [$pkg] })
            run-live $"cargo:($name)" ...(['cargo' 'install' '--git' $git '--force'] ++ $extra)
        } else {
            print $"(ansi green)安装 cargo: ($name)(ansi reset)"
            let extra = (if $locked { ['--locked'] } else { [] })
            run-live $"cargo:($name)" ...(['cargo' 'install' '--force' $name] ++ $extra)
        }
        if not $ok { $failed = ($failed | append $"cargo:($name)") }
    }
    $failed
}

def install-uv [names] {
    if ($names | is-empty) { return [] }
    print $"(ansi green)安装 uv: ($names | str join ' ')(ansi reset)"
    if (run-live 'uv' ...(['uv' 'tool' 'install'] ++ $names)) {
        []
    } else {
        print $"(ansi yellow)uv 批量安装失败，逐个重试…(ansi reset)"
        mut failed = []
        for name in $names {
            if not (run-live $"uv:($name)" ...['uv' 'tool' 'install' $name]) {
                $failed = ($failed | append $"uv:($name)")
            }
        }
        $failed
    }
}

def install-bun [names] {
    if ($names | is-empty) { return [] }
    print $"(ansi green)安装 bun: ($names | str join ' ')(ansi reset)"
    if (run-live 'bun' ...(['bun' 'add' '-g'] ++ $names)) {
        []
    } else {
        print $"(ansi yellow)bun 批量安装失败，逐个重试…(ansi reset)"
        mut failed = []
        for name in $names {
            if not (run-live $"bun:($name)" ...['bun' 'add' '-g' $name]) {
                $failed = ($failed | append $"bun:($name)")
            }
        }
        $failed
    }
}

def install-rustup [names] {
    mut failed = []
    for ch in $names {
        print $"(ansi green)安装 rustup: ($ch)(ansi reset)"
        if not (run-live $"rustup:($ch)" ...['rustup' 'toolchain' 'install' $ch]) {
            $failed = ($failed | append $"rustup:($ch)")
        }
    }
    $failed
}

# ---------- 卸载 ----------

def remove-pacman [names] {
    if ($names | is-empty) { return }
    print $"(ansi red)卸载 pacman: ($names | str join ' ')(ansi reset)"
    let r = (^sudo pacman -Rns --noconfirm ...$names | complete)
    if $r.exit_code != 0 {
        print $"(ansi yellow)批量卸载失败，逐个尝试…(ansi reset)"
        for n in $names {
            let one = (^sudo pacman -Rns --noconfirm $n | complete)
            if $one.exit_code != 0 {
                let why = (($one.stderr | str trim) | str substring 0..200)
                print $"(ansi yellow)跳过 ($n): ($why)(ansi reset)"
            }
        }
    }
}

def confirm [text: string] {
    try {
        let a = (input $text)
        (($a | str trim | str lowercase) in ['y' 'yes'])
    } catch {
        false
    }
}

# ---------- 命令 ----------

def require-tools [] {
    for c in ['paru' 'cargo' 'uv' 'bun' 'rustup' 'pacman'] {
        if ((which $c | length) == 0) {
            error make {msg: $"缺少命令: ($c)"}
        }
    }
}

def sync [--dry-run, --yes, --no-prune] {
    require-tools
    let manifest = (load-manifest)
    validate $manifest
    let p = (plan $manifest)

    print ""
    print $"(ansi green_bold)== 安装 ==(ansi reset)"
    let missing = ($MANAGERS | each {|m|
        let xs = ($p | get $m | get install)
        if ($xs | is-empty) { null } else { $"  ($m): ($xs | str join ' ')" }
    } | where {|x| $x != null })
    if ($missing | is-empty) { print "  无" } else { $missing | each {|l| print $l } }

    print ""
    print $"(ansi yellow_bold)== 卸载（已装但清单未声明）==(ansi reset)"
    let extra = ($MANAGERS | each {|m|
        let xs = ($p | get $m | get remove)
        if ($xs | is-empty) { null } else { $"  ($m): ($xs | str join ' ')" }
    } | where {|x| $x != null })
    if ($extra | is-empty) { print "  无" } else { $extra | each {|l| print $l } }
    print ""

    if $dry_run {
        print "(dry-run：未做任何修改)"
        return
    }

    # 1) 安装
    mut failures = []
    $failures = ($failures | append (install-pacman ($p.pacman.install)))
    $failures = ($failures | append (install-cargo $manifest ($p.cargo.install)))
    $failures = ($failures | append (install-uv ($p.uv.install)))
    $failures = ($failures | append (install-bun ($p.bun.install)))
    $failures = ($failures | append (install-rustup ($p.rustup.install)))

    # 安装失败时不做任何卸载，避免出现“旧的删了、新的没装”的空窗
    if not ($failures | is-empty) {
        print ""
        print $"(ansi red)有 ($failures | length) 项安装失败，已跳过全部卸载。先处理失败项再重跑。(ansi reset)"
        exit 1
    }

    # 2) 卸载
    if not $no_prune {
        mut removals = {pacman: [], cargo: [], uv: [], bun: [], rustup: []}
        for mgr in $MANAGERS {
            for name in ($p | get $mgr | get remove) {
                let ok = if $yes { true } else { confirm $"卸载未声明包 ($mgr):($name)? [y/N] " }
                if $ok {
                    $removals = ($removals | upsert $mgr ($removals | get $mgr | append $name))
                }
            }
        }
        remove-pacman ($removals.pacman)
        for n in ($removals.cargo) { print $"(ansi red)卸载 cargo: ($n)(ansi reset)"; ^cargo uninstall $n | ignore }
        for n in ($removals.uv) { print $"(ansi red)卸载 uv: ($n)(ansi reset)"; ^uv tool uninstall $n | ignore }
        for n in ($removals.bun) { print $"(ansi red)卸载 bun: ($n)(ansi reset)"; ^bun remove -g $n | ignore }
        for n in ($removals.rustup) { print $"(ansi red)卸载 rustup: ($n)(ansi reset)"; ^rustup toolchain uninstall $n | ignore }
    }

    # 3) 复检（--no-prune 时未声明项不算漂移）
    let after = (plan $manifest)
    let drift = if $no_prune {
        $MANAGERS | each {|m| ($after | get $m | get install | length) } | math sum
    } else {
        (drift-count $after)
    }
    if $drift == 0 {
        print $"(ansi green)完成：系统与清单一致(ansi reset)"
    } else {
        print $"(ansi yellow)完成：仍有 ($drift) 项差异（安装失败或被跳过）(ansi reset)"
        exit 1
    }
}

def audit [] {
    let manifest = (load-manifest)
    validate $manifest
    let p = (plan $manifest)

    print ""
    for mgr in $MANAGERS {
        let i = ($p | get $mgr | get install)
        let r = ($p | get $mgr | get remove)
        print $"(ansi green_bold)($mgr)(ansi reset) 缺失: ($i | length)，未声明: ($r | length)"
        if not ($i | is-empty) { print $"  + ($i | str join ' ')" }
        if not ($r | is-empty) { print $"  - ($r | str join ' ')" }
    }
    print ""
    let drift = (drift-count $p)
    if $drift > 0 {
        print $"(ansi yellow)存在 ($drift) 项差异(ansi reset)"
        exit 1
    } else {
        print $"(ansi green)系统与清单一致(ansi reset)"
    }
}

def export-manifest [] {
    let q = {|n| if ($n =~ '^[A-Za-z0-9_-]+$') { $n } else { '"' + $n + '"' } }
    mut out = ['# pacman.nu export — 当前系统状态（需人工按 system/drivers/others 分类）', '', '[pacman]']
    for n in (installed-pacman | sort) { $out = ($out | append ((do $q $n) + ' = {}')) }
    $out = ($out | append ['', '[cargo]'])
    for n in (installed-cargo | sort) { $out = ($out | append ((do $q $n) + ' = {}')) }
    $out = ($out | append ['', '[uv]'])
    for n in (installed-uv | sort) { $out = ($out | append ((do $q $n) + ' = {}')) }
    $out = ($out | append ['', '[bun]'])
    for n in (installed-bun | sort) { $out = ($out | append ((do $q $n) + ' = {}')) }
    let tc = (installed-rustup | sort | each {|t| '"' + $t + '"' } | str join ', ')
    $out = ($out | append ['', '[rustup]', ('toolchains = [' + $tc + ']')])
    $out | each {|l| print $l } | ignore
}

def list-manifest [] {
    let m = (load-manifest)
    for mgr in $MANAGERS {
        print $"(ansi green_bold)[($mgr)](ansi reset)"
        if $mgr == 'rustup' {
            print $"  ($m.rustup | str join ' ')"
        } else {
            ($m | get $mgr | columns) | each {|x| print $"  ($x)" } | ignore
        }
    }
}

# ---------- 升级 ----------

# 已安装的 cargo 包：name -> {version, src}（src 对 git 安装含 #hash）
def cargo-installed [] {
    mut out = {}
    for line in (^cargo install --list | complete | get stdout | lines) {
        let t = ($line | str trim)
        if not ($t | str ends-with ':') { continue }
        let m = ($t | parse --regex '^(?<name>\S+) v(?<ver>\S+)(?: \((?<src>[^)]+)\))?:$')
        if ($m | is-empty) { continue }
        $out = ($out | upsert $m.0.name {version: $m.0.ver, src: ($m.0 | get --optional src)})
    }
    $out
}

# crates.io sparse 索引的目录路径（cargo 的 1/2/3/4+ 字符规则）
def sparse-index-path [name: string] {
    let n = ($name | str lowercase)
    let len = ($n | str length)
    if $len <= 2 {
        $"($len)/($n)"
    } else if $len == 3 {
        $"3/($n | str substring 0..0)/($n)"
    } else {
        $"($n | str substring 0..1)/($n | str substring 2..3)/($n)"
    }
}

# rsproxy sparse 索引里的最新稳定版；失败回退 cargo search
def cargo-latest-version [name: string] {
    let r = (^curl -sSf --max-time 8 $"https://rsproxy.cn/index/(sparse-index-path $name)" | complete)
    if $r.exit_code == 0 {
        let vers = (
            $r.stdout | lines
            | where {|l| $l | str contains '"yanked":false' }
            | parse --regex '"vers":"(?<v>[^"]+)"'
            | get v
        )
        if not ($vers | is-empty) {
            let stable = ($vers | where {|v| not ($v | str contains '-') })
            let pool = (if ($stable | is-empty) { $vers } else { $stable })
            return ($pool | to text | ^sort -V | lines | last)
        }
        return ''
    }
    let s = (^cargo search $name --limit 1 --registry crates-io | complete)
    if $s.exit_code != 0 { return '' }
    let m = (($s.stdout | lines | first | default '') | parse --regex '= "(?<v>[^"]+)"')
    if ($m | is-empty) { '' } else { $m.0.v }
}

# 远端仓库 HEAD（git 安装的包用它判断有没有新提交）
def git-remote-hash [url: string] {
    let r = (^git ls-remote $url HEAD | complete)
    if $r.exit_code != 0 { return '' }
    let first = (($r.stdout | lines | first | default '') | split row "\t" | first | str trim)
    $first
}

# 并发检查清单里的 cargo 包：name -> {git, local, latest, local_hash, remote_hash, up_to_date}
def cargo-update-plan [manifest] {
    let installed = (cargo-installed)
    let rows = (
        ($manifest.cargo | columns) | par-each {|name|
            let meta = ($manifest.cargo | get $name)
            let git = ($meta | get --optional git)
            let inst = ($installed | get --optional $name)
            let local = (($inst | default {}).version? | default '')
            let src = (($inst | default {}).src? | default '')
            let lh = (($src | parse --regex '#(?<h>[0-9a-fA-F]+)') | get --optional 0 | default {} | get --optional h | default '')
            if not ($git | is-empty) {
                let remote = (git-remote-hash $git)
                {
                    name: $name, git: $git, local: $local, latest: '',
                    local_hash: $lh, remote_hash: $remote,
                    up_to_date: ((not ($lh | is-empty)) and (not ($remote | is-empty)) and ($remote | str starts-with $lh)),
                }
            } else {
                let latest = (cargo-latest-version $name)
                {
                    name: $name, git: '', local: $local, latest: $latest,
                    local_hash: '', remote_hash: '',
                    up_to_date: ((not ($local | is-empty)) and (not ($latest | is-empty)) and ((^vercmp $local $latest | str trim) != '-1')),
                }
            }
        }
    )
    $rows | reduce --fold {} {|it, acc| $acc | upsert $it.name $it }
}

# 升级：系统 + AUR 全量升级，再升级清单里各原生管理器管理的包。
def update [--dry-run] {
    let manifest = (load-manifest)

    if $dry_run {
        print $"(ansi green_bold)可升级的 pacman / AUR 包(ansi reset)"
        let repo = (^checkupdates | complete)
        if ($repo.stdout | str trim | is-empty) {
            print '  （仓库无更新）'
        } else {
            print $repo.stdout
        }
        let aur = (^paru -Qua | complete)
        if ($aur.stdout | str trim | is-empty) {
            print '  （AUR 无更新）'
        } else {
            print $aur.stdout
        }
        print $"(ansi green_bold)cargo(ansi reset)"
        let p = (cargo-update-plan $manifest)
        for name in ($manifest.cargo | columns) {
            let e = ($p | get --optional $name)
            if ($e | is-empty) { continue }
            if not ($e.git | is-empty) {
                if $e.up_to_date {
                    print $"  ($name): 已是远端最新（($e.local_hash)）"
                } else {
                    print $"  ($name): git 有新提交（($e.local_hash) -> ($e.remote_hash)）"
                }
            } else {
                if $e.up_to_date {
                    print $"  ($name): 已是最新（($e.local)）"
                } else {
                    print $"  ($name): ($e.local) -> ($e.latest)"
                }
            }
        }
        print $"(ansi green_bold)uv / bun / rustup(ansi reset)"
        print $"  uv: ($manifest.uv | columns | str join ' ')"
        print $"  bun: ($manifest.bun | columns | str join ' ')"
        print '  rustup update（跳过 nightly）'
        return
    }

    print $"(ansi green_bold)升级 pacman / AUR(ansi reset)"
    try {
        ^paru -Syu --noconfirm
    } catch {
        print $"(ansi red)pacman/paru 升级失败，已中止(ansi reset)"
        exit 1
    }

    mut failed = []

    print $"(ansi green_bold)升级 cargo(ansi reset)"
    let cplan = (cargo-update-plan $manifest)
    for name in ($manifest.cargo | columns) {
        let e = ($cplan | get --optional $name)
        if ($e | is-empty) { continue }
        let meta = ($manifest.cargo | get $name)
        let pkg = ($meta | get --optional package)
        let locked = (($meta | get --optional locked) | default false)
        if $e.up_to_date {
            if not ($e.git | is-empty) {
                print $"  ($name): 已是远端最新（($e.local_hash)）"
            } else {
                print $"  ($name): 已是最新（($e.local)）"
            }
        } else if not ($e.git | is-empty) {
            print $"  ($name): 从 git 重装"
            let extra = (if ($pkg | is-empty) { [] } else { [$pkg] })
            if not (run-live $"cargo:($name)" ...(['cargo' 'install' '--git' $e.git '--force'] ++ $extra)) {
                $failed = ($failed | append $"cargo:($name)")
            }
        } else {
            print $"  ($name): ($e.local) -> ($e.latest)"
            let lk = (if $locked { ['--locked'] } else { [] })
            if not (run-live $"cargo:($name)" ...(['cargo' 'install' '--force' $name] ++ $lk)) {
                $failed = ($failed | append $"cargo:($name)")
            }
        }
    }

    print $"(ansi green_bold)升级 uv(ansi reset)"
    let uv_names = ($manifest.uv | columns)
    if not ($uv_names | is-empty) {
        # uv tool upgrade 支持多包名，一次解析、只输出一次 Nothing to upgrade
        if not (run-live 'uv' ...(['uv' 'tool' 'upgrade'] ++ $uv_names)) {
            print $"(ansi yellow)uv 批量升级失败，逐个重试…(ansi reset)"
            for name in $uv_names {
                if not (run-live $"uv:($name)" ...['uv' 'tool' 'upgrade' $name]) {
                    $failed = ($failed | append $"uv:($name)")
                }
            }
        }
    }

    print $"(ansi green_bold)升级 bun(ansi reset)"
    let bun_names = ($manifest.bun | columns)
    if not ($bun_names | is-empty) {
        # 一次 bun add -g 处理全部包，只出一次版本横幅/一次解析
        if not (run-live 'bun' ...(['bun' 'add' '-g'] ++ $bun_names)) {
            print $"(ansi yellow)bun 批量升级失败，逐个重试…(ansi reset)"
            for name in $bun_names {
                if not (run-live $"bun:($name)" ...['bun' 'add' '-g' $name]) {
                    $failed = ($failed | append $"bun:($name)")
                }
            }
        }
    }

    print $"(ansi green_bold)升级 rustup toolchains（跳过 nightly）(ansi reset)"
    # nightly 每次更新都可能带来行为变化，固定不动；要更新时手动 rustup update nightly
    let tcs = (installed-rustup | where {|t| not (($t | str lowercase) | str starts-with 'nightly') })
    if ($tcs | is-empty) {
        print $"(ansi yellow)  只装了 nightly，跳过(ansi reset)"
    } else if not (run-live 'rustup' ...(['rustup' 'update'] ++ $tcs)) {
        $failed = ($failed | append 'rustup')
    }

    let p = (plan $manifest)
    let drift = (drift-count $p)
    print ""
    if not ($failed | is-empty) {
        print $"(ansi red)有 ($failed | length) 项升级失败: ($failed | str join ', ')(ansi reset)"
        exit 1
    }
    if $drift > 0 {
        print $"(ansi yellow)升级完成，但系统有 ($drift) 项与清单不一致（跑 ./pacman.nu 收敛）(ansi reset)"
    } else {
        print $"(ansi green)升级完成，系统与清单一致(ansi reset)"
    }
}

def main [
    action?: string
    --dry-run (-n)
    --yes (-y)
    --no-prune
] {
    let action = ($action | default 'sync')
    match $action {
        'sync' => { sync --dry-run=$dry_run --yes=$yes --no-prune=$no_prune },
        'audit' => { audit },
        'update' => { update --dry-run=$dry_run },
        'export' => { export-manifest },
        'list' => { list-manifest },
        _ => { error make {msg: $"未知命令: ($action)（可用: sync / update / audit / export / list）"} },
    }
}
