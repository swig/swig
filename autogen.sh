#! /bin/sh
# Bootstrap the development environment

set -x
autoheader
autoconf
(cd Tools; autoconf)
