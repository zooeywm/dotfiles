return {
    {
        "sainnhe/gruvbox-material",
        config = function()
            vim.g.gruvbox_material_background = "medium"
            vim.g.gruvbox_material_current_word = "underline"
            vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
            vim.g.gruvbox_material_visual = "blue background"
            vim.g.gruvbox_material_enable_bold = 1
            vim.g.gruvbox_material_menu_selection_background = "aqua"
            vim.g.gruvbox_material_diagnostic_text_highlight = 0
            vim.g.gruvbox_material_inlay_hints_background = "none" --[[ or dimmed ]]
            -- vim.cmd.colorscheme("gruvbox-material")
        end,
    },
    {
        "sainnhe/everforest",
        config = function()
            -- Optionally configure and load the colorscheme
            -- directly inside the plugin declaration.
            vim.g.everforest_enable_italic = 1
            vim.g.everforest_background = "medium"
            vim.g.everforest_diagnostic_text_highlight = 0
            -- Available values:   `'grey'`, `'colored'`, `'highlighted'`
            vim.g.everforest_diagnostic_virtual_text = "colored"
            -- Available values:   `'none'`, `'dimmed'`
            vim.g.everforest_inlay_hints_background = "none"
        end,
    },
    {
        "catppuccin/nvim",
        lazy = true,
        name = "catppuccin",
        config = function()
            require("catppuccin").setup({
                highlight_overrides = {
                    all = function(colors)
                        return {
                            CurSearch = { bg = colors.sky },
                            IncSearch = { bg = colors.sky },
                            CursorLineNr = { fg = colors.blue, style = { "bold" } },
                            DashboardFooter = { fg = colors.overlay0 },
                            TreesitterContextBottom = { style = {} },
                            WinSeparator = { fg = colors.overlay0, style = { "bold" } },
                            ["@markup.italic"] = { fg = colors.blue, style = { "italic" } },
                            ["@markup.strong"] = { fg = colors.blue, style = { "bold" } },
                            Headline = { style = { "bold" } },
                            Headline1 = { fg = colors.blue, style = { "bold" } },
                            Headline2 = { fg = colors.pink, style = { "bold" } },
                            Headline3 = { fg = colors.lavender, style = { "bold" } },
                            Headline4 = { fg = colors.green, style = { "bold" } },
                            Headline5 = { fg = colors.peach, style = { "bold" } },
                            Headline6 = { fg = colors.flamingo, style = { "bold" } },
                            rainbow1 = { fg = colors.blue, style = { "bold" } },
                            rainbow2 = { fg = colors.pink, style = { "bold" } },
                            rainbow3 = { fg = colors.lavender, style = { "bold" } },
                            rainbow4 = { fg = colors.green, style = { "bold" } },
                            rainbow5 = { fg = colors.peach, style = { "bold" } },
                            rainbow6 = { fg = colors.flamingo, style = { "bold" } },
                        }
                    end,
                },
                color_overrides = {
                    macchiato = {
                        rosewater = "#F5B8AB",
                        flamingo = "#F29D9D",
                        pink = "#AD6FF7",
                        mauve = "#FF8F40",
                        red = "#E66767",
                        maroon = "#EB788B",
                        peach = "#FAB770",
                        yellow = "#FACA64",
                        green = "#70CF67",
                        teal = "#4CD4BD",
                        sky = "#61BDFF",
                        sapphire = "#4BA8FA",
                        blue = "#00BFFF",
                        lavender = "#00BBCC",
                        text = "#C1C9E6",
                        subtext1 = "#A3AAC2",
                        subtext0 = "#8E94AB",
                        overlay2 = "#7D8296",
                        overlay1 = "#676B80",
                        overlay0 = "#464957",
                        surface2 = "#3A3D4A",
                        surface1 = "#2F313D",
                        surface0 = "#1D1E29",
                        base = "#0b0b12",
                        mantle = "#11111a",
                        crust = "#191926",
                    },
                    latte = {
                        -- custom everforest light hard port
                        rosewater = "#a43b35",
                        flamingo = "#da3537",
                        pink = "#d332a1",
                        mauve = "#aa3685",
                        red = "#ff3532",
                        maroon = "#de3631",
                        peach = "#f36c0b",
                        yellow = "#bd8800",
                        green = "#596600",
                        teal = "#287e5e",
                        sky = "#52b1c7",
                        sapphire = "#3fb4b8",
                        blue = "#317da7",
                        lavender = "#474155",
                        text = "#4d4742",
                        subtext1 = "#5b5549",
                        subtext0 = "#6d6655",
                        overlay2 = "#786d5a",
                        overlay1 = "#8c7c62",
                        overlay0 = "#a18d66",
                        surface2 = "#c9bea5",
                        surface1 = "#d8d3ba",
                        surface0 = "#e8e2c8",
                        base = "#fbf1c7",
                        mantle = "#e1dab5",
                        crust = "#bdc0a0",
                    },
                },
                integrations = {
                    telescope = {
                        enabled = true,
                        style = "nvchad",
                    },
                    blink_cmp = true,
                    diffview = true,
                    noice = true,
                    snacks = {
                        enabled = true,
                        indent_scope_color = "teal", -- catppuccin color (eg. `lavender`) Default: text
                    },
                    sandwich = true,
                    which_key = true,
                },
            })
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = function()
            vim.o.background = "light"
            return {
                -- colorscheme = "gruvbox-material",
                colorscheme = "catppuccin-macchiato",
            }
        end,
    },
}
