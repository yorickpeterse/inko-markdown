# inko-markdown

An opinionated dialect of [Markdown](https://en.wikipedia.org/wiki/Markdown),
aimed at making it easy to use and maintain, written in
[Inko](https://inko-lang.org/).

This library started as an experiment in parsing Markdown using conventional
[LL(k)](https://en.wikipedia.org/wiki/LL_parser) parsing techniques, rather than
the usual approach involving distinct block and inline parsing phases. As it
turns out, it's certainly doable provided we bend the rules a little bit. For
example, parsing becomes easier if we drop support for indented code blocks and
use a slightly different syntax for block quotes.

# Differences with Markdown

To make parsing easier (read: not a nightmare), inko-markdown only supports a
subset of the Markdown syntax, though this should still be good enough for most
Markdown documents out there. Apart from syntax specific differences (as
mentioned below), one big difference is that inko-markdown is strict: when it
encounters invalid syntax, an error is produced instead of silently rendering
the document incorrectly. This _significantly_ simplifies the parser, and makes
debugging incorrectly formatted documents easier.

## Lists

Unordered lists are created using `-`, and ordered lists using `1.`. Other list
markers (including `2.`, `3.`, etc) aren't supported:

```markdown
- Unordered list item 1
- Unordered list item 2

1. Ordered list item 1
1. Ordered list item 2
```

List values are limited to inline values and other lists. Block elements inside
lists aren't supported.

## Emphasis

For strong emphasis, only `**strong**` is supported. For regular emphasis, only
`_emphasis_` is supported. `__word__` is parsed as `<em></em>word<em></em>`.

## Headings

Only ATX headings are supported:

```markdown
# Heading 1
## Heading 2
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6
```

The contents of a heading can be wrapped like paragraphs, so this:

```markdown
# Foo
bar
```

Turns into this:

```html
<h1>Foo
bar</h1>
```

## Hard breaks

Hard line breaks use a trailing backslash, instead of relying on trailing
whitespace:

```markdown
this is \
a single paragraph
```

## No inline HTML

Inline HTML isn't supported, but custom blocks _are_ supported (see the
extensions section for more details).

## Code blocks and spans

Indented code blocks aren't supported, instead only fenced code blocks and
inline code blocks are supported. Fenced code blocks are _always_ parsed as code
blocks, even if they are preceded by text:

````markdown
This is text```
this is a code block, instead of literal text (per CommonMark)
```
````

Leading/trailing whitespace inside a code span isn't stripped and instead left
as-is.

## Block quotes use a syntax similar to fenced code blocks

Markdown's block quote syntax is tricky to parse, and rather painful to work
with as a document author. inko-markdown instead uses a block syntax similar to
fenced code blocks, inspired by GitLab Flavoured Markdown:

```markdown
>>>
block quote
>>>
```

Similar to fenced code blocks, the signs can be repeated to allow for nested
block quotes:

```markdown
>>>
before

>>>>
inner
>>>>

after
>>>
```

## Only one type of thematic break

The only form of thematic breaks that is supported is `---`, without any spaces
between the hyphens.

## Links containing parentheses need to be escaped

When using the syntax `[text](link)`, if `link` contains parentheses, these must
be escaped like so:

```markdown
[Cookie](https://en.wikipedia.org/wiki/Cookie_\(disambiguation\))
```

# Extensions

## Tables

The commonly used pipe table syntax is tricky to parse, and doesn't work well
for anything but basic content, as you can't wrap the content across lines.
inko-markdown uses a different syntax that makes working with tables easier.

A basic table looks like this:

```markdown
|-
| Row 1 column 1
| Row 1 column 2
|-
| Row 2 column 1
| Row 2 column 2
```

Here `|-` signals the start of a table row, and `|` the start of a column in
that row.

Header rows are created using `|=` and must come _before_ regular rows:

```markdown
|=
| Header row 1 column 1
| Header row 1 column 2
|-
| Row 1 column 1
| Row 1 column 2
|-
| Row 2 column 1
| Row 2 column 2
```

Table footers are created using `|+`, and must come _after_ regular rows:

```markdown
|=
| Header row 1 column 1
| Header row 1 column 2
|-
| Row 1 column 1
| Row 1 column 2
|-
| Row 2 column 1
| Row 2 column 2
|+
| Footer row 1 column 1
| Footer row 1 column 2
```

Cell/row formatting rules, such as text alignment, aren't supported; you should
use CSS for that instead.

If you start a table with a footer, or a column (without the row marker), the
parser produces an error.

Table cells are limited to inline elements, so you can't put (for example) a
list in a table cell. You can however wrap the content across lines, provided
the wrapped lines start with at least a single space:

```markdown
|-
| Row 1 column 1
| Row 1 column 2
  wrapped across a line
```

## Footnotes

Footnotes are referred to using `[^footnote]`, and defined using `[^footnote]:
value`. Footnote values are limited to inline elements, but their values can be
wrapped across multiple lines, as long as each line starts with at least a
single space:

```markdown
This is an example of a footnote[^example].

[^example]: foo
  bar
  baz
```

## Custom blocks and spans

Similar to [Djot](https://djot.net/), inko-markdown supports custom blocks/divs
with an optional tag:

```markdown
::: tag-name

:::
```

Just like fenced code blocks, custom blocks need at least three colons (`:::`),
but more are supported to allow nesting of blocks:

```markdown
::: outer
:::: inner
foo
::::
:::
```

This results in:

```html
<div class="outer">
  <div class="inner">
    <p>foo</p>
  </div>
</div>
```

Inline spans also use the same syntax as Djot:

```markdown
[This is the body]{highlight}
```

This results in:

```html
<p><span class="highlight">This is the body</span></p>
```

## Superscript and subscript

Superscript text uses the syntax `^body^`, while subscript uses `~body~`. The
content can be any inline value. Nesting isn't supported, so `^^foo^^` results
in `<sup></sup>foo<sup></sup>`.

# Requirements

- Inko 0.13.2 or newer

# Installation

```bash
inko pkg add github.com/yorickpeterse/inko-markdown 0.12.0
inko pkg sync
```

# Usage

Hello world using inko-markdown:

```inko
import markdown.Document
import std.stdio.STDOUT

class async Main {
  fn async main {
    let input = 'Hello **world**'
    let doc = Document.parse(input).unwrap
    let html = doc.to_html.to_string

    STDOUT.new.print(html)
  }
}
```

This produces the following HTML:

```html
<p>Hello <strong>world</strong></p>
```

# Filters

Filters are used to transform HTML documents generated from Markdown documents.
Filters implement the trait `markdown.html.Filter`, and modify documents in
place. Filters are used as follows:

```inko
import markdown.Document
import markdown.html.TableOfContents

# Filters operate on HTML documents, not Markdown documents, so we must generate
# an HTML document first:
let doc = Document.parse('# Foo').unwrap.to_html

TableOfContents.new.run(doc)
doc.to_pretty_string
```

## TableOfContents

The filter `markdown.html.TableOfContents` adds `id` attributes to all headings
based on their content, and optionally replaces custom blocks with the `toc`
tag with a table of contents. For example, consider the following Markdown
document:

```markdown
::: toc
:::

# Installation
## Linux
### Alpine
### Ubuntu
## Windows
# Manually
```

When converting this to HTML and applying this filter, the output is transformed
into the following:

```html
<ul class="toc">
  <li>
    <a href="#installation">Installation</a>
    <ul>
      <li>
        <a href="#linux">Linux</a>
        <ul>
          <li><a href="#alpine">Alpine</a></li>
          <li><a href="#ubuntu">Ubuntu</a></li>
        </ul>
      </li>
      <li><a href="#windows">Windows</a></li>
    </ul>
  </li>
  <li><a href="#manually">Manually</a></li>
</ul>
<h1 id="installation">Installation</h1>
<h2 id="linux">Linux</h2>
<h3 id="alpine">Alpine</h3>
<h3 id="ubuntu">Ubuntu</h3>
<h2 id="windows">Windows</h2>
<h1 id="manually">Manually</h1>
```

Headings can be ignored by wrapping the contents in an inline span with the
class "toc-ignore" like so:

```markdown
# [Table of contents]{toc-ignore}
```

For this to work, the span must be the outer-most and first element in the
heading, i.e. this won't work:

```markdown
# _test_ [Table of contents]{toc-ignore}
```

The following fields can be set to customize the process of generating the table
of contents:

| Option         | Default      | Description
|:---------------|:-------------|:----------------------------------------------
| `class`        | `toc`        | The `class` value of the container.
| `ignore_class` | `toc-ignore` | The class used to ignore headings in the table
| `maximum`      | `6`          | The maximum heading level to include.

# License

All source code in this repository is licensed under the Mozilla Public License
version 2.0, unless stated otherwise. A copy of this license can be found in the
file "LICENSE".
