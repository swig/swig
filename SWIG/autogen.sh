#! /bin/sh
# Bootstrap the development environment
autoconf
autoheader
(cd Tools; autoconf)
