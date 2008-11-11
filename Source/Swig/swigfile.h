/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swigfile.h
 *
 * File handling functions in the SWIG core
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9603 2006-12-05 21:47:01Z beazley $ */

extern List   *Swig_add_directory(const String_or_char *dirname);
extern void    Swig_push_directory(const String_or_char *dirname);
extern void    Swig_pop_directory(void);
extern String *Swig_last_file(void);
extern List   *Swig_search_path(int syspathvoid);
extern FILE   *Swig_open(const String_or_char *name);
extern String *Swig_read_file(FILE *f); 
extern String *Swig_include(const String_or_char *name);
extern String *Swig_include_sys(const String_or_char *name);
extern int     Swig_insert_file(const String_or_char *name, File *outfile);
extern void    Swig_set_push_dir(int dopush);
extern int     Swig_get_push_dir(void);
extern void    Swig_register_filebyname(const String_or_char *filename, File *outfile);
extern File   *Swig_filebyname(const String_or_char *filename);
extern char   *Swig_file_suffix(const String_or_char *filename);
extern char   *Swig_file_basename(const String_or_char *filename);
extern char   *Swig_file_filename(const String_or_char *filename);
extern char   *Swig_file_dirname(const String_or_char *filename);

/* Delimiter used in accessing files and directories */

#if defined(MACSWIG)
#  define SWIG_FILE_DELIMITER ":"
#elif defined(_WIN32)
#  define SWIG_FILE_DELIMITER "\\"
#else
#  define SWIG_FILE_DELIMITER "/"
#endif
