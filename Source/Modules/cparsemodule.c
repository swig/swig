/* ----------------------------------------------------------------------------- 
 * cparsemodule.c
 *
 *     This module is responsible for running the SWIG C Parsing module.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

#include "swig.h"
#include "swigconfig.h"
#include "lparse.h"

static const char *usage = "C Parsing options:\n\
";

static 
int cparse_init(int argc, char **argv) {
  int   i;
  /* Look for command line options */
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if (strcmp(argv[i],"-c++") == 0) {
	LParse_cplusplus(1);
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
DOH *cparse_run(DOH *node) {
  String  *data;
  DOH     *result;

  data = Getattr(node,"data");
  if (!data) {
    Printf(stderr,"SWIG: cparse error. no data.\n");
    Swig_exit(1);
  }
  Seek(data,0, SEEK_SET);
  result = LParse_parse(data);
  Setattr(result,"last",node);
  return result;
}

void cparsemodule() {
  Swig_register_module("cparse","swig:preprocess", cparse_init, cparse_run);
}
