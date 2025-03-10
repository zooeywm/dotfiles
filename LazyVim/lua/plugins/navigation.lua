return {
    {
        "akinsho/bufferline.nvim",
        keys = {
            { "<leader>bj", "<cmd>BufferLinePick<cr>", desc = "Jump" },
            { "<leader>bl", "<cmd>BufferLineCloseRight<cr>", desc = "Close all at right" },
            { "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all at left" },
        },
        opts = {
            options = {
                always_show_bufferline = false,
                show_buffer_close_icons = false,
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
