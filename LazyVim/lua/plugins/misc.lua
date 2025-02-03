return {
    {
        "TD-Sky/fcitx.nvim",
        ft = { "markdown", "typst" },
        keys = {
            {
                "<leader>ux",
                "<cmd>FcitxEnableSwitch<CR>",
                desc = "开启输入法自动切换",
            },
            {
                "<leader>uX",
                "<cmd>FcitxDisableSwitch<CR>",
                desc = "关闭输入法自动切换",
            },
        },
    },
    {
        "JuanZoran/Trans.nvim",
        dependencies = { "kkharji/sqlite.lua" },
        build = function()
            require("Trans").install()
        end,
        keys = {
            { "gl", "<cmd>Translate<cr>", mode = { "n", "x" }, desc = " Translate" },
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
}
