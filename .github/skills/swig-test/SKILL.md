---
name: swig-test
description: 'Run SWIG test-suite for specific languages. Use when testing SWIG changes, verifying language support, debugging test failures, or running regression tests.'
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
3. For parallel execution: Use `make -j[n] check-[language]-test-suite` to speed up on multi-core systems that have n cores.
4. Review output for pass/fail status and any warnings.

## Procedure for Single Test
1. Navigate to the language test directory: `cd Examples/test-suite/[language]/`
2. Run a specific test: `make -s [testcase].cpptest` (for C++), `make -s [testcase].ctest` (for C), or `make -s [testcase].multicpptest` (for multi-module).
3. Example: `make -s ret_by_value.cpptest`
4. For verbose output: Remove `-s` flag.
5. Clean up: `make -s [testcase].clean`

## Notes
- Tests can take significant time; always specify the language clearly.
- Check Doc/Manual/Extending.html for more details on test-suite.
