/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * templ.c
 *
 * Expands a template into a specialized version.   
 * ----------------------------------------------------------------------------- */

char cvsroot_templ_c[] = "$Id$";

#include "swig.h"
#include "cparse.h"

static int template_debug = 0;


const char *baselists[3];

void SwigType_template_init() {
  baselists[0] = "baselist";
  baselists[1] = "protectedbaselist";
  baselists[2] = "privatebaselist";
}


static void add_parms(ParmList *p, List *patchlist, List *typelist) {
  while (p) {
    SwigType *ty = Getattr(p, "type");
    SwigType *val = Getattr(p, "value");
    Append(typelist, ty);
    Append(typelist, val);
    Append(patchlist, val);
    p = nextSibling(p);
  }
}

void Swig_cparse_debug_templates(int x) {
  template_debug = x;
}

/* -----------------------------------------------------------------------------
 * cparse_template_expand()
 *
 * Expands a template node into a specialized version.  This is done by
 * patching typenames and other aspects of the node according to a list of
 * template parameters
 * ----------------------------------------------------------------------------- */

static int cparse_template_expand(Node *n, String *tname, String *rname, String *templateargs, List *patchlist, List *typelist, List *cpatchlist) {
  static int expanded = 0;
  int ret;
  String *nodeType;
  if (!n)
    return 0;
  nodeType = nodeType(n);
  if (Getattr(n, "error"))
    return 0;

  if (Equal(nodeType, "template")) {
    /* Change the node type back to normal */
    if (!expanded) {
      expanded = 1;
      set_nodeType(n, Getattr(n, "templatetype"));
      ret = cparse_template_expand(n, tname, rname, templateargs, patchlist, typelist, cpatchlist);
      expanded = 0;
      return ret;
    } else {
      /* Called when template appears inside another template */
      /* Member templates */

      set_nodeType(n, Getattr(n, "templatetype"));
      ret = cparse_template_expand(n, tname, rname, templateargs, patchlist, typelist, cpatchlist);
      set_nodeType(n, "template");
      return ret;
    }
  } else if (Equal(nodeType, "cdecl")) {
    /* A simple C declaration */
    SwigType *t, *v, *d;
    String *code;
    t = Getattr(n, "type");
    v = Getattr(n, "value");
    d = Getattr(n, "decl");

    code = Getattr(n, "code");

    Append(typelist, t);
    Append(typelist, d);
    Append(patchlist, v);
    Append(cpatchlist, code);

    if (Getattr(n, "conversion_operator")) {
      Append(cpatchlist, Getattr(n, "name"));
      if (Getattr(n, "sym:name")) {
	Append(cpatchlist, Getattr(n, "sym:name"));
      }
    }

    add_parms(Getattr(n, "parms"), cpatchlist, typelist);
    add_parms(Getattr(n, "throws"), cpatchlist, typelist);

  } else if (Equal(nodeType, "class")) {
    /* Patch base classes */
    {
      int b = 0;
      for (b = 0; b < 3; ++b) {
	List *bases = Getattr(n, baselists[b]);
	if (bases) {
	  int i;
	  int ilen = Len(bases);
	  for (i = 0; i < ilen; i++) {
	    String *name = Copy(Getitem(bases, i));
	    Setitem(bases, i, name);
	    Append(typelist, name);
	  }
	}
      }
    }
    /* Patch children */
    {
      Node *cn = firstChild(n);
      while (cn) {
	cparse_template_expand(cn, tname, rname, templateargs, patchlist, typelist, cpatchlist);
	cn = nextSibling(cn);
      }
    }
  } else if (Equal(nodeType, "constructor")) {
    String *name = Getattr(n, "name");
    if (!(Getattr(n, "templatetype"))) {
      String *symname;
      String *stripped_name = SwigType_templateprefix(name);
      if (Strstr(tname, stripped_name)) {
	Replaceid(name, stripped_name, tname);
      }
      Delete(stripped_name);
      symname = Getattr(n, "sym:name");
      if (symname) {
	stripped_name = SwigType_templateprefix(symname);
	if (Strstr(tname, stripped_name)) {
	  Replaceid(symname, stripped_name, tname);
	}
	Delete(stripped_name);
      }
      if (strchr(Char(name), '<')) {
	Append(patchlist, Getattr(n, "name"));
      } else {
	Append(name, templateargs);
      }
      name = Getattr(n, "sym:name");
      if (name) {
	if (strchr(Char(name), '<')) {
	  Clear(name);
	  Append(name, rname);
	} else {
	  String *tmp = Copy(name);
	  Replace(tmp, tname, rname, DOH_REPLACE_ANY);
	  Clear(name);
	  Append(name, tmp);
	  Delete(tmp);
	}
      }
      /* Setattr(n,"sym:name",name); */
    }
    Append(cpatchlist, Getattr(n, "code"));
    Append(typelist, Getattr(n, "decl"));
    add_parms(Getattr(n, "parms"), cpatchlist, typelist);
    add_parms(Getattr(n, "throws"), cpatchlist, typelist);
  } else if (Equal(nodeType, "destructor")) {
    String *name = Getattr(n, "name");
    if (name) {
      if (strchr(Char(name), '<'))
        Append(patchlist, Getattr(n, "name"));
      else
        Append(name, templateargs);
    }
    name = Getattr(n, "sym:name");
    if (name) {
      if (strchr(Char(name), '<')) {
        String *sn = Copy(tname);
        Setattr(n, "sym:name", sn);
        Delete(sn);
      } else {
        Replace(name, tname, rname, DOH_REPLACE_ANY);
      }
    }
    /* Setattr(n,"sym:name",name); */
    Append(cpatchlist, Getattr(n, "code"));
  } else if (Equal(nodeType, "using")) {
    String *uname = Getattr(n, "uname");
    if (uname && strchr(Char(uname), '<')) {
      Append(patchlist, uname);
    }
    if (Getattr(n, "namespace")) {
      /* Namespace link.   This is nasty.  Is other namespace defined? */

    }
  } else {
    /* Look for obvious parameters */
    Node *cn;
    Append(cpatchlist, Getattr(n, "code"));
    Append(typelist, Getattr(n, "type"));
    Append(typelist, Getattr(n, "decl"));
    add_parms(Getattr(n, "parms"), cpatchlist, typelist);
    add_parms(Getattr(n, "kwargs"), cpatchlist, typelist);
    add_parms(Getattr(n, "pattern"), cpatchlist, typelist);
    add_parms(Getattr(n, "throws"), cpatchlist, typelist);
    cn = firstChild(n);
    while (cn) {
      cparse_template_expand(cn, tname, rname, templateargs, patchlist, typelist, cpatchlist);
      cn = nextSibling(cn);
    }
  }
  return 0;
}

