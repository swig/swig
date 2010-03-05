/* ----------------------------------------------------------------------------- 
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * swigfile.h
 *
 * File handling functions in the SWIG core
 * ----------------------------------------------------------------------------- */

/* $Id: swig.h 9603 2006-12-05 21:47:01Z beazley $ */

extern List   *Swig_add_directory(const String_or_char *dirname);
extern void    Swig_push_directory(const String_or_char *dirname);
extern void    Swig_pop_directory();
extern String *Swig_last_file();
extern List   *Swig_search_path();
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
