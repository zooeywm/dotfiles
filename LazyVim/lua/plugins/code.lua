local utils = require("utils")

return {
    {
        "garymjr/nvim-snippets",
        opts = {
            search_paths = { vim.fn.stdpath("config") .. "/snippets" },
        },
    },
    {
        "nvimdev/guard.nvim",
        dependencies = {
            "nvimdev/guard-collection",
        },
        keys = {
            { "<leader>lf", "<cmd>GuardFmt<cr>", desc = "异步格式化" },
        },
        opts = {
            lua = {
                cmd = "stylua",
                args = { "--indent-type", "Spaces", "-" },
                stdin = true,
            },
            python = {
                cmd = "black",
                args = { "--quiet", "-" },
                stdin = true,
            },
            toml = "taplo",
            ocaml = {
                cmd = "ocamlformat",
                args = {
                    "--enable-outside-detected-project",
                    "--name",
                    utils.vim.current_buffer_name(),
                    "-",
                },
                stdin = true,
            },
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
            ["vue,json,jsonc,javascript,typescript,xml,yaml,html,css"] = "prettier",
            typst = {
                cmd = "typstyle",
                stdin = true,
            },
            slint = {
                cmd = "slint-lsp",
                args = { "format", "-i" },
                fname = true,
            },
        },
        config = function(_, opts)
            local ft = require("guard.filetype")
            ft("rust"):fmt("rustfmt"):extra("+nightly")

            for lang, opt in pairs(opts) do
                ft(lang):fmt(opt)
            end

            require("guard").setup({ fmt_on_save = false })
        end,
    },
    {
        "folke/todo-comments.nvim",
        keys = {
            { "[t", false },
            { "]t", false },
        },
    },
    {
        "numToStr/Comment.nvim",
        -- FIXME: interim
        config = function()
            require("Comment").setup({
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
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, tbl)
            local cmp = require("cmp")
            local override = {
                matching = {
                    disallow_fuzzy_matching = false,
                    disallow_fullfuzzy_matching = false,
                    disallow_partial_fuzzy_matching = false,
                    disallow_partial_matching = false,
                    disallow_prefix_unmatching = false,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<M-Space>"] = cmp.mapping.complete(),
                    ["<TAB>"] = LazyVim.cmp.confirm({ select = auto_select }),
                }),
                -- window = {
                --     completion = cmp.config.window.bordered(),
                --     documentation = cmp.config.window.bordered(),
                -- },
            }
            return vim.tbl_deep_extend("force", tbl, override)
        end,
    },
}
