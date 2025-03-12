require("starship"):setup()
require("session"):setup({
    sync_yanked = true,
})
require("git"):setup({
    show_branch = true,
})
require("full-border"):setup({
    -- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
    type = ui.Border.ROUNDED,
})

-- require("full-border"):setup()
-- require("githead"):setup()

Status:children_add(function(self)
    local h = self._current.hovered
    if h and h.link_to then
        return " -> " .. tostring(h.link_to)
    else
        return ""
    end
end, 3300, Status.LEFT)
