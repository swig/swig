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

static char cvsroot[] = "$Header$";

#include "internal.h"
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

extern "C" FILE *Swig_open(void *);

/*******************************************************************************
 * $Header$
 *
 * File : include.cxx
 *
 * Code for including files into a wrapper file.
 *******************************************************************************/

// -----------------------------------------------------------------------------
// void check_suffix(char *name)
// 
// Checks the suffix of an include file to see if we need to handle it
// differently.  C and C++ source files need a little extra help.
// -----------------------------------------------------------------------------

void check_suffix(char *name) {
  char *c;

  if (!name) return;
  if (strlen(name) == 0) return;
  c = name+strlen(name)-1;
  while (c != name) {
    if (*c == '.') break;
    c--;
  }
  if (c == name) return;

  /* Check suffixes */

  if (strcmp(c,".c") == 0) {
    ForceExtern = 1;
  } else if (strcmp(c,".C") == 0) {
    ForceExtern = 1;
  } else if (strcmp(c,".cc") == 0) {
    ForceExtern = 1;
  } else if (strcmp(c,".cxx") == 0) {
    ForceExtern = 1;
  } else if (strcmp(c,".c++") == 0) {
    ForceExtern = 1;
  } else if (strcmp(c,".cpp") == 0) {
    ForceExtern = 1;
  } else {
    ForceExtern = 0;
  }
}

// -----------------------------------------------------------------------------
// void copy_data(FILE *f1, FILE *f2)
//
// Copies data from file f1 to file f2.
// -----------------------------------------------------------------------------

static char buffer[1024];

void copy_data(FILE *f1, FILE *f2) {

  while (fgets(buffer,1023,f1)) {
    fputs(buffer, f2);
  }
  fclose(f1);
}

// -----------------------------------------------------------------------------
// void copy_data(FILE *f1, String *s2)
//
// Copies data from file f1 to String s2.
// -----------------------------------------------------------------------------

void copy_data(FILE *f1, String &s2) {

  while (fgets(buffer,1023,f1)) {
    s2 << buffer;
  }
  fclose(f1);
}

// -----------------------------------------------------------------------------
// int insert_file(char *name, FILE *f)
//
// Looks for a file and inserts into file f.
// -----------------------------------------------------------------------------
int insert_file(char *name, FILE *f_out) {
  FILE  *f;
  f = Swig_open((void *) name);
  if (f) {
      copy_data(f,f_out);
      return 0;
  }
  return -1;
}

// -----------------------------------------------------------------------------
// void swig_append(char *filename, FILE *f)
// 
// Appends the contents of filename to stream f.
// -----------------------------------------------------------------------------

void swig_append(char *filename, FILE *f) {
  FILE *in_file;
  if ((in_file = fopen(filename,"r")) == NULL) {
      fprintf(stderr,"** SWIG ERROR ** file %s not found.\n",filename);
      FatalError();
      return;
  }
  copy_data(in_file, f);
}

// -----------------------------------------------------------------------------
// int get_file(char *name, String &str)
//
// Looks for a file and converts it into a String.  
// -----------------------------------------------------------------------------
int get_file(char *name, String &str) {
  FILE  *f;
  f = Swig_open((void *) name);
  if (!f) {
    fprintf(stderr,"SWIG Error. Unable to find %s. Possible installation problem.\n",name);
    FatalError();
    return -1;
  }
  copy_data(f,str);
  return 0;
}






