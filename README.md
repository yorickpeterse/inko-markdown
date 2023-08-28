# inko-markdown

An opinionated subset of [Markdown](https://en.wikipedia.org/wiki/Markdown),
aimed at making it easy to use and maintain, written in
[Inko](https://inko-lang.org/).

inko-markdown is opinionated in that it does away with some of the
inconsistencies and questionable features of Markdown, such as offering
different ways of writing lists and headers.

inko-markdown remains compatible with existing Markdown tooling such as
[Vale](https://github.com/errata-ai/vale) (ignoring any extensions), making it
easier to adopt.

# Why

I needed a way to convert Markdown documents to HTML, without relying on any C
libraries. Markdown itself lacks a clear specification and is rather painful to
parse. While [CommonMark](https://commonmark.org/) exists, it doesn't address
the problems with Markdown, instead it just provides a specification of them.

[Djot](https://djot.net/) is an interesting alternative, and is _mostly_
compatible with Markdown. I say _mostly_ because it makes several changes that
make switching between Markdown and Djot tricky, such as `*word*` resulting in
`<i>word</i>` in Markdown, but `<strong>word</strong>` in Djot. Similarly to
Markdown, Djot also provides different ways of writing lists, complicating the
parsing process, and has some odd requirements for writing nested lists. All
this means that you can't seamlessly switch between Djot and Markdown.

# Differences with Markdown

- There are only two ways of writing lists: `- item` for unordered lists, and
  `1. item` for ordered lists. Other numbers (e.g. `3.`) for ordered lists
  aren't supported.
- `**word**` is `<strong>word</strong>` and `_word_` is `<em>word</em>`. Nesting
  the same emphasis type isn't supported, and we only support single underscores
  for regular emphasis. This means `__word__` results in
  `<em></em>word<em></em>`.
- No support for setext headings.
- Hard line breaks use a trailing `\` like Djot, instead of two spaces, as
  editors are likely to remove trailing whitespace, and because trailing
  whitespace isn't easily visible.
- No support for inline HTML, decoupling the Markup from the browser, and
  removing the need for also including an HTML parser.
- No support for indented code blocks, only fenced code blocks are supported.
- In general, the parser is much more strict/pedantic about how things should be
  parsed. This makes maintenance easier and leads to more consistent and
  predictable behaviour.
- No auto linking based on the URI scheme, just use `<link>` or `[text](link)`
  instead.
- Anything else I forgot to implement or just don't care for :)
- No support for triple strong/emphasis delimiters (e.g. `***foo***`).
- `[foo][bar]` is always a link with text "foo" using reference "bar". If "bar"
  isn't defined, the link URL is empty.
- Using triple grave accents, even in inline contexts, always results in a code
  block.
- List values are restricted to inline elements or other lists, meaning you
  can't put e.g. a title in a list value.

# Extensions

- Fenced code blocks using triple backticks.
- Pipe tables.
- Admonitions, using the [Python
  Markdown](https://python-markdown.github.io/extensions/admonition/) syntax.
- [Front matter](https://jekyllrb.com/docs/front-matter/), using a simple
  YAML-like syntax (that isn't a pain to parse).
- Footnotes

## Fenced code blocks

Fenced code blocks use the usual triple (or more) backtick syntax:

````
```
code goes here
```
````

The number of backticks must be at least three or more. The closing tag must
match the same number of backticks. We allow more than three backticks so you
can nest fenced code blocks, on the rare occasion this is necessary (such as the
above example).

## Pipe tables

```
| Header column 1 | Header column 2
|:----------------|:--------------
| Row column 1    | Row column 2
```

Here `:---` is used to signal that the previous row is the header row. Unlike
other Markdown dialects, the alignment is up to the generator/output, i.e
there's no `---:` support.

The number of hyphens doesn't matter, as long as there's at least one. Alignment
isn't necessary either, meaning this is perfectly fine (ignoring the part where
it's hard to read):

```
| Header column 1 | Header column 2
|:-|:-
| Row column 1 | Row column 2
```

Multi-line content in cells isn't supported. This is annoying, but alternatives
require a different syntax for tables, and I haven't come up with something that
doesn't come with its own problems.

## Admonitions

Admonitions use the following syntax:

```
!!! KIND
    BODY
```

`KIND` can be `tip`, `info`, `warning` or `note`.

Some examples:

```
!!! tip
    This is the body.

!!! info
    This is the body.

!!! warning
    This is the body.

!!! note
    This is the body.
```

## Footnotes

Footnotes are referred to using `[^footnote]` name, and defined using
`[^footnote]: value`. Footnote values are limited to inline elements, but their
values can be wrapped across multiple lines, as long as each line starts with at
least a single space:

```markdown
[^footnote]: foo
  bar
  baz
```

## Front matter

Front matter starts with `---` on its own line, and ends with `---` on its own
line. Within the front matter block, you can specify keys and values like so:

```
---
KEY1: VALUE
KEY2: VALUE
---
```

Each key is an identifier limited to characters in the range `[a-zA-Z0-9_]`. The
value is text that runs until the end of the line. This text may span multiple
lines as long as each line is preceded by at least a single space. If multiple
spaces are used, they are compressed into a single space. The value _can_ start
on a new line, as long as it too starts with at least a single space:

```
---
title:
  This is the title
description:
  This is the description of my blog post.
---
```

Values are limited to text only. If you need lists, you can use a comma
separated string and handle this as part of whatever consumes the meta data.

# Requirements

- Inko `main` (for now)

# Installation

```bash
inko pkg add github.com/yorickpeterse/inko-markdown 0.1.0
inko pkg sync
```

# Usage

TODO

# License

All source code in this repository is licensed under the Mozilla Public License
version 2.0, unless stated otherwise. A copy of this license can be found in the
file "LICENSE".
