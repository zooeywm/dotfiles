vim.api.nvim_create_user_command("ProjectRoot", function()
    local hist_file = vim.fn.stdpath("data") .. "/neovim-project/history"
    local hist = io.open(hist_file, "a")
    if hist then
        -- 要用~替代家目录来欺骗neovim-project
        local proj = vim.fn.getcwd():gsub(vim.env.HOME, "~")
        hist:write("\n" .. proj)
        hist:flush()
        hist:close()
    end
end, { desc = "记住此项目位置" })

vim.api.nvim_create_user_command("GitPath", function()
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    local file_path = vim.fn.expand("%:p")
    local relative_path = file_path:gsub(git_root .. "/", "")
    vim.fn.setreg("+", relative_path) -- 复制到系统剪贴板
    print("Copied: " .. relative_path)
end, {})

vim.api.nvim_create_user_command("Path", function()
    local file_path = vim.fn.expand("%:p")
    vim.fn.setreg("+", file_path) -- 复制到系统剪贴板
    print("Copied: " .. file_path)
end, {})
