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
  char *arr = 0;

  arr = DataType_arraystr(t);
  if (!arr) arr = (char*)"";

  switch(extern_type) {

  case 0:
    // No extern.  Just a forward reference
    if (DataType_arraystr(t))
      t->is_pointer--;

    if (t->is_reference) {
      t->is_pointer--;
      fprintf(f,"%s& %s%s; \n", DataType_print_full(t), decl, arr);
      t->is_pointer++;
    } else {
      fprintf(f,"%s %s%s; \n", DataType_print_full(t), decl,arr);
    }
    if (DataType_arraystr(t))
      t->is_pointer++;
    break;
  case 1: case 2:
    if (DataType_arraystr(t))
      t->is_pointer--;

    // Normal C/C++ extern
//    fprintf(f,"#line %d \"%s\"\n", line_number, input_file);
    if (t->is_reference) {
      t->is_pointer--;
      fprintf(f,"extern %s& %s%s; \n", DataType_print_full(t), decl,arr);
      t->is_pointer++;
    } else {
      fprintf(f,"extern %s %s%s; \n", DataType_print_full(t), decl,arr);
    }
    if (DataType_arraystr(t))
      t->is_pointer++;

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
    if (t->is_reference) {
	t->is_pointer--;
	fprintf(f,"%s&", DataType_print_full(t));
	t->is_pointer++;
    } else {
      fprintf(f,"%s", DataType_print_full(t));
    }

    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 1:
    // Normal C/C++ extern
//    fprintf(f,"#line %d \"%s\"\n", line_number, input_file);
    if (t->is_reference) {
	t->is_pointer--;
	fprintf(f,"extern %s&", DataType_print_full(t));
	t->is_pointer++;
    } else {
      fprintf(f,"extern %s", DataType_print_full(t));
    }
    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 2:
    // A C++ --- > C Extern
//    fprintf(f,"#line %d \"%s\"\n", line_number, input_file);
    if (t->is_reference) {
	t->is_pointer--;
	fprintf(f,"extern \"C\" %s&", DataType_print_full(t));
	t->is_pointer++;
    } else {
      fprintf(f,"extern \"C\" %s", DataType_print_full(t));
    }
    fprintf(f,"%s(", decl);
    ParmList_print_types(L,f);
    fprintf(f,");\n");
    break;
  case 3:
    // A function declaration (for inlining )
    if (t->is_reference) {
	t->is_pointer--;
	fprintf(f,"%s&", DataType_print_full(t));
	t->is_pointer++;
    } else {
      fprintf(f,"%s", DataType_print_full(t));
    }

    fprintf(f,"%s(", decl);
    ParmList_print_args(L,f);
    fprintf(f,")\n");
    break;
  default:
    break;
  }
}

// -----------------------------------------------------------------------------
// char *emit_local(int i)
//
// Returns the name of local variable for parameter i
// -----------------------------------------------------------------------------

char *emit_local(int i) {
  static char arg[64];

  sprintf(arg,"_arg%d", i);
  return arg;
}

// -----------------------------------------------------------------------------
// int emit_args(char *d, DataType *rt, ParmList *l, Wrapper *f)
//
// Creates a list of variable declarations for both the return value
// and function parameters.
//
// The return value is always called _result and arguments label as
// _arg0, _arg1, _arg2, etc...
//
// Returns the number of parameters associated with a function.
// -----------------------------------------------------------------------------

