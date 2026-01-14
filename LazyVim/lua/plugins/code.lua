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
            ["javascript,typescript,javascriptreact,typescriptreact,css,json,jsonc,json5,markdown,vue,html,yaml"] = {
                cmd = "oxfmt",
                fname = true,
                stdin = false,
            },
            -- kotlin = {
            --     cmd = "ktfmt",
            --     args = { "--kotlinlang-style", "-" },
            --     stdin = true,
            -- },
            ["xml,astro,scss,less"] = "prettier",
            cs = {
                cmd = "dotnet-csharpier",
                args = { "--write-stdout" },
            },
            -- ["jsonc,json5"] = {
            --     cmd = "prettier",
            --     args = { "--trailing-comma", "none", "--stdin-filepath" },
            --     fname = true,
            --     stdin = true,
            -- },
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
                local f = ft(lang):fmt(opt)

                if vim.g.project_config ~= nil and vim.g.project_config.guard_on_fmt ~= nil then vim.g.project_config.guard_on_fmt(lang, f) end
            end

            vim.g.guard_config = {
                fmt_on_save = false,
                always_on_save = true,
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

                if filetype == "slint" or filetype == "lox" then
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
    -- {
    --     "milanglacier/minuet-ai.nvim",
    --     config = function()
    --         require("minuet").setup({
    --             provider = "openai_fim_compatible",
    --             provider_options = {
    --                 openai_fim_compatible = {
    --                     api_key = "DEEPSEEK_API_KEY",
    --                     name = "deepseek",
    --                     optional = {
    --                         max_tokens = 256,
    --                         top_p = 0.9,
    --                     },
    --                 },
    --             },
    --         })
    --     end,
    -- },
    {
        "saghen/blink.cmp",
        dependencies = {
            "xzbdmw/colorful-menu.nvim",
            { "bydlw98/blink-cmp-env", lazy = true },
            { "mikavilpas/blink-ripgrep.nvim", lazy = true },
            { "Kaiser-Yang/blink-cmp-dictionary", dependencies = { "nvim-lua/plenary.nvim" }, lazy = true },
            -- "giuxtaposition/blink-cmp-copilot",
        },
        opts = {
            snippets = {
                preset = "luasnip",
            },
            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                    "ripgrep",
                    "dictionary",
                    "env",
                    "cmdline",
                    -- "minuet",
                    -- "copilot",
                },
                per_filetype = {
                    sql = { "dadbod" },
                    -- optionally inherit from the `default` sources
                    lua = { inherit_defaults = true, "lazydev" },
                    bash = { "env" },
                    sh = { "env" },
                    zsh = { "env" },
                    nu = { "env" },
                },
                providers = {
                    -- minuet = {
                    --     name = "minuet",
                    --     module = "minuet.blink",
                    --     async = true,
                    --     -- Should match minuet.config.request_timeout * 1000,
                    --     -- since minuet.config.request_timeout is in seconds
                    --     timeout_ms = 10000,
                    --     score_offset = 300, -- Gives minuet higher priority among suggestions
                    -- },
                    lsp = {
                        timeout_ms = 10000,
                        score_offset = 200,
                    },
                    snippets = {
                        score_offset = 90,
                    },
                    path = {
                        score_offset = 80,
                    },
                    env = {
                        name = "Env",
                        module = "blink-cmp-env",
                        opts = {},
                        score_offset = 90,
                    },
                    buffer = {
                        opts = {
                            -- get all buffers, even ones like neo-tree
                            get_bufnrs = vim.api.nvim_list_bufs,
                        },
                        score_offset = 0,
                    },
                    ripgrep = {
                        timeout_ms = 10000,
                        async = true,
                        module = "blink-ripgrep",
                        name = "Ripgrep",
                        min_keyword_length = 5,
                        ---@module "blink-ripgrep"
                        ---@type blink-ripgrep.Options
                        opts = {
                            prefix_min_len = 5,
                            backend = {
                                context_size = 5,
                                ripgrep = {
                                    max_filesize = "1M",
                                    search_casing = "--smart-case",
                                },
                            },
                        },
                        score_offset = -50,
                    },
                    dictionary = {
                        timeout_ms = 10000,
                        async = true,
                        min_keyword_length = 4,
                        name = "Dict",
                        module = "blink-cmp-dictionary",
                        ---@module "blink-cmp-dictionary"
                        ---@type blink-cmp-dictionary.Options
                        opts = {
                            dictionary_files = {
                                vim.fn.stdpath("data") .. "/lazy/Trans.nvim/neovim.dict",
                            },
                            get_documentation = function(item)
                                return {
                                    get_command = "sqlite3",
                                    get_command_args = {
                                        vim.fn.stdpath("data") .. "/lazy/Trans.nvim/ultimate.db",
                                        "select translation from stardict where word = '" .. item .. "';",
                                    },
                                    ---@diagnostic disable-next-line: redefined-local
                                    resolve_documentation = function(output) return output end,
                                }
                            end,
                        },
                        score_offset = -100,
                    },
                    -- copilot = {
                    --     timeout_ms = 10000,
                    --     name = "copilot",
                    --     module = "blink-cmp-copilot",
                    --     kind = "Copilot",
                    --     score_offset = 200,
                    --     async = true,
                    -- },
                },
            },
            fuzzy = {
                implementation = "prefer_rust_with_warning",
                sorts = {
                    "score", -- Primary sort: by fuzzy matching score
                    "sort_text", -- Secondary sort: by sortText field if scores are equal
                    "label", -- Tertiary sort: by label if still tied
                },
            },
            completion = {
                accept = {
                    auto_brackets = { enabled = false },
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
                        columns = { { "kind_icon" }, { "label", "label_description", "kind", "source_name", gap = 1 } },
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
                ["<C-k>"] = { "show" },
                ["<M-y>"] = { function(cmp) cmp.scroll_documentation_up(1) end },
                ["<M-e>"] = { function(cmp) cmp.scroll_documentation_down(1) end },
            },
        },
    },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        keys = function()
            local ls = require("luasnip")
            return {
                {
                    "<Tab>",
                    function()
                        if ls.expand_or_jumpable() then
                            ls.jump(1)
                        else
                            return "<Tab>"
                        end
                    end,
                    mode = { "i", "s" },
                    expr = true,
                },
                { "<S-Tab>", function() ls.jump(-1) end, mode = { "i", "s" } },
                {
                    "<C-l>",
                    function()
                        if ls.choice_active() then ls.change_choice(1) end
                    end,
                    mode = { "i", "s" },
                },
                {
                    "<C-h>",
                    function()
                        if ls.choice_active() then ls.change_choice(-1) end
                    end,
                    mode = { "i", "s" },
                },
            }
        end,
        config = function()
            require("luasnip.loaders.from_vscode").lazy_load({
                paths = { vim.fn.stdpath("config") .. "/snippets" },
            })

            local luasnip = require("luasnip")
            luasnip.add_snippets("rust", require("plugins.snippets.rust"))
            luasnip.add_snippets("cpp", require("plugins.snippets.qt"))
        end,
    },
    {
        "Mythos-404/xmake.nvim",
        version = "^3",
        lazy = true,
        event = "BufReadPost",
        opts = {
            on_save = {
                -- Reload project information
                reload_project_info = true,
                -- Configuration for generating `compile_commands.json`
                lsp_compile_commands = {
                    enable = false,
                    -- Directory name (relative path) for output file
                    output_dir = "build",
                },
            },
        },
    },
}
