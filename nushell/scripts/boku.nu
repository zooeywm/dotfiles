#!/usr/bin/env -S nu --stdin

# Filters by `characters`
export def chars [...chars: string] {
    $in | where ($it.characters | list contains $chars)
}

# Filters by `tags`
export def tags [...tags: string] {
    $in | where ($it.tags | list contains $tags)
}

# Aggregates books into human-readable table
export def agg [] {
    $in
    | each {|it| {
        id: $it.id,
        book: (book fmt $it),
    }}
    | table --theme basic
}

# Records a new book
export def rec [
    toc: string = "./boku.nuon", # Book indices
    --author (-a): string,
    --name (-e): string,
    --series (-s): string,
    --chars (-c): list<string>,
    --tags (-t): list<string>,
    --book (-b): string, # Rename this directory to allocated ID
] {
    let id = (random uuid)
    let info = {
        id: $id,
        author: $author,
        name: $name,
        series: $series,
        characters: $chars,
        tags: $tags,
    }
    print {
        id: $id,
        info: (book fmt $info),
    }

    open $toc | append $info | save -f $toc

    if ($book | is-not-empty) {
        mv $book $id
    }
}

def 'option map' [f: closure] {
    let self = $in
    if not ($self | is-empty) {
        do $f $self
    } else {
        null
    }
}

def 'book fmt' [bk: record] {
    [
        $bk.name,
        ("作者：" + $bk.author),
        ($bk.series | option map {|it| '系列：' + $it }),
        ($bk.characters | str join ', ' | option map {|it| '角色：' + $it }),
        ($bk.tags | str join ',' | option map {|it| '要素：' + $it }),
    ]
    | filter {|it| $it != null }
    | str join (char newline)
}

def 'list contains' [list: list<string>] {
    let self = $in | default []

    for $elt in $list {
        if $elt not-in $self {
            return false
        }
    }

    true
}
