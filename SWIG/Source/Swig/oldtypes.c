/* ----------------------------------------------------------------------------- 
 * types.cxx
 *
 *     This file contains code for SWIG1.1 type objects.
 *
 * !!! This file is deprecated and is being replaced !!!
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

int type_id = 0;

/* Create a data type only from the type code (used to form constants) */

DataType *NewDataType(int t) {
  DataType *ty = (DataType *) malloc(sizeof(DataType));
  switch(t) {
  case T_BOOL:
    strcpy(ty->name,"bool");
    break;
  case T_INT:
    strcpy(ty->name,"int");
    break;
  case T_UINT:
    strcpy(ty->name,"unsigned int");
    break;
  case T_SHORT:
    strcpy(ty->name,"short");
    break;
  case T_USHORT:
    strcpy(ty->name,"unsigned short");
    break;
  case T_LONG: 
    strcpy(ty->name,"long");
    break;
  case T_ULONG:
    strcpy(ty->name,"unsigned long");
    break;
  case T_FLOAT:
    strcpy(ty->name, "float");
    break;
  case T_DOUBLE:
    strcpy(ty->name, "double");
    break;
  case T_CHAR: case T_SCHAR:
    strcpy(ty->name, "char");
    break;
  case T_UCHAR:
    strcpy(ty->name,"unsigned char");
    break;
  case T_VOID:
    strcpy(ty->name,"void");
    break;
  case T_USER:
    strcpy(ty->name,"USER");
    break;
  default :
    strcpy(ty->name,"");
    break;
  }
  ty->_type = t;
  ty->is_pointer = 0;
  ty->implicit_ptr = 0;
  ty->_qualifier = 0;
  ty->is_reference = 0;
  ty->status = 0;
  ty->_arraystr = 0;
  ty->id = type_id++;
  return ty;
}
 	
DataType *CopyDataType(DataType *t) {
  DataType *ty = (DataType *) malloc(sizeof(DataType));
  ty->_type = t->_type;
  strcpy(ty->name,t->name);
  ty->is_pointer = t->is_pointer;
  ty->implicit_ptr = t->implicit_ptr;
  ty->_qualifier = Swig_copy_string(t->_qualifier);
  ty->is_reference = t->is_reference;
  ty->status = t->status;
  ty->_arraystr = Swig_copy_string(t->_arraystr);
  ty->id = t->id;
  return ty;
}

void DelDataType(DataType *t) {
    if (t->_qualifier) free(t->_qualifier);
    if (t->_arraystr) free(t->_arraystr);
    free(t);
}

int   DataType_type(DataType *t) {
  if ((t->_type == T_CHAR) && (t->is_pointer == 1)) return T_STRING;
  if (t->_arraystr) return T_ARRAY;
  if (t->is_reference) return T_REFERENCE;
  if (t->is_pointer) return T_POINTER;
  return t->_type;
}

int DataType_Gettypecode(DataType *t) {
  return t->_type;
}

void DataType_Settypecode(DataType *t, int ty) {
  t->_type = ty;
}

char *DataType_qualifier(DataType *t) {
  return t->_qualifier;
}

void DataType_set_qualifier(DataType *t, char *q) {
  if (t->_qualifier) free(t->_qualifier);
  t->_qualifier = Swig_copy_string(q);
}

char *DataType_arraystr(DataType *t) {
  return t->_arraystr;
}

void DataType_set_arraystr(DataType *t, char *a) {
  if (t->_arraystr) free(t->_arraystr);
  t->_arraystr = Swig_copy_string(a);
}


/* --------------------------------------------------------------------
 * DataType_primitive()
 *
 * Turns a datatype into its bare-bones primitive type.  Rarely used,
 * but sometimes used for typemaps.  Permanently alters the datatype!
 * -------------------------------------------------------------------- */

