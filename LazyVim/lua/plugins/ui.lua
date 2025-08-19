return {
    {
        "folke/noice.nvim",
        opts = {
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                            { find = "%d lines? yanked" },
                            { find = "%d lines? changed" },
                            { find = "1 line less" },
                            { find = "%d fewer lines" },
                            { find = "%d more lines?" },
                            { find = "1 buffer wiped out" },
                            { find = "1 buffer deleted" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                theme = "catppuccin", -- 主题（如 "tokyonight"、"catppuccin"）
                component_separators = { left = "", right = "" }, -- 细圆润分隔符（组件间）
                section_separators = { left = "", right = "" }, -- 粗圆润分隔符（区块间）
                -- component_separators = { left = "", right = "" },
                -- section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { { "searchcount", maxcount = 999999, timeout = 1000 }, "selectioncount" },
                lualine_x = {
                    "lsp_status",
                    -- { "filename", path = 1, shorting_target = 20 },
                    -- "encoding",
                    -- "fileformat",
                    "filetype",
                },
                lualine_y = {},
                lualine_z = { "progress" },
            },
        },
    },
    -- {
    --     "nvim-focus/focus.nvim",
    --     config = true,
    -- },
}
