/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * include.c
 *
 * The functions in this file are used to manage files in the SWIG library.
 * General purpose functions for opening, including, and retrieving pathnames
 * are provided.
 * ----------------------------------------------------------------------------- */

char cvsroot_include_c[] = "$Id$";

#include "swig.h"

/* Delimeter used in accessing files and directories */

static List   *directories = 0;	        /* List of include directories */
static String *lastpath = 0;	        /* Last file that was included */
static List   *pdirectories = 0;        /* List of pushed directories  */
static int     dopush = 1;		/* Whether to push directories */

/* This functions determine whether to push/pop dirs in the preprocessor */
void Swig_set_push_dir(int push) {
  dopush = push;
}

int Swig_get_push_dir(void) {
  return dopush;
}

/* -----------------------------------------------------------------------------
 * Swig_add_directory()
 *
 * Adds a directory to the SWIG search path.
 * ----------------------------------------------------------------------------- */

List *Swig_add_directory(const String_or_char *dirname) {
  String *adirname;
  if (!directories)
    directories = NewList();
  assert(directories);
  if (dirname) {
    adirname = NewString(dirname);
    Append(directories,adirname);
    Delete(adirname);
  }
  return directories;
}

/* -----------------------------------------------------------------------------
 * Swig_push_directory()
 *
 * Inserts a directory at the front of the SWIG search path.  This is used by
 * the preprocessor to grab files in the same directory as other included files.
 * ----------------------------------------------------------------------------- */

void Swig_push_directory(const String_or_char *dirname) {
  String *pdirname;
  if (!Swig_get_push_dir())
    return;
  if (!pdirectories)
    pdirectories = NewList();
  assert(pdirectories);
  pdirname = NewString(dirname);
  assert(pdirname);
  Insert(pdirectories,0,pdirname);
  Delete(pdirname);
}

/* -----------------------------------------------------------------------------
 * Swig_pop_directory()
 *
 * Pops a directory off the front of the SWIG search path.  This is used by
 * the preprocessor.
 * ----------------------------------------------------------------------------- */

void Swig_pop_directory() {
  if (!Swig_get_push_dir())
    return;
  if (!pdirectories)
    return;
  Delitem(pdirectories, 0);
}

/* -----------------------------------------------------------------------------
 * Swig_last_file()
 * 
 * Returns the full pathname of the last file opened. 
 * ----------------------------------------------------------------------------- */

String *Swig_last_file() {
  assert(lastpath);
  return lastpath;
}

/* -----------------------------------------------------------------------------
 * Swig_search_path() 
 * 
 * Returns a list of the current search paths.
 * ----------------------------------------------------------------------------- */

static List *Swig_search_path_any(int syspath) {
  String *filename;
  List   *slist;
  int     i, ilen;

  slist = NewList();
  assert(slist);
  filename = NewStringEmpty();
  assert(filename);
#ifdef MACSWIG
  Printf(filename, "%s", SWIG_FILE_DELIMETER);
#else
  Printf(filename, ".%s", SWIG_FILE_DELIMETER);
#endif
  Append(slist, filename);
  Delete(filename);
  
  /* If there are any pushed directories.  Add them first */
  if (pdirectories) {
    ilen = Len(pdirectories);
    for (i = 0; i < ilen; i++) {
      filename = NewString(Getitem(pdirectories,i));
      StringAppend(filename,SWIG_FILE_DELIMETER);
      Append(slist,filename);
      Delete(filename);
    }
  }
  /* Add system directories next */
  ilen = Len(directories);
  for (i = 0; i < ilen; i++) {
    filename = NewString(Getitem(directories,i));
    StringAppend(filename,SWIG_FILE_DELIMETER);
    if (syspath) {
      /* If doing a system include, put the system directories first */
      Insert(slist,i,filename);
    } else {
      /* Otherwise, just put the system directories after the pushed directories (if any) */
      Append(slist,filename);
    }
    Delete(filename);
  }
  return slist;
}

List *Swig_search_path() {
  return Swig_search_path_any(0);
}



/* -----------------------------------------------------------------------------
 * Swig_open()
 *
 * Looks for a file and open it.  Returns an open  FILE * on success.
 * ----------------------------------------------------------------------------- */

static FILE *Swig_open_any(const String_or_char *name, int sysfile) {
  FILE *f;
  String *filename;
  List *spath = 0;
  char *cname;
  int i, ilen;

  if (!directories)
    directories = NewList();
  assert(directories);

  cname = Char(name);
  filename = NewString(cname);
  assert(filename);
  f = fopen(Char(filename), "r");
  if (!f) {
    spath = Swig_search_path_any(sysfile);
    ilen = Len(spath);
    for (i = 0; i < ilen; i++) {
      Clear(filename);
      Printf(filename, "%s%s", Getitem(spath, i), cname);
      f = fopen(Char(filename), "r");
      if (f)
	break;
    }
    Delete(spath);
  }
  if (f) {
#if defined(_WIN32)		/* Note not on Cygwin else filename is displayed with double '/' */
    Replaceall(filename, "\\\\", "\\");	/* remove double '\' in case any already present */
    Replaceall(filename, "\\", "\\\\");
#endif
    Delete(lastpath);
    lastpath = Copy(filename);
  }
  Delete(filename);
  return f;
}

