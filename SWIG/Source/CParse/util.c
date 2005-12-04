/* ----------------------------------------------------------------------------- 
 * util.c
 *
 *     Parsing utilities
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_util_c[] = "$Header$";

#include "swig.h"
#include "cparse.h"

/* -----------------------------------------------------------------------------
 * Swig_cparse_replace_descriptor()
 *
 * Replaces type descriptor string $descriptor() with the SWIG type descriptor
 * string.
 * ----------------------------------------------------------------------------- */

void Swig_cparse_replace_descriptor(String *s) {
  char   tmp[512];
  String *arg = 0;
  SwigType *t;
  char *c = 0;

  while ((c = strstr(Char(s),"$descriptor("))) {
    char *d = tmp;
    int  level = 0;
    while (*c) {
      if (*c == '(') level++;
      if (*c == ')') {
	level--;
	if (level == 0) {
	  break;
	}
      }
      *d = *c;
      d++;
      c++;
    }
    *d = 0;
    arg = NewString(tmp+12);
    t = Swig_cparse_type(arg);
    Delete(arg);
    arg = 0;

    if (t) {
      String *mangle;
      String *descriptor;
      
      mangle = SwigType_manglestr(t);
      descriptor = NewStringf("SWIGTYPE%s",mangle);
      SwigType_remember(t);
      *d = ')';
      d++;
      *d = 0;
      Replace(s,tmp,descriptor,DOH_REPLACE_ANY);
      Delete(mangle);
      Delete(descriptor);
      Delete(t);
    } else {
      Swig_error(Getfile(s),Getline(s),"Bad $descriptor() macro.\n");
      break;
    }
  }
}

/* -----------------------------------------------------------------------------
 * cparse_normalize_void()
 *
 * This function is used to replace arguments of the form (void) with empty
 * arguments in C++
 * ----------------------------------------------------------------------------- */

void cparse_normalize_void(Node *n) {
  String *decl = Getattr(n,"decl");
  Parm   *parms = Getattr(n,"parms");

  if (SwigType_isfunction(decl)) {
    if ((ParmList_len(parms) == 1) && (SwigType_type(Getattr(parms,"type")) == T_VOID)) {
      Replaceall(decl,"f(void).","f().");
      Delattr(n,"parms");
    }
  }
}

/* -----------------------------------------------------------------------------
 * int need_protected(Node* n, int dirprot_mode)
 *
 * Detects when we need to fully register the protected member.
 * 
 * ----------------------------------------------------------------------------- */

int need_protected(Node* n, int dirprot_mode)
{
  /* First, 'n' looks like a function */
  if (!dirprot_mode && !Swig_director_mode()) return 0;
  if ((Strcmp(nodeType(n),"cdecl") == 0) &&
      SwigType_isfunction(Getattr(n,"decl"))) {
    String *storage = Getattr(n,"storage");
    /* and the function is declared like virtual, or it has no
       storage. This eliminates typedef, static and so on. */ 
    return (!storage || (Strcmp(storage,"virtual") == 0));
  } else if ((Strcmp(nodeType(n),"constructor") == 0)) {
    return 1;
  }

  return 0;
}

/* -----------------------------------------------------------------------------
 * int need_name_warning(Node *n)
 *
 * Detects if a node needs name warnings 
 *
 * ----------------------------------------------------------------------------- */

int need_name_warning(Node *n)
{
  int need = 1;
  /* 
     we don't use name warnings for:
     - class forwards, no symbol is generated at the target language.
     - template declarations, only for real instances using %template(name).
     - typedefs, they have no effect at the target language.
  */
  if (Strcmp(nodeType(n),"classforward") == 0) {
    need = 0;
  } else if (Getattr(n,"templatetype")) {
    need = 0;
  } else {
    String *storage = Getattr(n,"storage");
    if (storage && (Strcmp(storage,"typedef") == 0)) {
      need = 0;
    }
  }
  return need;
}
    

int are_equivalent_nodes(Node* a, Node* b, int a_inclass)
{
  /* they must have the same type */
  SwigType *ta = nodeType(a);
  SwigType *tb = nodeType(b);  
  if (Cmp(ta, tb) != 0) return 0;
  
  /* cdecl case */
  if (Cmp(ta, "cdecl") == 0) {
    /* typedef */
    String *a_storage = Getattr(a,"storage");
    String *b_storage = Getattr(b,"storage");

    if ((Cmp(a_storage,"typedef") == 0)
	|| (Cmp(b_storage,"typedef") == 0)) {	
      if (Cmp(a_storage, b_storage) == 0) {
	String *a_type = (Getattr(a,"type"));
	String *b_type = (Getattr(b,"type"));
	if (Cmp(a_type, b_type) == 0) return 1;
      }
      return 0;
    }

    /* static functions */
    if ((Cmp(a_storage, "static") == 0) 
	|| (Cmp(b_storage, "static") == 0)) {
      if (Cmp(a_storage, b_storage) != 0) return 0;
    }

    /* friend methods */
    
    if (!a_inclass || (Cmp(a_storage,"friend") == 0)) {
      /* check declaration */

      String *a_decl = (Getattr(a,"decl"));
      String *b_decl = (Getattr(b,"decl"));
      if (Cmp(a_decl, b_decl) == 0) {
	/* check return type */
	String *a_type = (Getattr(a,"type"));
	String *b_type = (Getattr(b,"type"));
	if (Cmp(a_type, b_type) == 0) {
	  /* check parameters */
	  Parm *ap = (Getattr(a,"parms"));
	  Parm *bp = (Getattr(b,"parms"));
	  while (ap && bp) {
	    SwigType *at = Getattr(ap,"type");
	    SwigType *bt = Getattr(bp,"type");
	    if (Cmp(at, bt) != 0) return 0;
	    ap = nextSibling(ap);
	    bp = nextSibling(bp);
	  }
	  if (ap || bp) {
	    return 0;
	  } else {
            Node *a_template = Getattr(a,"template");
            Node *b_template = Getattr(b,"template");
            /* Not equivalent if one is a template instantiation (via %template) and the other is a non-templated function */
            if ((a_template && !b_template) || (!a_template && b_template)) return 0;
          }
	  return 1;
	}
      }
    }
  } else {
    /* %constant case */  
    String *a_storage = Getattr(a,"storage");
    String *b_storage = Getattr(b,"storage");
    if ((Cmp(a_storage, "%constant") == 0) 
	|| (Cmp(b_storage, "%constant") == 0)) {
      if (Cmp(a_storage, b_storage) == 0) {
	String *a_type = (Getattr(a,"type"));
	String *b_type = (Getattr(b,"type"));
	if ((Cmp(a_type, b_type) == 0)
	    && (Cmp(Getattr(a,"value"), Getattr(b,"value")) == 0))
	  return 1;
      }
      return 0;
    }
  }
  return 0;
}

int need_redefined_warn(Node* a, Node* b, int InClass)
{
  String *a_symname = Getattr(a,"sym:name");
  String *b_symname = Getattr(b,"sym:name");
  /* always send a warning if a 'rename' is involved */
  if ((a_symname && Cmp(a_symname,Getattr(a,"name")))
      || (b_symname && Cmp(b_symname,Getattr(b,"name"))))
    return 1;

  return !are_equivalent_nodes(a, b, InClass);
}