void DataType_primitive(DataType *t) {
  switch(t->_type) {
  case T_BOOL:
    strcpy(t->name,"bool");
    break;
  case T_INT:
    strcpy(t->name,"int");
    break;
  case T_SHORT:
    strcpy(t->name,"short");
    break;
  case T_LONG: 
    strcpy(t->name,"long");
    break;
  case T_CHAR: 
    strcpy(t->name,"char");
    break;
  case T_SCHAR:
    strcpy(t->name,"signed char");
    break;
  case T_UINT:
    strcpy(t->name,"unsigned int");
    break;
  case T_USHORT:
    strcpy(t->name,"unsigned short");
    break;
  case T_ULONG:
    strcpy(t->name,"unsigned long");
    break;
  case T_UCHAR:
    strcpy(t->name,"unsigned char");
    break;
  case T_FLOAT:
    strcpy(t->name,"float");
    break;
  case T_DOUBLE:
    strcpy(t->name,"double");
    break;
  case T_VOID:
    strcpy(t->name,"void");
    break;
  case T_USER:
    strcpy(t->name,"USER");
    break;
  default:
    strcpy(t->name,"UNKNOWN");
    break;
  }
  t->implicit_ptr = 0;           /* Gets rid of typedef'd pointers */
  if (t->_qualifier) {
    free(t->_qualifier);
    t->_qualifier = 0;
  }
  t->_qualifier = 0;
  t->status = 0;
}

/* --------------------------------------------------------------------
 * char *mangle_default()
 *
 * Prints a mangled version of this datatype.   Used for run-time type
 * checking in order to print out a "language friendly" version (ie. no
 * spaces and no weird characters).
 * -------------------------------------------------------------------- */

char *DataType_mangle_default(DataType *t) {
  static char   result[8][256];
  static int    ri = 0;
  int   i;
  char *c;
  char *d;

  ri = ri % 8;
  c = t->name;

  result[ri][0] = '_';

  d = result[ri] + 1;

  if ((strncmp(c,"struct ",7) == 0) || (strncmp(c,"class ",6) == 0) || (strncmp(c,"union ",6) == 0)) {
    c = strchr(c,' ') + 1;
  }
  for (; *c; c++) {
      if ((*c == ' ') || (*c == ':') || (*c == '<') || (*c == '>')) *(d++) = '_';
      else *(d++) = *c;
  }
  if ((t->is_pointer-t->implicit_ptr)) *(d++) = '_';
  for (i = 0; i < (t->is_pointer-t->implicit_ptr); i++)
    *(d++) = 'p';

  *d = 0;
  return result[ri++];
}

/* This is kind of ugly but needed for each language to support a
   custom name mangling mechanism.  (ie. Perl5). */

static char *(*mangler)(DataType *t) = DataType_mangle_default;

char *DataType_manglestr(DataType *t) {
   /* Call into target language for name mangling. */
  return (*mangler)(t);
}

void DataType_set_mangle(char *(*m)(DataType *t)) {
  mangler = m;
}

/* -----------------------------------------------------------------------------
 * char *DataType_str()
 *
 * Produces an exact string representation of the datatype along with an optional
 * variable name.
 * ----------------------------------------------------------------------------- */

char *DataType_str(DataType *t, DOHString_or_char *name) {
  static char  result[8][256];
  static int    ri = 0;
  int i;

  ri = ri % 8;
  if (t->_arraystr) t->is_pointer--;
  if (t->is_reference) t->is_pointer--;
  if (t->_qualifier) {
    sprintf(result[ri],"%s %s", t->_qualifier, t->name);
  } else {
    sprintf(result[ri],"%s ", t->name);
  }

  for (i = 0; i < (t->is_pointer-t->implicit_ptr); i++) {
    strcat(result[ri],"*");
  }
  if (t->is_reference) strcat(result[ri],"&");
  if (name) strcat(result[ri],Char(name));
  if (t->_arraystr) {
    strcat(result[ri],t->_arraystr);
    t->is_pointer++;
  }
  if (t->is_reference) t->is_pointer++;
  return result[ri++];
}

/* --------------------------------------------------------------------
 * char *DataType_lstr()
 *
 * Produces a type-string that is suitable as a lvalue in an expression.
 * That is, a type that can be freely assigned a value without violating
 * any C assignment rules.
 *
 *      -   Qualifiers such as 'const' and 'volatile' are stripped.
 *      -   Arrays are converted into a *single* pointer (i.e.,
 *          double [][] becomes double *).
 *      -   References are converted into a pointer.
 *      -   Typedef names that refer to read-only types will be replaced
 *          with an equivalent assignable version.
 * -------------------------------------------------------------------- */

char *DataType_lstr(DataType *ty, DOHString_or_char *name) {
  static char    result[8][256];
  static int    ri = 0;
  int i;
  DataType *t = ty;
  
  if (ty->status & STAT_REPLACETYPE) {
    t = CopyDataType(ty);
    DataType_typedef_replace(t);    /* Replace the type with its typedef value */
  }
  ri = ri % 8;
  sprintf(result[ri],"%s ", t->name);
  for (i = 0; i < (t->is_pointer-t->implicit_ptr); i++)
    strcat(result[ri],"*");

  if (ty->status & STAT_REPLACETYPE) {
    DelDataType(t);
  }
  if (name) {
    strcat(result[ri],Char(name));
  }
  return result[ri++];
}

