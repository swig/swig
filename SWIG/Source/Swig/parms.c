/* -----------------------------------------------------------------------------
 * parms.cxx
 *
 *     Parameter list class.
 *
 * !!! This file is deprecated and is being replaced !!!
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

#include "swig.h"

#define MAXPARMS 16

/* ------------------------------------------------------------------------
 * NewParm()
 *
 * Create a new parameter from datatype 'type' and name 'n'.
 * ------------------------------------------------------------------------ */

Parm *NewParm(DataType *type, char *n) {
  Parm *p = NewHash();
  
  if (type) {
    Setattr(p,"type", NewVoid(CopyDataType(type), (void (*)(void *)) DelDataType));
  }
  Setattr(p,"name",n);
  return p;
}

/* ------------------------------------------------------------------------
 * CopyParm()
 * ------------------------------------------------------------------------ */

Parm *CopyParm(Parm *p) {
  DataType *t;
  char     *name;
  char     *lname;
  char     *value;
  int       ignore;

  Parm *np = NewHash();
  t = GetVoid(p,"type");
  name = GetChar(p,"name");
  lname = GetChar(p,"lname");
  value = GetChar(p,"value");
  ignore = GetInt(p,"ignore");

  Setattr(np,"type",NewVoid(CopyDataType(t), (void (*)(void *)) DelDataType));
  if (name)
    Setattr(np,"name",name);
  if (lname)
    Setattr(np,"lname", lname);
  if (value)
    Setattr(np,"value", value);
  if (ignore)
    SetInt(np,"ignore", ignore);
  return np;
}

/* ------------------------------------------------------------------
 * NewParmList()
 * ------------------------------------------------------------------ */

ParmList *NewParmList() {
  return NewList();
}

/* ------------------------------------------------------------------
 * CopyParmList()
 * ------------------------------------------------------------------ */

ParmList *
CopyParmList(ParmList *l) {
  ParmList *nl;
  int i, len;

  nl = NewList();
  len = Len(l);
  for (i = 0; i < len; i++) {
    Parm *p = Getitem(l,i);
    Append(nl, CopyParm(p));
  }
  return nl;
}

/* ------------------------------------------------------------------
 * int ParmList_numarg()
 * ------------------------------------------------------------------ */

int ParmList_numarg(ParmList *l) {
  int  n = 0;
  Parm *p;

  p = Firstitem(l);
  while (p) {
    if (Getignore(p)) n++;
    p = Nextitem(l);
  }
  return n;
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generates a string of parameters
 * ---------------------------------------------------------------------- */

char *ParmList_str(ParmList *l) {
  static DOHString *out = 0;
  Parm *p;
  DataType *t;

  if (!out) out = NewString("");
  Clear(out);
  p = Firstitem(l);
  while(p) {
    t = Gettype(p);
    Printf(out,"%s", DataType_str(t,Getname(p)));
    p = Nextitem(l);
    if (p)
      Printf(out,",");
  }
  return Char(out);
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generate a prototype string.
 * ---------------------------------------------------------------------- */

char *ParmList_protostr(ParmList *l) {
  static DOHString *out = 0;
  Parm     *p;
  DataType *t;

  if (!out) out = NewString("");
  Clear(out);
  p = Firstitem(l);
  while(p) {
    t = Gettype(p);
    Printf(out,"%s", DataType_str(t,0));
    p = Nextitem(l);
    if (p)
      Printf(out,",");
  }
  return Char(out);
}



