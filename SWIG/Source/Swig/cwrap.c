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

static Parm *nonvoid_parms(Parm *p) {
  if (p) {
    SwigType *t = Getattr(p,"type");
    if (SwigType_type(t) == T_VOID) return 0;
  }
  return p;
}

/* -----------------------------------------------------------------------------
 * Swig_parm_name()
 *
 * Generates a name for the ith argument in an argument list
 * ----------------------------------------------------------------------------- */

String *
Swig_cparm_name(Parm *p, int i) {
  String *name = NewStringf("arg%d",i+1);
  if (p) {
    Setattr(p,"lname",name);
  }
  return name;
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
  case T_REFERENCE:
    if (value) 
      Printf(decl,"%s = (%s) &%s", SwigType_lstr(t,name), SwigType_lstr(t,0), value);
    else
      Printf(decl,"%s", SwigType_lstr(t,name));
    break;
  case T_VOID:
    break;
  case T_VARARGS:
    Printf(decl,"void *%s = 0", name);
    break;

  default:
    if (value)
      Printf(decl,"%s = %s", SwigType_lstr(t,name), value);
    else
      Printf(decl,"%s", SwigType_lstr(t,name));
  }
  return decl;
}

/* -----------------------------------------------------------------------------
 * Swig_wrapped_var_convert()
 *
 * Converts a member variable for use in the get and set wrapper methods.
 * This function only converts user defined types to pointers.
 * ----------------------------------------------------------------------------- */

String *
Swig_wrapped_var_type(SwigType *t) {
  SwigType *ty;
  SwigType *qty, *qty1;
  ty = Copy(t);

  if (SwigType_isclass(t)) {
    SwigType_add_pointer(ty);
  }

#ifdef OLD
  switch(SwigType_type(t)) {
  case T_USER:
    SwigType_add_pointer(ty);
    break;
  default:
    break;
  }
#endif

  return ty;
}

String *
Swig_wrapped_var_deref(SwigType *t, String_or_char *name) {
  if (SwigType_isclass(t)) {
    return NewStringf("*%s",name);
  } else {
    return SwigType_rcaststr(t,name);
  }
#ifdef OLD
  if (SwigType_type(t) == T_USER) {
    return NewStringf("*%s",name);
  } else {
    return SwigType_rcaststr(t,name);
  }
#endif

}

String *
Swig_wrapped_var_assign(SwigType *t, String_or_char *name) {
  if (SwigType_isclass(t)) {
    return NewStringf("&%s",name);
  } else {
    return SwigType_lcaststr(t,name);
  }

#ifdef OLD
  if (SwigType_type(t) == T_USER) {
    return NewStringf("&%s",name);
  } else {
    return SwigType_lcaststr(t,name);
  }
#endif
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
  SwigType *altty;

  i = 0;
  while (p != 0) {
    lname  = Swig_cparm_name(p,i);
    pt     = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      pname  = Getattr(p,"name");
      pvalue = Getattr(p,"value");
      altty = Getattr(p,"alttype");
      if (!altty) {
	local  = Swig_clocal(pt,lname,pvalue);
      } else {
	local = Swig_clocal(altty,lname, pvalue);
      }
      Wrapper_add_localv(w,lname,local,NULL);
      i++;
    }
    p = nextSibling(p);
  }
  return(i);
}

/* -----------------------------------------------------------------------------
 * Swig_cresult()
 *
 * This function generates the C code needed to set the result of a C
 * function call.  
 * ----------------------------------------------------------------------------- */