/* -----------------------------------------------------------------------------
 * DataType_ltype(DataType *ty)
 *
 * Returns a type object corresponding to the string created by lstr
 * ----------------------------------------------------------------------------- */

DataType *DataType_ltype(DataType *t) {

  DataType *ty = CopyDataType(t);
  if (ty->status & STAT_REPLACETYPE) {
    DataType_typedef_replace(ty);    /* Replace the type with its typedef value */
  }
  if (ty->_qualifier) {
    free(ty->_qualifier);
    ty->_qualifier = 0;
  }
  if (ty->_arraystr) {
    free(ty->_arraystr);
    ty->_arraystr = 0;
  }
  ty->is_reference = 0;
  return ty;
}

/* -----------------------------------------------------------------------------
 * char *DataType_rcaststr(DataType *t, char *name)
 *
 * Produces a casting string that maps the type returned by lstr() to the real 
 * datatype printed by str().
 * ----------------------------------------------------------------------------- */

char *DataType_rcaststr(DataType *ty, DOHString_or_char *name) {
  static char   result[8][256];
  static int    ri = 0;
  DataType *t = 0;
  ri = ri % 8;

  strcpy(result[ri],"");
  if (ty->_arraystr) {
    t = ty;
    if (ty->status & STAT_REPLACETYPE) {
      t = CopyDataType(ty);
      DataType_typedef_replace(t);
    }

    ri = ri % 8;
    if (t->_arraystr) {
      int ndim;
      char *c;
      ndim = 0;
      c = t->_arraystr;
      while (*c) {
	if (*c == '[') ndim++;
	c++;
      }
      if (ndim > 1) {
	/* a Multidimensional array.  Provide a special cast for it */
	char *oldarr = 0;
	int oldstatus = ty->status;
	t->status = t->status & (~STAT_REPLACETYPE);
	t->is_pointer--;
	oldarr = t->_arraystr;
	t->_arraystr = 0;
	sprintf(result[ri],"(%s", DataType_str(t,0));
	t->_arraystr = oldarr;
	t->is_pointer++;
	t->status = oldstatus;
	strcat(result[ri]," (*)");
	c = t->_arraystr;
	while (*c) {
	  if (*c == ']') break;
	  c++;
	}
	if (*c) c++;
	strcat(result[ri],c);
	strcat(result[ri],")");
      }
    }
    if (ty->status & STAT_REPLACETYPE) {
      DelDataType(t);
    }
  } else if (ty->_qualifier) {
    /* Make a cast to restore const/volatile */
    sprintf(result[ri],"(%s)", DataType_str(ty,0));
  }

  if (name) {
    if (ty->is_reference) {
      strcat(result[ri],"*");
    }
    strcat(result[ri],Char(name));
  }
  return result[ri++];
}

/* -----------------------------------------------------------------------------
 * DataType_lcaststr()
 *
 * Casts a variable from the real type to the local datatype.
 * ----------------------------------------------------------------------------- */

char *DataType_lcaststr(DataType *ty, DOHString_or_char *name) {
  static char   result[8][256];
  static int    ri = 0;
  ri = ri % 8;

  strcpy(result[ri],"");
  
  if (ty->_arraystr) {
    sprintf(result[ri],"(%s)", DataType_lstr(ty,0));
    if (name)
      strcat(result[ri], Char(name));
  } else if (ty->is_reference) {
    sprintf(result[ri],"(%s)", DataType_lstr(ty,0));
    if (name) {
      strcat(result[ri], "&");
      strcat(result[ri], Char(name));
    }
  } else if (ty->_qualifier) {
    sprintf(result[ri],"(%s)", DataType_lstr(ty,0));
    if (name) {
      strcat(result[ri], Char(name));
    }
  } else {
    if (name) {
      strcat(result[ri], Char(name));
    }
  }
  return result[ri++];
}

/* --------------------------------------------------------------------
 * int DataType_array_dimensions()
 *
 * Returns the number of dimensions in an array or 0 if not an array.
 * -------------------------------------------------------------------- */

int DataType_array_dimensions(DataType *t) {
  char *c;
  int  ndim = 0;

  if (!t->_arraystr) return 0;
  c = t->_arraystr;
  while (*c) {
    if (*c == '[') {
      ndim++;
    }
    c++;
  }
  return ndim;
}

