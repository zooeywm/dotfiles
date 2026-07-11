local Target = {
    Native = "native",
    Linux = "linux",
    Windows = "windows",
    All = "all",
}

local linux_target = "x86_64-unknown-linux-gnu"
local windows_target = "x86_64-pc-windows-msvc"

local linux_settings = {
    cargo = {
        target = linux_target,
        allTargets = false,

        buildScripts = {
            overrideCommand = {
                "cargo",
                "check",
                "--quiet",
                "--workspace",
                "--message-format=json",
                "--keep-going",
                "--target",
                linux_target,
            },
        },
    },

    check = {
        allTargets = false,
        overrideCommand = {
            "cargo",
            "clippy",
            "--workspace",
            "--no-deps",
            "--message-format=json-diagnostic-rendered-ansi",
            "--keep-going",
            "--target",
            linux_target,
        },
    },
}

local windows_settings = {
    cargo = {
        target = windows_target,
        allTargets = false,

        buildScripts = {
            overrideCommand = {
                "cargo",
                "xwin",
                "check",
                "--quiet",
                "--workspace",
                "--message-format=json",
                "--keep-going",
                "--target",
                windows_target,
            },
        },
    },

    check = {
        allTargets = false,
        overrideCommand = {
            "cargo",
            "xwin",
            "clippy",
            "--workspace",
            "--message-format=json-diagnostic-rendered-ansi",
            "--keep-going",
            "--target",
            windows_target,
        },
    },
}

local all_settings = {
    check = {
        allTargets = false,
        overrideCommand = {
            "sh",
            "-c",
            table.concat({
                "cargo clippy --workspace --no-deps --message-format=json-diagnostic-rendered-ansi --keep-going --target "
                    .. linux_target,
                "linux_status=$?",
                "cargo xwin clippy --workspace --message-format=json-diagnostic-rendered-ansi --keep-going --target "
                    .. windows_target,
                "windows_status=$?",
                'if [ "$linux_status" -ne 0 ]; then exit "$linux_status"; fi',
                'exit "$windows_status"',
            }, "\n"),
        },
    },
}

vim.g.rust_analyzer_target = vim.g.rust_analyzer_target or Target.Native

local function normalize_target(target)
    target = string.lower(target or "")

    if target == "" then return nil end
    if target == Target.Native then return Target.Native end
    if target == Target.Linux then return Target.Linux end
    if target == Target.Windows or target == "win" then return Target.Windows end
    if target == Target.All then return Target.All end

    return nil
end

local function target_label(target)
    if target == Target.Native then return "Native" end
    if target == Target.Linux then return "Linux" end
    if target == Target.Windows then return "Windows" end
    if target == Target.All then return "All" end

    return tostring(target)
end

local function target_override(target)
    if target == Target.Native then return {} end
    if target == Target.Linux then return linux_settings end
    if target == Target.Windows then return windows_settings end
    if target == Target.All then return all_settings end

    return nil
end

local function apply_target_to_client(client, target)
    local override = target_override(target)
    if not override then
        vim.notify("unknown rust-analyzer target: " .. tostring(target), vim.log.levels.ERROR)
        return
    end

    client.config.settings = client.config.settings or {}

    if not client.config._rust_analyzer_target_base_settings then
        client.config._rust_analyzer_target_base_settings = vim.deepcopy(client.config.settings["rust-analyzer"] or {})
    end

    local settings = vim.deepcopy(client.config.settings)
    local ra = vim.deepcopy(client.config._rust_analyzer_target_base_settings)

    if override.cargo ~= nil then ra.cargo = vim.deepcopy(override.cargo) end
    if override.check ~= nil then ra.check = vim.deepcopy(override.check) end

    settings["rust-analyzer"] = ra
    client.config.settings = settings
    client.settings = settings
    client:notify("workspace/didChangeConfiguration", { settings = settings })
end

local function refresh_rust_analyzer()
    pcall(vim.cmd, "silent! RustLsp reloadWorkspace")
    pcall(vim.cmd, "silent! RustLsp flyCheck run")
end

local function apply_target(target, restart)
    target = normalize_target(target)
    if not target then
        vim.notify("rust-analyzer target must be one of: Native, Linux, Windows, All", vim.log.levels.ERROR)
        return
    end

    vim.g.rust_analyzer_target = target

    for _, client in ipairs(vim.lsp.get_clients({ name = "rust-analyzer" })) do
        apply_target_to_client(client, target)
    end

    if restart then
        pcall(vim.cmd, "silent! RustAnalyzer restart")
    else
        refresh_rust_analyzer()
    end

    vim.notify("rust-analyzer target: " .. target_label(target))
