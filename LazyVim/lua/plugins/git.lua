return {
    {
        "lewis6991/gitsigns.nvim",
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "right_align", -- 'eol' | 'overlay' | 'right_align'
                delay = 0,
                ignore_whitespace = false,
                virt_text_priority = 100,
            },
            signs = {
                add = { text = "│" },
                change = { text = "│" },
                delete = { text = "│" },
            },
            signs_staged = {
                add = { text = "┃" },
                change = { text = "┃" },
                delete = { text = "│" },
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
