local wezterm = require("wezterm")
local act = wezterm.action

return {
    enable_wayland = true,
    enable_scroll_bar = false,
    font = wezterm.font_with_fallback({
        -- 1 l I
        --     - ~
        --     0 o
        "JetBrainsMono NF SemiBold",
        "Noto Sans CJK SC",
        "DejaVu Sans Mono",
        "Noto Sans Symbols2",
        "Noto Serif Grantha", -- 古印度文
        "Noto Sans Gujarati UI", -- 古吉拉特文
    }),

    -- -> <- <<- ->> <<= =>> => <=> __ <= >= ___ ____ ==
    -- === *** || ## ### #### #### !! ?? ... <> >>> >> << <<<
    -- :: ::: ;; ;;; {} [] ++ +++ -- ---

    -- harfbuzz_features = { "calt", "liga", "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" },
    font_size = 12,
    -- color_scheme = "Everforest Light (Gogh)",
    -- color_scheme = "Gruvbox light, medium (base16)",
    color_scheme = "Ayu Dark (Gogh)",
    force_reverse_video_cursor = true,
    colors = {
        cursor_bg = "#8ec07c",
        cursor_fg = "#282828",
        cursor_border = "#282828",
    },
    max_fps = 120,
    line_height = 1.05,
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
    exit_behavior = "Close",
    hide_tab_bar_if_only_one_tab = true,
    scrollback_lines = 10000,
    keys = {
        { key = "t", mods = "CTRL", action = wezterm.action.SpawnWindow },
        -- { key = "u", mods = "ALT", action = wezterm.action.QuickSelectArgs({ patterns = { ".*" } }) },
        { key = "y", mods = "ALT", action = act.ScrollByLine(-1) },
        { key = "e", mods = "ALT", action = act.ScrollByLine(1) },
        { key = "k", mods = "ALT|SHIFT", action = act.ScrollByLine(-1) },
        { key = "j", mods = "ALT|SHIFT", action = act.ScrollByLine(1) },
        { key = "u", mods = "ALT", action = act.ScrollByLine(-10) },
        { key = "d", mods = "ALT", action = act.ScrollByLine(10) },
        { key = "g", mods = "ALT", action = act.ScrollToTop },
        { key = "g", mods = "ALT|SHIFT", action = act.ScrollToBottom },
        { key = "u", mods = "ALT|SHIFT", action = wezterm.action.ActivateCopyMode },
        {
            key = "P",
            mods = "ALT|SHIFT",
            action = wezterm.action.QuickSelectArgs({
                label = "open url",
                patterns = {
                    "https?://\\S+",
                },
                skip_action_on_paste = true,
                action = wezterm.action_callback(function(window, pane)
                    local url = window:get_selection_text_for_pane(pane)
                    wezterm.log_info("opening: " .. url)
                    wezterm.open_with(url)
                end),
            }),
        },
        {
            key = "K",
            mods = "CTRL|SHIFT",
            action = act.ClearScrollback("ScrollbackAndViewport"),
        },
        { key = "{", mods = "SHIFT|ALT", action = act.MoveTabRelative(-1) },
        { key = "}", mods = "SHIFT|ALT", action = act.MoveTabRelative(1) },
        { key = "-", mods = "ALT", action = act.ActivateTabRelative(-1) },
        { key = "=", mods = "ALT", action = act.ActivateTabRelative(1) },
        { key = "V", mods = "SHIFT|ALT", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
        { key = "B", mods = "SHIFT|ALT", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }) },
        { key = "H", mods = "SHIFT|ALT", action = wezterm.action.ActivatePaneDirection("Left") },
        { key = "L", mods = "SHIFT|ALT", action = wezterm.action.ActivatePaneDirection("Right") },
        { key = "J", mods = "SHIFT|ALT", action = wezterm.action.ActivatePaneDirection("Down") },
        { key = "K", mods = "SHIFT|ALT", action = wezterm.action.ActivatePaneDirection("Up") },
        { key = "W", mods = "SHIFT|ALT", action = wezterm.action.CloseCurrentPane({ confirm = true }) },
        { key = "S", mods = "SHIFT|ALT", action = act.PaneSelect({ alphabet = "1234567890abcdefghijklmnopqrstuvwxyz" }) },
        { key = "F", mods = "SHIFT|ALT", action = wezterm.action.TogglePaneZoomState },
        -- { key = "UpArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
        -- { key = "DownArrow", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },
    },
    mouse_bindings = {
        -- 鼠标滚轮每次上滚一行
        {
            event = { Down = { streak = 1, button = { WheelUp = 1 } } },
            mods = "NONE",
            action = wezterm.action.ScrollByLine(-1),
        },
        -- 鼠标滚轮每次下滚一行
        {
            event = { Down = { streak = 1, button = { WheelDown = 1 } } },
            mods = "NONE",
            action = wezterm.action.ScrollByLine(1),
        },
    },
}