String *Swig_cresult(SwigType *t, const String_or_char *name, const String_or_char *decl) {
  String *fcall;
  
  fcall = NewString("");
  switch(SwigType_type(t)) {
  case T_VOID:
    break;
  case T_REFERENCE:
    Printf(fcall,"%s = ", SwigType_str(t,"_result_ref"));
    break;
  case T_USER:
    Printf(fcall,"%s = ", name);
    break;

  default:
    /* Normal return value */
    Printf(fcall,"%s = (%s)", name, SwigType_lstr(t,0));
    break;
  }

  /* Now print out function call */
  Printv(fcall,decl,NULL);

  /* A sick hack */
  {
    char *c = Char(decl) + Len(decl) - 1;
    if (!((*c == ';') || (*c == '}')))
      Printf(fcall, ";");
  }
  Printf(fcall,"\n");

  if (SwigType_type(t) == T_REFERENCE) {
    Printf(fcall,"%s = (%s) &_result_ref;\n", name, SwigType_lstr(t,0));
  }
  return fcall;
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
  int comma = 0;
  Parm *p = parms;
  SwigType *pt;

  func = NewString("");
  Printf(func,"%s(", name);
  while (p) {
    String *pname;
    pt = Getattr(p,"type");

    if ((SwigType_type(pt) != T_VOID)) {
      if (comma) Printf(func,",");
      pname = Swig_cparm_name(p,i);
      Printf(func,"%s", SwigType_rcaststr(pt, pname));
      comma = 1;
      i++;
    }
    p = nextSibling(p);
  }
  Printf(func,")");
  return func;
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
  int comma = 0;

  func = NewString("");
  if (!p) return func;
  pt = Getattr(p,"type");
  Printf(func,"(%s)->%s(", SwigType_rcaststr(pt,Swig_cparm_name(p,0)), name);
  i++;
  p = nextSibling(p);
  while (p) {
    String *pname;
    pt = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      if (comma) Printf(func,",");
      pname = Swig_cparm_name(p,i);
      Printf(func,"%s", SwigType_rcaststr(pt, pname));
      comma = 1;
      i++;
    }
    p = nextSibling(p);
  }
  Printf(func,")");
  return func;
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
  return func;
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
  int comma = 0;
  Parm *p = parms;
  SwigType *pt;
  func = NewString("");
  Printf(func,"new %s(", name);
  while (p) {
    String *pname;
    pt = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      if (comma) Printf(func,",");
      pname = Swig_cparm_name(p,i);
      Printf(func,"%s", SwigType_rcaststr(pt, pname));
      comma = 1;
      i++;
    }
    p = nextSibling(p);
  }
  Printf(func,")");
  return func;
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
  return func;
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
  return func;
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
  String *func;
  func = NewString("");
  if (SwigType_type(type) != T_ARRAY) {
    Printf(func,"if (%s) %s->%s = %s",Swig_cparm_name(0,0), Swig_cparm_name(0,0),name, Swig_wrapped_var_deref(type, Swig_cparm_name(0,1)));
  }
  return(func);
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
  Printf(func,"%s (%s->%s)", Swig_wrapped_var_assign(t,""),Swig_cparm_name(0,0), name);
  return func;
}

/* -----------------------------------------------------------------------------
 * Swig_MethodToFunction(Node *n)
 *
 * Converts a C++ method node to a function accessor function.
 * ----------------------------------------------------------------------------- */

int
Swig_MethodToFunction(Node *n, String *classname, int added) {
  String   *name, *qualifier;
  ParmList *parms;
  SwigType *type;
  Parm     *p;

  name      = Getattr(n,"name");
  qualifier = Getattr(n,"qualifier");
  parms     = CopyParmList(nonvoid_parms(Getattr(n,"parms")));
  
  type = NewString(classname);
  if (qualifier) {
    SwigType_push(type,qualifier);
  }
  SwigType_add_pointer(type);
  p = NewParm(type,"self");
  set_nextSibling(p,parms);
  Delete(type);
  
  /* Generate action code for the access */
  if (!added) {
    Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", Swig_cmethod_call(name,p)));
  } else {
    String *code;
    String *mangled;
    String *membername = Swig_name_member(classname, name);
    mangled = Swig_name_mangle(membername);
    type = Getattr(n,"type");
    Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", Swig_cfunction_call(mangled,p)));

    /* See if there is any code that we need to emit */
    code = Getattr(n,"code");
    if (code) {
      String *body;
      String *tmp = NewStringf("%s(%s)", mangled, ParmList_str(p));
      body = SwigType_str(type,tmp);
      Delete(tmp);
      Printv(body,code,"\n",NULL);
      Setattr(n,"wrap:code",body);
    }
    Delete(membername);
    Delete(mangled);
  }
  Setattr(n,"parms",p);
  Delete(p);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_ConstructorToFunction()
 *
 * This function creates a C wrapper for a C constructor function. 
 * ----------------------------------------------------------------------------- */

int
Swig_ConstructorToFunction(Node *n, String *classname, int cplus, int added)
{
  ParmList *parms;
  SwigType *type;
  String *membername = Swig_name_construct(classname);
  parms = CopyParmList(nonvoid_parms(Getattr(n,"parms")));
  type  = NewString(classname);
  SwigType_add_pointer(type);

  if (added) {
    String *code = Getattr(n,"code");
    if (code) {
      String *wrap;
      String *s = NewStringf("%s(%s)", membername, ParmList_str(parms));
      wrap = SwigType_str(type,s);
      Delete(s);
      Printv(wrap,code,"\n",NULL);
      Setattr(n,"wrap:code",wrap);
      Delete(wrap);
    }
    Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cfunction_call(membername,parms)));
  } else {
    if (cplus) {
      Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cppconstructor_call(classname,parms)));
    } else {
      Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cconstructor_call(classname)));
    }
  }
  Setattr(n,"type",type);
  Setattr(n,"parms", parms);
  Delete(type);
  Delete(parms);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_DestructorToFunction()
 *
 * This function creates a C wrapper for a destructor function.
 * ----------------------------------------------------------------------------- */

