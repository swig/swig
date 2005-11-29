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

extern int    cparse_cplusplus;

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

static String *
Swig_clocal(SwigType *t, const String_or_char *name, const String_or_char *value) {
  String *decl;

  decl = NewStringEmpty();

  switch(SwigType_type(t)) {
  case T_REFERENCE:
    if (value) {
      String *lstrname = SwigType_lstr(t,name);
      String *lstr = SwigType_lstr(t,0);
      Printf(decl,"%s = (%s) &%s_defvalue", lstrname, lstr, name);
      Delete(lstrname);
      Delete(lstr);
    } else {
      String *lstrname = SwigType_lstr(t,name);
      Printf(decl,"%s = 0", lstrname);
      Delete(lstrname);
    }
    break;
  case T_VOID:
    break;
  case T_VARARGS:
    Printf(decl,"void *%s = 0", name);
    break;

  default:
    if (value) {
      String *lcaststr = SwigType_lcaststr(t,value);
      String *lstr = SwigType_lstr(t,0);
      String *lstrn = SwigType_lstr(t,name);
      Printf(decl,"%s = (%s) %s", lstrn, lstr, lcaststr);
      Delete(lcaststr);
      Delete(lstr);
      Delete(lstrn);
    } else {
      String *lstrname = SwigType_lstr(t,name);
      Printf(decl,"%s", lstrname);
      Delete(lstrname);
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

static int varref = 0;
String *
Swig_wrapped_var_type(SwigType *t) {
  SwigType *ty;

  if (!Strstr(t,"enum $unnamed")) {
    ty = Copy(t);
  } else {
    /* Change the type for unnamed enum instance variables */
    ty = NewString("int");
  }

  if (SwigType_isclass(t)) {
    if (varref) {
      if (!SwigType_isconst(ty)) SwigType_add_qualifier(ty, "const");
      SwigType_add_reference(ty);
    } else {
      SwigType_add_pointer(ty);
    }
  }
  return ty;
}

static String *
Swig_wrapped_var_deref(SwigType *t, String_or_char *name) {
  if (SwigType_isclass(t)) {
    return NewStringf("*%s",name);
  } else {
    return SwigType_rcaststr(t,name);
  }
}

static String *
Swig_wrapped_var_assign(SwigType *t, const String_or_char *name) {
  if (SwigType_isclass(t)) {
    if (varref) {
      String* ty = SwigType_lstr(t,0);
      return NewStringf("(const %s&)%s",ty, name);
    } else {
      return NewStringf("&%s",name);
    }
  } else {
    return SwigType_lcaststr(t,name);
  }
}

/* -----------------------------------------------------------------------------
 * Swig_cargs()
 *
 * Emit all of the local variables for a list of parameters.  Returns the
 * number of parameters.
 * Default values for the local variables are only emitted if the compact default
 * argument behaviour is required.
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
  int      compactdefargs = ParmList_is_compactdefargs(p);

  i = 0;

  while (p != 0) {
    lname  = Swig_cparm_name(p,i);
    pt     = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      pname  = Getattr(p,"name");

      /* default values only emitted if in compact default args mode */
      if (compactdefargs)
        pvalue = Getattr(p,"value");
      else
        pvalue = 0;

      type  = Getattr(p,"type");
      altty = SwigType_alttype(type,0);
      tycode = SwigType_type(type);
      if (tycode == T_REFERENCE) {
	if (pvalue) {
	  SwigType *tvalue;
	  String *defname, *defvalue, *rvalue, *qvalue;
	  rvalue = SwigType_typedef_resolve_all(pvalue);
	  qvalue = SwigType_typedef_qualified(rvalue);
	  defname = NewStringf("%s_defvalue", lname);
	  tvalue = Copy(type);
	  SwigType_del_reference(tvalue);
	  tycode = SwigType_type(tvalue);
	  if (tycode != T_USER) {
	    /* plain primitive type, we copy the the def value */
	    String *lstr = SwigType_lstr(tvalue,defname);
	    defvalue = NewStringf("%s = %s", lstr,qvalue);
	    Delete(lstr);
	  } else {
	    /* user type, we copy the reference value */
	    String *str = SwigType_str(type,defname);
	    defvalue = NewStringf("%s = %s",str,qvalue);
	    Delete(str);
	  }
	  Wrapper_add_localv(w,defname, defvalue, NIL);
	  Delete(tvalue);
	  Delete(rvalue);
	  Delete(qvalue);
	  Delete(defname);
	  Delete(defvalue);
	}
      }  else if (!pvalue && ((tycode == T_POINTER) || (tycode == T_STRING))) {
	pvalue = (String *) "0";
      }
      if (!altty) {
	local  = Swig_clocal(pt,lname,pvalue);
      } else {
	local = Swig_clocal(altty,lname,pvalue);
	Delete(altty);
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
  
  fcall = NewStringEmpty();
  switch(SwigType_type(t)) {
  case T_VOID:
    break;
  case T_REFERENCE: 
    {
      String *str = SwigType_str(t,"_result_ref");
      Printf(fcall,"{\n");
      Printf(fcall,"%s = ", str);
      Delete(str);
    }
    break;
  case T_USER:
    Printf(fcall,"%s = ", name);
    break;

  default:
    /* Normal return value */
    {
      String *lstr = SwigType_lstr(t,0);
      Printf(fcall,"%s = (%s)", name, lstr);
      Delete(lstr);
    }
    break;
  }

  /* Now print out function call */
  Append(fcall,decl);

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
  String  *nname;

  func = NewStringEmpty();
  nname = SwigType_namestr(name);

  /*
    SWIGTEMPLATEDISAMBIGUATOR is compiler dependent (swiglabels.swg),
      - SUN Studio 9 requires 'template', 
      - gcc-3.4 forbids the use of 'template'.
    the rest seems not caring very much,
  */
  if (SwigType_istemplate(name)) {
    String *prefix = Swig_scopename_prefix(nname);
    String *last = Swig_scopename_last(nname);
    if (!prefix || Len(prefix) == 0) {
      Printf(func,"%s(", last);
    } else {
      Printf(func,"%s::SWIGTEMPLATEDISAMBIGUATOR %s(", prefix, last);
    }
    Delete(prefix);
    Delete(last);
  } else {
    Printf(func,"%s(", nname);
  }
  Delete(nname);

  while (p) {
    SwigType *pt = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      SwigType *rpt = SwigType_typedef_resolve_all(pt);
      String *pname = Swig_cparm_name(p,i);
      String *rcaststr = SwigType_rcaststr(rpt, pname);

      if (comma) {
	Printf(func, ",%s", rcaststr);
      } else {
	Printf(func, "%s", rcaststr);
      }
      Delete(rpt);
      Delete(pname);
      Delete(rcaststr);
      comma = 1;
      i++;
    }
    p = nextSibling(p);    
  }
  Append(func,")");
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

  func = NewStringEmpty();
  nname = SwigType_namestr(name);
  if (!p) return func;
  Append(func,self);
  pt = Getattr(p,"type");

  /* If the method is invoked through a dereferenced pointer, we don't add any casts
     (needed for smart pointers).  Otherwise, we cast to the appropriate type */

  if (Strstr(func,"*this")) {
    Replaceall(func,"this", Swig_cparm_name(p,0));
  } else {
    String *rcaststr = SwigType_rcaststr(pt, Swig_cparm_name(p,0));
    Replaceall(func,"this", rcaststr);
    Delete(rcaststr);
  }

  /*
    SWIGTEMPLATEDESIMBUAGATOR is compiler dependent (swiglabels.swg),
      - SUN Studio 9 requires 'template', 
      - gcc-3.4 forbids the use of 'template'.
    the rest seems not caring very much,
  */
  if (SwigType_istemplate(name)) {
    Printf(func,"SWIGTEMPLATEDISAMBIGUATOR %s(", nname);
  } else {
    Printf(func,"%s(", nname);
  }

  i++;
  p = nextSibling(p);
  while (p) {
    pt = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      String *pname = Swig_cparm_name(p,i);
      String *rcaststr = SwigType_rcaststr(pt, pname);
      if (comma) Printf(func,",");
      Printf(func,"%s", rcaststr);
      Delete(rcaststr);
      comma = 1;
      i++;
    }
    p = nextSibling(p);
  }
  Append(func,")");
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

  func = NewStringEmpty();
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
Swig_cppconstructor_base_call(String_or_char *name, ParmList *parms, int skip_self) {
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
  func = NewStringEmpty();
  Printf(func,"new %s(", nname);
  while (p) {
    String *pname;
    pt = Getattr(p,"type");
    if ((SwigType_type(pt) != T_VOID)) {
      if (comma) Printf(func,",");
      if (!Getattr(p, "arg:byname")) {
	pname = Swig_cparm_name(p,i);
	i++;
      } else {
	if ((pname = Getattr(p, "value")))
	  pname = Copy(pname);
	else
	  pname = Copy(Getattr(p, "name"));
      }
      Printf(func,"%s", SwigType_rcaststr(pt, pname));
      comma = 1;
    }
    p = nextSibling(p);
  }
  Printf(func,")");
  Delete(nname);
  return func;
}

String *
Swig_cppconstructor_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 0);
}

