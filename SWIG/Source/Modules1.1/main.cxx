/* -----------------------------------------------------------------------------
 * main.cxx
 *
 *     Main entry point to the SWIG core.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "swig11.h"
#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
extern "C" {
#include "preprocessor.h"
}

#ifndef SWIG_LANG
#define SWIG_LANG PYTHON
#endif

#include "tcl8.h"
#include "python.h"
#include "perl5.h"
#include "guile.h"
#ifdef OLD
#include "java.h"
#endif
#include "mzscheme.h"
#include "ruby.h"
#include "xml.h"

// Global variables

    FILE      *f_runtime = 0;
    DOH       *f_header = 0;                        // Some commonly used
    DOH       *f_wrappers = 0;                      // FILE pointers
    DOH       *f_init = 0;
    Language  *lang;                            // Language method
    int        CPlusPlus = 0;
    int        NewObject = 0;                   // NewObject flag
    int        ForceExtern = 0;                 // Force extern mode
    int        GenerateDefault = 0;            // Generate default constructors
    int        NoInclude = 0;
    int        Verbose = 0;
    String     *swig_module = 0;

static char *usage = (char*)"\
\nSWIG1.1 Options\n\
";

// -----------------------------------------------------------------------------
// check_suffix(char *name)
//
// Checks the suffix of a file to see if we should emit extern declarations.
// -----------------------------------------------------------------------------

static
int
check_suffix(char *name) {
  char *c;
  if (!name) return 0;
  if (strlen(name) == 0) return 0;
  c = name+strlen(name)-1;
  while (c != name) {
    if (*c == '.') break;
    c--;
  }
  if (c == name) return 0;
  if ((strcmp(c,".c") == 0) ||
      (strcmp(c,".C") == 0) ||
      (strcmp(c,".cc") == 0) ||
      (strcmp(c,".cxx") == 0) ||
      (strcmp(c,".c++") == 0) ||
      (strcmp(c,".cpp") == 0)) {
    return 1;
  }
  return 0;
}

//-----------------------------------------------------------------
// main()
//
// Main program.    Initializes the files and starts the parser.
//-----------------------------------------------------------------

char  infilename[256];
char  filename[256];
char  output_dir[512];
char  fn_runtime[256];
static char *outfile_name = 0;

char *SwigLib;

extern "C"
int swig11_init(int argc, char *argv[]) {
  int    i;
  char   *c;
  char    infile[512];
  int     help = 0;

  lang = new SWIG_LANG;
  f_wrappers = 0;
  f_init = 0;
  f_header = 0;

  // Get options
  for (i = 1; i < argc; i++) {
    if (argv[i]) {
      if(strcmp(argv[i],"-tcl") == 0) {
	fprintf(stderr,"swig: -tcl option now implies -tcl8\n");
	lang = new TCL8;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-tcl8") == 0) {
	lang = new TCL8;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-python") == 0) {
	lang = new PYTHON;
	Swig_mark_arg(i);

      } else if (strcmp(argv[i],"-perl5") == 0) {
	lang = new PERL5;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-guile") == 0) {
	lang = new GUILE;
	Swig_mark_arg(i);
#ifdef OLD
      } else if (strcmp(argv[i],"-java") == 0) {
	lang = new JAVA;
	Swig_mark_arg(i);
#endif
      } else if (strcmp(argv[i],"-mzscheme") == 0) {
	lang = new MZSCHEME;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-ruby") == 0) {
	lang = new RUBY;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-help") == 0) {
	fputs(usage,stderr);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-c++") == 0) {
	CPlusPlus=1;
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-c") == 0) {
	NoInclude=1;
	Preprocessor_define((void *) "SWIG_NOINCLUDE 1", 0);
	Swig_mark_arg(i);
      } else if (strcmp(argv[i],"-make_default") == 0) {
	GenerateDefault = 1;
	Swig_mark_arg(i);
      } else if(strcmp(argv[i],"-module") == 0) {
	if (argv[i+1]) {
	  swig_module = NewString(argv[i+1]);
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	} else {
	  Swig_arg_error();
	}
      } else if (strcmp(argv[i],"-o") == 0) {
	if (argv[i+1]) {
	  outfile_name = argv[i+1];
	  Swig_mark_arg(i);
	  Swig_mark_arg(i+1);
	  i++;
	}
      } else if (strcmp(argv[i],"-help") == 0) {
	fputs(usage,stderr);
	Swig_mark_arg(i);
	help = 1;
      }
    }
  }
  // Parse language dependent options
  lang->parse_args(argc,argv);

  if (help) return 0;

  // Create names of temporary files that are created
  sprintf(infilename,"%s", argv[argc-1]);

  // Check the suffix for a .c file.  If so, we're going to
  // declare everything we see as "extern"

  ForceExtern = check_suffix(infilename);
  // Strip off suffix

  c = infilename + strlen(infilename);
  while (c != infilename) {
    if (*c == '.') {
      *c = 0;
      break;
    } else {
      c--;
    }
  }
  if (!outfile_name) {
    char *cc = infilename + strlen(infilename);
    while (cc != infilename) {
      if (*cc == '/') {
	cc++;
	break;
      }
      cc--;
    }
    sprintf(fn_runtime,"%s_wrap.c",infilename);
    strcpy(infile,infilename);
    outfile_name = fn_runtime;
  } else {
    sprintf(fn_runtime,"%s",outfile_name);
  }
  {
    // Try to identify the output directory
    char *cc = outfile_name;
    char *lastc = outfile_name;
    while (*cc) {
      if (*cc == '/') lastc = cc+1;
      cc++;
    }
    cc = outfile_name;
    char *dd = output_dir;
    while (cc != lastc) {
      *dd = *cc;
      dd++;
      cc++;
    }
    *dd = 0;
    // Patch up the input filename
    cc = infilename + strlen(infilename);
    while (cc != infilename) {
      if (*cc == '/') {
	cc++;
	break;
      }
      cc--;
    }
    strcpy(infile,cc);
  }
  return 0;
}


extern  void  generate(DOH *top);

extern "C"
DOH *swig11_run(DOH *node) {
  if ((f_runtime = fopen(fn_runtime,"w")) == 0) {
    fprintf(stderr,"Unable to open %s\n", fn_runtime);
    Swig_exit(1);
  }
  f_header = NewString("");
  f_wrappers = NewString("");
  f_init = NewString("");

  Swig_register_filebyname("header",f_header);
  Swig_register_filebyname("runtime", f_runtime);
  Swig_register_filebyname("wrapper", f_wrappers);
  Swig_register_filebyname("init", f_init);

  // Set up the typemap for handling new return strings
  if (CPlusPlus)
    Swig_typemap_register((char*)"newfree",(char*)"p.char",(char*)"",(char*)"delete [] $source;\n",0);
  else
    Swig_typemap_register((char*)"newfree",(char*)"p.char",(char*)"",(char*)"free($source);\n",0);

  generate(node);

  Dump(f_header,f_runtime);
  Dump(f_wrappers, f_runtime);
  Wrapper_pretty_print(f_init,f_runtime);
  fclose(f_runtime);
  return node;
}

extern "C"
void swig11module() {
  Swig_register_module("tcl8","swig:top", swig11_init, swig11_run);
  Swig_register_module("python","swig:top", swig11_init, swig11_run);
  Swig_register_module("perl5","swig:top", swig11_init, swig11_run);
  Swig_register_module("ruby","swig:top", swig11_init, swig11_run);
  Swig_register_module("guile","swig:top", swig11_init, swig11_run);
  Swig_register_module("mzscheme","swig:top", swig11_init, swig11_run);
  Swig_register_module("swig11","swig:top", swig11_init, swig11_run);
  Swig_register_module("xml","swig:top", xml_init, xml_run);
}
