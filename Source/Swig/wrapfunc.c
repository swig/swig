/* ----------------------------------------------------------------------------- 
 * wrapfunc.c
 *
 *     This file defines a object for creating wrapper functions.  Primarily
 *     this is used for convenience since it allows pieces of a wrapper function
 *     to be created in a piecemeal manner.
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
#include <ctype.h>

#include "dohobj.h"

typedef struct {
  Hash      *attr;        /* Attributes */
  Hash      *localh;      /* Hash of local variable names */
  String    *code;        /* Code string */
} WrapObj;

/* -----------------------------------------------------------------------------
 * DelWrapper()
 * ----------------------------------------------------------------------------- */

static void
DelWrapper(DOH *wo) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  Delete(w->localh);
  Delete(w->code);
  Delete(w->attr);
  DohFree(w);
}

/* -----------------------------------------------------------------------------
 * Wrapper_pretty_print()
 *
 * Formats a wrapper function and fixes up the indentation.
 * ----------------------------------------------------------------------------- */

void 
Wrapper_pretty_print(String *str, File *f) {
  String *ts;
  int level = 0;
  int c, i;
  int empty = 1;

  ts = NewString("");
  Seek(str,0, SEEK_SET);
  Clear(ts);
  while ((c = Getc(str)) != EOF) {
    if (c == '\"') {
      Putc(c,ts);
      while ((c = Getc(str)) != EOF) {
	if (c == '\\') {
	  Putc(c,ts);
	  c = Getc(str);
	}
	Putc(c,ts);
	if (c == '\"') break;
      }
    } else if (c == '\'') {
      Putc(c,ts);
      while ((c = Getc(str)) != EOF) {
	if (c == '\\') {
	  Putc(c,ts);
	  c = Getc(str);
	}
	Putc(c,ts);
	if (c == '\'') break;
      }
    } else if (c == '{') {
      Putc(c,ts);
      Putc('\n',ts);
      for (i = 0; i < level; i++) 
	Putc(' ',f);
      Printf(f,"%s", ts);
      Clear(ts);
      level+=4;
      while ((c = Getc(str)) != EOF) {
	if (!isspace(c)) {
	  Ungetc(c,str);
	  break;
	}
      }
    } else if (c == '}') {
      if (!empty) {
	Putc('\n',ts);
	for (i = 0; i < level; i++)
	  Putc(' ',f);
	Printf(f,"%s",ts);
	Clear(ts);
      }
      level-=4;
      Putc(c,ts);
    } else if (c == '\n') {
      Putc(c,ts);
      for (i = 0; i < level; i++)
	Putc(' ',f);
      Printf(f,"%s",ts);
      Clear(ts);
      empty = 1;
    } else {
      if (!empty || !isspace(c)) {
	Putc(c,ts);
	empty = 0;
      }
    }
  }
  if (!empty) Printf(f,"%s",ts);
  Delete(ts);
  Printf(f,"\n");
}


/* -----------------------------------------------------------------------------
 * Wrapper_str()
 *
 * Create a string representation of the wrapper function.
 * ----------------------------------------------------------------------------- */

static String *
Wrapper_str(DOH *wo) {
  String *s, *s1;
  WrapObj *w = (WrapObj *) ObjData(wo);
  s = NewString(w->code);
  s1 = NewString("");
  Replace(s,"$locals", Getattr(w->attr,"locals"), DOH_REPLACE_ANY);
  Wrapper_pretty_print(s,s1);
  Delete(s);
  return s1;
}

/* -----------------------------------------------------------------------------
 * Wrapper_dump()
 * 
 * Serialize on out
 * ----------------------------------------------------------------------------- */

static int
Wrapper_dump(DOH *wo, DOH *out) {
  String *s;
  int len;
  s = Wrapper_str(wo);
  len = Dump(s,out);
  Delete(s);
  return len;
}

/* -----------------------------------------------------------------------------
 * Wrapper_add_local()
 *
 * Adds a new local variable declaration to a function. Returns -1 if already
 * present (which may or may not be okay to the caller).
 * ----------------------------------------------------------------------------- */

