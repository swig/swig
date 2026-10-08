# ===========================================================================
#  https://www.gnu.org/software/autoconf-archive/ax_prog_bison_version.html
# ===========================================================================
#
# SYNOPSIS
#
#   AX_PROG_BISON_VERSION([VERSION],[ACTION-IF-TRUE],[ACTION-IF-FALSE])
#
# DESCRIPTION
#
#   Makes sure that bison version is greater or equal to the version
#   indicated. If true the shell commands in ACTION-IF-TRUE are executed. If
#   not the shell commands in commands in ACTION-IF-TRUE are executed. If
#   not the shell commands in ACTION-IF-FALSE are run. Note if $BISON is not
#   set (for example by running AC_CHECK_PROG or AC_PATH_PROG) the macro
#   will fail.
#
#   Example:
#
#     AC_PATH_PROG([BISON],[bison])
#     AX_PROG_BISON_VERSION([3.0.2],[ ... ],[ ... ])
#
#   This will check to make sure that the bison you have is at least version
#   3.0.2 or greater.
#
#   The version extracted from "$BISON --version" may have any number of
#   dot-separated components, for example both of these are handled:
#
#     bison (GNU Bison) 2.3
#     bison (GNU Bison) 3.8.2
#
#   NOTE: This macro uses the $BISON variable to perform the check.
#
# LICENSE
#
#   Copyright (c) 2015 Jonathan Rajotte-Julien <jonathan.rajotte-julien@efficios.com>
#
#   Copying and distribution of this file, with or without modification, are
#   permitted in any medium without royalty provided the copyright notice
#   and this notice are preserved. This file is offered as-is, without any
#   warranty.

#serial 3

AC_DEFUN([AX_PROG_BISON_VERSION],[
    AC_REQUIRE([AC_PROG_SED])
    AC_REQUIRE([AC_PROG_GREP])

    AS_IF([test -n "$BISON"],[
        ax_bison_version="$1"

        AC_MSG_CHECKING([for bison version])
        changequote(<<,>>)
        bison_version=`$BISON --version 2>&1 \
          | $SED -n -e '/bison (GNU Bison)/b inspect
b
: inspect
s/.* (\{0,1\}\([0-9]\{1,\}\(\.[0-9]\{1,\}\)\{1,2\}\))\{0,1\}.*/\1/;p'`
        changequote([,])
        AC_MSG_RESULT($bison_version)

	AC_SUBST([BISON_VERSION],[$bison_version])

        AX_COMPARE_VERSION([$bison_version],[ge],[$ax_bison_version],[
	    :
            $2
        ],[
	    :
            $3
        ])
    ],[
        AC_MSG_WARN([could not find bison])
        $3
    ])
])
