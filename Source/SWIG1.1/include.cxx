/* ----------------------------------------------------------------------------- 
 * include.cxx
 *
 *     File inclusion functions.  This file is deprecated.  These are only a
 *     thin wrapper over the functions in Swig/include.c.
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

extern "C" FILE *Swig_open(void *);

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

// -----------------------------------------------------------------------------
// int insert_file(char *filename, FILE *f)
// 
// Appends the contents of filename to stream f.
// -----------------------------------------------------------------------------
int insert_file(char *filename, FILE *f) {
  FILE *in_file;
  char buffer[1024];
  if ((in_file = Swig_open((void *) filename)) == NULL) {
    return -1;
  }
  while (fgets(buffer,1023,in_file)) {
    fputs(buffer, f);
  }
  fclose(in_file);
  return 0;
}

// -----------------------------------------------------------------------------
// int get_file(char *name, String &str)
//
// Looks for a file and converts it into a String.  
// -----------------------------------------------------------------------------
int get_file(char *name, String &str) {
  FILE  *f;
  char buffer[1024];
  f = Swig_open((void *) name);
  if (!f) {
    fprintf(stderr,"SWIG Error. Unable to find %s. Possible installation problem.\n",name);
    FatalError();
    return -1;
  }
  while (fgets(buffer,1023,f)) {
    str << buffer;
  }
  fclose(f);
  return 0;
}






