/* ----------------------------------------------------------------------------- 
 * internal.h
 *
 *     Internal declarations used by the SWIG core
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.	
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#include "swig11.h"

extern    Language      *lang;
extern    int           ForceExtern;
extern    int           WrapExtern;
extern    void         *CCode;
extern    int           GenerateDefault;
extern    char         *objc_construct;
extern    char         *objc_destruct;

// Structure for holding typemap parameters

struct TMParm {
  Parm     *p;
  ParmList *args;
  TMParm   *next;
  TMParm() {
    next = 0;
  }
};

/* Number of initialization names that can be used */

#define NI_NAMES    512

// Some functions for emitting some C++ helper code
extern void cplus_emit_member_func(char *classname, char *classtype, char *classrename,
                                   char *mname, char *mrename, SwigType *type, ParmList *l,
                                   int mode);

extern void cplus_emit_static_func(char *classname, char *classtype, char *classrename,
                                   char *mname, char *mrename, SwigType *type, ParmList *l,
                                   int mode);

extern void cplus_emit_destructor(char *classname, char *classtype, char *classrename,
                                  char *name, char *iname, int mode);

extern void cplus_emit_constructor(char *classname, char *classtype, char *classrename,
                                   char *name, char *iname, ParmList *l, int mode);

extern void cplus_emit_variable_get(char *classname, char *classtype, char *classrename,
				    char *name, char *iname, SwigType *type, int mode);

extern void cplus_emit_variable_set(char *classname, char *classtype, char *classrename,
				    char *name, char *iname, SwigType *type, int mode);

extern char *cplus_base_class(char *name);