int emit_args(DataType *rt, ParmList *l, Wrapper *f) {

  Parm *p;
  int   i;
  char *tm;
  DataType *pt;
  // Declare the return variable

  if ((rt->type != T_VOID) || (rt->is_pointer)) {
    if ((rt->type == T_USER) && (!rt->is_pointer)) {

      // Special case for return by "value"
      rt->is_pointer++;
      Wrapper_add_localv(f, "_result", DataType_print_type(rt), "_result",0);
      rt->is_pointer--;
    } else {
      // Normal return value
      Wrapper_add_localv(f, "_result", DataType_print_type(rt), "_result",0);
    }
  }

  // Emit function arguments

  i = 0;
  p = ParmList_first(l);
  while (p != 0) {
    pt = Parm_Gettype(p);
    if ((pt->type != T_VOID) || (pt->is_pointer))  {
      char *temp = emit_local(i);
      // Figure out default values
      char *pvalue = Parm_Getvalue(p);
      char *pname = Parm_Getname(p);
      if (((pt->is_reference) && (pvalue)) ||
	  ((pt->type == T_USER) && (pt->is_pointer == 0) && (pvalue))) {
	Wrapper_add_localv(f,temp, DataType_print_type(pt), temp," = (", DataType_print_type(pt), ") &", pvalue,0);
      } else {
	char deftmp[1024];
	if (pvalue) {
	  Wrapper_add_localv(f,temp, DataType_print_type(pt), temp, " = (", DataType_print_type(pt), ") ", pvalue, 0);
	} else {
	  if ((pt->type == T_USER) && (pt->is_pointer == 0)) {
	    pt->is_pointer++;
	    Wrapper_add_localv(f,temp, DataType_print_type(pt), temp, 0);
	    pt->is_pointer--;
	  } else {
	    Wrapper_add_localv(f,temp, DataType_print_type(pt), temp, 0);
	  }
	}

	tm = typemap_lookup((char*)"arginit", typemap_lang, pt,pname,(char*)"",temp,f);
	if (tm) {
	  Printv(f->code,tm,"\n",0);
	}
      }
      // Check for ignore or default typemaps
      tm = typemap_lookup((char*)"default",typemap_lang,pt,pname,(char*)"",temp,f);
      if (tm)
	Printv(f->code,tm,"\n",0);
      tm = typemap_lookup((char*)"ignore",typemap_lang,pt,pname,(char*)"",temp,f);
      if (tm) {
	Printv(f->code,tm,"\n",0);
	p->ignore = 1;
      }
      tm = typemap_check((char*)"build",typemap_lang,pt,pname);
      if (tm) {
	p->ignore = 1;
      }
      i++;
    }
    p = ParmList_next(l);
  }

  // i now contains number of parameters
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

  int  i;
  Parm  *p;
  DOHString *fcall;
  DOHString *exc;
  char *tm;

  fcall = NewString(tab4);
  exc = NewString("");

  // First check if there is a return value

  if ((t->type != T_VOID) || (t->is_pointer)) {
    if ((t->type == T_USER) && (!t->is_pointer)) {

      // Special case for return by "value"
      // Caution : This *will* cause a memory leak if not
      // used properly.

      if (CPlusPlus) {
	Printv(fcall, "_result = new ", DataType_print_type(t), "(", 0);
      } else {
	t->is_pointer++;
	Printv(fcall, "_result = ", DataType_print_cast(t), " malloc(sizeof(", 0);
	t->is_pointer--;
	Printv(fcall, DataType_print_type(t), "));\n", 0);
	Printv(fcall, tab4, "*(_result) = ", 0);
      }
    } else {
      // Check if this is a C++ reference
      if (t->is_reference) {
	t->is_pointer--;
	Printv(fcall, DataType_print_full(t), "& _result_ref = ", 0);
	t->is_pointer++;
      } else {

	// Normal return value
	Printv(fcall, "_result = ", DataType_print_cast(t), 0);
      }
    }
  }

  // Now print out function call
  Printv(fcall, decl, "(", 0);

  i = 0;
  p = ParmList_first(l);
  while(p != 0) {
    DataType *pt = Parm_Gettype(p);
    if ((pt->type != T_VOID) || (pt->is_pointer)){
      Printf(fcall,DataType_print_arraycast(pt));
      if ((pt->is_reference) || ((pt->is_pointer == 0) && (pt->type == T_USER)))
	Printf(fcall, "*");
      Printf(fcall, emit_local(i));
      i++;
    }
    p = ParmList_next(l);
    if (p != 0)
      Printf(fcall,",");
  }
  Printf(fcall,")");

  if ((t->type == T_USER) && (!t->is_pointer)) {
    if (CPlusPlus) {
      Printf(fcall,")");
    }
  }
  Printf(fcall,";\n");

  if (t->is_reference) {
    Printv(fcall, tab4, "_result = ",  DataType_print_cast(t), " &_result_ref;\n", 0);
  }
  // Check for exception handling

  if ((tm = typemap_lookup((char*)"except",typemap_lang,t,decl,(char*)"_result",(char*)""))) {
    // Found a type-specific mapping
    Printv(exc,tm,0);
    Replace(exc,"$function",fcall,DOH_REPLACE_ANY);
    Replace(exc,"$name",decl,DOH_REPLACE_ANY);
    Printv(f->code,exc,0);
  } else if ((tm = fragment_lookup((char*)"except",typemap_lang, t->id))) {
    Printv(exc,tm,0);
    Replace(exc,"$function",fcall,DOH_REPLACE_ANY);
    Replace(exc,"$name",decl,DOH_REPLACE_ANY);
    Printv(f->code,exc,0);
  } else {
    Printv(f->code,fcall,0);
  }
  Delete(fcall);
  Delete(exc);
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

    // First write a function to set the variable of the variable

    if (!(Status & STAT_READONLY)) {
      if ((t->type == T_USER) && (!t->is_pointer)) {
	t->is_pointer++;
	fprintf(f_header,"static %s %s(%s val) {\n",
		DataType_print_type(t), Swig_name_set(name), DataType_print_type(t));
	t->is_pointer--;
      } else {
	fprintf(f_header,"static %s %s(%s val) {\n",
		DataType_print_type(t), Swig_name_set(name), DataType_print_type(t));
      }

      if ((t->type != T_VOID) || (t->is_pointer)) {
	if (!t->is_pointer) {

	  // Have a real value here
	  // If it's a user defined type, we'll do something special.
	  // Otherwise, just assign it.

	  if (t->type != T_USER) {
	    fprintf(f_header,"\t return (%s) (%s = val);\n", DataType_print_type(t), name);
	  } else {
	    fprintf(f_header,"\t %s = *(val);\n", name);
	    t->is_pointer++;
	    fprintf(f_header,"\t return (%s) &%s;\n", DataType_print_type(t),name);
	    t->is_pointer--;
	  }
	} else {

	  // Is a pointer type here.  If string, we do something
	  // special.  Otherwise. No problem.

	  if ((t->type == T_CHAR) && (t->is_pointer == 1)) {
	    if (CPlusPlus) {
	      fprintf(f_header,"\t if (%s) delete %s;\n", name,name);
	      fprintf(f_header,"\t %s = new char[strlen(val)+1];\n",name);
	      fprintf(f_header,"\t strcpy(%s,val);\n", name);
	      fprintf(f_header,"\t return %s;\n", name);
	    } else {
	      fprintf(f_header,"\t if (%s) free(%s);\n", name,name);
	      fprintf(f_header,"\t %s = (char *) malloc(strlen(val)+1);\n",name);
	      fprintf(f_header,"\t strcpy(%s,val);\n", name);
	      fprintf(f_header,"\t return %s;\n", name);
	    }
	  } else {
	    fprintf(f_header,"\t return (%s) (%s = val);\n", DataType_print_type(t), name);
	  }
	}
      }

      fprintf(f_header,"}\n");

      // Now wrap it.

      l = NewParmList();
      p = NewParm(t,0);
      DataType *pt = Parm_Gettype(p);
      if ((t->type == T_USER) && (!t->is_pointer)) pt->is_pointer++;
      Parm_Setname(p,(char*)"");
      ParmList_append(l,p);

      new_name = copy_string(Swig_name_set(name));
      new_iname = copy_string(Swig_name_set(iname));

      if ((t->type == T_USER) && (!t->is_pointer)) {
	t->is_pointer++;
	lang->create_function(new_name, new_iname, t, l);
	t->is_pointer--;
      } else {
	lang->create_function(new_name, new_iname, t, l);
      }
      DelParmList(l);
      DelParm(p);
    }

    // Now write a function to get the value of the variable

    if ((t->type == T_USER) && (!t->is_pointer)) {
      t->is_pointer++;
      fprintf(f_header,"static %s %s() { \n",
	      DataType_print_type(t), Swig_name_get(name));
      fprintf(f_header,"\t return (%s) &%s;\n", DataType_print_type(t), name);
      t->is_pointer--;
    } else {
      fprintf(f_header,"static %s %s() { \n",
	      DataType_print_type(t), Swig_name_get(name));
      fprintf(f_header,"\t return (%s) %s;\n", DataType_print_type(t), name);
    }

    fprintf(f_header,"}\n");

    // Wrap this function

    l = NewParmList();

    if (new_name) delete [] new_name;
    if (new_iname) delete [] new_iname;

    new_name = copy_string(Swig_name_get(name));
    new_iname = copy_string(Swig_name_get(iname));

    if ((t->type == T_USER) && (!t->is_pointer)) {
      t->is_pointer++;
      lang->create_function(new_name, new_iname, t, l);
      t->is_pointer--;
    } else {
      lang->create_function(new_name, new_iname, t, l);
    }
    DelParmList(l);
    delete [] new_name;
    delete [] new_iname;
}




