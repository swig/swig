/* ----------------------------------------------------------------------------- 
 * lang.cxx
 *
 *     Language base class functions.  Default C++ handling is also implemented here.
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

#include "swig11.h"

/* -----------------------------------------------------------------
 * Language::create_command()
 * -----------------------------------------------------------------  */

void Language::create_command(String *, String *) {
  Printf(stderr,"SWIG Warning. No command creation procedure defined.\n");
  Printf(stderr,"C++ inheritance may not work correctly.\n");
}

/* -----------------------------------------------------------------
 * Language::nativefunction()
 * ----------------------------------------------------------------- */

void
Language::nativefunction(DOH *node) {
  Printf(stderr,"%s:%d.  Adding native function %s not supported (ignored).\n", Getfile(node), Getline(node), Getattr(node,"scriptname"));
}


/* The following strings are used during code generation and contain various
   permutations of the class name:

   ClassName     -  This is the name of the class as it appears in C/C++
                    source code.   It does not include a type specifier
                    such as "struct" or "class"

   ClassRename   -  If non-NULL, the class has been renamed.
   ClassType     -  The type of the class (struct, class, union)
   ClassFullname -  The full name of the class including its type specifier.
                    For example, "class Foo" or "struct Vector".
   ClassPrefix   -  The class prefix as used in the scripting language
                    interface.  This is either ClassName or ClassRename.
*/

static String  *ClassName     = 0;       
static String  *ClassRename   = 0;     
static String  *ClassType     = 0;       
static String  *ClassFullname = 0;   
static String  *ClassPrefix   = 0;     

/* -----------------------------------------------------------------------------
 * Language::cpp_open_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_open_class(DOH *node) {
  String *classname;
  String *classrename;
  String *ctype;
  String *altname;
  int     strip = CPlusPlus;

  classname = Getname(node);
  classrename = Getattr(node,"scriptname");
  ctype = Getattr(node,"classtype");

  altname = Getattr(node,"altname");
  if (altname) {
    strip = 1;
    classname = altname;         /* Use the alt name instead of the class name */
  }

  if (strip) SetInt(node,"strip",1);

  /* Copy the class name */
  if (ClassName) Delete(ClassName);
  ClassName = NewString(classname);

  /* Copy the class renaming */

  if (ClassRename) Delete(ClassRename);
  ClassRename = NewString(classrename);

  if (ClassType) Delete(ClassType);
  ClassType = strip ? 0 : NewString(ctype);

  if (ClassFullname) Delete(ClassFullname);

  ClassFullname = ClassType   ? NewStringf("%s %s", ClassType, ClassName) : NewString(ClassName);
  ClassPrefix   = ClassRename;
}

/* -----------------------------------------------------------------------------
 * Language::cpp_close_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_close_class() {

  /* Doesn't really do anything  */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_memberfunction()
 * ----------------------------------------------------------------------------- */

