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

#include "internal.h"
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

#ifndef SWIG_LIB
#define SWIG_LIB "/usr/local/lib/swig1.3"
#endif

#ifndef SWIG_CC
#define SWIG_CC "CC"
#endif

// Global variables

    FILE      *f_runtime;
    DOH       *f_header;                        // Some commonly used
    DOH       *f_wrappers;                      // FILE pointers
    DOH       *f_init;
    FILE      *f_input;
    char      InitName[256];
    char      LibDir[512];                      // Library directory
    int       Status;
    Language  *lang;                            // Language method
    int        CPlusPlus = 0;
    int        ObjC = 0;
    int        ObjCClass = 0;
    int        AddMethods = 0;                  // AddMethods flag
    int        NewObject = 0;                   // NewObject flag
    int        Inline = 0;                      // Inline mode
    int        ForceExtern = 0;                 // Force extern mode
    int        WrapExtern = 0;
    int        GenerateDefault = 0;            // Generate default constructors
    char      *Config = 0;
    int        NoInclude = 0;

    int        error_count = 0;                 // Error count
    int        Verbose = 0;

class SwigException {};

static char *usage = (char*)"\
\nGeneral Options\n\
     -c              - Produce raw wrapper code (omit support code)\n\
     -c++            - Enable C++ processing\n\
     -co             - Check a file out of the SWIG library\n\
     -Dsymbol        - Define a symbol (for conditional compilation)\n\
     -I<dir>         - Look for SWIG files in <dir>\n\
     -includeall     - Follow all #include statements\n\
     -l<ifile>       - Include SWIG library file.\n\
     -make_default   - Create default constructors/destructors\n\
     -o outfile      - Set name of the output file.\n\
     -objc           - Enable Objective C processing\n\
     -swiglib        - Report location of SWIG library and exit\n\
     -v              - Run in verbose mode\n\
     -version        - Print SWIG version number\n\
     -help           - This output.\n\n";



// -----------------------------------------------------------------------------
// check_suffix(char *name)
//
// Checks the suffix of a file to see if we should emit extern declarations.
// -----------------------------------------------------------------------------

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

#ifdef MACSWIG
FILE  *swig_log;
#endif

char *SwigLib;
static int     freeze = 0;

static String  *lang_config = 0;

/* This function sets the name of the configuration file */

void SWIG_config_file(const String_or_char *filename) {
  lang_config = NewString(filename);
}

