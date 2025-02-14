return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            current_line_blame = true,
            numhl = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
                delay = 0,
                ignore_whitespace = false,
                virt_text_priority = 100,
            },
        },
        keys = {
            { "gb", "<cmd>Gitsigns blame_line<cr>", desc = "git-blame" },
        },
    },
    {
        "sindrets/diffview.nvim",
        config = true,
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "diff" },
            { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "file-history" },
            { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "file-history-current" },
        },
    },
}
