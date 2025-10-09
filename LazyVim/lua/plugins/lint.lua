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
            local util = require("lint.util")

            local function wrap_linter(linter, severity, filter_rules)
                return util.wrap(linter, function(diagnostic)
                    diagnostic.severity = severity
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
                lint.linters[linter_name] = wrap_linter(lint.linters[linter_name], vim.diagnostic.severity.WARN, rules)
            end
        end,
    },
}
