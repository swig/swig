---
name: swig-debug
description: 'Debug the SWIG compiler itself: -debug-* command-line flags, parse-tree dumps (text and XML), gdb with the swigprint/locswigprint helpers from Tools/swig.gdb, valgrind via the SWIGTOOL/RUNTOOL test-suite hooks, and DOH_DEBUG_MEMORY_POOLS for memory-corruption diagnosis.'
argument-hint: 'Optionally specify the .i interface file and language target to debug'
---

# Debugging the SWIG compiler

## When to Use
- Investigating a SWIG crash or assertion (segfault, abort, internal error)
- Understanding why a parse-tree node has unexpected attributes
- Tracing template instantiation, typemap selection, or symbol-table resolution
- Diagnosing DOH memory-corruption / use-after-free problems

## Why DOH needs special handling
All DOH types (`String *`, `SwigType *`, `Hash *`, `List *`, `Node *`, etc.) are typedefined to `void`, so debuggers cannot inspect them automatically. Use SWIG's print helpers — never raw `print` on a DOH pointer.

See `Doc/Devel/internals.html` section 7 ("Debugging SWIG") for the authoritative reference.

## Setup

1. Build SWIG with debug symbols and no optimisation:
   ```bash
   ./configure CFLAGS='-g -O0' CXXFLAGS='-g -O0'
   make
   ```
2. Load `Tools/swig.gdb` into your gdb session. Either add to `~/.gdbinit`:
   ```
   source /path/to/swig/Tools/swig.gdb
   ```
   or `source` it interactively each session. This defines `swigprint` and `locswigprint`.
3. Confirm helpers are loaded: `(gdb) show user` lists them; `(gdb) help swigprint` shows usage.

## Running SWIG under gdb

The test suite invokes `./preinst-swig` (which sets `SWIG_LIB=./Lib`). To debug the actual binary, run the underlying `./swig` directly with the same args, or set the env var manually:

```bash
gdb --args ./swig -python -c++ -I./Lib -outdir /tmp Examples/test-suite/foo.i
(gdb) set environment SWIG_LIB=./Lib
(gdb) run
```

To capture the exact command a test uses, run the test once with verbose output and copy the swig invocation:
```bash
cd Examples/test-suite/python
make foo.cpptest    # without -s, so commands are printed
```

### Running the test suite under tools

The shared `Examples/test-suite/common.mk` exposes two hook variables that wrap stages of the test pipeline:

- `SWIGTOOL` — wraps the SWIG invocation itself
- `RUNTOOL` — wraps the runtime test execution (the language interpreter)

**The make target suffix must match the test source type — getting it wrong silently runs nothing or the wrong recipe.** Use:

- `.cpptest` for C++ tests (the `.i` uses C++ — most tests in `Examples/test-suite/`)
- `.ctest` for plain C tests
- `.multicpptest` for multi-module C++ tests (testcase split across multiple `.i` files)

There is no auto-detection; check the testcase to see which it is. Examples below pick the right suffix for `ret_by_value` (a C test):

```bash
# gdb on a single SWIG invocation
make ret_by_value.ctest SWIGTOOL="gdb --args"

# valgrind the runtime test
make ret_by_value.ctest RUNTOOL="valgrind --leak-check=full"

# valgrind SWIG itself (needs DOH_DEBUG_MEMORY_POOLS rebuild — see Memory section)
make ret_by_value.ctest SWIGTOOL="valgrind --tool=memcheck --trace-children=yes"

# gdb on the runtime side
make ret_by_value.ctest RUNTOOL="gdb --args"
```

For a C++ testcase the same calls would use `.cpptest` (e.g. `make bools.cpptest SWIGTOOL="gdb --args"`); for a multi-module testcase, `.multicpptest` (e.g. `make imports.multicpptest`). `make <testcase>.clean` (same suffix rules) removes generated files.

### Adding flags via `SWIG_FEATURES`

