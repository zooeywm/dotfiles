return {
    {
        "johmsalas/text-case.nvim",
        config = function()
            local textcase = require("textcase")
            local wk = require("which-key")

            local function convert_case(dest_case)
                return function() textcase.current_word(dest_case) end
            end

            wk.add({
                mode = { "n", "o", "v" },
                { "<leader>tt-", convert_case("to_dash_case"),     desc = "to-dash-case" },
                { "<leader>tt/", convert_case("to_path_case"),     desc = "to/path/case" },
                { "<leader>ttC", convert_case("to_constant_case"), desc = "TO_CONSTANT_CASE" },
                { "<leader>ttP", convert_case("to_pascal_case"),   desc = "ToPascalCaser" },
                { "<leader>ttc", convert_case("to_camel_case"),    desc = "toCamelCase" },
                { "<leader>tt.", convert_case("to_dot_case"),      desc = "to.dot.case" },
                { "<leader>ttl", convert_case("to_lower_case"),    desc = "to lower case" },
                { "<leader>ttu", convert_case("to_upper_case"),    desc = "TO UPPER CASE" },
                { "<leader>ttp", convert_case("to_phrase_case"),   desc = "To phrase case" },
                { "<leader>tts", convert_case("to_snake_case"),    desc = "to_snake_case" },
                { "<leader>ttt", convert_case("to_title_case"),    desc = "To Title Case" },
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
        "ibhagwan/fzf-lua",
    },
    {
        -- retake keymap for flash.nvim
        "folke/flash.nvim",
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
        keys = {
            {
                "U",
                mode = { "n", "x", "o" },
                function() require("flash").jump() end,
                desc = "flash-jump",
            },
            {
                "<leader><space>",
                mode = { "n", "x", "o" },
                function() require("utils").treesitter.try_exec(require("flash").treesitter) end,
                desc = "Flash Treesitter",
            },
            { "s", mode = { "n", "x", "o" }, false },
            -- { "S", mode = { "n", "x", "o" }, false },
        },
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
        "tzachar/highlight-undo.nvim",
        event = "VeryLazy",
        opts = {
            duration = 100,
        },
    },
    {
        "hotoo/pangu.vim",
        config = function() vim.g.pangu_rule_date = 1 end,
    },
    {
        "nvimdev/cwordmini.nvim",
        config = true,
    },
}
