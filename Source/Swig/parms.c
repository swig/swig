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

/* ------------------------------------------------------------------------
 * NewParm()
 *
 * Create a new parameter from datatype 'type' and name 'name' copying
 * the file and line number from the Node file_line_node.
 * ------------------------------------------------------------------------ */

Parm *NewParm(SwigType *type, const_String_or_char_ptr name, Node *file_line_node) {
  Parm *p = NewParmWithoutFileLineInfo(type, name);
  Setfile(p, Getfile(file_line_node));
  Setline(p, Getline(file_line_node));
  return p;
}

/* ------------------------------------------------------------------------
 * NewParmWithoutFileLineInfo()
 *
 * Create a new parameter from datatype 'type' and name 'name' without any
 * file / line numbering information.
 * ------------------------------------------------------------------------ */

Parm *NewParmWithoutFileLineInfo(SwigType *type, const_String_or_char_ptr name) {
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
 * CopyParm()
 * ------------------------------------------------------------------------ */

Parm *CopyParm(Parm *p) {
  Parm *np = NewHash();
  Iterator ki;
  for (ki = First(p); ki.key; ki = Next(ki)) {
    if (DohIsString(ki.item)) {
      DOH *c = Copy(ki.item);
      Setattr(np,ki.key,c);
      Delete(c);
    }
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
 * get_empty_type()
 * ---------------------------------------------------------------------- */

static SwigType *get_empty_type() {
  return NewStringEmpty();
}

/* ---------------------------------------------------------------------
 * ParmList_str()
 *
 * Generates a string of parameters
 * ---------------------------------------------------------------------- */

String *ParmList_str(ParmList *p) {
  String *out = NewStringEmpty();
  while (p) {
    String *type = Getattr(p, "type");
    String *pstr = SwigType_str(type ? type : get_empty_type(), Getattr(p, "name"));
    Append(out, pstr);
    p = nextSibling(p);
    if (p) {
      Append(out, ",");
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
    String *type = Getattr(p, "type");
    String *pstr = SwigType_str(type ? type : get_empty_type(), Getattr(p, "name"));
    Append(out, pstr);
    if (value) {
      Printf(out, "=%s", value);
    }
    p = nextSibling(p);
    if (p) {
      Append(out, ",");
    }
    Delete(pstr);
  }
  return out;
}

/* -----------------------------------------------------------------------------
 * ParmList_str_multibrackets()
 *
 * Generates a string of parameters including default arguments adding brackets
 * if more than one parameter
 * ----------------------------------------------------------------------------- */

String *ParmList_str_multibrackets(ParmList *p) {
  String *out;
  String *parm_str = ParmList_str_defaultargs(p);
  if (ParmList_len(p) > 1)
    out = NewStringf("(%s)", parm_str);
  else
    out = NewStringf("%s", parm_str);
  Delete(parm_str);
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
    String *type = Getattr(p, "type");
    String *pstr = SwigType_str(type ? type : get_empty_type(), 0);
    Append(out, pstr);
    p = nextSibling(p);
    if (p) {
      Append(out, ",");
    }
    Delete(pstr);
  }
  return out;
}

/* ---------------------------------------------------------------------
 * ParmList_has_defaultargs()
 *
 * Returns 1 if the parameter list passed in is has one or more default
 * arguments. Otherwise returns 0.
 * ---------------------------------------------------------------------- */

int ParmList_has_defaultargs(ParmList *p) {
  while (p) {
    if (Getattr(p, "value")) {
      return 1;
    }
    p = nextSibling(p);
  }
  return 0;
}
