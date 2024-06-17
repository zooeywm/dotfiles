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
                    "--style",
                    "{IndentWidth: 4}",
                },
                stdin = true,
            },
            rust = "rustfmt",
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
        },
        config = function(_, opts)
            local ft = require("guard.filetype")

            local function pango()
                -- `[[ ... ]]` is Lua's way to denote a multi-line string, which makes it easier to include complex patterns without needing to escape characters.
                vim.cmd([[ silent! %s/[^\x00-\xff]\zs\ze\w\|\w\zs\ze[^\x00-\xff]/ /g ]])
            end
            for lang, opt in pairs(opts) do
                ft(lang):fmt(opt)
            end
            ft("markdown"):fmt({
                fn = pango,
            })

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
        config = true,
    },
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, tbl)
            local override = {
                matching = {
                    disallow_fuzzy_matching = false,
                    disallow_fullfuzzy_matching = false,
                    disallow_partial_fuzzy_matching = false,
                    disallow_partial_matching = false,
                    disallow_prefix_unmatching = false,
                },
            }
            return vim.tbl_extend("force", tbl, override)
        end,
    },
}
