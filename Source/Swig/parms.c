/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * parms.c
 *
 * Parameter list class.
 * ----------------------------------------------------------------------------- */

char cvsroot_parms_c[] = "$Id$";

#include "swig.h"
#include "swigkeys.h"

/* ------------------------------------------------------------------------
 * NewParm()
 *
 * Create a new parameter from datatype 'type' and name 'name'.
 * ------------------------------------------------------------------------ */

Parm *NewParm(SwigType *type, const String_or_char *name) {
  Parm *p = NewHash();
  set_nodeType(p, "parm");
  if (type) {
    SwigType *ntype = Copy(type);
    Setattr(p, k_type, ntype);
    Delete(ntype);
  }
  Setattr(p, k_name, name);
  return p;
}

/* ------------------------------------------------------------------------
 * NewParmFromNode()
 *
 * Create a new parameter from datatype 'type' and name 'name'.
 * Sets the file and line number for the parameter for error handling by
 * making a (shallow) copy of file and line number from Node 'n'.
 * ------------------------------------------------------------------------ */

Parm *NewParmFromNode(SwigType *type, const String_or_char *name, Node *n) {
  Parm *p = NewParm(type, name);
  Setfile(p, Getfile(n));
  Setline(p, Getline(n));

  return p;
}

/* ------------------------------------------------------------------------
 * CopyParm()
 * ------------------------------------------------------------------------ */

Parm *CopyParm(Parm *p) {
  Parm *np = NewHash();
  SwigType *t = Getattr(p, k_type);
  String *name = Getattr(p, k_name);
  String *lname = Getattr(p, k_lname);
  String *value = Getattr(p, k_value);
  String *ignore = Getattr(p, k_ignore);
  String *alttype = Getattr(p, k_alttype);
  String *byname = Getattr(p, k_argbyname);
  String *compactdefargs = Getattr(p, k_compactdefargs);
  String *self = Getattr(p, k_self);

  if (t) {
    SwigType *nt = Copy(t);
    Setattr(np, k_type, nt);
    Delete(nt);
  }
  if (name) {
    String *str = Copy(name);
    Setattr(np, k_name, str);
    Delete(str);
  }
  if (lname) {
    String *str = Copy(lname);
    Setattr(np, k_lname, str);
    Delete(str);
  }
  if (value) {
    String *str = Copy(value);
    Setattr(np, k_value, str);
    Delete(str);
  }
  if (ignore) {
    String *str = Copy(ignore);
    Setattr(np, k_ignore, str);
    Delete(str);
  }
  if (alttype) {
    String *str = Copy(alttype);
    Setattr(np, k_alttype, str);
    Delete(str);
  }
  if (byname) {
    String *str = Copy(byname);
    Setattr(np, k_argbyname, str);
    Delete(str);
  }
  if (compactdefargs) {
    String *str = Copy(compactdefargs);
    Setattr(np, k_compactdefargs, str);
    Delete(str);
  }
  if (self) {
    String *str = Copy(self);
    Setattr(np, k_self, str);
    Delete(str);
  }

  Setfile(np, Getfile(p));
  Setline(np, Getline(p));

  return np;
}

/* ------------------------------------------------------------------
 * CopyParmList()
 * ------------------------------------------------------------------ */

ParmList *CopyParmList(ParmList *p) {
  Parm *np;
  Parm *pp = 0;
  Parm *fp = 0;

  if (!p)
    return 0;

  while (p) {
    np = CopyParm(p);
    if (pp) {
      set_nextSibling(pp, np);
      Delete(np);
    } else {
      fp = np;
    }
    pp = np;
    p = nextSibling(p);
  }
  return fp;
}

/* ------------------------------------------------------------------
 * int ParmList_numarg()
 * ------------------------------------------------------------------ */

int ParmList_numarg(ParmList *p) {
  int n = 0;
  while (p) {
    if (!Getattr(p, k_ignore))
      n++;
    p = nextSibling(p);
  }
  return n;
}

/* -----------------------------------------------------------------------------
 * int ParmList_numrequired().  Return number of required arguments
 * ----------------------------------------------------------------------------- */