/* --------------------------------------------------------------------
 * char *DataType_get_dimension(int n)
 * 
 * Returns a string containing the value specified for dimension n.
 * -------------------------------------------------------------------- */

char *DataType_get_dimension(DataType *t, int n) {
  static char dim[256];
  char  *c;
  char  *d = dim;

  if (n >= DataType_array_dimensions(t)) {
    *d = 0;
    return dim;
  }
  
   /* Attempt to locate the right dimension */

  c = t->_arraystr;
  while ((*c) && (n >= 0)) {
    if (*c == '[') n--;
    c++;
  }
  
   /* c is now at start of array dimension */
  if (*c) {
    while ((*c) && (*c != ']')) {
      *(d++) = *(c++);
    }
  }
  *d = 0;
  return dim;
}

/* --------------------------------------------------------------------
 * typedef support.  This needs to be scoped.
 * -------------------------------------------------------------------- */
#define MAXSCOPE 16

static DOHHash *typedef_hash[MAXSCOPE];
static int      scope = 0;             /* Current scope */

/* -----------------------------------------------------------------------------
 * void DataType_init_typedef() 
 * 
 * Inputs : None
 *
 * Output : None
 *
 * Side Effects : Initializes the typedef hash tables
 * ----------------------------------------------------------------------------- */

void DataType_init_typedef() {
  int i;
  for (i = 0; i < MAXSCOPE; i++)
    typedef_hash[i] = 0;
  scope = 0;
  typedef_hash[scope] = NewHash();
}

/* --------------------------------------------------------------------
 * int DataType_typedef_add()
 *
 * Adds this datatype to the typedef hash table.  mode is an optional
 * flag that can be used to only add the symbol as a typedef, but not
 * generate any support code for the SWIG typechecker.  This is used
 * for some of the more obscure datatypes like function pointers,
 * arrays, and enums.
 * --------------------------------------------------------------------*/

int DataType_typedef_add(DataType *t,char *tname, int mode) {
  char     *name1, *name2;
  DataType *nt, *t1;
  void typeeq_addtypedef(char *name, char *eqname, DataType *);

  /* Check to see if this typedef already defined
   * We only check in the local scope.   C++ classes may make typedefs
   * that shadow global ones.*/

  if (Getattr(typedef_hash[scope],tname)) {
    return -1;
  }

  /* Make a new datatype that we will place in our hash table */

  nt = CopyDataType(t);
  nt->implicit_ptr = (t->is_pointer-t->implicit_ptr);  /* Record if mapped type is a pointer*/
  nt->is_pointer = (t->is_pointer-t->implicit_ptr);    /* Adjust pointer value to be correct */
  DataType_typedef_resolve(nt,0);                      /* Resolve any other mappings of this type */
  
  /* Add this type to our hash table */
  SetVoid(typedef_hash[scope],tname, (void *) nt);

  /* Now add this type mapping to our type-equivalence table */

  if (mode == 0) {
      if ((t->_type != T_VOID) && (strcmp(t->name,tname) != 0)) {
	t1 = NewDataType(0);
	strcpy(t1->name,tname);
	name2 = DataType_manglestr(t1);
	name1 = DataType_manglestr(t);
	typeeq_addtypedef(name1,name2,t1);
	typeeq_addtypedef(name2,name1,t);
	DelDataType(t1);
      }
  }
  /* Call into the target language with this typedef */
  /*  lang->add_typedef(t,tname); */
  return 0;
}

/* --------------------------------------------------------------------
 * void DataType_typedef_resolve(int level = 0)
 *
 * Checks to see if this datatype is in the typedef hash and
 * resolves it if necessary.   This will check all of the typedef
 * hash tables we know about.
 *
 * level is an optional parameter that determines which scope to use.
 * Usually this is only used with a bare :: operator in a datatype.
 * 
 * The const headache :
 *
 * Normally SWIG will fail if a const variable is used in a typedef
 * like this :
 *
 *       typedef const char *String;
 *
 * This is because future occurrences of "String" will be treated like
 * a char *, but without regard to the "constness".  To work around 
 * this problem.  The resolve() method checks to see if these original 
 * data type is const.  If so, we'll substitute the name of the original
 * datatype instead.  Got it? Whew.   In a nutshell, this means that
 * all future occurrences of "String" will really be "const char *".
 * -------------------------------------------------------------------- */

