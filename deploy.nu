#!/usr/bin/env -S nu --stdin

use std/log
use std/iter

def main [] {
    []
    | pf shell ~/.config/shell
    | pf clangd ~/.config/clangd
    | pf navi ~/.local/share/navi/cheats
    | pf memo ~/.local/share/memo
    | pf zsh/zshenv ~/.zshenv
    | pf zsh/zshrc ~/.config/zsh/.zshrc
    | pf zsh/p10k.zsh -t ~/.config/zsh
    | pf bashrc ~/.bashrc
    | pf rofi/config ~/.config/rofi
    | pf rofi/themes ~/.local/share/rofi/themes
    # hard-link on
    | pf gtk/gtk-3.0 ~/.config/gtk-3.0 -h
    | pf gtk/gtk-4.0 ~/.config/gtk-4.0 -h
    | pf Xresources ~/.Xresources -h
    # hard-link off
    | pf bin -t ~/.local
    | pf cargo ~/.cargo
    | pf fcitx5/config ~/.config/fcitx5
    | pf fcitx5/share ~/.local/share/fcitx5
    | pf waybar/style.less ~/.config/waybar/style.css
    | pf waybar/latte.css ~/.config/waybar/latte.css
    | pf waybar/config.jsonc ~/.config/waybar/config.jsonc
    | pf kde ~/.config
    # | pf Templates -t ~
    | pfs [
        starship.toml fish nushell dunst presenterm
        LazyVim neovide wezterm kitty alacritty zellij yazi git git-cliff
        gitui lazygit zathura mpv gdb pip.conf macchina paru
        mise atuin uv jj
    ] ~/.config
    | pfs [
        hypr fontconfig mimeapps.list
    ] ~/.config -h
    | pfs [memo applications] ~/.local/share
    | each {|it| deploy-item $it }

    return
}

def 'main root' [] {
    for src in (ls root | get name) {
        cp -r $src  /
    }
}

# prepare
def pf [
    src: string,
    --target (-t),
    dest: string,
    --hard (-h),
] {
    let self = $in

    $self
    | append {
        src: $src,
        dest: $dest,
        place: $target,
        hard: $hard,
    }
}

def pfs [
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

def deploy-item [it: record] {
    let dest = $it.dest | path expand

    match ($it.src | path type) {
        file => {
            deploy-file $it.src $dest --place=$it.place --hard=$it.hard
        },
        dir if $it.place => {
            place-dir $it.src $dest --hard=$it.hard
        },
        dir => {
            deploy-dir $it.src $dest --hard=$it.hard
        },
    }
}

def deploy-file [
    src: string,
    dest: path,
    --place,
    --hard,
] {
    let dest = if $place {
        mkdir -v $dest
        $dest | path join ($src | path basename)
    } else {
        mkdir -v ($dest | path dirname)
        $dest
    }

    link $src $dest --hard=$hard
}

def deploy-dir [
    src: string,
    dest: path,
    --hard,
] {
    let dest_path = {|p|
        $dest
        | path join (
            $p
            | path strip (pwd) $src
        )
    }

    let dirs = glob $"($src)/**/*" --no-file
        | skip 1
        | each $dest_path

    # 确保dirs为空时也创建dest
    mkdir -v $dest ...$dirs

    glob $"($src)/**/*" --no-dir
    | each {|file|
        let dest = (do $dest_path $file)
        let file = $file | path strip (pwd)
        link $file $dest --hard=$hard
    }
}

def place-dir [
    src: string,
    dest: path,
    --hard,
] {
    let dest_path = {|p|
        $dest
        | path join (
            $p
            | path strip (pwd) ($src | path dirname)
        )
    }

    let dirs = glob $"($src)/**/*" --no-file
        | each $dest_path

    mkdir -v ...$dirs

    glob $"($src)/**/*" --no-dir
    | each {|file|
        let dest = (do $dest_path $file)
        let file = $file | path strip (pwd)
        link $file $dest --hard=$hard
    }
}

def link [
    src: string,
    dest: path,
    --hard,
] {
    let srcp = pwd | path join $src

    if $hard {
        if not (is-hard-linked $srcp $dest) {
            log info $"($src) => ($dest)"
            ln --force $srcp $dest
        }
    } else if not (is-linked $srcp $dest) {
        log info $"($src) => ($dest)"
        ln -s $srcp $dest
    }
}

def is-linked [src: path, dest: path]: nothing -> bool {
    try {
        $src == (realpath $dest)
    } catch {
        false
    }
}

def is-hard-linked [src: path, dest: path]: nothing -> bool {
    let f = {|p| stat --printf %i $p err> /dev/null }
    try {Add commentMore actions
        (do $f $src) == (do $f $dest)
    } catch {
        false
    }
}

def 'path strip' [...prefix: string]: nothing -> path {
    $in | path relative-to ($prefix | path join)
}
