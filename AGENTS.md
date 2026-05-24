# AGENTS.md

This file provides guidance to AI agents such as Claude Code (claude.ai/code) when working with code in this repository.

## Project skill files - read these first

Three short `SKILL.md` files under `.agents/skills/` are the canonical references for the most common tasks an AI agent performs in this repo. Open the matching file **before** improvising; each is one or two pages and contains the specific commands, flags, and conventions that AGENTS.md only summarises:

- **`.agents/skills/swig-test/SKILL.md`** — the canonical way to run the test suite for a target language and individual test cases. Read before running any test.
- **`.agents/skills/swig-debug/SKILL.md`** — debugging the SWIG compiler: full `-debug-*` flag list, parse tree dumps (text and XML), `SWIG_FEATURES` env var, gdb with the `swigprint` / `locswigprint` helpers from `Tools/swig.gdb`, valgrind via `SWIGTOOL` / `RUNTOOL`, `DOH_DEBUG_MEMORY_POOLS` for memory corruption diagnosis, and a pointer to **`Doc/Manual/Extending.html` §40.12** as the per node attribute reference. Read before any non-trivial parse tree inspection or compiler debugging.
- **`.agents/skills/swig-doc/SKILL.md`** — editing chapters under `Doc/Manual/`: heading anchor conventions, the four content `<div>` classes (`code` / `targetlang` / `shell` / `diagram`), cross document anchored links, and the `make maketoc check` cycle. Read before any change to `Doc/Manual/*.html`.

`.github/skills/` (GitHub Copilot's discovery path) and `.claude/skills/` (Claude Code's discovery path) hold tracked symlinks that point at the same files, so each tool's auto discovery works without duplicating content. On Windows a contributor needs `git config --global core.symlinks true` for the symlinks to materialise as real links rather than text files.

## What is SWIG

SWIG is a compiler that reads C/C++ header files and interface files (`.i`) and generates wrapper code that makes C/C++ libraries accessible from other languages: Python, Java, C#, Go, Ruby, Perl, PHP, Lua, Tcl, R, Guile, D, Octave, Scilab, OCaml, and XML output.

Project home: https://www.swig.org

## Build

