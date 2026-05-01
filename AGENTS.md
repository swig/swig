# AGENTS.md

This file provides guidance to AI agents such as Claude Code (claude.ai/code) when working with code in this repository.

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

The built executable is `./swig` at the repo root. The test-suite and examples invoke `./preinst-swig` instead — a thin wrapper that sets `SWIG_LIB=./Lib` so tests run against the just-built binary without needing `make install`.

A `CMakeLists.txt` is also provided as an alternative build system, but Autotools is the primary path used by CI and the test-suite.

`CCache/` builds `ccache-swig` (a SWIG-specific ccache fork). It's built by default; `make check` runs `check-ccache` as part of the suite.

## Code Formatting

```bash
make format-check     # check formatting (requires clang-format 18+)
make format-inplace   # apply formatting
```

Format config: `Source/.clang-format` (Google style, 160 column limit).

## Testing

```bash
make -k check                          # full test-suite, keep going on errors
make check-python-test-suite           # all tests for one language
make -j8 check-java-test-suite         # parallel execution

cd Examples/test-suite/python
make -s ret_by_value.cpptest           # single C++ test (silent)
make -s ret_by_value.ctest             # single C test
make -s ret_by_value.multicpptest      # single multi-module test
make -s ret_by_value.clean             # clean generated files
```

Test suffixes match source type: `.cpptest` (C++), `.ctest` (C), `.multicpptest` (multiple C++ modules).

Available language test targets: `c`, `csharp`, `d`, `go`, `guile`, `java`, `javascript`, `lua`, `ocaml`, `octave`, `perl5`, `php`, `python`, `r`, `ruby`, `scilab`, `tcl`.

Bug fixes and new features should ideally land with a regression test in the test-suite.

Test cases live in `Examples/test-suite/<language>/`. Each test consists of a `.i` interface file in `Examples/test-suite/` (shared across all languages) and an optional `<testname>_runme.<ext>` script in the language subdirectory. The `.i` file drives wrapper generation/compilation; the runme exercises the wrapped code at runtime — language-specific behavior belongs in the runme, not the shared `.i`.

The shared test makefile is `Examples/test-suite/common.mk` (included by each per-language Makefile). New tests are typically added to `common.mk` in the appropriate `*_TESTCASES` variable.

Related skills under `.github/skills/`:
- `swig-test/SKILL.md` — running the test-suite for a target language and individual testcases
- `swig-debug/SKILL.md` — debugging the SWIG compiler itself: `-debug-*` flags, parse-tree dumps, gdb, valgrind, and memory-pool diagnostics
- `swig-doc/SKILL.md` — authoring and editing the user manual under `Doc/Manual/`: chapter conventions, manual heading anchors, content `<div>` classes, and the `make maketoc check` cycle

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

### DOH

Almost every SWIG internal data structure is a DOH object. Common operations:

- `NewString(s)`, `NewStringf(fmt, ...)`, `Copy(obj)`, `Delete(obj)` — strings and lifetime
- `Getattr(node, "name")`, `Setattr(node, "name", val)` — parse-tree node access (nodes are hashes)
- `Printf(out, fmt, ...)` where `out` may be a `String` or `File` — main emission primitive
- `Firstitem(list)` / `Nextitem(list)` — list iteration

See `Source/DOH/doh.h` for the full API and `Doc/Devel/internals.html` for design.

### Debugging SWIG itself

For debugging the SWIG compiler — gdb setup, the `swigprint`/`locswigprint` helpers in `Tools/swig.gdb`, the full `-debug-*` flag list, the four-stage processing model, `SWIGTOOL`/`RUNTOOL`/`SWIG_FEATURES` test-suite hooks, XML parse-tree dumps, and `DOH_DEBUG_MEMORY_POOLS` for memory-corruption diagnosis — see `.github/skills/swig-debug/SKILL.md`.

## Changelog

User-visible changes (bug fixes, new features, behavior changes, deprecations) go in `CHANGES.current` for the in-progress release. On release, those entries are appended to `CHANGES`. `RELEASENOTES` holds higher-level per-release summaries. Entry style: see existing entries for date/issue-number format.

## Developer Documentation

- `Doc/Devel/internals.html` — SWIG internals (DOH, parse tree, type system)
- `Doc/Devel/engineering.html` — engineering guidelines
- `Doc/Devel/tree.html` — parse tree node attributes
- `Doc/Manual/Extending.html` — guide to extending SWIG, adding a new target language, and the test-suite

Useful background for contributors: C API design, the C++ type system, and SWIG's typemap mechanism. Adding a new target language follows the recipe in `Doc/Manual/Extending.html`.

### Authoring the user manual

For editing chapters under `Doc/Manual/` — chapter conventions, manual heading anchors (always use `<filebase>_topic`-style anchors, never the auto-generated `_nnN`), the `code` / `targetlang` / `shell` / `diagram` `<div>` classes, link/anchor rules, and the `make maketoc check` cycle that renumbers headings and validates HTML — see `.github/skills/swig-doc/SKILL.md`.
