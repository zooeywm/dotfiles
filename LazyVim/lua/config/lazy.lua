local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
    spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        { import = "lazyvim.plugins.extras.lang.yaml" },
        { import = "lazyvim.plugins.extras.lang.clangd" },
        { import = "lazyvim.plugins.extras.coding.blink" },
        { import = "lazyvim.plugins.extras.test.core" },
        { import = "lazyvim.plugins.extras.ai.sidekick" },
        -- { import = "lazyvim.plugins.extras.ai.copilot" },
        { import = "lazyvim.plugins.extras.coding.neogen" },
        { import = "plugins" },
        { import = "plugins.lang" },
    },
    rocks = {
        enabled = false,
    },
    defaults = {
        lazy = false,
        version = false,
    },
    checker = {
        enabled = false, -- automatically check for plugin updates
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                -- "tutor",
                "matchparen",
                "zipPlugin",
            },
        },
    },
})
-- vim.cmd.colorscheme("gruvbox")
