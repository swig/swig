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

char cvsroot_cwrap_c[] = "$Header$";

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
    if (value) {
      Printf(decl,"%s = (%s) &%s_defvalue", SwigType_lstr(t,name), SwigType_lstr(t,0), name);
    } else {
      Printf(decl,"%s = 0", SwigType_lstr(t,name));
    }
    break;
  case T_VOID:
    break;
  case T_VARARGS:
    Printf(decl,"void *%s = 0", name);
    break;

  default:
    if (value) {
      Printf(decl,"%s = (%s) %s", SwigType_lstr(t,name), SwigType_lstr(t,0), SwigType_lcaststr(t,value));
    } else {
      Printf(decl,"%s", SwigType_lstr(t,name));
    }
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
  ty = Copy(t);

  if (SwigType_isclass(t)) {
    SwigType_add_pointer(ty);
  }
  return ty;
}

String *
Swig_wrapped_var_deref(SwigType *t, String_or_char *name) {
  if (SwigType_isclass(t)) {
    return NewStringf("*%s",name);
  } else {
    return SwigType_rcaststr(t,name);
  }
}

String *
Swig_wrapped_var_assign(SwigType *t, String_or_char *name) {
  if (SwigType_isclass(t)) {
    return NewStringf("&%s",name);
  } else {
    return SwigType_lcaststr(t,name);
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
  SwigType *altty;
  String  *type;
  int      tycode;

  i = 0;
  while (p != 0) {
    lname  = Swig_cparm_name(p,i);
    pt     = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      pname  = Getattr(p,"name");
      pvalue = Getattr(p,"value");
      altty = Getattr(p,"alttype");
      type  = Getattr(p,"type");
      tycode = SwigType_type(type);
      if (tycode == T_REFERENCE) {
	if (pvalue) {
	  String *defname, *defvalue;
	  defname = NewStringf("%s_defvalue", lname);
	  defvalue = NewStringf("%s = %s", SwigType_str(type,defname), pvalue);
	  Wrapper_add_localv(w,defname, defvalue, NIL);
	  Delete(defname);
	  Delete(defvalue);
	}
      }  else if (!pvalue && (tycode == T_POINTER)) {
	pvalue = (String *) "0";
      }
      if (!altty) {
	local  = Swig_clocal(pt,lname,pvalue);
      } else {
	local = Swig_clocal(altty,lname, pvalue);
      }
      Wrapper_add_localv(w,lname,local,NIL);
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
    Printf(fcall,"{\n");
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
  Printv(fcall,decl,NIL);

  /* A sick hack */
  {
    char *c = Char(decl) + Len(decl) - 1;
    if (!((*c == ';') || (*c == '}')))
      Printf(fcall, ";");
  }
  Printf(fcall,"\n");

  if (SwigType_type(t) == T_REFERENCE) {
    Printf(fcall,"%s = (%s) &_result_ref;\n", name, SwigType_lstr(t,0));
    Printf(fcall,"}\n");
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
  String *func;
  int i = 0;
  int comma = 0;
  Parm *p = parms;
  SwigType *pt;
  String  *nname;

  func = NewString("");
  nname = SwigType_namestr(name);
  Printf(func,"%s(", nname);
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
 * self is an argument that defines how to handle the first argument. Normally,
 * it should be set to "this->".  With C++ proxy classes enabled, it could be
 * set to "(*this)->" or some similar sequence.
 * ----------------------------------------------------------------------------- */

String *
Swig_cmethod_call(String_or_char *name, ParmList *parms, String_or_char *self) {
  String *func, *nname;
  int i = 0;
  Parm *p = parms;
  SwigType *pt;
  int comma = 0;

  if (!self) self = (char *) "(this)->";

  func = NewString("");
  nname = SwigType_namestr(name);
  if (!p) return func;
  Append(func,self);
  pt = Getattr(p,"type");

  /* If the method is invoked through a dereferenced pointer, we don't add any casts
     (needed for smart pointers).  Otherwise, we cast to the appropriate type */

  if (Strstr(func,"*this")) {
    Replaceall(func,"this", Swig_cparm_name(p,0));
  } else {
    Replaceall(func,"this", SwigType_rcaststr(pt, Swig_cparm_name(p,0)));
  }

  if (SwigType_istemplate(name)) {
      Printf(func,"template %s(", nname);
  } else {
      Printf(func,"%s(", nname);
  }
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
  Delete(nname);
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
Swig_cppconstructor_base_call(String_or_char *name, ParmList *parms, int skip_self, int disown) {
  String *func;
  String *nname;
  int i = 0;
  int comma = 0;
  Parm *p = parms;
  SwigType *pt;
  if (skip_self) {
    if (p) p = nextSibling(p);
    i++;
  }
  nname = SwigType_namestr(name);
  func = NewString("");
  Printf(func,"new %s(", nname);
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
  if (disown >= 0) {
    if (comma) Printf(func, ",");
    Printf(func, "%d", disown);
  }
  Printf(func,")");
  Delete(nname);
  return func;
}

String *
Swig_cppconstructor_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 0, -1);
}

String *
Swig_cppconstructor_nodirector_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 1, -1);
}

String *
Swig_cppconstructor_director_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 0, 0);
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
  String *func;
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
  String *func;

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
Swig_cmemberset_call(String_or_char *name, SwigType *type, String_or_char *self) {
  String *func;
  func = NewString("");
  if (!self) self = NewString("(this)->");
  else self = NewString(self);
  Replaceall(self,"this",Swig_cparm_name(0,0));
  if (SwigType_type(type) != T_ARRAY) {
    Printf(func,"if (%s) %s%s = %s",Swig_cparm_name(0,0), self,name, Swig_wrapped_var_deref(type, Swig_cparm_name(0,1)));
  }
  Delete(self);
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
Swig_cmemberget_call(String_or_char *name, SwigType *t, String_or_char *self) {
  String *func;
  if (!self) self = NewString("(this)->");
  else self = NewString(self);
  Replaceall(self,"this",Swig_cparm_name(0,0));
  func = NewString("");
  Printf(func,"%s (%s%s)", Swig_wrapped_var_assign(t,""),self, name);
  Delete(self);
  return func;
}

/* -----------------------------------------------------------------------------
 * Swig_MethodToFunction(Node *n)
 *
 * Converts a C++ method node to a function accessor function.
 * ----------------------------------------------------------------------------- */

int
Swig_MethodToFunction(Node *n, String *classname, int flags) {
  String   *name, *qualifier;
  ParmList *parms;
  SwigType *type;
  Parm     *p;
  String   *self = 0;

  /* If smart pointer, change self derefencing */
  if (flags & CWRAP_SMART_POINTER) {
    self = NewString("(*this)->");
  }
  /* If node is a member template expansion, we don't allow added code */

  if (Getattr(n,"templatetype")) flags &= ~(CWRAP_EXTEND);

  name      = Getattr(n,"name");
  qualifier = Getattr(n,"qualifier");
  parms     = CopyParmList(nonvoid_parms(Getattr(n,"parms")));
 
  type = NewString(classname);
  if (qualifier) {
    SwigType_push(type,qualifier);
  }
  SwigType_add_pointer(type);
  p = NewParm(type,"self");
  Setattr(p,"hidden","1");
  set_nextSibling(p,parms);
  Delete(type);
  
  /* Generate action code for the access */
  if (!(flags & CWRAP_EXTEND)) {
    Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", Swig_cmethod_call(name,p,self)));
  } else {
    String *code;
    String *mangled;
    String *membername = Swig_name_member(classname, name);
    mangled = Swig_name_mangle(membername);

    code = Getattr(n,"code");
    type = Getattr(n,"type");

    /* Check if the method is overloaded.   If so, and it has code attached, we append an extra suffix
       to avoid a name-clash in the generated wrappers.  This allows overloaded methods to be defined
       in C. */

    if (Getattr(n,"sym:overloaded") && code) {
      Append(mangled,Getattr(n,"sym:overname"));
    }

    Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", Swig_cfunction_call(mangled,p)));

    /* See if there is any code that we need to emit */
    if (code) {
      String *body;
      String *tmp = NewStringf("%s(%s)", mangled, ParmList_str(p));
      body = SwigType_str(type,tmp);
      Delete(tmp);
      Printv(body,code,"\n",NIL);
      Setattr(n,"wrap:code",body);
    }
    Delete(membername);
    Delete(mangled);
  }
  Setattr(n,"parms",p);
  Delete(p);
  Delete(self);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_methodclass()
 *
 * This function returns the class node for a given method or class.
 * ----------------------------------------------------------------------------- */

Node*
Swig_methodclass(Node *n) {
  Node* type = Getattr(n, "nodeType");
  if (!Cmp(type, "class")) return n;
  return Getattr(n, "parentNode");
}

int
Swig_directorbase(Node *n) {
  Node *classNode = Swig_methodclass(n);
  return (classNode && (Getattr(classNode, "directorBase") != 0));
}

int
Swig_directorclass(Node *n) {
  Node *classNode = Swig_methodclass(n);
  return (Getattr(classNode, "vtable") != 0);
}

int
Swig_directormethod(Node *n) {
  Node *classNode = Swig_methodclass(n);
  if (classNode) {
    Node *vtable = Getattr(classNode, "vtable");
    if (vtable) {
      String *name = Getattr(n, "name");
      String *decl = Getattr(n, "decl");
      String *method_id = NewStringf("%s|%s", name, decl);
      Hash *item = Getattr(vtable, method_id);
      Delete(method_id);
      if (item) {
        return (Getattr(item, "director") != 0);
      }
    }
  }
  return 0;
}

Node *
Swig_directormap(Node *module, String *type) {
  int is_void = !Cmp(type, "void");
  if (!is_void && module) {
    String* base = SwigType_base(type);
    Node *directormap = Getattr(module, "wrap:directormap");
    if (directormap) return Getattr(directormap, base);
  }
  return 0;
}

	
/* -----------------------------------------------------------------------------
 * Swig_ConstructorToFunction()
 *
 * This function creates a C wrapper for a C constructor function. 
 * ----------------------------------------------------------------------------- */

int
Swig_ConstructorToFunction(Node *n, String *classname, 
			   String *none_comparison, int cplus, int flags)
{
  ParmList *parms;
  SwigType *type;
  String   *membername;
  String   *mangled;
  Node     *classNode;
  int      use_director;
  
  classNode = Swig_methodclass(n);
  use_director = Swig_directorclass(n);
  
  membername = Swig_name_construct(classname);
  mangled = Swig_name_mangle(membername);

  parms = CopyParmList(nonvoid_parms(Getattr(n,"parms")));

  type  = NewString(classname);
  SwigType_add_pointer(type);

  if (flags & CWRAP_EXTEND) {
    String *code = Getattr(n,"code");
    if (code) {
      String *wrap;
      String *s = NewStringf("%s(%s)", mangled, ParmList_str(parms));
      wrap = SwigType_str(type,s);
      Delete(s);
      Printv(wrap,code,"\n",NIL);
      Setattr(n,"wrap:code",wrap);
      Delete(wrap);
    }
    Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cfunction_call(mangled,parms)));
  } else {
    if (cplus) {
      /* if a C++ director class exists, create it rather than the original class */
      if (use_director) {
	Node *parent = Swig_methodclass(n);
	String *name = Getattr(parent, "sym:name");
        String* directorname = NewStringf("__DIRECTOR__%s", name);
	String* action = NewString("");
	String* tmp_none_comparison = Copy(none_comparison);
	
	Replaceall( tmp_none_comparison, "$arg", "arg1" );

        /* if Python class has been subclassed, create a director instance.  
	 * otherwise, just create a normal instance.
         */
	// arty: arg1 != Py_None => tmp_none_comparison
	Printv(action, "if (",tmp_none_comparison,") { // subclassed\n",
	               Swig_cresult(type, "result", Swig_cppconstructor_director_call(directorname, parms)),
		       "} else {\n",
	               Swig_cresult(type, "result", Swig_cppconstructor_nodirector_call(classname, parms)),
		       "}\n",
		       NULL);
	Setattr(n, "wrap:action", action);
	Delete(tmp_none_comparison);
	Delete(action);
        Delete(directorname);
      } else {
        Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cppconstructor_call(classname,parms)));
      }
    } else {
      Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cconstructor_call(classname)));
    }
  }
  Setattr(n,"type",type);
  Setattr(n,"parms", parms);
  Delete(type);
  Delete(parms);
  Delete(mangled);
  Delete(membername);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_DestructorToFunction()
 *
 * This function creates a C wrapper for a destructor function.
 * ----------------------------------------------------------------------------- */

