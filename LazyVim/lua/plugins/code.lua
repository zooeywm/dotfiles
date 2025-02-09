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
                args = { "--indent-type", "Spaces", "-" },
                stdin = true,
            },
            python = "ruff",
            toml = "taplo",
            -- ocaml = {
            --     cmd = "ocamlformat",
            --     args = {
            --         "--enable-outside-detected-project",
            --         "--name",
            --         utils.vim.current_buffer_name(),
            --         "-",
            --     },
            --     stdin = true,
            -- },
            sh = "shfmt",
            ["c,cpp"] = {
                cmd = "clang-format",
                args = {
                    -- "--style",
                    -- "{IndentWidth: 4}",
                },
                stdin = true,
            },
            go = "gofmt",
            cs = {
                cmd = "dotnet-csharpier",
                args = { "--write-stdout" },
            },
            ["vue,json,javascript,typescript,xml,yaml,html,css,astro"] = "prettier",
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
        },
        config = function(_, opts)
            local ft = require("guard.filetype")
            ft("rust"):fmt("rustfmt"):extra("+nightly")

            for lang, opt in pairs(opts) do
                ft(lang):fmt(opt)
            end

            vim.g.guard_config = {
                fmt_on_save = false,
            }
        end,
    },
    -- {
    --     "folke/todo-comments.nvim",
    --     keys = {
    --         { "[t", false },
    --         { "]t", false },
    --     },
    -- },
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
        dependencies = { "xzbdmw/colorful-menu.nvim" },
        -- event = "InsertEnter",
        opts = {
            completion = {
                trigger = {
                    show_on_x_blocked_trigger_characters = { "'", '"', "(", "{", "=" },
                },
                menu = {
                    -- border = "rounded",
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
                                text = function(ctx)
                                    return require("colorful-menu").blink_components_text(ctx)
                                end,
                                highlight = function(ctx)
                                    return require("colorful-menu").blink_components_highlight(ctx)
                                end,
                            },
                        },
                    },
                    min_width = 30,
                    max_height = 10,
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
        },
    },
}
