---
name: swig-test
description: 'Run SWIG test suite for specific languages. Use when testing SWIG changes, verifying language support, debugging test failures, or running regression tests.'
argument-hint: 'Specify language (e.g., python, java) and optionally a single test name'
---

# SWIG Test Running

## When to Use
- Testing changes to SWIG core or language modules
- Verifying support for a target language
- Debugging test failures
- Running regression tests

## Procedure for All Tests in a Language
1. Ensure SWIG is built: Run `make` in the root directory.
2. Run all tests for a language: Execute `make check-[language]-test-suite` (e.g., `make check-python-test-suite`).
3. For parallel execution: Use `make -j[n] check-[language]-test-suite` to speed up on multi core systems that have n cores.
4. Review output for pass/fail status and any warnings.

## Procedure for Single Test
1. Navigate to the language test directory: `cd Examples/test-suite/[language]/`
2. Run a specific test: `make -s [testcase].cpptest` (for C++), `make -s [testcase].ctest` (for C), or `make -s [testcase].multicpptest` (for multi module).
3. Example: `make -s ret_by_value.cpptest`
4. For verbose output: Remove `-s` flag.
5. Clean up: `make -s [testcase].clean`

## Procedure for One Test Across Every Configured Language
**Whenever you add a new testcase or modify an existing one, the final
confidence step is to run it across every configured language**, not just the
one or two you developed against. This applies equally to a brand new test and
to any change to an existing test: a testcase that passes in Python can still
fail (or warn) in Java, Ruby, Go, and the rest, so this all-language run is what
tells you the added or modified test actually works everywhere. Make it the last
thing you do before considering the test complete.

Run it for *all* the target languages this build was configured for (which may
be a subset of the full language list, as determined by `./configure`). Use the
helper script in this skill:

```
.agents/skills/swig-test/test-configured-languages.sh [options] TARGET [extra make args...]
```

`TARGET` is the test-suite make target including its suffix, e.g.
`cpp11_alias_templates.cpptest` (C++), `li_cdata.ctest` (C), or
`imports.multicpptest` (multi module). Run it from anywhere inside the source
tree; it locates the repo root and reads the configured language set from the
generated top-level `Makefile` (a language is enabled when its
`skip-<lang> = test -n ""` marker is empty), so it never runs a language that
`./configure` disabled.

To match CI, each language is built with the same warning flags the GitHub
Actions Linux workflow uses: the script runs `Tools/testflags.py` per language
and passes the resulting `CFLAGS`/`CXXFLAGS` (which include `-Werror` plus a
per-language warning set) to `make`, exactly as `.github/workflows/linux.yml`
does. The C++ standard is auto-detected from a `cppNN_` test name prefix
(`cpp11_` -> `c++11`, `cpp17_` -> `c++17`, ...) and defaults to `c++17`
otherwise; the C standard is derived from it as CI does. Override with
`--std c++20`, or use `--no-flags` to run plain `make` without the strict flags.

Examples:
```
# every configured language, serial, clean summary
.agents/skills/swig-test/test-configured-languages.sh cpp11_alias_templates.cpptest

# 4 languages in parallel
.agents/skills/swig-test/test-configured-languages.sh -j 4 bools.cpptest

# skip the experimental C backend and Go
.agents/skills/swig-test/test-configured-languages.sh -x "c go" template_basic.cpptest

# only these languages
.agents/skills/swig-test/test-configured-languages.sh -o python,java li_std_vector.cpptest

# just show which languages would run
.agents/skills/swig-test/test-configured-languages.sh --list
```

Key options: `-l/--list`, `-o/--only LANGS`, `-x/--exclude LANGS`,
`-j/--jobs N`, `--std CPPSTD`, `--cstd CSTD`, `--compiler gcc|clang`,
`--engine node|jsc|v8`, `-n/--no-flags`, `-v/--verbose`, `-s/--stop` (stop at
first failure, serial only), `-h/--help`. It does not abort on the first failure
(unless `-s`): each language is reported PASS/FAIL and a final summary lists the
failures. Exit status is the number of languages that failed. Note the
experimental `c` backend has known failing tests, so `-x c` is often useful.