void DataType_typedef_resolve(DataType *t, int level) {

  DataType *td;
  int       s = scope - level;

  while (s >= 0) {
    if ((td = (DataType *) GetVoid(typedef_hash[s],t->name))) {
      t->_type = td->_type;
      t->is_pointer += td->is_pointer;
      t->implicit_ptr += td->implicit_ptr;
      t->status = t->status | td->status;

      /* Check for constness, and replace type name if necessary*/

      if (td->_qualifier) {
	if (strcmp(td->_qualifier,"const") == 0) {
	  strcpy(t->name,td->name);
	  t->_qualifier = Swig_copy_string(td->_qualifier);
	  t->implicit_ptr -= td->implicit_ptr;
	}
      }
      return;
    }
    s--;
  }
  /* Not found, do nothing */
  return;
}

/* --------------------------------------------------------------------
 * void DataType_typedef_replace()
 *
 * Checks to see if this datatype is in the typedef hash and
 * replaces it with the hash entry. Only applies to current scope.
 * -------------------------------------------------------------------- */

void DataType_typedef_replace (DataType *t) {
  DataType *td;
  char   temp[512];

  temp[0] = 0;

  if ((td = (DataType *) GetVoid(typedef_hash[scope],t->name))) {
    t->_type = td->_type;
    t->is_pointer = td->is_pointer;
    t->implicit_ptr -= td->implicit_ptr;
    strcpy(t->name, td->name);
    if (td->_arraystr) {
      if (t->_arraystr) {
	strcat(temp,t->_arraystr);
	free(t->_arraystr);
      }
      strcat(temp,td->_arraystr);
      t->_arraystr = Swig_copy_string(temp);
    }
  }
  /* Not found, do nothing */
  return;
}

/* ---------------------------------------------------------------
 * int DataType_is_typedef(char *t)
 *
 * Checks to see whether t is the name of a datatype we know
 * about.  Returns 1 if there's a match, 0 otherwise
 * --------------------------------------------------------------- */

int DataType_is_typedef(char *t) {
  int s = scope;
  while (s >= 0) {
    if (Getattr(typedef_hash[s],t)) return 1;
    s--;
  }
  return 0;
}

/* ---------------------------------------------------------------
 * void DataType_typedef_updatestatus(int newstatus)
 *
 * Checks to see if this datatype is in the hash table.  If
 * so, we'll update its status.   This is sometimes used with
 * typemap handling.  Only applies to current scope.
 * --------------------------------------------------------------- */

void DataType_typedef_updatestatus(DataType *t, int newstatus) {

  DataType *nt;
  if ((nt = (DataType *) GetVoid(typedef_hash[scope],t->name))) {
    nt->status = newstatus;
  }
}

/* -----------------------------------------------------------------------------
 * void DataType_merge_scope(Hash *h) 
 * 
 * Copies all of the entries in scope h into the current scope.  This is
 * primarily done with C++ inheritance.
 *
 * Inputs : Hash table h.
 *
 * Output : None
 *
 * Side Effects : Copies all of the entries in h to current scope.
 * ----------------------------------------------------------------------------- */

void DataType_merge_scope(void *ho) {
  DOHString *key;
  DataType *t, *nt;
  DOHHash *h = (DOHHash *) ho;

  if (h) {
    /* Copy all of the entries in the given hash table to this new one */
    key = Firstkey(h);
    while (key) {
      /*      printf("%s\n", key); */
      t = (DataType *) GetVoid(h,key);
      nt = CopyDataType(t);
      SetVoid(typedef_hash[scope],key,(void *) nt);
      key = Nextkey(h);
    }
  }
}

/* -----------------------------------------------------------------------------
 * void DataType_new_scope(Hash *h = 0)
 *
 * Creates a new scope for handling typedefs.   This is used in C++ handling
 * to create typedef local to a class definition. 
 * 
 * Inputs : h = Optional hash table scope (Used for C++ inheritance).
 *
 * Output : None
 *
 * Side Effects : Creates a new hash table and increments the scope counter
 * ----------------------------------------------------------------------------- */

void DataType_new_scope(void *ho) {
  scope++;
  typedef_hash[scope] = NewHash();
  if (ho) {
    DataType_merge_scope(ho);
  }
}

/* -----------------------------------------------------------------------------
 * Hash *DataType_collapse_scope(char *prefix) 
 * 
 * Collapses the current scope into the previous one, but applies a prefix to
 * all of the datatypes.   This is done in order to properly handle C++ stuff.
 * For example :
 *
 *      class Foo {
 *         ... 
 *         typedef double Real;
 *      }
 *
 * will have a type mapping of "double --> Real" within the class itself. 
 * When we collapse the scope, this mapping will become "double --> Foo::Real"
 *
 * Inputs : None
 *
 * Output : None
 *
 * Side Effects : Returns the hash table corresponding to the current scope
 * ----------------------------------------------------------------------------- */