SWIG uses GNU Autotools. Building from a git checkout requires extra steps vs. a release tarball (see https://swig.org/svn.html):

```bash
./autogen.sh          # generate configure (git checkout only)
./configure
make
```

Key configure options:
- `--prefix=/path` — install location
- `--without-pcre` — disable PCRE2 dependency

The built executable is `./swig` at the repo root. The test suite and examples invoke `./preinst-swig` instead — a thin wrapper that sets `SWIG_LIB=./Lib` so tests run against the just-built binary without needing `make install`.

A `CMakeLists.txt` is also provided as an alternative build system, but Autotools is the primary path used by CI and the test suite.

`CCache/` builds `ccache-swig` (a SWIG-specific ccache fork). It's built by default; `make check` runs `check-ccache` as part of the suite.

## Code Formatting

```bash
make format-check     # check formatting (requires clang-format 18+)
make format-inplace   # apply formatting
```

Format config: `Source/.clang-format` (Google style, 160 column limit).

## Testing

```bash
make -k check                          # full test suite, keep going on errors
make check-python-test-suite           # all tests for one language
make -j8 check-java-test-suite         # parallel execution

cd Examples/test-suite/python
make -s ret_by_value.cpptest           # single C++ test (silent)
make -s ret_by_value.ctest             # single C test
make -s ret_by_value.multicpptest      # single multi module test
make -s ret_by_value.clean             # clean generated files
```

Test suffixes match source type: `.cpptest` (C++), `.ctest` (C), `.multicpptest` (multiple C++ modules).

Available language test targets: `c`, `csharp`, `d`, `go`, `guile`, `java`, `javascript`, `lua`, `ocaml`, `octave`, `perl5`, `php`, `python`, `r`, `ruby`, `scilab`, `tcl`.

Bug fixes and new features should ideally land with a regression test in the test suite.

Test cases live in `Examples/test-suite/<language>/`. Each test consists of a `.i` interface file in `Examples/test-suite/` (shared across all languages) and an optional `<testname>_runme.<ext>` script in the language subdirectory. The `.i` file drives wrapper generation/compilation; the runme exercises the wrapped code at runtime — language-specific behavior belongs in the runme, not the shared `.i`.

The shared test makefile is `Examples/test-suite/common.mk` (included by each per-language Makefile). New tests are typically added to `common.mk` in the appropriate `*_TESTCASES` variable.

Python runmes must never use the `assert` statement - `python3 -O` strips asserts and the test would silently pass on a regression. Use the helpers in `Examples/test-suite/python/swig_test_utils.py` instead: `swig_check(lhs, rhs)` for equality checks (prints both values on failure), `swig_assert(condition, msg)` for arbitrary conditions, and `swig_assert_raises(exc_cls)` as a context manager for expected exceptions.

For test suite procedures (per language, single test, parallel runs, valgrind/gdb hooks via `SWIGTOOL` / `RUNTOOL`), use `.agents/skills/swig-test/SKILL.md` as the canonical reference rather than improvising from this summary.

## Architecture

SWIG processes input in this pipeline:

1. **Preprocessor** (`Source/Preprocessor/`) — C preprocessor pass over `.i` and header files
2. **Scanner** (`Source/Swig/scanner.c`) — lexical analysis
3. **Parser** (`Source/CParse/parser.y`) — Bison grammar producing a parse tree (DOH nodes)
4. **Type system** (`Source/Swig/typesys.c`, `typeobj.c`) — type resolution and equivalences
5. **Type passes** (`Source/Modules/typepass.cxx`) — tree-level analysis passes (directors, nested classes, etc.)
6. **Language module** (`Source/Modules/<lang>.cxx`) — walks the parse tree and emits wrapper code

### Key source directories

| Directory | Role |
|---|---|
| `Source/DOH/` | Data Object Hub — SWIG's internal object system for strings, lists, hashes, files |
| `Source/Swig/` | Core: type system, typemaps, symbol table, `cwrap.c` (C wrapper emission), scanner |
| `Source/CParse/` | C/C++ parser (`parser.y`), template instantiation (`templ.c`) |
| `Source/Preprocessor/` | SWIG's C preprocessor |
| `Source/Modules/` | Language backends + entry point (`main.cxx`) |
| `Lib/` | SWIG library: `.i`/`.swg` files included by interface files at runtime |

### Source/Modules key files

- `main.cxx` — entry point, command-line parsing, invokes the selected language module
- `swigmain.cxx` — dispatch table connecting `-python`, `-java`, etc. to module classes
- `lang.cxx` — base `Language` class that all backends inherit from
- `typepass.cxx` — post-parse tree passes run before language modules
- `directors.cxx` — director (C++ virtual method callback) shared logic
- `overload.cxx` — overloaded method dispatch code generation
- `allocate.cxx` — memory/ownership analysis

Each language backend (e.g., `python.cxx`, `java.cxx`) subclasses `Language` and overrides virtual methods like `functionWrapper()`, `classDeclaration()`, `variableWrapper()`.

### Parse tree

The parse tree is built from DOH nodes (hash-like objects). Key node attributes are documented in `Doc/Devel/tree.html`. The tree is walked by language modules using `Swig_symbol_*` and direct node traversal.

### Typemaps

Typemaps (defined in `Lib/*.swg` and user `.i` files) control how C/C++ types are converted to/from target language types. The typemap engine is in `Source/Swig/typemap.c`. The `%typemap` directive in interface files is the primary mechanism for customizing conversions.

### Template handling

C++ template instantiation is handled in `Source/CParse/templ.c`. Template specialization matching is a complex area — see `Source/Swig/typesys.c` for the type equivalence machinery.

### Parser is not reentrant

`Swig_cparse_parms()`, `Swig_cparse_type()` and the other entry points that wrap `yyparse()` clobber parser globals (`top`, `cparse_file`, `cparse_line`, `yylval`, `yychar`) and cannot be called from inside a parser action. Grammar that needs to build a `ParmList` for a fresh subsyntax must reuse the existing `parms` / `valparms` / `template_parms` productions natively (see how the C++20 `requires_expression` rule reuses `parms` for the requirement-parameter-list), not recurse through `Swig_cparse_parms()`.

### DOH

Almost every SWIG internal data structure is a DOH object. Common operations:

- `NewString(s)`, `NewStringf(fmt, ...)`, `Copy(obj)`, `Delete(obj)` — strings and lifetime
- `Getattr(node, "name")`, `Setattr(node, "name", val)` — parse tree node access (nodes are hashes)
- `Printf(out, fmt, ...)` where `out` may be a `String` or `File` — main emission primitive
- `Firstitem(list)` / `Nextitem(list)` — list iteration

See `Source/DOH/doh.h` for the full API and `Doc/Devel/internals.html` for design.

### Debugging SWIG itself

For debugging the SWIG compiler — gdb setup, the `swigprint`/`locswigprint` helpers in `Tools/swig.gdb`, the full `-debug-*` flag list, the four stage processing model, `SWIGTOOL`/`RUNTOOL`/`SWIG_FEATURES` test suite hooks, XML parse tree dumps, and `DOH_DEBUG_MEMORY_POOLS` for memory corruption diagnosis — read `.agents/skills/swig-debug/SKILL.md` rather than working from memory.

## Changelog

User visible changes (bug fixes, new features, behavior changes, deprecations) go in `CHANGES.current` for the in progress release. On release, those entries are appended to `CHANGES`. `RELEASENOTES` holds higher level per release summaries. Entry style: see existing entries for date/issue number format. Describe only what a user observes - new syntax, generated wrapper behaviour, warning/error messages - and leave internal helper names, refactors, and `Source/` symbols out. Purely internal changes do not get a `CHANGES.current` entry.

## Disclosing AI assistance in source code contributions

Any contribution produced with significant AI assistance to the SWIG source under the `Source/` or `Lib/` directories should disclose it in the commit message via an `Assisted-by:` trailer naming the tool/model. For example:

```
Assisted-by: Claude Code (Opus 4.7)
```

Place the trailer in the standard Git trailer block at the bottom of the commit message, alongside any `Signed-off-by:` lines. "Significant" means AI was used to generate, design, or substantially edit the code in the commit; trivial completions (single-line autocompletes, name suggestions, formatting) do not need disclosure.

Do **not** add a `Co-Authored-By:` trailer for an AI tool or model. AI agents are not authors and hold no copyright in their output, so coauthorship attribution is inappropriate. Use only the `Assisted-by:` trailer described above.

Disclosure is optional for other areas of the codebase such as the test suite (`Examples/test-suite/`) and the documentation (`Doc/`).

AI-assisted commit messages should be clear, concise and to the point - describe the change accurately without padding or marketing language.

## Comment style

In source code comments under `Source/` and `Lib/`, prefer single quotes (`'`) or double quotes (`"`) when quoting a token, identifier, keyword, or short snippet. Do not use backticks (`` ` ``) - they are a Markdown convention and have no meaning in C/C++ comments. For example, write `'requires' keyword` or `"concept Name = expr;"`, not the backtick wrapped form.

For all code everywhere, aim for comment lines around 120 characters wide. If wrapping at 120 leaves a stub second line, stretch the first line up to the 160 characters permitted by `clang-format` and keep the comment on one line, or rebalance so both lines carry meaningful content.

## `parser.y` formatting (new code)

`Source/CParse/parser.y` is a long lived Bison file with a mix of historical conventions. For **new code** added to it, follow the same conventions used in `.c` and `.cxx` files:

- Indent with spaces only - do not introduce tabs in any new lines (existing tab indented context lines may be left alone).
- Write comments the way they are written in C/C++ source.

A future cleanup pass will run `clang-format` over `parser.y` to normalise the file as a whole; until then, contributors should keep new additions consistent with the wider Source/ style.

## Developer Documentation

- `Doc/Devel/internals.html` — SWIG internals (DOH, parse tree, type system)
- `Doc/Devel/engineering.html` — engineering guidelines
- `Doc/Devel/tree.html` — parse tree node attributes
- `Doc/Manual/Extending.html` — guide to extending SWIG, adding a new target language, and the test suite

Useful background for contributors: C API design, the C++ type system, and SWIG's typemap mechanism. Adding a new target language follows the recipe in `Doc/Manual/Extending.html`.

### Authoring the user manual

For editing chapters under `Doc/Manual/` — chapter conventions, manual heading anchors (always use `<filebase>_topic`-style anchors, never the auto generated `_nnN`), the `code` / `targetlang` / `shell` / `diagram` `<div>` classes, link/anchor rules, and the `make maketoc check` cycle that renumbers headings and validates HTML — read `.agents/skills/swig-doc/SKILL.md` rather than working from memory.
