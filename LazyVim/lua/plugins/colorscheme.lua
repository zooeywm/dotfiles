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
            -- Colors are applied automatically based on user-defined highlight groups.
            -- There is no default value.
            vim.cmd.highlight("IndentLine guifg=#808080")
            -- Current indent line highlight
            vim.cmd.highlight("IndentLineCurrent guifg=#FF6347")
            local config = vim.fn["gruvbox_material#get_configuration"]()
            local palette = vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
            local set_hl = vim.fn["gruvbox_material#highlight"]

            set_hl("Search", palette.none, palette.bg_visual_yellow)
            set_hl("IncSearch", palette.none, palette.bg_visual_red)
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "gruvbox-material",
        },
    },
}
