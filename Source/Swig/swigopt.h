/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigopt.h
 *
 * Header file for the SWIG command line processing functions
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9622 2006-12-19 03:49:17Z beazley $ */

 extern void  Swig_init_args(int argc, char **argv);
 extern void  Swig_mark_arg(int n);
 extern int   Swig_check_marked(int n);
 extern void  Swig_check_options(int check_input);
 extern void  Swig_arg_error(void);
