return {
    -- { "elkowar/yuck.vim", enabled = false, ft = "yuck" },
    {
        "eraserhd/parinfer-rust",
        -- enabled = false,
        ft = {
            "clojure",
            "lisp",
            "scheme",
            "racket",
            "query",
        },
        build = "cargo build --release",
    },
}
