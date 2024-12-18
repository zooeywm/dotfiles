-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local wk = require("which-key")
local map = {
    n = function(mapping)
        for _, m in ipairs(mapping) do
            vim.keymap.set("n", m[1], m[2], { desc = m.desc })
        end
    end,
    i = function(mapping)
        for key, op in pairs(mapping) do
            vim.keymap.set("i", key, op)
        end
    end,
    v = function(mapping)
        for key, op in pairs(mapping) do
            vim.keymap.set("v", key, op)
        end
    end,
}

-- 删除LazyVim映射的键位
vim.keymap.del("n", "<Leader>l")
-- vim.keymap.del("n", "<Leader>gG")
vim.keymap.del("n", "<Leader>cd")
vim.keymap.del({ "n", "i", "v" }, "<C-s>")
vim.keymap.del("n", "<C-f>")
vim.keymap.del("n", "<C-b>")

wk.add({ "<leader>l", group = "language" })
wk.add({ "<leader>t", group = "toggle" })

-- 切换标签页
map.n({
    { "[t", "<cmd>tabNext<cr>", desc = "Prev tab" },
    { "]t", "<cmd>tabnext<cr>", desc = "Next tab" },
    { "<C-s>", "<cmd>SudaWrite<cr>", desc = "sudo write" },
    -- My commands
    {
        "<leader><CR>",
        function()
            vim.system({ "open-term-here" })
        end,
        desc = "Open term here",
    },
    { "<leader>lc", "<cmd>LspConfig<cr>", desc = "Lsp Config" },
    { "<C-a>", "ggVG", desc = "Select all" },
    { "<leader>tw", ":lua ToggleWordWrap()<CR>", desc = "Toggle word wrap" },
    { "<leader>tc", ":lua ToggleColorizer()<CR>", desc = "Toggle Colorizer" },
    { "<M-l>", "zl", desc = "Screen to the right" },
    { "<M-h>", "zh", desc = "Screen to the left" },
    { "<M-L>", "zL", desc = "Screen half to the right" },
    { "<M-H>", "zH", desc = "Screen half to the right" },
})

function ToggleWordWrap()
    local wrap = vim.opt.wrap:get()
    vim.opt.wrap = not wrap
    print("Word wrap " .. (wrap and "disabled" or "enabled"))
end

function ToggleColorizer()
    vim.cmd("ColorizerToggle")
end
-- emacs keymaps
map.i({
    -- move
    ["<C-h>"] = "<Left>",
    ["<C-l>"] = "<Right>",
    ["<C-b>"] = "<Left>",
    ["<C-f>"] = "<Right>",
    -- jump
    ["<C-a>"] = "<C-o>^",
    ["<C-e>"] = "<C-o>$",
    -- delete
    ["<C-d>"] = "<C-o>dl",
    ["<C-u>"] = "<ESC>^C",
})

-- line text object
map.v({
    ["il"] = "0o$h", -- exclude end
    ["al"] = "0o$", -- include end
})
vim.keymap.set("o", "ik", "<cmd>normal vik<cr>")

-- NOTE: use for neovide to paste
if vim.g.neovide then
	vim.api.nvim_set_keymap('v', '<sc-c>', '"+y', {noremap = true})
	vim.api.nvim_set_keymap('n', '<sc-v>', 'l"+P', {noremap = true})
	vim.api.nvim_set_keymap('v', '<sc-v>', '"+P', {noremap = true})
	vim.api.nvim_set_keymap('c', '<sc-v>', '<C-o>l<C-o>"+<C-o>P<C-o>l', {noremap = true})
	vim.api.nvim_set_keymap('i', '<sc-v>', '<ESC>l"+Pli', {noremap = true})
	vim.api.nvim_set_keymap('t', '<sc-v>', '<C-\\><C-n>"+Pi', {noremap = true})
	vim.api.nvim_set_keymap('n', '<c-+>', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>', {noremap = true})
	vim.api.nvim_set_keymap('n', '<c-_>', ':lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>', {noremap = true})
	vim.api.nvim_set_keymap('n', '<c-0>', ':lua vim.g.neovide_scale_factor = 1.0<CR>', {noremap = true})
end
