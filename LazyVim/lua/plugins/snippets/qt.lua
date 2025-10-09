local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local ai = require("luasnip.nodes.absolute_indexer")
local events = require("luasnip.util.events")
local extras = require("luasnip.extras")
local fmt = extras.fmt
local m = extras.m
local l = extras.l
local postfix = require("luasnip.extras.postfix").postfix
local rep = require("luasnip.extras").rep

local function guard_header_from_class(args)
    local class = args[1][1] or ""
    -- 转大写 + 去掉非字母数字
    local guard = class:gsub("[^%w]", ""):upper()
    return guard .. "_H"
end

local function guard_private_header_from_class(args)
    local class = args[1][1] or ""
    local guard = class:gsub("[^%w]", ""):upper()
    return guard .. "_P_H"
end

return {
    -- QObject 类声明片段
    -- stylua: off
    s("qheader", {
        t("#ifndef "),
        f(guard_header_from_class, { 1 }),
        t({ "", "#define " }),
        f(guard_header_from_class, { 1 }),
        t({ "", "" }),
        t({ "", "#include <QObject>", "" }),
        t({ "", "" }),

        t("class "),
        i(1, "MyClass"),
        t("Private;"),
        t({ "", "class " }),
        rep(1),
        t(" : public QObject"),
        t({ "", "{", "" }),
        t({ "    Q_OBJECT", "    Q_DECLARE_PRIVATE(" }),
        rep(1),
        t(")", ""),

        t({ "", "" }),

        t({ "", "public:", "    explicit " }),
        rep(1),
        t("(QObject *parent = nullptr);"),

        t({ "", "protected:", "    QScopedPointer<" }),
        rep(1),
        t("Private> d_ptr;"),

        t({ "", "public:", "    ~" }),
        rep(1),
        t({ "() override;", "};", "", "#endif // " }),
        f(guard_header_from_class, { 1 }),
    }),
    -- stylua: on
    -- QObject 类定义片段
    s("qsource", {
        t('#include "'),
        rep(1), -- 保持与类名一致
        t('.h"'),
        t({ "", "", "// " }),
        i(1, "MyClass"),
        t({ "", "", "" }),
        rep(1),
        t("::"),
        rep(1),
        t("(QObject *parent)"),
        t({ "", "    : QObject(parent)" }),
        t({ "", "    , d_ptr(new " }),
        rep(1),
        t({ "Private())", "{" }),
        t({ "", "    d_ptr->q_ptr = this;", "}", "", "" }),
        rep(1),
        t("::~"),
        rep(1),
        t({ "()", "{" }),
        t({ "", "}", "", "// " }),
        rep(1),
        t({ "Private", "", "" }),
        rep(1),
        t("Private::"),
        rep(1),
        t({ "Private()", "    : q_ptr(nullptr)" }),
        t({ "", "{" }),
        t({ "", "}", "", "" }),
        rep(1),
        t("Private::~"),
        rep(1),
        t({ "Private()", "{" }),
        t({ "", "}" }),
    }),
    s("qprivate", {
        -- 输入类名插槽
        i(1, "MyClass"),
        t({ "", "" }),
        -- 宏防护
        t("#ifndef "),
        f(guard_private_header_from_class, { 1 }),
        t({ "", "#define " }),
        f(guard_private_header_from_class, { 1 }),
        t({ "", "" }),
        -- include
        t('#include "'),
        rep(1),
        t('.h"'),
        t({ "", "" }),
        -- class 声明
        t("class "),
        rep(1),
        t("Private : public QObjectPrivate"),
        t({ "", "{" }),
        t("    Q_DECLARE_PUBLIC("),
        rep(1),
        t(")"),
        t({ "", "", "public:", "    " }),
        rep(1),
        t("Private();"),
        t({ "", "    virtual ~" }),
        rep(1),
        t("Private();"),
        t({ "", "", "protected:", "    " }),
        rep(1),
        t(" *q_ptr;"),
        t({ "", "};", "", "#endif // " }),
        f(guard_private_header_from_class, { 1 }),
    }),
}
