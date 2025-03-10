-- vim.api.nvim_set_keymap("v", "d", '"_d', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "c", '"_c', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("v", "p", '"_dP', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "dd", '"_dd', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "diw", '"_diw', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "ciw", '"_ciw', { noremap = true, silent = true })

require("config.filetypes")

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.o.background = "light"
if vim.g.neovide then
    require("config.neovide")
end