String *
Swig_cppconstructor_nodirector_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 1);
}

String *
Swig_cppconstructor_director_call(String_or_char *name, ParmList *parms) {
  return Swig_cppconstructor_base_call(name, parms, 0);
}

/* -----------------------------------------------------------------------------
 * Swig_rflag_search()
 *
 * This function searches for the class attribute 'attr' in the class
 * 'n' or recursively in its bases.
 *
 * If you define SWIG_FAST_REC_SEARCH, the method will set the found
 * 'attr' in the target class 'n'. If not, the method will set the
 * 'noattr' one. This prevents of having to navigate the entire
 * hierarchy tree everytime, so, it is an O(1) method...  or something
 * like that. However, it populates all the parsed classes with the
 * 'attr' and/or 'noattr' attributes.
 *
 * If you undefine the SWIG_FAST_REC_SEARCH no attribute will be set
 * while searching. This could be slower for large projects with very
 * large hierarchy trees... or maybe not. But it will be cleaner. 
 *
 * Maybe later a swig option can be added to switch at runtime.
 *
 * ----------------------------------------------------------------------------- */

/* #define SWIG_FAST_REC_SEARCH 1 */
String *
Swig_rflag_search(Node *n, const String *attr, const String *noattr)
{
  String *f = 0;
  n = Swig_methodclass(n);  
  if (GetFlag(n, noattr)) {
    return 0;
  }
  f = GetFlagAttr(n, attr);
  if (f) {
    return f;
  } else {
    List* bl = Getattr(n, "bases");
    if (bl) {
      Iterator bi;
      for (bi = First(bl); bi.item; bi = Next(bi)) {
	f = Swig_rflag_search(bi.item, attr, noattr);
	if (f) {
#ifdef SWIG_FAST_REC_SEARCH
	  SetFlagAttr(n, attr, f);
#endif
	  return f;
	}
      }
    }
  }
#ifdef SWIG_FAST_REC_SEARCH
  SetFlag(n, noattr);
#endif
  return 0;
}

