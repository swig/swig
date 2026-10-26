---
name: swig-conventions
description: 'SWIG source code conventions: clang-format / code formatting, C/C++ comment style (quotes, widths, function header blocks), parser.y new code rules, alphabetical ordering of makefile lists, adding or retiring a warning number and checking it is documented, hyphenation and CHANGES.current file entries for user visible release notes. Read before writing or editing Source/ or Lib/ code or comments, or a CHANGES.current entry.'
---

# SWIG Coding and Contribution Conventions

## When to use
- Before writing or editing C/C++ code under `Source/` or `Lib/`
- Before adding a test case to a makefile list
- Before writing or rewording a source code comment
- Before adding new code to `Source/CParse/parser.y`
- Before writing a `CHANGES.current` entry
- When choosing whether to hyphenate a compound term in code, comments, or docs

Commit messages, the `Assisted-by:` AI disclosure trailer and what to test before committing are in `.agents/skills/swig-contribute/SKILL.md`.

## Code formatting

```bash
make format-check     # check formatting (requires clang-format 18+)
make format-inplace   # apply formatting
```

Format config: `Source/.clang-format` (Google style, 160 column limit).

## Comment style

In source code comments under `Source/` and `Lib/`, prefer single quotes (`'`) or double quotes (`"`) when quoting a token, identifier, keyword or short type such as `'char [*]'`. Do not use backticks (`` ` ``) - they are a Markdown convention and have no meaning in C/C++ comments. For example, write `'requires' keyword`, not the backtick wrapped form.

Do not put a code statement, declaration or a series of code examples inline in a comment's prose, quoted or not. Show the code as an indented block instead, one statement or example per line without quotes, indented two spaces further than the comment's text, and continue the prose on the next line. This:

```c
/* A function declared again with the same type, which C allows, can give the size of a C99 variable length array
   parameter that the first declaration 'c', the one that is wrapped, does not.  For example:
     void f(int, int a[*]);
     void f(int n, int a[n]);
   Keep the size from the later declaration 'n' for a typemap written with '[*]'. */
```

not this:

```c
/* A function declared again with the same type, which C allows, can give the size of a C99 variable length array
   parameter that the first declaration 'c', the one that is wrapped, does not.  For example, 'void f(int, int a[*]);'
   followed by 'void f(int n, int a[n]);'.  Keep the size from the later declaration 'n' for a typemap written with
   '[*]'. */
```

In a comment whose lines start with ` * `, indent the code two spaces after the ` * `.

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

## Makefile lists

All lists in the makefiles are kept in alphabetical order - the test case lists in
`Examples/test-suite/common.mk` and in each `Examples/test-suite/<language>/Makefile.in`
(`CPP_TEST_CASES`, `CPP11_TEST_CASES`, `C_TEST_CASES`, `MULTI_CPP_TEST_CASES`,
`FAILING_CPP_TESTS` and the rest), and any other list of names.

**Add a new entry in its alphabetical position, never at the end of the list.** Appending is the
easy mistake to make and it is not caught by any build check, so the ordering only stays correct if
each addition is placed deliberately.

Order by the plain name as a person reads it, treating `_` as a word separator rather than as a
character to sort on - `li_std_vectora` is listed before `li_std_vector_extra`. `sort` disagrees
with this, since it compares `_` (0x5F) against the letter, so do not run the lists through `sort`
to fix them up.

A small amount of historical drift exists in the longer lists. Leave it alone unless the list is
the subject of the change - reordering unrelated entries adds noise to a diff.

## Adding, changing or retiring a warning

A warning is spread over three files that nothing in the build ties together: the number in `Source/Include/swigwarn.h`, sometimes a message in `Lib/swigwarnings.swg`, and the user visible entry in `Doc/Manual/Warnings.html`. A number added to the header can therefore silently never reach the manual, which is how a whole batch of numbers came to be undocumented.

**Whenever you add, renumber or retire a warning, run:**

```bash
Tools/checkwarnings.py          # --help for options
```

It lists any number defined but not documented, or documented but not defined, and exits non-zero when the two sets differ.

The check covers presence only, not message text. If you change what a message *says*, update the matching entry in `Doc/Manual/Warnings.html` by hand, and run the errors test suite - it is the only thing that pins warning text:

```bash
make check-errors-test-suite
```

Retire a number rather than deleting it, so that it is never reused. Comment the `#define` out in place as `/* Unused since X.Y.Z: ... */` (see the existing 101-110 and 341-343), delete any `_MSG` define from `Lib/swigwarnings.swg`, and remove the `<li>` entirely from `Doc/Manual/Warnings.html`. `Lib/swigwarn.swg` is generated from the header and follows automatically.

## CHANGES.current entries

CHANGES.current entries are the release notes section for users to read what has changed. An entry is only added if a change is visible to users. Internal implementation details is not recorded here. The entries should be concise. If there is no referenced issue, then more detail can be added with a short example.

When an entry affects only certain target languages, tag it with the affected language(s) in square brackets at the start of the entry, e.g. `[Python]` or `[Octave, Python, Ruby]`. Keep the whole bracket tag on one line even when it lists many languages, starting the description on the following line if needed. Name the affected languages only in the bracket tag, never in the entry text. When a change affects groups of languages differently, write one entry per group, each with its own tag. Omit the tag only for changes that affect all target languages in the same way, the parser, or the core.

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

Only hyphenate compounds the C++ standard hyphenates (grammar productions like `using-declaration`, `type-constraint`, `requires-clause`, `simple-template-id`). Drop the hyphen everywhere else: `pack expansion`, `deduction guide`, `parameter pack`, `read only`, `compile time`, `runtime`, `language independent`, `before C++20`. When in doubt, drop it.

`runtime` is one word, never `run-time` or `run time`. Older text, notably in `Doc/Manual`, still has needless hyphens such as `language-independent` and `run-time`. Drop them in any line that a change writes or rewrites, rather than copying them.
