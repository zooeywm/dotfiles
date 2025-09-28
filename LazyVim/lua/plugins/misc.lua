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
    { "mtdl9/vim-log-highlighting" },
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup({
                "css",
                "less",
                "javascript",
                "hyprlang",
            }, {
                RRGGBBAA = true, -- #RRGGBBAA hex codes
                rgb_fn = true, -- CSS rgb() and rgba() functions
                hsl_fn = true, -- CSS hsl() and hsla() functions
                css = true, -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
                css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
            })
        end,
    },
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

            -- LSP
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definitions" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declarations" },
            { "gT", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definitions" },
            { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementations" },
        },
        opts = function(_, opts)
            opts.scroll = { enabled = false }
            opts.image = { enabled = true }
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
            table.insert(opts.dashboard.preset.keys, 2, {
                icon = "",
                key = "F",
                desc = "Find Files (cwd)",
                action = "<leader>fF",
            })
            opts.indent.animate = { duration = { step = 20, total = 300 } }
            opts.words.enabled = false
            -- zen
            opts.zen = {
                toggles = {
                    dim = false,
                    git_signs = true,
                },
            }
            -- styles
            opts.styles = {
                zen = {
                    backdrop = {
                        transparent = false,
                        blend = 99,
                    },
                },
            }
        end,
    },
}
