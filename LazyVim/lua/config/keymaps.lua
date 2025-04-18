-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local wk = require("which-key")
wk.add({ "<leader>l", group = "language" })
wk.add({ "<leader>t", group = "toggle/text-case" })
local map = {
    n = function(mapping)
        for _, m in ipairs(mapping) do
            vim.keymap.set("n", m[1], m[2], { desc = m[3] })
        end
    end,
    i = function(mapping)
        for _, m in pairs(mapping) do
            vim.keymap.set("i", m[1], m[2], { desc = m[3] })
        end
    end,
    v = function(mapping)
        for _, m in pairs(mapping) do
            vim.keymap.set("v", m[1], m[2], { desc = m[3] })
        end
    end,
}

local del = function(mapping)
    for _, m in ipairs(mapping) do
        local modes = m[1]
        local action = m[2]

        if type(modes) == "table" then
            vim.keymap.del(modes, action)
        else
            vim.keymap.del(modes, action)
        end
    end
end

del({
    { "n",               "<leader>l" },
    { { "n", "i", "v" }, "<C-s>" },
    { "n",               "<leader>fn" },
    { "n",               "<leader>cf" },
})

map.n({
    -- { "T", "<cmd>tabNext<cr>", "next-tab" },
    -- { "t", "<cmd>tabnext<cr>", "prev-tab" },
    { "<C-s>",        "<cmd>SudaWrite<cr>",                            "sudo-write" },
    { "<leader><CR>", function() vim.system({ "open-term-here" }) end, "Open term here" },
    { "<leader>lc",   "<cmd>LspConfig<cr>",                            "Lsp config" },
    { "<leader>lp",   "<cmd>PanguAll<cr>",                             "Pangu all" },
    { "<leader>cl",   function() Snacks.picker.lsp_config() end,       "Lsp info" },
    { "<leader>tw",   function() ToggleWordWrap() end,                 "Toggle word wrap" },
    { "<leader>tc",   function() ToggleColorizer() end,                "Toggle colorizer" },
    { "<leader>gn",   "<cmd>GitPath<cr>",                              "Copy file path from git root" },
    { "yn",           "<cmd>Path<cr>",                                 "Copy file path" },
    { "<M-l>",        "zl",                                            "Scroll right one character" },
    { "<M-h>",        "zh",                                            "Scroll left one character" },
    { "<M-L>",        "zL",                                            "Scroll left half screen" },
    { "<M-H>",        "zH",                                            "Scroll left half screen" },
    { "<M-K>",        "<Up>",                                          "Move up" },
    { "<M-J>",        "<Down>",                                        "Move down" },
    { "<leader>bn",   "<cmd>enew<cr>",                                 "New buffer" },

    { "<PageUp>",     "<Nop>",                                         "nop" },
    { "<PageDown>",   "<Nop>",                                         "nop" },
    { "<Home>",       "<Nop>",                                         "nop" },
    { "<End>",        "<Nop>",                                         "nop" },
    { "q:",           "<Nop>",                                         "nop" },
    { "<Tab>",        "<Nop>",                                         "nop" },
    { "<C-i>",        "<C-i>",                                         "prev" },
})

map.i({
    { "<M-h>", "<Left>",  "move-left" },
    { "<M-l>", "<Right>", "move-right" },
    { "<M-j>", "<Down>",  "move-up" },
    { "<M-k>", "<Up>",    "move-down" },
    { "<C-h>", "<Left>",  "move-left" },
    { "<C-l>", "<Right>", "move-right" },
    { "<C-k>", "<Up>",    "move-down" },
    { "<C-j>", "<Down>",  "move-up" },
    { "<C-a>", "<C-o>^",  "move-up" },
    { "<C-e>", "<C-o>$",  "move-up" },
    { "<C-d>", "<C-o>dl", "move-up" },
    { "<C-u>", "<ESC>^C", "move-up" },
})

map.v({
    { "n", "<Nop>", "nop" },
    { "N", "<Nop>", "nop" },
    { "v", "0o$h",  "exclude-end" },
    { "u", "<Nop>", "nop" },
})

function ToggleWordWrap()
    ---@diagnostic disable-next-line: undefined-field
    local wrap = vim.opt.wrap:get()
    vim.opt.wrap = not wrap
    print("Word wrap " .. (wrap and "disabled" or "enabled"))
end

function ToggleColorizer() vim.cmd("ColorizerToggle") end

if vim.g.neovide then
    vim.keymap.set("v", "<sc-c>", '"+y', { desc = "copy" })
    vim.keymap.set("n", "<sc-v>", 'l"+p', { desc = "paste" })
    vim.keymap.set("v", "<sc-v>", '"+P', { desc = "paste" })
    vim.keymap.set({ "c", "i" }, "<sc-v>", "<C-R>+", { desc = "paste" })
    vim.keymap.set({ "t" }, "<sc-v>", [[<C-\><C-N>"+pa]], { desc = "paste from clipboard in terminal mode" })

    local function increase_scale() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1 end
    local function decrease_scale() vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1 end
    local function reset_scale() vim.g.neovide_scale_factor = 1.0 end

    vim.keymap.set({ "v", "n", "c", "i", "t" }, "<C-+>", increase_scale, { noremap = true })
    vim.keymap.set({ "v", "n", "c", "i", "t" }, "<C-_>", decrease_scale, { noremap = true })
    vim.keymap.set({ "v", "n", "c", "i", "t" }, "<C-)>", reset_scale, { noremap = true })
end
