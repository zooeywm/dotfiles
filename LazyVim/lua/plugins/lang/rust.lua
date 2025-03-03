return {
    {
        "saecki/crates.nvim",
        event = "BufRead Cargo.toml",
        tag = "stable",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = function()
            local crates = require("crates")
            return {
                { "<leader>ci", crates.show_crate_popup, ft = "toml", desc = "show-crate-popup" },
                { "<leader>cv", crates.show_versions_popup, ft = "toml", desc = "show-versions-popup" },
                { "<leader>cf", crates.show_features_popup, ft = "toml", desc = "show-features-popup" },
                { "<leader>ct", crates.extract_crate_into_table, ft = "toml", desc = "extract-crate-into-table" },
            }
        end,
        opts = {
            popup = {
                autofocus = true,
                hide_on_select = true,
            },
        },
    },
    {
        "mrcjkb/rustaceanvim",
        ft = { "rust" },
        keys = {
            { "<leader>ce", "<cmd>RustLsp expandMacro<CR>", ft = "rust", desc = "show-expand-macro" },
            { "<leader>cr", "<cmd>RustLsp runnables<CR>", ft = "rust", desc = "show-runnables" },
            { "<leader>cc", "<cmd>RustLsp openCargo<CR>", ft = "rust", desc = "open-cargo-toml" },
            { "<leader>cd", "<cmd>RustLsp openDocs<CR>", ft = "rust", desc = "open-rust-doc" },
            { "<leader>ch", "<cmd>RustLsp hover actions<CR>", ft = "rust", desc = "show-hover-actions" },
            { "<leader>ld", "<cmd>RustLsp renderDiagnostic current<CR>", ft = "rust", desc = "diagnostic-current" },
            { "gp", "<cmd>RustLsp parentModule<CR>", ft = "rust", desc = "goto-parent-module" },
        },
        opts = {
            tools = {
                float_win_config = {
                    -- the border that is used for the hover window or explain_error window
                    ---@see vim.api.nvim_open_win()
                    ---@type string[][] | string
                    border = "rounded",
                    max_width = math.floor(vim.api.nvim_win_get_width(0) * 0.7),
                    max_height = math.floor(vim.api.nvim_win_get_height(0) * 0.7),

                    --- whether the floating window gets automatically focused
                    --- default: false
                    ---@type boolean
                    auto_focus = true,
                },
            },
            server = {
                default_settings = {
                    ["rust-analyzer"] = {
                        check = {
                            command = "clippy",
                            extraArgs = {
                                "--no-deps",
                                "--message-format=json-diagnostic-rendered-ansi",
                            },
                            workspace = false,
                        },
                        checkOnSave = true,
                        inlayHints = {
                            typeHints = {
                                enable = false,
                            },
                            parameterHints = {
                                enable = true,
                            },
                            discriminantHints = {
                                enable = "always",
                            },
                        },
                        procMacro = {
                            ignored = {
                                "async_trait::async_trait",
                                "tokio::test",
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            --  project_lspconfig 就是`plugins/lsp.lua`的 nvim-lspconfig 的`opts.servers`
            local project_lspconfig = vim.g.project_lspconfig
            if project_lspconfig ~= nil and project_lspconfig.rust_analyzer ~= nil then opts.server = vim.tbl_deep_extend("force", opts.server, project_lspconfig.rust_analyzer) end

            vim.g.rustaceanvim = opts
        end,
    },
    {
        "vxpm/ferris.nvim",
        keys = function()
            return {
                {
                    "<leader>cm",
                    require("ferris.methods.view_memory_layout"),
                    desc = "View memory layout",
                },
            }
        end,
    },
}
