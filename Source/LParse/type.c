/* ----------------------------------------------------------------------------- 
 * type.c
 *
 *     Lame SWIG1.1 type implementation.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

static char cvsroot[] = "$Header$";

#include "lparse.h"

extern DOH *LParseTypeStr(DOH *to);

static DohObjInfo LParseTypeType = {
    "LParseType",          /* objname */
    sizeof(LParseType),    /* objsize */
    DelLParseType,         /* doh_del */
    CopyLParseType,        /* doh_copy */
    0,                   /* doh_clear */
    0,                   /* doh_scope */
    LParseTypeStr,         /* doh_str */
    0,                   /* doh_data */
    0,                   /* doh_dump */
    0,                   /* doh_load */
    0,                   /* doh_len */
    0,                   /* doh_hash    */
    0,                   /* doh_cmp */
    0,                   /* doh_mapping */
    0,                   /* doh_sequence */
    0,                   /* doh_file */
    0,                   /* doh_string */ 
    0,                   /* doh_callable */ 
    0,                   /* doh_position */
};

/* -----------------------------------------------------------------------------
 * NewLParseType()   - Create a new datatype
 * ----------------------------------------------------------------------------- */
LParseType *
NewLParseType(int ty) {
  LParseType *t = (LParseType *) DohObjMalloc(sizeof(LParseType));
  t->objinfo = &LParseTypeType;
  t->type = ty;
  t->name = (char *) malloc(LPARSE_MAX_NAME);
  t->name[0] = 0;
  t->is_pointer = 0;
  t->implicit_ptr = 0;
  t->is_reference = 0;
  t->status = 0;
  t->qualifier = 0;
  t->arraystr = 0;
  switch(ty) {
  case LPARSE_T_INT: 
    strcpy(t->name,"int");
    break;
  case LPARSE_T_UINT: 
    strcpy(t->name,"unsigned");
    break;
  case LPARSE_T_SHORT: 
    strcpy(t->name,"short");
    break;
  case LPARSE_T_USHORT: 
    strcpy(t->name,"unsigned short");
    break;
  case LPARSE_T_LONG: 
    strcpy(t->name,"long");
    break;
  case LPARSE_T_ULONG: 
    strcpy(t->name,"unsigned long");
    break;
  case LPARSE_T_FLOAT: 
    strcpy(t->name,"float");
    break;
  case LPARSE_T_DOUBLE: 
    strcpy(t->name,"double");
    break;
  case LPARSE_T_CHAR: 
    strcpy(t->name,"char");
    break;
  case LPARSE_T_SCHAR: 
    strcpy(t->name,"signed char");
    break;
  case LPARSE_T_UCHAR: 
    strcpy(t->name,"unsigned char");
    break;
  case LPARSE_T_VOID: 
    strcpy(t->name,"void");
    break;
  case LPARSE_T_BOOL: 
    strcpy(t->name,"bool");
    break;
  default:
    break;
  }
  return t;
}

/* -----------------------------------------------------------------------------
 * DelLParseType()  - Destroy a datatype
 * ----------------------------------------------------------------------------- */
void DelLParseType(DOH *t) {
  LParseType *ty = (LParseType *) t;
  assert(ty->refcount <= 0);
  free(ty->name);
  if (ty->qualifier) free(ty->qualifier);
  if (ty->arraystr) free(ty->arraystr);
}

/* -----------------------------------------------------------------------------
 * CopyLParseType()   - Copy a type
 * ----------------------------------------------------------------------------- */
DOH *
CopyLParseType(DOH *co) {
  LParseType *c;
  LParseType *t = (LParseType *) DohObjMalloc(sizeof(LParseType));
  c = (LParseType *) co;
  t->objinfo = &LParseTypeType;
  t->type = c->type;
  t->name = (char *) malloc(LPARSE_MAX_NAME);
  strcpy(t->name,c->name);
  t->is_pointer = c->is_pointer;
  t->implicit_ptr = c->implicit_ptr;
  t->is_reference = c->is_reference;
  t->status = c->status;
  t->qualifier = Swig_copy_string(c->qualifier);
  t->arraystr = Swig_copy_string(c->arraystr);
  return t;
}

/* ----------------------------------------------------------------------------- 
 * LParseTypeStr() - Make a string of a datatype. 
 * ----------------------------------------------------------------------------- */
DOH *
LParseTypeStr(DOH *to) {
  DOH *s;
  int i;
  LParseType *t = (LParseType *) to;
  s = NewString("");
  if (t->qualifier)
    Printf(s,"%s ",t->qualifier);
  Printf(s,"%s ",t->name);
  if (t->is_reference || t->arraystr) t->is_pointer--;
  for (i = 0; i < t->is_pointer; i++)
    Putc('*',s);
  if (t->is_reference || t->arraystr) t->is_pointer++;
  if (t->is_reference)
    Putc('&',s);
  if (t->arraystr)
    Printf(s,"%s", t->arraystr);
  return s;
}

/* -----------------------------------------------------------------------------
 *                      --- typedef support ---
 * ----------------------------------------------------------------------------- */

#define MAXSCOPE 256
static DOH  *typedef_hash[MAXSCOPE];
static int   scope = 0;
static int   typedef_init = 0;

static void init_typedef() {
  int i;
  for (i = 0; i < MAXSCOPE; i++)
    typedef_hash[i] = 0;
  scope = 0;
  typedef_hash[scope] = NewHash();
  typedef_init = 1;
}

/* -----------------------------------------------------------------------------
 * void LParse_typedef_add(LParseType *t, DOH *tname)
 *
 * Create a new typedef.
 * ----------------------------------------------------------------------------- */

