/* -----------------------------------------------------------------------------
 * emit.cxx
 *
 *     Useful functions for emitting various pieces of code.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1998-2000.  The University of Chicago
 * Copyright (C) 1995-1998.  The University of Utah and The Regents of the
 *                           University of California.
 *
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */

#include "internal.h"
extern "C" {
#include "swig.h"
}

static char cvsroot[] = "$Header$";

// -----------------------------------------------------------------------------
// emit_extern_var(char *decl, DataType *t, int extern_type, FILE *f)
//
// Emits an external variables declaration.   Extern_type defines the
// type of external declaration.  Currently, only C/C++ declarations
// are allowed, but this might be extended to allow Fortran linkage
// someday
//
// Inputs :
//          decl        = Name of the declaration
//          t           = Datatype
//          extern_type = Numeric code indicating type of extern
//                              0   - No "extern"
//                              1,2 -  Normal extern (C/C++)
//          f           = FILE handle
// -----------------------------------------------------------------------------

void emit_extern_var(char *decl, DataType *t, int extern_type, FILE *f) {
  switch(extern_type) {
  case 0:
    // No extern.  Just a forward reference
    fprintf(f,"%s;\n", DataType_str(t, decl));
    break;
  case 1: case 2:
    fprintf(f,"extern %s;\n", DataType_str(t,decl));
    break;
  default:
    break;
  }
}

// -----------------------------------------------------------------------------
// emit_extern_func(char *decl, DataType *t, ParmList *L, int extern_type,
//                  FILE *f)
//
// Emits an external function declaration (similiar to emit_extern_var).
//
// Inputs :
//          decl        = Name of declaration
//          t           = Return datatype
//          L           = parameter list
//          extern_type = Type of extern
//                           0 - No "extern"
//                           1 - extern
//                           2 - extern "C"
//                           3 - Function declaration (with arg names)
//          f           = FILE Handle
// -----------------------------------------------------------------------------

void emit_extern_func(char *decl, DataType *t, ParmList *L, int extern_type, FILE *f) {

  switch(extern_type) {
  case 0:
    fprintf(f,"%s", DataType_str(t,0));
    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 1:
    fprintf(f,"extern %s", DataType_str(t,0));
    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 2:
    // A C++ --- > C Extern
    fprintf(f,"extern \"C\" %s", DataType_str(t,0));
    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 3:
    fprintf(f,"%s", DataType_str(t,0));
    fprintf(f,"%s(", decl);
    ParmList_print_args(L,f);
    fprintf(f,")\n");
    break;
  default:
    break;
  }
}

// -----------------------------------------------------------------------------
// int emit_args(char *d, DataType *rt, ParmList *l, Wrapper *f)
//
// Creates a list of variable declarations for both the return value
// and function parameters.
//
// The return value is always called result and arguments arg0, arg1, arg2, etc...
// Returns the number of parameters associated with a function.
// -----------------------------------------------------------------------------

int emit_args(DataType *rt, ParmList *l, Wrapper *f) {

  Parm *p;
  int   i;
  char *tm;
  DataType *pt;
  char  *pvalue;
  char  *pname;
  char  *local;
  char  *lname;

  // Emit function arguments
  Swig_cargs(f, l);

  i = 0;
  p = ParmList_first(l);
  while (p != 0) {
    lname  = Parm_Getlname(p);
    pt     = Parm_Gettype(p);
    pname  = Parm_Getname(p);
    pvalue = Parm_Getvalue(p);

    tm = typemap_lookup((char*)"arginit", typemap_lang, pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
    }
    // Check for ignore or default typemaps
    tm = typemap_lookup((char*)"default",typemap_lang,pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
    }
    tm = typemap_lookup((char*)"ignore",typemap_lang,pt,pname,(char*)"",lname,f);
    if (tm) {
      Printv(f->code,tm,"\n",0);
      p->ignore = 1;
    }
    i++;
    p = ParmList_next(l);
  }
  return(i);
}

// -----------------------------------------------------------------------------
// int emit_func_call(char *decl, DataType *t, ParmList *l, Wrapper*f)
//
// Emits code for a function call (new version).
//
// Exception handling support :
//
//     -  This function checks to see if any sort of exception mechanism
//        has been defined.  If so, we emit the function call in an exception
//        handling block.
// -----------------------------------------------------------------------------

