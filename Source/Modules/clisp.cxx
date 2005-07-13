/* -----------------------------------------------------------------------------
 * python.cxx
 *
 *     Python module.
 *
 * Author(s) : Surendra Singhi (surendra@asu.edu)
 *
 * Copyright (C) 2005 Surendra Singhi
 * See the file LICENSE for information on usage and redistribution.
 * ----------------------------------------------------------------------------- */



char cvsroot_clisp_cxx[] = "$Header$";

#include "swigmod.h"

class CLISP : public Language {
public:
  File *f_cl;
  String *module;
  virtual void main(int argc, char *argv[]);
  virtual int top(Node *n);
  virtual int functionWrapper(Node *n); 
  virtual int constantWrapper(Node *n);
  virtual int classDeclaration(Node *n);

private:
  String* get_ffi_type(SwigType *ty, const String_or_char *name);
  String* convert_literal(String *num_param, String *type);
  String* strip_parens(String *string);
};


void CLISP :: main(int argc, char *argv[]) {
  int i;

  SWIG_library_directory("clisp"); 
  SWIG_config_file("clisp.swg");

  for(i=1; i<argc; i++) {
    if (!strcmp(argv[i], "-help")) {
      fprintf(stdout, "clisp Options (available with -clisp)\n");
      fprintf(stdout, 
	      " currently none");

    }
  }
}


int CLISP :: top(Node *n) {

  File *f_null=NewString("");
  module=Getattr(n, "name");
  String *output_filename;

  /* Get the output file name */
  String *outfile = Getattr(n,"outfile");
   
  if(!outfile)
    output_filename=outfile;
  else  {
    output_filename=NewString("");
    Printf(output_filename, "%s%s.lisp", SWIG_output_directory(), module);
  }

  f_cl=NewFile(output_filename, "w");
  if (!f_cl) {
    Printf(stderr, "Unable to open %s for writing\n", output_filename);
    SWIG_exit(EXIT_FAILURE);
  }

  Swig_register_filebyname("header",f_null);
  Swig_register_filebyname("runtime",f_null);
  Swig_register_filebyname("wrapper", f_null);

  Printf(f_cl, ";; This is an automatically generated file. \n;;Make changes as you feel are necessary (but remember if you try to regenerate this file, your changes will be lost). \n\n(defpackage :%s\n  (:use :common-lisp :ff :excl))\n\n(in-package :%s)\n", module, module);

  
  Language::top(n);

  Close(f_cl);
  Delete(f_cl); // Deletes the handle, not the file

  return SWIG_OK;
}


int CLISP :: functionWrapper(Node *n) {
  String *func_name=Getattr(n, "sym:name");

  ParmList *pl=Getattr(n, "parms");
  Parm *p;
  int argnum=0, first=1, varargs=0;
  
  //Language::functionWrapper(n);

  Printf(f_cl, "\n(ffi:def-cal-out %s-%s (:name \"%s\")\n", module, func_name,func_name);

  /* Special cases */
  
  if (ParmList_len(pl) != 0) {
    Printf(f_cl, "\t(:arguments ");
  }
  for (p=pl; p; p=nextSibling(p), argnum++) {
    String *argname=Getattr(p, "name");
    SwigType *argtype=Getattr(p, "type");
    String *ffitype=get_ffi_type(argtype, argname);
    int tempargname=0;
      
    if (!argname) {
      argname=NewStringf("arg%d", argnum);
      tempargname=1;
    }
      
    if (!first) {
      Printf(f_cl, "\n\t\t");
    }
    Printf(f_cl, "(%s %s)", argname, ffitype);
    first=0;
      
    Delete(ffitype);

    if (tempargname) 
      Delete(argname);
  }
  Printf(f_cl, ")\n"); /* finish arg list */
  Printf(f_cl, "\t(:return-type %s)\n", get_ffi_type(Getattr(n, "type"), "result"));
  Printf(f_cl, "\t(:library +library-name+))\n");
   
  return SWIG_OK;
}


int CLISP :: constantWrapper(Node *n) {
  String *type=Getattr(n, "type");
  String *converted_value=convert_literal(Getattr(n, "value"), type);
  String *name=Getattr(n, "sym:name");

#if 1
  Printf(stdout, "constant %s is of type %s. value: %s\n",
	 name, type, converted_value);
#endif

  Printf(f_cl, "(defconstant \"%s\" %s)\n",
	 name, converted_value);

  Delete(converted_value);
 
  return SWIG_OK;
}

