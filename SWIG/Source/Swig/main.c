/* ----------------------------------------------------------------------------- 
 * main.c
 *
 *     SWIG main program.   
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swigconfig.h"
#include "swigver.h"
#include "swig.h"

static char *usage = (char*)"\
\nGeneral Options\n\
     -version        - Print SWIG version number\n\
     -help           - This output.\n\n";

/* -----------------------------------------------------------------------------
 * Swig_main()
 *
 * Entry point to SWIG.  This should only be called after all of the available
 * modules have been registered (presumably by the real main function).
 * ----------------------------------------------------------------------------- */

int Swig_main(int argc, char **argv, char **modules) {
  int   i;
  int   help = 0;
  int   freeze = 0;
  Hash   *top = 0;

  /* Initialize the SWIG core */
  Swig_init();
  Swig_init_args(argc,argv);

  /* Look for command line options */
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-freeze") == 0) {
	freeze= 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-version") == 0) {
	fprintf(stderr,"\nSWIG Version %s %s\n",
		SWIG_VERSION, SWIG_SPIN);
	fprintf(stderr,"Copyright (c) 1995-1998, University of Utah and the Regents of the University of California\n");
	fprintf(stderr,"Copyright (c) 1998-2000, University of Chicago\n");
	Swig_exit (EXIT_SUCCESS);
      } else if (strcmp(argv[i],"-help") == 0) {
	Printf(stderr,"%s",usage);
	Swig_mark_arg(i);
	help = 1;
      } else {
	if (!Swig_check_marked(i)) {
	  Module *m;
	  m = Swig_load_module(argv[i]+1);
	  if (m) {
	    Swig_mark_arg(i);
	    Swig_init_module(m, argc, argv);
	  }
	}
      }
    }
  }

  /* Load the default modules (always enabled) */
  if (modules) {
    int i = 0;
    while (modules[i]) {
      Module *m;
      m = Swig_load_module(modules[i]);
      if (m) {
	Swig_init_module(m,argc,argv);
      } else {
	Printf(stderr,"Swig: default module '%s' not found!\n", modules[i]);
      }
      i++;
    }
  }

  if (help) Swig_exit(EXIT_SUCCESS);
  /* Check the arguments */
  Swig_check_options();

  /* Get the input file name and create a starting node */
  top = NewHash();
  Settag(top,"swig:initial");
  Setname(top,argv[argc-1]);

  /* Run the modules */
  Swig_run_modules(top);

  while(freeze);
  return 0;
}

void Swig_exit(int n) {
  exit(n);
}



