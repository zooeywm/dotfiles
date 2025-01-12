return {
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 500,
            stages = "fade",
        },
    },
    {
        "TD-Sky/neo-rhythm",
        opts = {
            range = {
                start = { 7, 0 },
                ending = { 18, 30 },
            },
            day = function()
                vim.o.background = "dark"
            end,
            night = function()
                vim.o.background = "dark"
            end,
        },
    },
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
        "lewis6991/gitsigns.nvim",
        keys = {
            { "gb", "<cmd>Gitsigns blame_line<cr>", desc = "git blame" },
        },
    },
    {
        "nvim-focus/focus.nvim",
        config = true,
    },
    -- {
    --     "nvimdev/dashboard-nvim",
    --     optional = true,
    --     opts = function(_, opts)
    --         local projects = {
    --             action = "Telescope neovim-project history",
    --             desc = " Projects",
    --             icon = " ",
    --             key = "p",
    --         }
    --
    --         projects.desc = projects.desc .. string.rep(" ", 43 - #projects.desc)
    --         projects.key_format = "  %s"
    --
    --         table.insert(opts.config.center, 3, projects)
    --     end,
    -- },
}
