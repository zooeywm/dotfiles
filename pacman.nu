#!/usr/bin/env -S nu --stdin

# pacman.nu — 软件包状态引擎
#
# 本体不写软件，只读清单并收敛系统：
#   system/packages/system.toml    系统核心（内核/引导/基础运行时）
#   system/packages/drivers.toml   驱动/固件/硬件支持
#   system/packages/others.toml    其余软件（pacman + cargo + uv + bun + rustup）
#
# 管理器优先级：pacman（官方/archlinuxcn/AUR）> 其他。非 pacman 声明若在
# pacman 侧存在会被 audit/sync 直接报错。
#
# 用法：
#   ./pacman.nu                 默认 sync：装缺失，逐项询问卸载未声明
#   ./pacman.nu sync [flags]    同上
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
    let dir = ((base-dir) | path join 'system' 'packages')
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

def fail-msg [name, r] {
    let why = (($r.stderr | str trim) | str substring 0..300)
    print $"(ansi red)安装失败 ($name): ($why)(ansi reset)"
}

def install-pacman [names] {
    if ($names | is-empty) { return [] }
    print $"(ansi green)安装 pacman: ($names | str join ' ')(ansi reset)"
    let r = (^paru -S --needed --noconfirm ...$names | complete)
    if $r.exit_code == 0 {
        []
    } else {
        fail-msg 'pacman' $r
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
        let r = if not ($git | is-empty) {
            print $"(ansi green)安装 cargo-git: ($name)(ansi reset)"
            let extra = (if ($pkg | is-empty) { [] } else { [$pkg] })
            (^cargo install --git $git --force ...$extra | complete)
        } else {
            print $"(ansi green)安装 cargo: ($name)(ansi reset)"
            let extra = (if $locked { ['--locked'] } else { [] })
            (^cargo install --force $name ...$extra | complete)
        }
        if $r.exit_code != 0 { fail-msg $"cargo:($name)" $r; $failed = ($failed | append $"cargo:($name)") }
    }
    $failed
}

def install-uv [names] {
    mut failed = []
    for name in $names {
        print $"(ansi green)安装 uv: ($name)(ansi reset)"
        let r = (^uv tool install $name | complete)
        if $r.exit_code != 0 { fail-msg $"uv:($name)" $r; $failed = ($failed | append $"uv:($name)") }
    }
    $failed
}

def install-bun [names] {
    mut failed = []
    for name in $names {
        print $"(ansi green)安装 bun: ($name)(ansi reset)"
        let r = (^bun add -g $name | complete)
        if $r.exit_code != 0 { fail-msg $"bun:($name)" $r; $failed = ($failed | append $"bun:($name)") }
    }
    $failed
}

def install-rustup [names] {
    mut failed = []
    for ch in $names {
        print $"(ansi green)安装 rustup: ($ch)(ansi reset)"
        let r = (^rustup toolchain install $ch | complete)
        if $r.exit_code != 0 { fail-msg $"rustup:($ch)" $r; $failed = ($failed | append $"rustup:($ch)") }
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
        'export' => { export-manifest },
        'list' => { list-manifest },
        _ => { error make {msg: $"未知命令: ($action)（可用: sync / audit / export / list）"} },
    }
}
