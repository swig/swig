/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * com.cxx
 *
 * COM module for SWIG.
 * ----------------------------------------------------------------------------- */

char cvsroot_com_cxx[] = "$Id$";

#include "swigmod.h"
#include "cparse.h"

class COM:public Language {
  static const char *usage;

  File *f_runtime;
  File *f_header;

public:

  /* -----------------------------------------------------------------------------
   * COM()
   * ----------------------------------------------------------------------------- */

   COM() {}

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("com");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
	if (strcmp(argv[i], "-help") == 0) {
	  Printf(stdout, "%s\n", usage);
	}
      }
    }
    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGCOM 1", 0);

    // Add typemap definitions
    SWIG_typemap_lang("com");
    SWIG_config_file("com.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");
    String *outfile_h = Getattr(n, "outfile_h");

    if (!outfile) {
      Printf(stderr, "Unable to determine outfile\n");
      SWIG_exit(EXIT_FAILURE);
    }

    f_runtime = NewFile(outfile, "w");
    if (!f_runtime) {
      FileErrorDisplay(outfile);
      SWIG_exit(EXIT_FAILURE);
    }

    f_header = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("runtime", f_runtime);

    /* Emit code */
    Language::top(n);

    /* Close all of the files */
    Dump(f_header, f_runtime);
    Delete(f_header);
    Delete(f_runtime);
    return SWIG_OK;
  }

};				/* class COM */

/* -----------------------------------------------------------------------------
 * swig_com()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_com() {
  return new COM();
}
extern "C" Language *swig_com(void) {
  return new_swig_com();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *COM::usage = (char *) "\
COM Options (available with -com)\n\
\n";
