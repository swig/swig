---
name: swig-contribute
description: 'Get a SWIG change ready to commit and submit: what to test for each kind of change, including comparing the generated code before and after a core change, commit message rules and the Assisted-by AI disclosure trailer, what to do when the human makes the commit, running CI on your own fork, CI etiquette and what goes in a pull request description. Use before any git commit, push or pull request, or when asked for a commit message or pull request description.'
---

# Contributing a SWIG Change

## When to use
- Before any `git commit`, `git push` or pull request
- When asked to write a commit message or a pull request description
- When deciding how much testing a change needs

The "Rules that always apply" at the top of `AGENTS.md` come first; this skill gives the details. `CONTRIBUTING.md` describes the same workflow for humans.

## What to test

Match the testing to what the change touches. Run every item that applies.

- **Anything under `Source/`:** `make format-check`. The clang-format CI jobs gate every other job.
- **A test case added or changed:** `.agents/skills/swig-test/test-configured-languages.sh <testcase>.<suffix>`
  (see swig-test).
- **One target language, `Lib/<lang>/` or `Source/Modules/<lang>.cxx`:** `make check-<lang>-test-suite` and
  `make check-<lang>-examples`.
- **Core:** `Source/CParse`, `Source/Swig`, `Source/Preprocessor`, `Source/DOH`, the `Source/Modules` files every
  language uses (such as `lang.cxx`, `typepass.cxx`, `overload.cxx`), shared `Lib/*.swg`, `Lib/std` and `Lib/typemaps`.
  Run `make -k check` with every target language you can install, compare the generated code before and after the
  change (below), then run CI on your fork.
- **A warning or error message:** `make check-errors-test-suite`, plus `Tools/checkwarnings.py` if a warning number
  changed (see swig-conventions).
- **`Doc/Manual` only:** `make maketoc check` in `Doc/Manual` (see swig-doc).

A core change needs the full test suite of every target language. `make -k check` covers only the languages
`./configure` found, so install as many target languages as you can and never test just one. CI on the contributor's
fork runs the rest. Add `-jN` to any of these to run in parallel.

JavaScript has several engines. When changing JavaScript, run `make check-javascript-test-suite ENGINE=<engine>` for
each of `node`, `napi`, `v8` and `jsc` that is installed.

For a core change, also compare the generated code before and after the change. `make partialcheck-test-suite` runs SWIG
over the test suite of every target language without compiling or running anything. On its own it only shows whether
SWIG fails, so it is no substitute for the test suites. In one checkout, so that paths in the generated code match:

1. Build SWIG without the change, run `make -k partialcheck-test-suite` and copy `Examples/test-suite` elsewhere.
2. Build SWIG with the change, run it again and make a second copy.
3. Compare the copies with `diff -r`. Examine every difference and make sure it is intended and correct.

Report the number of files compared and the files that differ.

When you finish, report the exact commands run, which languages passed and which were not tested. Never report a test as passing that you did not run.

## Commit messages

- Write the subject and body as plain text with a short subject line. Describe the change accurately, clearly and
  concisely, without padding or marketing language.
- Do not use backticks anywhere - they are a Markdown convention and have no meaning in `git log` or `git format-patch`.
  Quote code tokens, identifiers and file names with `'` or `"` if needed.
- Refer to issues and pull requests by their short form only: write #3474, not a full
  https://github.com/swig/swig/issues/3474 URL. GitHub renders #NNNN as a link.
- Stage files by explicit path, never with `git add -A` or `git add .`, as building and testing leave generated files in the source tree.

### The Assisted-by trailer

Many AI tools append a `Co-Authored-By:` line naming the tool to every commit message. **In this repository
that is wrong: remove it.** AI agents are not authors and hold no copyright in their output, so
coauthorship attribution is inappropriate.

Disclose significant AI assistance with one `Assisted-by:` trailer instead, in exactly this form:

```
Assisted-by: Claude Code (Opus 4.8)
```

That is the tool, a space and the model in parentheses. Do not append an `<email>`, a context size such as
`(1M context)` or anything else. Place the trailer in the standard Git trailer block at the bottom of the commit
message, alongside any `Signed-off-by:` lines.

"Significant" means AI was used to generate, design or substantially edit the change. Trivial completions
such as single line autocompletes, name suggestions or formatting do not need disclosure. The trailer is
required for changes under `Source/` or `Lib/` and optional elsewhere, such as the test suite
(`Examples/test-suite/`) and the documentation (`Doc/`).

The commit-msg hook in `Tools/git-hooks` rejects an AI `Co-authored-by:` line, backticks and an `Assisted-by:` line in
any other form. Never bypass it with `git commit --no-verify`.

### When the human makes the commit

Some contributors never let an agent commit. Then finish by giving the human:

- the complete commit message, subject, body and `Assisted-by:` trailer, ready to use;
- the files to stage, by explicit path;
- a reminder to fill in the AI assistance section of the pull request template.

## Before opening a pull request

- Each push to a swig/swig pull request starts about 200 CI jobs. Iterate on the contributor's own fork instead: enable
  GitHub Actions once in the fork's Actions tab, push the branch there and wait for a green run. Never push to
  swig/swig, or open or comment on its pull requests and issues, without the human's explicit approval.
- Base the branch on the latest master and check master is green, for example with
  `gh run list -R swig/swig -b master -L 4`. If master is red, a CI failure on the branch may not be the branch's fault.
- To debug a failure that only happens in Linux CI, see swig-ci-repro.
- Batch fixes into one push. Except for a few developers on the exclusion list in the workflow files, a newer push to
  the same pull request cancels the CI run of the older one.
- Do not push just to fix a commit message, such as a missing `Assisted-by:` line. Put the correct line in the
  pull request description instead; the maintainer fixes the commit when merging. A commit containing
  `[skip ci]` in its message starts no CI run.
- Keep a pull request to one topic. The maintainer usually squashes a pull request into one commit; say so in the description if the commits should be kept.
- A pull request that is not ready for review is closed, see "Quality of contributions" in `CONTRIBUTING.md`. Do not
  suggest opening one until the change is one topic with a regression test, passes the tests for its scope and the
  human has reviewed it.

## Pull request description

The template in `.github/pull_request_template.md` asks for:

- what the change does and why, with `Fixes #NNNN` if it fixes an issue;
- what was tested: the commands run and a link to the green CI run on the fork;
- whether a regression test and a `CHANGES.current` entry were added;
- the `Assisted-by:` line, if AI tools were used, with one sentence on what they did.

The human is responsible for the description and for answering review comments, as reviewers need to talk to the person
who understands the change. If asked to draft a description, keep it short and factual, list only tests that were
actually run and leave the human to check and post it.