/* -----------------------------------------------------------------------------
 * Swig_unref_call()
 *
 * find the unref call, if any.
 * ----------------------------------------------------------------------------- */

String *
Swig_unref_call(Node *n) {
  Node *cn = Swig_methodclass(n);  
  String* unref = Swig_rflag_search(cn,"feature:unref","feature:nounref");
  if (unref) {
    unref = NewString(unref);
    Replaceall(unref,"$this",Swig_cparm_name(0,0));
    Replaceall(unref,"$self",Swig_cparm_name(0,0));
  }
  return unref;
}

/* -----------------------------------------------------------------------------
 * Swig_ref_call()
 *
 * find the ref call, if any.
 * ----------------------------------------------------------------------------- */

String *
Swig_ref_call(Node *n, const String* lname) {
  Node *cn = Swig_methodclass(n);  
  String* ref = Swig_rflag_search(cn,"feature:ref","feature:noref");
  if (ref) {
    ref = NewString(ref);
    Replaceall(ref,"$this",lname);
    Replaceall(ref,"$self",lname);
  }
  return ref;
}

/* -----------------------------------------------------------------------------
 * Swig_cdestructor_call()
 *
 * Creates a string that calls a C destructor function.
 *
 *      free((char *) arg0);
 * ----------------------------------------------------------------------------- */

String *
Swig_cdestructor_call(Node *n) {
  String* unref = Swig_unref_call(n);
  if (unref) return unref;
  
  return NewStringf("free((char *) %s);",Swig_cparm_name(0,0));
}


/* -----------------------------------------------------------------------------
 * Swig_cppdestructor_call()
 *
 * Creates a string that calls a C destructor function.
 *
 *      delete arg0;
 * ----------------------------------------------------------------------------- */