int SWIG_main(int argc, char *argv[], Language *l) {
  int    i;
  char   *c;
  char    temp[512];
  char    infile[512];
  char   *outfile_name = 0;
  int     help = 0;
  int     checkout = 0;
  int     cpp_only = 0;
  int     tm_debug = 0;
  char   *includefiles[256];
  int     includecount = 0;
  extern  int check_suffix(char *);
  extern  void scanner_file(DOHFile *);
  extern void parser_init(void);
  DOH    *libfiles = 0;

  /* Initialize the SWIG core */
  Swig_init();

#ifdef MACSWIG
  try {
#endif

  // Initialize the preprocessor
  Preprocessor_init();

  f_wrappers = 0;
  f_init = 0;
  f_header = 0;

  lang = l;
  Status = 0;

  // Set up some default symbols (available in both SWIG interface files
  // and C files)

  Preprocessor_define((DOH *) "SWIG 1", 0);
  Preprocessor_define((DOH *) "__STDC__", 0);
#ifdef MACSWIG
  Preprocessor_define((DOH *) "SWIGMAC 1", 0);
#endif
#ifdef SWIGWIN32
  Preprocessor_define((DOH *) "SWIGWIN32 1", 0);
#endif

  // Check for SWIG_LIB environment variable

  if ((c = getenv("SWIG_LIB")) == (char *) 0) {
      sprintf(LibDir,"%s",SWIG_LIB);    // Build up search paths
  } else {
      strcpy(LibDir,c);
  }

  SwigLib = Swig_copy_string(LibDir);        // Make a copy of the real library location

#ifdef MACSWIG
  sprintf(temp,"%s:config", LibDir);
  Swig_add_directory((DOH *) ":swig_lib:config");
  Swig_add_directory((DOH *) ":swig_lib");
#else
  sprintf(temp,"%s/config", LibDir);
  Swig_add_directory((DOH *) "./swig_lib/config");
  Swig_add_directory((DOH *) "./swig_lib");
#endif
  Swig_add_directory((DOH *) temp);
  Swig_add_directory((DOH *) LibDir);
  sprintf(InitName,"init_wrap");

  libfiles = NewList();

  // Get options
  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if (strncmp(argv[i],"-I",2) == 0) {
	    // Add a new directory search path
	    includefiles[includecount++] = Swig_copy_string(argv[i]+2);
	    Swig_mark_arg(i);
	  } else if (strncmp(argv[i],"-D",2) == 0) {
	    DOH *d = NewString(argv[i]+2);
	    Replace(d,(char*)"=",(char*)" ", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
	    Preprocessor_define((DOH *) d,0);
	    // Create a symbol
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-E") == 0) {
	    cpp_only = 1;
	    Swig_mark_arg(i);
	  } else if ((strcmp(argv[i],"-verbose") == 0) ||
		     (strcmp(argv[i],"-v") == 0)) {
	      Verbose = 1;
	      Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-c++") == 0) {
	      CPlusPlus=1;
	      Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-objc") == 0) {
	      ObjC = 1;
              Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-c") == 0) {
	      NoInclude=1;
	      Preprocessor_define((DOH *) "SWIG_NOINCLUDE 1", 0);
	      Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-make_default") == 0) {
	    GenerateDefault = 1;
	    Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-swiglib") == 0) {
	    printf("%s\n", LibDir);
	    SWIG_exit (EXIT_SUCCESS);
	  } else if (strcmp(argv[i],"-o") == 0) {
	      Swig_mark_arg(i);
	      if (argv[i+1]) {
		outfile_name = Swig_copy_string(argv[i+1]);
		Swig_mark_arg(i+1);
		i++;
	      } else {
		Swig_arg_error();
	      }
	  } else if (strcmp(argv[i],"-version") == 0) {
 	      fprintf(stderr,"\nSWIG Version %s %s\n",
		      SWIG_VERSION, SWIG_SPIN);
	      fprintf(stderr,"Copyright (c) 1995-98\n");
	      fprintf(stderr,"University of Utah and the Regents of the University of California\n");
	      fprintf(stderr,"\nCompiled with %s\n", SWIG_CC);
	      SWIG_exit (EXIT_SUCCESS);
	  } else if (strncmp(argv[i],"-l",2) == 0) {
	    // Add a new directory search path
	    Append(libfiles,argv[i]+2);
	    Swig_mark_arg(i);
          } else if (strcmp(argv[i],"-co") == 0) {
	    checkout = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-freeze") == 0) {
	    freeze = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-includeall") == 0) {
	    Preprocessor_include_all(1);
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-tm_debug") == 0) {
	    tm_debug = 1;
	    Swig_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	    Swig_mark_arg(i);
	    help = 1;
	  }
      }
  }
  if (Verbose)
    printf ("LibDir: %s\n", LibDir);

  while (includecount > 0) {
    Swig_add_directory((DOH *) includefiles[--includecount]);
  }

  // Parse language dependent options
  lang->parse_args(argc,argv);

  if (help) SWIG_exit (EXIT_SUCCESS);    // Exit if we're in help mode

  // Check all of the options to make sure we're cool.
  Swig_check_options();

  // Add language dependent directory to the search path
  {
    DOH *rl = NewString("");
#ifdef MACSWIG
    Printf(r1,"%s:%s", SwigLib,LibDir);
#else
    Printf(rl,"%s/%s", SwigLib,LibDir);
#endif    
    Swig_add_directory(rl);
  }

  // If we made it this far, looks good. go for it....
  // Create names of temporary files that are created

  sprintf(infilename,"%s", argv[argc-1]);
  input_file = new char[strlen(infilename)+1];
  strcpy(input_file, infilename);

  // If the user has requested to check out a file, handle that
  if (checkout) {
    DOH *s;
    char *outfile = input_file;
    if (outfile_name)
      outfile = outfile_name;

    if (Verbose)
      printf ("Handling checkout...\n");

    s = Swig_include(input_file);
    if (!s) {
      fprintf(stderr,"Unable to locate '%s' in the SWIG library.\n", input_file);
    } else {
      FILE *f = fopen(outfile,"r");
      if (f) {
	fclose(f);
	fprintf(stderr,"File '%s' already exists. Checkout aborted.\n", outfile);
      } else {
	f = fopen(outfile,"w");
	if (!f) {
	  fprintf(stderr,"Unable to create file '%s'\n", outfile);
	} else {
	  fprintf(stderr,"'%s' checked out from the SWIG library.\n", input_file);
	  fputs(Char(s),f);
	  fclose(f);
	}
      }
    }
  } else {
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

    // Define the __cplusplus symbol
    if (CPlusPlus)
      Preprocessor_define((DOH *) "__cplusplus 1", 0);

    // Run the preprocessor
    if (Verbose)
      printf ("Preprocessing...\n");
    {
      DOH *cpps;
      int i;
      String *fs = NewString("");
      String *ds = Swig_include(input_file);
      if (!ds) {
	Printf(stderr,"Unable to find '%s'\n", input_file);
	SWIG_exit (EXIT_FAILURE);
      }
      if (lang_config) {
	Printf(fs,"\n%%include \"%s\"\n", lang_config);
      }
      Printf(fs,"\n%%file(\"include\") \"%s\" {\n", Swig_last_file());
      Append(fs, ds);
      Append(fs,"\n}\n");
      Delete(ds);
      for (i = 0; i < Len(libfiles); i++) {
	Printf(fs,"\n%%include \"%s\"\n", Getitem(libfiles,i));
      }
      Seek(fs,0,SEEK_SET);
      cpps = Preprocessor_parse(fs);
      if (cpp_only) {
	Printf(stdout,"%s", cpps);
	while (freeze);
	SWIG_exit (EXIT_SUCCESS);
      }

      // Initialize the scanner
      Seek(cpps, 0, SEEK_SET);
      scanner_file(cpps);
    }
    if ((f_runtime = fopen(fn_runtime,"w")) == 0) {
      fprintf(stderr,"Unable to open %s\n", fn_runtime);
      exit(0);
    }
    f_header = NewString("");
    f_wrappers = NewString("");
    f_init = NewString("");

    // Set up the typemap for handling new return strings
    {
      if (CPlusPlus)
	Swig_typemap_register((char*)"newfree",(char*)"p.char",(char*)"",(char*)"delete [] $source;\n",0);
      else
	Swig_typemap_register((char*)"newfree",(char*)"p.char",(char*)"",(char*)"free($source);\n",0);
    }

    // If in Objective-C mode.  Load in a configuration file

    if (ObjC) {
      // Add the 'id' object type as a void *
      /*      DataType *t = new DataType(T_VOID);
      t->is_pointer = 1;
      t->implicit_ptr = 0;
      t->typedef_add("id");
      delete t;
      */
    }

    // Pass control over to the specific language interpreter

    if (Verbose) {
      fprintf (stdout, "Starting language-specific parse...\n");
      fflush (stdout);
    }
    parser_init();
    lang->parse();
    if (Verbose) {
      fprintf (stdout, "Finished language-specific parse.\n");
      fflush (stdout);
    }

    Dump(f_header,f_runtime);
    Dump(f_wrappers, f_runtime);
    Wrapper_pretty_print(f_init,f_runtime);
    fclose(f_runtime);
    if (checkout) {
      // File was checked out from the SWIG library.   Remove it now
      remove(input_file);
    }
  }
  if (tm_debug) Swig_typemap_debug();
  while (freeze);
  return error_count;
}

// --------------------------------------------------------------------------
// SWIG_exit(int exit_code)
//
// Cleanup and either freeze or exit
// --------------------------------------------------------------------------

void SWIG_exit(int exit_code) {
  if (f_runtime) {
    fclose(f_runtime);
    remove(fn_runtime);
  }
  while (freeze);
  exit (exit_code);
}


// --------------------------------------------------------------------------
// swig_pragma(char *name, char *value)
//
// Handle pragma directives.  Not many supported right now
// --------------------------------------------------------------------------

void swig_pragma(char *name, char *value) {

  if (strcmp(name,"make_default") == 0) {
    GenerateDefault = 1;
  }
  if (strcmp(name,"no_default") == 0) {
    GenerateDefault = 0;
  }
  if (strcmp(name,"objc_new") == 0) {
    objc_construct = Swig_copy_string(value);
  }
  if (strcmp(name,"objc_delete") == 0) {
    objc_destruct = Swig_copy_string(value);
  }
}
