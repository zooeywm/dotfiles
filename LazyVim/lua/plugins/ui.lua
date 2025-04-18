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
                theme = "auto", -- 主题（如 "tokyonight"、"catppuccin"）
                component_separators = { left = "|", right = "|" }, -- 分隔符
                section_separators = { left = " ", right = "" }, -- 区块分隔符（可选）
            },
            sections = {
                lualine_b = { "branch", "diff", "diagnostics" },
                lualine_c = { "searchcount", "selectioncount" },
                lualine_x = { "lsp_status", --[[ { "filename", path = 1, shorting_target = 20 }, ]] "encoding", "fileformat", "filetype" },
            },
        },
    },
    -- {
    --     "nvim-focus/focus.nvim",
    --     config = true,
    -- },
}
