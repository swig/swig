/* -----------------------------------------------------------------------------
 * cwrap.c
 *
 *     This file defines a variety of wrapping rules for C/C++ handling including
 *     the naming of local variables, calling conventions, and so forth.
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

/* -----------------------------------------------------------------------------
 * Swig_parm_name()
 *
 * Generates a name for the ith argument in an argument list
 * ----------------------------------------------------------------------------- */

char *
Swig_cparm_name(Parm *p, int i) {
  static char name[256];
  sprintf(name,"arg%d",i);
  Parm_Setlname(p,name);
  return Parm_Getlname(p);
}

/* -----------------------------------------------------------------------------
 * Swig_clocal()
 *
 * Creates a string that declares a C local variable type.  Converts references
 * and user defined types to pointers.
 * ----------------------------------------------------------------------------- */

char *
Swig_clocal(DataType *t, DOHString_or_char *name, DOHString_or_char *value) {
  static DOHString *decl = 0;

  if (!decl) decl = NewString("");
  Clear(decl);
  if ((t->type != T_VOID) || (t->is_pointer)) {
    if ((t->type == T_USER) && (!t->is_pointer)) {
      t->is_pointer++;
      if (value) 
	Printf(decl,"%s = &%s", DataType_lstr(t,name), value);
      else
	Printf(decl,"%s", DataType_lstr(t,name));
      t->is_pointer--;
    } else if (t->is_reference) {
      if (value) 
	Printf(decl,"%s = &%s", DataType_lstr(t,name), value);
      else
	Printf(decl,"%s", DataType_lstr(t,name));
    } else {
      if (value)
	Printf(decl,"%s = %s", DataType_lstr(t,name), value);
      else
	Printf(decl,"%s", DataType_lstr(t,name));
    }
  }
  return Char(decl);
}

/* -----------------------------------------------------------------------------
 * Swig_clocal_type()
 *
 * Creates a string that declares a C local variable type.  Converts references
 * and user defined types to pointers.
 * ----------------------------------------------------------------------------- */

DataType *
Swig_clocal_type(DataType *t) {
  DataType *ty;
  if ((t->type != T_VOID) || (t->is_pointer)) {
    if ((t->type == T_USER) && (!t->is_pointer)) {
      t->is_pointer++;
      ty = DataType_ltype(t);
      t->is_pointer--;
    } else {
      ty = DataType_ltype(t);
    }
  } else {
    ty = DataType_ltype(t);
  }
  return ty;
}


/* -----------------------------------------------------------------------------
 * Swig_clocal_deref()
 *
 * Creates a string that can be used to deref a local variable wrapped with 
 * the Swig_clocal() function.
 * ----------------------------------------------------------------------------- */

char *
Swig_clocal_deref(DataType *t, DOHString_or_char *name) {
  static char temp[256];
  if ((t->type != T_VOID) || (t->is_pointer)) {
    if ((t->type == T_USER) && (!t->is_pointer)) {
      sprintf(temp,"*%s",Char(name));
    } else {
      sprintf(temp,DataType_rcaststr(t,name));
    }
  } else {
    strcpy(temp,"");
  }
  return temp;
}

/* -----------------------------------------------------------------------------
 * Swig_clocal_assign()
 *
 * Assigns a value to a local
 * ----------------------------------------------------------------------------- */

char *
Swig_clocal_assign(DataType *t, DOHString_or_char *name) {
  static char temp[256];
  if ((t->type != T_VOID) || (t->is_pointer)) {
    if ((t->type == T_USER) && (!t->is_pointer)) {
      sprintf(temp,"&%s",Char(name));
    } else {
      sprintf(temp,DataType_lcaststr(t,name));
    }
  } else {
    strcpy(temp,"");
  }
  return temp;
}

/* -----------------------------------------------------------------------------
 * Swig_cargs()
 *
 * Emit all of the local variables for a list of parameters.  Returns the
 * number of parameters.
 * ----------------------------------------------------------------------------- */

int Swig_cargs(Wrapper *w, ParmList *l) {
  Parm *p;
  int   i;
  DataType *pt;
  char      *pvalue;
  char      *pname;
  char      *local;
  char      *lname;

  i = 0;
  p = ParmList_first(l);
  while (p != 0) {
    lname  = Swig_cparm_name(p,i);
    pt     = Parm_Gettype(p);
    pname  = Parm_Getname(p);
    pvalue = Parm_Getvalue(p);
    local  = Swig_clocal(pt,lname,pvalue);
    Wrapper_add_localv(w,lname,local,0);
    i++;
    p = ParmList_next(l);
  }
  return(i);
}

/* -----------------------------------------------------------------------------
 * Swig_cresult()
 *
 * This function generates the C code needed to set the result of a C
 * function call.  
 * ----------------------------------------------------------------------------- */

