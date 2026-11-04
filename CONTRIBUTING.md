# Contributing to SWIG

SWIG is developed by volunteers and contributions are very welcome: bug fixes, new features, tests and documentation.
Contributions made with the help of AI tools are welcome too, see [Using AI tools](#using-ai-tools).
This page explains how to get a change accepted without using up the maintainers' time or the project's shared CI.

Ask questions in [GitHub Discussions](https://github.com/swig/swig/discussions) or on the
[swig-devel mailing list](https://www.swig.org/mail.html). Report a bug as a [GitHub issue](https://github.com/swig/swig/issues)
with a small, complete test case that shows it.

## Before you start

- Search the issues and pull requests in case the problem is already known or being worked on.
- The [milestones](https://github.com/swig/swig/milestones) page lists the next few planned releases. Ask for an issue to be
  added to a milestone if you would like it considered for that release.
- For a large change, or a change to the SWIG core, open an issue or discussion first.

## Building SWIG from git

Fork [swig/swig](https://github.com/swig/swig) on GitHub, then build from your fork:

```
git clone https://github.com/<your-account>/swig.git
cd swig
./autogen.sh
./configure
make
```

[swig.org/svn.html](https://swig.org/svn.html) lists the tools needed. The wiki's
[Getting Started](https://github.com/swig/swig/wiki/Getting-Started) page lists the packages to install for each target
language on popular operating systems.

Use the git hooks in `Tools/git-hooks`: the pre-commit hook checks the formatting of the C/C++ source with clang-format
and the commit-msg hook checks the commit message rules below. Run this once in your clone:

```
git config core.hooksPath Tools/git-hooks
```

The setting applies to every git worktree of the clone and each worktree uses the hooks in its own checkout. Git then
ignores any hooks in `.git/hooks`. If you have hooks of your own there, copy the SWIG hooks into `.git/hooks` instead.
See [Coding style guidelines](Doc/Manual/Extending.html#Extending_coding_style_guidelines) for more on the hooks and
clang-format.

## Making a change

- Keep a pull request to one topic. Follow the style of the surrounding code and do not reformat unrelated code.
- Add a regression test for a bug fix or new feature, see
  [the test suite](Doc/Manual/Extending.html#Extending_test_suite).
- Add an entry to `CHANGES.current` for any change users will notice, in the style of the existing entries.
- Update the manual in `Doc/Manual` for new features. It is hand written HTML; run `make maketoc check` in `Doc/Manual`
  after editing it.
- [AGENTS.md](AGENTS.md) and the skills in [.agents/skills](.agents/skills) are written for AI agents, but they are also
  the most complete description of SWIG's development conventions. They are worth reading without an AI tool too.

## Testing

Run the tests that match what you changed before opening a pull request:

| You changed | Run at least |
|---|---|
| Anything in `Source` | `make format-check` |
| One target language | `make check-<lang>-test-suite` and `make check-<lang>-examples` |
| A test case | that test case in every language you have installed, see `.agents/skills/swig-test/SKILL.md` |
| The core: the parser, type system, typemaps or `Lib` files shared by all languages | The full test suite and a comparison of the generated code, see below |

A change to the core needs the full test suite of every target language, not just the languages you work with. Run the
test suites locally for as many target languages as you can install, never just one. CI on your fork then runs the
rest.

Also compare the code SWIG generates before and after a core change. `make partialcheck-test-suite` runs SWIG over the
test suite of every target language without compiling or running anything. Run it in the same checkout without your
change and then with it, keeping a copy of `Examples/test-suite` after each run. Compare the copies with `diff -r`.
Examine every difference and make sure you understand why it is correct. On its own, partialcheck only shows whether
SWIG fails, so it is no substitute for running the test suites. `.agents/skills/swig-contribute/SKILL.md` has more
detail.

## CI etiquette

Each push to a pull request runs about 200 jobs on the GitHub Actions resources that the whole project shares. The
maintainers have to wait for them before merging anything else. Please:

1. **Run CI on your own fork first.** Enable GitHub Actions once in the Actions tab of your fork, push your branch there
   and open the pull request when it passes. It costs you nothing for a public fork.
2. **Check that [master is green](https://github.com/swig/swig/actions?query=branch%3Amaster)** before opening a
   pull request or pushing to one. If master is failing, your pull request will fail too.
3. **Batch your fixes into one push.** Except for a few developers on the exclusion list described below, a newer push
   to the same pull request cancels the CI run of the older one.
4. **Do not push just to fix a commit message,** such as a missing `Assisted-by:` line. Put the correct line in the pull
   request description and the maintainer fixes the commit when merging. A commit with `[skip ci]` in its message
   starts no CI run.

Regular contributors who want every push tested in full can ask the maintainers to add them to the list of users whose
runs are never cancelled, at the top of each workflow file in `.github/workflows`. If a test fails only in the Linux CI,
`Tools/ci-repro` can reproduce the CI environment in a container, see `.agents/skills/swig-ci-repro/SKILL.md`.

## Commit messages

- Write plain text with a short subject line. Do not use backticks; quote code with `'` or `"` if needed.
- Refer to issues and pull requests as #NNNN.
- The maintainer usually squashes a pull request into one commit. Say so in the pull request if the commits should be
  kept as they are.

## Using AI tools

AI assisted contributions are welcome, in line with projects such as LLVM, the Linux kernel, Fedora and the Apache
Software Foundation. The rules are:

- **You are the author.** You are responsible for every line of the change. You must understand it well enough to
  explain it and to answer review questions yourself.
- **Disclose significant AI assistance** with an `Assisted-by:` trailer at the end of the commit message, in exactly
  this form: `Assisted-by: Claude Code (Opus 4.8)`, that is the tool followed by the model in parentheses, with no email
  or context size. It is required for changes under `Source` or `Lib` and optional elsewhere. Significant means the tool
  generated, designed or substantially edited the change, not just completed a line.
- **Never add a `Co-authored-by:` line for an AI tool.** Copyright requires a human author, so an AI tool is not a
  coauthor. Many tools add such a line by default; turn it off.
- **If you make the commit yourself, add the trailer yourself.** If you forget, give the line in the pull request
  description rather than pushing again.
- **Write the pull request description and your replies to review comments yourself,** or at least check every claim in
  them. Reviewers need to talk to the person who understands the change.
- **Do not let an agent act on swig/swig for you.** It must not push to swig/swig, or open or comment on its pull requests
  and issues, without your review.

Point your tool at [AGENTS.md](AGENTS.md), which starts with the rules an agent must follow. The
[AI Assisted Development](https://github.com/swig/swig/wiki/AI-Assisted-Development) wiki page has setup tips for
particular tools, such as how to make each one read AGENTS.md and stop adding a `Co-authored-by:` line.

## Opening a pull request

Fill in the pull request template. It asks what the change does and why, which issue it fixes and what you tested,
with a link to the green CI run on your fork. It also asks for the `Assisted-by:` line if you used AI tools. The
maintainers are volunteers, so please be patient while waiting for a review. A pull request that is not ready for
review may be closed, see [Quality of contributions](#quality-of-contributions).

## Quality of contributions

The most capable AI tools can produce excellent contributions to SWIG. Less capable tools and AI models, or any tool used without
care, tend to produce changes that look plausible but are wrong, untested, far larger than the problem needs or not
understood by the person submitting them. Reviewing such a change takes a maintainer much longer than generating it
took. SWIG is maintained by a few volunteers, so their time is the project's most limited resource.

A pull request that is not ready for review may therefore be closed with a link to this section. This is not a judgement
of you the author or of the idea behind the change. It only means that the change needs more work before a maintainer can review
it. Common reasons are:

- it does not build, or the tests fail;
- there is no regression test, or the test does not show the problem being fixed;
- it changes much more than the problem needs, or mixes several unrelated changes;
- the change is just too quirky, non-conventional, hacky or lacks a wider understanding of the SWIG code base or how SWIG works;
- the description does not match the change, or the code refers to things that do not exist in SWIG;
- review questions are answered with generated text that does not address them.

To take your change forward:

1. Reduce it to one problem and its fix, with a regression test in `Examples/test-suite`.
2. Run the tests described in [Testing](#testing) until they pass, then run CI on your fork.
3. Read the whole change and make sure you understand every part of it. If you use an AI tool, a frontier model
   working from [AGENTS.md](AGENTS.md) makes a big difference.
4. Open a new pull request and describe in your own words what the change does and how you tested it.

One small, well tested change is much easier to review and merge than a large one.

## More information

- [AGENTS.md](AGENTS.md) and [.agents/skills](.agents/skills): development conventions, testing, debugging and the manual
- [Extending SWIG](Doc/Manual/Extending.html): SWIG internals, the test suite and adding a target language
- [The SWIG documentation](https://www.swig.org/doc.html): the manual for each release, online
- [Doc/Devel](Doc/Devel/index.html): SWIG internals and its internal APIs
- [The SWIG wiki](https://github.com/swig/swig/wiki)