static
String *partial_arg(String *s, String *p) {
  char *c;
  char *cp = Char(p);
  String *prefix;
  String *newarg;

  /* Find the prefix on the partial argument */

  c = strchr(cp, '$');
  if (!c) {
    return Copy(s);
  }
  prefix = NewStringWithSize(cp, c - cp);
  newarg = Copy(s);
  Replace(newarg, prefix, "", DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
  Delete(prefix);
  return newarg;
}

/* -----------------------------------------------------------------------------
 * Swig_cparse_template_expand()
 * ----------------------------------------------------------------------------- */

int Swig_cparse_template_expand(Node *n, String *rname, ParmList *tparms, Symtab *tscope) {
  List *patchlist, *cpatchlist, *typelist;
  String *templateargs;
  String *tname;
  String *iname;
  String *tbase;
  patchlist = NewList();
  cpatchlist = NewList();
  typelist = NewList();

  {
    String *tmp = NewStringEmpty();
    if (tparms) {
      SwigType_add_template(tmp, tparms);
    }
    templateargs = Copy(tmp);
    Delete(tmp);
  }

  tname = Copy(Getattr(n, "name"));
  tbase = Swig_scopename_last(tname);

  /* Look for partial specialization matching */
  if (Getattr(n, "partialargs")) {
    Parm *p, *tp;
    ParmList *ptargs = SwigType_function_parms(Getattr(n, "partialargs"));
    p = ptargs;
    tp = tparms;
    while (p && tp) {
      SwigType *ptype;
      SwigType *tptype;
      SwigType *partial_type;
      ptype = Getattr(p, "type");
      tptype = Getattr(tp, "type");
      if (ptype && tptype) {
	partial_type = partial_arg(tptype, ptype);
	/*      Printf(stdout,"partial '%s' '%s'  ---> '%s'\n", tptype, ptype, partial_type); */
	Setattr(tp, "type", partial_type);
	Delete(partial_type);
      }
      p = nextSibling(p);
      tp = nextSibling(tp);
    }
    assert(ParmList_len(ptargs) == ParmList_len(tparms));
    Delete(ptargs);
  }

  /*
    Parm *p = tparms;
    while (p) {
      Printf(stdout, "tparm: '%s' '%s' '%s'\n", Getattr(p, "name"), Getattr(p, "type"), Getattr(p, "value"));
      p = nextSibling(p);
    }
  */

  /*  Printf(stdout,"targs = '%s'\n", templateargs);
     Printf(stdout,"rname = '%s'\n", rname);
     Printf(stdout,"tname = '%s'\n", tname);  */
  cparse_template_expand(n, tname, rname, templateargs, patchlist, typelist, cpatchlist);

  /* Set the name */
  {
    String *name = Getattr(n, "name");
    if (name) {
      Append(name, templateargs);
    }
    iname = name;
  }

  /* Patch all of the types */
  {
    Parm *tp = Getattr(n, "templateparms");
    Parm *p = tparms;
    /*    Printf(stdout,"%s\n", ParmList_str_defaultargs(tp)); */

    if (tp) {
      Symtab *tsdecl = Getattr(n, "sym:symtab");
      while (p && tp) {
	String *name, *value, *valuestr, *tydef, *tmp, *tmpr;
	int sz, i;
	String *dvalue = 0;
	String *qvalue = 0;

	name = Getattr(tp, "name");
	value = Getattr(p, "value");
	tydef = Getattr(p, "typedef");

	if (name) {
	  if (!value)
	    value = Getattr(p, "type");
	  qvalue = Swig_symbol_typedef_reduce(value, tsdecl);
	  dvalue = Swig_symbol_type_qualify(qvalue, tsdecl);
	  if (SwigType_istemplate(dvalue)) {
	    String *ty = Swig_symbol_template_deftype(dvalue, tscope);
	    Delete(dvalue);
	    dvalue = ty;
	  }

	  assert(dvalue);
	  valuestr = SwigType_str(dvalue, 0);
	  /* Need to patch default arguments */
	  {
	    Parm *rp = nextSibling(p);
	    while (rp) {
	      String *rvalue = Getattr(rp, "value");
	      if (rvalue) {
		Replace(rvalue, name, dvalue, DOH_REPLACE_ID);
	      }
	      rp = nextSibling(rp);
	    }
	  }
	  sz = Len(patchlist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(patchlist, i);
	    Replace(s, name, dvalue, DOH_REPLACE_ID);
	  }
	  sz = Len(typelist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(typelist, i);
	    /*      Replace(s,name,value, DOH_REPLACE_ID); */
	    /*      Printf(stdout,"name = '%s', value = '%s', tbase = '%s', iname='%s' s = '%s' --> ", name, dvalue, tbase, iname, s); */
	    SwigType_typename_replace(s, name, dvalue);
	    SwigType_typename_replace(s, tbase, iname);
	    /*      Printf(stdout,"'%s'\n", s); */
	  }

	  if (!tydef) {
	    tydef = dvalue;
	  }
	  tmp = NewStringf("#%s", name);
	  tmpr = NewStringf("\"%s\"", valuestr);

	  sz = Len(cpatchlist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(cpatchlist, i);
	    Replace(s, tmp, tmpr, DOH_REPLACE_ID);
	    /*  Replace(s,name,tydef, DOH_REPLACE_ID); */
	    Replace(s, name, valuestr, DOH_REPLACE_ID);
	  }
	  Delete(tmp);
	  Delete(tmpr);
	  Delete(valuestr);
	  Delete(dvalue);
	  Delete(qvalue);
	}
	p = nextSibling(p);
	tp = nextSibling(tp);
	if (!p)
	  p = tp;
      }
    } else {
      /* No template parameters at all.  This could be a specialization */
      int i, sz;
      sz = Len(typelist);
      for (i = 0; i < sz; i++) {
	String *s = Getitem(typelist, i);
	SwigType_typename_replace(s, tbase, iname);
      }
    }
  }

  /* Patch bases */
  {
    List *bases = Getattr(n, "baselist");
    if (bases) {
      Iterator b;
      for (b = First(bases); b.item; b = Next(b)) {
	String *qn = Swig_symbol_type_qualify(b.item, tscope);
	Clear(b.item);
	Append(b.item, qn);
	Delete(qn);
      }
    }
  }
  Delete(patchlist);
  Delete(cpatchlist);
  Delete(typelist);
  Delete(tbase);
  Delete(tname);
  Delete(templateargs);

  /*  set_nodeType(n,"template"); */
  return 0;
}

/* -----------------------------------------------------------------------------
 * template_locate()
 *
 * Search for a template that matches name with given parameters.
 * ----------------------------------------------------------------------------- */

static Node *template_locate(String *name, Parm *tparms, Symtab *tscope) {
  Node *n;
  String *tname, *rname = 0;
  Node *templ;
  List *mpartials = 0;
  Parm *p;
  Parm *parms;
  Parm *targs;
  ParmList *expandedparms;

  tname = Copy(name);
  parms = CopyParmList(tparms);

  /* Search for generic template */
  templ = Swig_symbol_clookup(name, 0);

  /* Add default values from generic template */
  if (templ) {
    Symtab *tsdecl = Getattr(templ, "sym:symtab");

    targs = Getattr(templ, "templateparms");
    expandedparms = Swig_symbol_template_defargs(parms, targs, tscope, tsdecl);
  } else {
    expandedparms = parms;
  }


  /* reduce the typedef */
  p = expandedparms;
  while (p) {
    SwigType *ty = Getattr(p, "type");
    if (ty) {
      SwigType *nt = Swig_symbol_type_qualify(ty, tscope);
      Setattr(p, "type", nt);
      Delete(nt);
    }
    p = nextSibling(p);
  }

  SwigType_add_template(tname, expandedparms);

  if (template_debug) {
    Printf(stdout, "\n%s:%d: template_debug: Searching for %s\n", cparse_file, cparse_line, tname);
  }

  /* Search for an exact specialization.
     Example: template<> class name<int> { ... } */
  {
    if (template_debug) {
      Printf(stdout, "    searching: '%s' (exact specialization)\n", tname);
    }
    n = Swig_symbol_clookup_local(tname, 0);
    if (!n) {
      SwigType *rname = Swig_symbol_typedef_reduce(tname, tscope);
      if (!Equal(rname, tname)) {
	if (template_debug) {
	  Printf(stdout, "    searching: '%s' (exact specialization)\n", rname);
	}
	n = Swig_symbol_clookup_local(rname, 0);
      }
      Delete(rname);
    }
    if (n) {
      Node *tn;
      String *nodeType = nodeType(n);
      if (Equal(nodeType, "template"))
	goto success;
      tn = Getattr(n, "template");
      if (tn) {
	n = tn;
	goto success;		/* Previously wrapped by a template return that */
      }
      Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, nodeType(n));
      Delete(tname);
      Delete(parms);
      return 0;			/* Found a match, but it's not a template of any kind. */
    }
  }

  /* Search for partial specialization. 
     Example: template<typename T> class name<T *> { ... } */

  /* Generate reduced template name (stripped of extraneous pointers, etc.) */

  rname = NewStringf("%s<(", name);
  p = parms;
  while (p) {
    String *t;
    t = Getattr(p, "type");
    if (!t)
      t = Getattr(p, "value");
    if (t) {
      String *ty = Swig_symbol_typedef_reduce(t, tscope);
      String *tb = SwigType_base(ty);
      String *td = SwigType_default(ty);
      Replaceid(td, "enum SWIGTYPE", tb);
      Replaceid(td, "SWIGTYPE", tb);
      Append(rname, td);
      Delete(tb);
      Delete(ty);
      Delete(td);
    }
    p = nextSibling(p);
    if (p) {
      Append(rname, ",");
    }
  }
  Append(rname, ")>");

  mpartials = NewList();
  if (templ) {
    /* First, we search using an exact type prototype */
    Parm *p;
    char tmp[32];
    int i;
    List *partials;
    String *ss;
    Iterator pi;

    partials = Getattr(templ, "partials");
    if (partials) {
      for (pi = First(partials); pi.item; pi = Next(pi)) {
	ss = Copy(pi.item);
	p = parms;
	i = 1;
	while (p) {
	  String *t, *tn;
	  sprintf(tmp, "$%d", i);
	  t = Getattr(p, "type");
	  if (!t)
	    t = Getattr(p, "value");
	  if (t) {
	    String *ty = Swig_symbol_typedef_reduce(t, tscope);
	    tn = SwigType_base(ty);
	    Replaceid(ss, tmp, tn);
	    Delete(tn);
	    Delete(ty);
	  }
	  i++;
	  p = nextSibling(p);
	}
	if (template_debug) {
	  Printf(stdout, "    searching: '%s' (partial specialization - %s)\n", ss, pi.item);
	}
	if ((Equal(ss, tname)) || (Equal(ss, rname))) {
	  Append(mpartials, pi.item);
	}
	Delete(ss);
      }
    }
  }

  if (template_debug) {
    Printf(stdout, "    Matched partials: %s\n", mpartials);
  }

  if (Len(mpartials)) {
    String *s = Getitem(mpartials, 0);
    n = Swig_symbol_clookup_local(s, 0);
    if (Len(mpartials) > 1) {
      if (n) {
	Swig_warning(WARN_PARSE_TEMPLATE_AMBIG, cparse_file, cparse_line, "Instantiation of template '%s' is ambiguous,\n", SwigType_namestr(tname));
	Swig_warning(WARN_PARSE_TEMPLATE_AMBIG, Getfile(n), Getline(n), "  instantiation '%s' is used.\n", SwigType_namestr(Getattr(n, "name")));
      }
    }
  }

  if (!n) {
    n = templ;
  }
  if (!n) {
    Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", name);
  } else if (n) {
    String *nodeType = nodeType(n);
    if (!Equal(nodeType, "template")) {
      Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, nodeType);
      n = 0;
    }
  }
