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

static char cvsroot[] = "$Header$";

/***********************************************************************
 * $Header$
 *
 * swigmain.cxx
 *
 * The main program.
 *
 ***********************************************************************/

#include "swigconfig.h"
#include "mod11.h"
#include "tcl8.h"
#include "perl5.h"
#include "java.h"
#include "python.h"
#include "guile.h"
#include "mzscheme.h"

#include <ctype.h>

#ifndef SWIG_LANG
#define SWIG_LANG PYTHON
#endif

static char  *usage = (char*)"\
swig <options> filename\n\n\
Target Language Options:\n\
     -tcl            - Generate Tcl wrappers.\n\
     -python         - Generate Python wrappers.\n\
     -perl5          - Generate Perl5 wrappers.\n\
     -java           - Generate Java wrappers.\n\
     -guile          - Generate Guile wrappers.\n\
     -mzscheme       - Generate Mzscheme wrappers.\n";

//-----------------------------------------------------------------
// main()
//
// Main program.    Initializes the files and starts the parser.
//-----------------------------------------------------------------


int main(int argc, char **argv) {
  int i;
  Language *dl = new SWIG_LANG;
  extern int SWIG_main(int, char **, Language *);
  Swig_init_args(argc,argv);

  // Get options
  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if(strcmp(argv[i],"-tcl") == 0) {
	      fprintf(stderr,"swig: -tcl option now implies -tcl8\n");
	      dl = new TCL8;
	      Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-tcl8") == 0) {
	      dl = new TCL8;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-perl5") == 0) {
	      dl = new PERL5;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-python") == 0) {
	      dl = new PYTHON;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-guile") == 0) {
	      dl = new GUILE;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-java") == 0) {
	      dl = new JAVA;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-mzscheme") == 0) {
	      dl = new MZSCHEME;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	      fputs(usage,stderr);
	      Swig_mark_arg(i);
	  }
      }
  }
  return SWIG_main(argc,argv,dl);
}
