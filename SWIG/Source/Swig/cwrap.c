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

String *
Swig_cparm_name(Parm *p, int i) {
  String *name = NewStringf("arg%d",i);
  if (p) {
    Setlname(p,name);
  }
  return Swig_temp_result(name);
}

/* -----------------------------------------------------------------------------
 * Swig_clocal()
 *
 * Creates a string that declares a C local variable type.  Converts references
 * and user defined types to pointers.
 * ----------------------------------------------------------------------------- */

String *
Swig_clocal(SwigType *t, String_or_char *name, String_or_char *value) {
  String *decl;

  decl = NewString("");
  switch(SwigType_type(t)) {
  case T_USER:
    SwigType_add_pointer(t);
    if (value) 
      Printf(decl,"%s = &%s", SwigType_lstr(t,name), value);
    else
      Printf(decl,"%s", SwigType_lstr(t,name));
    SwigType_del_pointer(t);
    break;
  case T_REFERENCE:
    if (value) 
      Printf(decl,"%s = &%s", SwigType_lstr(t,name), value);
    else
      Printf(decl,"%s", SwigType_lstr(t,name));
    break;
  case T_VOID:
    break;
  default:
    if (value)
      Printf(decl,"%s = %s", SwigType_lstr(t,name), value);
    else
      Printf(decl,"%s", SwigType_lstr(t,name));
  }
  return Swig_temp_result(decl);
}

/* -----------------------------------------------------------------------------
 * Swig_clocal_type()
 *
 * Creates a string that declares a C local variable type.  Converts references
 * and user defined types to pointers.
 * ----------------------------------------------------------------------------- */

SwigType *
Swig_clocal_type(SwigType *t) {
  SwigType *ty;
  switch(SwigType_type(t)) {
  case T_USER:
    SwigType_add_pointer(t);
    ty = SwigType_ltype(t);
    SwigType_del_pointer(t);
    break;
  default:
    ty = SwigType_ltype(t);
    break;
  }
  return ty;
}

/* -----------------------------------------------------------------------------
 * Swig_clocal_deref()
 *
 * Creates a string that can be used to deref a local variable wrapped with 
 * the Swig_clocal() function.
 * ----------------------------------------------------------------------------- */

