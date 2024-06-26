local wezterm = require("wezterm")

return {
    enable_wayland = false,
    enable_scroll_bar = true,
    font = wezterm.font_with_fallback({
        "JetBrains Mono", -- 代码 <内置>
        "FiraCode Nerd Font", -- 炫酷图标
        "Noto Sans CJK SC", -- 汉字
        "DejaVu Sans Mono",
        "Noto Sans Symbols2",
        "Noto Serif Grantha", -- 古印度文
        "Noto Sans Gujarati UI", -- 古吉拉特文
    }),
    font_size = 20,
    color_scheme = "Abernathy",
    force_reverse_video_cursor = true, -- 光标反色
    -- window_background_opacity = 0.90,
    line_height = 1.1,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    default_prog = { "/bin/zsh", "-l" },
    exit_behavior = "Close",
    hide_tab_bar_if_only_one_tab = true,
    keys = {
        { key = "t", mods = "CTRL", action = wezterm.action.SpawnWindow },
        {
            key = "w",
            mods = "CTRL|SHIFT",
            action = wezterm.action.QuickSelectArgs({
                patterns = {
                    "[0-9a-f]{7,40}",
                    "[^\\s]+",
                },
            }),
        },
        { key = "l", mods = "CTRL|SHIFT", action = wezterm.action.QuickSelectArgs({ patterns = { ".*" } }) },
    },
}
