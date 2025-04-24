return {
    {
        "akinsho/bufferline.nvim",
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
                separator_style = "thin",
                color_icons = true,
                -- diagnostics = false,
                -- diagnostics_update_on_event = false,
                show_tab_indicators = true,
                show_duplicate_prefix = true,
                -- sort_by = function(buffer_a, buffer_b)
                --     -- add custom logic
                --     local modified_a = vim.fn.getftime(buffer_a.path)
                --     local modified_b = vim.fn.getftime(buffer_b.path)
                --     return modified_a > modified_b
                -- end,
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
        "crusj/bookmarks.nvim",
        keys = {
            { "<leader>B", remap = true, desc = "Bookmarks" },
            { "<leader>m", remap = true, desc = "Make bookmark" },
            { "<leader>sB", "<cmd>Telescope bookmarks<CR>", desc = "Bookmarks" },
        },
        branch = "main",
        dependencies = { "nvim-web-devicons" },
        opts = {
            keymap = {
                toggle = "<leader>B",
                add = "<leader>m",
            },
        },
        config = function(_, opts)
            require("bookmarks").setup(opts)
            require("telescope").load_extension("bookmarks")
        end,
    },
    {
        "mikavilpas/yazi.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        keys = {
            {
                "<leader>e",
                function() require("yazi").yazi() end,
                desc = "Open the file manager",
            },
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
}
