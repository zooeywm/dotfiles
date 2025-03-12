-- local utils = require("utils")

return {
    {
        "nvimdev/guard.nvim",
        dependencies = {
            "nvimdev/guard-collection",
        },
        keys = {
            { "<leader>lf", "<cmd>Guard fmt<cr>", desc = "异步格式化" },
        },
        opts = {
            lua = {
                cmd = "stylua",
                args = { "--column-width", "200", "--indent-type", "Spaces", "--collapse-simple-statement", "Always", "--sort-requires", "-" },
                stdin = true,
            },
            python = "ruff",
            toml = "taplo",
            sh = {
                cmd = "shfmt",
                args = { "-i", "4" },
                stdin = true,
            },
            ["c,cpp"] = "clang-format",
            go = "gofmt",
            ["vue,json,javascript,typescript,xml,yaml,html,css,scss,less,astro,graphql,markdown"] = "prettier",
            cs = {
                cmd = "dotnet-csharpier",
                args = { "--write-stdout" },
            },
            ["jsonc,json5"] = {
                cmd = "prettier",
                args = { "--trailing-comma", "none", "--stdin-filepath" },
                fname = true,
                stdin = true,
            },
            typst = {
                cmd = "typstyle",
                stdin = true,
            },
            slint = {
                cmd = "slint-lsp",
                args = { "format" },
                stdin = true,
                fname = true,
            },
            rust = {
                cmd = "rustfmt",
                args = { "+nightly", "--edition", "2024", "--emit", "stdout" },
                stdin = true,
            },
            qml = {
                cmd = "qmlformat",
                fname = true,
                stdin = true,
            },
        },
        config = function(_, opts)
            local ft = require("guard.filetype")
            for lang, opt in pairs(opts) do
                ft(lang):fmt(opt)
            end
            vim.g.guard_config = {
                fmt_on_save = false,
            }
        end,
    },
    {
        "numToStr/Comment.nvim",
        -- NOTE: For block comment
        opts = {
            pre_hook = function(ctx)
                local U = require("Comment.utils")
                local filetype = vim.bo.filetype

                if filetype == "slint" then
                    local commentstring = "// %s"
                    if ctx.ctype == U.ctype.linewise then
                        return commentstring
                    elseif ctx.ctype == U.ctype.blockwise then
                        return "/* %s */"
                    end
                end
            end,
        },
    },
    {
        "saghen/blink.cmp",
        dependencies = { "xzbdmw/colorful-menu.nvim", "giuxtaposition/blink-cmp-copilot" },
        opts = {
            -- sources = {
            --     default = { "copilot" },
            --     providers = {
            --         copilot = {
            --             name = "copilot",
            --             module = "blink-cmp-copilot",
            --             kind = "Copilot",
            --             score_offset = 100,
            --             async = true,
            --         },
            --     },
            -- },
            completion = {
                trigger = {
                    show_on_x_blocked_trigger_characters = { "'", '"', "(", "{", "=" },
                },
                menu = {
                    draw = {
                        columns = {
                            { "kind_icon" },
                            {
                                "label",
                                gap = 0,
                            },
                        },
                        components = {
                            label = {
                                text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
                                highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
                            },
                        },
                    },
                    min_width = 30,
                    max_height = 15,
                },
                documentation = {
                    auto_show = true,
                    update_delay_ms = 0,
                    auto_show_delay_ms = 0,
                    window = {
                        border = "rounded",
                    },
                },
                list = {
                    selection = { preselect = true, auto_insert = true },
                    -- 'preselect' will automatically select the first item in the completion list
                    -- 'manual' will not select any item by default
                    -- 'auto_insert' will not select any item by default, and insert the completion items automatically
                    -- when selecting them
                },
            },
            signature = {
                enabled = true,
                window = {
                    border = "rounded",
                },
            },
            keymap = {
                ["<C-k>"] = { "show", "show_documentation", "hide_documentation" },
            },
        },
    },
}
