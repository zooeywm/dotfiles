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
            { "<leader>T", "<cmd>Translate<cr>", mode = { "n", "x" }, desc = "󰊿 Translate" },
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
                "<leader>cs",
                "<cmd>CodeSnap<cr>",
                mode = { "x" },
                desc = "Save selected code snapshot into clipboard",
            },
            {
                "<leader>ca",
                "<cmd>CodeSnapASCII<cr>",
                mode = { "x" },
                desc = "Save selected code ASCII snapshot into clipboard",
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
            -- git
            { "<leader>gb", false },
            { "<leader>gl", false },
            { "<leader>gL", false },
            { "<leader>gs", false },
            { "<leader>gS", false },
            { "<leader>gd", false },
            -- { "<leader>gf", false },
        },
        opts = function(_, opts)
            opts.scroll = { enabled = false }
            opts.styles = {
                input = {
                    relative = "cursor",
                    row = 1,
                    col = 0,
                    keys = {
                        i_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "1", expr = true },
                    },
                },
            }
            opts.image = { enabled = true }
            table.insert(opts.dashboard.preset.keys, 2, {
                icon = "",
                key = "F",
                desc = "Find Files (cwd)",
                action = "<leader>fF",
            })
            opts.indent.animate = { duration = { step = 20, total = 300 } }
            opts.words.enabled = false
        end,
    },
    {
        "2kabhishek/nerdy.nvim",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-telescope/telescope.nvim",
        },
        cmd = "Nerdy",
    },
    {
        "nvim-telescope/telescope.nvim",
        opts = {
            pickers = {
                find_files = {
                    previewer = false,
                },
                git_files = {
                    previewer = false,
                },
                live_grep = {
                    layout_config = {
                        preview_width = 0.5,
                    },
                },
            },
        },
    },
}