void Language::cpp_memberfunction(DOH *node) {
  String     *name;
  String     *iname;
  String     *ccode;
  String     *script_name;
  SwigType   *type;
  ParmList   *parms;
  Wrapper    *w;

  name  = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  type  = Getattr(node,"type");
  parms = Getattr(node,"parms");
  ccode = Getattr(node,"code");

  /* Generate the C wrapper function name and interpreter name of this function*/
  /* Create the actual function name */

  script_name = Swig_name_member(ClassPrefix, iname ? iname : name);

  /* Now do a symbol table lookup on it */

  /* Create the C wrapper function for this */
  w = Swig_cmethod_wrapper(ClassFullname, name, type, parms, ccode);
  if (AddMethods && ccode) {
    /* Dump the C wrappers */
    Printf(f_wrappers,"%s",w);
  } else if (!AddMethods) {
    /* Just create a string that does what we want */
    emit_set_action(Swig_cmethod_call(name, Getparms(w)));
  }
  Setattr(w,"scriptname",script_name);
  lang->function(w);
  Delete(w);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_constructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_constructor(DOH *node) {
  String  *name;
  String  *iname;
  String  *cname;
  String  *ccode;
  ParmList *parms;
  Wrapper  *w;

  name  = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  parms = Getattr(node,"parms");
  ccode = Getattr(node,"code");

  if ((Cmp(name,ClassName))) {
    Printf(stderr,"%s:%d.  Function %s must have a return type.\n", 
	    Getfile(node), Getline(node), name);
    return;
  }
  
  cname = Swig_name_construct(iname ? iname : ClassPrefix);

  /* Add this function to the SWIG symbol table */

  if (CPlusPlus) {
    w = Swig_cppconstructor_wrapper(ClassFullname, parms, ccode);
  } else {
    w = Swig_cconstructor_wrapper(ClassFullname, parms, ccode);
  }
  Setattr(w,"scriptname", cname);

  if (!AddMethods) {
    if (CPlusPlus) {
      emit_set_action(Swig_cppconstructor_call(ClassFullname, parms));
    } else {
      emit_set_action(Swig_cconstructor_call(ClassFullname));
    }
  } else {
    if (ccode) {
      Printf(f_wrappers,"%s",w);
    }
  }
  lang->function(w);
  Delete(w);

  /* Call our default method */
	 /*  cplus_emit_constructor(Char(ClassName), Char(ClassType), Char(ClassRename), name, iname, l, AddMethods); */

}

/* -----------------------------------------------------------------------------
 * Language::cpp_destructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_destructor(DOH *node) {
  String *name;
  String *iname;
  String *cname;
  String *ccode;
  Wrapper *w;

  name = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  cname = Swig_name_destroy(ClassRename ? ClassRename : ClassName);
  ccode = Getattr(node,"code");

  /* Add this function to the SWIG symbol table */

  if (CPlusPlus) {
    w = Swig_cppdestructor_wrapper(ClassFullname,ccode);
  } else {
    w = Swig_cdestructor_wrapper(ClassFullname, ccode);
  }
  Setattr(w,"scriptname",cname);
  if (AddMethods && ccode) {
    Printf(f_wrappers,"%s", w);
    lang->function(w);
  } else if (AddMethods) {
    lang->function(w);
  } else {
    if (CPlusPlus) 
      emit_set_action(Swig_cppdestructor_call());
    else
      emit_set_action(Swig_cdestructor_call());
    lang->function(w);
  } 
  Delete(w);
}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_inherit()
 * ----------------------------------------------------------------------------- */

