return {
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            local common_capabilities = {
                workspace = {
                    fileOperations = {
                        didRename = true,
                        willRename = true,
                    },
                },
            }
            local with_capabilities = {
                capabilities = vim.deepcopy(common_capabilities),
            }
            local opts_ext = {
                inlay_hints = {
                    enabled = false,
                    exclude = { "rust" },
                },
                codelens = {
                    enabled = false,
                },
                servers = {
                    ["*"] = {
                        capabilities = vim.deepcopy(common_capabilities),
                    },
                    lua_ls = vim.deepcopy(with_capabilities),
                    just = vim.deepcopy(with_capabilities),
                    dockerls = vim.deepcopy(with_capabilities),
                    texlab = vim.deepcopy(with_capabilities),
                    taplo = vim.deepcopy(with_capabilities),
                    gopls = vim.deepcopy(with_capabilities),
                    ts_ls = vim.deepcopy(with_capabilities),
                    tailwindcss = vim.deepcopy(with_capabilities),
                    volar = vim.deepcopy(with_capabilities),
                    tinymist = vim.deepcopy(with_capabilities),
                    bashls = vim.deepcopy(with_capabilities),
                    jsonls = vim.deepcopy(with_capabilities),
                    slint_lsp = vim.deepcopy(with_capabilities),
                    nushell = vim.deepcopy(with_capabilities),
                    clangd = {
                        capabilities = vim.deepcopy(common_capabilities),
                        keys = {
                            { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                        },
                    },
                    basedpyright = vim.deepcopy(with_capabilities),
                    neocmake = vim.deepcopy(with_capabilities),
                    hyprls = vim.deepcopy(with_capabilities),
                    qmlls = vim.deepcopy(with_capabilities),
                    astro = vim.deepcopy(with_capabilities),
                    cssls = vim.deepcopy(with_capabilities),
                },
            }

            local merged = vim.tbl_deep_extend("force", opts, opts_ext)
            merged.capabilities = nil
            return merged
        end,
    },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            { "nvim-tree/nvim-web-devicons" },
            { "nvim-treesitter/nvim-treesitter" },
        },
        event = "LspAttach",
        keys = {
            -- 跳转
            { "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Prev Diagnostic" },
            { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },
            { "[e", function() require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Prev Error" },
            { "]e", function() require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR }) end, desc = "Next Error" },
            -- 审视
            { "<S-k>", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover" },
            { "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<CR>", desc = "Line Diagnostics" },
            { "<leader>lI", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
            -- 更改
            { "<leader>lr", "<cmd>Lspsaga rename<cr>", desc = "Rename" },
            {
                mode = { "n", "v" },
                "<leader>la",
                "<cmd>Lspsaga code_action<cr>",
                desc = "Code Action",
            },
            { "<leader>ll", vim.lsp.codelens.run, mode = "n", desc = "Code Lens" },
            { "<leader>ls", "<cmd>Lspsaga outline<cr>", desc = "Outline" },
            { "<leader>li", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incoming calls tree" },
            { "<leader>lo", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing calls tree" },
        },
        opts = {
            outline = {
                win_width = 50,
                close_after_jump = true,
                keys = {
                    toggle_or_jump = "e",
                    jump = "o",
                },
            },
            ui = {
                code_action = "󰞇",
            },
            finder = {
                max_height = 0.8,
                default = "ref",
            },
        },
    },
}