int
Swig_DestructorToFunction(Node *n, String *classname, int cplus, int added)
{
  SwigType *type;
  Parm     *p;

  type  = NewString(classname);
  SwigType_add_pointer(type);
  p = NewParm(type,"self");
  Delete(type);
  type = NewString("void");

  if (added) {
    String   *membername = Swig_name_destroy(classname);
    String *code = Getattr(n,"code");
    if (code) {
      String *s = NewStringf("void %s(%s)", membername, ParmList_str(p));
      Printv(s,code,"\n",NULL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(membername,p)));
    Delete(membername);
  } else {
    if (cplus) {
      Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cppdestructor_call()));
    } else {
      Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cdestructor_call()));
    }
  }
  Setattr(n,"type",type);
  Setattr(n,"parms", p);
  Delete(type);
  Delete(p);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_MembersetToFunction()
 *
 * This function creates a C wrapper for setting a structure member.
 * ----------------------------------------------------------------------------- */

int
Swig_MembersetToFunction(Node *n, String *classname, int added) {
  String   *name;
  ParmList *parms;
  Parm     *p;
  SwigType *t;
  SwigType *ty;
  SwigType *type;
  String   *membername;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  membername = Swig_name_member(classname, Swig_name_set(name));

  t = NewString(classname);
  SwigType_add_pointer(t);
  parms = NewParm(t,"self");
  Delete(t);

  ty = Swig_wrapped_var_type(type);
  p = NewParm(ty,name);
  set_nextSibling(parms,p);
  Delete(p);

  if (added) {
    String *code = Getattr(n,"code");
    if (code) {
      String *s = NewStringf("void %s(%s)", membername, ParmList_str(parms));
      Printv(s,code,"\n",NULL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(membername,parms)));
  } else {
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cmemberset_call(name,type)));
  }
  Setattr(n,"type","void");
  Setattr(n,"parms", parms);
  Delete(parms);
  Delete(ty);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_MembergetToFunction()
 *
 * This function creates a C wrapper for setting a structure member.
 * ----------------------------------------------------------------------------- */

int
Swig_MembergetToFunction(Node *n, String *classname, int added) {
  String   *name;
  ParmList *parms;
  SwigType *t;
  SwigType *ty;
  SwigType *type;
  String   *membername;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  membername = Swig_name_member(classname, Swig_name_get(name));

  t = NewString(classname);
  SwigType_add_pointer(t);
  parms = NewParm(t,"self");
  Delete(t);

  ty = Swig_wrapped_var_type(type);
  if (added) {
    String *code = Getattr(n,"code");
    if (code) {
      String *tmp = NewStringf("%s(%s)", membername, ParmList_str(parms));
      String *s = SwigType_str(ty,tmp);
      Delete(tmp);
      Printv(s,code,"\n",NULL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", Swig_cresult(ty,"result",Swig_cfunction_call(membername,parms)));
  } else {
    Setattr(n,"wrap:action", Swig_cresult(ty,"result",Swig_cmemberget_call(name,type)));
  }
  Setattr(n,"type",ty);
  Setattr(n,"parms", parms);
  Delete(parms);
  Delete(ty);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_VarsetToFunction()
 *
 * This function creates a C wrapper for setting a global variable.
 * ----------------------------------------------------------------------------- */

int
Swig_VarsetToFunction(Node *n) {
  String   *name;
  ParmList *parms;
  SwigType *type, *ty;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  ty = Swig_wrapped_var_type(type);
  parms = NewParm(ty,"value");
  Delete(ty);
  
  Setattr(n,"wrap:action", NewStringf("%s = %s;\n", name, Swig_wrapped_var_deref(type,Swig_cparm_name(0,0))));
  Setattr(n,"type","void");
  Setattr(n,"parms",parms);
  Delete(parms);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_VargetToFunction()
 *
 * This function creates a C wrapper for getting a global variable.
 * ----------------------------------------------------------------------------- */

int
Swig_VargetToFunction(Node *n) {
  String   *name;
  SwigType *type, *ty;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  ty = Swig_wrapped_var_type(type);

  Setattr(n,"wrap:action", NewStringf("result = (%s) %s;\n", SwigType_lstr(ty,0), Swig_wrapped_var_assign(type,name)));
  Setattr(n,"type",ty);
  Delattr(n,"parms");
  Delete(ty);
  return SWIG_OK;
}
