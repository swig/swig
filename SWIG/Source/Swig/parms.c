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

Parm *NewParm(SwigType *type, String_or_char *n) {
  Parm *p = NewHash();
  
  if (type) {
    Setattr(p,"type", Copy(type));
  }
  Setattr(p,"name",n);
  return p;
}

/* ------------------------------------------------------------------------
 * CopyParm()
 * ------------------------------------------------------------------------ */

Parm *CopyParm(Parm *p) {
  SwigType *t;
  char     *name;
  char     *lname;
  char     *value;
  int       ignore;
  char     *alttype;

  Parm *np = NewHash();
  t = Getattr(p,"type");
  name = GetChar(p,"name");
  lname = GetChar(p,"lname");
  value = GetChar(p,"value");
  ignore = GetInt(p,"ignore");
  alttype = GetChar(p,"alttype");

  if (t) 
    Setattr(np,"type",Copy(t));
  if (name)
    Setattr(np,"name",name);
  if (lname)
    Setattr(np,"lname", lname);
  if (value)
    Setattr(np,"value", value);
  if (ignore)
    SetInt(np,"ignore", ignore);
  if (alttype) 
    Setattr(np,"alttype", alttype);
      
  return np;
}

/* ------------------------------------------------------------------
 * CopyParmList()
 * ------------------------------------------------------------------ */

ParmList *
CopyParmList(ParmList *p) {
  Parm *np;
  Parm *pp = 0;
  Parm *fp = 0;

  if (!p) return 0;

  while (p) {
    np = CopyParm(p);
    if (pp) {
      set_nextSibling(pp,np);
    } else {
      fp = np;
    }
    pp = np;
    p = nextSibling(p);
  }
  return fp;
}

/* ------------------------------------------------------------------
 * int ParmList_numarg()
 * ------------------------------------------------------------------ */

int ParmList_numarg(ParmList *p) {
  int  n = 0;
  while (p) {
    if (!Getattr(p,"ignore")) n++;
    p = nextSibling(p);
  }
  return n;
}

/* -----------------------------------------------------------------------------
 * int ParmList_numrequired().  Return number of required arguments
 * ----------------------------------------------------------------------------- */

int ParmList_numrequired(ParmList *p) {
  int i = 0;
  while (p) {
    SwigType *t = Getattr(p,"type");
    String   *value = Getattr(p,"value");
    if (value) return i;
    if (!(SwigType_type(t) == T_VOID)) i++;
    else break;
    p = nextSibling(p);
  }
  return i;
}

/* -----------------------------------------------------------------------------
 * int ParmList_len()
 * ----------------------------------------------------------------------------- */

int ParmList_len(ParmList *p) {
  int i = 0;
  while (p) {
    i++;
    p = nextSibling(p);
  }
  return i;
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generates a string of parameters
 * ---------------------------------------------------------------------- */

String *ParmList_str(ParmList *p) {
  String *out;
  SwigType *t;

  out = NewString("");
  while(p) {
    t = Getattr(p,"type");
    Printf(out,"%s", SwigType_str(t,Getattr(p,"name")));
    p = nextSibling(p);
    if (p)
      Printf(out,",");
  }
  return out;
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generate a prototype string.
 * ---------------------------------------------------------------------- */

String *ParmList_protostr(ParmList *p) {
  String *out;
  SwigType *t;

  out = NewString("");
  while(p) {
    t = Getattr(p,"type");
    Printf(out,"%s", SwigType_str(t,0));
    p = nextSibling(p);
    if (p)
      Printf(out,",");
  }
  return out;
}



