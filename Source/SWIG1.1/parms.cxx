/* ----------------------------------------------------------------------------- 
 * parms.cxx
 *
 *     Parameter list class.
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

extern "C" {
  #include "doh.h"
}

// ------------------------------------------------------------------------
// NewParm()
//
// Create a new parameter from datatype 'type' and name 'n'.
// Copies will be made of type and n, unless they aren't specified.
// ------------------------------------------------------------------------

Parm *NewParm(DataType *type, char *n) {
  Parm *p = (Parm *) malloc(sizeof(Parm));
  if (type) {
    p->t = new DataType(type);
  } else {
    p->t = 0;
  }
  p->name = copy_string(n);
  p->call_type = 0;
  p->defvalue = 0;
  p->ignore = 0;
  p->objc_separator = 0;
  return p;
}

// ------------------------------------------------------------------------
// CopyParm(Parm *p)
//
// Make a copy of a parameter
// ------------------------------------------------------------------------

Parm *CopyParm(Parm *p) {
  Parm *np = (Parm *) malloc(sizeof(Parm));
  if (p->t) np->t = new DataType(p->t);
  np->name = copy_string(p->name);
  np->call_type = p->call_type;
  np->defvalue = copy_string(p->defvalue);
  np->ignore = p->ignore;
  np->objc_separator = copy_string(p->objc_separator);
  return np;
}

// ------------------------------------------------------------------------
// DelParm()
//
// Destroy a parameter
// ------------------------------------------------------------------------

void DelParm(Parm *p) {
  if (p->t) delete p->t;
  if (p->name) delete p->name;
  if (p->defvalue) delete p->defvalue;
  if (p->objc_separator) delete p->objc_separator;
  free(p);
}

// ------------------------------------------------------------------
// NewParmList()
//
// Create a new (empty) parameter list
// ------------------------------------------------------------------

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

// ------------------------------------------------------------------
// CopyParmList()
//
// Make a copy of parameter list
// ------------------------------------------------------------------

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

// ------------------------------------------------------------------
// DelParmList()
//
// Delete a parameter list
// ------------------------------------------------------------------
  
void DelParmList(ParmList *l) {
  int i;
  for (i = 0; i < l->maxparms; i++) {
    if (l->parms[i]) DelParm(l->parms[i]);
  }
  free(l->parms);
  free(l);
}


// ------------------------------------------------------------------
// moreparms()               (PRIVATE)
//
// Doubles the amount of parameter memory available.  
// ------------------------------------------------------------------

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

// ------------------------------------------------------------------
// void ParmList_append(ParmList *l, Parm *p)
//
// Add a new parameter to the end of a parameter list
// ------------------------------------------------------------------

void ParmList_append(ParmList *l, Parm *p) {

  if (l->nparms == l->maxparms) moreparms(l);

  // Add parm onto the end 

  l->parms[l->nparms] = CopyParm(p);
  l->nparms++;
}

// ------------------------------------------------------------------
// void ParmList_insert()
//
// Inserts a parameter at position pos.   Parameters are inserted
// *before* any existing parameter at position pos.
// ------------------------------------------------------------------

void ParmList_insert(ParmList *l, Parm *p, int pos) {

  // If pos is out of range, we'd better fix it

  if (pos < 0) pos = 0;
  if (pos > l->nparms) pos = l->nparms;

  // If insertion is going to need more memory, take care of that now

  if (l->nparms >= l->maxparms) moreparms(l);

  // Now shift all of the existing parms to the right

  for (int i = l->nparms; i > pos; i--) {
    l->parms[i] = l->parms[i-1];
  }

  // Set new parameter
  
  l->parms[pos] = CopyParm(p);
  l->nparms++;

}
  
// ------------------------------------------------------------------
// void ParmList_del()
//
// Deletes the parameter at position pos.
// ------------------------------------------------------------------

void ParmList_del(ParmList *l, int pos) {

  if (l->nparms <= 0) return;
  if (pos < 0) pos = 0;
  if (pos >= l->nparms) pos = l->nparms-1;

  // Delete the parameter (if it exists)

  if (l->parms[pos]) DelParm(l->parms[pos]);

  // Now slide all of the parameters to the left

  for (int i = pos; i < l->nparms-1; i++) {
    l->parms[i] = l->parms[i+1];
  }
  l->nparms--;

}

// ------------------------------------------------------------------
// Parm *ParmList_get(ParmList *l, int pos)
//
// Gets the parameter at location pos.  Returns 0 if invalid
// position.
// ------------------------------------------------------------------

Parm *ParmList_get(ParmList *l, int pos) {

  if ((pos < 0) || (pos >= l->nparms)) return 0;
  return l->parms[pos];
}

// ------------------------------------------------------------------
// int ParmList_numopt()
//
// Gets the number of optional arguments. 
// ------------------------------------------------------------------
int ParmList_numopt(ParmList *l) {
  int  n = 0;
  int  state = 0;

  for (int i = 0; i < l->nparms; i++) {
    if (l->parms[i]->defvalue) {
      n++;
      state = 1;
    } else if (typemap_check((char*)"default",typemap_lang,l->parms[i]->t,l->parms[i]->name)) {
      n++;
      state = 1;
    } else if (typemap_check((char*)"ignore",typemap_lang,l->parms[i]->t,l->parms[i]->name)) {
      n++;
    } else {
      if (state) {
	fprintf(stderr,"%s : Line %d.  Argument %d must have a default value!\n", input_file,line_number,i+1);
      }
    }
  }
  return n;
}

// ------------------------------------------------------------------
// int ParmList::numarg()
//
// Gets the number of arguments
// ------------------------------------------------------------------
int ParmList_numarg(ParmList *l) {
  int  n = 0;

  for (int i = 0; i < l->nparms; i++) {
    if (!l->parms[i]->ignore)
      n++;
  } 
  return n;
}

// ---------------------------------------------------------------------
// Parm * ParmList_first()
//
// Returns the first item on a parameter list.
// ---------------------------------------------------------------------

Parm *ParmList_first(ParmList *l) {
  l->current_parm = 0;
  if (l->nparms > 0) return l->parms[l->current_parm++];
  else return (Parm *) 0;
}

// ----------------------------------------------------------------------
// Parm *ParmList_next()
//
// Returns the next item on the parameter list.
// ----------------------------------------------------------------------

Parm * ParmList_next(ParmList *l) {
  if (l->current_parm >= l->nparms) return 0;
  else return l->parms[l->current_parm++];
}

// ---------------------------------------------------------------------
// void ParmList_print_types(DOHFile *f)
//
// Prints a comma separated list of all of the parameter types.
// This is for generating valid C prototypes.   Has to do some
// manipulation of pointer types depending on how the call_type
// variable has been set.
// ----------------------------------------------------------------------

void ParmList_print_types(ParmList *l, DOHFile *f) {

  int   is_pointer;
  int   pn;
  pn = 0;
  while(pn < l->nparms) {
    is_pointer = l->parms[pn]->t->is_pointer;
    if (l->parms[pn]->t->is_reference) {
      if (l->parms[pn]->t->is_pointer) {
	l->parms[pn]->t->is_pointer--;
	Printf(f,"%s&", l->parms[pn]->t->print_real());
	l->parms[pn]->t->is_pointer++;
      } else {
	Printf(f,"%s&", l->parms[pn]->t->print_real());
      }
    } else {
      if (l->parms[pn]->call_type & CALL_VALUE) l->parms[pn]->t->is_pointer++;
      if (l->parms[pn]->call_type & CALL_REFERENCE) l->parms[pn]->t->is_pointer--;
      Printf(f,"%s", l->parms[pn]->t->print_real());
      l->parms[pn]->t->is_pointer = is_pointer;
    }
    pn++;
    if (pn < l->nparms)
      Printf(f,",");
  }
}

// ---------------------------------------------------------------------
// void ParmList_print_args()
//
// Prints a comma separated list of all of the parameter arguments.
// ----------------------------------------------------------------------

void ParmList_print_args(ParmList *l, DOHFile *f) {

  int   is_pointer;
  int   pn;
  pn = 0;
  while(pn < l->nparms) {
    is_pointer = l->parms[pn]->t->is_pointer;
    if (l->parms[pn]->t->is_reference) {
      if (l->parms[pn]->t->is_pointer) {
	l->parms[pn]->t->is_pointer--;
	Printf(f,"%s&", l->parms[pn]->t->print_full());
	l->parms[pn]->t->is_pointer++;
      } else {
	Printf(f,"%s&", l->parms[pn]->t->print_full());
      }
    } else {
      if (l->parms[pn]->call_type & CALL_VALUE) l->parms[pn]->t->is_pointer++;
      if (l->parms[pn]->call_type & CALL_REFERENCE) l->parms[pn]->t->is_pointer--;
      Printf(f,"%s", l->parms[pn]->t->print_full());
      l->parms[pn]->t->is_pointer = is_pointer;
    }
    Printf(f,"%s",l->parms[pn]->name);
    pn++;
    if (pn < l->nparms)
      Printf(f,",");
  }
}

