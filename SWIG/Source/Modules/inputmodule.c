/* ----------------------------------------------------------------------------- 
 * inputmodule.c
 *
 *     This module is responsible for reading input files and setting up all
 *     of the proper search paths.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "swigconfig.h"

#ifndef SWIG_LIB
#define SWIG_LIB "./swiglib"
#endif

static int      checkout = 0;
static List    *includedirs;
static List    *libfiles;
static String  *outfile = 0;
static int      debug_path = 0;
static int      debug_input = 0;

static const char *usage = "File options:\n\
     -I<dir>         - Look for SWIG files in <dir>\n\
     -l<ifile>       - Include SWIG library file.\n\
     -o outfile      - Set name of the output file.\n\
     -co             - Check file out of SWIG library.\n\
";

static 
int input_init(int argc, char **argv) {
  char *c;
  int   i;

  /* Directories included with the -I option */
  includedirs = NewList();

  /* Files added with the -l option */
  libfiles     = NewList();

  /* Look for command line options */
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strncmp(argv[i],"-I",2) == 0) {
	Append(includedirs,argv[i]+2);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-debug_path") == 0) {
	debug_path = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-debug_input") == 0) {
	debug_input = 1;
	Swig_mark_arg(i);
      } else if (strncmp(argv[i],"-l",2) == 0) {
	Append(libfiles, argv[i]+2);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-co") == 0) {
	checkout = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-o") == 0) {
	Swig_mark_arg(i);
	if (argv[i+1]) {
	  outfile = NewString(argv[i+1]);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-help") == 0) {
	Printf(stderr,"%s",usage);
	Swig_mark_arg(i);
      }
    }
  }
  /* Set the location of the SWIG library */
  if (!(c = getenv("SWIG_LIB"))) {
    Append(includedirs,SWIG_LIB);
  } else {
    Append(includedirs,c);
  }
  return 0;
}

static
DOH *input_run(DOH *node) {
  int      i;
  String  *infile;
  FILE    *f;
  String  *input;
  DOH     *result;
  String  *swiglib;
  String  *lang_config;

  infile = Getname(node); 

  /* Register all of the include directories */
  swiglib = Swig_swiglib_get();
  for (i = Len(includedirs); i > 0; i--) {
    if (swiglib) {
      String *l = NewStringf("%s%s%s", Getitem(includedirs,i-1),SWIG_FILE_DELIMETER,swiglib);
      Swig_add_directory(l);
    }
    Swig_add_directory(Getitem(includedirs,i-1));
  }

  if (debug_path) {
    List *l;
    Printf(stdout,"SWIG search path:\n");
    l = Swig_search_path();
    if (l) {
      String *s;
      for (s = Firstitem(l); s; s = Nextitem(l)) {
	Printf(stdout,"     %s\n", s);
      }
    }
  }

  /* user has requested to simply check out a file */
  if (checkout) {
    String *outfilename;
    String *s;
    outfilename = outfile ? outfile : infile;

    /* Grab the file */
    s = Swig_include(infile);
    if (!s) {
      Printf(stderr,"Unable to locate '%s' in the SWIG library.\n", infile);
      Swig_exit(EXIT_FAILURE);
    } else {
      File *f = NewFile(outfilename,"r");
      if (f) {
	Delete(f);
	Printf(stderr,"File '%s' already exists. Checkout aborted.\n", outfilename);
      } else {
	f = NewFile(outfilename,"w");
	if (!f) {
	  Printf(stderr,"Unable to create file '%s'\n", outfilename);
	} else {
	  Printf(stderr,"'%s' checked out from the SWIG library.\n", infile);
	  Dump(s,f);
	  Delete(f);
	}
      }
    }
    return 0;
  }

  /* Try to find input files */
  f = Swig_open(infile);
  if (!f) {
    Printf(stderr,"Unable to find '%s'\n", infile);
    Swig_exit (EXIT_FAILURE);
  }
  fclose(f);
  input = NewString("%include \"swig.swg\"\n");
  lang_config = Swig_get_config_file();
  if (lang_config) {
    Printf(input,"\n%%include \"%s\"\n", lang_config);
  }
  Printf(input,"\n%%include \"%s\"\n", infile);
  for (i = 0; i < Len(libfiles); i++) {
    Printf(input,"\n%%include \"%s\"\n", Getitem(libfiles,i));
  }
  result = NewHash();
  Settag(result,"swig:input");
  Setattr(result,"name", infile);
  Setattr(result,"path", Getfile(input));
  Setattr(result,"outfile", outfile);
  Setattr(result,"data",input);
  Setattr(result,"last",node);

  if (debug_input) {
    Printf(stdout,"::: inputmodule :::\n");
    Printf(stdout,"%s\n", input);
  }
  return result;
}

void inputmodule() {
  Swig_register_module("input","swig:initial", input_init, input_run);
}


