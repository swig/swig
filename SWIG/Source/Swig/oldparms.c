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
  Parm *p = (Parm *) malloc(sizeof(Parm));
  if (type) {
    p->_type = CopyDataType(type);
  } else {
    p->_type = 0;
  }
  p->_name = Swig_copy_string(n);
  p->_lname = 0;
  p->_defvalue = 0;
  p->ignore = 0;
  return p;
}

/* ------------------------------------------------------------------------
 * CopyParm()
 * ------------------------------------------------------------------------ */

Parm *CopyParm(Parm *p) {
  Parm *np = (Parm *) malloc(sizeof(Parm));
  if (p->_type) np->_type = CopyDataType(p->_type);
  np->_name = Swig_copy_string(p->_name);
  np->_defvalue = Swig_copy_string(p->_defvalue);
  np->_lname = Swig_copy_string(p->_lname);
  np->ignore = p->ignore;
  return np;
}

/* ------------------------------------------------------------------------
 * DelParm()
 * ------------------------------------------------------------------------ */

void DelParm(Parm *p) {
  if (p->_type) DelDataType(p->_type);
  if (p->_name) free(p->_name);
  if (p->_defvalue) free(p->_defvalue);
  if (p->_lname) free(p->_lname);
  free(p);
}

void Parm_Settype(Parm *p, DataType *t) {
  if (p->_type) DelDataType(p->_type);
  p->_type = CopyDataType(t);
}

DataType *Parm_Gettype(Parm *p) {
  return p->_type;
}

void Parm_Setname(Parm *p, char *n) {
  if (p->_name) free(p->_name);
  p->_name = Swig_copy_string(n);
}

char *Parm_Getname(Parm *p) {
  return p->_name;
}

void Parm_Setlname(Parm *p, char *n) {
  if (p->_lname) free(p->_lname);
  p->_lname = Swig_copy_string(n);
}

char *Parm_Getlname(Parm *p) {
  return p->_lname;
}

void Parm_Setvalue(Parm *p, char *v) {
  if (p->_defvalue) free(p->_defvalue);
  p->_defvalue = Swig_copy_string(v);
}

char *Parm_Getvalue(Parm *p) {
  return p->_defvalue;
}

/* ------------------------------------------------------------------
 * NewParmList()
 * ------------------------------------------------------------------ */

ParmList *NewParmList() {
  int i;
  ParmList *l = (ParmList *) malloc(sizeof(ParmList));
  l->nparms = 0;
  l->maxparms = MAXPARMS;
  l->parms = (Parm **) malloc(MAXPARMS*sizeof(Parm *));
  for (i = 0; i < MAXPARMS; i++) {
    l->parms[i] = 0;
  }
  return l;
}

/* ------------------------------------------------------------------
 * CopyParmList()
 * ------------------------------------------------------------------ */

ParmList *
CopyParmList(ParmList *l) {
  ParmList *nl;
  int i;

  if (l) {
    nl = (ParmList *) malloc(sizeof(ParmList));
    nl->nparms = l->nparms;
    nl->maxparms = l->maxparms;
    nl->parms = (Parm **) malloc(l->maxparms*sizeof(Parm*));

    for (i = 0; i < l->maxparms; i++) {
      if (l->parms[i])
	nl->parms[i] = CopyParm(l->parms[i]);
      else
	nl->parms[i] = 0;
    }
    return nl;
  } else {
    return NewParmList();
  }
}

/* ------------------------------------------------------------------
 * DelParmList()
 * ------------------------------------------------------------------ */

void DelParmList(ParmList *l) {
  int i;
  if (NULL == l) return;
  for (i = 0; i < l->maxparms; i++) {
    if (l->parms[i]) DelParm(l->parms[i]);
  }
  free(l->parms);
  free(l);
}


/* ------------------------------------------------------------------
 * moreparms()  - Increase memory for parameter list
 * ------------------------------------------------------------------ */

static void moreparms(ParmList *l) {
  Parm  **newparms;
  int     i;

  newparms = (Parm **) malloc(2*l->maxparms*sizeof(Parm *));
  for (i = 0; i < 2*l->maxparms; i++)
    newparms[i] = (Parm *) 0;
  for (i = 0; i < l->maxparms; i++) {
    newparms[i] = l->parms[i];
  }
  l->maxparms = 2*l->maxparms;
  free(l->parms);
  l->parms = newparms;
}

