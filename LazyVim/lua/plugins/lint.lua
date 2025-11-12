return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            events = { "BufNewFile", "BufReadPre", "BufWritePost", "BufReadPost", "InsertLeave" },
            linters_by_ft = {
                cpp = { --[[ "clazy", ]]
                    "cppcheck",
                    "clangtidy",
                },
                bash = "bash",
                ["*"] = { "codespell", "typos" },
            },
        },
        cmd = function()
            local lint = require("lint")
            local lint_util = require("lint.util")

            local function wrap_linter(linter, filter_rules)
                return lint_util.wrap(linter, function(diagnostic)
                    for _, rule in ipairs(filter_rules) do
                        if rule.condition(diagnostic) then
                            return nil -- 过滤掉匹配的诊断
                        end
                    end

                    return diagnostic
                end)
            end

            local spell_ignore = {
                condition = function(d) return string.find(d.message, "INVOKABLE", 1, true) or string.find(d.message, "requestor", 1, true) end,
            }

            local filters = {
                clazy = {
                    { condition = function(d) return d.code == "range-loop-detach" end },
                    { condition = function(d) return d.code == "no-module-include" end },
                },
                cppcheck = {
                    { condition = function(d) return d.code == "unknownMacro" end },
                },
                typos = {
                    spell_ignore,
                },
                codespell = {
                    spell_ignore,
                },
            }

            for linter_name, rules in pairs(filters) do
                lint.linters[linter_name] = wrap_linter(lint.linters[linter_name], rules)
            end
            -- lint.linters.clangtidy = lint_util.wrap(lint.linters.clangtidy, function(diagnostic)
            --     if diagnostic.severity == vim.diagnostic.severity.HINT then return nil end
            --     return diagnostic
            -- end)
        end,
    },
}