end

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "rust-analyzer" and vim.g.rust_analyzer_target ~= Target.Native then
            apply_target_to_client(client, vim.g.rust_analyzer_target)
        end
    end,
})

local function target_command(target)
    return function(opts)
        apply_target(target, not opts.bang)
    end
end

vim.api.nvim_create_user_command("RustAnalyzerTarget", function(opts)
    local target = normalize_target(opts.args)
    if target == nil then
        print("rust-analyzer target: " .. target_label(vim.g.rust_analyzer_target))
        return
    end

    apply_target(target, not opts.bang)
end, {
    bang = true,
    nargs = "?",
    complete = function()
        return { "Native", "Linux", "Windows", "All" }
    end,
    desc = "Show or set rust-analyzer target.",
})

vim.api.nvim_create_user_command("RustAnalyzerTargetNative", target_command(Target.Native), {
    bang = true,
    desc = "Use native rust-analyzer target. Add ! to avoid restarting rust-analyzer.",
})

vim.api.nvim_create_user_command("RustAnalyzerTargetLinux", target_command(Target.Linux), {
    bang = true,
    desc = "Use explicit Linux rust-analyzer target. Add ! to avoid restarting rust-analyzer.",
})

vim.api.nvim_create_user_command("RustAnalyzerTargetWindows", target_command(Target.Windows), {
    bang = true,
    desc = "Use explicit Windows rust-analyzer target. Add ! to avoid restarting rust-analyzer.",
})

vim.api.nvim_create_user_command("RustAnalyzerTargetAll", target_command(Target.All), {
    bang = true,
    desc = "Use native rust-analyzer target and check Linux plus Windows. Add ! to avoid restarting rust-analyzer.",
})

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
            { "<leader>cO", "<cmd>RustLsp openCargo<CR>", ft = "rust", desc = "open-cargo-toml" },
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
                settings = {
                    ["rust-analyzer"] = {
                        diagnostics = {
                            disabled = { "proc-macro-disabled" },
                        },
                        check = {
                            command = "clippy",
                            extraArgs = {
                                "--no-deps",
                                "--message-format=json-diagnostic-rendered-ansi",
                            },
                            workspace = false,
                        },
                        cachePriming = {
                            enable = false,
                        },
                        checkOnSave = true,
                        lens = {
                            implementations = {
                                enable = false,
                            },
                        },
                        inlayHints = {
                            typeHints = {
                                enable = false,
                            },
                            parameterHints = {
                                enable = false,
                            },
                            discriminantHints = {
                                enable = "always",
                            },
                        },
                        procMacro = {
                            ignored = {
                                ["async-trait"] = { "async_trait" },
                                ["tokio-macros"] = { "main", "test" },
                            },
                        },
                        completion = {
                            autoimport = {
                                exclude = {
                                    {
                                        path = "anyhow::Ok",
                                        type = "always",
                                    },
                                    {
                                        path = "boxcar::Vec",
                                        type = "always",
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
        config = function(_, opts)
            local project_config = vim.g.project_config
            if project_config ~= nil and project_config.rust_analyzer ~= nil then opts.server = vim.tbl_deep_extend("force", opts.server, project_config.rust_analyzer) end

            vim.g.rustaceanvim = opts
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                rust_analyzer = {
                    enabled = false,
                },
                ["rust-analyzer"] = {
                    keys = {
                        { "<leader>cc", "<cmd>RustLsp flyCheck<CR>", desc = "fly-check" },
                        { "<leader>cr", "<cmd>RustLsp runnables<CR>", desc = "show-runnables" },
                        { "<leader>cd", "<cmd>RustLsp openDocs<CR>", desc = "open-rust-doc" },
                        { "<leader>ch", "<cmd>RustLsp hover actions<CR>", desc = "show-hover-actions" },
                        { "<leader>ld", "<cmd>RustLsp renderDiagnostic current<CR>", desc = "diagnostic-current" },
                        { "gp", "<cmd>RustLsp parentModule<CR>", desc = "goto-parent-module" },
                    },
                },
            },
        },
    },
    {
        "vxpm/ferris.nvim",
        keys = function()
            return {
                {
                    "<leader>cm",
                    require("ferris.methods.view_memory_layout"),
                    ft = "rust",
                    desc = "View memory layout",
                },
            }
        end,
    },
}
