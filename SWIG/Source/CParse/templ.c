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

static char cvsroot[] = "$Header$";

#include "swig.h"
#include "cparse.h"

static int template_debug = 0;

static void add_parms(ParmList *p, List *patchlist, List *typelist) {
  while (p) {
    SwigType *ty = Getattr(p,"type");
    SwigType *val = Getattr(p,"value");
    Append(typelist,ty);
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

  if (!n) return 0;
  if (Getattr(n,"error")) return 0;

  if (Strcmp(nodeType(n),"template") == 0) {
    /* Change the node type back to normal */
    if (!expanded) {
      expanded = 1;
      set_nodeType(n,Getattr(n,"templatetype"));
      ret = cparse_template_expand(n,tname, rname, templateargs, patchlist,typelist, cpatchlist);
      expanded = 0;
      return ret;
    } else {
	/* Called when template appears inside another template */
	/* Member templates */

      set_nodeType(n,Getattr(n,"templatetype"));
      ret = cparse_template_expand(n,tname, rname, templateargs, patchlist,typelist, cpatchlist);
      set_nodeType(n,"template");
      return ret;
    }
  } else if (Strcmp(nodeType(n),"cdecl") == 0) {
    /* A simple C declaration */
    SwigType *t, *v, *d;
    String   *code;
    t = Getattr(n,"type");
    v = Getattr(n,"value");
    d = Getattr(n,"decl");

    code = Getattr(n,"code");
    
    Append(typelist,t);
    Append(typelist,d);
    Append(patchlist,v);
    Append(cpatchlist,code);
    
    add_parms(Getattr(n,"parms"), cpatchlist, typelist);
  } else if (Strcmp(nodeType(n),"class") == 0) {
    /* Patch base classes */
    {
      List *bases = Getattr(n,"baselist");
      if (bases) {
	int i;
	for (i = 0; i < Len(bases); i++) {
	  String *name = Copy(Getitem(bases,i));
	  Setitem(bases,i,name);
	  Append(typelist,name);
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
  } else if (Strcmp(nodeType(n),"constructor") == 0) {
    String *name = Getattr(n,"name");
    if (!(Getattr(n,"templatetype"))) {
      String *symname;
      String *stripped_name = SwigType_templateprefix(name);
      if (Strstr(tname,stripped_name)) {
	Replaceid(name,stripped_name,tname);
      }
      Delete(stripped_name);
      symname = Getattr(n,"sym:name");
      if (symname) {
	stripped_name = SwigType_templateprefix(symname);
	if (Strstr(tname,stripped_name)) {
	  Replaceid(symname,stripped_name,tname);
	}
	Delete(stripped_name);
      }
      if (Strstr(name,"<")) {
	Append(patchlist,Getattr(n,"name"));
      } else {
	Append(name,templateargs);
      }
      name = Getattr(n,"sym:name");
      if (name && (Strstr(name,"<"))) {
	Setattr(n,"sym:name", Copy(tname));
      } else {
	Replace(name,tname,rname, DOH_REPLACE_ANY);
      }
      Setattr(n,"sym:name",name);
    }
    Append(cpatchlist,Getattr(n,"code"));
    Append(typelist, Getattr(n,"decl"));
    add_parms(Getattr(n,"parms"), cpatchlist, typelist);
  } else if (Strcmp(nodeType(n),"destructor") == 0) {
    String *name = Getattr(n,"name");
    if (Strstr(name,"<")) {
      Append(patchlist,Getattr(n,"name"));
    } else {
      Append(name,templateargs);
    }
    name = Getattr(n,"sym:name");
    if (Strstr(name,"<")) {
      Setattr(n,"sym:name", Copy(tname));
    } else {
      Replace(name,tname,rname, DOH_REPLACE_ANY);
    }
    Setattr(n,"sym:name",name);
    Append(cpatchlist,Getattr(n,"code"));
  } else if (Strcmp(nodeType(n),"using") == 0) {
    String *uname = Getattr(n,"uname");
    if (uname) {
      if (Strstr(uname,"<")) {
	Append(patchlist, uname);
      }
    }
    if (Getattr(n,"namespace")) {
      /* Namespace link.   This is nasty.  Is other namespace defined? */

    }
  } else {
    /* Look for obvious parameters */
    Node *cn;
    Append(cpatchlist,Getattr(n,"code"));
    Append(typelist, Getattr(n,"type"));
    Append(typelist, Getattr(n,"decl"));
    add_parms(Getattr(n,"parms"), cpatchlist, typelist);
    add_parms(Getattr(n,"pattern"), cpatchlist, typelist);
    cn = firstChild(n);
    while (cn) {
      cparse_template_expand(cn,tname, rname, templateargs, patchlist, typelist, cpatchlist);
      cn = nextSibling(cn);
    }
  }
  return 0;
}

int
Swig_cparse_template_expand(Node *n, String *rname, ParmList *tparms) {
  List *patchlist, *cpatchlist, *typelist;
  String *templateargs;
  String *tname;
  String *iname;
  String *tbase;
  patchlist = NewList();
  cpatchlist = NewList();
  typelist = NewList();

  {
    String *tmp = NewString("");
    if (tparms) {
      SwigType_add_template(tmp,tparms);
    }
    templateargs = Copy(tmp);
    Delete(tmp);
  }

  tname = Copy(Getattr(n,"name"));
  tbase = Swig_scopename_base(tname);

  cparse_template_expand(n,tname, rname, templateargs, patchlist, typelist, cpatchlist);

  /* Set the name */
  {
    String *name = Getattr(n,"name");
    if (name) {
      Append(name,templateargs);
    }
    iname = name;
  }

  /* Patch all of the types */
  {
    Parm *tp = Getattr(n,"templateparms");
    Parm *p  = tparms;
    while (p && tp) {
      String *name, *value, *valuestr, *tydef, *tmp, *tmpr;
      int     sz, i;

      name = Getattr(tp,"name");
      value = Getattr(p,"value");
      tydef = Getattr(p,"typedef");
      if (name) {
	  if (!value) {
	      value = Getattr(p,"type");
	      valuestr = SwigType_str(value,0);
	  } else {
	      valuestr = Copy(value);
	  }
	  assert(value);
	  
	  /* Need to patch default arguments */
	  {
	      Parm *rp = nextSibling(p);
	      while (rp) {
		  String *rvalue = Getattr(rp,"value");
		  if (rvalue) {
		      Replace(rvalue,name,value, DOH_REPLACE_ID);
		  }
		  rp = nextSibling(rp);
	      }
	  }
	  
	  sz = Len(patchlist);
	  for (i = 0; i < sz; i++) {
	      String *s = Getitem(patchlist,i);
	      Replace(s,name,value, DOH_REPLACE_ID);
	  }
	  sz = Len(typelist);
	  for (i = 0; i < sz; i++) {
	      String *s = Getitem(typelist,i);
	      Replace(s,name,value, DOH_REPLACE_ID);
	      /*	Printf(stdout,"s='%s' tname = '%s', iname = '%s'\n", s, tname,iname); */
	      SwigType_typename_replace(s,tbase,iname);
	      
	  }
	  if (!tydef) {
	      tydef = value;
	  }
	  tmp = NewStringf("#%s",name);
	  tmpr = NewStringf("\"%s\"", value);
	  
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
      }
      p = nextSibling(p);
      tp = nextSibling(tp);
      if (!p) p = tp;
    }
  }
  Delete(patchlist);
  Delete(cpatchlist);
  Delete(typelist);
  Delete(tbase);

  /*  set_nodeType(n,"template");*/
  return 0;
}

/* -----------------------------------------------------------------------------
 * cparse_template_locate()
 *
 * Search for a template that matches name with given parameters.
 * ----------------------------------------------------------------------------- */

Node *
Swig_cparse_template_locate(String *name, Parm *parms) {
  Node   *n;
  String *tname, *rname;
  Node   *templ;
  List   *mpartials = 0;
  Parm   *p;

  tname = NewString(name);
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
      if (n) {
	  Node *tn;
	  if (Strcmp(nodeType(n),"template") == 0) goto success;
	  tn = Getattr(n,"template");
	  if (tn) {
	      n = tn;
	      goto success; /* Previously wrapped by a template return that */
	  }
	  Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, nodeType(n));
	  Delete(tname);
	  return 0;        /* Found a match, but it's not a template of any kind. */
      }
  }

  /* Search for generic template */
  templ = Swig_symbol_clookup_local(name,0);

  /* Search for partial specialization. 
     Example: template<typename T> class name<T *> { ... } */

  /* Generate reduced template name (stripped of extraneous pointers, etc.) */

  rname = NewStringf("%s<(",name);
  p = parms;
  while (p) {
    String *t;
    t = Getattr(p,"type");
    if (t) {
      String *tbase = SwigType_base(t);
      t = SwigType_default(t);
      Replaceid(t,"SWIGTYPE",tbase);
      Replaceid(t,"SWIGENUM",tbase);
      Printf(rname,"%s",t);
      Delete(t);
    } else {
      String *v = Getattr(p,"value");
      Printf(rname,"%s",v);
    }
    p = nextSibling(p);
    if (p) {
      Printf(rname,",");
    }
  }
  Printf(rname,")>");

  mpartials = NewList();
  if (templ) {
      /* First, we search using an exact type prototype */
      Parm   *p;
      char   tmp[32];
      int    i;
      List   *partials;
      String *s, *ss;

      partials = Getattr(templ,"partials");
      if (partials) {
	for (s = Firstitem(partials); s; s= Nextitem(partials)) {
	  ss = Copy(s);
	  p = parms;
	  i = 1;
	  while (p) {
	    String *t,*tn;
	    sprintf(tmp,"$%d",i);
	    t = Getattr(p,"type");
	    if (t) {
	      tn = SwigType_base(t);
	      Replaceid(ss,tmp,tn);
	      Delete(tn);
	    } else {
	      String *v = Getattr(p,"value");
	      Replaceid(ss,tmp,v);
	    }
	    i++;
	    p = nextSibling(p);
	  }
	  if (template_debug) {
	    Printf(stdout,"    searching: '%s' (partial specialization)\n", ss);
	    if ((Strcmp(ss,tname) == 0) || (Strcmp(ss,rname) == 0)) {
	      Printf(stdout,"    Match!\n");
	    }
	  }
	  if ((Strcmp(ss,tname) == 0) || (Strcmp(ss,rname) == 0)) {
	    Append(mpartials,s);
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
	Swig_warning(WARN_PARSE_TEMPLATE_AMBIG,cparse_file,cparse_line,"Instantiation of template %s is ambiguous. Using %s at %s:%d\n",
		     SwigType_namestr(tname), SwigType_namestr(Getattr(n,"name")), Getfile(n),Getline(n));
      }
    }
  }

  if (!n) {
    n = templ;
  }
  if (!n) {
      Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", name);
  } else  if (n && (Strcmp(nodeType(n),"template") != 0)) {
      Swig_error(cparse_file, cparse_line, "'%s' is not defined as a template. (%s)\n", name, nodeType(n));	  
      n = 0;
  }
 success:
  Delete(tname);
  Delete(rname);
  Delete(mpartials);
  if ((template_debug) && (n)) {
      Swig_print_node(n);
  }
  return n;
}