void *DataType_collapse_scope(char *prefix) {
  DataType *t,*nt;
  DOHString *key;
  char     *temp;
  DOHHash  *h;

  if (scope > 0) {
    if (prefix) {
      key = Firstkey(typedef_hash[scope]);
      while (key) {
	t = (DataType *) GetVoid(typedef_hash[scope],key);
	nt = CopyDataType(t);
	temp = (char *) malloc(strlen(prefix)+strlen(Char(key)) + 4);
	sprintf(temp,"%s::%s",prefix,Char(key));
	SetVoid(typedef_hash[scope-1],temp, (void *)nt);
	free(temp);
	key = Nextkey(typedef_hash[scope]);
      }
    }
    h = typedef_hash[scope];
    typedef_hash[scope] = 0;
    scope--;
    return (void *) h;
  }
  return 0;
}
		
/* -------------------------------------------------------------
 * Class equivalency lists
 * 
 * These are used to keep track of which datatypes are equivalent.
 * This information can be dumped in tabular form upon completion
 * for use in the pointer type checker.
 *
 * cast is an extension needed to properly handle multiple inheritance
 * -------------------------------------------------------------- */

typedef struct EqEntry {
  char     *name;
  char     *cast;
  DataType *type;
  struct EqEntry  *next;
} EqEntry;

static DOHHash *typeeq_hash = 0;
static int  te_init = 0;

void typeeq_init() {
  void typeeq_standard();
  if (!typeeq_hash) typeeq_hash = NewHash();
  te_init = 1;
  typeeq_standard();
}


/* --------------------------------------------------------------
 * typeeq_add(char *name, char *eqname, char *cast) 
 *
 * Adds a new name to the type-equivalence tables.
 * Creates a new entry if it doesn't exit.
 *
 * Cast is an optional name for a pointer casting function.
 * -------------------------------------------------------------- */

void typeeq_add(char *name, char *eqname, char *cast, DataType *type) {
  EqEntry *e1,*e2;

  if (!te_init) typeeq_init();

  if (strcmp(name,eqname) == 0) return;    /* If they're the same, forget it. */
  
  /* Search for "name" entry in the hash table */

  e1 = (EqEntry *) GetVoid(typeeq_hash,name);

  if (!e1) {
    /* Create a new entry */
    e1 = (EqEntry *) malloc(sizeof(EqEntry));
    e1->name = Swig_copy_string(name);
    e1->next = 0;
    e1->cast = 0;
    /* Add it to the hash table */
    SetVoid(typeeq_hash,name,(void *) e1);
  }

  /* Add new type to the list
   * We'll first check to see if it's already been added */

  e2 = e1->next;
  while (e2) {
    if (strcmp(e2->name, eqname) == 0) {
      if (cast) 
	e2->cast = Swig_copy_string(cast);
      return;
    }
    e2 = e2->next;
  }

  e2 = (EqEntry *) malloc(sizeof(EqEntry));
  e2->name = Swig_copy_string(eqname);
  e2->cast = Swig_copy_string(cast);
  if (type) 
    e2->type = CopyDataType(type);
  else 
    e2->type = 0;
  e2->next = e1->next;                /* Add onto the linked list for name */
  e1->next = e2;

}

/* --------------------------------------------------------------
 * typeeq_addtypedef(char *name, char *eqname, DataType *t) 
 *
 * Adds a new typedef declaration to the equivelency list.
 * -------------------------------------------------------------- */

void typeeq_addtypedef(char *name, char *eqname, DataType *t) {
  EqEntry  *e1,*e2;

  if (!te_init) typeeq_init();

  if (!t) {
    t = NewDataType(T_USER);
    strcpy(t->name, eqname);
  }

  /*printf("addtypedef: %s : %s : %s\n", name, eqname, t->print_type()); */

  /* First we're going to add the equivalence, no matter what */
  
  typeeq_add(name,eqname,0,t);

  /* Now find the hash entry */

  e1 = (EqEntry *) GetVoid(typeeq_hash,name);
  if (!e1) return;

  /* Walk down the list and make other equivalences */

  e2 = e1->next;
  while (e2) {
    if (strcmp(e2->name, eqname) != 0) {
      typeeq_add(e2->name, eqname,e2->cast,t);
      typeeq_add(eqname, e2->name,e2->cast,e2->type);
    }
    e2 = e2->next;
  }
}