int ParmList_numrequired(ParmList *p) {
  int i = 0;
  while (p) {
    SwigType *t = Getattr(p, k_type);
    String *value = Getattr(p, k_value);
    if (value)
      return i;
    if (!(SwigType_type(t) == T_VOID))
      i++;
    else
      break;
    p = nextSibling(p);
  }
  return i;
}

/* -----------------------------------------------------------------------------
 * int ParmList_len()
 * ----------------------------------------------------------------------------- */

int ParmList_len(ParmList *p) {
  int i = 0;
  while (p) {
    i++;
    p = nextSibling(p);
  }
  return i;
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generates a string of parameters
 * ---------------------------------------------------------------------- */

String *ParmList_str(ParmList *p) {
  String *out = NewStringEmpty();
  while (p) {
    String *pstr = SwigType_str(Getattr(p, k_type), Getattr(p, k_name));
    StringAppend(out, pstr);
    p = nextSibling(p);
    if (p) {
      StringAppend(out, ",");
    }
    Delete(pstr);
  }
  return out;
}

/* ---------------------------------------------------------------------
 * ParmList_str_defaultargs()
 *
 * Generates a string of parameters including default arguments
 * ---------------------------------------------------------------------- */

String *ParmList_str_defaultargs(ParmList *p) {
  String *out = NewStringEmpty();
  while (p) {
    String *value = Getattr(p, k_value);
    String *pstr = SwigType_str(Getattr(p, k_type), Getattr(p, k_name));
    StringAppend(out, pstr);
    if (value) {
      Printf(out, "=%s", value);
    }
    p = nextSibling(p);
    if (p) {
      StringAppend(out, ",");
    }
    Delete(pstr);
  }
  return out;
}

/* ---------------------------------------------------------------------
 * ParmList_protostr()
 *
 * Generate a prototype string.
 * ---------------------------------------------------------------------- */

String *ParmList_protostr(ParmList *p) {
  String *out = NewStringEmpty();
  while (p) {
    if (Getattr(p, k_hidden)) {
      p = nextSibling(p);
    } else {
      String *pstr = SwigType_str(Getattr(p, k_type), 0);
      StringAppend(out, pstr);
      p = nextSibling(p);
      if (p) {
	StringAppend(out, ",");
      }
      Delete(pstr);
    }
  }
  return out;
}

/* ---------------------------------------------------------------------
 * ParmList_is_compactdefargs()
 *
 * Returns 1 if the parameter list passed in is marked for compact argument
 * handling (by the "compactdefargs" attribute). Otherwise returns 0.
 * ---------------------------------------------------------------------- */

int ParmList_is_compactdefargs(ParmList *p) {
  int compactdefargs = 0;

  if (p) {
    compactdefargs = Getattr(p, k_compactdefargs) ? 1 : 0;

    /* The "compactdefargs" attribute should only be set on the first parameter in the list.
     * However, sometimes an extra parameter is inserted at the beginning of the parameter list,
     * so we check the 2nd parameter too. */
    if (!compactdefargs) {
      Parm *nextparm = nextSibling(p);
      compactdefargs = (nextparm && Getattr(nextparm, k_compactdefargs)) ? 1 : 0;
    }
  }

  return compactdefargs;
}


/* ---------------------------------------------------------------------
 * ParmList_has_defaultargs()
 *
 * Returns 1 if the parameter list passed in is has one or more default
 * arguments. Otherwise returns 0.
 * ---------------------------------------------------------------------- */

int ParmList_has_defaultargs(ParmList *p) {
  int default_args = 0;
  while (p) {
    if (Getattr(p, k_value)) {
      default_args = 1;
      break;
    }
    p = nextSibling(p);
  }
  return default_args;
}

/* ---------------------------------------------------------------------
 * ParmList_copy_all_except_last_parm()
 *
 * Create a new parameter list by copying all the parameters barring the
 * last parameter.
 * ---------------------------------------------------------------------- */

ParmList *ParmList_copy_all_except_last_parm(ParmList *p) {
  ParmList *newparms = 0;
  Parm *newparm = 0;
  Parm *pp = 0;
  Parm *fp = 0;
  while (nextSibling(p)) {
    newparm = CopyParm(p);
    if (pp) {
      set_nextSibling(pp, newparm);
      Delete(newparm);
    } else {
      fp = newparm;
    }
    pp = newparm;
    p = nextSibling(p);
  }
  newparms = fp;
  return newparms;
}
