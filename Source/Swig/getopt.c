/*******************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 *******************************************************************************/

#include "swigcore.h"

/*******************************************************************************
 * $Header$
 *
 * File : getopt.c
 *
 * Functions for handling command line arguments.  This is a little funky because
 * the arguments are checked in multiple places.
 *******************************************************************************/

static char **args;
static int    numargs;
static int   *marked;

/* -----------------------------------------------------------------------------
 * void SWIG_init_args(int argc, char **argv)
 * 
 * Initializes the argument list. 
 * ----------------------------------------------------------------------------- */

void
SWIG_init_args(int argc, char **argv)
{
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
 * void SWIG_mark_arg(int n)
 * 
 * Marks an argument as being parsed.  All modules should do this whenever they
 * parse a command line option.
 * ----------------------------------------------------------------------------- */

void
SWIG_mark_arg(int n) {
   assert(marked);
   assert((n >= 0) && (n < numargs)); 
   marked[n] = 1;
}

/* -----------------------------------------------------------------------------
 * void SWIG_check_options()
 * 
 * Checks for unparsed command line options.  If so, issues an error and exits.
 * ----------------------------------------------------------------------------- */
 
void SWIG_check_options() {
    int error = 0;
    int i;
    assert(marked);

    for (i = 1; i < numargs-1; i++) {
      if (!marked[i]) {
	Printf(stderr,"swig error : Unrecognized option %s\n", args[i]);
	error=1;
      }
    }
    if (error) {
      Printf(stderr,"Use 'swig -help' for available options.\n");
      exit(1);
    }
    if (marked[numargs-1]) {
      Printf(stderr,"Must specify an input file. Use -help for available options.\n");
      exit(1);
    }
}

/* -----------------------------------------------------------------------------
 * void SWIG_arg_error()
 * 
 * Generates a generic error message and exits.
 * ----------------------------------------------------------------------------- */

void SWIG_arg_error() {
  Printf(stderr,"SWIG : Unable to parse command line options.\n");
  Printf(stderr,"Use 'swig -help' for available options.\n");
  exit(1);
}


	
		


