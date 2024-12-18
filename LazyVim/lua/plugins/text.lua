local utils = require("utils")

return {
    {
        "johmsalas/text-case.nvim",
        config = function()
            local textcase = require("textcase")
            local wk = require("which-key")

            local function convert_case(dest_case)
                return function()
                    textcase.current_word(dest_case)
                end
            end

            wk.add({
                mode = { "n", "o", "x" },
                { "gt", group = "text-case" },
                { "gt-", convert_case("to_dash_case"), desc = "to-dash" },
                { "gt/", convert_case("to_path_case"), desc = "to/path" },
                { "gtC", convert_case("to_constant_case"), desc = "TO_CONSTANT" },
                { "gtP", convert_case("to_pascal_case"), desc = "ToPascal" },
                { "gtc", convert_case("to_camel_case"), desc = "toCamel" },
                { "gt.", convert_case("to_dot_case"), desc = "to.dot" },
                { "gtl", convert_case("to_lower_case"), desc = "to lower" },
                { "gtu", convert_case("to_upper_case"), desc = "to UPPER" },
                { "gtp", convert_case("to_phrase_case"), desc = "To phrase" },
                { "gts", convert_case("to_snake_case"), desc = "to_snake" },
                { "gtt", convert_case("to_title_case"), desc = "To Title" },
            })
        end,
    },
    {
        "machakann/vim-sandwich",
        config = function()
            vim.api.nvim_exec2(
                [[
                    let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
                    let g:sandwich#recipes += [
                    \  {
                    \    'buns': ['“', '”'],
                    \    'nesting': 1, 'match_syntax': 1,
                    \    'kind': ['add', 'delete', 'replace'],
                    \    'action': ['add', 'delete','replace'],
                    \    'input': ['“', '”']
                    \  },
                    \  {
                    \    'buns': ['（', '）'],
                    \    'nesting': 1, 'match_syntax': 1,
                    \    'kind': ['add', 'delete', 'replace'],
                    \    'action': ['add', 'delete','replace'],
                    \    'input': ['（', '）']
                    \  },
                    \  {
                    \    'buns': ['【', '】'],
                    \    'nesting': 1, 'match_syntax': 1,
                    \    'kind': ['add', 'delete', 'replace'],
                    \    'action': ['add', 'delete','replace'],
                    \    'input': ['【', '】']
                    \  },
                    \ ]
                ]],
                {}
            )
        end,
    },
    {
        "utilyre/sentiment.nvim",
        version = "*",
        event = "VeryLazy",
        init = function()
            -- NOTE: Disables the built-in matchparen.vim plugin.
            -- `matchparen.vim` needs to be disabled manually in case of lazy loading
            vim.g.loaded_matchparen = 1
        end,
        config = true,
    },
    {
        -- retake keymap for flash.nvim
        "folke/flash.nvim",
        dependencies = {
            {
                "ibhagwan/fzf-lua",
                cmd = "FzfLua",
                keys = {
                    {
                        "<leader><space>",
                        mode = { "n", "x", "o" },
                        function()
                            require("utils").treesitter.try_exec(require("flash").treesitter)
                        end,
                        desc = "Flash Treesitter",
                    },
                },
            },
        },
        opts = {
            modes = {
                search = {
                    enabled = false,
                },
                char = {
                    enabled = false,
                },
            },
        },
        keys = function()
            return {
                {
                    "U",
                    mode = { "n", "x", "o" },
                    function()
                        require("flash").jump()
                    end,
                    desc = "Flash Jump",
                },
            }
        end,
    },
    {
        "echasnovski/mini.indentscope",
        opts = function(_, tbl)
            vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = "#00CCCC" })
            local override = {
                symbol = "┆",
                draw = {
                    delay = 0,
                    animation = require("mini.indentscope").gen_animation.none(),
                    priority = 2,
                },
            }
            return vim.tbl_extend("force", tbl, override)
        end,
    },
    {
        "chrisgrieser/nvim-recorder",
        event = "RecordingEnter",
        keys = {
            { "q", desc = "Start Recording" },
            { "Q", desc = "Play Recording" },
        },
    },
    {
        "fei6409/log-highlight.nvim",
        config = function()
            require("log-highlight").setup({})
        end,
    },
    {
        "tzachar/highlight-undo.nvim",
        event = "VeryLazy",
        opts = {
            duration = 100,
            keymaps = {
                paste = {
                    disabled = true,
                },
                Paste = {
                    disabled = true,
                },
            },
        },
    },
}
