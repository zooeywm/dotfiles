local utils = require("utils")
return {
    {
        "akinsho/bufferline.nvim",
        dependencies = { "catppuccin/nvim" },
        keys = {
            { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Jump" },
            { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all at right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all at left" },
            { "<leader>bs", "<cmd>BufferLineSortByTabs<cr>", desc = "Sort all tabs" },
        },
        opts = {
            options = {
                always_show_bufferline = true,
                -- show_buffer_icons = false,
                show_buffer_close_icons = false,
                tab_size = 1,
                max_name_length = 18,
                -- separator_style = "slope",
                color_icons = true,
                -- diagnostics = false,
                -- diagnostics_update_on_event = false,
                show_tab_indicators = true,
                show_duplicate_prefix = true,
                indicator = {
                    style = "underline",
                },
                sort_by = "insert_after_current",
            },
        },
    },
    {
        "mbbill/undotree",
        keys = {
            { "<leader>uu", "<cmd>UndotreeToggle<cr>", desc = "Toggle Undotree" },
        },
        config = function() vim.g.undotree_WindowLayout = 4 end,
    },
    {
        "mikavilpas/yazi.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        keys = {
            { "<leader>e", function() require("yazi").yazi() end, desc = "Open the file manager (cwd)" },
            { "<leader>E", function() require("yazi").yazi({}, LazyVim.root.get()) end, desc = "Open the file manager (Root Dir)" },
        },
        opts = {
            open_for_directories = true,
            hooks = {
                yazi_opened_multiple_files = function(chosen_files, _, _)
                    for _, file in ipairs(chosen_files) do
                        vim.cmd("edit " .. file)
                    end
                end,
            },
        },
    },
    {
        "MagicDuck/grug-far.nvim",
        keys = {
            {
                "gs",
                function()
                    local grug = require("grug-far")
                    grug.open({
                        engine = "ripgrep",
                        transient = true,
                        prefills = {
                            filesFilter = utils.path.filename(utils.vim.current_buffer_path()),
                        },
                        visualSelectionUsage = "operate-within-range",
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace ripgrep",
            },
            {
                "<leader>sA",
                function()
                    local grug = require("grug-far")

                    local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
                    grug.open({
                        engine = "astgrep",
                        transient = true,
                        prefills = {
                            filesFilter = ext and ext ~= "" and "*." .. ext or nil,
                        },
                    })
                end,
                mode = { "n", "v" },
                desc = "Search and Replace AST",
            },
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        keys = {
            { "<leader>e", false },
            { "<leader>E", false },
        },
    },
}
