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
 * Language::add_native()
 * ----------------------------------------------------------------- */

void
Language::add_native(char *, char *iname, SwigType *, ParmList *) {
  Printf(stderr,"%s : Line %d.  Adding native function %s not supported (ignored).\n", input_file, line_number, iname);
}

static char  *ClassName = 0;        /* This is the real name of the current class */
static char  *ClassRename = 0;      /* This is non-NULL if the class has been renamed */
static char  *ClassType = 0;        /* Type of class (ie. union, struct, class)  */

/* -----------------------------------------------------------------------------
 * Language::cpp_open_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_open_class(char *classname, char *classrename, char *ctype, int strip) {

  /* Copy the class name */

  if (ClassName) free(ClassName);
  ClassName = Swig_copy_string(classname);

  /* Copy the class renaming */

  if (ClassRename) free(ClassRename);
  if (classrename) {
    ClassRename = Swig_copy_string(classrename);
  } else {
    ClassRename = 0;           /* No renaming */
  }

  /* Make the class type*/

  if (ClassType) free(ClassType);
  ClassType = (char *) malloc(strlen(ctype)+2);
  if (strip) ClassType[0] = 0;
  else sprintf(ClassType,"%s ",ctype);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_close_class()
 * ----------------------------------------------------------------------------- */

void Language::cpp_close_class() {


  /* Doesn't really do anything  */
}

/* -----------------------------------------------------------------------------
 * Language::cpp_member_func()
 * ----------------------------------------------------------------------------- */

void Language::cpp_member_func(char *name, char *iname, SwigType *t, ParmList *l) {
  char       new_name[256];
  char       *prefix;

  /* Generate the C wrapper function name and interpreter name of this function*/
  
  /* Set the classname prefix */
  if (ClassRename) {
    prefix = ClassRename;
  } else {
    prefix = ClassName;
  }
  /* Create the actual function name */

  if (iname) {
    strcpy(new_name, Char(Swig_name_member(prefix,iname)));
  } else {
    strcpy(new_name, Char(Swig_name_member(prefix,name)));
  }

  /* Now do a symbol table lookup on it : */

  if (add_symbol(new_name)) {
    Printf(stderr,"%s : Line %d. Function %s (member %s) multiply defined (2nd definition ignored).\n",
	    input_file, line_number, iname, name);
    return;
  }
  cplus_emit_member_func(ClassName, ClassType, ClassRename, name, iname, t, l, AddMethods);
}

/* -----------------------------------------------------------------------------
 * Language::cpp_constructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_constructor(char *name, char *iname, ParmList *l) {

  char *prefix, *cname;

  if ((strcmp(name,ClassName)) && (!ObjCClass)) {
    Printf(stderr,"%s : Line %d.  Function %s must have a return type.\n", 
	    input_file, line_number, name);
    return;
  }

  /* Set the prefix */

  if (ClassRename)
    prefix = ClassRename;
  else
    prefix = ClassName;

  if (iname)
    cname = Char(Swig_name_construct(iname));
  else
    cname = Char(Swig_name_construct(prefix));

  /* Add this function to the SWIG symbol table */

  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Constructor %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname);
    return;
  }

  /* Call our default method */

  cplus_emit_constructor(ClassName, ClassType, ClassRename, name, iname, l, AddMethods);

}

/* -----------------------------------------------------------------------------
 * Language::cpp_destructor()
 * ----------------------------------------------------------------------------- */

void Language::cpp_destructor(char *name, char *iname) {

  char *cname;

  if (ClassRename) 
    cname = Char(Swig_name_destroy(ClassRename));
  else
    cname = Char(Swig_name_destroy(ClassName));

  /* Add this function to the SWIG symbol table */

  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Destructor %s multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname);
    return;
  }


  /* Call our default method */

  cplus_emit_destructor(ClassName, ClassType, ClassRename, name, iname, AddMethods);

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

void Language::cpp_variable(char *name, char *iname, SwigType *t) {
  char *prefix, *cname;

  /* Set the class prefix */
  
  if (ClassRename) {
    prefix = ClassRename;
  } else {
    prefix = ClassName;
  }

  if (iname)
    cname = Char(Swig_name_get(Swig_name_member(prefix,iname)));
  else
    cname = Char(Swig_name_get(Swig_name_member(prefix,name)));

  /* Check the symbol table */

  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Variable %s multiply defined (2nd definition ignored).\n", input_file, line_number, cname);
    return;
  }

  /* Create a function to set the value of the variable */

  if (!(Status & STAT_READONLY)) {
    cplus_emit_variable_set(ClassName, ClassType, ClassRename, name, iname, t, AddMethods);
  }

  /* Create a function to get the value of a variable */

  cplus_emit_variable_get(ClassName,ClassType, ClassRename, name, iname, t, AddMethods);

}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_func()
 * ----------------------------------------------------------------------------- */

void Language::cpp_static_func(char *name, char *iname, SwigType *t, ParmList *l) {

  char  *prefix;
  char  *mname;
  char  *cname;

  /* Set the classname prefix */
  
  if (ClassRename) 
    prefix = ClassRename;
  else
    prefix = ClassName;

  /* Set the member function name */

  if (iname)
    mname = iname;
  else
    mname = name;

  cname = Char(Swig_name_member(prefix,mname));

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
  cplus_emit_static_func(ClassName,ClassType, ClassRename, name, iname, t, l, AddMethods);

}

/* ----------------------------------------------------------------------------- 
 * Language::cpp_declare_const()
 * ----------------------------------------------------------------------------- */

void Language::cpp_declare_const(char *name, char *iname, SwigType *type, char *value)
{

  char  *cname;
  char  mname[256];
  char  *new_value;
  char  *prefix;

  /* Set the classname prefix */
  
  if (ClassRename) {
    prefix = ClassRename;
  } else {
    prefix = ClassName;
  }

  /* Set the constant name */

  if (iname)
    cname = Char(Swig_name_member(prefix,iname));
  else
    cname = Char(Swig_name_member(prefix,name));

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
    new_value = (char *) malloc(strlen(ClassName)+strlen(name)+3);
    sprintf(new_value,"%s::%s",ClassName,name);
  } else {
    new_value = value;
  }

  lang->declare_const(cname,cname,type, new_value);
  
  if (!value) {
    free(new_value);
  }
}

/* -----------------------------------------------------------------------------
 * Language::cpp_static_var()
 * ----------------------------------------------------------------------------- */

void Language::cpp_static_var(char *name, char *iname, SwigType *t) {

  char  *cname;
  char  mname[256];
  char  *prefix;

  /* Set the classname prefix */
  
  if (ClassRename) {
    prefix = ClassRename;
  } else {
    prefix = ClassName;
  }

  /* Create the variable name */
  
  if (iname) 
    cname = Char(Swig_name_member(prefix,iname));
  else
    cname = Char(Swig_name_member(prefix,name));

  /* Now do a symbol table lookup on it : */

  if (add_symbol(cname)) {
    Printf(stderr,"%s : Line %d. Variable %s (member %s) multiply defined (2nd definition ignored).\n",
	    input_file, line_number, cname, name);
    return;
  }

  /* Form correct C++ name */

  sprintf(mname,"%s::%s",ClassName,name);

  /* Link with this variable */

  lang->link_variable(mname,cname,t);
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
