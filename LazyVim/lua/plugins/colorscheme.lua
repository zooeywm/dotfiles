return {
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_backgroud = "hard"
            vim.g.gruvbox_material_current_word = "underline"
            vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
            vim.g.gruvbox_material_visual = "blue background"
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_menu_selection_background = "aqua"
            vim.g.gruvbox_material_diagnostic_text_highlight = 1
            vim.g.gruvbox_material_inlay_hints_background = "none" --[[ or dimmed ]]
            vim.cmd.colorscheme("gruvbox-material")
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruvbox-material",
        },
    },
}
