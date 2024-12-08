#!/usr/bin/env nu

use std/log
use std/iter

def main [] {
    []
    | pf shell ~/.config/shell
    | pf navi ~/.local/share/navi/cheats
    | pf memo ~/.local/share/memo
    | pf zsh/zshenv ~/.zshenv
    | pf zsh/zshrc ~/.config/zsh/.zshrc
    | pf zsh/p10k.zsh -t ~/.config/zsh
    | pf bashrc ~/.bashrc
    | pf rofi/config ~/.config/rofi
    | pf rofi/themes ~/.local/share/rofi/themes
    | pf gtk/gtk-3.0 ~/.config/gtk-3.0
    | pf gtk/gtk-4.0 ~/.config/gtk-4.0
    | pf gtk/gtkrc-2.0 ~/.gtkrc-2.0
    | pf bin -t ~/.local
    | pf cargo ~/.cargo
    | pf fcitx5/config ~/.config/fcitx5
    | pf fcitx5/share ~/.local/share/fcitx5
    | pf Templates -t ~
    | pfs [
        starship.toml fish nushell dunst dconf hypr waybar
        LazyVim neovide wezterm kitty zellij yazi git git-cliff
        gitui zathura mpv gdb pip.conf macchina paru mimeapps.list
    ] ~/.config
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
] {
    let self = $in

    $self
    | append {
        src: $src,
        dest: $dest,
        place: $target,
    }
}

def pfs [srcs: list<string>, dest: string] {
    let self = $in

    $srcs
    | reduce --fold $self {|src, self|
        $self
        | append {
            src: $src,
            dest: $dest,
            place: true,
        }
    }
}

def deploy-item [it: record] {
    let dest = $it.dest | path expand

    match ($it.src | path type) {
        file => { deploy-file $it.src $dest $it.place },
        dir if $it.place => { place-dir $it.src $dest },
        dir => { deploy-dir $it.src $dest },
    }
}

def deploy-file [
    src: string,
    dest: path,
    place: bool,
] {
    let dest = if $place {
        mkdir -v $dest
        $dest | path join ($src | path basename)
    } else {
        mkdir -v ($dest | path dirname)
        $dest
    }

    link $src $dest
}

def deploy-dir [
    src: string,
    dest: path,
] {
    let join_suffix = {|p|
        $dest
        | path join ($p | str split-once).1
    }

    let dirs = glob $"($src)/**/*" --no-file
        | skip 1
        | each { path strip-cwd }

    try {
        mkdir -v $dest ...($dirs | each $join_suffix)
    }

    let files = glob $"($src)/**/*" --no-dir
        | each { path strip-cwd }

    $files
    | each {|file|
        let dest = do $join_suffix $file
        link $file $dest
    }
}

def place-dir [src: string, dest: path] {
    let join_suffix = {|p| $dest | path join $p }

    let dirs = glob $"($src)/**/*" --no-file
        | each { path strip-cwd }

    try {
        mkdir -v ...($dirs | each $join_suffix)
    }

    let files = glob $"($src)/**/*" --no-dir
        | each { path strip-cwd }

    $files
    | each {|file|
        let dest = do $join_suffix $file
        link $file $dest
    }
}

def link [src: string, dest: path] {
    let srcp = pwd | path join $src

    if not (is-linked $srcp $dest) {
        log info $"($src) => ($dest)"
        ln -s $srcp $dest
    }
}

def is-linked [src: path, dest: path] {
    try {
        $src == (realpath $dest)
    } catch {
        false
    }
}

def 'str split-once' [] -> list {
    let s = $in

    let i = $s
    | split chars
    | iter find-index {|c| $c == '/' }

    if $i >= 0 {
        [
            ($s | str substring ..<$i),
            ($s | str substring ($i + 1)..),
        ]
    } else {
        null
    }
}

def 'path strip-cwd' [] -> path {
    $in | path relative-to (pwd)
}
