return {
    {
        "mfussenegger/nvim-lint",
        opts = {
            events = { "BufNewFile", "BufReadPre", "BufWritePost", "BufReadPost", "InsertLeave" },
            linters_by_ft = {
                cpp = { "clazy", "cppcheck" },
                bash = "bash",
                ["*"] = { "codespell", "typos" },
            },
        },
        cmd = function()
            local lint = require("lint")
            local util = require("lint.util")
            lint.linters.clazy = util.wrap(lint.linters.clazy, function(diagnostic)
                diagnostic.severity = vim.diagnostic.severity.WARN
                if diagnostic.code == "range-loop-detach" then return nil end
                return diagnostic
            end)
            lint.linters.cppcheck = util.wrap(lint.linters.cppcheck, function(diagnostic)
                diagnostic.severity = vim.diagnostic.severity.WARN
                if diagnostic.code == "unknownMacro" then return nil end
                return diagnostic
            end)
        end,
    },
}
