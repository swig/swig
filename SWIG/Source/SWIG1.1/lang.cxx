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

#include "internal.h"
#include <ctype.h>

extern "C" {
#include "swig.h"
}

extern int add_symbol(char *name);

/* -----------------------------------------------------------------
 * Language::create_command()
 * -----------------------------------------------------------------  */

void Language::create_command(char *, char *) {
  Printf(stderr,"SWIG Warning. No command creation procedure defined.\n");
  Printf(stderr,"C++ inheritance may not work correctly.\n");
}

/* -----------------------------------------------------------------
 * Language::nativefunction()
 * ----------------------------------------------------------------- */

void
Language::nativefunction(DOH *node) {
  Printf(stderr,"%s : Line %d.  Adding native function %s not supported (ignored).\n", input_file, line_number, Getattr(node,"scriptname"));
}

static String  *ClassName = 0;        /* This is the real name of the current class */
static String  *ClassRename = 0;      /* This is non-NULL if the class has been renamed */
static String  *ClassType = 0;        /* Type of class (ie. union, struct, class)  */
static String  *ClassFullname = 0;    /* Full name of the class */
static String  *ClassPrefix = 0;      /* Prefix used on wrappers */

/* -----------------------------------------------------------------------------
 * Language::cpp_open_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_open_class(char *classname, char *classrename, char *ctype, int strip) {

  /* Copy the class name */

  if (ClassName) Delete(ClassName);
  ClassName = NewString(classname);

  /* Copy the class renaming */

  if (ClassRename) Delete(ClassRename);
  if (classrename) {
    ClassRename = NewString(classrename);
  } else {
    ClassRename = 0;           /* No renaming */
  }

  /* Make the class type*/

  if (ClassType) Delete(ClassType);
  if (strip) ClassType = NewString("");
  else ClassType = NewStringf("%s ", ctype);

  if (ClassFullname) Delete(ClassFullname);
  ClassFullname = NewStringf("%s%s", ClassType, ClassName);

  if (ClassRename) {
    ClassPrefix = ClassRename;
  } else {
    ClassPrefix = ClassName;
  }
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
  ccode = Getattr(node,"ccode");

  /* Generate the C wrapper function name and interpreter name of this function*/
  /* Create the actual function name */

  script_name = Swig_name_member(ClassPrefix, iname ? iname : name);

  /* Now do a symbol table lookup on it : */
  if (add_symbol(Char(script_name))) {
    Printf(stderr,"%s : Line %d. Function %s (member %s) multiply defined (2nd definition ignored).\n",
	    input_file, line_number, iname, name);
    return;
  }

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
  char *name, *iname;
  ParmList *l;
  char *cname;

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  l = Getattr(node,"parms");

  if ((strcmp(name,Char(ClassName))) && (!ObjCClass)) {
    Printf(stderr,"%s : Line %d.  Function %s must have a return type.\n", 
	    input_file, line_number, name);
    return;
  }
  
  cname = Char(Swig_name_construct(iname ? iname : ClassPrefix));

  /* Add this function to the SWIG symbol table */
  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Constructor %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname);
    return;
  }

  /* Call our default method */
  cplus_emit_constructor(Char(ClassName), Char(ClassType), Char(ClassRename), name, iname, l, AddMethods);

}

/* -----------------------------------------------------------------------------
 * Language::cpp_destructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_destructor(DOH *node) {
  char *name, *iname;
  char *cname;

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  cname = Char(Swig_name_destroy(ClassRename ? ClassRename : ClassName));

  /* Add this function to the SWIG symbol table */

  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Destructor %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname);
    return;
  }


  /* Call our default method */

  cplus_emit_destructor(Char(ClassName), Char(ClassType), Char(ClassRename), name, iname, AddMethods);

}

/* ----------------------------------------------------------------------------- 
 * Language::cleanup()
 * ----------------------------------------------------------------------------- */

void Language::cpp_cleanup() {

  /* This doesn't do anything (well, not be default) */

}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_inherit()
 * ----------------------------------------------------------------------------- */

void Language::cpp_inherit(char **baseclass, int mode) {
  
  extern void cplus_inherit_members(char *, int);
  int    i = 0;

  if (!baseclass) return;
  while (baseclass[i]) {
    cplus_inherit_members(baseclass[i],mode);
    i++;
  }
}

/* -----------------------------------------------------------------------------
 * Language::cpp_variable()
 * ----------------------------------------------------------------------------- */

void Language::cpp_variable(DOH *node) {
  char *name, *iname;
  SwigType *t;
  char *cname;

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  t = Getattr(node,"type");

  /* Set the class prefix */

  cname = Char(Swig_name_get(Swig_name_member(ClassPrefix, iname ? iname : name)));

  /* Check the symbol table */
  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Variable %s multiply defined (2nd definition ignored).\n", input_file, line_number, cname);
    return;
  }

  /* Create a function to set the value of the variable */
  if (!(Status & STAT_READONLY)) {
    cplus_emit_variable_set(Char(ClassName), Char(ClassType), Char(ClassRename), name, iname, t, AddMethods);
  }

  /* Create a function to get the value of a variable */
  cplus_emit_variable_get(Char(ClassName),Char(ClassType), Char(ClassRename), name, iname, t, AddMethods);

}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_func()
 * ----------------------------------------------------------------------------- */

void Language::cpp_staticfunction(DOH *node) {
  char *name, *iname;
  SwigType *t;
  ParmList *l;
  char  *cname;

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  t = Getattr(node,"type");
  l = Getattr(node,"parms");

  /* Set the member function name */

  cname = Char(Swig_name_member(ClassPrefix,iname ? iname : name));

  /* Now do a symbol table lookup on it : */

  if (add_symbol(cname)) {
    if (ObjCClass)
      Printf(stderr,"%s : Line %d. class function %s multiply defined (2nd definition ignored).\n",
	      input_file, line_number, cname);
    else
      Printf(stderr,"%s : Line %d. static function %s multiply defined (2nd definition ignored).\n",
	      input_file, line_number, cname);
    return;
  }
  cplus_emit_static_func(Char(ClassName),Char(ClassType), Char(ClassRename), name, iname, t, l, AddMethods);
}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_constant()
 * ----------------------------------------------------------------------------- */

void Language::cpp_constant(DOH *node) 
{
  char *name, *iname, *value;
  SwigType *type;
  
  char  *cname;
  char  mname[256];
  String *new_value;

  name = GetChar(node,"name");
  iname = GetChar(node,"scriptname");
  value = GetChar(node,"value");
  type = Getattr(node,"type");

  /* Set the constant name */

  cname = Char(Swig_name_member(ClassPrefix, iname ? iname : name));

  /* Now do a symbol table lookup on it : */
  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Constant %s (member %s) multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname, name);
    return;
  }

  /* Form correct C++ name */
  sprintf(mname,"%s::%s",ClassName,name);

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
  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Variable %s (member %s) multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname, name);
    return;
  }

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

void Language::cpp_class_decl(char *, char *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_pragma()
 * ----------------------------------------------------------------------------- */

void Language::cpp_pragma(Pragma *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::add_typedef()
 * ----------------------------------------------------------------------------- */

void Language::add_typedef(SwigType *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::pragma()
 * ----------------------------------------------------------------------------- */

void Language::pragma(char *, char *, char *) {
  /* Does nothing by default */
}

/* -----------------------------------------------------------------------------
 * Language::import()
 * ----------------------------------------------------------------------------- */

void Language::import(char *) {
  /* Does nothing by default */
}
