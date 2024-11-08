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
        "akinsho/toggleterm.nvim",
        enabled = false,
        keys = {
            { "<M-1>", "<cmd>ToggleTerm size=11 direction=horizontal<cr>", desc = "水平终端" },
            { "<M-2>", "<cmd>ToggleTerm size=50 direction=vertical<cr>", desc = "垂直终端" },
            { "<M-3>", "<cmd>ToggleTerm direction=float<cr>", desc = "浮动终端" },
        },
        config = true,
    },
    {
        "nvimdev/dashboard-nvim",
        optional = true,
        opts = function(_, opts)
            local projects = {
                action = "Telescope neovim-project history",
                desc = " Projects",
                icon = " ",
                key = "p",
            }

            projects.desc = projects.desc .. string.rep(" ", 43 - #projects.desc)
            projects.key_format = "  %s"

            table.insert(opts.config.center, 3, projects)
        end,
    },
    {
        "sindrets/diffview.nvim",
        config = true,
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "diff" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "文件历史" },
            { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "当前文件历史" },
        },
    },
    -- {
    --     "NeogitOrg/neogit",
    --     cmd = "Neogit",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-telescope/telescope.nvim",
    --         "sindrets/diffview.nvim",
    --     },
    --     keys = {
    --         { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
    --     },
    --     config = true,
    -- },
}
