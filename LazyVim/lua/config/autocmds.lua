-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local my_group = vim.api.nvim_create_augroup("MyAutocommands", { clear = true })
vim.api.nvim_create_autocmd("BufReadPre", {
    callback = function(_)
        local root_dir = require("lazyvim.util").root.get()
        local cwd = vim.fn.getcwd()
        local exrc = root_dir .. "/.nvim.lua"
        if root_dir ~= cwd and vim.fn.filereadable(exrc) == 1 then
            vim.cmd("luafile " .. exrc)
        end
    end,
    desc = "When pwd isn't program root, read `.nvim.lua` located in program root",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    command = "setlocal nospell",
    group = my_group,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "*" },
    callback = function()
        require("colorizer").setup()
    end,
    group = my_group,
})
