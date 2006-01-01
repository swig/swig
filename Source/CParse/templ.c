/* ----------------------------------------------------------------------------- 
 * templ.c
 *
 *     Expands a template into a specialized version.   
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 * ----------------------------------------------------------------------------- */

char cvsroot_templ_c[] = "$Header$";

#include "swig.h"
#include "cparse.h"

static int template_debug = 0;

static String *k_baselist = 0;
static String *k_cdecl = 0;
static String *k_class = 0;
static String *k_code = 0;
static String *k_constructor = 0;
static String *k_conversionoperator = 0;
static String *k_decl = 0;
static String *k_destructor = 0;
static String *k_error = 0;
static String *k_kwargs = 0;
static String *k_name = 0;
static String *k_namespace = 0;
static String *k_nodetype = 0;
static String *k_parms = 0;
static String *k_partialargs = 0;
static String *k_partials = 0;
static String *k_pattern = 0;
static String *k_privatebaselist = 0;
static String *k_protectedbaselist = 0;
static String *k_symname = 0;
static String *k_symnextSibling = 0;
static String *k_symsymtab = 0;
static String *k_template = 0;
static String *k_templateparms = 0;
static String *k_templatetype = 0;
static String *k_throws = 0;
static String *k_type = 0;
static String *k_typedef = 0;
static String *k_uname = 0;
static String *k_using = 0;
static String *k_value = 0;

String *baselists[3];

void SwigType_template_init()
{
  k_baselist = NewString("baselist");
  k_cdecl = NewString("cdecl");
  k_class = NewString("class");
  k_code = NewString("code");
  k_constructor = NewString("constructor");
  k_conversionoperator = NewString("conversion_operator");
  k_decl = NewString("decl");
  k_destructor = NewString("destructor");
  k_error = NewString("error");
  k_kwargs = NewString("kwargs");
  k_name = NewString("name");
  k_namespace = NewString("namespace");
  k_nodetype = NewString("nodeType");
  k_parms = NewString("parms");
  k_partialargs = NewString("partialargs");
  k_partials = NewString("partials");
  k_pattern = NewString("pattern");
  k_privatebaselist = NewString("privatebaselist");
  k_protectedbaselist = NewString("protectedbaselist");
  k_symname = NewString("sym:name");
  k_symnextSibling = NewString("sym:nextSibling");
  k_symsymtab = NewString("sym:symtab");
  k_template = NewString("template");
  k_templateparms = NewString("templateparms");
  k_templatetype = NewString("templatetype");
  k_throws = NewString("throws");
  k_type = NewString("type");
  k_typedef = NewString("typedef");
  k_uname = NewString("uname");
  k_using = NewString("using");
  k_value = NewString("value");

  baselists[0] = k_baselist;
  baselists[1] = k_protectedbaselist;
  baselists[2] = k_privatebaselist;
}


static void add_parms(ParmList *p, List *patchlist, List *typelist) {
  while (p) {
    SwigType *ty = Getattr(p,k_type);
    SwigType *val = Getattr(p,k_value);
    Append(typelist,ty);
    Append(typelist,val);
    Append(patchlist,val);
    p = nextSibling(p);
  }
}

void Swig_cparse_debug_templates(int x) {
    template_debug = x;
}

/* -----------------------------------------------------------------------------
 * Swig_cparse_template_expand()
 *
 * Expands a template node into a specialized version.  This is done by
 * patching typenames and other aspects of the node according to a list of
 * template parameters
 * ----------------------------------------------------------------------------- */

