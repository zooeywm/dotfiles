local util = require("lazyvim.util")

local function format(component, text, hl_group)
    if not hl_group then
        return text
    end

    ---@type table<string, string>
    component.hl_cache = component.hl_cache or {}
    local lualine_hl_group = component.hl_cache[hl_group]
    if not lualine_hl_group then
        local utils = require("lualine.utils.utils")
        local mygui = function()
            local mybold = utils.extract_highlight_colors(hl_group, "bold") and "bold"
            local myitalic = utils.extract_highlight_colors(hl_group, "italic") and "italic"
            if mybold and myitalic then
                return mybold .. "," .. myitalic
            elseif mybold then
                return mybold
            elseif myitalic then
                return myitalic
            else
                return ""
            end
        end

        lualine_hl_group = component:create_hl({
            fg = utils.extract_highlight_colors(hl_group, "fg"),
            gui = mygui(),
        }, "LV_" .. hl_group)
        component.hl_cache[hl_group] = lualine_hl_group
    end
    return component:format_hl(lualine_hl_group) .. text .. component:get_default_hl()
end

local function pretty_path(opts)
    opts = vim.tbl_extend("force", {
        relative = "cwd",
        modified_hl = "MatchParen",
        filename_hl = "Bold",
        dirpath_hl = "Conceal",
    }, opts or {})

    return function(self)
        local path = vim.fn.expand("%:p") --[[@as string]]
        if path == "" then
            return ""
        end

        local root = util.root.get({ normalize = true })
        local cwd = util.root.cwd()

        if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
            path = path:sub(#cwd + 2)
        else
            path = path:sub(#root + 2)
        end

        local sep = package.config:sub(1, 1)
        local parts = vim.split(path, "[\\/]")

        if #parts > 3 then
            parts = { parts[1], "…", parts[#parts - 1], parts[#parts] }
        end

        if opts.modified_hl and vim.bo.modified then
            parts[#parts] = format(self, parts[#parts], opts.modified_hl)
        else
            parts[#parts] = format(self, parts[#parts], opts.filename_hl)
        end

        local dirpath = ""
        if #parts > 1 then
            dirpath = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
            dirpath = format(self, dirpath .. sep, opts.dirpath_hl)
        end
        return dirpath .. parts[#parts]
    end
end

return {
    -- {
    --     "sainnhe/gruvbox-material",
    --     config = function()
    --         vim.g.gruvbox_material_backgroud = "soft"
    --         vim.g.gruvbox_material_current_word = "underline"
    --         vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
    --         vim.g.gruvbox_material_visual = "red background"
    --         vim.cmd.colorscheme("gruvbox-material")
    --         -- Colors are applied automatically based on user-defined highlight groups.
    --         -- There is no default value.
    --         vim.cmd.highlight("IndentLine guifg=#808080")
    --         -- Current indent line highlight
    --         vim.cmd.highlight("IndentLineCurrent guifg=#FF6347")
    --     end,
    -- },
    -- {
    --     "Shatur/neovim-ayu",
    --     config = function()
    --         require("ayu").setup({
    --             mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
    --             terminal = true, -- Set to `false` to let terminal manage its own colors.
    --             overrides = {}, -- A dictionary of group names, each associated with a dictionary of parameters (`bg`, `fg`, `sp` and `style`) and colors in hex.
    --         })
    --         require("ayu").colorscheme()
    --     end,
    -- },
    --
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
                },
                integrations = {
                    telescope = {
                        enabled = true,
                        style = "nvchad",
                    },
                },
            })
        end,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin-macchiato",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            opts.options = {
                section_separators = { left = "", right = "" },
                component_separators = { left = "", right = "" },
            }
            -- opts.sections.lualine_a = {
            --     {
            --         function()
            --             return ""
            --         end,
            --         padding = { left = 1, right = 0 },
            --         separator = "",
            --     },
            --     "mode",
            -- }
            opts.sections.lualine_c[4] = { pretty_path() }
            opts.sections.lualine_y = { "progress" }
            opts.sections.lualine_z = {
                { "location", separator = "" },
                -- {
                --     function()
                --         return ""
                --     end,
                --     padding = { left = 0, right = 1 },
                -- },
            }
            return opts
        end,
    },
    {
        "b0o/incline.nvim",
        event = "BufReadPre",
        keys = {
            {
                "<leader>uI",
                function()
                    require("incline").toggle()
                end,
                desc = "Toggle Incline",
            },
        },
        config = function()
            require("incline").setup({
                highlight = {
                    groups = {
                        InclineNormal = { default = true, group = "lualine_a_normal" },
                        InclineNormalNC = { default = true, group = "Comment" },
                    },
                },
                window = { margin = { vertical = 0, horizontal = 1 } },
                render = function(props)
                    local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                    local icon, color = require("nvim-web-devicons").get_icon_color(filename)
                    return { { icon, guifg = color }, { icon and " " or "" }, { filename } }
                end,
            })
        end,
    },
}