void emit_func_call(char *decl, DataType *t, ParmList *l, Wrapper *f) {
  char *tm;

  if ((tm = typemap_lookup((char*)"except",typemap_lang,t,decl,(char*)"result",(char*)""))) {
    // Found a type-specific mapping
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
  } else if ((tm = fragment_lookup((char*)"except",typemap_lang, t->id))) {
    Printv(f->code,tm,0);
    Replace(f->code,"$name",decl,DOH_REPLACE_ANY);
  } else {
    Printv(f->code,"$function",0);
  }
  if (CPlusPlus) {
    Swig_cppresult(f, t, "result", Swig_cfunction(decl,l));
  } else {
    Swig_cresult(f, t, "result", Swig_cfunction(decl,l));
  }
}

// -----------------------------------------------------------------------------
// void emit_set_get(char *name, char *iname, DataType *type)
//
// Emits a pair of functions to set/get the value of a variable.
// This should be used as backup in case the target language can't
// provide variable linking.
//
// double foo;
//
// Gets translated into the following :
//
// double foo_set(double x) {
//      return foo = x;
// }
//
// double foo_get() {
//      return foo;
// }
//
// Need to handle special cases for char * and for user
// defined types.
//
// 1.  char *
//
//     Will free previous contents (if any) and allocate
//     new storage.   Could be risky, but it's a reasonably
//     natural thing to do.
//
// 2.  User_Defined
//     Will assign value from a pointer.
//     Will return a pointer to current value.
// -----------------------------------------------------------------------------

void emit_set_get(char *name, char *iname, DataType *t) {

    Parm *p;
    ParmList *l;
    char *new_name = 0, *new_iname = 0;
    
    DataType *lt;

    // Figure out the assignable local type for this variable

    lt = Swig_clocal_type(t);

    // First write a function to set the variable of the variable
    if (!(Status & STAT_READONLY)) {
      fprintf(f_header,"static %s %s(%s) {\n",
	      DataType_lstr(lt,0), Swig_name_set(name), DataType_lstr(lt,"val"));
      if (!t->is_pointer) {
	fprintf(f_header,"\t %s = %s;\n",   name, Swig_clocal_deref(t,"val"));
	fprintf(f_header,"\t return %s;\n", Swig_clocal_assign(t,name));
      } else {
	// Is a pointer type here.  If string, we do something
	// special.  Otherwise. No problem.
	if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
	  if (CPlusPlus) {
	    fprintf(f_header,"\t if (%s) delete %s;\n", name,name);
	    fprintf(f_header,"\t %s = new char[strlen(val)+1];\n",name);
	    fprintf(f_header,"\t strcpy(%s,val);\n", name);
	    fprintf(f_header,"\t return %s;\n", Swig_clocal_assign(t,name));
	  } else {
	    fprintf(f_header,"\t if (%s) free(%s);\n", name,name);
	    fprintf(f_header,"\t %s = (char *) malloc(strlen(val)+1);\n",name);
	    fprintf(f_header,"\t strcpy(%s,val);\n", name);
	    fprintf(f_header,"\t return %s;\n", Swig_clocal_assign(t,name));
	  }
	} else {
	  fprintf(f_header,"\t %s = %s;\n",  name, Swig_clocal_deref(t,"val"));
	  fprintf(f_header,"\t return %s;\n", Swig_clocal_assign(t,name));
	}
      }
      fprintf(f_header,"}\n");

      // Now wrap it.
      l = NewParmList();
      p = NewParm(lt,0);
      Parm_Setname(p,(char*)"");
      ParmList_append(l,p);

      new_name = copy_string(Swig_name_set(name));
      new_iname = copy_string(Swig_name_set(iname));
      lang->create_function(new_name, new_iname, lt, l);
      DelParmList(l);
      DelParm(p);
    }

    // Now write a function to get the value of the variable
    fprintf(f_header,"static %s %s() { \n",
	    DataType_lstr(lt,0), Swig_name_get(name));
    fprintf(f_header,"\t return %s;\n", Swig_clocal_assign(t,name));
    fprintf(f_header,"}\n");

    // Wrap this function

    l = NewParmList();
    if (new_name) delete [] new_name;
    if (new_iname) delete [] new_iname;

    new_name = copy_string(Swig_name_get(name));
    new_iname = copy_string(Swig_name_get(iname));
    lang->create_function(new_name, new_iname, lt, l);
    DelParmList(l);
    DelDataType(lt);
    delete [] new_name;
    delete [] new_iname;
}