void Swig_cresult(Wrapper *w, DataType *t, DOHString_or_char *name, DOHString_or_char *decl) {
  int  i;
  Parm  *p;
  DOHString *fcall;
  char *tm;

  fcall = NewString("");
  if ((t->type != T_VOID) || (t->is_pointer)) {
    Wrapper_add_localv(w,name, Swig_clocal(t,name,0), 0);
    if ((t->type == T_USER) && (!t->is_pointer)) {
      t->is_pointer++;
      Printv(fcall, name, " = (", DataType_lstr(t,0), ") malloc(sizeof(", 0);
      t->is_pointer--;
      Printv(fcall, DataType_str(t,0), "));\n", 0);
      Printv(fcall, "*(", name, ") = ", 0);
    } else {
      /* Is this a reference? */
      if (t->is_reference) {
	Printv(fcall, DataType_str(t,"_result_ref")," = ", 0);
      } else {
	/* Normal return value */
	if (DataType_qualifier(t)) {
	  Printv(fcall, name, " = (", DataType_lstr(t,0), ")", 0);
	} else {
	  Printv(fcall, name, " = ", 0);
	}
      }
    }
  }

  /* Now print out function call */
  Printv(fcall, decl, ";\n", 0);

  if (t->is_reference) {
    Printv(fcall, name, " = (",  DataType_lstr(t,0), ") &_result_ref;\n", 0);
  }

  if (Replace(w->code,"$function",fcall, DOH_REPLACE_ANY) == 0) {
    Printv(w->code, fcall, 0);
  }
  Delete(fcall);
}

/* -----------------------------------------------------------------------------
 * Swig_cppresult()
 *
 * This function generates the C++ code needed to set the result.   This uses
 * the C++ default copy constructor for user defined objects.
 * ----------------------------------------------------------------------------- */

void Swig_cppresult(Wrapper *w, DataType *t, DOHString_or_char *name, DOHString_or_char *decl) {
  int  i;
  Parm  *p;
  DOHString *fcall;
  char *tm;

  fcall = NewString("");
  if ((t->type != T_VOID) || (t->is_pointer)) {
    Wrapper_add_localv(w,name, Swig_clocal(t,name,0), 0);
    if ((t->type == T_USER) && (!t->is_pointer)) {
      Printv(fcall, name, " = new ", DataType_str(t,0), "(", 0);
    } else {
      /* Is this a reference? */
      if (t->is_reference) {
	Printv(fcall, DataType_str(t,"_result_ref")," = ", 0);
      } else {
	/* Normal return value */
	Printv(fcall, name, " = (", DataType_lstr(t,0), ")", 0);
      }
    }
  }

  /* Now print out function call */
  Printv(fcall, decl, 0);

  if ((t->type == T_USER) && (!t->is_pointer)) {
    Printf(fcall,")");
  }
  Printf(fcall,";\n");

  if (t->is_reference) {
    Printv(fcall, name, " = (",  DataType_lstr(t,0), ") &_result_ref;\n", 0);
  }

  if (Replace(w->code,"$function",fcall, DOH_REPLACE_ANY) == 0) {
    Printv(w->code, fcall, 0);
  }
  Delete(fcall);
}

/* -----------------------------------------------------------------------------
 * Swig_cfunction()
 *
 * Creates a string that calls a C function using the local variable rules
 * defined above.
 *
 *    name(arg0, arg1, arg2, ... argn)
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cfunction(DOHString_or_char *name, ParmList *parms) {
  static DOH *func = 0;
  int i = 0;
  Parm *p;
  DataType *pt;

  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"%s(", name);

  p = ParmList_first(parms);
  while (p) {
    pt = Parm_Gettype(p);
    Printf(func,"%s", Swig_clocal_deref(pt, Swig_cparm_name(p,i)));
    i++;
    p = ParmList_next(parms);
    if (p) 
      Printf(func,",");
  }
  Printf(func,")");
  return Char(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cmethod()
 *
 * Generates a string that calls a C++ method from a list of parameters.
 * 
 *    arg0->name(arg1, arg2, arg3, ..., argn)
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmethod(DOHString_or_char *name, ParmList *parms) {
  static DOH *func = 0;
  int i = 0;
  Parm *p;
  DataType *pt;

  if (!func) func = NewString("");
  Clear(func);

  p = ParmList_first(parms);

  if (!p) return "";
  Printf(func,"%s->%s(", Swig_cparm_name(p,0), name);
  i++;
  p = ParmList_next(parms);
  while (p) {
    pt = Parm_Gettype(p);
    Printf(func,"%s", Swig_clocal_deref(pt, Swig_cparm_name(p,i)));
    i++;
    p = ParmList_next(parms);
    if (p) 
      Printf(func,",");
  }
  Printf(func,")");
  return Char(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cmember_set()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name = arg1
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmember_set(DOHString_or_char *name, ParmList *parms) {
  static DOH *func = 0;
  Parm *p;
  DataType *pt;

  if (!func) func = NewString("");
  Clear(func);

  if (ParmList_numarg(parms) != 2) {
    printf("Swig_cmember_set called with wrong # args!\n");
    abort();
  }

  p = ParmList_first(parms);
  Printf(func,"(%s->%s = ", Swig_cparm_name(p,0), name);
  p = ParmList_next(parms);
  pt = Parm_Gettype(p);
  Printf(func,"%s", Swig_clocal_deref(pt, Swig_cparm_name(p,1)));
  Printf(func,")");
  return Char(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cmember_get()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmember_get(DOHString_or_char *name, ParmList *parms) {
  static DOH *func = 0;
  Parm *p;
  DataType *pt;

  if (!func) func = NewString("");
  Clear(func);

  if (ParmList_numarg(parms) != 1) {
    printf("Swig_cmember_get called with wrong # args!\n");
    abort();
  }

  p = ParmList_first(parms);
  Printf(func,"(%s->%s)", Swig_cparm_name(p,0), name);
  return Char(func);
}








