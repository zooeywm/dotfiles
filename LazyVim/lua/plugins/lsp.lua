return {
    {
        "neovim/nvim-lspconfig",
        dependencies = { "saghen/blink.cmp" },
        event = "LazyFile",
        opts = {
            inlay_hints = {
                enabled = false,
            },
            codelens = {
                enabled = true,
            },
            document_color = {
                enabled = true,
            },
            -- LSP Server Settings
            servers = {
                lua_ls = {},
                texlab = {},
                taplo = {},
                gopls = {},
                ts_ls = {},
                volar = {},
                tinymist = {},
                bashls = {},
                jsonls = {
                    filetypes = { "json", "jsonc", "json5" },
                },
                slint_lsp = {
                    root_dir = require("lspconfig").util.root_pattern(),
                },
                nushell = {},
                clangd = {
                    keys = {
                        { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                    root_dir = function(fname)
                        return require("lspconfig.util").root_pattern("Makefile", "configure.ac", "configure.in", "config.h.in", "meson.build", "meson_options.txt", "build.ninja")(fname)
                            or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(fname)
                            or require("lspconfig.util").find_git_ancestor(fname)
                    end,
                    capabilities = {
                        offsetEncoding = { "utf-16" },
                    },
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                        "--fallback-style=llvm",
                    },
                    init_options = {
                        usePlaceholders = true,
                        completeUnimported = true,
                        clangdFileStatus = true,
                    },
                },
                basedpyright = {},
                cmake = {},
                hyprls = {},
                slangd = {
                    settings = {
                        predefinedMacros = { "MY_VALUE_MACRO=1" },
                        inlayHints = {
                            deducedTypes = true,
                            parameterNames = true,
                        },
                    },
                },
                wgsl_analyzer = {},
                glslls = {},
                qmlls = {
                    cmd = { "qmlls6" },
                },
                astro = {},
                cssls = {},
            },
        },
        setup = {
            clangd = function(_, opts)
                local clangd_ext_opts = LazyVim.opts("clangd_extensions.nvim")
                require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
                return false
            end,
        },
        config = function(_, opts)
            LazyVim.lsp.setup()

            if vim.g.project_lspconfig ~= nil then opts.servers = vim.tbl_deep_extend("force", opts.servers, vim.g.project_lspconfig) end
            -- 指定诊断日志的图标
            for severity, icon in pairs(opts.diagnostics.signs.text) do
                local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
                name = "DiagnosticSign" .. name
                vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
            end

            if opts.inlay_hints.enabled then
                LazyVim.lsp.on_supports_method("textDocument/inlayHint", function(_, buffer)
                    if vim.api.nvim_buf_is_valid(buffer) and vim.bo[buffer].buftype == "" and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype) then
                        vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
                    end
                end)
            end

            if opts.codelens.enabled and vim.lsp.codelens then
                LazyVim.lsp.on_supports_method("textDocument/codeLens", function(_, buffer)
                    vim.lsp.codelens.refresh()
                    vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
                        buffer = buffer,
                        callback = vim.lsp.codelens.refresh,
                    })
                end)
            end

            -- if opts.document_color.enabled then
            --     LazyVim.lsp.on_supports_method(
            --         "textDocument/documentColor",
            --         function(_, buffer)
            --             vim.lsp.document_color.enable(true, buffer, {
            --                 style = "virtual",
            --             })
            --         end
            --     )
            -- end

            if vim.g.project_lspconfig ~= nil then
                opts.servers = vim.tbl_deep_extend("force", opts.servers, vim.g.project_lspconfig)
                opts.servers.rust_analyzer = nil
            end

            -- 指定诊断日志的图标
            for level, icon in pairs(require("lazyvim.config").icons.diagnostics) do
                level = "DiagnosticSign" .. level
                vim.fn.sign_define(level, { text = icon, texthl = level, numhl = "" })
            end
            -- 配置诊断
            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

            local capabilities = vim.tbl_deep_extend(
                "force",
                vim.lsp.protocol.make_client_capabilities(),
                require("blink.cmp").get_lsp_capabilities(), -- 令 blink.cmp 连接服务器
                opts.capabilities or {}
            )

            for server, server_opts in pairs(opts.servers) do
                server_opts.capabilities = vim.tbl_deep_extend("force", capabilities, server_opts.capabilities or {})
                -- 如果语言服务器不支持语义化 token，高亮就会 fallback 到 treesitter
                require("lspconfig")[server].setup(server_opts)
            end
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
            { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
            { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
            { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
            { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
            { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
            { "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Prev Diagnostic" },
            { "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next Diagnostic" },
            {
                "[e",
                function()
                    require("lspsaga.diagnostic"):goto_prev({
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end,
                desc = "Prev Error",
            },
            {
                "]e",
                function()
                    require("lspsaga.diagnostic"):goto_next({
                        severity = vim.diagnostic.severity.ERROR,
                    })
                end,
                desc = "Next Error",
            },
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
            {
                "<leader>lA",
                function()
                    vim.lsp.buf.code_action({
                        context = { only = { "source" }, diagnostics = {} },
                    })
                end,
                desc = "Source Action",
            },
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