void Language::cpp_inherit(List *bases) {

  if (!bases) return;
  /*
  while (baseclass[i]) {
    //    cplus_inherit_members(baseclass[i],mode);
    i++;
  }
  */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_variable()
 * ----------------------------------------------------------------------------- */

void Language::cpp_variable(DOH *node) {
  String   *name;
  String   *iname;
  String   *cname;
  String   *setcode, *getcode;
  SwigType *type;
  Wrapper  *w;

  name  = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  type  = Getattr(node,"type");
  setcode  = Getattr(node,"setcode");
  getcode  = Getattr(node,"getcode");

  /* Set the class prefix */

  cname = Swig_name_get(Swig_name_member(ClassPrefix, iname ? iname : name));

  /* Check the symbol table */

  /* Create a function to set the value of the variable */
  if (!ReadOnly) {
    w = Swig_cmemberset_wrapper(ClassFullname, name, type, setcode);
    Setattr(w,"scriptname",Swig_name_set(Swig_name_member(ClassPrefix,iname ? iname : name)));
    if (AddMethods && setcode) {
      Printf(f_wrappers,"%s",w);
    } else if (!AddMethods) {
      /* Check for a member in typemap here */
      String *target = NewStringf("%s->%s", Swig_cparm_name(0,0),name);
      char *tm = Swig_typemap_lookup("memberin",type,name,Swig_cparm_name(0,1),target,0);
      if (!tm)
	emit_set_action(Swig_cmemberset_call(name,type));
      else
	emit_set_action(tm);
      Delete(target);
    }
    lang->function(w);
    Delete(w);
  }
  w = Swig_cmemberget_wrapper(ClassFullname, name, type, getcode);
  Setattr(w,"scriptname", Swig_name_get(Swig_name_member(ClassPrefix, iname ? iname : name)));
  if (AddMethods && getcode) {
    Printf(f_wrappers,"%s",w);
  } else if (!AddMethods) {
    emit_set_action(Swig_cmemberget_call(name,type));
  }
  lang->function(w);
  Delete(w);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_func()
 * ----------------------------------------------------------------------------- */

void Language::cpp_staticfunction(DOH *node) {
  String   *name;
  String   *iname;
  SwigType *type;
  ParmList *parms;
  String   *ccode;
  String   *script_name;
  String   *real_name;
  DOH      *nnode;
  Wrapper  *w;

  name  = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  type  = Getattr(node,"type");
  parms = Getattr(node,"parms");
  ccode = Getattr(node,"code");

  /* Set the member function name */
  script_name = Swig_name_member(ClassPrefix,iname ? iname : name);

  /* Now do a symbol table lookup on it : */

  /* Figure out the name of the function */
  if (AddMethods) {
    real_name = Swig_name_member(ClassName, name);
    if (!ccode) {
      nnode = Copy(node);
      Setattr(nnode,"name", real_name);
      Setattr(nnode,"scriptname", script_name);
      lang->function(nnode);
      Delete(nnode);
    } else {
      w = Swig_cfunction_wrapper(real_name,type,parms,ccode);
      Printf(f_wrappers,"%s",w);
      Setattr(w,"scriptname",script_name);
      lang->function(w);
      Delete(w);
    }
  } else {
    nnode = Copy(node);
    real_name = NewStringf("%s::%s", ClassName, name);
    Setattr(nnode,"name", real_name);
    Setattr(nnode,"scriptname", script_name);
    lang->function(nnode);
    Delete(nnode);
    Delete(real_name);
  }
}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_constant()
 * ----------------------------------------------------------------------------- */

void Language::cpp_constant(DOH *node) 
{
  String   *name;
  String   *iname;
  String   *value;
  SwigType *type;
  String   *cname;
  String   *mname;
  String   *new_value;

  name  = Getattr(node,"name");
  iname = Getattr(node,"scriptname");
  value = Getattr(node,"value");
  type  = Getattr(node,"type");

  /* Set the constant name */

  cname = Swig_name_member(ClassPrefix, iname ? iname : name);

  /* Now do a symbol table lookup on it : */

  /* Form correct C++ name */
  mname = NewStringf("%s::%s", ClassName,name);

  /* Declare a constant */
  if (!value) {
    new_value = NewStringf("%s::%s", ClassName, name);
  } else {
    new_value = NewString(value);
  }
  Hash *n;
  n = NewHash();
  Setattr(n,"name",cname);
  Setattr(n,"scriptname",cname);
  Setattr(n,"type",type);
  Setattr(n,"value",new_value);
  lang->constant(n);
  Delete(n);
  Delete(new_value);
  Delete(mname);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_staticvariable()
 * ----------------------------------------------------------------------------- */

void Language::cpp_staticvariable(DOH *node) {
  char *name, *iname;
  SwigType *t;
  char  *cname;
  char  mname[256];

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  t = Getattr(node,"type");

  /* Create the variable name */

  cname = Char(Swig_name_member(ClassPrefix, iname ? iname : name));

  /* Now do a symbol table lookup on it : */

  /* Form correct C++ name */
  sprintf(mname,"%s::%s",Char(ClassName),name);

  /* Link with this variable */

  Hash *n = NewHash();
  Setattr(n,"name",mname);
  Setattr(n,"scriptname", cname);
  Setattr(n,"type",t);
  lang->variable(n);
  Delete(n);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_class_decl()
 * ----------------------------------------------------------------------------- */

void Language::cpp_class_decl(DOH *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::add_typedef()
 * ----------------------------------------------------------------------------- */

void Language::add_typedef(SwigType *, String *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::pragma()
 * ----------------------------------------------------------------------------- */

void Language::pragma(DOH *node) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::import()
 * ----------------------------------------------------------------------------- */

void Language::import(String *) {
  /* Does nothing by default */
}