static int
cparse_template_expand(Node *n, String *tname, String *rname, String *templateargs, List *patchlist, List *typelist, List *cpatchlist) {
  static int expanded = 0;
  int ret;
  String *nodeType = Getattr(n,k_nodetype);
  if (!n) return 0;
  if (Getattr(n,k_error)) return 0;

  if (StringEqual(nodeType,k_template)) {
    /* Change the node type back to normal */
    if (!expanded) {
      expanded = 1;
      Setattr(n,k_nodetype,Getattr(n,k_templatetype));
      ret = cparse_template_expand(n,tname, rname, templateargs, patchlist,typelist, cpatchlist);
      expanded = 0;
      return ret;
    } else {
	/* Called when template appears inside another template */
	/* Member templates */

      Setattr(n,k_nodetype,Getattr(n,k_templatetype));
      ret = cparse_template_expand(n,tname, rname, templateargs, patchlist,typelist, cpatchlist);
      Setattr(n,k_nodetype,k_template);
      return ret;
    }
  } else if (StringEqual(nodeType,k_cdecl)) {
    /* A simple C declaration */
    SwigType *t, *v, *d;
    String   *code;
    t = Getattr(n,k_type);
    v = Getattr(n,k_value);
    d = Getattr(n,k_decl);

    code = Getattr(n,k_code);
    
    Append(typelist,t);
    Append(typelist,d);
    Append(patchlist,v);
    Append(cpatchlist,code);
    
    if (Getattr(n,k_conversionoperator)) {
      Append(cpatchlist, Getattr(n,k_name));
      if (Getattr(n,k_symname)) {
	Append(cpatchlist, Getattr(n,k_symname));
      }
    }
    
    add_parms(Getattr(n,k_parms), cpatchlist, typelist);
    add_parms(Getattr(n,k_throws), cpatchlist, typelist);

  } else if (StringEqual(nodeType,k_class)) {
    /* Patch base classes */
    {
      int b = 0;
      for (b = 0; b < 3; ++b) {
	List *bases = Getattr(n,baselists[b]);
	if (bases) {
	  int i;
	  int ilen = Len(bases); 
	  for (i = 0; i < ilen; i++) {
	    String *name = Copy(Getitem(bases,i));
	    Setitem(bases,i,name);
	    Append(typelist,name);
	  }
	}
      }
    }
    /* Patch children */
    {
      Node *cn = firstChild(n);
      while (cn) {
	cparse_template_expand(cn,tname, rname, templateargs, patchlist,typelist,cpatchlist);
	cn = nextSibling(cn);
      }
    }
  } else if (StringEqual(nodeType,k_constructor)) {
    String *name = Getattr(n,k_name);
    if (!(Getattr(n,k_templatetype))) {
      String *symname;
      String *stripped_name = SwigType_templateprefix(name);
      if (Strstr(tname,stripped_name)) {
	Replaceid(name,stripped_name,tname);
      }
      Delete(stripped_name);
      symname = Getattr(n,k_symname);
      if (symname) {
	stripped_name = SwigType_templateprefix(symname);
	if (Strstr(tname,stripped_name)) {
	  Replaceid(symname,stripped_name,tname);
	}
	Delete(stripped_name);
      }
      if (strstr(Char(name),"<")) {
	Append(patchlist,Getattr(n,k_name));
      } else {
	Append(name,templateargs);
      }
      name = Getattr(n,k_symname);
      if (name) {
	if (strstr(Char(name),"<")) {
	  Clear(name);
	  Append(name,rname);   
	} else {
	  String *tmp = Copy(name);
	  Replace(tmp,tname,rname, DOH_REPLACE_ANY);
	  Clear(name);
	  Append(name,tmp);
	  Delete(tmp);
	}
      }
      /* Setattr(n,k_symname,name); */
    }
    Append(cpatchlist,Getattr(n,k_code));
    Append(typelist, Getattr(n,k_decl));
    add_parms(Getattr(n,k_parms), cpatchlist, typelist);
    add_parms(Getattr(n,k_throws), cpatchlist, typelist);
  } else if (StringEqual(nodeType,k_destructor)) {
    String *name = Getattr(n,k_name);
    if (name && strstr(Char(name),"<")) {
      Append(patchlist,Getattr(n,k_name));
    } else {
      Append(name,templateargs);
    }
    name = Getattr(n,k_symname);
    if (name && strstr(Char(name),"<")) {
      String *sn = Copy(tname);
      Setattr(n,k_symname, sn);
      Delete(sn);
    } else {
      Replace(name,tname,rname, DOH_REPLACE_ANY);
    }
    /* Setattr(n,k_symname,name); */
    Append(cpatchlist,Getattr(n,k_code));
  } else if (StringEqual(nodeType,k_using)) {
    String *uname = Getattr(n,k_uname);
    if (uname && strstr(Char(uname),"<")) {
      Append(patchlist, uname);
    }
    if (Getattr(n,k_namespace)) {
      /* Namespace link.   This is nasty.  Is other namespace defined? */

    }
  } else {
    /* Look for obvious parameters */
    Node *cn;
    Append(cpatchlist,Getattr(n,k_code));
    Append(typelist, Getattr(n,k_type));
    Append(typelist, Getattr(n,k_decl));
    add_parms(Getattr(n,k_parms), cpatchlist, typelist);
    add_parms(Getattr(n,k_kwargs), cpatchlist, typelist);
    add_parms(Getattr(n,k_pattern), cpatchlist, typelist);
    add_parms(Getattr(n,k_throws), cpatchlist, typelist);
    cn = firstChild(n);
    while (cn) {
      cparse_template_expand(cn,tname, rname, templateargs, patchlist, typelist, cpatchlist);
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
  
  c = strstr(cp,"$");
  if (!c) {
    return Copy(s);
  }
  prefix = NewStringWithSize(cp,c-cp);
  newarg = Copy(s);
  Replace(newarg,prefix,"",DOH_REPLACE_ANY | DOH_REPLACE_FIRST);
  Delete(prefix);
  return newarg;
}

int
Swig_cparse_template_expand(Node *n, String *rname, ParmList *tparms, Symtab *tscope) {
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
      SwigType_add_template(tmp,tparms);
    }
    templateargs = Copy(tmp);
    Delete(tmp);
  }

  tname = Copy(Getattr(n,k_name));
  tbase = Swig_scopename_last(tname);

  /* Look for partial specialization matching */
  if (Getattr(n,k_partialargs)) {
    Parm *p, *tp;
    ParmList *ptargs = SwigType_function_parms(Getattr(n,k_partialargs));
    p = ptargs;
    tp = tparms;
    while (p && tp) {
      SwigType *ptype;
      SwigType *tptype;
      SwigType *partial_type;
      ptype = Getattr(p,k_type);
      tptype = Getattr(tp,k_type);
      if (ptype && tptype) {
	partial_type = partial_arg(tptype,ptype);
	/*	Printf(stdout,"partial '%s' '%s'  ---> '%s'\n", tptype, ptype, partial_type); */
	Setattr(tp,k_type,partial_type);
	Delete(partial_type);
      }
      p = nextSibling(p);
      tp = nextSibling(tp);
    }
    assert(ParmList_len(ptargs) == ParmList_len(tparms));
    Delete(ptargs);
  }

  if (0) {
    Parm *p = tparms;
    while (p) {
      Printf(stdout,"tparm: '%s' '%s' '%s'\n", Getattr(p,k_name), Getattr(p,k_type), Getattr(p,k_value));
      p = nextSibling(p);
    }
  }

  /*  Printf(stdout,"targs = '%s'\n", templateargs);
  Printf(stdout,"rname = '%s'\n", rname);
  Printf(stdout,"tname = '%s'\n", tname);  */
  cparse_template_expand(n,tname, rname, templateargs, patchlist, typelist, cpatchlist);

  /* Set the name */
  {
    String *name = Getattr(n,k_name);
    if (name) {
      Append(name,templateargs);
    }
    iname = name;
  }

  /* Patch all of the types */
  {
    Parm *tp = Getattr(n,k_templateparms);
    Parm *p  = tparms;
    /*    Printf(stdout,"%s\n", ParmList_str_defaultargs(tp)); */

    if (tp) {
      Symtab *tsdecl = Getattr(n,k_symsymtab);
      while (p && tp) {
	String *name, *value, *valuestr, *tydef, *tmp, *tmpr;
	int     sz, i;
	String *dvalue = 0;
	String *qvalue = 0;
	
	name = Getattr(tp,k_name);
	value = Getattr(p,k_value);
	tydef = Getattr(p,k_typedef);

	if (name) {
	  if (!value) value = Getattr(p,k_type);
	  qvalue = Swig_symbol_typedef_reduce(value, tsdecl);
	  dvalue = Swig_symbol_type_qualify(qvalue,tsdecl); 
	  if (SwigType_istemplate(dvalue)) {
	    String *ty = Swig_symbol_template_deftype(dvalue, tscope);
	    Delete(dvalue);
	    dvalue = ty;
	  }
	  
	  assert(dvalue);
	  valuestr = SwigType_str(dvalue,0);
	  /* Need to patch default arguments */
	  {
	    Parm *rp = nextSibling(p);
	    while (rp) {
	      String *rvalue = Getattr(rp,k_value);
	      if (rvalue) {
		Replace(rvalue,name,dvalue, DOH_REPLACE_ID);
	      }
	      rp = nextSibling(rp);
	    }
	  }
	  sz = Len(patchlist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(patchlist,i);
	    Replace(s,name,dvalue, DOH_REPLACE_ID);
	  }
	  sz = Len(typelist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(typelist,i);
	    /*	    Replace(s,name,value, DOH_REPLACE_ID); */
	    /*	    Printf(stdout,"name = '%s', value = '%s', tbase = '%s', iname='%s' s = '%s' --> ", name, dvalue, tbase, iname, s); */
	    SwigType_typename_replace(s,name,dvalue);
	    SwigType_typename_replace(s,tbase,iname);
	    /*	    Printf(stdout,"'%s'\n", s);*/
	  }
	  
	  if (!tydef) {
	    tydef = dvalue;
	  }
	  tmp = NewStringf("#%s",name);
	  tmpr = NewStringf("\"%s\"", valuestr);
	  
	  sz = Len(cpatchlist);
	  for (i = 0; i < sz; i++) {
	    String *s = Getitem(cpatchlist,i);
	    Replace(s,tmp,tmpr, DOH_REPLACE_ID);
	    /*	Replace(s,name,tydef, DOH_REPLACE_ID); */
	    Replace(s,name,valuestr, DOH_REPLACE_ID);
	  }
	  Delete(tmp);
	  Delete(tmpr);
	  Delete(valuestr);
	  Delete(dvalue);
	  Delete(qvalue);
	}
	p = nextSibling(p);
	tp = nextSibling(tp);
	if (!p) p = tp;
      }
    } else {
      /* No template parameters at all.  This could be a specialization */
      int i, sz;
      sz = Len(typelist);
      for (i = 0; i < sz; i++) {
	String *s = Getitem(typelist,i);
	SwigType_typename_replace(s,tbase,iname);
      }
    }
  }

  /* Patch bases */
  {
    List *bases = Getattr(n,k_baselist);
    if (bases) {
      Iterator b;
      for (b = First(bases); b.item; b = Next(b)) {
	String *qn = Swig_symbol_type_qualify(b.item,tscope);
	Clear(b.item);
	Append(b.item,qn);
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

  /*  set_nodeType(n,k_template);*/
  return 0;
}

/* -----------------------------------------------------------------------------
 * template_locate()
 *
 * Search for a template that matches name with given parameters.
 * ----------------------------------------------------------------------------- */

static Node *
template_locate(String *name, Parm *tparms, Symtab *tscope) {
  Node   *n;
  String *tname, *rname = 0;
  Node   *templ;
  List   *mpartials = 0;
  Parm   *p;
  Parm   *parms;
  Parm   *targs;

  tname = Copy(name);
  parms = CopyParmList(tparms);

  /* Search for generic template */
  templ = Swig_symbol_clookup(name,0);

  /* Add default values from generic template */
  if (templ) {
    Symtab *tsdecl = Getattr(templ,k_symsymtab);

    targs = Getattr(templ,k_templateparms);
    Swig_symbol_template_defargs(parms, targs, tscope, tsdecl);
  }
  

  /* reduce the typedef */
  p = parms;
  while (p) {
    SwigType *ty = Getattr(p,k_type);
    if (ty) {
      SwigType *nt = Swig_symbol_type_qualify(ty,tscope);
      Setattr(p,k_type,nt);
      Delete(nt);
    }
    p = nextSibling(p);
  }

  SwigType_add_template(tname,parms);

  if (template_debug) {
      Printf(stdout,"\n%s:%d: template_debug: Searching for %s\n", cparse_file, cparse_line, tname);
  }

  /* Search for an exact specialization.
     Example: template<> class name<int> { ... } */
  {
    if (template_debug) {
      Printf(stdout,"    searching: '%s' (exact specialization)\n", tname);
    }
    n = Swig_symbol_clookup_local(tname,0);
    if (!n) {
      SwigType *rname = Swig_symbol_typedef_reduce(tname,tscope);	
      if (!StringEqual(rname,tname)) {
	if (template_debug) {
	  Printf(stdout,"    searching: '%s' (exact specialization)\n", rname);
	}
	n = Swig_symbol_clookup_local(rname,0);
      }
      Delete(rname);
    }
    if (n) {
      Node *tn;
      String *nodeType = Getattr(n,k_nodetype);
      if (StringEqual(nodeType,k_template)) goto success;
      tn = Getattr(n,k_template);
      if (tn) {
	n = tn;
	goto success; /* Previously wrapped by a template return that */
      }
      Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, Getattr(n,k_nodetype));
      Delete(tname);
      Delete(parms);
      return 0;        /* Found a match, but it's not a template of any kind. */
    }
  }
  
  /* Search for partial specialization. 
     Example: template<typename T> class name<T *> { ... } */

  /* Generate reduced template name (stripped of extraneous pointers, etc.) */

  rname = NewStringf("%s<(",name);
  p = parms;
  while (p) {
    String *t;
    t = Getattr(p,k_type);
    if (!t) t = Getattr(p,k_value);
    if (t) {
      String *ty = Swig_symbol_typedef_reduce(t,tscope);
      String *tb = SwigType_base(ty); 
      String *td = SwigType_default(ty);
      Replaceid(td,"enum SWIGTYPE",tb);
      Replaceid(td,"SWIGTYPE",tb);
      Append(rname,td);
      Delete(tb);
      Delete(ty);
      Delete(td);
    }
    p = nextSibling(p);
    if (p) {
      Append(rname,",");
    }
  }
  Append(rname,")>");

  mpartials = NewList();
  if (templ) {
      /* First, we search using an exact type prototype */
      Parm   *p;
      char   tmp[32];
      int    i;
      List   *partials;
      String *ss;
      Iterator pi;

      partials = Getattr(templ,k_partials);
      if (partials) {
	for (pi = First(partials); pi.item; pi = Next(pi)) {
	  ss = Copy(pi.item);
	  p = parms;
	  i = 1;
	  while (p) {
	    String *t,*tn;
	    sprintf(tmp,"$%d",i);
	    t = Getattr(p,k_type);
	    if (!t) t = Getattr(p,k_value);
	    if (t) {
	      String *ty = Swig_symbol_typedef_reduce(t,tscope);
	      tn = SwigType_base(ty);
	      Replaceid(ss,tmp,tn);
	      Delete(tn);
	      Delete(ty);
	    }
	    i++;
	    p = nextSibling(p);
	  }
	  if (template_debug) {
	    Printf(stdout,"    searching: '%s' (partial specialization - %s)\n", ss, pi.item);
	  }
	  if ((StringEqual(ss,tname)) || (StringEqual(ss,rname))) {
	    Append(mpartials,pi.item);
	  }
	  Delete(ss);
	}
      }
  }

  if (template_debug) {
    Printf(stdout,"    Matched partials: %s\n", mpartials);
  }

  if (Len(mpartials)) {
    String *s = Getitem(mpartials,0);
    n = Swig_symbol_clookup_local(s,0);
    if (Len(mpartials) > 1) {
      if (n) {
	Swig_warning(WARN_PARSE_TEMPLATE_AMBIG,cparse_file,cparse_line,
		     "Instantiation of template '%s' is ambiguous,\n",
		     SwigType_namestr(tname));
	Swig_warning(WARN_PARSE_TEMPLATE_AMBIG,Getfile(n),Getline(n),
		     "  instantiation '%s' is used.\n",
		     SwigType_namestr(Getattr(n,k_name)));
      }
    }
  }

  if (!n) {
    n = templ;
  }
  if (!n) {
    Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", name);
  } else  if (n) {
    String *nodeType = Getattr(n,k_nodetype);
    if (!StringEqual(nodeType,k_template)) {
      Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, nodeType);	  
      n = 0;
    }
  }
 success:
  Delete(tname);
  Delete(rname);
  Delete(mpartials);
  if ((template_debug) && (n)) {
    Printf(stdout,"Node: %p\n", n);
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

Node *
Swig_cparse_template_locate(String *name, Parm *tparms, Symtab *tscope) {
  Node *n  = template_locate(name, tparms, tscope); /* this function does what we want for templated classes */
  String *nodeType = Getattr(n,k_nodetype);

  if (n) {
    int isclass = 0;
    assert(StringEqual(nodeType,k_template));
    isclass = (StringEqual(Getattr(n,k_templatetype),k_class));
    if (!isclass) {
      /* If not a templated class we must have a templated function.
         The template found is not necessarily the one we want when dealing with templated
         functions. We don't want any specialized templated functions as they won't have
         the default parameters. Lets look for the unspecialized template. Also make sure
         the number of template parameters is correct as it is possible to overload a
         templated function with different numbers of template parameters. */

      if (template_debug) {
        Printf(stdout,"    Not a templated class, seeking most appropriate templated function\n");
      }

      n = Swig_symbol_clookup_local(name,0);
      while (n) {
        Parm *tparmsfound = Getattr(n,k_templateparms);
        if (ParmList_len(tparms) == ParmList_len(tparmsfound)) {
          /* successful match */
          break;
        }
        /* repeat until we find a match with correct number of templated parameters */
        n = Getattr(n,k_symnextSibling);
      }
 
      if (!n) {
        Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", name);
      }

      if ((template_debug) && (n)) {
        Printf(stdout,"Templated function found: %p\n", n);
          Swig_print_node(n);
      }
    }
  }

  return n;
}

