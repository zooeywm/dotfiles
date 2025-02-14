return {
    {
        "TD-Sky/fcitx.nvim",
        ft = { "markdown", "typst", "lua" },
        keys = {
            {
                "<leader>tf",
                "<cmd>FcitxToggleSwitch<CR>",
                desc = "开关输入法自动切换",
            },
        },
    },
    {
        "JuanZoran/Trans.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        build = function() require("Trans").install() end,
        keys = {
            { "t", "<cmd>Translate<cr>", mode = { "n", "x" }, desc = " Translate" },
        },
        opts = {
            frontend = {
                default = {
                    animation = {
                        open = "fold",
                        close = "fold",
                    },
                },
                hover = {
                    width = 80,
                },
            },
        },
    },
    { "lambdalisue/suda.vim" },
    {
        "mistricky/codesnap.nvim",
        build = "make build_generator",
        keys = {
            {
                "<leader>us",
                "<cmd>CodeSnap<cr>",
                mode = { "x" },
                desc = "Save selected code snapshot into clipboard",
            },
        },
        opts = {
            mac_window_bar = false,
            bg_x_padding = 10,
            bg_y_padding = 10,
            has_line_number = true,
        },
    },
    { "norcalli/nvim-colorizer.lua" },
    {
        "folke/snacks.nvim",
        keys = {
            {
                "<leader>gb",
                function() Snacks.gitbrowse() end,
                desc = "跳转到远程仓库相应位置",
            },
        },
        opts = {
            scroll = { enabled = false },
            bigfile = {},
            styles = {
                input = {
                    relative = "cursor",
                    row = 1,
                    col = 0,
                    keys = {
                        i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "1", expr = true },
                    },
                },
            },
        },
    },
    {
        "2kabhishek/nerdy.nvim",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-telescope/telescope.nvim",
        },
        cmd = "Nerdy",
    },
}