int
Wrapper_add_local(Wrapper *wo, const String_or_char *name, const String_or_char *decl) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  /* See if the local has already been declared */
  if (Getattr(w->localh,name)) {
    return -1;
  }
  Setattr(w->localh,name,decl);
  Printf(Getattr(w->attr,"locals"),"%s;\n", decl);
  return 0;
}

/* -----------------------------------------------------------------------------
 * Wrapper_add_localv()
 *
 * Same as add_local(), but allows a NULL terminated list of strings to be
 * used as a replacement for decl.   This saves the caller the trouble of having
 * to manually construct the 'decl' string before calling.
 * ----------------------------------------------------------------------------- */

int
Wrapper_add_localv(Wrapper *wo, const String_or_char *name, ...) {
  va_list ap;
  int     ret;
  String *decl;
  DOH       *obj;
  WrapObj *w = (WrapObj *) ObjData(wo);
  decl = NewString("");
  va_start(ap,name);

  obj = va_arg(ap,void *);
  while (obj) {
    Printv(decl,obj,0);
    Putc(' ', decl);
    obj = va_arg(ap, void *);
  }
  va_end(ap);

  ret = Wrapper_add_local(wo,name,decl);
  Delete(decl);
  return ret;
}

/* -----------------------------------------------------------------------------
 * Wrapper_check_local()
 *
 * Check to see if a local name has already been declared
 * ----------------------------------------------------------------------------- */

int
Wrapper_check_local(Wrapper *wo, const String_or_char *name) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  if (Getattr(w->localh,name)) {
    return 1;
  }
  return 0;
}

/* ----------------------------------------------------------------------------- 
 * Wrapper_new_local()
 *
 * Adds a new local variable with a guarantee that a unique local name will be
 * used.  Returns the name that was actually selected.
 * ----------------------------------------------------------------------------- */

char *
Wrapper_new_local(Wrapper *wo, const String_or_char *name, const String_or_char *decl) {
  int i;
  char      *ret;
  String *nname = NewString(name);
  String *ndecl = NewString(decl);
  WrapObj *w = (WrapObj *) ObjData(wo);
  i = 0;

  while (Wrapper_check_local(w,nname)) {
    Clear(nname);
    Printf(nname,"%s%d",name,i);
    i++;
  }
  Replace(ndecl, name, nname, DOH_REPLACE_ID);
  Setattr(w->localh,nname,ndecl);
  Printf(Getattr(w->attr,"locals"),"%s;\n", ndecl);
  ret = Char(nname);
  Delete(nname);
  Delete(ndecl);
  return ret;      /* Note: nname should still exists in the w->localh hash */
}


/* -----------------------------------------------------------------------------
 * Wrapper_add_localv()
 *
 * Same as add_local(), but allows a NULL terminated list of strings to be
 * used as a replacement for decl.   This saves the caller the trouble of having
 * to manually construct the 'decl' string before calling.
 * ----------------------------------------------------------------------------- */

char *
Wrapper_new_localv(Wrapper *wo, const String_or_char *name, ...) {
  va_list ap;
  char *ret;
  String *decl;
  DOH       *obj;
  WrapObj *w = (WrapObj *) ObjData(wo);
  decl = NewString("");
  va_start(ap,name);

  obj = va_arg(ap,void *);
  while (obj) {
    Printv(decl,obj,0);
    Putc(' ',decl);
    obj = va_arg(ap, void *);
  }
  va_end(ap);

  ret = Wrapper_new_local(wo,name,decl);
  Delete(decl);
  return ret;
}

/* -----------------------------------------------------------------------------
 * Wrapper_Getattr()
 * ----------------------------------------------------------------------------- */

static DOH *
Wrapper_getattr(Wrapper *wo, DOH *k) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Getattr(w->attr,k);
}

/* -----------------------------------------------------------------------------
 * Wrapper_Delattr()
 * ----------------------------------------------------------------------------- */

static int
Wrapper_delattr(Wrapper *wo, DOH *k) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  Delattr(w->attr,k);
  return 0;
}