int
Swig_DestructorToFunction(Node *n, String *classname, int cplus, int flags)
{
  SwigType *type;
  Parm     *p;
 
  type  = NewString(classname);
  SwigType_add_pointer(type);
  p = NewParm(type,"self");
  Delete(type);
  type = NewString("void");

  if (flags & CWRAP_EXTEND) {
    String *membername, *mangled, *code;
    membername = Swig_name_destroy(classname);
    mangled = Swig_name_mangle(membername);
    code = Getattr(n,"code");
    if (code) {
      String *s = NewStringf("void %s(%s)", mangled, ParmList_str(p));
      Printv(s,code,"\n",NIL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(mangled,p)));
    Delete(membername);
    Delete(mangled);
  } else {
    if (cplus) {
      String* action = NewString("");
      Printf(action, "%s;\n", Swig_cppdestructor_call());
      Setattr(n,"wrap:action", action);
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
Swig_MembersetToFunction(Node *n, String *classname, int flags) {
  String   *name;
  ParmList *parms;
  Parm     *p;
  SwigType *t;
  SwigType *ty;
  SwigType *type;
  String   *membername;
  String   *mangled;
  String   *self= 0;

  if (flags & CWRAP_SMART_POINTER) {
    self = NewString("(*this)->");
  }

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  membername = Swig_name_member(classname, Swig_name_set(name));
  mangled = Swig_name_mangle(membername);

  t = NewString(classname);
  SwigType_add_pointer(t);
  parms = NewParm(t,"self");
  Delete(t);

  ty = Swig_wrapped_var_type(type);
  p = NewParm(ty,name);
  set_nextSibling(parms,p);

  /* If the type is a pointer or reference.  We mark it with a special wrap:disown attribute */
  if (SwigType_check_decl(type,"p.")) {
    Setattr(p,"wrap:disown","1");
  }
  Delete(p);

  if (flags & CWRAP_EXTEND) {
    String *code = Getattr(n,"code");
    if (code) {
      String *s = NewStringf("void %s(%s)", mangled, ParmList_str(parms));
      Printv(s,code,"\n",NIL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(mangled,parms)));
  } else {
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cmemberset_call(name,type,self)));
  }
  Setattr(n,"type","void");
  Setattr(n,"parms", parms);
  Delete(parms);
  Delete(ty);
  Delete(membername);
  Delete(mangled);
  Delete(self);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_MembergetToFunction()
 *
 * This function creates a C wrapper for setting a structure member.
 * ----------------------------------------------------------------------------- */

int
Swig_MembergetToFunction(Node *n, String *classname, int flags) {
  String   *name;
  ParmList *parms;
  SwigType *t;
  SwigType *ty;
  SwigType *type;
  String   *membername;
  String   *mangled;
  String   *self = 0;

  if (flags & CWRAP_SMART_POINTER) {
    self = NewString("(*this)->");
  }

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  membername = Swig_name_member(classname, Swig_name_get(name));
  mangled = Swig_name_mangle(membername);

  t = NewString(classname);
  SwigType_add_pointer(t);
  parms = NewParm(t,"self");
  Delete(t);

  ty = Swig_wrapped_var_type(type);
  if (flags & CWRAP_EXTEND) {
    String *code = Getattr(n,"code");
    if (code) {
      String *tmp = NewStringf("%s(%s)", mangled, ParmList_str(parms));
      String *s = SwigType_str(ty,tmp);
      Delete(tmp);
      Printv(s,code,"\n",NIL);
      Setattr(n,"wrap:code",s);
      Delete(s);
    }
    Setattr(n,"wrap:action", Swig_cresult(ty,"result",Swig_cfunction_call(mangled,parms)));
  } else {
    Setattr(n,"wrap:action", Swig_cresult(ty,"result",Swig_cmemberget_call(name,type,self)));
  }
  Setattr(n,"type",ty);
  Setattr(n,"parms", parms);
  Delete(parms);
  Delete(ty);
  Delete(membername);
  Delete(mangled);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_VarsetToFunction()
 *
 * This function creates a C wrapper for setting a global variable.
 * ----------------------------------------------------------------------------- */

int
Swig_VarsetToFunction(Node *n) {
  String   *name,*nname;
  ParmList *parms;
  SwigType *type, *ty;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  nname = SwigType_namestr(name);

  ty = Swig_wrapped_var_type(type);
  parms = NewParm(ty,"value");
  Delete(ty);
  
  Setattr(n,"wrap:action", NewStringf("%s = %s;\n", nname, Swig_wrapped_var_deref(type,Swig_cparm_name(0,0))));
  Setattr(n,"type","void");
  Setattr(n,"parms",parms);
  Delete(parms);
  Delete(nname);
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_VargetToFunction()
 *
 * This function creates a C wrapper for getting a global variable.
 * ----------------------------------------------------------------------------- */

int
Swig_VargetToFunction(Node *n) {
  String   *name, *nname;
  SwigType *type, *ty;

  name = Getattr(n,"name");
  type = Getattr(n,"type");

  nname = SwigType_namestr(name);
  ty = Swig_wrapped_var_type(type);

  Setattr(n,"wrap:action", Swig_cresult(ty,"result",Swig_wrapped_var_assign(type,nname)));
  Setattr(n,"type",ty);
  Delattr(n,"parms");
  Delete(nname);
  Delete(ty);
  return SWIG_OK;
}