String *
Swig_clocal_deref(SwigType *t, String_or_char *name) {
  switch(SwigType_type(t)) {
  case T_USER:
    return Swig_temp_result(NewStringf("*%s",name));
    break;
  case T_VOID:
    return Swig_temp_result(NewString(""));
    break;
  default:
    return SwigType_rcaststr(t,name);
    break;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_clocal_assign()
 *
 * Assigns a value to a local
 * ----------------------------------------------------------------------------- */

String *
Swig_clocal_assign(SwigType *t, String_or_char *name) {
  switch(SwigType_type(t)) {
  case T_VOID:
    return Swig_temp_result(NewString(""));
    break;
  case T_USER:
    return Swig_temp_result(NewStringf("&%s", name));
    break;
  default:
    return SwigType_lcaststr(t,name);
    break;
  }
}

/* -----------------------------------------------------------------------------
 * Swig_cargs()
 *
 * Emit all of the local variables for a list of parameters.  Returns the
 * number of parameters.
 * ----------------------------------------------------------------------------- */

int Swig_cargs(Wrapper *w, ParmList *p) {
  int   i;
  SwigType *pt;
  String  *pvalue;
  String  *pname;
  String  *local;
  String  *lname;

  i = 0;
  while (p != 0) {
    lname  = Swig_cparm_name(p,i);
    pt     = Gettype(p);
    pname  = Getname(p);
    pvalue = Getvalue(p);
    local  = Swig_clocal(pt,lname,pvalue);
    Wrapper_add_localv(w,lname,local,0);
    i++;
    p = Getnext(p);
  }
  return(i);
}

/* -----------------------------------------------------------------------------
 * Swig_cresult()
 *
 * This function generates the C code needed to set the result of a C
 * function call.  
 * ----------------------------------------------------------------------------- */

void Swig_cresult(Wrapper *w, SwigType *t, String_or_char *name, String_or_char *decl) {
  String *fcall;
  
  fcall = NewString("");
  
  if (SwigType_type(t) != T_VOID)
    Wrapper_add_localv(w,name, Swig_clocal(t,name,0), 0);   

  switch(SwigType_type(t)) {
  case T_VOID:
    break;
  case T_USER:
    SwigType_add_pointer(t);
    Printf(fcall,"%s = (%s) malloc(sizeof(", name, SwigType_lstr(t,0));
    SwigType_del_pointer(t);
    Printf(fcall, "%s));\n", SwigType_str(t,0));
    Printf(fcall, "*(%s) = ", name);
    break;
  case T_REFERENCE:
    Printf(fcall,"%s = ", SwigType_str(t,"_result_ref"));
    break;
  default:
    /* Normal return value */
    Printf(fcall,"%s = (%s)", name, SwigType_lstr(t,0));
    break;
  }

  /* Now print out function call */
  Printv(fcall, decl, ";\n", 0);

  if (SwigType_type(t) == T_REFERENCE) {
    Printf(fcall,"%s = (%s) &_result_ref;\n", name, SwigType_lstr(t,0));
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

void Swig_cppresult(Wrapper *w, SwigType *t, String_or_char *name, String_or_char *decl) {
  String *fcall;

  fcall = NewString("");
  if (SwigType_type(t) != T_VOID)
    Wrapper_add_localv(w,name, Swig_clocal(t,name,0), 0);   

  switch(SwigType_type(t)) {
  case T_VOID:
    break;
  case T_USER:
    Printf(fcall, "%s = new %s(", name, SwigType_str(t,0));
    break;
  case T_REFERENCE:
    Printf(fcall, "%s = ", SwigType_str(t,"_result_ref"));
    break;
  default:
    Printf(fcall,"%s = (%s)", name, SwigType_lstr(t,0));
    break;
  }

  /* Now print out function call */
  Printv(fcall, decl, 0);
  
  switch(SwigType_type(t)) {
  case T_USER:
    Printf(fcall,");");
    break;
  case T_REFERENCE:
    Printf(fcall,";\n");
    Printf(fcall, "%s = (%s) &_result_ref;\n", name, SwigType_lstr(t,0));
    break;
  default:
    Printf(fcall,";\n");
    break;
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

String *
Swig_cfunction_call(String_or_char *name, ParmList *parms) {
  DOH *func;
  int i = 0;
  Parm *p = parms;
  SwigType *pt;

  func = NewString("");
  Printf(func,"%s(", name);
  while (p) {
    String *pname;
    pt = Gettype(p);
    pname = Swig_cparm_name(p,i);
    Printf(func,"%s", Swig_clocal_deref(pt, pname));
    i++;
    p = Getnext(p);
    if (p) 
      Printf(func,",");
  }
  Printf(func,")");
  return Swig_temp_result(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cmethod_call()
 *
 * Generates a string that calls a C++ method from a list of parameters.
 * 
 *    arg0->name(arg1, arg2, arg3, ..., argn)
 *
 * ----------------------------------------------------------------------------- */

String *
Swig_cmethod_call(String_or_char *name, ParmList *parms) {
  DOH *func;
  int i = 0;
  Parm *p = parms;
  SwigType *pt;

  func = NewString("");
  if (!p) return Swig_temp_result(func);
  Printf(func,"%s->%s(", Swig_cparm_name(p,0), name);
  i++;
  p = Getnext(p);
  while (p) {
    String *pname;
    pt = Gettype(p);
    pname = Swig_cparm_name(p,i);
    Printf(func,"%s", Swig_clocal_deref(pt, pname));
    i++;
    p = Getnext(p);
    if (p) 
      Printf(func,",");
  }
  Printf(func,")");
  return Swig_temp_result(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cconstructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      (name *) calloc(1,sizeof(name));
 * ----------------------------------------------------------------------------- */

String *
Swig_cconstructor_call(String_or_char *name) {
  DOH *func;

  func = NewString("");
  Printf(func,"(%s *) calloc(1, sizeof(%s))", name, name);
  return Swig_temp_result(func);
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

String *
Swig_cppconstructor_call(String_or_char *name, ParmList *parms) {
  DOH *func;
  int i = 0;
  Parm *p = parms;
  SwigType *pt;
  func = NewString("");
  Printf(func,"new %s(", name);
  while (p) {
    String *pname;
    pt = Gettype(p);
    pname = Swig_cparm_name(p,i);
    Printf(func,"%s", Swig_clocal_deref(pt, pname));
    i++;
    p = Getnext(p);
    if (p) 
      Printf(func,",");
  }
  Printf(func,")");
  return Swig_temp_result(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cdestructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      free((char *) arg0);
 * ----------------------------------------------------------------------------- */

String *
Swig_cdestructor_call() {
  DOH *func;

  func = NewString("");

  Printf(func,"free((char *) %s)", Swig_cparm_name(0,0));
  return Swig_temp_result(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cppdestructor_call()
 *
 * Creates a string that calls a C constructor function.
 *
 *      delete arg0;
 * ----------------------------------------------------------------------------- */

String *
Swig_cppdestructor_call() {
  DOH *func;

  func = NewString("");
  Printf(func,"delete %s", Swig_cparm_name(0,0));
  return Swig_temp_result(func);
}

/* -----------------------------------------------------------------------------
 * Swig_cmemberset_call()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name = arg1
 *
 * ----------------------------------------------------------------------------- */

String *
Swig_cmemberset_call(String_or_char *name, SwigType *type) {
  DOH *func;
  String *pname;
  func = NewString("");

  if (SwigType_type(type) == T_USER) {
    Printf(func,"%s %s->%s; ", Swig_clocal_assign(type,""), Swig_cparm_name(0,0), name);
  } else {
    Printf(func,"%s ", Swig_clocal_assign(type,""));
  }
  Printf(func,"(%s->%s = ", Swig_cparm_name(0,0), name);
  Printf(func,"%s)", Swig_clocal_deref(type, (pname = Swig_cparm_name(0,1))));
  return Swig_temp_result(func);
}


/* -----------------------------------------------------------------------------
 * Swig_cmemberget_call()
 *
 * Generates a string that sets the name of a member in a C++ class or C struct.
 *
 *        arg0->name
 *
 * ----------------------------------------------------------------------------- */

String *
Swig_cmemberget_call(String_or_char *name, SwigType *t) {
  DOH *func;

  func = NewString("");
  Printf(func,"%s (%s->%s)", Swig_clocal_assign(t,""),Swig_cparm_name(0,0), name);
  return Swig_temp_result(func);
}


static void fix_parm_names(ParmList *p) {
  int i = 0;
  while (p) {
    if (!Getname(p)) {
      char temp[64];
      sprintf(temp,"arg%d",i);
      Setname(p,temp);
    }
    i++;
    p = Getnext(p);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_cfunction_wrapper()
 *
 * This function creates a C wrapper around a C++ method.  Returns a Wrapper
 * object containing the code, parameters, and so forth.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cfunction_wrapper(String_or_char *funcname,
		       SwigType *rtype,
		       ParmList *parms,
		       String_or_char *code)
{
  Wrapper *w;
  ParmList *l;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,funcname);

  l = CopyParmList(parms);
  fix_parm_names(l);
  Printf(w->def,"%s %s(%s) {", SwigType_str(rtype,0), funcname, ParmList_str(l));
  if (code) {
    Printv(w->code, code, "\n", 0);
  }

  Printf(w->code,"}\n");
  Wrapper_Settype(w,rtype);
  Wrapper_Setparms(w,l);
  Delete(l);
  return w;
}
  
/* -----------------------------------------------------------------------------
 * Swig_cmethod_wrapper()
 *
 * This function creates a C wrapper around a C++ method.  Returns a Wrapper
 * object containing the code, parameters, and so forth.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmethod_wrapper(String_or_char *classname,
		     String_or_char *methodname,
		     SwigType *rtype,
		     ParmList *parms,
		     String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  SwigType *t;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, methodname));

  l = CopyParmList(parms);
  t = NewString(classname);
  SwigType_add_pointer(t);
  p = NewParm(t,"self");
  Setnext(p,l);
  Delete(t);

  l = p;
  fix_parm_names(l);

  Printf(w->def,"%s %s(%s) {", SwigType_str(rtype,0), Swig_name_member(classname, methodname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    if (SwigType_type(rtype) != T_VOID) {
      Printf(w->code,"return ");
    }
    
    Printf(w->code,"self->%s(", methodname);
    p = Getnext(l);
    while (p) {
      Printf(w->code,"%s", Getname(p));
      p = Getnext(p);
      if (p) 
	Printf(w->code,",");
    }
    Printf(w->code,");\n");
    Printf(w->code,"}\n");
  } else {
    Printv(w->code, code, "\n", 0);
    Printf(w->code,"}\n");
  }
  Wrapper_Settype(w,rtype);
  Wrapper_Setparms(w,l);
  Delete(l);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cconstructor_wrapper()
 *
 * This function creates a C wrapper for a C constructor function. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cconstructor_wrapper(String_or_char *classname,
			  ParmList *parms,
			  String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  SwigType *t;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_construct(classname));

  l = CopyParmList(parms);
  t = NewString(classname);
  SwigType_add_pointer(t);

  /* Patch up the argument names */
  fix_parm_names(l);

  Printf(w->def,"%s %s(%s) {", SwigType_str(t,0), Swig_name_construct(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"return (%s) calloc(1,sizeof(%s));\n", SwigType_str(t,0), classname);
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(t);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cppconstructor_wrapper()
 *
 * This function creates a C wrapper for a C++ constructor function. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cppconstructor_wrapper(String_or_char *classname,
			  ParmList *parms,
			  String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  SwigType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_construct(classname));

  l = CopyParmList(parms);
  t = NewString(classname);
  SwigType_add_pointer(t);

  /* Patch up the argument names */
  fix_parm_names(l);

  Printf(w->def,"%s %s(%s) {", SwigType_str(t,0), Swig_name_construct(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"return new %s", SwigType_str(t,0));
    p = l;
    if (p) {
      Printf(w->code,"(");
      while (p) {
	Printf(w->code,"%s", Getname(p));
	p = Getnext(p);
	if (p)
	  Printf(w->code,",");
      }
      Printf(w->code,")");
    }
    Printf(w->code,";\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(t);
  return w;
}
  

/* -----------------------------------------------------------------------------
 * Swig_cdestructor_wrapper()
 *
 * This function creates a C wrapper for a C destructor. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cdestructor_wrapper(String_or_char *classname,
			  String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  SwigType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_destroy(classname));

  t = NewString(classname);
  SwigType_add_pointer(t);
  p = NewParm(t,"self");
  l = p;
  Delete(t);

  t = NewString("void");

  Printf(w->def,"%s %s(%s) {", SwigType_str(t,0), Swig_name_destroy(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"free((char *) self);\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(t);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cppdestructor_wrapper()
 *
 * This function creates a C wrapper for a C++ destructor. 
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cppdestructor_wrapper(String_or_char *classname,
			  String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  SwigType *t;
  Parm     *p;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_destroy(classname));

  t = NewString(classname);
  SwigType_add_pointer(t);
  p = NewParm(t,"self");

  l = p;
  Delete(t);

  t = NewString("void");

  Printf(w->def,"%s %s(%s) {", SwigType_str(t,0), Swig_name_destroy(classname), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"delete self;\n");
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,t);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(t);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cmemberset_wrapper()
 *
 * This function creates a C wrapper for setting a C++ structure member.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmemberset_wrapper(String_or_char *classname,
			String_or_char *membername,
			SwigType *type,
			String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  SwigType *t;
  SwigType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, Swig_name_set(membername)));

  t = NewString(classname);
  SwigType_add_pointer(t);
  p = NewParm(t,"self");
  l = p;
  Delete(t);

  lt = Swig_clocal_type(type);
  p = NewParm(lt,"value");
  Setnext(l,p);
  
  Printf(w->def,"%s %s(%s) {", SwigType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"self->%s = %s;\n", membername, Swig_clocal_deref(lt,"value"));
    Printf(w->code,"return %s self->%s;\n", Swig_clocal_assign(lt,""), membername);
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(lt);
  return w;
}


/* -----------------------------------------------------------------------------
 * Swig_cmemberget_wrapper()
 *
 * This function creates a C wrapper for getting a structure member
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cmemberget_wrapper(String_or_char *classname,
			String_or_char *membername,
			SwigType *type,
			String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  SwigType *t;
  SwigType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_member(classname, Swig_name_get(membername)));

  t = NewString(classname);
  SwigType_add_pointer(t);
  p = NewParm(t,"self");
  l = p;
  Delete(t);

  lt = Swig_clocal_type(type);
  Printf(w->def,"%s %s(%s) {", SwigType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"return %s self->%s;", Swig_clocal_assign(lt,""), membername);
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(lt);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cvarset_wrapper()
 *
 * This function creates a C wrapper for setting a global variable.
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cvarset_wrapper(String_or_char *varname,
		     SwigType *type,
		     String_or_char *code)
{
  Wrapper *w;
  ParmList *l;
  Parm     *p;
  SwigType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w,Swig_name_set(varname));

  lt = Swig_clocal_type(type);
  p = NewParm(lt,"value");
  l = p;
  
  Printf(w->def,"%s %s(%s) {", SwigType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"%s = %s;\n", varname, Swig_clocal_deref(lt,"value"));
    Printf(w->code,"return %s;\n", Swig_clocal_assign(lt,varname));
  } else {
    Printv(w->code, code, "\n", 0);
    Replace(w->code,"$target",varname, DOH_REPLACE_ANY);
    Replace(w->code,"$source","value", DOH_REPLACE_ANY);
    Replace(w->code,"$ltype", SwigType_str(lt,""), DOH_REPLACE_ANY);
    Replace(w->code,"$rtype", SwigType_str(type,""), DOH_REPLACE_ANY);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(lt);
  return w;
}

/* -----------------------------------------------------------------------------
 * Swig_cvarget_wrapper()
 *
 * This function creates a C wrapper for getting a structure member
 * ----------------------------------------------------------------------------- */

Wrapper *
Swig_cvarget_wrapper(String_or_char *varname,
                     SwigType *type,
                     String_or_char *code)
{
  Wrapper *w;
  ParmList *l = 0;
  SwigType *lt;

  w = NewWrapper();

  /* Set the name of the function */
  Wrapper_Setname(w, Swig_name_get(varname));

  lt = Swig_clocal_type(type);

  Printf(w->def,"%s %s(%s) {", SwigType_str(lt,0), Wrapper_Getname(w), ParmList_str(l));

  if (!code) {
    /* No code supplied.  Write a function manually */
    Printf(w->code,"return %s;", Swig_clocal_assign(type,varname));
  } else {
    Printv(w->code, code, "\n", 0);
  }
  Printf(w->code,"}\n");
  Wrapper_Settype(w,lt);
  Wrapper_Setparms(w,l);
  Delete(l);
  Delete(lt);
  return w;
}





