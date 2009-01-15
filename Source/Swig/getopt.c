/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * getopt.c
 *
 * Handles the parsing of command line options.  This is particularly nasty
 * compared to other utilities given that command line options can potentially
 * be read by many different modules within SWIG.  Thus, in order to make sure
 * there are no unrecognized options, each module is required to "mark"
 * the options that it uses.  Afterwards, we can make a quick scan to make
 * sure there are no unmarked options.
 * 
 * TODO: 
 *     - This module needs to be modified so that it doesn't call exit().
 *       Should have cleaner error handling in general.
 * ----------------------------------------------------------------------------- */

char cvsroot_getopt_c[] = "$Id$";

#include "swig.h"

static char **args;
static int numargs;
static int *marked;

/* -----------------------------------------------------------------------------
 * Swig_init_args()
 * 
 * Initialize the argument list handler.
 * ----------------------------------------------------------------------------- */

void Swig_init_args(int argc, char **argv) {
  int i;
  assert(argc > 0);
  assert(argv);

  numargs = argc;
  args = argv;
  marked = (int *) malloc(numargs * sizeof(int));
  for (i = 0; i < argc; i++) {
    marked[i] = 0;
  }
  marked[0] = 1;
}

/* -----------------------------------------------------------------------------
 * Swig_mark_arg()
 * 
 * Marks an argument as being parsed.
 * ----------------------------------------------------------------------------- */

void Swig_mark_arg(int n) {
  assert(marked);
  assert((n >= 0) && (n < numargs));
  marked[n] = 1;
}

/* -----------------------------------------------------------------------------
 * Swig_check_marked()
 *
 * Checks to see if argument has been picked up.
 * ----------------------------------------------------------------------------- */

int Swig_check_marked(int n) {
  assert((n >= 0) && (n < numargs));
  return marked[n];
}

/* -----------------------------------------------------------------------------
 * Swig_check_options()
 * 
 * Checkers for unprocessed command line options and errors.
 * ----------------------------------------------------------------------------- */

void Swig_check_options(int check_input) {
  int error = 0;
  int i;
  int max = check_input ? numargs - 1 : numargs;
  assert(marked);
  for (i = 1; i < max; i++) {
    if (!marked[i]) {
      Printf(stderr, "swig error : Unrecognized option %s\n", args[i]);
      error = 1;
    }
  }
  if (error) {
    Printf(stderr, "Use 'swig -help' for available options.\n");
    exit(1);
  }
  if (check_input && marked[numargs - 1]) {
    Printf(stderr, "Must specify an input file. Use -help for available options.\n");
    exit(1);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_arg_error()
 * 
 * Generates a generic error message and exits.
 * ----------------------------------------------------------------------------- */

void Swig_arg_error(void) {
  Printf(stderr, "SWIG : Unable to parse command line options.\n");
  Printf(stderr, "Use 'swig -help' for available options.\n");
  exit(1);
}