For `javascript` the script picks the engine automatically, following the
javascript test Makefile's own precedence (node, then jsc, then v8) but only
choosing node when its test toolchain is actually present - node-gyp builds the
wrapper and the Makefile runs `npm config get prefix`, so a missing `npm` makes
the node engine fail. When node is not usable it falls back to the configured
`jsc`/`v8` engine, which is what passing `ENGINE=jsc` to `make` by hand used to
work around. Override with `--engine jsc` (or just pass `ENGINE=jsc` as an extra
make arg, which the script leaves untouched).

### No warnings allowed
A passing test is not enough: an added or modified test must also produce **no
warnings**, from either SWIG or the C/C++ compiler, in any language. Because the script
applies CI's `-Werror` flags by default, a compiler warning on the generated
wrapper automatically turns into a build failure, so a clean all-language run
already proves the wrapper compiles warning free everywhere. SWIG warnings
(e.g. `Warning 4xx: ...`) are printed rather than fatal, so still watch for
them - they usually mean the interface is not being wrapped as intended. Run
with `-v/--verbose` to see the full SWIG and compiler output:

```
.agents/skills/swig-test/test-configured-languages.sh -v mytest.cpptest 2>&1 | grep -iE "warning|error"
```

If a warning is expected and legitimate for the testcase, suppress or assert on
it the usual way (e.g. `%warnfilter`, or the test's expected-warnings
mechanism) rather than leaving it in the output. The goal is a clean run -
no failures and no stray warnings - across every configured language.

### A failure in one target language is a defect to fix, not to exclude
When a core change or a new/modified test makes a test fail in one of the target
languages, the fix is in **that target language**, not in the test's coverage:
either correct the language module (`Source/Modules/<lang>.cxx`) or add a
target-language workaround (a language-specific typemap / `%feature` /
`%dmethodmodifiers`-style override in the `.i`, a per-language runme, or library
code) so the test passes there too. A change is not finished while it leaves any
configured language broken.

If the failure is a known language-module bug that is too fundamental to fix as
part of the current change, the accepted workaround is to guard just the
offending construct in the shared `.i` with `#if !defined(SWIG<LANG>)` (e.g.
`#if !defined(SWIGD)`) and a `// TODO` comment naming the bug, so the test still
builds and runs for that language with the unsupported part omitted - see
`using_member_multiple_inherit.i`'s `MultBottomA`, guarded out of D with
`// TODO: Fix bug adding incorrect override`. Prefer the real module fix; reach
for the guard only when deferring it, and keep the omitted surface as small as
possible (a single class/method, not the whole module).

Do **not** reach for the `FAILING_<LANG>_TESTS` lists in
`Examples/test-suite/<lang>/Makefile.in` to make the suite green. Those lists are
only for long-standing, documented limitations of a language's *paradigm* (for
example D's single-inheritance model excluding `using_composition`). They are not
a place to silence a regression or a new failure your change introduced -
excluding a test there hides the defect instead of fixing it. If you believe a
failure is genuinely a fundamental language limitation rather than a fixable bug,
stop and confirm with the maintainer before adding an exclusion.

The one exception is an **experimental backend** (e.g. the experimental `c`
target, which already has known failing tests - hence the frequent `-x c`). A
production language must be fixed or worked around as above, but when only an
experimental backend fails it is fine to simply exclude the test by adding it to
that language's `FAILING_<LANG>_TESTS` list in
`Examples/test-suite/<lang>/Makefile.in`, rather than fixing the experimental
module.

### Report what was run
When you finish, report:
- the test case name(s) and which target languages passed (and any that were
  excluded, e.g. `-x c` or a `FAILING_<LANG>_TESTS` entry, so coverage is clear);
- any target-language-specific handling the test case now carries - a
  `%warnfilter`, a guarded `%ignore` / typemap / `%feature` /
  `#if defined(SWIG<LANG>)` block, a per-language runme, etc. - and which
  language each was added for and why.

This makes it explicit what was actually verified and what the test now does
differently per language.

## Writing test interfaces
- Do not collapse a class or struct definition onto a single line in a `.i` test case. Put the body members on their own lines, as you would in real source:

  ```c++
  struct A {
    int g() { return 1; }
  };
  ```

  rather than `struct A { int g() { return 1; } };`.
- Keep comments in test cases brief (see AGENTS.md).

## Notes
- Tests can take significant time; always specify the language clearly.
- Check Doc/Manual/Extending.html for more details on the test suite.