success:
  Delete(tname);
  Delete(rname);
  Delete(mpartials);
  if ((template_debug) && (n)) {
    Printf(stdout, "Node: %p\n", n);
    Swig_print_node(n);
  }
  Delete(parms);
  return n;
}


/* -----------------------------------------------------------------------------
 * Swig_cparse_template_locate()
 *
 * Search for a template that matches name with given parameters.
 * For templated classes finds the specialized template should there be one.
 * For templated functions finds the unspecialized template even if a specialized
 * template exists.
 * ----------------------------------------------------------------------------- */

Node *Swig_cparse_template_locate(String *name, Parm *tparms, Symtab *tscope) {
  Node *n = template_locate(name, tparms, tscope);	/* this function does what we want for templated classes */

  if (n) {
    String *nodeType = nodeType(n);
    int isclass = 0;
    assert(Equal(nodeType, "template"));
    isclass = (Equal(Getattr(n, "templatetype"), "class"));
    if (!isclass) {
      /* If not a templated class we must have a templated function.
         The template found is not necessarily the one we want when dealing with templated
         functions. We don't want any specialized templated functions as they won't have
         the default parameters. Lets look for the unspecialized template. Also make sure
         the number of template parameters is correct as it is possible to overload a
         templated function with different numbers of template parameters. */

      if (template_debug) {
	Printf(stdout, "    Not a templated class, seeking most appropriate templated function\n");
      }

      n = Swig_symbol_clookup_local(name, 0);
      while (n) {
	Parm *tparmsfound = Getattr(n, "templateparms");
	if (ParmList_len(tparms) == ParmList_len(tparmsfound)) {
	  /* successful match */
	  break;
	}
	/* repeat until we find a match with correct number of templated parameters */
	n = Getattr(n, "sym:nextSibling");
      }

      if (!n) {
	Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", name);
      }

      if ((template_debug) && (n)) {
	Printf(stdout, "Templated function found: %p\n", n);
	Swig_print_node(n);
      }
    }
  }

  return n;
}
