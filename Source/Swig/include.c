/****************************************************************************
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
 ****************************************************************************/

static char cvsroot[] = "$Header$";

#include "swigcore.h"

/*******************************************************************************
 * $Header$
 *
 * File : include.c
 *
 * Various file manipulation functions.
 *******************************************************************************/

/* Delimeter used in accessing files and directories */

static DOH           *directories = 0;        /* List of include directories */
static DOH           *libdir = 0;             /* SWIG library directory */
static DOH           *lastpath = 0;           /* Last file that was included */
static int            bytes_read = 0;         /* Bytes read */

/* -----------------------------------------------------------------------------
 * void SWIG_add_directory( DOH *dirname)
 *
 * Adds a directory to the SWIG search path.
 * ----------------------------------------------------------------------------- */

void 
SWIG_add_directory(DOH *dirname)
{
  if (!directories) directories = NewList();
  assert(directories);
  if (!String_check(dirname)) {
    dirname = NewString((char *) dirname);
    assert(dirname);
  }
  Append(directories, dirname);
}

/* -----------------------------------------------------------------------------
 * void SWIG_set_library(DOH *libname) 
 *
 * Sets the language specific library name like 'tcl', 'perl5', 'python', etc...
 * ----------------------------------------------------------------------------- */

void
SWIG_set_library(DOH *libname)
{
  Delete(libdir);
  if (!String_check(libname)) {
      libname = NewString((char *) libname);
      assert(libname);
  }
  libdir = libname;
}

/* -----------------------------------------------------------------------------
 * DOH *SWIG_get_library()
 *
 * Gets the language specific name like 'tcl', 'perl5', etc...
 * ----------------------------------------------------------------------------- */
DOH *
SWIG_get_library() {
  assert(libdir);
  return libdir;
}

/* -----------------------------------------------------------------------------
 * DOH *SWIG_last_file()
 * 
 * Returns the full pathname of the last file opened. 
 * ----------------------------------------------------------------------------- */

DOH *
SWIG_last_file() {
  assert(lastpath);
  return lastpath;
}

/* -----------------------------------------------------------------------------
 * DOH *SWIG_search_path() 
 * 
 * Returns a list of the current search paths.
 * ----------------------------------------------------------------------------- */

DOH *SWIG_search_path() 
{
  DOH *filename;
  DOH *dirname;
  DOH *slist;
  int i;

  slist = NewList();
  assert(slist);
  filename = NewString("");
  assert(filename);
  Printf(filename,".%s", FILE_DELIMETER);
  Append(slist,filename);
  for (i = 0; i < Len(directories); i++) {
    dirname =  Getitem(directories,i);
    if (libdir) {
      filename = NewString("");
      assert(filename);
      Printf(filename,"%s%s%s%s", dirname, FILE_DELIMETER, libdir, FILE_DELIMETER);
      Append(slist,filename);
    }
    filename = NewString("");
    assert(filename);
    Printf(filename, "%s%s", dirname, FILE_DELIMETER);
    Append(slist,filename);
  }
  return slist;
}  

/* -----------------------------------------------------------------------------
 * FILE *SWIG_open( DOH *name)           
 *
 * Looks for a file and open it.
 * ----------------------------------------------------------------------------- */

FILE *
SWIG_open(DOH *name)
{
  FILE    *f;
  DOH     *filename;
  DOH     *spath = 0;
  char    *cname;
  int     i;

  if (!directories) directories = NewList();
  assert(directories);

  cname = Char(name);
  filename = NewString(cname);
  assert(filename);
  f = fopen(Char(filename),"r");
  if (!f) {
      spath = SWIG_search_path();
      for (i = 0; i < Len(spath); i++) {
	  Clear(filename);
	  Printf(filename,"%s%s", Getitem(spath,i), cname);
	  f = fopen(Char(filename),"r");
	  if (f) break;
      } 
      Delete(spath);
  }
  if (f) {
    Delete(lastpath);
    lastpath = Copy(filename);
  }
  Delete(filename);
  return f;
}

/* -----------------------------------------------------------------------------
 * DOH *SWIG_read_file(FILE *f)
 * 
 * Reads data from f and returns as a new string
 * ----------------------------------------------------------------------------- */

DOH *SWIG_read_file(FILE *f) {
  char buffer[4096];
  DOH *str = NewString("");
  assert(str);
  while (fgets(buffer,4095,f)) {
    Append(str,buffer);
  }
  return str;
}

/* -----------------------------------------------------------------------------
 * DOH *SWIG_include(DOH *name)
 *
 * Open a file and return it as a string.
 * ----------------------------------------------------------------------------- */

DOH *
SWIG_include(DOH *name) 
{
  FILE  *f;
  DOH    *str;
  f = SWIG_open(name);
  if (!f) return 0;
  str = SWIG_read_file(f);
  bytes_read = bytes_read + Len(str);
  fclose(f);
  Seek(str,0,SEEK_SET);
  Setfile(str,lastpath);
  Setline(str,1);
  /*   fprintf(stderr,"%d bytes read\n", bytes_read); */
  return str;
}

