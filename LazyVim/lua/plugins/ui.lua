return {
    {
        "folke/noice.nvim",
        opts = {
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                            { find = "%d lines? yanked" },
                            { find = "%d lines? changed" },
                            { find = "1 line less" },
                            { find = "%d fewer lines" },
                            { find = "%d more lines?" },
                            { find = "1 buffer wiped out" },
                            { find = "1 buffer deleted" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },
    {
        "nvim-focus/focus.nvim",
        config = true,
    },
}