/* ----------------------------------------------------------------
 * void emit_ptr_equivalence()
 *
 * Dump out the pointer equivalence table to file.
 *
 * Changed to register datatypes with the type checker in order
 * to support proper type-casting (needed for multiple inheritance)
 * ---------------------------------------------------------------- */

void emit_ptr_equivalence(DOHFile *tablef, DOHFile *initf) {

  EqEntry      *e1,*e2;
  DOH          *k;
  void         typeeq_standard();
  DOHString   *ttable;

  if (!te_init) typeeq_init();

  ttable = NewString("");

  Printv(ttable,"\
/*\n\
 * This table is used by the pointer type-checker\n\
 */\n\
static struct { char *n1; char *n2; void *(*pcnv)(void *); } _swig_mapping[] = {\n",
	 0);

  k = Firstkey(typeeq_hash);
  while (k) {
    e1 = (EqEntry *) GetVoid(typeeq_hash,k);
    e2 = e1->next;
    /* Walk through the equivalency list */
    while (e2) {
      if (e2->cast) 
	Printv(ttable,
	       "    { \"", e1->name, "\",\"", e2->name, "\"," , e2->cast , "},\n",
	       0);
      else
	Printv(ttable,
	       "    { \"", e1->name, "\",\"", e2->name, "\",0},\n",
	       0);

      e2 = e2->next;
    }
    k = Nextkey(typeeq_hash);
  }
  Printf(ttable,"{0,0,0}};\n");
  Printf(tablef,"%s\n", Char(ttable));
  Printf(initf,"{\n");
  Printf(initf,"   int i;\n");
  Printf(initf,"   for (i = 0; _swig_mapping[i].n1; i++)\n");
  Printf(initf,"        SWIG_RegisterMapping(_swig_mapping[i].n1,_swig_mapping[i].n2,_swig_mapping[i].pcnv);\n");
  Printf(initf,"}\n");
  Delete(ttable);
}

/* ------------------------------------------------------------------------------
 * typeeq_derived(char *n1, char *n2, char *cast)
 *
 * Adds a one-way mapping between datatypes.
 * ------------------------------------------------------------------------------ */

void typeeq_derived(char *n1, char *n2, char *cast) {
  DataType   *t,*t1;
  char       *name, *name2;

  t = NewDataType(0);
  t1 = NewDataType(0);
  if (!te_init) typeeq_init();

  t->_type = T_USER;
  t1->_type = T_USER;
  strcpy(t->name,n1);
  strcpy(t1->name,n2);
  name = DataType_manglestr(t);
  name2 = DataType_manglestr(t1);
  typeeq_add(name,name2, cast, t1);
  DelDataType(t);
  DelDataType(t1);
}

/* ------------------------------------------------------------------------------
 * typeeq_mangle(char *n1, char *n2, char *cast=)
 *
 * Adds a single type equivalence
 * ------------------------------------------------------------------------------ */

void typeeq_mangle(char *n1, char *n2, char *cast) {
  DataType   *t,*t1;
  char      *name, *name2;

  t = NewDataType(0);
  t1 = NewDataType(0);
  if (!te_init) typeeq_init();

  strcpy(t->name,n1);
  strcpy(t1->name,n2);
  name = DataType_manglestr(t);
  name2 = DataType_manglestr(t1);
  typeeq_add(name,name2,cast,0);
  DelDataType(t);
  DelDataType(t1);
}

/* ------------------------------------------------------------------------------
 * typeeq_standard(void)
 *
 * Generate standard type equivalences (well, pointers that can map into
 * other pointers naturally).
 * 
 * ------------------------------------------------------------------------------- */
  
void typeeq_standard(void) {
  
  typeeq_mangle((char*)"int", (char*)"signed int",0);
  typeeq_mangle((char*)"int", (char*)"unsigned int",0);
  typeeq_mangle((char*)"signed int", (char*)"int",0);
  typeeq_mangle((char*)"unsigned int", (char*)"int",0);
  typeeq_mangle((char*)"short",(char*)"signed short",0);
  typeeq_mangle((char*)"signed short",(char*)"short",0);
  typeeq_mangle((char*)"short",(char*)"unsigned short",0);
  typeeq_mangle((char*)"unsigned short",(char*)"short",0);
  typeeq_mangle((char*)"long",(char*)"signed long",0);
  typeeq_mangle((char*)"signed long",(char*)"long",0);
  typeeq_mangle((char*)"long",(char*)"unsigned long",0);
  typeeq_mangle((char*)"unsigned long",(char*)"long",0);

}

