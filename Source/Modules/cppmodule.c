/* ----------------------------------------------------------------------------- 
 * cppmodule.c
 *
 *     This module is responsible for running the SWIG preprocessor module.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "swigconfig.h"
#include "preprocessor.h"

static int      cpp_only = 0;

static const char *usage = "Preprocessor options:\n\
     -E              - Run the preprocessor only\n\
     -Dmacro         - Define a new macro\n\
";

static 
int preprocessor_init(int argc, char **argv) {
  int   i;
  /* Look for command line options */
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-E") == 0) {
	cpp_only = 1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-c++") == 0) {
	Preprocessor_define("__cplusplus 1", 0);
	Swig_mark_arg(i);
      } else if (strncmp(argv[i],"-D",2) == 0) {
	DOH *d = NewString(argv[i]+2);
	Replace(d,"="," ", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
	Preprocessor_define(d,0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-includeall") == 0) {
	Preprocessor_include_all(1);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-help") == 0) {
	Printf(stderr,"%s",usage);
	Swig_mark_arg(i);
      }
    }
  }
  return 0;
}

static
DOH *preprocessor_run(DOH *node) {
  String  *cpps, *data;
  DOH     *result;

  data = Getattr(node,"data");
  if (!data) {
    Printf(stderr,"SWIG: preprocessor error. no data.\n");
    Swig_exit(1);
  }

  Preprocessor_define("SWIG 1", 0);
  Preprocessor_define("__STDC__ 1", 0);
#ifdef MACSWIG
  Preprocessor_define("SWIGMAC 1", 0);
#endif
#ifdef SWIGWIN32
  Preprocessor_define("SWIGWIN32 1", 0);
#endif

  Seek(data,0, SEEK_SET);
  cpps = Preprocessor_parse(data);
  if (cpp_only) {
    Printf(stdout,"%s", cpps);
    return 0;
  }

  result = NewHash();
  Settag(result,"swig:preprocess");
  Setfile(cpps,Getfile(data));
  Setline(cpps,Getline(data));
  Seek(cpps,0,SEEK_SET);
  Setattr(result,"data",cpps);
  Setattr(result,"last",node);
  return result;
}

void preprocessormodule() {
  Swig_register_module("preprocessor","swig:input", preprocessor_init, preprocessor_run);
  Preprocessor_init();
}