// Includes structs
int CLISP :: classDeclaration(Node *n) {
  String *name=Getattr(n, "sym:name");
  String *kind = Getattr(n,"kind");
  Node *c;
  
  if (Strcmp(kind, "struct")) {
    Printf(stderr, "Don't know how to deal with %s kind of class yet.\n",
	   kind);
    Printf(stderr, " (name: %s)\n", name);
    SWIG_exit(EXIT_FAILURE);
  }

  Printf(f_cl,"(ffi:def-c-struct  %s",name);
  
  for (c=firstChild(n); c; c=nextSibling(c)) {
    SwigType *type=Getattr(c, "type");
    String *lisp_type;

    if (Strcmp(nodeType(c), "cdecl")) {
      Printf(stderr, "Structure %s has a slot that we can't deal with.\n",
	     name);
      Printf(stderr, "nodeType: %s, name: %s, type: %s\n", 
	     nodeType(c),
	     Getattr(c, "name"),
	     Getattr(c, "type"));
      SWIG_exit(EXIT_FAILURE);
    }

    
    /* Printf(stdout, "Converting %s in %s\n", type, name); */
    lisp_type=get_ffi_type(type, Getattr(c, "sym:name"));

    Printf(f_cl, 
	   "\n\t(%s :type %s)", 
	   Getattr(c, "sym:name"),
	   lisp_type);

    Delete(lisp_type);
  }
  
  Printf(f_cl, ")\n");

  /* Add this structure to the known lisp types */
  //Printf(stdout, "Adding %s foreign type\n", name);
  //  add_defined_foreign_type(name);
  
  return SWIG_OK;
}


  
/* utilities */
/* returns new string w/ parens stripped */
String* CLISP::strip_parens(String *string) {
	char *s=Char(string), *p;
	int len=Len(string);
	String *res;
	
	if (len==0 || s[0] != '(' || s[len-1] != ')') {
		return NewString(string);
	}
	
	p=(char *)malloc(len-2+1);
	if (!p) {
		Printf(stderr, "Malloc failed\n");
		SWIG_exit(EXIT_FAILURE);
	}
	
	strncpy(p, s+1, len-1);
	p[len-2]=0; /* null terminate */
	
	res=NewString(p);
	free(p);
	
	return res;
}

String* CLISP::convert_literal(String *num_param, String *type) {
	String *num=strip_parens(num_param), *res;
	char *s=Char(num);
	
	/* Make sure doubles use 'd' instead of 'e' */
	if (!Strcmp(type, "double")) {
		String *updated=Copy(num);
		if (Replace(updated, "e", "d", DOH_REPLACE_ANY) > 1) {
			Printf(stderr, "Weird!! number %s looks invalid.\n", num);
			SWIG_exit(EXIT_FAILURE);
		}
		Delete(num);
		return updated;
	}

	if (SwigType_type(type) == T_CHAR) {
		/* Use CL syntax for character literals */
		return NewStringf("#\\%s", num_param);
	}
	else if (SwigType_type(type) == T_STRING) {
		/* Use CL syntax for string literals */
		return NewStringf("\"%s\"", num_param);
	}
	
	if (Len(num) < 2 || s[0] != '0') {
		return num;
	}
	
	/* octal or hex */
	
	res=NewStringf("#%c%s", 
		       s[1] == 'x' ? 'x' : 'o', 
		       s+2);
	Delete(num);

	return res;
}

String* CLISP::get_ffi_type(SwigType *ty, const String_or_char *name) {
  Hash *typemap = Swig_typemap_search("ffitype", ty, name, 0);
  if (typemap) {
    String *typespec = Getattr(typemap, "code");
    return NewString(typespec);
  }
  else {
    SwigType *tr=SwigType_typedef_resolve_all(ty);
    char *type_reduced=Char(tr);
    //    int i;

    //Printf(stdout,"convert_type %s\n", ty);
    if (SwigType_isconst(tr)) {
      SwigType_pop(tr);
      type_reduced=Char(tr);
    }

    if (SwigType_ispointer(type_reduced) || SwigType_isarray(ty) ||
	!strncmp(type_reduced, "p.f", 3)) {
#if 1
      return NewString("(* :void)");
#else
      return NewString(":foreign-address");
#endif
    }
  
    // 	  for(i=0; i<defined_foreign_types.count; i++) {
    // 		  if (!Strcmp(ty, defined_foreign_types.entries[i])) {
    // 			  return NewStringf("#.(%s \"%s\" :type :type)",
    // 					    identifier_converter, 
    // 					    ty);
    // 		  }
    // 	  }
  
    if (!Strncmp(type_reduced, "enum ", 5)) {
      return NewString(":int");
    }

    Printf(stderr, "Unsupported data type: %s (was: %s)\n", type_reduced, ty);
    SWIG_exit(EXIT_FAILURE);
  }
  return 0;
}

extern "C" Language *swig_clisp(void) {
  return new CLISP();
}