`SWIG_FEATURES` is an environment variable read by SWIG and merged with command-line options. Useful to inject `-debug-*` flags into a test or the whole suite without editing makefiles:

```bash
make ret_by_value.ctest SWIG_FEATURES="-debug-tmsearch"
env SWIG_FEATURES=-O make check-python-test-suite
```

## Inspecting parse-tree nodes

The most common debugging task. Set a breakpoint in the language module's wrapper entry point and `swigprint` the node:

```
(gdb) break JAVA::functionWrapper
(gdb) run
Breakpoint 1, JAVA::functionWrapper (this=0x..., n=0xb7d2afc8) at Modules/java.cxx:799
(gdb) swigprint n
Hash(0xb7d2afc8) {
  'name' : x,
  'sym:name' : Shape_x_set,
  'nodeType' : cdecl,
  'type' : void,
  ...
}
```

`swigprint` accepts:
- a DOH variable: `swigprint symname`
- a raw address: `swigprint 0xb7cb9408`
- an optional second arg controlling Hash nesting depth (default 1): `swigprint n 2`

Collapsed Hashes appear as `Hash(0x...) {......}`; the dot count equals the number of attributes.

`locswigprint` is identical but prefixes the output with the source file/line where the node originated:
```
(gdb) locswigprint 0xb7cb9408
example.h:11: [Hash(0xb7cb9408) { ... }]
```

**Tip**: gdb command-completes user-defined commands, so `sw` / `loc` are sufficient prefixes.

## Common breakpoints

| Goal | Breakpoint |
|---|---|
| Wrapper emission per declaration | `<LANG>::functionWrapper`, e.g. `PYTHON::functionWrapper` |
| Class emission | `<LANG>::classHandler` |
| Template instantiation | functions in `Source/CParse/templ.c` (e.g. `Swig_cparse_template_expand`) |
| Type resolution | `SwigType_typedef_resolve`, `SwigType_str` in `Source/Swig/typesys.c` |
| Typemap lookup | `Swig_typemap_lookup`, `Swig_typemap_attach_parms` in `Source/Swig/typemap.c` |
| Symbol table | `Swig_symbol_*` in `Source/Swig/symbol.c` |

## Calling print functions from instrumented code

If gdb cannot call into the binary (optimised build, release distro, awkward environment), insert calls to the print family directly in the SWIG source and recompile. The functions are listed under "Debugging Functions" in `Doc/Devel/tree.html`. `Swig_print_node(n)`, `Swig_print_tree(n)`, and `Printf(stdout, "%s\n", obj)` are the most useful.

## Try `-debug-*` first

The built-in command-line flags often answer the question without needing gdb at all. Full list (from `Doc/Manual/Extending.html` §40.11):

| Flag | Purpose |
|---|---|
| `-debug-tags` | Display the tag of every parse-tree node (one line each) — quick structural overview |
| `-debug-top <n>` | Dump the entire parse tree at stage `<n>` (CSV list of stages 1–4) |
| `-debug-module <n>` | Dump only the user module's subtree at stage `<n>` (skips system files — much smaller) |
| `-debug-quiet` | Suppress noisy linked-list / symbol-table pointer fields when dumping (combine with the two above) |
| `-debug-classes` | Information about classes found in the interface |
| `-debug-symtabs` | Symbol-table contents |
| `-debug-symbols` | Target-language symbols in the symbol tables |
| `-debug-csymbols` | C symbols in the symbol tables |
| `-debug-lsymbols` | Target-language-layer symbols |
| `-debug-template` | Template instantiation tracing |
| `-debug-typedef` | Types and typedefs in the interface |
| `-debug-typemap` | Typemap-engine internals |
| `-debug-tmsearch` | Typemap search trace (which lookup keys were tried) |
| `-debug-tmused` | Which typemap was actually applied at each site |

`./swig -help` prints the canonical list.

### The four processing stages

