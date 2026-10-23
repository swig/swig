---
name: swig-ci-repro
description: 'Reproduce a GitHub Actions Linux CI failure locally when it does not happen on your machine: a podman/docker image that mirrors the ubuntu-22.04 runner by reusing the real Tools/CI-linux-*.sh install scripts, parameterised by target language and version. Covers the helper Tools/ci-repro/run.sh, the act fallback, and a worked Ruby 3.3 example.'
argument-hint: 'Optionally specify the failing language and version, e.g. ruby 3.3'
---

# Reproducing GitHub Actions Linux CI failures locally

## When to use
- A test or build passes locally but fails only on the GHA Linux runner.
- The failure depends on a language runtime or version you do not have installed (the apt
  package differs from what CI builds - e.g. CI builds Ruby 3.3 from source via RVM, apt ships 3.2).
- You need an interactive shell in a CI-equivalent environment to run gdb or valgrind.

Linux jobs only. macOS and Windows runners cannot be containerised - for those, re-run the job with
a debug session, use a self hosted runner, or a local VM.

## How GHA Linux jobs are defined
- The matrix is in `.github/workflows/linux.yml`. Each entry sets `SWIGLANG`, `VER` and `CPPSTD`;
  jobs without an explicit `os` default to `ubuntu-22.04`. Find the matrix row that matches the
  failing job - that is the language and version to reproduce.
- Dependencies and the language runtime are installed by `Tools/GHA-linux-install.sh`, which sources
  `Tools/CI-linux-install.sh`. That script installs the compiler, `libpcre2`/boost, and the runtime
  (RVM for Ruby, NVM for Node, etc.).
- The build then runs out of tree: `./autogen.sh`, `configure --without-alllang --with-<lang>
  CXXFLAGS=-std=<cppstd>`, `make`, then `make check-<lang>-test-suite`.

## Primary: the reproduction container
`Tools/ci-repro/` builds an `ubuntu:22.04` image that runs the same CI install scripts, so it stays
in sync with the workflow. `Tools/ci-repro/run.sh` drives it and auto-detects podman (preferred,
rootless) or docker - override with `CONTAINER=docker`. Your working tree is bind mounted at `/swig`
and built out of tree in a named volume, so the host tree stays clean apart from autogen output.

```sh
Tools/ci-repro/run.sh build                 # build the image (RVM compiles Ruby 3.3 - slow, one off)
Tools/ci-repro/run.sh test li_std_functors  # run one test on the CI runtime
Tools/ci-repro/run.sh ci                     # full check-ruby-test-suite
Tools/ci-repro/run.sh shell                  # interactive shell, swig already built
```

Pick a different job with `--lang` / `--ver` / `--std`:

```sh
Tools/ci-repro/run.sh --lang ruby --ver 3.4 test li_std_functors
Tools/ci-repro/run.sh --lang python --ver 3.13 ci
```

Inside the `shell`, swig is built under `/home/swig/build`; debug it there with gdb or valgrind as
described in `.agents/skills/swig-debug/SKILL.md`. Editing the bind mounted sources and re-running
rebuilds incrementally.

## Secondary: act for full-matrix fidelity
To run the actual workflow YAML (closest to the real runner, but awkward to debug interactively) use
[nektos/act](https://github.com/nektos/act) with the catthehacker image, the de-facto Docker stand
in for the runner (GitHub's image is a Packer VM, not published as a container):

```sh
act -j build --matrix SWIGLANG:ruby --matrix VER:3.3 \
    -P ubuntu-22.04=catthehacker/ubuntu:act-22.04
```

To drive act with podman instead of docker, expose the podman socket first:

```sh
systemctl --user start podman.socket
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock
```

## Worked example: the Ruby 3.3 GC crash (issue #3385)
The `li_std_functors` segfault in `swig::SwigGCReferences::GC_register` only reproduced on the GHA
Ruby 3.3 runner. To reproduce and diagnose it:

```sh
Tools/ci-repro/run.sh --lang ruby --ver 3.3 build
Tools/ci-repro/run.sh --lang ruby --ver 3.3 shell
```

The crash is intermittent and GC timing dependent. In the shell, drive it harder than the test does:
run the runme in a loop with `GC.stress = true` and Ruby 3.x compaction (`GC.compact` or
`GC.auto_compact = true`), which surfaces a moved or freed `VALUE`. To capture what actually reaches
the crashing `rb_hash_aref(_hash, obj)` line, add a counter in `GC_register` for the type of `obj`
that passes the early-return guard (NIL_P / SPECIAL_CONST_P / T_NONE) and print
`rb_obj_classname(obj)` - this tells you whether the fault is a nil, a freed object, or a dangling
reference rather than guessing.

## Pointers
- Matrix and steps: `.github/workflows/linux.yml`
- Install logic this image reuses: `Tools/CI-linux-install.sh`, `Tools/GHA-linux-install.sh`,
  `Tools/CI-linux-environment.sh`
- The reproduction helper: `Tools/ci-repro/Dockerfile`, `Tools/ci-repro/run.sh`
- Debugging the built compiler: `.agents/skills/swig-debug/SKILL.md`
