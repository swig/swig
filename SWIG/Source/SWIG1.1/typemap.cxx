/* ----------------------------------------------------------------------------- 
 * typemap.cxx
 *
 *     Typemap support.
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
#include <limits.h>

extern "C" {
#include "doh.h"
}

// ------------------------------------------------------------------------
// This file provides universal support for typemaps.   Typemaps are created
// using the following SWIG command in an interface file:
//
//       %typemap(lang,operation) type { code }        Make a new typemap
//       %typemap(lang,operation) type;                Clears any previous typemap
//
// lang is an identifier indicating the target language.  The typemap will
// simply be ignored if its for a different language.  The code is the
// corresponding C code for the mapping.  An example typemap might look
// like this :
//
//       %typemap(tcl,get) double {
//              $target = atof($source);
//       }
//       %typemap(tcl,set) double {
//              sprintf($target,"%0.17f",$source);
//       }
//
// The variables $target and $source should be used in any type-mappings.
// Additional local variables can be created, but this should be done 
// by enclosing the entire code fragment in an extra set of braces.
//
// The C++ API to the type-mapper is as follows :
//
// void typemap_register(char *op, char *lang, DataType *type, char *pname, String &getcode, ParmList *args)
// char *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source, char *target);
// void typemap_clear(char *op, char *lang, DataType *type, char *pname);
//
// The lookup functions return a character string corresponding to the type-mapping
// code or NULL if none exists.   The string return will have the source and target
// strings substituted for the strings "$source" and "$target" in the type-mapping code.
//
// (2/19/97) This module has been extended somewhat to provide generic mappings
// of other parts of the code--most notably exceptions.
//
// void fragment_register(char *op, char *lang, String &code)
// char fragment_lookup(char *op, char *lang, int age);
// char fragment_clear(char *op, char *lang);
//
// ------------------------------------------------------------------------

// Structure for holding a typemap

struct TypeMap {
  char       *lang;
  DataType   *type;
  DOHString  *code;
  int         first;
  int         last;
  TypeMap     *next;
  TypeMap     *previous;                // Previously defined typemap (if any)
  ParmList    *args;                    // Local variables (if any)

  TypeMap(char *l, DataType *t, char *c, ParmList *p = 0) {
    lang = copy_string(l);
    type = new DataType(t);
    code = NewString(c);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = 0;
    if (p) {
      args = new ParmList(p);
    } else {
      args = 0;
    }
  }
  TypeMap(char *l, char *c) {
    lang = copy_string(l);
    type = 0;
    code = NewString(c);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = 0;
    args = 0;
  }
  TypeMap(TypeMap *t) {
    lang = copy_string(t->lang);
    type = new DataType(t->type);
    code = Copy(t->code);
    first = type_id;
    last = INT_MAX;
    next = 0;
    previous = t->previous;
    if (args) {
      args = new ParmList(args);
    } else {
      args = 0;
    }
  }
};

// Hash tables for storing type-mappings

static DOH *typemap_hash = 0;

// Structure for holding "applications of a typemap"

struct TmMethod {
  char *name;          // Typemap name;
  DataType *type;      // Typemap type
  TmMethod *next;      // Next method
  TmMethod(char *n, DataType *t, TmMethod *m = 0) {
    if (n) name = copy_string(n);
    else name = 0;
    if (t) {
      type = new DataType(t);
    } else {
      type = 0;
    }
    next = m;
  }
};

// Hash table for storing applications of a datatype

static DOH *application_hash = 0;

// ------------------------------------------------------------------------
// void typemap_apply(DataType *tm_type, char *tm_name, DataType *type, char *pname)
//
// Attempts to apply a typemap given by (tm_type,tm_name) to (type,pname)
// Called by the %apply directive.
// ------------------------------------------------------------------------

void typemap_apply(DataType *tm_type, char *tm_name, DataType *type, char *pname) {
  TmMethod *m,*m1;
  char temp[512];

  // Form the application name
  if (!pname) pname = (char*)"";
  sprintf(temp,"%s$%s",type->print_type(),pname);

  // See if there is a method already defined

  if (!application_hash) application_hash = NewHash();
  m = (TmMethod *) GetVoid(application_hash,temp);
  
  if (!m) {
    m = new TmMethod(temp,type,0);
    SetVoid(application_hash,temp,m);
  }

  // Check to see if an array typemap has been applied to a non-array type

  if ((tm_type->arraystr) && (!type->arraystr)) {
    fprintf(stderr,"%s:%d: Warning. Array typemap has been applied to a non-array type.\n",
	    input_file,line_number);
  }

  // If both are arrays, make sure they have the same dimension 

  if ((tm_type->arraystr) && (type->arraystr)) {
    char s[128],*t;
    if (tm_type->array_dimensions() != type->array_dimensions()) {
      fprintf(stderr,"%s:%d: Warning. Array types have different number of dimensions.\n",
	      input_file,line_number);
    } else {
      for (int i = 0; i < tm_type->array_dimensions(); i++) {
	strcpy(s,tm_type->get_dimension(i));
	t = type->get_dimension(i);
	if (strcmp(s,"ANY") != 0) {
	  if (strcmp(s,t)) 
	    fprintf(stderr,"%s:%d: Warning. Array typemap applied to an array of different size.\n",
		    input_file, line_number);
	}
      }
    }
  }

  // Add a new mapping corresponding to the typemap

  m1 = new TmMethod(tm_name,tm_type,m->next);
  m->next = m1;
  
}
// ------------------------------------------------------------------------
// void typemap_clear_apply(DataType *type, char *pname)
//
// Clears the application of a typemap.
// Called by the %clear directive.
// ------------------------------------------------------------------------

void typemap_clear_apply(DataType *type, char *pname) {
  char temp[512];
  if (!pname) pname = (char*)"";
  sprintf(temp,"%s$%s", type->print_type(), pname);
  if (!application_hash) application_hash = NewHash();
  Delattr(application_hash,temp);
}

// ------------------------------------------------------------------------
// char *typemap_string(char *lang, DataType *type, char *pname, char *ary, char *suffix)
//
// Produces a character string corresponding to a lang, datatype, and
// method.   This string is used as the key for our typemap hash table.
// ------------------------------------------------------------------------

static char *typemap_string(char *lang, DataType *type, char *pname, char *ary, char *suffix) {
  static DOHString *str = 0;

  int old_status;
  if (!str) str = NewString("");
  old_status = type->status;
  type->status = 0;
  Clear(str);

  if (ary)
    Printv(str, lang, type->print_type(), pname, ary, suffix, 0);
  else
    Printv(str, lang, type->print_type(), pname, suffix,0);

  type->status = old_status;
  return Char(str);
}

// ------------------------------------------------------------------------
// void typemap_register(char *op, char *lang, DataType *type, char *pname,
//                       char *getcode, ParmList *args)
//
// Register a new mapping with the type-mapper.  
// ------------------------------------------------------------------------

void typemap_register(char *op, char *lang, DataType *type, char *pname, 
                      char *getcode, ParmList *args) {
  
  char     *key;
  TypeMap  *tm,*tm_old;
  char     temp[256];
  int      is_default = 0;

  // printf("Registering : %s %s %s %s\n%s\n", op, lang, type->print_type(), pname, getcode);

  if (!typemap_hash) typemap_hash = NewHash();

  tm = new TypeMap(lang,type,getcode,args);
  // If this is a default typemap, downgrade the type!

  if (strcmp(pname,"SWIG_DEFAULT_TYPE") == 0) {
    tm->type->primitive();   
    is_default = 1;
  }

  key = typemap_string(lang,tm->type,pname,tm->type->arraystr, op);

  // Get any previous setting of the typemap

  tm_old = (TypeMap *) GetVoid(typemap_hash,key);

  if (tm_old) {

    // Perform a chaining operation, but only if the last typemap is
    // active.

    if (type_id < tm_old->last) {
      sprintf(temp,"$%s",op);
      Replace(tm->code,temp,tm_old->code, DOH_REPLACE_ANY);
    }

    // If found, we need to attach the old version to the new one

    tm->previous = tm_old;
    tm->next = tm_old;
    tm_old->last = type_id;

    // Remove the old one from the hash
  
    Delattr(typemap_hash,key);
  } 

  // Add new typemap to the hash table
  SetVoid(typemap_hash,key,tm);

  // Now try to perform default chaining operation (if available)
  //  if (!is_default) {
  //    sprintf(temp,"$%s",op);
  //    if (strstr(tm->code,temp)) {
  //      tm->code.replace(temp,typemap_resolve_default(op,lang,type));
  //    }
  //  }

  // Just a sanity check to make sure args look okay.
  
  if (args) {
    Parm *p;
    p = tm->args->get_first();
    while (p) {
      if (p->name) {
	//	printf("    %s %s\n", p->t->print_type(),p->name);
      } else {
	fprintf(stderr,"%s:%d:  Typemap error. Local variables must have a name\n",
		input_file, line_number);
      }
      // If a call by reference thingy, fix that
      if (p->call_type & CALL_REFERENCE) {
	p->t->is_pointer--;
	p->call_type = 0;
      }
      p = tm->args->get_next();
    }
  }
}

// ------------------------------------------------------------------------
// void typemap_register(char *op, char *lang, char *type, char *pname,
//                       char *getcode, ParmList *args)
//
// Register a new mapping with the type-mapper. Special version that uses a
// string instead of a datatype.
// ------------------------------------------------------------------------

void typemap_register(char *op, char *lang, char *type, char *pname, 
                      char *getcode, ParmList *args) {
  DataType temp;
  strcpy(temp.name,type);
  temp.is_pointer = 0;
  temp.type = T_USER;
  typemap_register(op,lang,&temp,pname,getcode,args);
}


// ------------------------------------------------------------------------
// void typemap_register_default(char *op, char *lang, int type, int ptr, char *arraystr,
//                               char *code, ParmList *args)
//
// Registers a default typemap with the system using numerical type codes.
// type is the numerical code, ptr is the level of indirection. 
// ------------------------------------------------------------------------

void typemap_register_default(char *op, char *lang, int type, int ptr, char *arraystr,
			   char *code, ParmList *args) {

  DataType *t = new DataType(type);

  // Create a raw datatype from the arguments

  t->is_pointer = ptr;
  t->arraystr = copy_string(arraystr);

  // Now, go register this as a default type

  typemap_register(op,lang,t,(char*)"SWIG_DEFAULT_TYPE",code,args);
  delete t;
}


// ------------------------------------------------------------------------
// static TypeMap *typemap_search(char *key, int id) 
//
// An internal function for searching for a particular typemap given
// a key value and datatype id.
//
// Basically this checks the hash table and then checks the id against
// first and last values, looking for a match.   This is to properly
// handle scoping problems.
// ------------------------------------------------------------------------

TypeMap *typemap_search(char *key, int id) {
  
  TypeMap *tm;

  if (!typemap_hash) typemap_hash = NewHash();
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  while (tm) {
    if ((id >= tm->first) && (id < tm->last)) return tm;
    else tm = tm->next;
  }
  return tm;
}

// ------------------------------------------------------------------------
// TypeMap *typemap_search_array(char *op, char *lang, DataType *type, char *pname, DOHString *str)
//
// Performs a typemap lookup on an array type.  This is abit complicated
// because we need to look for ANY tags specifying that any array dimension
// is valid.   The resulting code will be placed in str with dimension variables
// substituted.
// ------------------------------------------------------------------------

TypeMap *typemap_search_array(char *op, char *lang, DataType *type, char *pname, DOHString *str) {
  char      *origarr = type->arraystr;
  char      *key;
  int       ndim,i,j,k,n;
  TypeMap   *tm;
  char      temp[10];

  if (!type->arraystr) return 0;

  // First check to see if exactly this array has been mapped

  key = typemap_string(lang,type,pname,type->arraystr,op);
  tm = typemap_search(key,type->id);

  // Check for unnamed array of specific dimensions
  if (!tm) {
    key = typemap_string(lang,type,(char*)"",type->arraystr,op);
    tm = typemap_search(key,type->id);
  } 

  if (!tm) {
    // We're going to go search for matches with the ANY tag
    DOHString *tempastr = NewString("");
    ndim = type->array_dimensions();             // Get number of dimensions
    j = (1 << ndim) - 1;                         // Status bits
    for (i = 0; i < (1 << ndim); i++) {
      // Form an array string
      Clear(tempastr);
      k = j;
      for (n = 0; n < ndim; n++) {
	if (k & 1) {
	  Printf(tempastr,"[%s]",type->get_dimension(n));
	} else {
	  Printf(tempastr,"[ANY]");
	}
	k = k >> 1;
      }
      type->arraystr = Char(tempastr);
      key = typemap_string(lang,type,pname,type->arraystr,op);
      tm = typemap_search(key,type->id);
      if (!tm) {
	key = typemap_string(lang,type,(char*)"",type->arraystr,op);
	tm = typemap_search(key,type->id);
      }
      type->arraystr = origarr;
      if (tm) {
	Delete(tempastr);
	break;
      }
      j--;
    }
    Delete(tempastr);
  }      
	
  if (tm) {
    Printf(str,"%s",tm->code);
    ndim = type->array_dimensions();
    sprintf(temp,"%d",ndim);
    Replace(str,"$ndim",temp, DOH_REPLACE_ANY);
    for (i = 0; i < ndim; i++) {
      sprintf(temp,"$dim%d",i);
      Replace(str,temp,type->get_dimension(i), DOH_REPLACE_ANY);
    }
  }
  return tm;
}

// ------------------------------------------------------------------------
// static typemap_locals(Datatype *t, char *pname, String &s, ParmList *l, Wrapper *f)
//
// Takes a string, a parameter list and a wrapper function argument and
// starts creating local variables.
//
// Substitutes locals in the string with actual values used.
// ------------------------------------------------------------------------

static void typemap_locals(DataType *t, char *pname, DOHString *s, ParmList *l, Wrapper *f) {
  Parm *p;
  char *new_name;
  
  p = l->get_first();
  while (p) {
    if (p->name) {
      if (strlen(p->name) > 0) {
	DOHString *str;
	DataType *tt;

	str = NewString("");
	// If the user gave us $type as the name of the local variable, we'll use
	// the passed datatype instead

	if (strcmp(p->t->name,"$type")==0 || strcmp(p->t->name,"$basetype")==0) {
	  tt = t;
	} else {
	  tt = p->t;
	}
        
	// Have a real parameter here
        if (tt->arraystr) {
	  tt->is_pointer--;
	  Printf(str,"%s%s",p->name, tt->arraystr);
	} 
        else {
	  Printf(str,"%s",p->name);
	}

	// Substitute parameter names
	Replace(str,"$arg",pname, DOH_REPLACE_ANY);
        if (strcmp(p->t->name,"$basetype")==0) {
          // use $basetype
          char temp_ip = tt->is_pointer;
          char temp_ip1 = tt->implicit_ptr;
          tt->is_pointer = 0;
          tt->implicit_ptr = 0;
          new_name = Wrapper_new_local(f,tt->print_type(),Char(str));
          tt->is_pointer = temp_ip;
          tt->implicit_ptr = temp_ip1;
        } 
        else 
          new_name = Wrapper_new_local(f,tt->print_full(),Char(str));

	if (tt->arraystr) tt->is_pointer++;
	// Substitute 
	Replace(s,p->name,new_name,DOH_REPLACE_ID);
      }
    }
    p = l->get_next();
  }
  // If the original datatype was an array. We're going to go through and substitute
  // it's array dimensions

  if (t->arraystr) {
    char temp[10];
    for (int i = 0; i < t->array_dimensions(); i++) {
      sprintf(temp,"$dim%d",i);
      Replace(f->locals,temp,t->get_dimension(i), DOH_REPLACE_ANY);
    }
  }

}

// ------------------------------------------------------------------------
// char *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source,
//                      char *target, WrapperFunction *f)
//            
// Looks up a "get" function in the type-map and returns a character string
// containing the appropriate translation code.
//
// op       is string code for type of mapping
// lang     is the target language string
// type     is the datatype
// pname    is an optional parameter name
// source   is a string with the source variable
// target   is a string containing the target value
// f        is a wrapper function object (optional)
//
// Returns NULL if no mapping is found.
//
// Typemaps follow a few rules regarding naming and C pointers by checking
// declarations in this order.
//
//         1.   type name []         - A named array (most specific)
//         2.   type name            - Named argument
//         3.   type []              - Type with array
//         4.   type                 - Ordinary type
// 
// Array checking is only made if the datatype actally has an array specifier      
// 
// Array checking uses a special token "ANY" that indicates that any
// dimension will match.  Since we are passed a real datatype here, we
// need to hack this a special case.
//
// Array dimensions are substituted into the variables $dim1, $dim2,...,$dim9
// ------------------------------------------------------------------------

static DataType *realtype;       // This is a gross hack
static char     *realname = 0;   // Real parameter name

char *typemap_lookup_internal(char *op, char *lang, DataType *type, char *pname, char *source,
                     char *target, Wrapper *f) {
  static DOHString *str = 0;
  char *key = 0;
  TypeMap *tm = 0;

  if (!str) str = NewString("");
  if (!lang) {
    return 0;
  }

  // First check for named array
  Clear(str);
  tm = typemap_search_array(op,lang,type,pname,str);

  // Check for named argument
  if (!tm) {
    key = typemap_string(lang,type,pname,0,op);
    tm = typemap_search(key,type->id);
    if (tm)
      Printf(str,"%s",tm->code);
  }

  // Check for unnamed type
  if (!tm) {
    key = typemap_string(lang,type,(char*)"",0,op);
    tm = typemap_search(key,type->id);
    if (tm)
      Printf(str,"%s", tm->code);
  }
  if (!tm) return 0;
  
  // Now perform character replacements

  Replace(str,"$source",source,DOH_REPLACE_ANY);
  Replace(str,"$target",target,DOH_REPLACE_ANY);
  Replace(str,"$type",realtype->print_type(),DOH_REPLACE_ANY);
  if (realname) {
    Replace(str,"$parmname",realname,DOH_REPLACE_ANY);
  } else {
    Replace(str,"$parmname","", DOH_REPLACE_ANY);
  }
  // Print base type (without any pointers)
  {
    char temp_ip = realtype->is_pointer;
    char temp_ip1 = realtype->implicit_ptr;
    realtype->is_pointer = 0;
    realtype->implicit_ptr = 0;
    char *bt = realtype->print_type();
    if (bt[strlen(bt)-1] == ' ') 
      bt[strlen(bt)-1] = 0;
    Replace(str,"$basetype",bt,DOH_REPLACE_ANY);
    Replace(str,"$basemangle",realtype->print_mangle(), DOH_REPLACE_ANY);
    realtype->is_pointer = temp_ip;
    realtype->implicit_ptr = temp_ip1;
  }
  
  Replace(str,"$mangle",realtype->print_mangle(), DOH_REPLACE_ANY);

  // If there were locals and a wrapper function, replace
  if ((tm->args) && f) {
    typemap_locals(realtype, pname, str,tm->args,f);
  }

  // If there were locals and no wrapper function, print a warning
  if ((tm->args) && !f) {
    if (!pname) pname = (char*)"";
    fprintf(stderr,"%s:%d: Warning. '%%typemap(%s,%s) %s %s' being applied with ignored locals.\n",
	    input_file, line_number, lang,op, type->print_type(), pname);
  }

  // Return character string

  return Char(str);
}

// ----------------------------------------------------------
// Real function call that takes care of application mappings
// ----------------------------------------------------------

char *typemap_lookup(char *op, char *lang, DataType *type, char *pname, char *source,
                     char *target, Wrapper *f) {
  TmMethod *m;
  char temp[512];
  char *result;
  char *ppname;
  char *tstr;

  realtype = type;         // The other half of the gross hack
  realname = pname;

  // Try to apply typemap right away

  result = typemap_lookup_internal(op,lang,type,pname,source,target,f);

  // If not found, try to pick up anything that might have been
  // specified with %apply

  if ((!result) && (pname)) {
    int drop_pointer = 0;
    ppname = pname;
    if (!ppname) ppname = (char*)"";
    
    // The idea : We're going to cycle through applications and
    // drop pointers off until we get a match.   

    while (drop_pointer <= (type->is_pointer - type->implicit_ptr)) {
      type->is_pointer -= drop_pointer;
      tstr = type->print_type();
      sprintf(temp,"%s$%s",tstr,ppname);
      // No mapping was found.  See if the name has been mapped with %apply
      m = (TmMethod *) GetVoid(application_hash,temp);
      if (!m) {
	sprintf(temp,"%s$",tstr);
	m = (TmMethod *) GetVoid(application_hash,temp);
      }
      if (m) {
	m = m->next;
	while (m) {
	  char *oldary = 0;
	  static DOHString *newarray = 0;
	  if (!newarray) newarray = NewString("");
	  if (*(m->name)) ppname = m->name;
	  else ppname = pname;
	  m->type->is_pointer += drop_pointer;

	  // Copy old array string (just in case)

	  oldary = m->type->arraystr; 

	  // If the mapping type is an array and has the 'ANY' keyword, we
          // have to play some magic

	  if ((m->type->arraystr) && (type->arraystr)) {
	    // Build up the new array string
	    Clear(newarray);
	    for (int n = 0; n < m->type->array_dimensions(); n++) {
	      char *d = m->type->get_dimension(n);
	      if (strcmp(d,"ANY") == 0) {
		Printf(newarray,"[%s]", type->get_dimension(n));
	      } else {
		Printf(newarray,"[%s]", d);
	      }
	    }
	    m->type->arraystr = Char(newarray);
	  } else if (type->arraystr) {
	    // If an array string is available for the current datatype,
	    // make it available.
	    m->type->arraystr = type->arraystr;
	  }
	  result = typemap_lookup_internal(op,lang,m->type,ppname,source,target,f);
	  m->type->arraystr = oldary;
	  m->type->is_pointer -= drop_pointer;
	  if (result) {
	    type->is_pointer += drop_pointer;
	    return result;
	  }
	  m = m->next;
	}
      }
      type->is_pointer += drop_pointer;
      drop_pointer++;
    }
  }
  // Still no idea, try to find a default typemap

  if (!result) {
    DataType *t = new DataType(type);
    t->primitive(); // Knock it down to its basic type
    result = typemap_lookup_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE",source,target,f);
    if (result) {
      delete t;
      return result;
    }
    if ((t->type == T_USER) || (t->is_pointer)) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) return 0;
    
      // Still no result, go even more primitive
      t->type = T_USER;
      t->is_pointer = 1;
      if (t->arraystr) delete [] t->arraystr;
      t->arraystr = 0;
      t->primitive();
      result = typemap_lookup_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE",source,target,f);
    }
    delete t;
  }
  return result;
}

// ----------------------------------------------------------------------------
// char *typemap_check(char *op, char *lang, DataType *type, char *pname)
//
// Checks to see if there is a typemap.  Returns typemap string if found, NULL
// if not.
// ----------------------------------------------------------------------------

char *typemap_check_internal(char *op, char *lang, DataType *type, char *pname) {
  static DOHString *str = 0;
  char *key = 0;
  TypeMap *tm = 0;

  if (!str) str = NewString("");
  if (!lang) {
    return 0;
  }
  // First check for named array

  Clear(str);
  tm = typemap_search_array(op,lang,type,pname,str);

  // First check for named array
  //
  //  if (type->arraystr) {
  //    key = typemap_string(lang,type,pname,type->arraystr,op);
  //    tm = typemap_search(key,type->id);
  //  }

  // Check for named argument
  if (!tm) {
    key = typemap_string(lang,type,pname,0,op);
    tm = typemap_search(key,type->id);
  }

  // Check for unnamed array
  if ((!tm) && (type->arraystr)) {
    key = typemap_string(lang,type,(char*)"",type->arraystr,op);
    tm = typemap_search(key,type->id);
  } 

  // Check for unname type
  if (!tm) {
    key = typemap_string(lang,type,(char*)"",0,op);
    tm = typemap_search(key,type->id);
  }
  if (!tm) return 0;
  
  Clear(str);
  Printf(str,"%s",tm->code);

  // Return character string
  Char(str);
}

// Function for checking with applications

char *typemap_check(char *op, char *lang, DataType *type, char *pname) {
  TmMethod *m;
  char temp[512];
  char *result;
  char *ppname;
  char *tstr;
  // Try to apply typemap right away

  result = typemap_check_internal(op,lang,type,pname);

  if (!result) {
    int drop_pointer = 0;
    ppname = pname;
    if (!ppname) ppname = (char*)"";
    
    // The idea : We're going to cycle through applications and
    // drop pointers off until we get a match.   

    while (drop_pointer <= (type->is_pointer - type->implicit_ptr)) {
      type->is_pointer -= drop_pointer;
      tstr = type->print_type();
      sprintf(temp,"%s$%s",tstr,ppname);
      // No mapping was found.  See if the name has been mapped with %apply
      if (!application_hash) application_hash = NewHash();
      m = (TmMethod *) GetVoid(application_hash,temp);
      if (!m) {
	sprintf(temp,"%s$",tstr);
	m = (TmMethod *) GetVoid(application_hash,temp);
      }
      if (m) {
	m = m->next;
	while (m) {
	  char *oldary = 0;
	  static DOHString *newarray = 0;
	  if (!newarray) newarray = NewString("");
	  if (*(m->name)) ppname = m->name;
	  else ppname = pname;
	  m->type->is_pointer += drop_pointer;
	  oldary = m->type->arraystr;

	  // If the mapping type is an array and has the 'ANY' keyword, we
          // have to play some magic
	  
	  if ((m->type->arraystr) && (type->arraystr)) {
	    // Build up the new array string
	    Clear(newarray);
	    for (int n = 0; n < m->type->array_dimensions(); n++) {
	      char *d = m->type->get_dimension(n);
	      if (strcmp(d,"ANY") == 0) {
		Printf(newarray,"[%s]", type->get_dimension(n));
	      } else {
		Printf(newarray,"[%s]", d);
	      }
	    }
	    oldary = m->type->arraystr;
	    m->type->arraystr = Char(newarray);
	  } else if (type->arraystr) {
	    m->type->arraystr = type->arraystr;
	  }
	  result = typemap_check_internal(op,lang,m->type,ppname);
	  m->type->arraystr = oldary;
	  m->type->is_pointer -= drop_pointer;
	  if (result) {
	    type->is_pointer += drop_pointer;
	    return result;
	  }
	  m = m->next;
	}
      }
      type->is_pointer += drop_pointer;
      drop_pointer++;
    }
  }

  // If still no result, might have a default typemap
  if (!result) {
    DataType *t = new DataType(type);
    t->primitive(); // Knock it down to its basic type
    result = typemap_check_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE");
    if (result) {
      delete t;
      return result;
    }
    if ((t->type == T_USER) || (t->is_pointer)) {
      if ((t->type == T_CHAR) && (t->is_pointer == 1)) return 0;
      // Still no result, go even more primitive
      t->type = T_USER;
      t->is_pointer = 1;
      if (t->arraystr) delete [] t->arraystr;
      t->arraystr = 0;
      t->primitive();
      result = typemap_check_internal(op,lang,t,(char*)"SWIG_DEFAULT_TYPE");
    }
    delete t;
  }
  return result;
}

// ------------------------------------------------------------------------
// void typemap_clear(char *op, char *lang, DataType *type, char *pname)
//
// Clears any previous typemap.   This works like a stack.  Clearing a
// typemap returns to any previous typemap in force.   If there is no
// previous map, then don't worry about it.
// ------------------------------------------------------------------------

void typemap_clear(char *op, char *lang, DataType *type, char *pname) {
  
  char     *key;
  TypeMap  *tm;

  key = typemap_string(lang,type,pname,type->arraystr,op);

  // Look for any previous version, simply set the last id if
  // applicable.
  
  if (!typemap_hash) typemap_hash = NewHash();
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm) {
    if (tm->last > type_id) tm->last = type_id;
  }
}

// ------------------------------------------------------------------------
// void typemap_copy(char *op, char *lang, DataType *stype, char *sname,
//                   DataType *ttype, char *tname)
//
// Copies the code associate with a typemap
// ------------------------------------------------------------------------

void typemap_copy(char *op, char *lang, DataType *stype, char *sname,
		      DataType *ttype, char *tname) {
  
  char     *key;
  TypeMap  *tm, *tk, *tn;

  // Try to locate a previous typemap

  key = typemap_string(lang,stype,sname,stype->arraystr,op);
  tm = typemap_search(key,stype->id);
  if (!tm) return;
  if (strcmp(ttype->name,"PREVIOUS") == 0) {
    // Pop back up to the previous typemap (if any)
    tk = tm->next;
    if (tk) {
      tn = new TypeMap(tk);       // Make a copy of the previous typemap
      tn->next = tm;              // Set up symlinks
      Delattr(typemap_hash,key);  // Remove old hash entry
      SetVoid(typemap_hash,key, tn);
    }
  } else {
    typemap_register(op,lang,ttype,tname,Char(tm->code),tm->args);
  }
}

// ------------------------------------------------------------------------
// char *fragment_string(char *op, char *lang)
//
// Produces a character string corresponding to a language and method
// This string is used as the key for our typemap hash table.
// ------------------------------------------------------------------------

static char *fragment_string(char *op, char *lang) {
  static char str[512];
  sprintf(str,"fragment:%s%s", lang, op);
  return str;
}

// ------------------------------------------------------------------------
// void fragment_register(char *op, char *lang, char *code)
//
// Register a code fragment with the type-mapper.
// ------------------------------------------------------------------------

void fragment_register(char *op, char *lang, char *code) {
  
  char     *key;
  TypeMap  *tm,*tm_old;
  char      temp[256];
  
  tm = new TypeMap(lang,code);
  key = fragment_string(op,lang);

  // Get any previous setting of the typemap

  tm_old = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm_old) {
    // If found, we need to attach the old version to the new one

    // Perform a chaining operation 

    sprintf(temp,"$%s",op);
    if (type_id < tm_old->last)
      Replace(tm->code,temp,tm_old->code,DOH_REPLACE_ANY);

    tm->next = tm_old;
    tm_old->last = type_id;

    // Remove the old one from the hash
  
    Delattr(typemap_hash,key);
  }
  
  // Perform a default chaining operation if needed (defaults to nothing)
  sprintf(temp,"$%s",op);
  Replace(tm->code,temp,"", DOH_REPLACE_ANY);

  // Add new typemap to the hash table
  SetVoid(typemap_hash,key,tm);
    
}


// ------------------------------------------------------------------------
// char *fragment_lookup(char *op, char *lang, int age)
//
// op       is string code for type of mapping
// lang     is the target language string
// age      is age of fragment.
//
// Returns NULL if no mapping is found.
//
// ------------------------------------------------------------------------

char *fragment_lookup(char *op, char *lang, int age) {
  static DOHString *str = 0;
  char *key = 0;
  TypeMap *tm = 0;
  
  if (!str) str = NewString("");
  if (!lang) {
    return 0;
  }

  Clear(str);
  key = fragment_string(op,lang);
  tm = typemap_search(key,age);

  if (!tm) return 0;

  Append(str,tm->code);
  return Char(str);
}

// ------------------------------------------------------------------------
// void fragment_clear(char *op, char *lang)
//
// Clears any previous fragment definition.   Is a stack operation--will
// restore any previously declared typemap.
// ------------------------------------------------------------------------

void fragment_clear(char *op, char *lang) {
  
  char     *key;
  TypeMap  *tm;

  key = fragment_string(op,lang);

  // Look for any previous version, simply set the last id if
  // applicable.
  
  tm = (TypeMap *) GetVoid(typemap_hash,key);
  if (tm) {
    if (tm->last > type_id) tm->last = type_id;
  }
}

// -----------------------------------------------------------------------------
// typemap_initialize()
//
// Initialize the hash tables
// -----------------------------------------------------------------------------

void
typemap_initialize() {
  typemap_hash = NewHash();
  application_hash = NewHash();
}