`-debug-top <n>` and `-debug-module <n>` accept stages 1–4. Stages roughly correspond to: 1 = post-parse raw tree, 2 = after type passes, 3 = after target-language-independent transforms, 4 = after the target-language module has finished (this is the final tree). `-debug-top 4` or the equivalent `-xmlout` is the right choice to see what the language module actually saw.

Conflicts and overload diagnostics are reported against `sym:name` values, which is why `sym:name` shows up so prominently in these dumps.

Recommended starting incantations:
```bash
./swig -c++ -python -debug-tags example.i                    # structural skeleton
./swig -c++ -python -debug-module 1 -debug-quiet example.i   # user-module tree, post-parse
./swig -c++ -python -debug-top 4 -debug-quiet example.i      # final tree, all stages applied
```

### Preprocessor dump

`swig -E interface.i` writes the post-preprocessor text that SWIG hands to its C++ parser (analogous to `gcc -E`). Useful for seeing how `%include`, macros, and `%define` expanded before parsing — often the first thing to check when a declaration is "missing" from the parse tree.

### XML dump

The parse tree can also be serialised as XML. Three modes (from `Extending.html` §40.4.4):

```bash
swig -python -c++ -xmlout out.xml  example.i   # final tree (~ -debug-top 4), with target-language processing
swig -xml      -o out.xml          example.i   # tree without any target language (~ -debug-top 3)
swig -xml -xmllite -o out.xml      example.i   # same, but skips typescope / typetab nodes (smaller)
```

XML output is bigger than `-debug-top` but easier to grep, diff, and post-process. Format is unstable across SWIG versions.

### `%feature` attributes

`%feature` directives attach as attributes in the `feature:` namespace on matching nodes. To see what features are stuck where, dump the final tree and grep for `feature:` — `-debug-top 4 -debug-quiet` is the usual incantation.

### `errors` test-suite

A dedicated suite under `Examples/test-suite/errors/` tests SWIG's warning and error messages themselves. Run with `make check-errors-test-suite`. Mechanism is documented in `Examples/test-suite/errors/Makefile.in` — useful if you're changing diagnostic output or adding a new warning.

## DOH inspection without the helpers

If `swigprint` is unavailable (e.g. core dump on a stripped binary), DOH objects can be cast manually. Compile with optimisations off first or these casts may fail:

- `String *s` → `(*(struct String *)(((DohBase *)s)->data)).str`
- `SwigType *t` → `(*(struct String *)(((DohBase *)t)->data)).str`
- `const_String_or_char_ptr sc` → either the `String *` cast above or `(char *)sc`, depending on which it actually is

These give you the underlying C string. Anything more structured (Hash contents, List items) is far easier with the helpers.

## Memory corruption

DOH uses reference counting and an internal pool allocator (`Source/DOH/memory.c`), so stale-pointer bugs do not show up under valgrind by default — the pool keeps freed memory mapped and reused.

To catch use-after-free of DOH objects:
1. Define `DOH_DEBUG_MEMORY_POOLS` in `Source/DOH/memory.c`.
2. Rebuild SWIG.
3. Re-run under valgrind. Stale DOH usage now triggers `Fatal internal error: Attempt to delete a non-DOH object.` instead of silently succeeding.

Memory-intensive — only enable while diagnosing.

## Notes
- Always build `-g -O0` before debugging; optimised inlining destroys most DOH casts.
- `make` after editing source — the test suite uses `./preinst-swig`, which calls the freshly built `./swig`, so no install is needed.
- Authoritative references:
  - `Doc/Devel/internals.html` §7 — debugging SWIG, DOH casts, memory pools
  - `Doc/Devel/tree.html` — parse-tree node attributes and the "Debugging Functions" list
  - `Doc/Manual/Extending.html` §40.4.3 (parse trees), §40.10 (test-suite tooling: `SWIGTOOL`/`RUNTOOL`/`SWIG_FEATURES`/valgrind/gdb), §40.11 (`-debug-*` options), §40.12 (per-node attribute reference)
  - `Tools/swig.gdb` — helper command definitions