/* ------------------------------------------------------------------
 * void ParmList_append(ParmList *l, Parm *p)
 * ------------------------------------------------------------------ */

void ParmList_append(ParmList *l, Parm *p) {

  if (l->nparms == l->maxparms) moreparms(l);
  l->parms[l->nparms] = CopyParm(p);
  l->nparms++;
}

/* ------------------------------------------------------------------
 * void ParmList_insert()
 * ------------------------------------------------------------------ */

void ParmList_insert(ParmList *l, Parm *p, int pos) {
  int i;
  /* If pos is out of range, we'd better fix it */

  if (pos < 0) pos = 0;
  if (pos > l->nparms) pos = l->nparms;

  /* If insertion is going to need more memory, take care of that now */

  if (l->nparms >= l->maxparms) moreparms(l);

  /* Now shift all of the existing parms to the right */

  for (i = l->nparms; i > pos; i--) {
    l->parms[i] = l->parms[i-1];
  }

  /* Set new parameter */

  l->parms[pos] = CopyParm(p);
  l->nparms++;

}

/* ------------------------------------------------------------------
 * void ParmList_del()
 * ------------------------------------------------------------------ */

void ParmList_del(ParmList *l, int pos) {
  int i;
  if (l->nparms <= 0) return;
  if (pos < 0) pos = 0;
  if (pos >= l->nparms) pos = l->nparms-1;

  /* Delete the parameter (if it exists) */

  if (l->parms[pos]) DelParm(l->parms[pos]);

  /* Now slide all of the parameters to the left */

  for (i = pos; i < l->nparms-1; i++) {
    l->parms[i] = l->parms[i+1];
  }
  l->nparms--;

}

/* ------------------------------------------------------------------
 * Parm *ParmList_get()
 * ------------------------------------------------------------------ */

Parm *ParmList_get(ParmList *l, int pos) {

  if ((pos < 0) || (pos >= l->nparms)) return 0;
  return l->parms[pos];
}

/* ------------------------------------------------------------------
 * int ParmList_numarg()
 * ------------------------------------------------------------------ */

int ParmList_numarg(ParmList *l) {
  int  n = 0;
  int  i;
  for (i = 0; i < l->nparms; i++) {
    if (!l->parms[i]->ignore)
      n++;
  }
  return n;
}

/* ---------------------------------------------------------------------
 * Parm * ParmList_first()
 * --------------------------------------------------------------------- */

Parm *ParmList_first(ParmList *l) {
  l->current_parm = 0;
  if (l->nparms > 0) return l->parms[l->current_parm++];
  else return (Parm *) 0;
}

/* ----------------------------------------------------------------------
 * Parm *ParmList_next()
 * ---------------------------------------------------------------------- */

Parm * ParmList_next(ParmList *l) {
  if (l->current_parm >= l->nparms) return 0;
  else return l->parms[l->current_parm++];
}

/* ---------------------------------------------------------------------
 * void ParmList_print_types(DOHFile *f)
 *
 * Prints a comma separated list of all of the parameter types.
 * This is for generating valid C prototypes. 
 * ---------------------------------------------------------------------- */

void ParmList_print_types(ParmList *l, DOHFile *f) {

  int   is_pointer;
  int   pn;
  DataType *t;
  pn = 0;
  while(pn < l->nparms) {
    t = Parm_Gettype(l->parms[pn]);
    Printf(f,"%s", DataType_str(t,0));
    pn++;
    if (pn < l->nparms)
      Printf(f,",");
  }
}

/* ---------------------------------------------------------------------
 * void ParmList_print_args()
 *
 * Prints a comma separated list of all of the parameter arguments.
 * ---------------------------------------------------------------------- */

void ParmList_print_args(ParmList *l, DOHFile *f) {
  int   is_pointer;
  int   pn;
  DataType *t;
  pn = 0;
  while(pn < l->nparms) {
    t = Parm_Gettype(l->parms[pn]);
    Printf(f,"%s", DataType_str(t,Parm_Getname(l->parms[pn])));
    pn++;
    if (pn < l->nparms)
      Printf(f,",");
  }
}



