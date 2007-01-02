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
    Setattr(p, "type", ntype);
    Delete(ntype);
  }
  Setattr(p, "name", name);
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
  SwigType *t = Getattr(p, "type");
  String *name = Getattr(p, "name");
  String *lname = Getattr(p, "lname");
  String *value = Getattr(p, "value");
  String *ignore = Getattr(p, "ignore");
  String *alttype = Getattr(p, "alttype");
  String *byname = Getattr(p, "arg:byname");
  String *compactdefargs = Getattr(p, "compactdefargs");
  String *self = Getattr(p, "self");

  if (t) {
    SwigType *nt = Copy(t);
    Setattr(np, "type", nt);
    Delete(nt);
  }
  if (name) {
    String *str = Copy(name);
    Setattr(np, "name", str);
    Delete(str);
  }
  if (lname) {
    String *str = Copy(lname);
    Setattr(np, "lname", str);
    Delete(str);
  }
  if (value) {
    String *str = Copy(value);
    Setattr(np, "value", str);
    Delete(str);
  }
  if (ignore) {
    String *str = Copy(ignore);
    Setattr(np, "ignore", str);
    Delete(str);
  }
  if (alttype) {
    String *str = Copy(alttype);
    Setattr(np, "alttype", str);
    Delete(str);
  }
  if (byname) {
    String *str = Copy(byname);
    Setattr(np, "arg:byname", str);
    Delete(str);
  }
  if (compactdefargs) {
    String *str = Copy(compactdefargs);
    Setattr(np, "compactdefargs", str);
    Delete(str);
  }
  if (self) {
    String *str = Copy(self);
    Setattr(np, "self", str);
    Delete(str);
  }

  Setfile(np, Getfile(p));
  Setline(np, Getline(p));

  return np;
}

/* ------------------------------------------------------------------
 * CopyParmListMax()
 * CopyParmList()
 * ------------------------------------------------------------------ */

ParmList *CopyParmListMax(ParmList *p, int count) {
  Parm *np;
  Parm *pp = 0;
  Parm *fp = 0;

  if (!p)
    return 0;

  while (p) {
    if (count == 0) break;
    np = CopyParm(p);
    if (pp) {
      set_nextSibling(pp, np);
      Delete(np);
    } else {
      fp = np;
    }
    pp = np;
    p = nextSibling(p);
    count--;
  }
  return fp;
}

ParmList *CopyParmList(ParmList *p) {
  return CopyParmListMax(p,-1);
}

/* ------------------------------------------------------------------
 * int ParmList_numarg()
 * ------------------------------------------------------------------ */

int ParmList_numarg(ParmList *p) {
  int n = 0;
  while (p) {
    if (!Getattr(p, "ignore"))
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
    SwigType *t = Getattr(p, "type");
    String *value = Getattr(p, "value");
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
    String *pstr = SwigType_str(Getattr(p, "type"), Getattr(p, "name"));
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
    String *value = Getattr(p, "value");
    String *pstr = SwigType_str(Getattr(p, "type"), Getattr(p, "name"));
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
    if (Getattr(p, "hidden")) {
      p = nextSibling(p);
    } else {
      String *pstr = SwigType_str(Getattr(p, "type"), 0);
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
    compactdefargs = Getattr(p, "compactdefargs") ? 1 : 0;

    /* The "compactdefargs" attribute should only be set on the first parameter in the list.
     * However, sometimes an extra parameter is inserted at the beginning of the parameter list,
     * so we check the 2nd parameter too. */
    if (!compactdefargs) {
      Parm *nextparm = nextSibling(p);
      compactdefargs = (nextparm && Getattr(nextparm, "compactdefargs")) ? 1 : 0;
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
    if (Getattr(p, "value")) {
      default_args = 1;
      break;
    }
    p = nextSibling(p);
  }
  return default_args;
}