void LParse_typedef_add(LParseType *t, DOH *tname) {
  LParseType *nt;

  if (!typedef_init) init_typedef();
  /* Check to see if the type already exists */
  if ((nt = (LParseType *) Getattr(typedef_hash[scope],tname))) {
    Printf(stderr,"Warning. Datatype %s already defined (2nd definition ignored).\n", tname);
    return;
  }

  nt = (LParseType *) CopyLParseType(t);
  nt->implicit_ptr = (t->is_pointer-t->implicit_ptr); /* Record if mapped type is a pointer */
  nt->is_pointer = (t->is_pointer-t->implicit_ptr);   /* Adjust pointer value to be correct */
  LParse_typedef_resolve(nt,0);                        /* Resolve any other mappings of this type */
  
  /* Add this type to our hash table */
  Setattr(typedef_hash[scope],tname, nt);
}

/* -----------------------------------------------------------------------------
 * void LParse_typedef_resolve(LParseType *t, int level = 0)
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
 * datatype instead.  Got it? 
 * ----------------------------------------------------------------------------- */

void LParse_typedef_resolve(LParseType *t, int level) {
  LParseType *td;
  int       s = scope - level;

  if (!typedef_init) init_typedef();
  while (s >= 0) {
    if ((td = (LParseType *) Getattr(typedef_hash[s],t->name))) {
      t->type = td->type;
      t->is_pointer += td->is_pointer;
      t->implicit_ptr += td->implicit_ptr;
      t->status = t->status | td->status;

      /* Check for constness, and replace type name if necessary */

      if (td->qualifier) {
	if (strcmp(td->qualifier,"const") == 0) {
	  strcpy(t->name,td->name);
	  t->qualifier = Swig_copy_string(td->qualifier);
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

/* -----------------------------------------------------------------------------
 * void LParse_typedef_replace()
 *
 * Checks to see if this datatype is in the typedef hash and
 * replaces it with the hash entry. Only applies to current scope.
 * ----------------------------------------------------------------------------- */

void LParse_typedef_replace(LParseType *t) {
  LParseType  *td;
  DOH       *temp;

  if (!typedef_init) init_typedef();
  temp = NewString("");
  if ((td = (LParseType *) Getattr(typedef_hash[scope],t->name))) {
    t->type = td->type;
    t->is_pointer = td->is_pointer;
    t->implicit_ptr -= td->implicit_ptr;
    strcpy(t->name, td->name);
    if (td->arraystr) {
      if (t->arraystr) {
	Printf(temp,"%s", t->arraystr);
	free(t->arraystr);
      }
      Printf(temp,"%s", td->arraystr);
      t->arraystr = Swig_copy_string(Char(temp));
    }
  }
  Delete(temp);
  /* Not found, do nothing */
  return;
}

/* -----------------------------------------------------------------------------
 * int LParse_typedef_check(DOH *tname)
 *
 * Checks to see whether tname is the name of a datatype we know
 * about.  Returns 1 if there's a match, 0 otherwise
 * ----------------------------------------------------------------------------- */

int LParse_typedef_check(DOH *tname) {
  int s = scope;
  if (!typedef_init) init_typedef();
  while (s >= 0) {
    if (Getattr(typedef_hash[s],tname)) return 1;
    s--;
  }
  return 0;
}

/* -----------------------------------------------------------------------------
 * void LParse_typedef_updatestatus(LParseType *t, int newstatus)
 *
 * Checks to see if this datatype is in the hash table.  If
 * so, we'll update its status.   This is sometimes used with
 * typemap handling.  Only applies to current scope.
 * ----------------------------------------------------------------------------- */
void LParse_typedef_updatestatus(LParseType *t, int newstatus) {
  LParseType *td;
  if (!typedef_init) init_typedef();
  if ((td = (LParseType *) Getattr(typedef_hash[scope], t->name))) {
    td->status = newstatus;
  }
}

/* -----------------------------------------------------------------------------
 * void LParse_merge_scope(DOH *h)
 * 
 * Copies all of the entries in scope h into the current scope.  This is
 * primarily done with C++ inheritance.
 * ----------------------------------------------------------------------------- */

void LParse_merge_scope(DOH *h) {
  DOH *key;
  DOH *nt;

  if (!typedef_init) init_typedef();
  if (h) {
    /* Copy all of the entries in the given hash table to this new one */
    key = Firstkey(h);
    while (key) {
      nt = Copy(Getattr(h,key));
      Setattr(typedef_hash[scope],key,nt);
      key = Nextkey(h);
    }
  }
}

/* -----------------------------------------------------------------------------
 * void LParse_new_scope(DOH *h)
 *
 * Creates a new scope for handling typedefs.   This is used in C++ handling
 * to create typedef local to a class definition. 
 * ----------------------------------------------------------------------------- */

void LParse_new_scope(DOH *h) {
  if (!typedef_init) init_typedef();
  scope++;
  typedef_hash[scope] = NewHash();
  if (h) {
    LParse_merge_scope(h);
  }
}

/* -----------------------------------------------------------------------------
 * DOH *LParse_collapse_scope(DOH *prefix)
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
 * ----------------------------------------------------------------------------- */

DOH *LParse_collapse_scope(DOH *prefix) {
  LParseType *nt;
  DOH *key;
  DOH *temp;
  DOH *h;

  if (!typedef_init) init_typedef();
  if (scope > 0) {
    if (prefix) {
      key = Firstkey(typedef_hash[scope]);
      while (key) {
	nt = (LParseType *) Copy(Getattr(typedef_hash[scope],key));
	temp = NewString("");
	Printf(temp,"%s::%s", prefix,key);
	Setattr(typedef_hash[scope-1],temp,nt);
	key = Nextkey(typedef_hash[scope]);
      }
    }
    h = typedef_hash[scope];
    typedef_hash[scope] = 0;
    scope--;
    return h;
  }
  return 0;
}
