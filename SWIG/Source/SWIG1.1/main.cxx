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
/***********************************************************************
 * $Header$
 *
 * main.cxx
 *
 * The main program.
 *
 ***********************************************************************/

static char cvsroot[] = "$Header$";

#define WRAP

#include "internal.h"
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#include "swigcpp.h"

class SwigException {};

static char *usage = "\
\nGeneral Options\n\
     -c              - Produce raw wrapper code (omit support code)\n\
     -c++            - Enable C++ processing\n\
     -co             - Check a file out of the SWIG library\n\
     -d docfile      - Set name of the documentation file.\n\
     -Dsymbol        - Define a symbol (for conditional compilation)\n\
     -I<dir>         - Look for SWIG files in <dir>\n\
     -l<ifile>       - Include SWIG library file.\n\
     -make_default   - Create default constructors/destructors\n\
     -nocomment      - Ignore all comments (for documentation).\n\
     -o outfile      - Set name of the output file.\n\
     -objc           - Enable Objective C processing\n\
     -strict n       - Set pointer type-checking strictness\n\
     -swiglib        - Report location of SWIG library and exit\n\
     -v              - Run in verbose mode\n\
     -version        - Print SWIG version number\n\
     -help           - This output.\n\n";

//-----------------------------------------------------------------
// main()
//
// Main program.    Initializes the files and starts the parser.
//-----------------------------------------------------------------

char  infilename[256];
char  filename[256];
char  fn_cpp[256];
char  fn_header[256];
char  fn_wrapper[256];
char  fn_init[256];
char  output_dir[512];
char  fn_runtime[256];

#ifdef MACSWIG
FILE  *swig_log;
#endif

char *SwigLib;