/* -----------------------------------------------------------------------------
 * Wrapper_Setattr()
 * ----------------------------------------------------------------------------- */

static int
Wrapper_setattr(Wrapper *wo, DOH *k, DOH *obj) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Setattr(w->attr,k,obj);
}

/* -----------------------------------------------------------------------------
 * Wrapper_firstkey()
 * ----------------------------------------------------------------------------- */

static DOH *
Wrapper_firstkey(Wrapper *wo) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Firstkey(w->attr);
}

/* -----------------------------------------------------------------------------
 * Wrapper_firstkey()
 * ----------------------------------------------------------------------------- */

static DOH *
Wrapper_nextkey(Wrapper *wo) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Nextkey(w->attr);
}

/* File methods.   These simply operate on the code string */

static int
Wrapper_read(Wrapper *wo, void *buffer, int nbytes) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Read(w->code,buffer,nbytes);
}

static int
Wrapper_write(Wrapper *wo, void *buffer, int nbytes) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Write(w->code,buffer,nbytes);
}

static int
Wrapper_putc(Wrapper *wo, int ch) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Putc(ch, w->code);
}

static int
Wrapper_getc(Wrapper *wo) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Getc(w->code);
}

static int
Wrapper_ungetc(Wrapper *wo, int ch) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Ungetc(ch, w->code);
}

static int
Wrapper_seek(Wrapper *wo, long offset, int whence) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Seek(w->code, offset, whence);
}

static long
Wrapper_tell(Wrapper *wo) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Tell(w->code);
}

/* String method */

static int Wrapper_replace(DOH *wo, DOH *tok, DOH *rep, int flags) {
  WrapObj *w = (WrapObj *) ObjData(wo);
  return Replace(w->code, tok, rep, flags);
}

/* -----------------------------------------------------------------------------
 * type information
 * ----------------------------------------------------------------------------- */

static DohHashMethods WrapperHashMethods = {
  Wrapper_getattr,
  Wrapper_setattr,
  Wrapper_delattr,
  Wrapper_firstkey,
  Wrapper_nextkey,
};

static DohFileMethods WrapperFileMethods = {
  Wrapper_read, 
  Wrapper_write,
  Wrapper_putc,
  Wrapper_getc,
  Wrapper_ungetc,
  Wrapper_seek,
  Wrapper_tell,
  0,              /* close */
};

static DohStringMethods WrapperStringMethods = {
  Wrapper_replace,
  0,
};

static DohObjInfo WrapperType = {
    "Wrapper",          /* objname */
    DelWrapper,         /* doh_del */
    0,                  /* doh_copy */
    0,                  /* doh_clear */
    Wrapper_str,        /* doh_str */
    0,                  /* doh_data */
    0,                  /* doh_dump */
    0,                  /* doh_len */
    0,                  /* doh_hash    */
    0,                  /* doh_cmp */
    0,                  /* doh_setfile */
    0,                  /* doh_getfile */
    0,                  /* doh_setline */
    0,                  /* doh_getline */
    &WrapperHashMethods, /* doh_mapping */
    0,                   /* doh_sequence */
    &WrapperFileMethods, /* doh_file */
    &WrapperStringMethods, /* doh_string */
    0,                /* doh_positional */
    0,
};

/* -----------------------------------------------------------------------------
 * NewWrapper()
 *
 * Create a new wrapper function object.
 * ----------------------------------------------------------------------------- */

#define DOHTYPE_WRAPPER   0xa

Wrapper *
NewWrapper() {
  WrapObj *w;
  static int init = 0;
  if (!init) {
    DohRegisterType(DOHTYPE_WRAPPER, &WrapperType);
    init = 1;
  }
  w = (WrapObj *) DohMalloc(sizeof(WrapObj));
  w->localh = NewHash();
  w->code = NewString("");
  w->attr= NewHash();
  Setattr(w->attr,"locals","");
  Setattr(w->attr,"wrapcode", w->code);
  return DohObjMalloc(DOHTYPE_WRAPPER, w);
}



