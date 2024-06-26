return {
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nushell/tree-sitter-nu", "tree-sitter-grammars/tree-sitter-hlsl" },
        opts = {
            -- stylua: ignore
            ensure_installed = {
                "rust", "slint",
                "go", "gomod",
                "python", "ruby", "perl",
                "bash", "fish",
                "c","cpp", "cmake",
                "scheme", "haskell",
                "html", "vue",
                "css", "scss",
                "javascript", "typescript",
                "java", "kotlin",
                "json", "json5", "jsonc",
                "latex", "bibtex",
                "markdown", "markdown_inline", "dot",
                "toml", "yaml", "kdl", "ron",
                "vim", "comment", "wgsl", "nu", "hlsl"
            },
            highlight = {
                enable = true,
                disable = function(_, buf)
                    return vim.api.nvim_buf_line_count(buf) > 5000 or vim.g.vscode
                end,
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter-context",
        opts = {
            max_lines = 1,
        },
    },
    { "nkrkv/nvim-treesitter-rescript", enabled = false, ft = "rescript" },
    {
        "rayliwell/tree-sitter-rstml",
        enabled = false,
        ft = "rust",
        dependencies = { "nvim-treesitter" },
        build = ":TSUpdate",
        config = true,
    },
}