int SWIG_main(int argc, char *argv[], Language *l, Documentation *d) {

  int    i;
  char   *c;
  extern  FILE   *LEX_in;
  extern  char   *get_time();
  char    temp[512];
  char    infile[512];

  char   *outfile_name = 0;
  extern  int add_iname(char *);
  int     help = 0;
  int     ignorecomments = 0;
  int     checkout = 0;
  int     cpp_only = 0;
  char   *typemap_file = 0;
  char   *includefiles[256];
  int     includecount = 0;
  extern  void check_suffix(char *);
  extern  void scanner_file(FILE *);
  DOH    *libfiles = 0;

#ifdef MACSWIG
  try {
#endif

  // Initialize the preprocessor
  SWIG_cpp_init();

  f_wrappers = 0;
  f_init = 0;
  f_header = 0;

  lang = l;
  doc = d;
  Status = 0;
  TypeStrict = 2;                   // Very strict type checking
  Verbose = 0;
  char    *doc_file = 0;
  
  DataType::init_typedef();         // Initialize the type handler

  // Set up some default symbols (available in both SWIG interface files
  // and C files)

  SWIG_cpp_define((DOH *) "SWIG 1", 0);
#ifdef MACSWIG
  SWIG_cpp_define((DOH *) "SWIGMAC 1", 0);
#endif
#ifdef SWIGWIN32
  SWIG_cpp_define((DOH *) "SWIGWIN32 1", 0);
#endif
  
  // Check for SWIG_LIB environment variable

  if ((c = getenv("SWIG_LIB")) == (char *) 0) {
      sprintf(LibDir,"%s",SWIG_LIB);    // Build up search paths
  } else {
      strcpy(LibDir,c);
  }
  
  SwigLib = copy_string(LibDir);        // Make a copy of the real library location
#ifdef MACSWIG
  /* This needs to be fixed */
  sprintf(temp,"%s:config", LibDir);
  add_directory(temp);
  add_directory(":swig_lib:config");
  add_directory(LibDir);
  add_directory(":swig_lib");
#else
  sprintf(temp,"%s/config", LibDir);

  SWIG_add_directory((DOH *) temp);
  SWIG_add_directory((DOH *) "./swig_lib/config");
  SWIG_add_directory((DOH *) LibDir);
  SWIG_add_directory((DOH *) "./swig_lib");
  sprintf(InitName,"init_wrap");
#endif

  sprintf(InitName,"init_wrap");  

  libfiles = NewList();

  // Get options
  for (i = 1; i < argc; i++) {
      if (argv[i]) {
	  if (strncmp(argv[i],"-I",2) == 0) {
	    // Add a new directory search path 
	    includefiles[includecount++] = copy_string(argv[i]+2);
	    SWIG_mark_arg(i);
	  } else if (strncmp(argv[i],"-D",2) == 0) {
	    DOH *d = NewString(argv[i]+2);
	    String_replace(d,(char*)"=",(char*)" ", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
	    SWIG_cpp_define((DOH *) d,0);
	    // Create a symbol
	    SWIG_mark_arg(i);
	  } else if (strcmp(argv[i],"-strict") == 0) {
	    if (argv[i+1]) {
	      TypeStrict = atoi(argv[i+1]);
	      SWIG_mark_arg(i);
	      SWIG_mark_arg(i+1);
	      i++;
	    } else {
	      SWIG_arg_error();
	    }
	  } else if (strcmp(argv[i],"-E") == 0) {
	    cpp_only = 1;
	    SWIG_mark_arg(i);
	  } else if ((strcmp(argv[i],"-verbose") == 0) || (strcmp(argv[i],"-v") == 0)) {
	      Verbose = 1;
	      SWIG_mark_arg(i);
	  } else if (strcmp(argv[i],"-nocomment") == 0) {
	      ignorecomments = 1;
	      SWIG_mark_arg(i);
	  } else if (strcmp(argv[i],"-c++") == 0) {
	      CPlusPlus=1;
	      SWIG_mark_arg(i);  
          } else if (strcmp(argv[i],"-objc") == 0) {
	      ObjC = 1;
              SWIG_mark_arg(i);
	  } else if (strcmp(argv[i],"-c") == 0) {
	      NoInclude=1;
	      SWIG_mark_arg(i);
          } else if (strcmp(argv[i],"-make_default") == 0) {
	    GenerateDefault = 1;
	    SWIG_mark_arg(i);
          } else if (strcmp(argv[i],"-swiglib") == 0) {
	    printf("%s\n", LibDir);
	    SWIG_exit(0);
	  } else if (strcmp(argv[i],"-o") == 0) {
	      SWIG_mark_arg(i);
	      if (argv[i+1]) {
		outfile_name = copy_string(argv[i+1]);
		SWIG_mark_arg(i+1);
		i++;
	      } else {
		SWIG_arg_error();
	      }
	  } else if (strcmp(argv[i],"-d") == 0) {
	      SWIG_mark_arg(i);
	      if (argv[i+1]) {
		doc_file = copy_string(argv[i+1]);
		SWIG_mark_arg(i+1);
		i++;
	      } else {
		SWIG_arg_error();
	      }
	  } else if (strcmp(argv[i],"-version") == 0) {
 	      fprintf(stderr,"\nSWIG Version %d.%d %s\n", SWIG_MAJOR_VERSION,
		      SWIG_MINOR_VERSION, SWIG_SPIN);
	      fprintf(stderr,"Copyright (c) 1995-98\n");
	      fprintf(stderr,"University of Utah and the Regents of the University of California\n");
	      fprintf(stderr,"\nCompiled with %s\n", SWIG_CC);
	      SWIG_exit(0);
	  } else if (strncmp(argv[i],"-l",2) == 0) {
	    // Add a new directory search path 
	    Append(libfiles,argv[i]+2);
	    SWIG_mark_arg(i);
          } else if (strcmp(argv[i],"-co") == 0) {
	    checkout = 1;
	    SWIG_mark_arg(i);
	  } else if (strcmp(argv[i],"-help") == 0) {
	    fputs(usage,stderr);
	    SWIG_mark_arg(i);
	    help = 1;
	  }
      }
  }

  while (includecount > 0) {
    SWIG_add_directory((DOH *) includefiles[--includecount]);
  }
    
  // Open up a comment handler

  comment_handler = new CommentHandler();
  comment_handler->parse_args(argc,argv);
  if (ignorecomments) comment_handler->style("ignore",0);

  // Create a new documentation entry

  doctitle = new DocTitle("",0);
  doctitle->parse_args(argc,argv);
  doc_entry = doctitle;

  // Handle documentation module options

  doc->parse_args(argc,argv);

  // Parse language dependent options

  lang->parse_args(argc,argv);

  if (help) SWIG_exit(0);              // Exit if we're in help mode

  // Check all of the options to make sure we're cool.
  
  SWIG_check_options();

  SWIG_set_library(LibDir);

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
    
    s = SWIG_include(input_file);
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
    doctitle->file = copy_string(input_file);
    doctitle->line_number = -1000;
    doctitle->end_line = -1000;
    
    // Check the suffix for a .c file.  If so, we're going to 
    // declare everything we see as "extern"
    
    check_suffix(infilename);
    
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
      sprintf(fn_runtime,"%s_wrap.c",infilename);
      strcpy(infile,infilename);
      strcpy(output_dir,"");
    } else {
      sprintf(fn_runtime,"%s",outfile_name);
      // Try to identify the output directory
      char *cc = outfile_name;
      char *lastc = outfile_name;
      while (*cc) {
#ifdef MACSWIG
	if (*cc == ':') lastc = cc+1;
#else
	if (*cc == '/') lastc = cc+1;
#endif
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
#ifdef MACSWIG
	if (*cc == ':') {
	  cc++;
	  break;
	}
#else
	if (*cc == '/') {
	  cc++;
	  break;
	}
#endif
	cc--;
      }
      strcpy(infile,cc);
    }

    sprintf(fn_cpp,"%s%s_wrap.ii", output_dir, infile);
    sprintf(fn_header,"%s%s_wrap.head", output_dir,infile);
    sprintf(fn_wrapper,"%s%s_wrap.wrap",output_dir,infile);
    sprintf(fn_init,"%s%s_wrap.init",output_dir,infile);
    
    sprintf(title,"%s", fn_runtime);
    
    // Define the __cplusplus symbol
    if (CPlusPlus) 
      SWIG_cpp_define((DOH *) "__cplusplus 1", 0);

    // Open up files

    /* Preprocess.  Ugh */

    {
      DOH *cpps;
      FILE *f;
      int i;
      DOH *ds = SWIG_include(input_file);
      Seek(ds,0,SEEK_END);
      for (i = 0; i < Len(libfiles); i++) {
	Printf(ds,"\n%%include \"%s\"\n", Getitem(libfiles,i));
      }
      Seek(ds,0,SEEK_SET);
      cpps = SWIG_cpp_parse(ds);
      if (cpp_only) {
	Printf(stdout,"%s", cpps);
	SWIG_exit(0);
      }
      f = fopen(fn_cpp,"w");
      fwrite(Char(cpps),1, Len(cpps), f);
      fclose(f);
    }
    
    if ((f_input = fopen(fn_cpp,"r")) == 0) {
      fprintf(stderr,"Unable to open %s\n", fn_cpp);
      SWIG_exit(0);
    }
    
    // Initialize the scanner
    LEX_in = f_input;
    scanner_file(LEX_in);

    //printf("fn_cpp = %s\n", fn_cpp);
    //printf("fn_header = %s\n", fn_header);
    //printf("fn_wrapper = %s\n", fn_wrapper);
    //printf("fn_init = %s\n", fn_init);

    if ((f_runtime = fopen(fn_runtime,"w")) == 0) {
      fprintf(stderr,"Unable to open %s\n", fn_runtime);
      exit(0);
    }
    if((f_header = fopen(fn_header,"w")) == 0) {
      fprintf(stderr,"Unable to open %s\n", fn_header);
      exit(0);
    }
    if((f_wrappers = fopen(fn_wrapper,"w")) == 0) {
      fprintf(stderr,"Unable to open %s\n",fn_wrapper);
      exit(0);
    }
    if ((f_init = fopen(fn_init,"w")) == 0) {
      fprintf(stderr,"Unable to open %s\n",fn_init);
      exit(0);
    }
    
    // Open up documentation
    
    if (doc_file) {
      doc->init(doc_file);
    } else {
      doc_file = new char[strlen(infile)+strlen(output_dir)+8];
      sprintf(doc_file,"%s%s_wrap",output_dir,infile);
      doc->init(doc_file);
    }
    
    // Set up the typemap for handling new return strings
    {
      DataType *temp_t = new DataType(T_CHAR);
      temp_t->is_pointer++;
      if (CPlusPlus) 
	typemap_register("newfree",typemap_lang,temp_t,"","delete [] $source;\n",0);
      else 
	typemap_register("newfree",typemap_lang,temp_t,"","free($source);\n",0);

      delete temp_t;
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

    lang->parse();

    fclose(f_header);
    fclose(f_wrappers);
    fclose(f_init);

    swig_append(fn_header, f_runtime);
    swig_append(fn_wrapper,f_runtime);
    swig_append(fn_init,f_runtime);
    
    fclose(f_runtime);
    
    // Print out documentation.  Due to tree-like nature of documentation,
    // printing out the title prints out everything.
    
    while(doctitle) {
      doctitle->output(doc);
      doctitle = doctitle->next;
    }
    
    doc->close();
    
    // Remove temporary files
    
    remove(fn_cpp);
    remove(fn_header);
    remove(fn_wrapper);
    remove(fn_init);

    // If only producing documentation, remove the wrapper file as well

    if (DocOnly) 
      remove(fn_runtime);

    // Check for undefined types that were used.

    if (Verbose)
      type_undefined_check();

    if (checkout) {
      // File was checked out from the SWIG library.   Remove it now
      remove(input_file);
    }
  }
#ifdef MACSWIG
  fclose(swig_log);
  } catch (SwigException) {
    fclose(swig_log);
  }
#else
  exit(error_count);
#endif
  return(error_count);
}

// --------------------------------------------------------------------------
// SWIG_exit()
//
// Fatal parser error. Exit and cleanup
// --------------------------------------------------------------------------

void SWIG_exit(int) {

  if (f_wrappers) {
    fclose(f_wrappers);
    remove(fn_wrapper);
  }
  if (f_header) {
    fclose(f_header);
    remove(fn_header);
  }
  if (f_init) {
    fclose(f_init);
    remove(fn_init);
  }
  if (f_runtime) {
    fclose(f_runtime);
    remove(fn_runtime);
  }
#ifndef MACSWIG
  exit(1);
#else
  throw SwigException();
#endif
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
    objc_construct = copy_string(value);
  }
  if (strcmp(name,"objc_delete") == 0) {
    objc_destruct = copy_string(value);
  }
}