/* ----------------------------------------------------------------------
 * char *check_equivalent(DataType *t)
 *
 * Checks for type names equivalent to t.  Returns a string with entries
 * suitable for output.
 * ---------------------------------------------------------------------- */

static char *
check_equivalent(DataType *t) {
  EqEntry *e1, *e2;
  static DOHString *out = 0;
  int    npointer = t->is_pointer;
  char  *m;
  DOHString *k;

  if (!out) out = NewString("");
  Clear(out);

  while (t->is_pointer >= t->implicit_ptr) {
    m = Swig_copy_string(DataType_manglestr(t));

    if (!te_init) typeeq_init();

    k = Firstkey(typeeq_hash);
    while (k) {
      e1 = (EqEntry *) GetVoid(typeeq_hash,k);
      if (strcmp(m,e1->name) == 0) {
	e2 = e1->next;
	while (e2) {
	  if (e2->type) {
	    e2->type->is_pointer += (npointer - t->is_pointer);
	    Printf(out,"{ \"%s\",", DataType_manglestr(e2->type));
	    e2->type->is_pointer -= (npointer - t->is_pointer);
	    if (e2->cast) 
	      Printf(out,"%s}, ", e2->cast);
	    else
	      Printf(out,"0}, ");
	  }
	  e2 = e2->next;
	}
      }
      k = Nextkey(typeeq_hash);
    }
    free(m);
    t->is_pointer--;
  }
  t->is_pointer = npointer;
  Printf(out,"{0}");
  return Char(out);
}

/* -----------------------------------------------------------------------------
 * void DataType_record_base(char *derived, char *base)
 *
 * Record base class information.  This is a hack to make runtime libraries
 * work across multiple files.
 * ----------------------------------------------------------------------------- */

static DOHHash  *bases = 0;

void DataType_record_base(char *derived, char *base)
{
  DOHHash *nh;
  if (!bases) bases = NewHash();
  nh = Getattr(bases,derived);
  if (!nh) {
    nh = NewHash();
    Setattr(bases,derived,nh);
  }
  if (!Getattr(nh,base)) {
    Setattr(nh,base,base);
  }
}

/* ----------------------------------------------------------------------
 * void DataType_remember()
 *
 * Marks a datatype as being used in the interface file.   We use this to
 * construct a big table of pointer values at the end.
 * ---------------------------------------------------------------------- */

static  DOHHash  *remembered = 0;

void DataType_remember(DataType *ty) {
  DOHHash *h;
  DataType *t = CopyDataType(ty);

  if (!remembered) remembered = NewHash();
  SetVoid(remembered, DataType_manglestr(t), t);

  if (!bases) bases = NewHash();
  /* Now, do the base-class hack */
  h = Getattr(bases,t->name);
  if (h) {
    DOH *key;
    key = Firstkey(h);
    while (key) {
      DataType *nt = CopyDataType(t);
      strcpy(nt->name,Char(key));
      if (!Getattr(remembered,DataType_manglestr(nt))) 
	DataType_remember(nt);
      DelDataType(nt);
      key = Nextkey(h);
    }
  }
}

void
emit_type_table(DOHFile *out) {
  DOH *key;
  DOHString *types, *table;
  int i = 0;

  if (!remembered) remembered = NewHash();

  table = NewString("");
  types = NewString("");
  Printf(table,"static _swig_type_info *_swig_types_initial[] = {\n");
  key = Firstkey(remembered);
  Printf(out,"/* ---- TYPES TABLE (BEGIN) ---- */\n");
  while (key) {
    Printf(out,"#define  SWIGTYPE%s _swig_types[%d] \n", key, i);
    Printv(types,"static _swig_type_info _swigt_", Char(key), "[] = {", 0);
    Printv(types,"{\"", Char(key), "\",0},", 0);
    Printv(types, "{\"", Char(key), "\",0},", 0);
    Printv(types, check_equivalent((DataType *)GetVoid(remembered,key)), "};\n", 0);
    Printv(table, "_swigt_", Char(key), ", \n", 0);
    key = Nextkey(remembered);
    i++;
  }

  Printf(table, "0\n};\n");
  Printf(out,"static _swig_type_info *_swig_types[%d];\n", i+1);

  Printf(out,"%s\n", types);
  Printf(out,"%s\n", table);
  Printf(out,"/* ---- TYPES TABLE (END) ---- */\n\n");
  Delete(types);
  Delete(table);
}






