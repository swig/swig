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
  if (p) {
    Parm_Setlname(p,name);
    return Parm_Getlname(p);
  } else {
    return name;
  }
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
  DOHString *fcall;

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
  DOHString *fcall;

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
	Printv(fcall, name, " = ", DataType_lcaststr(t,""), 0);
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
 * Swig_cfunction_call()
 *
 * Creates a string that calls a C function using the local variable rules
 * defined above.
 *
 *    name(arg0, arg1, arg2, ... argn)
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cfunction_call(DOHString_or_char *name, ParmList *parms) {
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
 * Swig_cmethod_call()
 *
 * Generates a string that calls a C++ method from a list of parameters.
 * 
 *    arg0->name(arg1, arg2, arg3, ..., argn)
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmethod_call(DOHString_or_char *name, ParmList *parms) {
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
 * Swig_cconstructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      (name *) calloc(1,sizeof(name));
 * ----------------------------------------------------------------------------- */

char *
Swig_cconstructor_call(DOHString_or_char *name) {
  static DOH *func = 0;

  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"(%s *) calloc(1, sizeof(%s))", name, name);
  return Char(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cppconstructor_call()
 *
 * Creates a string that calls a C function using the local variable rules
 * defined above.
 *
 *    name(arg0, arg1, arg2, ... argn)
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cppconstructor_call(DOHString_or_char *name, ParmList *parms) {
  static DOH *func = 0;
  int i = 0;
  Parm *p;
  DataType *pt;
  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"new %s(", name);
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
 * Swig_cdestructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      free((char *) arg0);
 * ----------------------------------------------------------------------------- */

char *
Swig_cdestructor_call() {
  static DOH *func = 0;

  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"free((char *) %s)", Swig_cparm_name(0,0));
  return Char(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cppdestructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      delete arg0;
 * ----------------------------------------------------------------------------- */

char *
Swig_cppdestructor_call() {
  static DOH *func = 0;

  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"delete %s", Swig_cparm_name(0,0));
  return Char(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cmemberset_call()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name = arg1
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmemberset_call(DOHString_or_char *name, DataType *type) {
  static DOH *func = 0;

  if (!func) func = NewString("");
  Clear(func);

  if ((type->type == T_USER) && (type->is_pointer == 0)) {
    Printf(func,"%s %s->%s; ", Swig_clocal_assign(type,""), Swig_cparm_name(0,0), name);
  } else {
    Printf(func,"%s ", Swig_clocal_assign(type,""));
  }
  Printf(func,"(%s->%s = ", Swig_cparm_name(0,0), name);
  Printf(func,"%s)", Swig_clocal_deref(type, Swig_cparm_name(0,1)));
  return Char(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cmemberget_call()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name
 *
 * ----------------------------------------------------------------------------- */

char *
Swig_cmemberget_call(DOHString_or_char *name, DataType *t) {
  static DOH *func = 0;

  if (!func) func = NewString("");
  Clear(func);

  Printf(func,"%s (%s->%s)", Swig_clocal_assign(t,""),Swig_cparm_name(0,0), name);
  return Char(func);
}


static void fix_parm_names(ParmList *l) {
  int i = 0;
  Parm *p;

  p = ParmList_first(l);
  while (p) {
    if (!Parm_Getname(p)) {
      char temp[64];
      sprintf(temp,"arg%d",i);
      Parm_Setname(p,temp);
    }
    i++;
    p = ParmList_next(l);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_cfunction_wrapper()
 *
 * This function creates a C wrapper around a C++ method.  Returns a Wrapper
 * object containing the code, parameters, and so forth.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cfunction_wrapper(DOHString_or_char *funcname,
		       DataType *rtype,
		       ParmList *parms,
		       DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,funcname);

  l = CopyParmList(parms);

  fix_parm_names(l);

  Printf(w->def,"%s %s(%s)", DataType_str(rtype,0), funcname, ParmList_str(l));

  if (code) {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,rtype);
  Wrapper_Setparms(w,l);

  DelParmList(l);
  return w;
}
  
/* -----------------------------------------------------------------------------
 * Swig_cmethod_wrapper()
 *
 * This function creates a C wrapper around a C++ method.  Returns a Wrapper
 * object containing the code, parameters, and so forth.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmethod_wrapper(DOHString_or_char *classname,
		     DOHString_or_char *methodname,
		     DataType *rtype,
		     ParmList *parms,
		     DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  DataType *t;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, methodname));

  l = CopyParmList(parms);
  t = NewDataType(T_USER);
  strcpy(t->name,Char(classname));
  t->is_pointer++;
  p = NewParm(t,"self");
  ParmList_insert(l,p,0);
  DelDataType(t);
  DelParm(p);

  fix_parm_names(l);

  Printf(w->def,"%s %s(%s)", DataType_str(rtype,0), Swig_name_member(classname, methodname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    
    if ((rtype->type != T_VOID) || (rtype->is_pointer)) {
      Printf(w->code,"return ");
    }
    
    Printf(w->code,"self->%s(", methodname);
    p = ParmList_first(l);
    p = ParmList_next(l);
    while (p) {
      Printf(w->code,"%s", Parm_Getname(p));
      p = ParmList_next(l);
      if (p) 
	Printf(w->code,",");
    }
    Printf(w->code,");\n");
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,rtype);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cconstructor_wrapper()
 *
 * This function creates a C wrapper for a C constructor function. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cconstructor_wrapper(DOHString_or_char *classname,
			  ParmList *parms,
			  DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  DataType *t;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_construct(classname));

  l = CopyParmList(parms);
  t = NewDataType(T_USER);
  sprintf(t->name,classname);
  t->is_pointer++;

  /* Patch up the argument names */
  fix_parm_names(l);

  Printf(w->def,"%s %s(%s)", DataType_str(t,0), Swig_name_construct(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"return (%s) calloc(1,sizeof(%s));\n", DataType_str(t,0), classname);
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(t);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cppconstructor_wrapper()
 *
 * This function creates a C wrapper for a C++ constructor function. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cppconstructor_wrapper(DOHString_or_char *classname,
			  ParmList *parms,
			  DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  DataType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_construct(classname));

  l = CopyParmList(parms);
  t = NewDataType(T_USER);
  sprintf(t->name,classname);
  t->is_pointer++;

  /* Patch up the argument names */
  fix_parm_names(l);

  Printf(w->def,"%s %s(%s)", DataType_str(t,0), Swig_name_construct(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"return new %s", DataType_str(t,0));
    p = ParmList_first(l);
    if (p) {
      Printf(w->code,"(");
      while (p) {
	Printf(w->code,"%s", Parm_Getname(p));
	p = ParmList_next(l);
	if (p)
	  Printf(w->code,",");
      }
      Printf(w->code,")");
    }
    Printf(w->code,";\n");
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(t);
  return w;
}
  

/* -----------------------------------------------------------------------------
 * Swig_cdestructor_wrapper()
 *
 * This function creates a C wrapper for a C destructor. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cdestructor_wrapper(DOHString_or_char *classname,
			  DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  DataType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_destroy(classname));

  l = NewParmList();
  t = NewDataType(T_USER);
  sprintf(t->name,classname);
  t->is_pointer++;
  p = NewParm(t,"self");
  ParmList_append(l,p);
  DelParm(p);
  DelDataType(t);

  t = NewDataType(T_VOID);

  Printf(w->def,"%s %s(%s)", DataType_str(t,0), Swig_name_destroy(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"free((char *) self);\n");
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(t);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cppdestructor_wrapper()
 *
 * This function creates a C wrapper for a C++ destructor. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cppdestructor_wrapper(DOHString_or_char *classname,
			  DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  DataType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_destroy(classname));

  l = NewParmList();
  t = NewDataType(T_USER);
  sprintf(t->name,classname);
  t->is_pointer++;
  p = NewParm(t,"self");
  ParmList_append(l,p);
  DelParm(p);
  DelDataType(t);

  t = NewDataType(T_VOID);

  Printf(w->def,"%s %s(%s)", DataType_str(t,0), Swig_name_destroy(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"delete self;\n");
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(t);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cmemberset_wrapper()
 *
 * This function creates a C wrapper for setting a C++ structure member.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmemberset_wrapper(DOHString_or_char *classname,
			DOHString_or_char *membername,
			DataType *type,
			DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  DataType *t;
  DataType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, Swig_name_set(membername)));

  l = NewParmList();
  t = NewDataType(T_USER);
  strcpy(t->name,Char(classname));
  t->is_pointer++;
  p = NewParm(t,"self");
  ParmList_append(l,p);
  DelDataType(t);
  DelParm(p);

  lt = Swig_clocal_type(type);
  p = NewParm(lt,"value");
  ParmList_append(l,p);
  DelParm(p);
  
  Printf(w->def,"%s %s(%s)", DataType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"self->%s = %s;\n", membername, Swig_clocal_deref(lt,"value"));
    Printf(w->code,"return %s self->%s;\n", Swig_clocal_assign(lt,""), membername);
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(lt);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cmemberget_wrapper()
 *
 * This function creates a C wrapper for getting a structure member
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmemberget_wrapper(DOHString_or_char *classname,
			DOHString_or_char *membername,
			DataType *type,
			DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  DataType *t;
  DataType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, Swig_name_get(membername)));

  l = NewParmList();
  t = NewDataType(T_USER);
  strcpy(t->name,Char(classname));
  t->is_pointer++;
  p = NewParm(t,"self");
  ParmList_append(l,p);
  DelDataType(t);
  DelParm(p);

  lt = Swig_clocal_type(type);
  Printf(w->def,"%s %s(%s)", DataType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"return %s self->%s;", Swig_clocal_assign(lt,""), membername);
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(lt);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cvarset_wrapper()
 *
 * This function creates a C wrapper for setting a global variable.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cvarset_wrapper(DOHString_or_char *varname,
		     DataType *type,
		     DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  DataType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_set(varname));

  l = NewParmList();
  lt = Swig_clocal_type(type);
  p = NewParm(lt,"value");
  ParmList_append(l,p);
  DelParm(p);
  
  Printf(w->def,"%s %s(%s)", DataType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"%s = %s;\n", varname, Swig_clocal_deref(lt,"value"));
    Printf(w->code,"return %s;\n", Swig_clocal_assign(lt,varname));
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
    Replace(w->code,"$target",varname, DOH_REPLACE_ANY);
    Replace(w->code,"$source","value", DOH_REPLACE_ANY);
    Replace(w->code,"$ltype", DataType_str(lt,""), DOH_REPLACE_ANY);
    Replace(w->code,"$rtype", DataType_str(type,""), DOH_REPLACE_ANY);
  }
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(lt);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cvarget_wrapper()
 *
 * This function creates a C wrapper for getting a structure member
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cvarget_wrapper(DOHString_or_char *varname,
                     DataType *type,
                     DOHString_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  DataType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w, Swig_name_get(varname));

  l = NewParmList();

  lt = Swig_clocal_type(type);

  Printf(w->def,"%s %s(%s)", DataType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->def," {\n");
    Printf(w->code,"return %s;", Swig_clocal_assign(type,varname));
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  DelParmList(l);
  DelDataType(lt);
  return w;
}





