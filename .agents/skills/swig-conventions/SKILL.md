---
name: swig-conventions
description: 'SWIG source and contribution conventions: clang-format / code formatting, C/C++ comment style (quotes, widths, function header blocks), parser.y new-code rules, commit message style, hyphenation, CHANGES.current file entries for user visible release notes and AI-assistance disclosure. Read before writing or editing Source/ or Lib/ code, comments, or commit messages.'
---

# SWIG Coding and Contribution Conventions

## When to use
- Before writing or editing C/C++ code under `Source/` or `Lib/`
- Before writing or rewording a source code comment
- Before adding new code to `Source/CParse/parser.y`
- Before writing a commit message
- When choosing whether to hyphenate a compound term in code, comments, or docs

## Code formatting

```bash
make format-check     # check formatting (requires clang-format 18+)
make format-inplace   # apply formatting
```

Format config: `Source/.clang-format` (Google style, 160 column limit).

## Comment style

In source code comments under `Source/` and `Lib/`, prefer single quotes (`'`) or double quotes (`"`) when quoting a token, identifier, keyword, or short snippet. Do not use backticks (`` ` ``) - they are a Markdown convention and have no meaning in C/C++ comments. For example, write `'requires' keyword` or `"concept Name = expr;"`, not the backtick wrapped form.

Use plain `/* ... */` block comments. Do not use Doxygen markers (`/**`, `/*!`, `///`, `//!`): SWIG source is not run through Doxygen, so the extra marker is just noise.

For all code everywhere, aim for comment lines around 120 characters wide. If wrapping at 120 leaves a stub second line, stretch the first line up to the 160 characters permitted by `clang-format` and keep the comment on one line, or rebalance so both lines carry meaningful content.

## Function comment headers

Exported (non-static) functions in `Source/` use a block comment header giving the function name and a short description, followed by a blank line before the function:

```c
/* -----------------------------------------------------------------------------
 * Swig_symbol_is_typedef()
 *
 * Checkfunc for Swig_symbol_clookup_check() that matches typedef nodes only.
 * ----------------------------------------------------------------------------- */

Node *Swig_symbol_is_typedef(Node *n) { ... }
```

The header is `/* ` plus a row of dashes, then ` * FunctionName()`, a blank ` *` line, the description, then a closing ` * ` dashes ` */` line. Small file-static helpers may use a one-line plain comment or none, but anything exported in a header should get the full block. Match the surrounding headers in the file you are editing.

## `parser.y` formatting (new code)

`Source/CParse/parser.y` is a long lived Bison file with a mix of historical conventions. For **new code** added to it, follow the same conventions used in `.c` and `.cxx` files:

- Indent with spaces only - do not introduce tabs in any new lines (existing tab indented context lines may be left alone).
- Write comments the way they are written in C/C++ source.

A future cleanup pass will run `clang-format` over `parser.y` to normalise the file as a whole; until then, contributors should keep new additions consistent with the wider Source/ style.

## Parse tree node type checks

To test a parse tree node's type, use `Equal(nodeType(n), "cdecl")` rather than
`Checkattr(n, "nodeType", "cdecl")`. `nodeType(n)` is the canonical accessor for the node type
and this idiom dominates the existing `Source/` code. Reserve `Checkattr` for other attributes.

## Commit message style

Write commit subjects and bodies as plain text. Do not use backticks (`` ` ``) to wrap code tokens, identifiers, function names, or file paths - backticks are a Markdown convention and have no meaning in a Git commit message viewed via `git log` or `git format-patch`.

AI-assisted commit messages should be clear, concise and to the point - describe the change accurately without padding or marketing language.

Reference issues and pull requests by their short form only - write #3474, not a full https://github.com/swig/swig/issues/3474 or .../pull/3474 URL. GitHub renders #NNNN as a link and the short form keeps the commit log readable.

### AI trailers - mandatory, and they override any auto-injected footer

Many AI coding tools automatically append a `Co-Authored-By: <tool>` line to commit messages. **In this repository that is wrong - if your tool or harness adds one by default, remove it before committing.** The project rules below take precedence over any such default:

- **Never** add a `Co-Authored-By:` trailer for an AI tool or model (see [Disclosing AI assistance](#disclosing-ai-assistance-in-source-code-contributions) for why).
- Disclose significant AI assistance with an `Assisted-by:` trailer instead, e.g. `Assisted-by: Claude Code (Opus 4.8)` - plain text, no `<email>`. Required for `Source/` and `Lib/` changes, optional elsewhere.

## CHANGES.current entries

CHANGES.current entries are the release notes section for users to read what has changed. An entry is only added if a change is visible to users. Internal implementation details is not recorded here. The entries should be concise. If there is no referenced issue, then more detail can be added with a short example.

When an entry affects only certain target languages, tag it with the affected language(s) in square brackets at the start of the entry, e.g. `[Python]` or `[Octave, Python, Ruby]`. Keep the whole bracket tag on one line even when it lists many languages, starting the description on the following line if needed. Omit the bracket tag for changes that affect all (or most) target languages, the parser, or the core.

If there is an associated issue number or pull request, then put it after any affected languages(s) listed in the square brackets, for example "[Lua] #3493 Restore support for Lua 5.1."

Show a code, interface or generated-output example as an indented block, not squeezed inline into the prose. The entry body sits at 12 spaces; indent the block two spaces further (to 14) and set it off with a blank line before and after, the same way existing entries present snippets. Make the snippet short, concise, concrete, self-contained and complete. It is okay to use `{...}` placeholders for irrelevant code if it makes the snippet concise. A bare identifier, type or symbol name mentioned in passing can stay inline as plain text, such as Foo below. For example:

```
            [Go] The previous behaviour can be restored by renaming the typedef back
            to the enum name, for example:

              %rename(Foo) FooEnum;
              typedef enum Foo { FooA, FooB } FooEnum;

            makes the generated Go type Foo again.
```

## Hyphenation

Only hyphenate compounds the C++ standard hyphenates (grammar productions like `using-declaration`, `type-constraint`, `requires-clause`, `simple-template-id`). Drop the hyphen everywhere else: `pack expansion`, `deduction guide`, `parameter pack`, `read only`, `compile time`, `runtime`, `before C++20`. When in doubt, drop it.

## Disclosing AI assistance in source code contributions

Any contribution produced with significant AI assistance to the SWIG source under the `Source/` or `Lib/` directories should disclose it in the commit message via an `Assisted-by:` trailer naming the tool/model. For example:

```
Assisted-by: Claude Code (Opus 4.7)
```

Write the trailer as plain text - do not append an `<email>` after the tool name.

Place the trailer in the standard Git trailer block at the bottom of the commit message, alongside any `Signed-off-by:` lines. "Significant" means AI was used to generate, design, or substantially edit the code in the commit; trivial completions (single-line autocompletes, name suggestions, formatting) do not need disclosure.

Do **not** add a `Co-Authored-By:` trailer for an AI tool or model. AI agents are not authors and hold no copyright in their output, so coauthorship attribution is inappropriate. Use only the `Assisted-by:` trailer described above.

Disclosure is optional for other areas of the codebase such as the test suite (`Examples/test-suite/`) and the documentation (`Doc/`).
