vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "c", '"_c', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "p", '"_dP', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "diw", '"_diw', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "ciw", '"_ciw', { noremap = true, silent = true })

require("config.filetypes")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

if vim.g.neovide then require("config.neovide") end

vim.cmd([[
    highlight CurSearch guibg=#dd7878 guifg=#eff1f5
    highlight IncSearch guibg=#04a5e5 guifg=#dce0e8
    highlight Search guibg=#e5c890 guifg=#232634
    highlight HighlightUndo guibg=#eed49f guifg=#232634
    highlight CursorWord guifg=#3674B5
]])