FILE *Swig_open(const String_or_char *name) {
  return Swig_open_any(name, 0);
}



/* -----------------------------------------------------------------------------
 * Swig_read_file()
 * 
 * Reads data from an open FILE * and returns it as a string.
 * ----------------------------------------------------------------------------- */

String *Swig_read_file(FILE *f) {
  int len;
  char buffer[4096];
  String *str = NewStringEmpty();

  assert(str);
  while (fgets(buffer, 4095, f)) {
    StringAppend(str, buffer);
  }
  len = StringLen(str);
  if (len) {
    char *cstr = Char(str);
    if (cstr[len - 1] != '\n') {
      StringAppend(str, "\n");
    }
  }
  return str;
}

/* -----------------------------------------------------------------------------
 * Swig_include()
 *
 * Opens a file and returns it as a string.
 * ----------------------------------------------------------------------------- */

static String *Swig_include_any(const String_or_char *name, int sysfile) {
  FILE *f;
  String *str;
  String *file;

  f = Swig_open_any(name, sysfile);
  if (!f)
    return 0;
  str = Swig_read_file(f);
  fclose(f);
  Seek(str, 0, SEEK_SET);
  file = Copy(lastpath);
  Setfile(str, file);
  Delete(file);
  Setline(str, 1);
  return str;
}

String *Swig_include(const String_or_char *name) {
  return Swig_include_any(name, 0);
}

String *Swig_include_sys(const String_or_char *name) {
  return Swig_include_any(name, 1);
}

/* -----------------------------------------------------------------------------
 * Swig_insert_file()
 *
 * Copies the contents of a file into another file
 * ----------------------------------------------------------------------------- */

int Swig_insert_file(const String_or_char *filename, File *outfile) {
  char buffer[4096];
  int nbytes;
  FILE *f = Swig_open(filename);

  if (!f)
    return -1;
  while ((nbytes = Read(f, buffer, 4096)) > 0) {
    Write(outfile, buffer, nbytes);
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_register_filebyname()
 *
 * Register a "named" file with the core.  Named files can become targets
 * for %insert directives and other SWIG operations.  This function takes
 * the place of the f_header, f_wrapper, f_init, and other global variables
 * in SWIG1.1
 * ----------------------------------------------------------------------------- */

static Hash *named_files = 0;

void Swig_register_filebyname(const String_or_char *filename, File *outfile) {
  if (!named_files)
    named_files = NewHash();
  Setattr(named_files, filename, outfile);
}

/* -----------------------------------------------------------------------------
 * Swig_filebyname()
 *
 * Get a named file
 * ----------------------------------------------------------------------------- */

File *Swig_filebyname(const String_or_char *filename) {
  if (!named_files)
    return 0;
  return Getattr(named_files, filename);
}

/* -----------------------------------------------------------------------------
 * Swig_file_suffix()
 *
 * Returns the suffix of a file
 * ----------------------------------------------------------------------------- */

char *Swig_file_suffix(const String_or_char *filename) {
  char *d;
  char *c = Char(filename);
  int len = Len(filename);
  if (strlen(c)) {
    d = c + len - 1;
    while (d != c) {
      if (*d == '.')
	return d;
      d--;
    }
    return c + len;
  }
  return c;
}

/* -----------------------------------------------------------------------------
 * Swig_file_basename()
 *
 * Returns the filename with no suffix attached.
 * ----------------------------------------------------------------------------- */

char *Swig_file_basename(const String_or_char *filename) {
  static char tmp[1024];
  char *c;
  strcpy(tmp, Char(filename));
  c = Swig_file_suffix(tmp);
  *c = 0;
  return tmp;
}

/* -----------------------------------------------------------------------------
 * Swig_file_filename()
 *
 * Return the file with any leading path stripped off
 * ----------------------------------------------------------------------------- */
char *Swig_file_filename(const String_or_char *filename) {
  static char tmp[1024];
  const char *delim = SWIG_FILE_DELIMETER;
  char *c;

  strcpy(tmp, Char(filename));
  if ((c = strrchr(tmp, *delim)))
    return c + 1;
  else
    return tmp;
}

/* -----------------------------------------------------------------------------
 * Swig_file_dirname()
 *
 * Return the name of the directory associated with a file
 * ----------------------------------------------------------------------------- */
char *Swig_file_dirname(const String_or_char *filename) {
  static char tmp[1024];
  const char *delim = SWIG_FILE_DELIMETER;
  char *c;
  strcpy(tmp, Char(filename));
  if (!strstr(tmp, delim)) {
    return "";
  }
  c = tmp + strlen(tmp) - 1;
  while (*c != *delim)
    c--;
  *(++c) = 0;
  return tmp;
}
