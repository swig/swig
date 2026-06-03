# Local reproduction of the GitHub Actions Linux CI environment.
#
# Mirrors the ubuntu-22.04 GHA runner closely enough to reproduce failures that
# only show up in CI: it reuses the real CI install scripts (Tools/CI-linux-*.sh)
# to install the same toolchain and target-language runtime that the workflow
# does, so the image stays in sync with .github/workflows/linux.yml.
#
# Parameterised by SWIGLANG / VER (defaults reproduce the ruby 3.3 job, the
# motivating case for issue #3385). Build with Tools/ci-repro/run.sh, which
# auto-detects podman or docker. The SWIG sources are NOT baked in - they are
# bind mounted at run time so the image builds your working tree.
#
# Example:
#   Tools/ci-repro/run.sh build                  # ruby 3.3 (default)
#   Tools/ci-repro/run.sh --lang ruby --ver 3.4 build

FROM ubuntu:22.04

ARG SWIGLANG=ruby
ARG VER=3.3
# Match the swig user to the host uid/gid (run.sh passes these) so a bind
# mounted source tree is writable and autogen output is owned by the caller.
ARG HOST_UID=1000
ARG HOST_GID=1000
ENV DEBIAN_FRONTEND=noninteractive

# Base toolchain the CI scripts assume is already present on the runner image.
# pcre2-config (libpcre2-dev) is what configure needs; the CI scripts add their
# own per language packages on top of this.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential autoconf automake libtool bison \
        libpcre2-dev pkg-config \
        git curl wget ca-certificates gnupg2 software-properties-common \
        file procps sudo \
    && rm -rf /var/lib/apt/lists/*

# Reproduce the non-root, passwordless-sudo user that GHA runs jobs as, so RVM /
# NVM and friends install under $HOME exactly as they do in CI.
RUN groupadd -g "$HOST_GID" swig 2>/dev/null || true; \
    useradd -m -s /bin/bash -u "$HOST_UID" -g "$HOST_GID" swig \
    && echo 'swig ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/swig \
    && chmod 0440 /etc/sudoers.d/swig
USER swig
WORKDIR /home/swig

# Run the real CI install scripts. They expect the GHA helper functions and
# variables: GITHUB_ENV / GITHUB_PATH receive the exported env / PATH additions,
# and with RUNNER_TOOL_CACHE unset probe_cached_tool falls through to a fresh
# install (e.g. RVM builds Ruby $VER from source, just like the workflow).
COPY --chown=swig:swig CI-linux-install.sh GHA-linux-install.sh CI-linux-environment.sh ci/
RUN set -eux; \
    export SWIGLANG="$SWIGLANG" VER="$VER" \
           GITHUB_ENV="$HOME/gha_env" GITHUB_PATH="$HOME/gha_path"; \
    : > "$GITHUB_ENV"; : > "$GITHUB_PATH"; \
    bash "$HOME/ci/GHA-linux-install.sh"; \
    # Make the freshly installed Ruby the default so 'ruby' resolves to $VER in
    # every later shell (RVM does not set a default on first install).
    if [ "$SWIGLANG" = ruby ]; then \
        bash -lc "source \$HOME/.rvm/scripts/rvm && rvm --default use $VER && ruby -v"; \
    fi

# entrypoint.sh reconstructs the CI environment (RVM + the GITHUB_ENV/PATH the
# install wrote) before exec'ing the command, the way GHA does between steps.
# Build context is Tools/, so this lives under ci-repro/ (see run.sh).
COPY --chown=swig:swig ci-repro/entrypoint.sh /home/swig/entrypoint.sh
RUN chmod +x /home/swig/entrypoint.sh

ENV SWIGLANG=${SWIGLANG} VER=${VER}
WORKDIR /swig
ENTRYPOINT ["/home/swig/entrypoint.sh"]
CMD ["bash"]
