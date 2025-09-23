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
            ["json,jsonc,json5,javascript,typescript,javascriptreact,typescriptreact,css,graphql"] = {
                cmd = "biome",
                args = { "format", "--indent-style=space", "--stdin-file-path" },
                fname = true,
                stdin = true,
            },
            -- kotlin = {
            --     cmd = "ktfmt",
            --     args = { "--kotlinlang-style", "-" },
            --     stdin = true,
            -- },
            ["vue,xml,yaml,html,astro,markdown,scss,less"] = "prettier",
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
            typst = "typstyle",
            slint = {
                cmd = "slint-lsp",
                args = { "format" },
                stdin = true,
                fname = true,
            },
            rust = {
                cmd = "rustfmt",
                -- args = { "+nightly", "--edition", "2024", "--emit", "stdout" },
                args = { "--edition", "2024", "--emit", "stdout" },
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

            -- local lint = require("guard.lint")
            -- -- ft("cpp"):lint("clang-tidy")
            -- ft("cpp"):lint({
            --     -- cmd = "clazy-standalone",
            --     cmd = "clang-tidy",
            --     fname = true,
            --     stdin = false,
            --     parse = lint.from_regex({
            --         -- source = "clazy-standalone",
            --         source = "clang-tidy",
            --         -- regex = ':(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]',
            --         -- regex = ":(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]",
            --         regex = ":(%d+):(%d+):%s+(%w+):%s+(.-)%s+%[(.-)%]",
            --         groups = { "lnum", "col", "severity", "message", "code" },
            --     }),
            --     severities = {
            --         information = lint.severities.info,
            --         hint = lint.severities.info,
            --         note = lint.severities.style,
            --     },
            -- })
            -- :lint("codespell")
        end,
    },
    {
        "nvim-neotest/neotest",
        opts = function()
            return {
                adapters = {
                    require("rustaceanvim.neotest"),
                },
            }
        end,
        keys = {
            { "<leader>tr", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File (Neotest)" },
        },
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
            snippets = {
                preset = "luasnip",
            },
            sources = {
                default = { "copilot" },
                providers = {
                    lsp = {
                        fallbacks = {},
                    },
                    copilot = {
                        name = "copilot",
                        module = "blink-cmp-copilot",
                        kind = "Copilot",
                        score_offset = 100,
                        async = true,
                    },
                    buffer = {
                        opts = {
                            -- get all buffers, even ones like neo-tree
                            get_bufnrs = vim.api.nvim_list_bufs,
                        },
                    },
                },
            },
            fuzzy = { implementation = "prefer_rust_with_warning" },
            completion = {
                accept = {
                    auto_brackets = { enabled = true },
                },
                keyword = {
                    range = "full",
                },
                trigger = {
                    show_on_keyword = true,
                    show_on_x_blocked_trigger_characters = { "'", '"', "(", "{", "=" },
                },
                menu = {
                    border = "rounded",
                    winblend = 15,
                    draw = {
                        gap = 0,
                        columns = { { "kind_icon" }, { "label", gap = 0 } },
                        components = {
                            label = {
                                text = function(ctx) return require("colorful-menu").blink_components_text(ctx) end,
                                highlight = function(ctx) return require("colorful-menu").blink_components_highlight(ctx) end,
                            },
                        },
                    },
                    min_width = 30,
                    max_height = 20,
                },
                documentation = {
                    auto_show = true,
                    update_delay_ms = 50,
                    auto_show_delay_ms = 0,
                    window = {
                        border = "rounded",
                        winblend = 15,
                    },
                },
                ghost_text = {
                    enabled = true,
                    show_without_selection = true,
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
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        keys = {
            { "<C-l>", "<Plug>luasnip-next-choice", mode = { "i", "s" } },
            { "<C-h>", "<Plug>luasnip-prev-choice", mode = { "i", "s" } },
        },
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = { vim.fn.stdpath("config") .. "/snippets" },
            })

            local luasnip = require("luasnip")
            luasnip.add_snippets("rust", require("plugins.snippets.rust"))
        end,
    },
}