String *
Swig_cppdestructor_call(Node *n) {
  String* unref = Swig_unref_call(n);
  if (unref) return unref;

  return NewStringf("delete %s;",Swig_cparm_name(0,0));
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
  func = NewStringEmpty();
  if (!self) self = NewString("(this)->");
  else self = NewString(self);
  Replaceall(self,"this",Swig_cparm_name(0,0));
  if (SwigType_type(type) != T_ARRAY) {
    if (!Strstr(type,"enum $unnamed")) {
      Printf(func,"if (%s) %s%s = %s",Swig_cparm_name(0,0), self,name,
	     Swig_wrapped_var_deref(type, Swig_cparm_name(0,1)));
    } else {
      Printf(func,"if (%s && sizeof(int) == sizeof(%s%s)) *(int*)(void*)&(%s%s) = %s",
             Swig_cparm_name(0,0), self, name, self, name, Swig_cparm_name(0,1));
    }
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
Swig_cmemberget_call(const String_or_char *name, SwigType *t,
		     String_or_char *self) {
  String *func;
  if (!self) self = NewString("(this)->");
  else self = NewString(self);
  Replaceall(self,"this",Swig_cparm_name(0,0));
  func = NewStringEmpty();
  Printf(func,"%s (%s%s)", Swig_wrapped_var_assign(t,""),self, name);
  Delete(self);
  return func;
}

/* -----------------------------------------------------------------------------
 * Swig_extension_code()
 *
 * Generates an extension function (a function defined in %extend)
 *
 *        return_type function_name(parms) code
 *
 * ----------------------------------------------------------------------------- */
String *
Swig_extension_code(const String *function_name, ParmList *parms,
		    SwigType *return_type, const String *code, int cplusplus) {
  String *parms_str = cplusplus ? ParmList_str_defaultargs(parms) : ParmList_str(parms);
  String *sig = NewStringf("%s(%s)", function_name, parms_str);
  String *rt_sig = SwigType_str(return_type,sig);
  String *body = NewStringf("static %s", rt_sig);
  Printv(body, code, "\n", NIL);
  Delete(parms_str);
  Delete(sig);
  Delete(rt_sig);
  return body;
}

/* -----------------------------------------------------------------------------
 * Swig_add_extension_code()
 *
 * Generates an extension function (a function defined in %extend) and
 * adds it to the "wrap:code" attribute of a node
 *
 * See also Swig_extension_code()
 *
 * ----------------------------------------------------------------------------- */
int
Swig_add_extension_code(Node *n, const String *function_name, ParmList *parms,
			SwigType *return_type, const String *code, int cplusplus) {
  String *body = Swig_extension_code(function_name, parms, return_type, code, cplusplus);
  Setattr(n,"wrap:code",body);
  Delete(body);
  return SWIG_OK;
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
  /*
    Disable the 'this' ownership in 'self' to manage inplace
    operations like:

    A& A::operator+=(int i) { ...; return *this;}
     
    Here the 'self' parameter ownership needs to be disabled since
    there could be two objects sharing the same 'this' pointer: the
    input and the result one. And worse, the pointer could be deleted
    in one of the objects (input), leaving the other (output) with
    just a seg. fault to happen.

    To avoid the previous problem, use

      %feature("self:disown") *::operator+=;
      %feature("new") *::operator+=;

    These two lines just transfer the ownership of the 'this' pointer
    from the input to the output wrapping object.
    
    This happens in python, but may also happens in other target
    languages.
  */
  if (GetFlag(n,"feature:self:disown")) {
    Setattr(p,"wrap:disown","1");
  }
  set_nextSibling(p,parms);
  Delete(type);
  
  /* Generate action code for the access */
  if (!(flags & CWRAP_EXTEND)) {
    String *call = Swig_cmethod_call(name,p,self);
    String *result = Swig_cresult(Getattr(n,"type"),"result", call);
    Setattr(n,"wrap:action", result);
    Delete(call);
    Delete(result);
  } else {
    /* Methods with default arguments are wrapped with additional methods for each default argument,
     * however, only one extra %extend method is generated. */

    String *defaultargs = Getattr(n,"defaultargs");
    String *code = Getattr(n,"code");
    String *cname = Getattr(n,"classname") ? Getattr(n,"classname") : classname;
    String *membername = Swig_name_member(cname, name);
    String *mangled = Swig_name_mangle(membername);
    int is_smart_pointer = flags & CWRAP_SMART_POINTER;

    type = Getattr(n,"type");

    /* Check if the method is overloaded.   If so, and it has code attached, we append an extra suffix
       to avoid a name-clash in the generated wrappers.  This allows overloaded methods to be defined
       in C. */
    if (Getattr(n,"sym:overloaded") && code) {
      Append(mangled,Getattr(defaultargs ? defaultargs : n,"sym:overname"));
    }

    /* See if there is any code that we need to emit */
    if (!defaultargs && code &&!is_smart_pointer) {
      Swig_add_extension_code(n, mangled, p, type, code, cparse_cplusplus);

    }
    if (is_smart_pointer) {
      int i = 0;
      Parm *pp = p;
      String *func = NewStringf("%s(", mangled);
      if (Cmp(Getattr(n,"storage"),"static") != 0) {
	String *fadd = NewStringf("(%s*)(%s)->operator ->()", cname, Swig_cparm_name(pp,i));
	Append(func,fadd);
	Delete(fadd);
	pp = nextSibling(pp);
	if (pp) Append(func,",");
      } else{ 
	pp = nextSibling(pp);
      }
      ++i;
      while (pp) {
	SwigType *pt = Getattr(pp,"type");
	if ((SwigType_type(pt) != T_VOID)) {
	  String *pname = Swig_cparm_name(pp,i++);
	  String *rcaststr = SwigType_rcaststr(pt, pname);
	  Append(func,rcaststr);
	  Delete(rcaststr);
	  Delete(pname);
	  pp = nextSibling(pp);
	  if (pp) Append(func,",");
	}
      }
      Append(func,")");
      Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", func));      
    } else {
      Setattr(n,"wrap:action", Swig_cresult(Getattr(n,"type"),"result", Swig_cfunction_call(mangled,p)));
    }
    
    Delete(membername);
    Delete(mangled);
  }
  Setattr(n,"parms",p);
  Delete(p);
  Delete(self);
  Delete(parms);
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
  assert(classNode != 0);
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
      String *local_decl = SwigType_typedef_resolve_all(decl);
      String *method_id = NewStringf("%s|%s", name, local_decl);
      Hash *item = Getattr(vtable, method_id);
      Delete(method_id);
      Delete(local_decl);
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
    /* ?? follow the inheritance hierarchy? */

    String* base = SwigType_base(type);

    Node *directormap = Getattr(module, "wrap:directormap");
    if (directormap)
      return Getattr(directormap, base);
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
			   String *none_comparison, String *director_ctor, int cplus, int flags)
{
  ParmList *parms;
  Parm     *prefix_args;
  Parm     *p;
  ParmList *directorparms;
  SwigType *type;
  Node     *classNode;
  int      use_director;
  
  classNode = Swig_methodclass(n);
  use_director = Swig_directorclass(n);

  parms = CopyParmList(nonvoid_parms(Getattr(n,"parms")));

  /* Prepend the list of prefix_args (if any) */
  prefix_args = Getattr(n,"director:prefix_args");
  if (prefix_args != NIL) {
    Parm *p2, *p3;

    directorparms = CopyParmList(prefix_args);
    for (p = directorparms; nextSibling(p); p = nextSibling(p));
    for (p2 = parms; p2; p2 = nextSibling(p2)) {
      p3 = CopyParm(p2);
      set_nextSibling(p, p3);
      Delete(p3);
      p = p3;
    }
  } else
    directorparms = parms;

  type  = NewString(classname);
  SwigType_add_pointer(type);

  if (flags & CWRAP_EXTEND) {
    /* Constructors with default arguments are wrapped with additional constructor methods for each default argument,
     * however, only one extra %extend method is generated. */

    String *defaultargs = Getattr(n,"defaultargs");
    String *code = Getattr(n,"code");
    String *membername = Swig_name_construct(classname);
    String *mangled = Swig_name_mangle(membername);

    /* Check if the constructor is overloaded.   If so, and it has code attached, we append an extra suffix
       to avoid a name-clash in the generated wrappers.  This allows overloaded constructors to be defined
       in C. */
    if (Getattr(n,"sym:overloaded") && code) {
      Append(mangled,Getattr(defaultargs ? defaultargs : n,"sym:overname"));
    }

    /* See if there is any code that we need to emit */
    if (!defaultargs && code) {
      Swig_add_extension_code(n, mangled, parms, type, code, cparse_cplusplus);
    }

    Setattr(n,"wrap:action", Swig_cresult(type,"result", Swig_cfunction_call(mangled,parms)));

    Delete(membername);
    Delete(mangled);
  } else {
    if (cplus) {
      /* if a C++ director class exists, create it rather than the original class */
      if (use_director) {
	Node *parent = Swig_methodclass(n);
  	int abstract = Getattr(parent, "abstract") != 0;
	String *name = Getattr(parent, "sym:name");
        String* directorname = NewStringf("SwigDirector_%s", name);
	String* action = NewStringEmpty();
	String* tmp_none_comparison = Copy(none_comparison);
	String* director_call;
	String* nodirector_call;
	
	Replaceall( tmp_none_comparison, "$arg", "arg1" );

	director_call = Swig_cppconstructor_director_call(directorname, directorparms);
	nodirector_call = Swig_cppconstructor_nodirector_call(classname, parms);

	if (abstract) {
	  /* whether or not the abstract class has been subclassed in python,
	   * create a director instance (there's no way to create a normal
	   * instance).  if any of the pure virtual methods haven't been
	   * implemented in the target language, calls to those methods will
	   * generate Swig::DirectorPureVirtualException exceptions.
	   */
	  Append(action, Swig_cresult(type, "result", director_call));
	} else {
	  /* (scottm): The code for creating a new director is now a string
	     template that gets passed in via the director_ctor argument.

	     $comparison : an 'if' comparison from none_comparison
	     $director_new: Call new for director class
	     $nondirector_new: Call new for non-director class
	   */
	  Append(action, director_ctor);
	  Replaceall( action, "$comparison", tmp_none_comparison);
	  Replaceall( action, "$director_new", 
		      Swig_cresult(type, "result", director_call) );
	  Replaceall( action, "$nondirector_new", 
		      Swig_cresult(type, "result", nodirector_call) );
	}
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
  if (directorparms != parms)
    Delete(directorparms);
  Delete(parms);
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
  Setattr(p,"wrap:disown","1");
  Delete(type);
  type = NewString("void");

  if (flags & CWRAP_EXTEND) {
    String *membername, *mangled, *code;
    membername = Swig_name_destroy(classname);
    mangled = Swig_name_mangle(membername);
    code = Getattr(n,"code");
    if (code) {
      Swig_add_extension_code(n, mangled, p, type, code, cparse_cplusplus);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(mangled,p)));
    Delete(membername);
    Delete(mangled);
  } else {
    if (cplus) {
      Setattr(n,"wrap:action", NewStringf("%s\n",Swig_cppdestructor_call(n)));
    } else {
      Setattr(n,"wrap:action", NewStringf("%s\n", Swig_cdestructor_call(n)));
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
  SwigType *void_type = NewString("void");
  String   *membername;
  String   *mangled;
  String   *self= 0;
  varref = flags & CWRAP_VAR_REFERENCE;  

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
      Swig_add_extension_code(n, mangled, parms, void_type, code, cparse_cplusplus);
    }
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cfunction_call(mangled,parms)));
  } else {
    Setattr(n,"wrap:action", NewStringf("%s;\n", Swig_cmemberset_call(name,type,self)));
  }
  Setattr(n,"type",void_type);
  Setattr(n,"parms", parms);
  Delete(parms);
  Delete(ty);
  Delete(void_type);
  Delete(membername);
  Delete(mangled);
  Delete(self);
  varref = 0;
  return SWIG_OK;
}

/* -----------------------------------------------------------------------------
 * Swig_MembergetToFunction()
 *
 * This function creates a C wrapper for getting a structure member.
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
  varref = flags & CWRAP_VAR_REFERENCE;  

  if (flags & CWRAP_SMART_POINTER) {
    if (checkAttribute(n, "storage", "static")) {
      Node *sn = Getattr(n,"cplus:staticbase");
      String *base = Getattr(sn,"name"); 
      self = NewStringf("%s::", base);
    } else {
      self = NewString("(*this)->");
    }
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
      Swig_add_extension_code(n, mangled, parms, ty, code, cparse_cplusplus);
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
  varref = 0;
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
  parms = NewParm(ty,name);
  Delete(ty);
  
  if (!Strstr(type,"enum $unnamed")) {
    Setattr(n,"wrap:action", NewStringf("%s = %s;\n", nname, Swig_wrapped_var_deref(type,Swig_cparm_name(0,0))));
  } else {
    Setattr(n,"wrap:action", NewStringf("if (sizeof(int) == sizeof(%s)) *(int*)(void*)&(%s) = %s;\n", nname, nname, Swig_cparm_name(0,0)));
  }
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
