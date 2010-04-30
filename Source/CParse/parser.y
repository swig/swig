/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * parser.y
 *
 * YACC parser for SWIG.   The grammar is a somewhat broken subset of C/C++.
 * This file is a bit of a mess and probably needs to be rewritten at
 * some point.  Beware.
 * ----------------------------------------------------------------------------- */

%{

#define yylex yylex

char cvsroot_parser_y[] = "$Id$";

#include "swig.h"
#include "cparse.h"
#include "preprocessor.h"
#include <ctype.h>

/* We do this for portability */
#undef alloca
#define alloca malloc

/* -----------------------------------------------------------------------------
 *                               Externals
 * ----------------------------------------------------------------------------- */

int  yyparse();

/* NEW Variables */

static Node    *top = 0;      /* Top of the generated parse tree */
static int      unnamed = 0;  /* Unnamed datatype counter */
static Hash    *extendhash = 0;     /* Hash table of added methods */
static Hash    *classes = 0;        /* Hash table of classes */
static Symtab  *prev_symtab = 0;
static Node    *current_class = 0;
String  *ModuleName = 0;
static Node    *module_node = 0;
static String  *Classprefix = 0;  
static String  *Namespaceprefix = 0;
static int      inclass = 0;
static int      nested_template = 0; /* template class/function definition within a class */
static char    *last_cpptype = 0;
static int      inherit_list = 0;
static Parm    *template_parameters = 0;
static int      extendmode   = 0;
static int      compact_default_args = 0;
static int      template_reduce = 0;
static int      cparse_externc = 0;

static int      max_class_levels = 0;
static int      class_level = 0;
static Node   **class_decl = NULL;

/* -----------------------------------------------------------------------------
 *                            Assist Functions
 * ----------------------------------------------------------------------------- */


 
/* Called by the parser (yyparse) when an error is found.*/
static void yyerror (const char *e) {
  (void)e;
}

static Node *new_node(const_String_or_char_ptr tag) {
  Node *n = NewHash();
  set_nodeType(n,tag);
  Setfile(n,cparse_file);
  Setline(n,cparse_line);
  return n;
}

/* Copies a node.  Does not copy tree links or symbol table data (except for
   sym:name) */

static Node *copy_node(Node *n) {
  Node *nn;
  Iterator k;
  nn = NewHash();
  Setfile(nn,Getfile(n));
  Setline(nn,Getline(n));
  for (k = First(n); k.key; k = Next(k)) {
    String *ci;
    String *key = k.key;
    char *ckey = Char(key);
    if ((strcmp(ckey,"nextSibling") == 0) ||
	(strcmp(ckey,"previousSibling") == 0) ||
	(strcmp(ckey,"parentNode") == 0) ||
	(strcmp(ckey,"lastChild") == 0)) {
      continue;
    }
    if (Strncmp(key,"csym:",5) == 0) continue;
    /* We do copy sym:name.  For templates */
    if ((strcmp(ckey,"sym:name") == 0) || 
	(strcmp(ckey,"sym:weak") == 0) ||
	(strcmp(ckey,"sym:typename") == 0)) {
      String *ci = Copy(k.item);
      Setattr(nn,key, ci);
      Delete(ci);
      continue;
    }
    if (strcmp(ckey,"sym:symtab") == 0) {
      Setattr(nn,"sym:needs_symtab", "1");
    }
    /* We don't copy any other symbol table attributes */
    if (strncmp(ckey,"sym:",4) == 0) {
      continue;
    }
    /* If children.  We copy them recursively using this function */
    if (strcmp(ckey,"firstChild") == 0) {
      /* Copy children */
      Node *cn = k.item;
      while (cn) {
	Node *copy = copy_node(cn);
	appendChild(nn,copy);
	Delete(copy);
	cn = nextSibling(cn);
      }
      continue;
    }
    /* We don't copy the symbol table.  But we drop an attribute 
       requires_symtab so that functions know it needs to be built */

    if (strcmp(ckey,"symtab") == 0) {
      /* Node defined a symbol table. */
      Setattr(nn,"requires_symtab","1");
      continue;
    }
    /* Can't copy nodes */
    if (strcmp(ckey,"node") == 0) {
      continue;
    }
    if ((strcmp(ckey,"parms") == 0) || (strcmp(ckey,"pattern") == 0) || (strcmp(ckey,"throws") == 0)
	|| (strcmp(ckey,"kwargs") == 0)) {
      ParmList *pl = CopyParmList(k.item);
      Setattr(nn,key,pl);
      Delete(pl);
      continue;
    }
    /* Looks okay.  Just copy the data using Copy */
    ci = Copy(k.item);
    Setattr(nn, key, ci);
    Delete(ci);
  }
  return nn;
}

/* -----------------------------------------------------------------------------
 *                              Variables
 * ----------------------------------------------------------------------------- */

static char  *typemap_lang = 0;    /* Current language setting */

static int cplus_mode  = 0;
static String  *class_rename = 0;

/* C++ modes */

#define  CPLUS_PUBLIC    1
#define  CPLUS_PRIVATE   2
#define  CPLUS_PROTECTED 3

/* include types */
static int   import_mode = 0;

void SWIG_typemap_lang(const char *tm_lang) {
  typemap_lang = Swig_copy_string(tm_lang);
}

void SWIG_cparse_set_compact_default_args(int defargs) {
  compact_default_args = defargs;
}

int SWIG_cparse_template_reduce(int treduce) {
  template_reduce = treduce;
  return treduce;  
}

/* -----------------------------------------------------------------------------
 *                           Assist functions
 * ----------------------------------------------------------------------------- */

static int promote_type(int t) {
  if (t <= T_UCHAR || t == T_CHAR) return T_INT;
  return t;
}

/* Perform type-promotion for binary operators */
static int promote(int t1, int t2) {
  t1 = promote_type(t1);
  t2 = promote_type(t2);
  return t1 > t2 ? t1 : t2;
}

static String *yyrename = 0;

/* Forward renaming operator */

static String *resolve_node_scope(String *cname);


Hash *Swig_cparse_features(void) {
  static Hash   *features_hash = 0;
  if (!features_hash) features_hash = NewHash();
  return features_hash;
}

static String *feature_identifier_fix(String *s) {
  String *tp = SwigType_istemplate_templateprefix(s);
  if (tp) {
    String *ts, *ta, *tq;
    ts = SwigType_templatesuffix(s);
    ta = SwigType_templateargs(s);
    tq = Swig_symbol_type_qualify(ta,0);
    Append(tp,tq);
    Append(tp,ts);
    Delete(ts);
    Delete(ta);
    Delete(tq);
    return tp;
  } else {
    return NewString(s);
  }
}

/* Generate the symbol table name for an object */
/* This is a bit of a mess. Need to clean up */
static String *add_oldname = 0;



static String *make_name(Node *n, String *name,SwigType *decl) {
  int destructor = name && (*(Char(name)) == '~');

  if (yyrename) {
    String *s = NewString(yyrename);
    Delete(yyrename);
    yyrename = 0;
    if (destructor  && (*(Char(s)) != '~')) {
      Insert(s,0,"~");
    }
    return s;
  }

  if (!name) return 0;
  return Swig_name_make(n,Namespaceprefix,name,decl,add_oldname);
}

/* Generate an unnamed identifier */
static String *make_unnamed() {
  unnamed++;
  return NewStringf("$unnamed%d$",unnamed);
}

/* Return if the node is a friend declaration */
static int is_friend(Node *n) {
  return Cmp(Getattr(n,"storage"),"friend") == 0;
}

static int is_operator(String *name) {
  return Strncmp(name,"operator ", 9) == 0;
}


/* Add declaration list to symbol table */
static int  add_only_one = 0;

static void add_symbols(Node *n) {
  String *decl;
  String *wrn = 0;

  if (nested_template) {
    if (!(n && Equal(nodeType(n), "template"))) {
      return;
    }
    /* continue if template function, but not template class, declared within a class */
  }

  if (inclass && n) {
    cparse_normalize_void(n);
  }
  while (n) {
    String *symname = 0;
    /* for friends, we need to pop the scope once */
    String *old_prefix = 0;
    Symtab *old_scope = 0;
    int isfriend = inclass && is_friend(n);
    int iscdecl = Cmp(nodeType(n),"cdecl") == 0;
    int only_csymbol = 0;
    if (extendmode) {
      Setattr(n,"isextension","1");
    }
    
    if (inclass) {
      String *name = Getattr(n, "name");
      if (isfriend) {
	/* for friends, we need to add the scopename if needed */
	String *prefix = name ? Swig_scopename_prefix(name) : 0;
	old_prefix = Namespaceprefix;
	old_scope = Swig_symbol_popscope();
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	if (!prefix) {
	  if (name && !is_operator(name) && Namespaceprefix) {
	    String *nname = NewStringf("%s::%s", Namespaceprefix, name);
	    Setattr(n,"name",nname);
	    Delete(nname);
	  }
	} else {
	  Symtab *st = Swig_symbol_getscope(prefix);
	  String *ns = st ? Getattr(st,"name") : prefix;
	  String *base  = Swig_scopename_last(name);
	  String *nname = NewStringf("%s::%s", ns, base);
	  Setattr(n,"name",nname);
	  Delete(nname);
	  Delete(base);
	  Delete(prefix);
	}
	Namespaceprefix = 0;
      } else {
	/* for member functions, we need to remove the redundant
	   class scope if provided, as in
	   
	   struct Foo {
	   int Foo::method(int a);
	   };
	   
	*/
	String *prefix = name ? Swig_scopename_prefix(name) : 0;
	if (prefix) {
	  if (Classprefix && (Equal(prefix,Classprefix))) {
	    String *base = Swig_scopename_last(name);
	    Setattr(n,"name",base);
	    Delete(base);
	  }
	  Delete(prefix);
	}

        /*
	if (!Getattr(n,"parentNode") && class_level) set_parentNode(n,class_decl[class_level - 1]);
        */
	Setattr(n,"ismember","1");
      }
    }
    if (!isfriend && inclass) {
      if ((cplus_mode != CPLUS_PUBLIC)) {
	only_csymbol = 1;
	if (cplus_mode == CPLUS_PROTECTED) {
	  Setattr(n,"access", "protected");
	  only_csymbol = !Swig_need_protected(n);
	} else {
	  Setattr(n,"access", "private");
	  /* private are needed only when they are pure virtuals - why? */
	  if ((Cmp(Getattr(n,"storage"),"virtual") == 0) && (Cmp(Getattr(n,"value"),"0") == 0)) {
	    only_csymbol = 0;
	  }
	}
      } else {
	  Setattr(n,"access", "public");
      }
    }
    if (Getattr(n,"sym:name")) {
      n = nextSibling(n);
      continue;
    }
    decl = Getattr(n,"decl");
    if (!SwigType_isfunction(decl)) {
      String *name = Getattr(n,"name");
      String *makename = Getattr(n,"parser:makename");
      if (iscdecl) {	
	String *storage = Getattr(n, "storage");
	if (Cmp(storage,"typedef") == 0) {
	  Setattr(n,"kind","typedef");
	} else {
	  SwigType *type = Getattr(n,"type");
	  String *value = Getattr(n,"value");
	  Setattr(n,"kind","variable");
	  if (value && Len(value)) {
	    Setattr(n,"hasvalue","1");
	  }
	  if (type) {
	    SwigType *ty;
	    SwigType *tmp = 0;
	    if (decl) {
	      ty = tmp = Copy(type);
	      SwigType_push(ty,decl);
	    } else {
	      ty = type;
	    }
	    if (!SwigType_ismutable(ty)) {
	      SetFlag(n,"hasconsttype");
	      SetFlag(n,"feature:immutable");
	    }
	    if (tmp) Delete(tmp);
	  }
	  if (!type) {
	    Printf(stderr,"notype name %s\n", name);
	  }
	}
      }
      Swig_features_get(Swig_cparse_features(), Namespaceprefix, name, 0, n);
      if (makename) {
	symname = make_name(n, makename,0);
        Delattr(n,"parser:makename"); /* temporary information, don't leave it hanging around */
      } else {
        makename = name;
	symname = make_name(n, makename,0);
      }
      
      if (!symname) {
	symname = Copy(Getattr(n,"unnamed"));
      }
      if (symname) {
	wrn = Swig_name_warning(n, Namespaceprefix, symname,0);
      }
    } else {
      String *name = Getattr(n,"name");
      SwigType *fdecl = Copy(decl);
      SwigType *fun = SwigType_pop_function(fdecl);
      if (iscdecl) {	
	Setattr(n,"kind","function");
      }
      
      Swig_features_get(Swig_cparse_features(),Namespaceprefix,name,fun,n);

      symname = make_name(n, name,fun);
      wrn = Swig_name_warning(n, Namespaceprefix,symname,fun);
      
      Delete(fdecl);
      Delete(fun);
      
    }
    if (!symname) {
      n = nextSibling(n);
      continue;
    }
    if (only_csymbol || GetFlag(n,"feature:ignore")) {
      /* Only add to C symbol table and continue */
      Swig_symbol_add(0, n);
    } else if (strncmp(Char(symname),"$ignore",7) == 0) {
      char *c = Char(symname)+7;
      SetFlag(n,"feature:ignore");
      if (strlen(c)) {
	SWIG_WARN_NODE_BEGIN(n);
	Swig_warning(0,Getfile(n), Getline(n), "%s\n",c+1);
	SWIG_WARN_NODE_END(n);
      }
      Swig_symbol_add(0, n);
    } else {
      Node *c;
      if ((wrn) && (Len(wrn))) {
	String *metaname = symname;
	if (!Getmeta(metaname,"already_warned")) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(0,Getfile(n),Getline(n), "%s\n", wrn);
	  SWIG_WARN_NODE_END(n);
	  Setmeta(metaname,"already_warned","1");
	}
      }
      c = Swig_symbol_add(symname,n);

      if (c != n) {
        /* symbol conflict attempting to add in the new symbol */
        if (Getattr(n,"sym:weak")) {
          Setattr(n,"sym:name",symname);
        } else {
          String *e = NewStringEmpty();
          String *en = NewStringEmpty();
          String *ec = NewStringEmpty();
          int redefined = Swig_need_redefined_warn(n,c,inclass);
          if (redefined) {
            Printf(en,"Identifier '%s' redefined (ignored)",symname);
            Printf(ec,"previous definition of '%s'",symname);
          } else {
            Printf(en,"Redundant redeclaration of '%s'",symname);
            Printf(ec,"previous declaration of '%s'",symname);
          }
          if (Cmp(symname,Getattr(n,"name"))) {
            Printf(en," (Renamed from '%s')", SwigType_namestr(Getattr(n,"name")));
          }
          Printf(en,",");
          if (Cmp(symname,Getattr(c,"name"))) {
            Printf(ec," (Renamed from '%s')", SwigType_namestr(Getattr(c,"name")));
          }
          Printf(ec,".");
	  SWIG_WARN_NODE_BEGIN(n);
          if (redefined) {
            Swig_warning(WARN_PARSE_REDEFINED,Getfile(n),Getline(n),"%s\n",en);
            Swig_warning(WARN_PARSE_REDEFINED,Getfile(c),Getline(c),"%s\n",ec);
          } else if (!is_friend(n) && !is_friend(c)) {
            Swig_warning(WARN_PARSE_REDUNDANT,Getfile(n),Getline(n),"%s\n",en);
            Swig_warning(WARN_PARSE_REDUNDANT,Getfile(c),Getline(c),"%s\n",ec);
          }
	  SWIG_WARN_NODE_END(n);
          Printf(e,"%s:%d:%s\n%s:%d:%s\n",Getfile(n),Getline(n),en,
                 Getfile(c),Getline(c),ec);
          Setattr(n,"error",e);
	  Delete(e);
          Delete(en);
          Delete(ec);
        }
      }
    }
    /* restore the class scope if needed */
    if (isfriend) {
      Swig_symbol_setscope(old_scope);
      if (old_prefix) {
	Delete(Namespaceprefix);
	Namespaceprefix = old_prefix;
      }
    }
    Delete(symname);

    if (add_only_one) return;
    n = nextSibling(n);
  }
}


/* add symbols a parse tree node copy */

static void add_symbols_copy(Node *n) {
  String *name;
  int    emode = 0;
  while (n) {
    char *cnodeType = Char(nodeType(n));

    if (strcmp(cnodeType,"access") == 0) {
      String *kind = Getattr(n,"kind");
      if (Strcmp(kind,"public") == 0) {
	cplus_mode = CPLUS_PUBLIC;
      } else if (Strcmp(kind,"private") == 0) {
	cplus_mode = CPLUS_PRIVATE;
      } else if (Strcmp(kind,"protected") == 0) {
	cplus_mode = CPLUS_PROTECTED;
      }
      n = nextSibling(n);
      continue;
    }

    add_oldname = Getattr(n,"sym:name");
    if ((add_oldname) || (Getattr(n,"sym:needs_symtab"))) {
      int old_inclass = -1;
      Node *old_current_class = 0;
      if (add_oldname) {
	DohIncref(add_oldname);
	/*  Disable this, it prevents %rename to work with templates */
	/* If already renamed, we used that name  */
	/*
	if (Strcmp(add_oldname, Getattr(n,"name")) != 0) {
	  Delete(yyrename);
	  yyrename = Copy(add_oldname);
	}
	*/
      }
      Delattr(n,"sym:needs_symtab");
      Delattr(n,"sym:name");

      add_only_one = 1;
      add_symbols(n);

      if (Getattr(n,"partialargs")) {
	Swig_symbol_cadd(Getattr(n,"partialargs"),n);
      }
      add_only_one = 0;
      name = Getattr(n,"name");
      if (Getattr(n,"requires_symtab")) {
	Swig_symbol_newscope();
	Swig_symbol_setscopename(name);
	Delete(Namespaceprefix);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
      }
      if (strcmp(cnodeType,"class") == 0) {
	old_inclass = inclass;
	inclass = 1;
	old_current_class = current_class;
	current_class = n;
	if (Strcmp(Getattr(n,"kind"),"class") == 0) {
	  cplus_mode = CPLUS_PRIVATE;
	} else {
	  cplus_mode = CPLUS_PUBLIC;
	}
      }
      if (strcmp(cnodeType,"extend") == 0) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }
      add_symbols_copy(firstChild(n));
      if (strcmp(cnodeType,"extend") == 0) {
	cplus_mode = emode;
      }
      if (Getattr(n,"requires_symtab")) {
	Setattr(n,"symtab", Swig_symbol_popscope());
	Delattr(n,"requires_symtab");
	Delete(Namespaceprefix);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
      }
      if (add_oldname) {
	Delete(add_oldname);
	add_oldname = 0;
      }
      if (strcmp(cnodeType,"class") == 0) {
	inclass = old_inclass;
	current_class = old_current_class;
      }
    } else {
      if (strcmp(cnodeType,"extend") == 0) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }
      add_symbols_copy(firstChild(n));
      if (strcmp(cnodeType,"extend") == 0) {
	cplus_mode = emode;
      }
    }
    n = nextSibling(n);
  }
}

/* Extension merge.  This function is used to handle the %extend directive
   when it appears before a class definition.   To handle this, the %extend
   actually needs to take precedence.  Therefore, we will selectively nuke symbols
   from the current symbol table, replacing them with the added methods */

static void merge_extensions(Node *cls, Node *am) {
  Node *n;
  Node *csym;

  n = firstChild(am);
  while (n) {
    String *symname;
    if (Strcmp(nodeType(n),"constructor") == 0) {
      symname = Getattr(n,"sym:name");
      if (symname) {
	if (Strcmp(symname,Getattr(n,"name")) == 0) {
	  /* If the name and the sym:name of a constructor are the same,
             then it hasn't been renamed.  However---the name of the class
             itself might have been renamed so we need to do a consistency
             check here */
	  if (Getattr(cls,"sym:name")) {
	    Setattr(n,"sym:name", Getattr(cls,"sym:name"));
	  }
	}
      } 
    }

    symname = Getattr(n,"sym:name");
    DohIncref(symname);
    if ((symname) && (!Getattr(n,"error"))) {
      /* Remove node from its symbol table */
      Swig_symbol_remove(n);
      csym = Swig_symbol_add(symname,n);
      if (csym != n) {
	/* Conflict with previous definition.  Nuke previous definition */
	String *e = NewStringEmpty();
	String *en = NewStringEmpty();
	String *ec = NewStringEmpty();
	Printf(ec,"Identifier '%s' redefined by %%extend (ignored),",symname);
	Printf(en,"%%extend definition of '%s'.",symname);
	SWIG_WARN_NODE_BEGIN(n);
	Swig_warning(WARN_PARSE_REDEFINED,Getfile(csym),Getline(csym),"%s\n",ec);
	Swig_warning(WARN_PARSE_REDEFINED,Getfile(n),Getline(n),"%s\n",en);
	SWIG_WARN_NODE_END(n);
	Printf(e,"%s:%d:%s\n%s:%d:%s\n",Getfile(csym),Getline(csym),ec, 
	       Getfile(n),Getline(n),en);
	Setattr(csym,"error",e);
	Delete(e);
	Delete(en);
	Delete(ec);
	Swig_symbol_remove(csym);              /* Remove class definition */
	Swig_symbol_add(symname,n);            /* Insert extend definition */
      }
    }
    n = nextSibling(n);
  }
}

static void append_previous_extension(Node *cls, Node *am) {
  Node *n, *ne;
  Node *pe = 0;
  Node *ae = 0;

  if (!am) return;
  
  n = firstChild(am);
  while (n) {
    ne = nextSibling(n);
    set_nextSibling(n,0);
    /* typemaps and fragments need to be prepended */
    if (((Cmp(nodeType(n),"typemap") == 0) || (Cmp(nodeType(n),"fragment") == 0)))  {
      if (!pe) pe = new_node("extend");
      appendChild(pe, n);
    } else {
      if (!ae) ae = new_node("extend");
      appendChild(ae, n);
    }    
    n = ne;
  }
  if (pe) prependChild(cls,pe);
  if (ae) appendChild(cls,ae);
}
 

/* Check for unused %extend.  Special case, don't report unused
   extensions for templates */
 
static void check_extensions() {
  Iterator ki;

  if (!extendhash) return;
  for (ki = First(extendhash); ki.key; ki = Next(ki)) {
    if (!Strchr(ki.key,'<')) {
      SWIG_WARN_NODE_BEGIN(ki.item);
      Swig_warning(WARN_PARSE_EXTEND_UNDEF,Getfile(ki.item), Getline(ki.item), "%%extend defined for an undeclared class %s.\n", ki.key);
      SWIG_WARN_NODE_END(ki.item);
    }
  }
}

/* Check a set of declarations to see if any are pure-abstract */

static List *pure_abstract(Node *n) {
  List *abs = 0;
  while (n) {
    if (Cmp(nodeType(n),"cdecl") == 0) {
      String *decl = Getattr(n,"decl");
      if (SwigType_isfunction(decl)) {
	String *init = Getattr(n,"value");
	if (Cmp(init,"0") == 0) {
	  if (!abs) {
	    abs = NewList();
	  }
	  Append(abs,n);
	  Setattr(n,"abstract","1");
	}
      }
    } else if (Cmp(nodeType(n),"destructor") == 0) {
      if (Cmp(Getattr(n,"value"),"0") == 0) {
	if (!abs) {
	  abs = NewList();
	}
	Append(abs,n);
	Setattr(n,"abstract","1");
      }
    }
    n = nextSibling(n);
  }
  return abs;
}

/* Make a classname */

static String *make_class_name(String *name) {
  String *nname = 0;
  String *prefix;
  if (Namespaceprefix) {
    nname= NewStringf("%s::%s", Namespaceprefix, name);
  } else {
    nname = NewString(name);
  }
  prefix = SwigType_istemplate_templateprefix(nname);
  if (prefix) {
    String *args, *qargs;
    args   = SwigType_templateargs(nname);
    qargs  = Swig_symbol_type_qualify(args,0);
    Append(prefix,qargs);
    Delete(nname);
    Delete(args);
    Delete(qargs);
    nname = prefix;
  }
  return nname;
}

static List *make_inherit_list(String *clsname, List *names) {
  int i, ilen;
  String *derived;
  List *bases = NewList();

  if (Namespaceprefix) derived = NewStringf("%s::%s", Namespaceprefix,clsname);
  else derived = NewString(clsname);

  ilen = Len(names);
  for (i = 0; i < ilen; i++) {
    Node *s;
    String *base;
    String *n = Getitem(names,i);
    /* Try to figure out where this symbol is */
    s = Swig_symbol_clookup(n,0);
    if (s) {
      while (s && (Strcmp(nodeType(s),"class") != 0)) {
	/* Not a class.  Could be a typedef though. */
	String *storage = Getattr(s,"storage");
	if (storage && (Strcmp(storage,"typedef") == 0)) {
	  String *nn = Getattr(s,"type");
	  s = Swig_symbol_clookup(nn,Getattr(s,"sym:symtab"));
	} else {
	  break;
	}
      }
      if (s && ((Strcmp(nodeType(s),"class") == 0) || (Strcmp(nodeType(s),"template") == 0))) {
	String *q = Swig_symbol_qualified(s);
	Append(bases,s);
	if (q) {
	  base = NewStringf("%s::%s", q, Getattr(s,"name"));
	  Delete(q);
	} else {
	  base = NewString(Getattr(s,"name"));
	}
      } else {
	base = NewString(n);
      }
    } else {
      base = NewString(n);
    }
    if (base) {
      Swig_name_inherit(base,derived);
      Delete(base);
    }
  }
  return bases;
}

/* If the class name is qualified.  We need to create or lookup namespace entries */

static Symtab *set_scope_to_global() {
  Symtab *symtab = Swig_symbol_global_scope();
  Swig_symbol_setscope(symtab);
  return symtab;
}
 
/* Remove the block braces, { and }, if the 'noblock' attribute is set.
 * Node *kw can be either a Hash or Parmlist. */
static String *remove_block(Node *kw, const String *inputcode) {
  String *modified_code = 0;
  while (kw) {
   String *name = Getattr(kw,"name");
   if (name && (Cmp(name,"noblock") == 0)) {
     char *cstr = Char(inputcode);
     size_t len = Len(inputcode);
     if (len && cstr[0] == '{') {
       --len; ++cstr; 
       if (len && cstr[len - 1] == '}') { --len; }
       /* we now remove the extra spaces */
       while (len && isspace((int)cstr[0])) { --len; ++cstr; }
       while (len && isspace((int)cstr[len - 1])) { --len; }
       modified_code = NewStringWithSize(cstr, len);
       break;
     }
   }
   kw = nextSibling(kw);
  }
  return modified_code;
}


static Node *nscope = 0;
static Node *nscope_inner = 0;

/* Remove the scope prefix from cname and return the base name without the prefix.
 * The scopes specified in the prefix are found, or created in the current namespace.
 * So ultimately the scope is changed to that required for the base name.
 * For example AA::BB::CC as input returns CC and creates the namespace AA then inner 
 * namespace BB in the current scope. If no scope separator (::) in the input, then nothing happens! */
static String *resolve_node_scope(String *cname) {
  Symtab *gscope = 0;
  nscope = 0;
  nscope_inner = 0;  
  if (Swig_scopename_check(cname)) {
    Node   *ns;
    String *prefix = Swig_scopename_prefix(cname);
    String *base = Swig_scopename_last(cname);
    if (prefix && (Strncmp(prefix,"::",2) == 0)) {
      /* Use the global scope */
      String *nprefix = NewString(Char(prefix)+2);
      Delete(prefix);
      prefix= nprefix;
      gscope = set_scope_to_global();
    }    
    if (!prefix || (Len(prefix) == 0)) {
      /* Use the global scope, but we need to add a 'global' namespace.  */
      if (!gscope) gscope = set_scope_to_global();
      /* note that this namespace is not the "unnamed" one,
	 and we don't use Setattr(nscope,"name", ""),
	 because the unnamed namespace is private */
      nscope = new_node("namespace");
      Setattr(nscope,"symtab", gscope);;
      nscope_inner = nscope;
      return base;
    }
    /* Try to locate the scope */
    ns = Swig_symbol_clookup(prefix,0);
    if (!ns) {
      Swig_error(cparse_file,cparse_line,"Undefined scope '%s'\n", prefix);
    } else {
      Symtab *nstab = Getattr(ns,"symtab");
      if (!nstab) {
	Swig_error(cparse_file,cparse_line,
		   "'%s' is not defined as a valid scope.\n", prefix);
	ns = 0;
      } else {
	/* Check if the node scope is the current scope */
	String *tname = Swig_symbol_qualifiedscopename(0);
	String *nname = Swig_symbol_qualifiedscopename(nstab);
	if (tname && (Strcmp(tname,nname) == 0)) {
	  ns = 0;
	  cname = base;
	}
	Delete(tname);
	Delete(nname);
      }
      if (ns) {
	/* we will try to create a new node using the namespaces we
	   can find in the scope name */
	List *scopes;
	String *sname;
	Iterator si;
	String *name = NewString(prefix);
	scopes = NewList();
	while (name) {
	  String *base = Swig_scopename_last(name);
	  String *tprefix = Swig_scopename_prefix(name);
	  Insert(scopes,0,base);
	  Delete(base);
	  Delete(name);
	  name = tprefix;
	}
	for (si = First(scopes); si.item; si = Next(si)) {
	  Node *ns1,*ns2;
	  sname = si.item;
	  ns1 = Swig_symbol_clookup(sname,0);
	  assert(ns1);
	  if (Strcmp(nodeType(ns1),"namespace") == 0) {
	    if (Getattr(ns1,"alias")) {
	      ns1 = Getattr(ns1,"namespace");
	    }
	  } else {
	    /* now this last part is a class */
	    si = Next(si);
	    ns1 = Swig_symbol_clookup(sname,0);
	    /*  or a nested class tree, which is unrolled here */
	    for (; si.item; si = Next(si)) {
	      if (si.item) {
		Printf(sname,"::%s",si.item);
	      }
	    }
	    /* we get the 'inner' class */
	    nscope_inner = Swig_symbol_clookup(sname,0);
	    /* set the scope to the inner class */
	    Swig_symbol_setscope(Getattr(nscope_inner,"symtab"));
	    /* save the last namespace prefix */
	    Delete(Namespaceprefix);
	    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	    /* and return the node name, including the inner class prefix */
	    break;
	  }
	  /* here we just populate the namespace tree as usual */
	  ns2 = new_node("namespace");
	  Setattr(ns2,"name",sname);
	  Setattr(ns2,"symtab", Getattr(ns1,"symtab"));
	  add_symbols(ns2);
	  Swig_symbol_setscope(Getattr(ns1,"symtab"));
	  Delete(Namespaceprefix);
	  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	  if (nscope_inner) {
	    if (Getattr(nscope_inner,"symtab") != Getattr(ns2,"symtab")) {
	      appendChild(nscope_inner,ns2);
	      Delete(ns2);
	    }
	  }
	  nscope_inner = ns2;
	  if (!nscope) nscope = ns2;
	}
	cname = base;
	Delete(scopes);
      }
    }
    Delete(prefix);
  }
  return cname;
}
 


/* Structures for handling code fragments built for nested classes */

typedef struct Nested {
  String   *code;        /* Associated code fragment */
  int      line;         /* line number where it starts */
  const char *name;      /* Name associated with this nested class */
  const char *kind;      /* Kind of class */
  int      unnamed;      /* unnamed class */
  SwigType *type;        /* Datatype associated with the name */
  struct Nested   *next; /* Next code fragment in list */
} Nested;

/* Some internal variables for saving nested class information */

static Nested      *nested_list = 0;

/* Add a function to the nested list */

static void add_nested(Nested *n) {
  if (!nested_list) {
    nested_list = n;
  } else {
    Nested *n1 = nested_list;
    while (n1->next)
      n1 = n1->next;
    n1->next = n;
  }
}

/* -----------------------------------------------------------------------------
 * nested_new_struct()
 *
 * Nested struct handling for C code only creates a global struct from the nested struct.
 *
 * Nested structure. This is a sick "hack". If we encounter
 * a nested structure, we're going to grab the text of its definition and
 * feed it back into the scanner.  In the meantime, we need to grab
 * variable declaration information and generate the associated wrapper
 * code later.  Yikes!
 *
 * This really only works in a limited sense.   Since we use the
 * code attached to the nested class to generate both C code
 * it can't have any SWIG directives in it.  It also needs to be parsable
 * by SWIG or this whole thing is going to puke.
 * ----------------------------------------------------------------------------- */

static void nested_new_struct(const char *kind, String *struct_code, Node *cpp_opt_declarators) {
  String *name;
  String *decl;

  /* Create a new global struct declaration which is just a copy of the nested struct */
  Nested *nested = (Nested *) malloc(sizeof(Nested));
  Nested *n = nested;

  name = Getattr(cpp_opt_declarators, "name");
  decl = Getattr(cpp_opt_declarators, "decl");

  n->code = NewStringEmpty();
  Printv(n->code, "typedef ", kind, " ", struct_code, " $classname_", name, ";\n", NIL);
  n->name = Swig_copy_string(Char(name));
  n->line = cparse_start_line;
  n->type = NewStringEmpty();
  n->kind = kind;
  n->unnamed = 0;
  SwigType_push(n->type, decl);
  n->next = 0;

  /* Repeat for any multiple instances of the nested struct */
  {
    Node *p = cpp_opt_declarators;
    p = nextSibling(p);
    while (p) {
      Nested *nn = (Nested *) malloc(sizeof(Nested));

      name = Getattr(p, "name");
      decl = Getattr(p, "decl");

      nn->code = NewStringEmpty();
      Printv(nn->code, "typedef ", kind, " ", struct_code, " $classname_", name, ";\n", NIL);
      nn->name = Swig_copy_string(Char(name));
      nn->line = cparse_start_line;
      nn->type = NewStringEmpty();
      nn->kind = kind;
      nn->unnamed = 0;
      SwigType_push(nn->type, decl);
      nn->next = 0;
      n->next = nn;
      n = nn;
      p = nextSibling(p);
    }
  }

  add_nested(nested);
}

/* -----------------------------------------------------------------------------
 * nested_forward_declaration()
 * 
 * Nested struct handling for C++ code only.
 *
 * Treat the nested class/struct/union as a forward declaration until a proper 
 * nested class solution is implemented.
 * ----------------------------------------------------------------------------- */

static Node *nested_forward_declaration(const char *storage, const char *kind, String *sname, const char *name, Node *cpp_opt_declarators) {
  Node *nn = 0;
  int warned = 0;

  if (sname) {
    /* Add forward declaration of the nested type */
    Node *n = new_node("classforward");
    Setfile(n, cparse_file);
    Setline(n, cparse_line);
    Setattr(n, "kind", kind);
    Setattr(n, "name", sname);
    Setattr(n, "storage", storage);
    Setattr(n, "sym:weak", "1");
    add_symbols(n);
    nn = n;
  }

  /* Add any variable instances. Also add in any further typedefs of the nested type.
     Note that anonymous typedefs (eg typedef struct {...} a, b;) are treated as class forward declarations */
  if (cpp_opt_declarators) {
    int storage_typedef = (storage && (strcmp(storage, "typedef") == 0));
    int variable_of_anonymous_type = !sname && !storage_typedef;
    if (!variable_of_anonymous_type) {
      int anonymous_typedef = !sname && (storage && (strcmp(storage, "typedef") == 0));
      Node *n = cpp_opt_declarators;
      SwigType *type = NewString(name);
      while (n) {
	Setattr(n, "type", type);
	Setattr(n, "storage", storage);
	if (anonymous_typedef) {
	  Setattr(n, "nodeType", "classforward");
	  Setattr(n, "sym:weak", "1");
	}
	n = nextSibling(n);
      }
      Delete(type);
      add_symbols(cpp_opt_declarators);

      if (nn) {
	set_nextSibling(nn, cpp_opt_declarators);
      } else {
	nn = cpp_opt_declarators;
      }
    }
  }

  if (nn && Equal(nodeType(nn), "classforward")) {
    Node *n = nn;
    if (GetFlag(n, "feature:nestedworkaround")) {
      Swig_symbol_remove(n);
      nn = 0;
      warned = 1;
    } else {
      SWIG_WARN_NODE_BEGIN(n);
      Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line,"Nested %s not currently supported (%s ignored)\n", kind, sname ? sname : name);
      SWIG_WARN_NODE_END(n);
      warned = 1;
    }
  }

  if (!warned)
    Swig_warning(WARN_PARSE_UNNAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (ignored).\n", kind);

  return nn;
}

/* Strips C-style and C++-style comments from string in-place. */
static void strip_comments(char *string) {
  int state = 0; /* 
                  * 0 - not in comment
                  * 1 - in c-style comment
                  * 2 - in c++-style comment
                  * 3 - in string
                  * 4 - after reading / not in comments
                  * 5 - after reading * in c-style comments
                  * 6 - after reading \ in strings
                  */
  char * c = string;
  while (*c) {
    switch (state) {
    case 0:
      if (*c == '\"')
        state = 3;
      else if (*c == '/')
        state = 4;
      break;
    case 1:
      if (*c == '*')
        state = 5;
      *c = ' ';
      break;
    case 2:
      if (*c == '\n')
        state = 0;
      else
        *c = ' ';
      break;
    case 3:
      if (*c == '\"')
        state = 0;
      else if (*c == '\\')
        state = 6;
      break;
    case 4:
      if (*c == '/') {
        *(c-1) = ' ';
        *c = ' ';
        state = 2;
      } else if (*c == '*') {
        *(c-1) = ' ';
        *c = ' ';
        state = 1;
      } else
        state = 0;
      break;
    case 5:
      if (*c == '/')
        state = 0;
      else 
        state = 1;
      *c = ' ';
      break;
    case 6:
      state = 3;
      break;
    }
    ++c;
  }
}

/* Dump all of the nested class declarations to the inline processor
 * However.  We need to do a few name replacements and other munging
 * first.  This function must be called before closing a class! */

static Node *dump_nested(const char *parent) {
  Nested *n,*n1;
  Node *ret = 0;
  Node *last = 0;
  n = nested_list;
  if (!parent) {
    nested_list = 0;
    return 0;
  }
  while (n) {
    Node *retx;
    SwigType *nt;
    /* Token replace the name of the parent class */
    Replace(n->code, "$classname", parent, DOH_REPLACE_ANY);

    /* Fix up the name of the datatype (for building typedefs and other stuff) */
    Append(n->type,parent);
    Append(n->type,"_");
    Append(n->type,n->name);

    /* Add the appropriate declaration to the C++ processor */
    retx = new_node("cdecl");
    Setattr(retx,"name",n->name);
    nt = Copy(n->type);
    Setattr(retx,"type",nt);
    Delete(nt);
    Setattr(retx,"nested",parent);
    if (n->unnamed) {
      Setattr(retx,"unnamed","1");
    }
    
    add_symbols(retx);
    if (ret) {
      set_nextSibling(last, retx);
      Delete(retx);
    } else {
      ret = retx;
    }
    last = retx;

    /* Strip comments - further code may break in presence of comments. */
    strip_comments(Char(n->code));

    /* Make all SWIG created typedef structs/unions/classes unnamed else 
       redefinition errors occur - nasty hack alert.*/

    {
      const char* types_array[3] = {"struct", "union", "class"};
      int i;
      for (i=0; i<3; i++) {
	char* code_ptr = Char(n->code);
	while (code_ptr) {
	  /* Replace struct name (as in 'struct name {...}' ) with whitespace
	     name will be between struct and opening brace */
	
	  code_ptr = strstr(code_ptr, types_array[i]);
	  if (code_ptr) {
	    char *open_bracket_pos;
	    code_ptr += strlen(types_array[i]);
	    open_bracket_pos = strchr(code_ptr, '{');
	    if (open_bracket_pos) { 
	      /* Make sure we don't have something like struct A a; */
	      char* semi_colon_pos = strchr(code_ptr, ';');
	      if (!(semi_colon_pos && (semi_colon_pos < open_bracket_pos)))
		while (code_ptr < open_bracket_pos)
		  *code_ptr++ = ' ';
	    }
	  }
	}
      }
    }
    
    {
      /* Remove SWIG directive %constant which may be left in the SWIG created typedefs */
      char* code_ptr = Char(n->code);
      while (code_ptr) {
	code_ptr = strstr(code_ptr, "%constant");
	if (code_ptr) {
	  char* directive_end_pos = strchr(code_ptr, ';');
	  if (directive_end_pos) { 
            while (code_ptr <= directive_end_pos)
              *code_ptr++ = ' ';
	  }
	}
      }
    }
    {
      Node *newnode = new_node("insert");
      String *code = NewStringEmpty();
      Wrapper_pretty_print(n->code, code);
      Setattr(newnode,"code", code);
      Delete(code);
      set_nextSibling(last, newnode);
      Delete(newnode);      
      last = newnode;
    }
      
    /* Dump the code to the scanner */
    start_inline(Char(Getattr(last, "code")),n->line);

    n1 = n->next;
    Delete(n->code);
    free(n);
    n = n1;
  }
  nested_list = 0;
  return ret;
}

Node *Swig_cparse(File *f) {
  scanner_file(f);
  top = 0;
  yyparse();
  return top;
}

static void single_new_feature(const char *featurename, String *val, Hash *featureattribs, char *declaratorid, SwigType *type, ParmList *declaratorparms, String *qualifier) {
  String *fname;
  String *name;
  String *fixname;
  SwigType *t = Copy(type);

  /* Printf(stdout, "single_new_feature: [%s] [%s] [%s] [%s] [%s] [%s]\n", featurename, val, declaratorid, t, ParmList_str_defaultargs(declaratorparms), qualifier); */

  fname = NewStringf("feature:%s",featurename);
  if (declaratorid) {
    fixname = feature_identifier_fix(declaratorid);
  } else {
    fixname = NewStringEmpty();
  }
  if (Namespaceprefix) {
    name = NewStringf("%s::%s",Namespaceprefix, fixname);
  } else {
    name = fixname;
  }

  if (declaratorparms) Setmeta(val,"parms",declaratorparms);
  if (!Len(t)) t = 0;
  if (t) {
    if (qualifier) SwigType_push(t,qualifier);
    if (SwigType_isfunction(t)) {
      SwigType *decl = SwigType_pop_function(t);
      if (SwigType_ispointer(t)) {
	String *nname = NewStringf("*%s",name);
	Swig_feature_set(Swig_cparse_features(), nname, decl, fname, val, featureattribs);
	Delete(nname);
      } else {
	Swig_feature_set(Swig_cparse_features(), name, decl, fname, val, featureattribs);
      }
      Delete(decl);
    } else if (SwigType_ispointer(t)) {
      String *nname = NewStringf("*%s",name);
      Swig_feature_set(Swig_cparse_features(),nname,0,fname,val, featureattribs);
      Delete(nname);
    }
  } else {
    /* Global feature, that is, feature not associated with any particular symbol */
    Swig_feature_set(Swig_cparse_features(),name,0,fname,val, featureattribs);
  }
  Delete(fname);
  Delete(name);
}

/* Add a new feature to the Hash. Additional features are added if the feature has a parameter list (declaratorparms)
 * and one or more of the parameters have a default argument. An extra feature is added for each defaulted parameter,
 * simulating the equivalent overloaded method. */
static void new_feature(const char *featurename, String *val, Hash *featureattribs, char *declaratorid, SwigType *type, ParmList *declaratorparms, String *qualifier) {

  ParmList *declparms = declaratorparms;

  /* remove the { and } braces if the noblock attribute is set */
  String *newval = remove_block(featureattribs, val);
  val = newval ? newval : val;

  /* Add the feature */
  single_new_feature(featurename, val, featureattribs, declaratorid, type, declaratorparms, qualifier);

  /* Add extra features if there are default parameters in the parameter list */
  if (type) {
    while (declparms) {
      if (ParmList_has_defaultargs(declparms)) {

        /* Create a parameter list for the new feature by copying all
           but the last (defaulted) parameter */
        ParmList* newparms = CopyParmListMax(declparms, ParmList_len(declparms)-1);

        /* Create new declaration - with the last parameter removed */
        SwigType *newtype = Copy(type);
        Delete(SwigType_pop_function(newtype)); /* remove the old parameter list from newtype */
        SwigType_add_function(newtype,newparms);

        single_new_feature(featurename, Copy(val), featureattribs, declaratorid, newtype, newparms, qualifier);
        declparms = newparms;
      } else {
        declparms = 0;
      }
    }
  }
}

/* check if a function declaration is a plain C object */
static int is_cfunction(Node *n) {
  if (!cparse_cplusplus || cparse_externc) return 1;
  if (Cmp(Getattr(n,"storage"),"externc") == 0) {
    return 1;
  }
  return 0;
}

/* If the Node is a function with parameters, check to see if any of the parameters
 * have default arguments. If so create a new function for each defaulted argument. 
 * The additional functions form a linked list of nodes with the head being the original Node n. */
static void default_arguments(Node *n) {
  Node *function = n;

  if (function) {
    ParmList *varargs = Getattr(function,"feature:varargs");
    if (varargs) {
      /* Handles the %varargs directive by looking for "feature:varargs" and 
       * substituting ... with an alternative set of arguments.  */
      Parm     *p = Getattr(function,"parms");
      Parm     *pp = 0;
      while (p) {
	SwigType *t = Getattr(p,"type");
	if (Strcmp(t,"v(...)") == 0) {
	  if (pp) {
	    ParmList *cv = Copy(varargs);
	    set_nextSibling(pp,cv);
	    Delete(cv);
	  } else {
	    ParmList *cv =  Copy(varargs);
	    Setattr(function,"parms", cv);
	    Delete(cv);
	  }
	  break;
	}
	pp = p;
	p = nextSibling(p);
      }
    }

    /* Do not add in functions if kwargs is being used or if user wants old default argument wrapping
       (one wrapped method per function irrespective of number of default arguments) */
    if (compact_default_args 
	|| is_cfunction(function) 
	|| GetFlag(function,"feature:compactdefaultargs") 
	|| GetFlag(function,"feature:kwargs")) {
      ParmList *p = Getattr(function,"parms");
      if (p) 
        Setattr(p,"compactdefargs", "1"); /* mark parameters for special handling */
      function = 0; /* don't add in extra methods */
    }
  }

  while (function) {
    ParmList *parms = Getattr(function,"parms");
    if (ParmList_has_defaultargs(parms)) {

      /* Create a parameter list for the new function by copying all
         but the last (defaulted) parameter */
      ParmList* newparms = CopyParmListMax(parms,ParmList_len(parms)-1);

      /* Create new function and add to symbol table */
      {
	SwigType *ntype = Copy(nodeType(function));
	char *cntype = Char(ntype);
        Node *new_function = new_node(ntype);
        SwigType *decl = Copy(Getattr(function,"decl"));
        int constqualifier = SwigType_isconst(decl);
	String *ccode = Copy(Getattr(function,"code"));
	String *cstorage = Copy(Getattr(function,"storage"));
	String *cvalue = Copy(Getattr(function,"value"));
	SwigType *ctype = Copy(Getattr(function,"type"));
	String *cthrow = Copy(Getattr(function,"throw"));

        Delete(SwigType_pop_function(decl)); /* remove the old parameter list from decl */
        SwigType_add_function(decl,newparms);
        if (constqualifier)
          SwigType_add_qualifier(decl,"const");

        Setattr(new_function,"name", Getattr(function,"name"));
        Setattr(new_function,"code", ccode);
        Setattr(new_function,"decl", decl);
        Setattr(new_function,"parms", newparms);
        Setattr(new_function,"storage", cstorage);
        Setattr(new_function,"value", cvalue);
        Setattr(new_function,"type", ctype);
        Setattr(new_function,"throw", cthrow);

	Delete(ccode);
	Delete(cstorage);
	Delete(cvalue);
	Delete(ctype);
	Delete(cthrow);
	Delete(decl);

        {
          Node *throws = Getattr(function,"throws");
	  ParmList *pl = CopyParmList(throws);
          if (throws) Setattr(new_function,"throws",pl);
	  Delete(pl);
        }

        /* copy specific attributes for global (or in a namespace) template functions - these are not templated class methods */
        if (strcmp(cntype,"template") == 0) {
          Node *templatetype = Getattr(function,"templatetype");
          Node *symtypename = Getattr(function,"sym:typename");
          Parm *templateparms = Getattr(function,"templateparms");
          if (templatetype) {
	    Node *tmp = Copy(templatetype);
	    Setattr(new_function,"templatetype",tmp);
	    Delete(tmp);
	  }
          if (symtypename) {
	    Node *tmp = Copy(symtypename);
	    Setattr(new_function,"sym:typename",tmp);
	    Delete(tmp);
	  }
          if (templateparms) {
	    Parm *tmp = CopyParmList(templateparms);
	    Setattr(new_function,"templateparms",tmp);
	    Delete(tmp);
	  }
        } else if (strcmp(cntype,"constructor") == 0) {
          /* only copied for constructors as this is not a user defined feature - it is hard coded in the parser */
          if (GetFlag(function,"feature:new")) SetFlag(new_function,"feature:new");
        }

        add_symbols(new_function);
        /* mark added functions as ones with overloaded parameters and point to the parsed method */
        Setattr(new_function,"defaultargs", n);

        /* Point to the new function, extending the linked list */
        set_nextSibling(function, new_function);
	Delete(new_function);
        function = new_function;
	
	Delete(ntype);
      }
    } else {
      function = 0;
    }
  }
}

/* -----------------------------------------------------------------------------
 * tag_nodes()
 *
 * Used by the parser to mark subtypes with extra information.
 * ----------------------------------------------------------------------------- */

static void tag_nodes(Node *n, const_String_or_char_ptr attrname, DOH *value) {
  while (n) {
    Setattr(n, attrname, value);
    tag_nodes(firstChild(n), attrname, value);
    n = nextSibling(n);
  }
}

%}

%union {
  char  *id;
  List  *bases;
  struct Define {
    String *val;
    String *rawval;
    int     type;
    String *qualifier;
    String *bitfield;
    Parm   *throws;
    String *throwf;
  } dtype;
  struct {
    char *type;
    String *filename;
    int   line;
  } loc;
  struct {
    char      *id;
    SwigType  *type;
    String    *defarg;
    ParmList  *parms;
    short      have_parms;
    ParmList  *throws;
    String    *throwf;
  } decl;
  Parm         *tparms;
  struct {
    String     *method;
    Hash       *kwargs;
  } tmap;
  struct {
    String     *type;
    String     *us;
  } ptype;
  SwigType     *type;
  String       *str;
  Parm         *p;
  ParmList     *pl;
  int           ivalue;
  Node         *node;
};

%token <id> ID
%token <str> HBLOCK
%token <id> POUND 
%token <id> STRING
%token <loc> INCLUDE IMPORT INSERT
%token <str> CHARCONST 
%token <dtype> NUM_INT NUM_FLOAT NUM_UNSIGNED NUM_LONG NUM_ULONG NUM_LONGLONG NUM_ULONGLONG NUM_BOOL
%token <ivalue> TYPEDEF
%token <type> TYPE_INT TYPE_UNSIGNED TYPE_SHORT TYPE_LONG TYPE_FLOAT TYPE_DOUBLE TYPE_CHAR TYPE_WCHAR TYPE_VOID TYPE_SIGNED TYPE_BOOL TYPE_COMPLEX TYPE_TYPEDEF TYPE_RAW TYPE_NON_ISO_INT8 TYPE_NON_ISO_INT16 TYPE_NON_ISO_INT32 TYPE_NON_ISO_INT64
%token LPAREN RPAREN COMMA SEMI EXTERN INIT LBRACE RBRACE PERIOD
%token CONST_QUAL VOLATILE REGISTER STRUCT UNION EQUAL SIZEOF MODULE LBRACKET RBRACKET
%token ILLEGAL CONSTANT
%token NAME RENAME NAMEWARN EXTEND PRAGMA FEATURE VARARGS
%token ENUM
%token CLASS TYPENAME PRIVATE PUBLIC PROTECTED COLON STATIC VIRTUAL FRIEND THROW CATCH EXPLICIT
%token USING
%token <node> NAMESPACE
%token NATIVE INLINE
%token TYPEMAP EXCEPT ECHO APPLY CLEAR SWIGTEMPLATE FRAGMENT
%token WARN 
%token LESSTHAN GREATERTHAN DELETE_KW
%token LESSTHANOREQUALTO GREATERTHANOREQUALTO EQUALTO NOTEQUALTO
%token QUESTIONMARK
%token TYPES PARMS
%token NONID DSTAR DCNOT
%token <ivalue> TEMPLATE
%token <str> OPERATOR
%token <str> COPERATOR
%token PARSETYPE PARSEPARM PARSEPARMS

%left  CAST
%left  QUESTIONMARK
%left  LOR
%left  LAND
%left  OR
%left  XOR
%left  AND
%left  EQUALTO NOTEQUALTO
%left  GREATERTHAN LESSTHAN GREATERTHANOREQUALTO LESSTHANOREQUALTO
%left  LSHIFT RSHIFT
%left  PLUS MINUS
%left  STAR SLASH MODULO
%left  UMINUS NOT LNOT
%left  DCOLON

%type <node>     program interface declaration swig_directive ;

/* SWIG directives */
%type <node>     extend_directive apply_directive clear_directive constant_directive ;
%type <node>     echo_directive except_directive fragment_directive include_directive inline_directive ;
%type <node>     insert_directive module_directive name_directive native_directive ;
%type <node>     pragma_directive rename_directive feature_directive varargs_directive typemap_directive ;
%type <node>     types_directive template_directive warn_directive ;

/* C declarations */
%type <node>     c_declaration c_decl c_decl_tail c_enum_decl c_enum_forward_decl c_constructor_decl ;
%type <node>     enumlist edecl;

/* C++ declarations */
%type <node>     cpp_declaration cpp_class_decl cpp_forward_class_decl cpp_template_decl;
%type <node>     cpp_members cpp_member;
%type <node>     cpp_constructor_decl cpp_destructor_decl cpp_protection_decl cpp_conversion_operator;
%type <node>     cpp_swig_directive cpp_temp_possible cpp_nested cpp_opt_declarators ;
%type <node>     cpp_using_decl cpp_namespace_decl cpp_catch_decl ;
%type <node>     kwargs options;

/* Misc */
%type <dtype>    initializer cpp_const ;
%type <id>       storage_class;
%type <pl>       parms  ptail rawparms varargs_parms;
%type <pl>       templateparameters templateparameterstail;
%type <p>        parm valparm rawvalparms valparms valptail ;
%type <p>        typemap_parm tm_list tm_tail ;
%type <p>        templateparameter ;
%type <id>       templcpptype cpptype access_specifier;
%type <node>     base_specifier
%type <type>     type rawtype type_right ;
%type <bases>    base_list inherit raw_inherit;
%type <dtype>    definetype def_args etype;
%type <dtype>    expr exprnum exprcompound valexpr;
%type <id>       ename ;
%type <id>       template_decl;
%type <str>      type_qualifier ;
%type <id>       type_qualifier_raw;
%type <id>       idstring idstringopt;
%type <id>       pragma_lang;
%type <str>      pragma_arg;
%type <loc>      includetype;
%type <type>     pointer primitive_type;
%type <decl>     declarator direct_declarator notso_direct_declarator parameter_declarator typemap_parameter_declarator;
%type <decl>     abstract_declarator direct_abstract_declarator ctor_end;
%type <tmap>     typemap_type;
%type <str>      idcolon idcolontail idcolonnt idcolontailnt idtemplate stringbrace stringbracesemi;
%type <id>       string stringnum ;
%type <tparms>   template_parms;
%type <dtype>    cpp_end cpp_vend;
%type <ivalue>   rename_namewarn;
%type <ptype>    type_specifier primitive_type_list ;
%type <node>     fname stringtype;
%type <node>     featattr;

%%

/* ======================================================================
 *                          High-level Interface file
 *
 * An interface is just a sequence of declarations which may be SWIG directives
 * or normal C declarations.
 * ====================================================================== */

program        :  interface {
                   if (!classes) classes = NewHash();
		   Setattr($1,"classes",classes); 
		   Setattr($1,"name",ModuleName);
		   
		   if ((!module_node) && ModuleName) {
		     module_node = new_node("module");
		     Setattr(module_node,"name",ModuleName);
		   }
		   Setattr($1,"module",module_node);
		   check_extensions();
	           top = $1;
               }
               | PARSETYPE parm SEMI {
                 top = Copy(Getattr($2,"type"));
		 Delete($2);
               }
               | PARSETYPE error {
                 top = 0;
               }
               | PARSEPARM parm SEMI {
                 top = $2;
               }
               | PARSEPARM error {
                 top = 0;
               }
               | PARSEPARMS LPAREN parms RPAREN SEMI {
                 top = $3;
               }
               | PARSEPARMS error SEMI {
                 top = 0;
               }
               ;

interface      : interface declaration {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   appendChild($1,$2);
                   $$ = $1;
               }
               | empty {
                   $$ = new_node("top");
               }
               ;

declaration    : swig_directive { $$ = $1; }
               | c_declaration { $$ = $1; } 
               | cpp_declaration { $$ = $1; }
               | SEMI { $$ = 0; }
               | error {
                  $$ = 0;
		  Swig_error(cparse_file, cparse_line,"Syntax error in input(1).\n");
		  exit(1);
               }
/* Out of class constructor/destructor declarations */
               | c_constructor_decl { 
                  if ($$) {
   		      add_symbols($$);
                  }
                  $$ = $1; 
	       }              

/* Out of class conversion operator.  For example:
     inline A::operator char *() const { ... }.

   This is nearly impossible to parse normally.  We just let the
   first part generate a syntax error and then resynchronize on the
   COPERATOR token---discarding the rest of the definition. Ugh.

 */

               | error COPERATOR {
                  $$ = 0;
                  skip_decl();
               }
               ;

/* ======================================================================
 *                           SWIG DIRECTIVES 
 * ====================================================================== */
  
swig_directive : extend_directive { $$ = $1; }
               | apply_directive { $$ = $1; }
 	       | clear_directive { $$ = $1; }
               | constant_directive { $$ = $1; }
               | echo_directive { $$ = $1; }
               | except_directive { $$ = $1; }
               | fragment_directive { $$ = $1; }
               | include_directive { $$ = $1; }
               | inline_directive { $$ = $1; }
               | insert_directive { $$ = $1; }
               | module_directive { $$ = $1; }
               | name_directive { $$ = $1; }
               | native_directive { $$ = $1; }
               | pragma_directive { $$ = $1; }
               | rename_directive { $$ = $1; }
               | feature_directive { $$ = $1; }
               | varargs_directive { $$ = $1; }
               | typemap_directive { $$ = $1; }
               | types_directive  { $$ = $1; }
               | template_directive { $$ = $1; }
               | warn_directive { $$ = $1; }
               ;

/* ------------------------------------------------------------
   %extend classname { ... } 
   ------------------------------------------------------------ */

extend_directive : EXTEND options idcolon LBRACE {
               Node *cls;
	       String *clsname;
	       cplus_mode = CPLUS_PUBLIC;
	       if (!classes) classes = NewHash();
	       if (!extendhash) extendhash = NewHash();
	       clsname = make_class_name($3);
	       cls = Getattr(classes,clsname);
	       if (!cls) {
		 /* No previous definition. Create a new scope */
		 Node *am = Getattr(extendhash,clsname);
		 if (!am) {
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename($3);
		   prev_symtab = 0;
		 } else {
		   prev_symtab = Swig_symbol_setscope(Getattr(am,"symtab"));
		 }
		 current_class = 0;
	       } else {
		 /* Previous class definition.  Use its symbol table */
		 prev_symtab = Swig_symbol_setscope(Getattr(cls,"symtab"));
		 current_class = cls;
		 extendmode = 1;
	       }
	       Classprefix = NewString($3);
	       Namespaceprefix= Swig_symbol_qualifiedscopename(0);
	       Delete(clsname);
	     } cpp_members RBRACE {
               String *clsname;
	       extendmode = 0;
               $$ = new_node("extend");
	       Setattr($$,"symtab",Swig_symbol_popscope());
	       if (prev_symtab) {
		 Swig_symbol_setscope(prev_symtab);
	       }
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
               clsname = make_class_name($3);
	       Setattr($$,"name",clsname);

	       /* Mark members as extend */

	       tag_nodes($6,"feature:extend",(char*) "1");
	       if (current_class) {
		 /* We add the extension to the previously defined class */
		 appendChild($$,$6);
		 appendChild(current_class,$$);
	       } else {
		 /* We store the extensions in the extensions hash */
		 Node *am = Getattr(extendhash,clsname);
		 if (am) {
		   /* Append the members to the previous extend methods */
		   appendChild(am,$6);
		 } else {
		   appendChild($$,$6);
		   Setattr(extendhash,clsname,$$);
		 }
	       }
	       current_class = 0;
	       Delete(Classprefix);
	       Delete(clsname);
	       Classprefix = 0;
	       prev_symtab = 0;
	       $$ = 0;

	     }
             ;

/* ------------------------------------------------------------
   %apply
   ------------------------------------------------------------ */

apply_directive : APPLY typemap_parm LBRACE tm_list RBRACE {
                    $$ = new_node("apply");
                    Setattr($$,"pattern",Getattr($2,"pattern"));
		    appendChild($$,$4);
               };

/* ------------------------------------------------------------
   %clear
   ------------------------------------------------------------ */

clear_directive : CLEAR tm_list SEMI {
		 $$ = new_node("clear");
		 appendChild($$,$2);
               }
               ;

/* ------------------------------------------------------------
   %constant name = value;
   %constant type name = value;
   ------------------------------------------------------------ */

constant_directive :  CONSTANT ID EQUAL definetype SEMI {
		   if (($4.type != T_ERROR) && ($4.type != T_SYMBOL)) {
		     SwigType *type = NewSwigType($4.type);
		     $$ = new_node("constant");
		     Setattr($$,"name",$2);
		     Setattr($$,"type",type);
		     Setattr($$,"value",$4.val);
		     if ($4.rawval) Setattr($$,"rawval", $4.rawval);
		     Setattr($$,"storage","%constant");
		     SetFlag($$,"feature:immutable");
		     add_symbols($$);
		     Delete(type);
		   } else {
		     if ($4.type == T_ERROR) {
		       Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE,cparse_file,cparse_line,"Unsupported constant value (ignored)\n");
		     }
		     $$ = 0;
		   }

	       }

               | CONSTANT type declarator def_args SEMI {
		 if (($4.type != T_ERROR) && ($4.type != T_SYMBOL)) {
		   SwigType_push($2,$3.type);
		   /* Sneaky callback function trick */
		   if (SwigType_isfunction($2)) {
		     SwigType_add_pointer($2);
		   }
		   $$ = new_node("constant");
		   Setattr($$,"name",$3.id);
		   Setattr($$,"type",$2);
		   Setattr($$,"value",$4.val);
		   if ($4.rawval) Setattr($$,"rawval", $4.rawval);
		   Setattr($$,"storage","%constant");
		   SetFlag($$,"feature:immutable");
		   add_symbols($$);
		 } else {
		     if ($4.type == T_ERROR) {
		       Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE,cparse_file,cparse_line,"Unsupported constant value\n");
		     }
		   $$ = 0;
		 }
               }
               | CONSTANT error SEMI {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 $$ = 0;
	       }
               ;

/* ------------------------------------------------------------
   %echo "text"
   %echo %{ ... %}
   ------------------------------------------------------------ */

echo_directive : ECHO HBLOCK {
		 char temp[64];
		 Replace($2,"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace($2,"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", $2);
		 Delete($2);
                 $$ = 0;
	       }
               | ECHO string {
		 char temp[64];
		 String *s = NewString($2);
		 Replace(s,"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace(s,"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", s);
		 Delete(s);
                 $$ = 0;
               }
               ;

/* ------------------------------------------------------------
   %except(lang) { ... }
   %except { ... }
   %except(lang);   
   %except;
   ------------------------------------------------------------ */

except_directive : EXCEPT LPAREN ID RPAREN LBRACE {
                    skip_balanced('{','}');
		    $$ = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       }

               | EXCEPT LBRACE {
                    skip_balanced('{','}');
		    $$ = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               }

               | EXCEPT LPAREN ID RPAREN SEMI {
		 $$ = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               }

               | EXCEPT SEMI {
		 $$ = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       }
               ;

/* fragment keyword arguments */
stringtype    : string LBRACE parm RBRACE {		 
                 $$ = NewHash();
                 Setattr($$,"value",$1);
		 Setattr($$,"type",Getattr($3,"type"));
               }
               ;

fname         : string {
                 $$ = NewHash();
                 Setattr($$,"value",$1);
              }
              | stringtype {
                $$ = $1;
              }
              ;

/* ------------------------------------------------------------
   %fragment(name, section) %{ ... %}
   %fragment("name" {type}, "section") %{ ... %}
   %fragment("name", "section", fragment="fragment1", fragment="fragment2") %{ ... %}
   Also as above but using { ... }
   %fragment("name");
   ------------------------------------------------------------ */

fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN HBLOCK {
                   Hash *p = $5;
		   $$ = new_node("fragment");
		   Setattr($$,"value",Getattr($3,"value"));
		   Setattr($$,"type",Getattr($3,"type"));
		   Setattr($$,"section",Getattr(p,"name"));
		   Setattr($$,"kwargs",nextSibling(p));
		   Setattr($$,"code",$7);
                 }
                 | FRAGMENT LPAREN fname COMMA kwargs RPAREN LBRACE {
		   Hash *p = $5;
		   String *code;
                   skip_balanced('{','}');
		   $$ = new_node("fragment");
		   Setattr($$,"value",Getattr($3,"value"));
		   Setattr($$,"type",Getattr($3,"type"));
		   Setattr($$,"section",Getattr(p,"name"));
		   Setattr($$,"kwargs",nextSibling(p));
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr($$,"code",code);
		   Delete(code);
                 }
                 | FRAGMENT LPAREN fname RPAREN SEMI {
		   $$ = new_node("fragment");
		   Setattr($$,"value",Getattr($3,"value"));
		   Setattr($$,"type",Getattr($3,"type"));
		   Setattr($$,"emitonly","1");
		 }
                 ;

/* ------------------------------------------------------------
   %includefile(option1="xyz", ...) "filename" [ declarations ] 
   %importfile(option1="xyz", ...) "filename" [ declarations ]
   ------------------------------------------------------------ */

include_directive: includetype options string LBRACKET {
                     $1.filename = Copy(cparse_file);
		     $1.line = cparse_line;
		     scanner_set_location(NewString($3),1);
                     if ($2) { 
		       String *maininput = Getattr($2, "maininput");
		       if (maininput)
		         scanner_set_main_input_file(NewString(maininput));
		     }
               } interface RBRACKET {
                     String *mname = 0;
                     $$ = $6;
		     scanner_set_location($1.filename,$1.line);
		     if (strcmp($1.type,"include") == 0) set_nodeType($$,"include");
		     if (strcmp($1.type,"import") == 0) {
		       mname = $2 ? Getattr($2,"module") : 0;
		       set_nodeType($$,"import");
		       if (import_mode) --import_mode;
		     }
		     
		     Setattr($$,"name",$3);
		     /* Search for the module (if any) */
		     {
			 Node *n = firstChild($$);
			 while (n) {
			     if (Strcmp(nodeType(n),"module") == 0) {
			         if (mname) {
				   Setattr(n,"name", mname);
				   mname = 0;
				 }
				 Setattr($$,"module",Getattr(n,"name"));
				 break;
			     }
			     n = nextSibling(n);
			 }
			 if (mname) {
			   /* There is no module node in the import
			      node, ie, you imported a .h file
			      directly.  We are forced then to create
			      a new import node with a module node.
			   */			      
			   Node *nint = new_node("import");
			   Node *mnode = new_node("module");
			   Setattr(mnode,"name", mname);
			   appendChild(nint,mnode);
			   Delete(mnode);
			   appendChild(nint,firstChild($$));
			   $$ = nint;
			   Setattr($$,"module",mname);
			 }
		     }
		     Setattr($$,"options",$2);
               }
               ;

includetype    : INCLUDE { $$.type = (char *) "include"; }
               | IMPORT  { $$.type = (char *) "import"; ++import_mode;}
               ;

/* ------------------------------------------------------------
   %inline %{ ... %}
   ------------------------------------------------------------ */

inline_directive : INLINE HBLOCK {
                 String *cpps;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");

		   $$ = 0;
		 } else {
		   $$ = new_node("insert");
		   Setattr($$,"code",$2);
		   /* Need to run through the preprocessor */
		   Setline($2,cparse_start_line);
		   Setfile($2,cparse_file);
		   Seek($2,0,SEEK_SET);
		   cpps = Preprocessor_parse($2);
		   start_inline(Char(cpps), cparse_start_line);
		   Delete($2);
		   Delete(cpps);
		 }
		 
	       }
               | INLINE LBRACE {
                 String *cpps;
		 int start_line = cparse_line;
		 skip_balanced('{','}');
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		   
		   $$ = 0;
		 } else {
		   String *code;
                   $$ = new_node("insert");
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr($$,"code", code);
		   Delete(code);		   
		   cpps=Copy(scanner_ccode);
		   start_inline(Char(cpps), start_line);
		   Delete(cpps);
		 }
               }
                ;

/* ------------------------------------------------------------
   %{ ... %}
   %insert(section) "filename"
   %insert("section") "filename"
   %insert(section) %{ ... %}
   %insert("section") %{ ... %}
   ------------------------------------------------------------ */

insert_directive : HBLOCK {
                 $$ = new_node("insert");
		 Setattr($$,"code",$1);
	       }
               | INSERT LPAREN idstring RPAREN string {
		 String *code = NewStringEmpty();
		 $$ = new_node("insert");
		 Setattr($$,"section",$3);
		 Setattr($$,"code",code);
		 if (Swig_insert_file($5,code) < 0) {
		   Swig_error(cparse_file, cparse_line, "Couldn't find '%s'.\n", $5);
		   $$ = 0;
		 } 
               }
               | INSERT LPAREN idstring RPAREN HBLOCK {
		 $$ = new_node("insert");
		 Setattr($$,"section",$3);
		 Setattr($$,"code",$5);
               }
               | INSERT LPAREN idstring RPAREN LBRACE {
		 String *code;
                 skip_balanced('{','}');
		 $$ = new_node("insert");
		 Setattr($$,"section",$3);
		 Delitem(scanner_ccode,0);
		 Delitem(scanner_ccode,DOH_END);
		 code = Copy(scanner_ccode);
		 Setattr($$,"code", code);
		 Delete(code);
	       }
               ;
      
/* ------------------------------------------------------------
    %module modname
    %module "modname"
   ------------------------------------------------------------ */

module_directive: MODULE options idstring {
                 $$ = new_node("module");
		 if ($2) {
		   Setattr($$,"options",$2);
		   if (Getattr($2,"directors")) {
		     Wrapper_director_mode_set(1);
		   } 
		   if (Getattr($2,"dirprot")) {
		     Wrapper_director_protected_mode_set(1);
		   } 
		   if (Getattr($2,"allprotected")) {
		     Wrapper_all_protected_mode_set(1);
		   } 
		   if (Getattr($2,"templatereduce")) {
		     template_reduce = 1;
		   }
		   if (Getattr($2,"notemplatereduce")) {
		     template_reduce = 0;
		   }
		 }
		 if (!ModuleName) ModuleName = NewString($3);
		 if (!import_mode) {
		   /* first module included, we apply global
		      ModuleName, which can be modify by -module */
		   String *mname = Copy(ModuleName);
		   Setattr($$,"name",mname);
		   Delete(mname);
		 } else { 
		   /* import mode, we just pass the idstring */
		   Setattr($$,"name",$3);   
		 }		 
		 if (!module_node) module_node = $$;
	       }
               ;

/* ------------------------------------------------------------
   %name(newname)    declaration
   %name("newname")  declaration
   ------------------------------------------------------------ */

name_directive : NAME LPAREN idstring RPAREN {
                 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 Delete(yyrename);
                 yyrename = NewString($3);
		 $$ = 0;
               }
               | NAME LPAREN RPAREN {
		 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 $$ = 0;
		 Swig_error(cparse_file,cparse_line,"Missing argument to %%name directive.\n");
	       }
               ;


/* ------------------------------------------------------------
   %native(scriptname) name;
   %native(scriptname) type name (parms);
   ------------------------------------------------------------ */

native_directive : NATIVE LPAREN ID RPAREN storage_class ID SEMI {
                 $$ = new_node("native");
		 Setattr($$,"name",$3);
		 Setattr($$,"wrap:name",$6);
	         add_symbols($$);
	       }
               | NATIVE LPAREN ID RPAREN storage_class type declarator SEMI {
		 if (!SwigType_isfunction($7.type)) {
		   Swig_error(cparse_file,cparse_line,"%%native declaration '%s' is not a function.\n", $7.id);
		   $$ = 0;
		 } else {
		     Delete(SwigType_pop_function($7.type));
		     /* Need check for function here */
		     SwigType_push($6,$7.type);
		     $$ = new_node("native");
	             Setattr($$,"name",$3);
		     Setattr($$,"wrap:name",$7.id);
		     Setattr($$,"type",$6);
		     Setattr($$,"parms",$7.parms);
		     Setattr($$,"decl",$7.type);
		 }
	         add_symbols($$);
	       }
               ;

/* ------------------------------------------------------------
   %pragma(lang) name=value
   %pragma(lang) name
   %pragma name = value
   %pragma name
   ------------------------------------------------------------ */

pragma_directive : PRAGMA pragma_lang ID EQUAL pragma_arg {
                 $$ = new_node("pragma");
		 Setattr($$,"lang",$2);
		 Setattr($$,"name",$3);
		 Setattr($$,"value",$5);
	       }
              | PRAGMA pragma_lang ID {
		$$ = new_node("pragma");
		Setattr($$,"lang",$2);
		Setattr($$,"name",$3);
	      }
              ;

pragma_arg    : string { $$ = NewString($1); }
              | HBLOCK { $$ = $1; }
              ;

pragma_lang   : LPAREN ID RPAREN { $$ = $2; }
              | empty { $$ = (char *) "swig"; }
              ;

/* ------------------------------------------------------------
   %rename identifier newname;
   %rename identifier "newname";
   ------------------------------------------------------------ */

rename_directive : rename_namewarn declarator idstring SEMI {
                SwigType *t = $2.type;
		Hash *kws = NewHash();
		String *fixname;
		fixname = feature_identifier_fix($2.id);
		Setattr(kws,"name",$3);
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ($1) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,$2.parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ($1) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,$2.parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ($1) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,$2.parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ($1) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,$2.parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                $$ = 0;
		scanner_clear_rename();
              }
              | rename_namewarn LPAREN kwargs RPAREN declarator cpp_const SEMI {
		String *fixname;
		Hash *kws = $3;
		SwigType *t = $5.type;
		fixname = feature_identifier_fix($5.id);
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if ($6.qualifier) SwigType_push(t,$6.qualifier);
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ($1) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,$5.parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ($1) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,$5.parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ($1) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,$5.parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ($1) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,$5.parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                $$ = 0;
		scanner_clear_rename();
              }
              | rename_namewarn LPAREN kwargs RPAREN string SEMI {
		if ($1) {
		  Swig_name_rename_add(Namespaceprefix,$5,0,$3,0);
		} else {
		  Swig_name_namewarn_add(Namespaceprefix,$5,0,$3);
		}
		$$ = 0;
		scanner_clear_rename();
              }
              ;

rename_namewarn : RENAME {
		    $$ = 1;
                } 
                | NAMEWARN {
                    $$ = 0;
                };


/* ------------------------------------------------------------
   Feature targeting a symbol name (non-global feature):

     %feature(featurename) name "val";
     %feature(featurename, val) name;

   where "val" could instead be the other bracket types, that is,
   { val } or %{ val %} or indeed omitted whereupon it defaults to "1".
   Or, the global feature which does not target a symbol name:

     %feature(featurename) "val";
     %feature(featurename, val);

   An empty val (empty string) clears the feature.
   Any number of feature attributes can optionally be added, for example
   a non-global feature with 2 attributes:

     %feature(featurename, attrib1="attribval1", attrib2="attribval2") name "val";
     %feature(featurename, val, attrib1="attribval1", attrib2="attribval2") name;
   ------------------------------------------------------------ */

                  /* Non-global feature */
feature_directive : FEATURE LPAREN idstring RPAREN declarator cpp_const stringbracesemi {
                    String *val = $7 ? NewString($7) : NewString("1");
                    new_feature($3, val, 0, $5.id, $5.type, $5.parms, $6.qualifier);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring COMMA stringnum RPAREN declarator cpp_const SEMI {
                    String *val = Len($5) ? NewString($5) : 0;
                    new_feature($3, val, 0, $7.id, $7.type, $7.parms, $8.qualifier);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring featattr RPAREN declarator cpp_const stringbracesemi {
                    String *val = $8 ? NewString($8) : NewString("1");
                    new_feature($3, val, $4, $6.id, $6.type, $6.parms, $7.qualifier);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring COMMA stringnum featattr RPAREN declarator cpp_const SEMI {
                    String *val = Len($5) ? NewString($5) : 0;
                    new_feature($3, val, $6, $8.id, $8.type, $8.parms, $9.qualifier);
                    $$ = 0;
                    scanner_clear_rename();
                  }

                  /* Global feature */
                  | FEATURE LPAREN idstring RPAREN stringbracesemi {
                    String *val = $5 ? NewString($5) : NewString("1");
                    new_feature($3, val, 0, 0, 0, 0, 0);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring COMMA stringnum RPAREN SEMI {
                    String *val = Len($5) ? NewString($5) : 0;
                    new_feature($3, val, 0, 0, 0, 0, 0);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring featattr RPAREN stringbracesemi {
                    String *val = $6 ? NewString($6) : NewString("1");
                    new_feature($3, val, $4, 0, 0, 0, 0);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  | FEATURE LPAREN idstring COMMA stringnum featattr RPAREN SEMI {
                    String *val = Len($5) ? NewString($5) : 0;
                    new_feature($3, val, $6, 0, 0, 0, 0);
                    $$ = 0;
                    scanner_clear_rename();
                  }
                  ;

stringbracesemi : stringbrace { $$ = $1; }
                | SEMI { $$ = 0; }
                | PARMS LPAREN parms RPAREN SEMI { $$ = $3; } 
                ;

featattr        : COMMA idstring EQUAL stringnum {
		  $$ = NewHash();
		  Setattr($$,"name",$2);
		  Setattr($$,"value",$4);
                }
                | COMMA idstring EQUAL stringnum featattr {
		  $$ = NewHash();
		  Setattr($$,"name",$2);
		  Setattr($$,"value",$4);
                  set_nextSibling($$,$5);
                }
		;

/* %varargs() directive. */

varargs_directive : VARARGS LPAREN varargs_parms RPAREN declarator cpp_const SEMI {
                 Parm *val;
		 String *name;
		 SwigType *t;
		 if (Namespaceprefix) name = NewStringf("%s::%s", Namespaceprefix, $5.id);
		 else name = NewString($5.id);
		 val = $3;
		 if ($5.parms) {
		   Setmeta(val,"parms",$5.parms);
		 }
		 t = $5.type;
		 if (!Len(t)) t = 0;
		 if (t) {
		   if ($6.qualifier) SwigType_push(t,$6.qualifier);
		   if (SwigType_isfunction(t)) {
		     SwigType *decl = SwigType_pop_function(t);
		     if (SwigType_ispointer(t)) {
		       String *nname = NewStringf("*%s",name);
		       Swig_feature_set(Swig_cparse_features(), nname, decl, "feature:varargs", val, 0);
		       Delete(nname);
		     } else {
		       Swig_feature_set(Swig_cparse_features(), name, decl, "feature:varargs", val, 0);
		     }
		     Delete(decl);
		   } else if (SwigType_ispointer(t)) {
		     String *nname = NewStringf("*%s",name);
		     Swig_feature_set(Swig_cparse_features(),nname,0,"feature:varargs",val, 0);
		     Delete(nname);
		   }
		 } else {
		   Swig_feature_set(Swig_cparse_features(),name,0,"feature:varargs",val, 0);
		 }
		 Delete(name);
		 $$ = 0;
              };

varargs_parms   : parms { $$ = $1; }
                | NUM_INT COMMA parm { 
		  int i;
		  int n;
		  Parm *p;
		  n = atoi(Char($1.val));
		  if (n <= 0) {
		    Swig_error(cparse_file, cparse_line,"Argument count in %%varargs must be positive.\n");
		    $$ = 0;
		  } else {
		    $$ = Copy($3);
		    Setattr($$,"name","VARARGS_SENTINEL");
		    for (i = 0; i < n; i++) {
		      p = Copy($3);
		      set_nextSibling(p,$$);
		      Delete($$);
		      $$ = p;
		    }
		  }
                }
               ;


/* ------------------------------------------------------------
   %typemap(method) type { ... }
   %typemap(method) type "..."
   %typemap(method) type;    - typemap deletion
   %typemap(method) type1,type2,... = type;    - typemap copy
   %typemap type1,type2,... = type;            - typemap copy
   ------------------------------------------------------------ */

typemap_directive :  TYPEMAP LPAREN typemap_type RPAREN tm_list stringbrace {
		   $$ = 0;
		   if ($3.method) {
		     String *code = 0;
		     $$ = new_node("typemap");
		     Setattr($$,"method",$3.method);
		     if ($3.kwargs) {
		       ParmList *kw = $3.kwargs;
                       code = remove_block(kw, $6);
		       Setattr($$,"kwargs", $3.kwargs);
		     }
		     code = code ? code : NewString($6);
		     Setattr($$,"code", code);
		     Delete(code);
		     appendChild($$,$5);
		   }
	       }
               | TYPEMAP LPAREN typemap_type RPAREN tm_list SEMI {
		 $$ = 0;
		 if ($3.method) {
		   $$ = new_node("typemap");
		   Setattr($$,"method",$3.method);
		   appendChild($$,$5);
		 }
	       }
               | TYPEMAP LPAREN typemap_type RPAREN tm_list EQUAL typemap_parm SEMI {
		   $$ = 0;
		   if ($3.method) {
		     $$ = new_node("typemapcopy");
		     Setattr($$,"method",$3.method);
		     Setattr($$,"pattern", Getattr($7,"pattern"));
		     appendChild($$,$5);
		   }
	       }
               ;

/* typemap method type (lang,method) or (method) */

typemap_type   : kwargs {
		 Hash *p;
		 String *name;
		 p = nextSibling($1);
		 if (p && (!Getattr(p,"value"))) {
 		   /* this is the deprecated two argument typemap form */
 		   Swig_warning(WARN_DEPRECATED_TYPEMAP_LANG,cparse_file, cparse_line,
				"Specifying the language name in %%typemap is deprecated - use #ifdef SWIG<LANG> instead.\n");
		   /* two argument typemap form */
		   name = Getattr($1,"name");
		   if (!name || (Strcmp(name,typemap_lang))) {
		     $$.method = 0;
		     $$.kwargs = 0;
		   } else {
		     $$.method = Getattr(p,"name");
		     $$.kwargs = nextSibling(p);
		   }
		 } else {
		   /* one-argument typemap-form */
		   $$.method = Getattr($1,"name");
		   $$.kwargs = p;
		 }
                }
               ;

tm_list        : typemap_parm tm_tail {
                 $$ = $1;
		 set_nextSibling($$,$2);
		}
               ;

tm_tail        : COMMA typemap_parm tm_tail {
                 $$ = $2;
		 set_nextSibling($$,$3);
                }
               | empty { $$ = 0;}
               ;

typemap_parm   : type typemap_parameter_declarator {
                  Parm *parm;
		  SwigType_push($1,$2.type);
		  $$ = new_node("typemapitem");
		  parm = NewParmWithoutFileLineInfo($1,$2.id);
		  Setattr($$,"pattern",parm);
		  Setattr($$,"parms", $2.parms);
		  Delete(parm);
		  /*		  $$ = NewParmWithoutFileLineInfo($1,$2.id);
				  Setattr($$,"parms",$2.parms); */
                }
               | LPAREN parms RPAREN {
                  $$ = new_node("typemapitem");
		  Setattr($$,"pattern",$2);
		  /*		  Setattr($$,"multitype",$2); */
               }
               | LPAREN parms RPAREN LPAREN parms RPAREN {
		 $$ = new_node("typemapitem");
		 Setattr($$,"pattern", $2);
		 /*                 Setattr($$,"multitype",$2); */
		 Setattr($$,"parms",$5);
               }
               ;

/* ------------------------------------------------------------
   %types(parmlist); 
   %types(parmlist) %{ ... %}
   ------------------------------------------------------------ */

types_directive : TYPES LPAREN parms RPAREN stringbracesemi {
                   $$ = new_node("types");
		   Setattr($$,"parms",$3);
                   if ($5)
		     Setattr($$,"convcode",NewString($5));
               }
               ;

/* ------------------------------------------------------------
   %template(name) tname<args>;
   ------------------------------------------------------------ */

template_directive: SWIGTEMPLATE LPAREN idstringopt RPAREN idcolonnt LESSTHAN valparms GREATERTHAN SEMI {
                  Parm *p, *tp;
		  Node *n;
		  Node *tnode = 0;
		  Symtab *tscope = 0;
		  int     specialized = 0;

		  $$ = 0;

		  tscope = Swig_symbol_current();          /* Get the current scope */

		  /* If the class name is qualified, we need to create or lookup namespace entries */
		  if (!inclass) {
		    $5 = resolve_node_scope($5);
		  }

		  /*
		    We use the new namespace entry 'nscope' only to
		    emit the template node. The template parameters are
		    resolved in the current 'tscope'.

		    This is closer to the C++ (typedef) behavior.
		  */
		  n = Swig_cparse_template_locate($5,$7,tscope);

		  /* Patch the argument types to respect namespaces */
		  p = $7;
		  while (p) {
		    SwigType *value = Getattr(p,"value");
		    if (!value) {
		      SwigType *ty = Getattr(p,"type");
		      if (ty) {
			SwigType *rty = 0;
			int reduce = template_reduce;
			if (reduce || !SwigType_ispointer(ty)) {
			  rty = Swig_symbol_typedef_reduce(ty,tscope);
			  if (!reduce) reduce = SwigType_ispointer(rty);
			}
			ty = reduce ? Swig_symbol_type_qualify(rty,tscope) : Swig_symbol_type_qualify(ty,tscope);
			Setattr(p,"type",ty);
			Delete(ty);
			Delete(rty);
		      }
		    } else {
		      value = Swig_symbol_type_qualify(value,tscope);
		      Setattr(p,"value",value);
		      Delete(value);
		    }

		    p = nextSibling(p);
		  }

		  /* Look for the template */
		  {
                    Node *nn = n;
                    Node *linklistend = 0;
                    while (nn) {
                      Node *templnode = 0;
                      if (Strcmp(nodeType(nn),"template") == 0) {
                        int nnisclass = (Strcmp(Getattr(nn,"templatetype"),"class") == 0); /* if not a templated class it is a templated function */
                        Parm *tparms = Getattr(nn,"templateparms");
                        if (!tparms) {
                          specialized = 1;
                        }
                        if (nnisclass && !specialized && ((ParmList_len($7) > ParmList_len(tparms)))) {
                          Swig_error(cparse_file, cparse_line, "Too many template parameters. Maximum of %d.\n", ParmList_len(tparms));
                        } else if (nnisclass && !specialized && ((ParmList_len($7) < ParmList_numrequired(tparms)))) {
                          Swig_error(cparse_file, cparse_line, "Not enough template parameters specified. %d required.\n", ParmList_numrequired(tparms));
                        } else if (!nnisclass && ((ParmList_len($7) != ParmList_len(tparms)))) {
                          /* must be an overloaded templated method - ignore it as it is overloaded with a different number of template parameters */
                          nn = Getattr(nn,"sym:nextSibling"); /* repeat for overloaded templated functions */
                          continue;
                        } else {
			  String *tname = Copy($5);
                          int def_supplied = 0;
                          /* Expand the template */
			  Node *templ = Swig_symbol_clookup($5,0);
			  Parm *targs = templ ? Getattr(templ,"templateparms") : 0;

                          ParmList *temparms;
                          if (specialized) temparms = CopyParmList($7);
                          else temparms = CopyParmList(tparms);

                          /* Create typedef's and arguments */
                          p = $7;
                          tp = temparms;
                          if (!p && ParmList_len(p) != ParmList_len(temparms)) {
                            /* we have no template parameters supplied in %template for a template that has default args*/
                            p = tp;
                            def_supplied = 1;
                          }

                          while (p) {
                            String *value = Getattr(p,"value");
                            if (def_supplied) {
                              Setattr(p,"default","1");
                            }
                            if (value) {
                              Setattr(tp,"value",value);
                            } else {
                              SwigType *ty = Getattr(p,"type");
                              if (ty) {
                                Setattr(tp,"type",ty);
                              }
                              Delattr(tp,"value");
                            }
			    /* fix default arg values */
			    if (targs) {
			      Parm *pi = temparms;
			      Parm *ti = targs;
			      String *tv = Getattr(tp,"value");
			      if (!tv) tv = Getattr(tp,"type");
			      while(pi != tp && ti && pi) {
				String *name = Getattr(ti,"name");
				String *value = Getattr(pi,"value");
				if (!value) value = Getattr(pi,"type");
				Replaceid(tv, name, value);
				pi = nextSibling(pi);
				ti = nextSibling(ti);
			      }
			    }
                            p = nextSibling(p);
                            tp = nextSibling(tp);
                            if (!p && tp) {
                              p = tp;
                              def_supplied = 1;
                            }
                          }

                          templnode = copy_node(nn);
                          /* We need to set the node name based on name used to instantiate */
                          Setattr(templnode,"name",tname);
			  Delete(tname);
                          if (!specialized) {
                            Delattr(templnode,"sym:typename");
                          } else {
                            Setattr(templnode,"sym:typename","1");
                          }
                          if ($3 && !inclass) {
			    /*
			       Comment this out for 1.3.28. We need to
			       re-enable it later but first we need to
			       move %ignore from using %rename to use
			       %feature(ignore).

			       String *symname = Swig_name_make(templnode,0,$3,0,0);
			    */
			    String *symname = $3;
                            Swig_cparse_template_expand(templnode,symname,temparms,tscope);
                            Setattr(templnode,"sym:name",symname);
                          } else {
                            static int cnt = 0;
                            String *nname = NewStringf("__dummy_%d__", cnt++);
                            Swig_cparse_template_expand(templnode,nname,temparms,tscope);
                            Setattr(templnode,"sym:name",nname);
			    Delete(nname);
                            Setattr(templnode,"feature:onlychildren", "typemap,typemapitem,typemapcopy,typedef,types,fragment");

			    if ($3) {
			      Swig_warning(WARN_PARSE_NESTED_TEMPLATE, cparse_file, cparse_line, "Named nested template instantiations not supported. Processing as if no name was given to %%template().\n");
			    }
                          }
                          Delattr(templnode,"templatetype");
                          Setattr(templnode,"template",nn);
                          tnode = templnode;
                          Setfile(templnode,cparse_file);
                          Setline(templnode,cparse_line);
                          Delete(temparms);

                          add_symbols_copy(templnode);

                          if (Strcmp(nodeType(templnode),"class") == 0) {

                            /* Identify pure abstract methods */
                            Setattr(templnode,"abstract", pure_abstract(firstChild(templnode)));

                            /* Set up inheritance in symbol table */
                            {
                              Symtab  *csyms;
                              List *baselist = Getattr(templnode,"baselist");
                              csyms = Swig_symbol_current();
                              Swig_symbol_setscope(Getattr(templnode,"symtab"));
                              if (baselist) {
                                List *bases = make_inherit_list(Getattr(templnode,"name"),baselist);
                                if (bases) {
                                  Iterator s;
                                  for (s = First(bases); s.item; s = Next(s)) {
                                    Symtab *st = Getattr(s.item,"symtab");
                                    if (st) {
				      Setfile(st,Getfile(s.item));
				      Setline(st,Getline(s.item));
                                      Swig_symbol_inherit(st);
                                    }
                                  }
				  Delete(bases);
                                }
                              }
                              Swig_symbol_setscope(csyms);
                            }

                            /* Merge in %extend methods for this class */

			    /* !!! This may be broken.  We may have to add the
			       %extend methods at the beginning of the class */

                            if (extendhash) {
                              String *stmp = 0;
                              String *clsname;
                              Node *am;
                              if (Namespaceprefix) {
                                clsname = stmp = NewStringf("%s::%s", Namespaceprefix, Getattr(templnode,"name"));
                              } else {
                                clsname = Getattr(templnode,"name");
                              }
                              am = Getattr(extendhash,clsname);
                              if (am) {
                                Symtab *st = Swig_symbol_current();
                                Swig_symbol_setscope(Getattr(templnode,"symtab"));
                                /*			    Printf(stdout,"%s: %s %x %x\n", Getattr(templnode,"name"), clsname, Swig_symbol_current(), Getattr(templnode,"symtab")); */
                                merge_extensions(templnode,am);
                                Swig_symbol_setscope(st);
				append_previous_extension(templnode,am);
                                Delattr(extendhash,clsname);
                              }
			      if (stmp) Delete(stmp);
                            }
                            /* Add to classes hash */
                            if (!classes) classes = NewHash();

                            {
                              if (Namespaceprefix) {
                                String *temp = NewStringf("%s::%s", Namespaceprefix, Getattr(templnode,"name"));
                                Setattr(classes,temp,templnode);
				Delete(temp);
                              } else {
				String *qs = Swig_symbol_qualifiedscopename(templnode);
                                Setattr(classes, qs,templnode);
				Delete(qs);
                              }
                            }
                          }
                        }

                        /* all the overloaded templated functions are added into a linked list */
                        if (nscope_inner) {
                          /* non-global namespace */
                          if (templnode) {
                            appendChild(nscope_inner,templnode);
			    Delete(templnode);
                            if (nscope) $$ = nscope;
                          }
                        } else {
                          /* global namespace */
                          if (!linklistend) {
                            $$ = templnode;
                          } else {
                            set_nextSibling(linklistend,templnode);
			    Delete(templnode);
                          }
                          linklistend = templnode;
                        }
                      }
                      nn = Getattr(nn,"sym:nextSibling"); /* repeat for overloaded templated functions. If a templated class there will never be a sibling. */
                    }
		  }
	          Swig_symbol_setscope(tscope);
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
                }
               ;

/* ------------------------------------------------------------
   %warn "text"
   %warn(no)
   ------------------------------------------------------------ */

warn_directive : WARN string {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", $2);
		  $$ = 0;
               }
               ;

/* ======================================================================
 *                              C Parsing
 * ====================================================================== */

c_declaration   : c_decl {
                    $$ = $1; 
                    if ($$) {
   		      add_symbols($$);
                      default_arguments($$);
   	            }
                }
                | c_enum_decl { $$ = $1; }
                | c_enum_forward_decl { $$ = $1; }

/* An extern C type declaration, disable cparse_cplusplus if needed. */

                | EXTERN string LBRACE {
		  if (Strcmp($2,"C") == 0) {
		    cparse_externc = 1;
		  }
		} interface RBRACE {
		  cparse_externc = 0;
		  if (Strcmp($2,"C") == 0) {
		    Node *n = firstChild($5);
		    $$ = new_node("extern");
		    Setattr($$,"name",$2);
		    appendChild($$,n);
		    while (n) {
		      SwigType *decl = Getattr(n,"decl");
		      if (SwigType_isfunction(decl) && Strcmp(Getattr(n, "storage"), "typedef") != 0) {
			Setattr(n,"storage","externc");
		      }
		      n = nextSibling(n);
		    }
		  } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", $2);
		    $$ = new_node("extern");
		    Setattr($$,"name",$2);
		    appendChild($$,firstChild($5));
		  }
                }
                ;

/* ------------------------------------------------------------
   A C global declaration of some kind (may be variable, function, typedef, etc.)
   ------------------------------------------------------------ */

c_decl  : storage_class type declarator initializer c_decl_tail {
              $$ = new_node("cdecl");
	      if ($4.qualifier) SwigType_push($3.type,$4.qualifier);
	      Setattr($$,"type",$2);
	      Setattr($$,"storage",$1);
	      Setattr($$,"name",$3.id);
	      Setattr($$,"decl",$3.type);
	      Setattr($$,"parms",$3.parms);
	      Setattr($$,"value",$4.val);
	      Setattr($$,"throws",$4.throws);
	      Setattr($$,"throw",$4.throwf);
	      if (!$5) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr($$,"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = $5;
		/* Inherit attributes */
		while (n) {
		  String *type = Copy($2);
		  Setattr(n,"type",type);
		  Setattr(n,"storage",$1);
		  n = nextSibling(n);
		  Delete(type);
		}
	      }
	      if ($4.bitfield) {
		Setattr($$,"bitfield", $4.bitfield);
	      }

	      /* Look for "::" declarations (ignored) */
	      if (Strstr($3.id,"::")) {
                /* This is a special case. If the scope name of the declaration exactly
                   matches that of the declaration, then we will allow it. Otherwise, delete. */
                String *p = Swig_scopename_prefix($3.id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p,Namespaceprefix) == 0) ||
		      (inclass && Strcmp(p,Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last($3.id);
		    Setattr($$,"name",lstr);
		    Delete(lstr);
		    set_nextSibling($$,$5);
		  } else {
		    Delete($$);
		    $$ = $5;
		  }
		  Delete(p);
		} else {
		  Delete($$);
		  $$ = $5;
		}
	      } else {
		set_nextSibling($$,$5);
	      }
           }
           ;

/* Allow lists of variables and functions to be built up */

c_decl_tail    : SEMI { 
                   $$ = 0;
                   Clear(scanner_ccode); 
               }
               | COMMA declarator initializer c_decl_tail {
		 $$ = new_node("cdecl");
		 if ($3.qualifier) SwigType_push($2.type,$3.qualifier);
		 Setattr($$,"name",$2.id);
		 Setattr($$,"decl",$2.type);
		 Setattr($$,"parms",$2.parms);
		 Setattr($$,"value",$3.val);
		 Setattr($$,"throws",$3.throws);
		 Setattr($$,"throw",$3.throwf);
		 if ($3.bitfield) {
		   Setattr($$,"bitfield", $3.bitfield);
		 }
		 if (!$4) {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr($$,"code",code);
		     Delete(code);
		   }
		 } else {
		   set_nextSibling($$,$4);
		 }
	       }
               | LBRACE { 
                   skip_balanced('{','}');
                   $$ = 0;
               }
              ;

initializer   : def_args { 
                   $$ = $1; 
                   $$.qualifier = 0;
		   $$.throws = 0;
		   $$.throwf = 0;
              }
              | type_qualifier def_args { 
                   $$ = $2; 
		   $$.qualifier = $1;
		   $$.throws = 0;
		   $$.throwf = 0;
	      }
              | THROW LPAREN parms RPAREN def_args { 
		   $$ = $5; 
                   $$.qualifier = 0;
		   $$.throws = $3;
		   $$.throwf = NewString("1");
              }
              | type_qualifier THROW LPAREN parms RPAREN def_args { 
                   $$ = $6; 
                   $$.qualifier = $1;
		   $$.throws = $4;
		   $$.throwf = NewString("1");
              }
              ;


/* ------------------------------------------------------------
   enum Name;
   ------------------------------------------------------------ */

c_enum_forward_decl : storage_class ENUM ID SEMI {
		   SwigType *ty = 0;
		   $$ = new_node("enumforward");
		   ty = NewStringf("enum %s", $3);
		   Setattr($$,"name",$3);
		   Setattr($$,"type",ty);
		   Setattr($$,"sym:weak", "1");
		   add_symbols($$);
	      }
              ;

/* ------------------------------------------------------------
   enum { ... }
 * ------------------------------------------------------------ */

c_enum_decl : storage_class ENUM ename LBRACE enumlist RBRACE SEMI {
		  SwigType *ty = 0;
                  $$ = new_node("enum");
		  ty = NewStringf("enum %s", $3);
		  Setattr($$,"name",$3);
		  Setattr($$,"type",ty);
		  appendChild($$,$5);
		  add_symbols($$);       /* Add to tag space */
		  add_symbols($5);       /* Add enum values to id space */
               }
               | storage_class ENUM ename LBRACE enumlist RBRACE declarator initializer c_decl_tail {
		 Node *n;
		 SwigType *ty = 0;
		 String   *unnamed = 0;
		 int       unnamedinstance = 0;

		 $$ = new_node("enum");
		 if ($3) {
		   Setattr($$,"name",$3);
		   ty = NewStringf("enum %s", $3);
		 } else if ($7.id) {
		   unnamed = make_unnamed();
		   ty = NewStringf("enum %s", unnamed);
		   Setattr($$,"unnamed",unnamed);
                   /* name is not set for unnamed enum instances, e.g. enum { foo } Instance; */
		   if ($1 && Cmp($1,"typedef") == 0) {
		     Setattr($$,"name",$7.id);
                   } else {
                     unnamedinstance = 1;
                   }
		   Setattr($$,"storage",$1);
		 }
		 if ($7.id && Cmp($1,"typedef") == 0) {
		   Setattr($$,"tdname",$7.id);
                   Setattr($$,"allows_typedef","1");
                 }
		 appendChild($$,$5);
		 n = new_node("cdecl");
		 Setattr(n,"type",ty);
		 Setattr(n,"name",$7.id);
		 Setattr(n,"storage",$1);
		 Setattr(n,"decl",$7.type);
		 Setattr(n,"parms",$7.parms);
		 Setattr(n,"unnamed",unnamed);

                 if (unnamedinstance) {
		   SwigType *cty = NewString("enum ");
		   Setattr($$,"type",cty);
		   SetFlag($$,"unnamedinstance");
		   SetFlag(n,"unnamedinstance");
		   Delete(cty);
                 }
		 if ($9) {
		   Node *p = $9;
		   set_nextSibling(n,p);
		   while (p) {
		     SwigType *cty = Copy(ty);
		     Setattr(p,"type",cty);
		     Setattr(p,"unnamed",unnamed);
		     Setattr(p,"storage",$1);
		     Delete(cty);
		     p = nextSibling(p);
		   }
		 } else {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr(n,"code",code);
		     Delete(code);
		   }
		 }

                 /* Ensure that typedef enum ABC {foo} XYZ; uses XYZ for sym:name, like structs.
                  * Note that class_rename/yyrename are bit of a mess so used this simple approach to change the name. */
                 if ($7.id && $3 && Cmp($1,"typedef") == 0) {
		   String *name = NewString($7.id);
                   Setattr($$, "parser:makename", name);
		   Delete(name);
                 }

		 add_symbols($$);       /* Add enum to tag space */
		 set_nextSibling($$,n);
		 Delete(n);
		 add_symbols($5);       /* Add enum values to id space */
	         add_symbols(n);
		 Delete(unnamed);
	       }
               ;

c_constructor_decl : storage_class type LPAREN parms RPAREN ctor_end {
                   /* This is a sick hack.  If the ctor_end has parameters,
                      and the parms parameter only has 1 parameter, this
                      could be a declaration of the form:

                         type (id)(parms)

			 Otherwise it's an error. */
                    int err = 0;
                    $$ = 0;

		    if ((ParmList_len($4) == 1) && (!Swig_scopename_check($2))) {
		      SwigType *ty = Getattr($4,"type");
		      String *name = Getattr($4,"name");
		      err = 1;
		      if (!name) {
			$$ = new_node("cdecl");
			Setattr($$,"type",$2);
			Setattr($$,"storage",$1);
			Setattr($$,"name",ty);

			if ($6.have_parms) {
			  SwigType *decl = NewStringEmpty();
			  SwigType_add_function(decl,$6.parms);
			  Setattr($$,"decl",decl);
			  Setattr($$,"parms",$6.parms);
			  if (Len(scanner_ccode)) {
			    String *code = Copy(scanner_ccode);
			    Setattr($$,"code",code);
			    Delete(code);
			  }
			}
			if ($6.defarg) {
			  Setattr($$,"value",$6.defarg);
			}
			Setattr($$,"throws",$6.throws);
			Setattr($$,"throw",$6.throwf);
			err = 0;
		      }
		    }
		    if (err) {
		      Swig_error(cparse_file,cparse_line,"Syntax error in input(2).\n");
		      exit(1);
		    }
                }
                ;

/* ======================================================================
 *                       C++ Support
 * ====================================================================== */

cpp_declaration : cpp_class_decl {  $$ = $1; }
                | cpp_forward_class_decl { $$ = $1; }
                | cpp_template_decl { $$ = $1; }
                | cpp_using_decl { $$ = $1; }
                | cpp_namespace_decl { $$ = $1; }
                | cpp_catch_decl { $$ = 0; }
                ;


/* A simple class/struct/union definition */
cpp_class_decl  : storage_class cpptype idcolon inherit LBRACE {
                 if (nested_template == 0) {
                   String *prefix;
                   List *bases = 0;
		   Node *scope = 0;
		   $<node>$ = new_node("class");
		   Setline($<node>$,cparse_start_line);
		   Setattr($<node>$,"kind",$2);
		   if ($4) {
		     Setattr($<node>$,"baselist", Getattr($4,"public"));
		     Setattr($<node>$,"protectedbaselist", Getattr($4,"protected"));
		     Setattr($<node>$,"privatebaselist", Getattr($4,"private"));
		   }
		   Setattr($<node>$,"allows_typedef","1");

		   /* preserve the current scope */
		   prev_symtab = Swig_symbol_current();
		  
		   /* If the class name is qualified.  We need to create or lookup namespace/scope entries */
		   scope = resolve_node_scope($3);
		   Setfile(scope,cparse_file);
		   Setline(scope,cparse_line);
		   $3 = scope;
		   
		   /* support for old nested classes "pseudo" support, such as:

		         %rename(Ala__Ola) Ala::Ola;
			class Ala::Ola {
			public:
			    Ola() {}
		         };

		      this should disappear when a proper implementation is added.
		   */
		   if (nscope_inner && Strcmp(nodeType(nscope_inner),"namespace") != 0) {
		     if (Namespaceprefix) {
		       String *name = NewStringf("%s::%s", Namespaceprefix, $3);		       
		       $3 = name;
		       Namespaceprefix = 0;
		       nscope_inner = 0;
		     }
		   }
		   Setattr($<node>$,"name",$3);

		   Delete(class_rename);
                   class_rename = make_name($<node>$,$3,0);
		   Classprefix = NewString($3);
		   /* Deal with inheritance  */
		   if ($4) {
		     bases = make_inherit_list($3,Getattr($4,"public"));
		   }
		   prefix = SwigType_istemplate_templateprefix($3);
		   if (prefix) {
		     String *fbase, *tbase;
		     if (Namespaceprefix) {
		       fbase = NewStringf("%s::%s", Namespaceprefix,$3);
		       tbase = NewStringf("%s::%s", Namespaceprefix, prefix);
		     } else {
		       fbase = Copy($3);
		       tbase = Copy(prefix);
		     }
		     Swig_name_inherit(tbase,fbase);
		     Delete(fbase);
		     Delete(tbase);
		   }
                   if (strcmp($2,"class") == 0) {
		     cplus_mode = CPLUS_PRIVATE;
		   } else {
		     cplus_mode = CPLUS_PUBLIC;
		   }
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename($3);
		   if (bases) {
		     Iterator s;
		     for (s = First(bases); s.item; s = Next(s)) {
		       Symtab *st = Getattr(s.item,"symtab");
		       if (st) {
			 Setfile(st,Getfile(s.item));
			 Setline(st,Getline(s.item));
			 Swig_symbol_inherit(st); 
		       }
		     }
		     Delete(bases);
		   }
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   cparse_start_line = cparse_line;

		   /* If there are active template parameters, we need to make sure they are
                      placed in the class symbol table so we can catch shadows */

		   if (template_parameters) {
		     Parm *tp = template_parameters;
		     while(tp) {
		       String *tpname = Copy(Getattr(tp,"name"));
		       Node *tn = new_node("templateparm");
		       Setattr(tn,"name",tpname);
		       Swig_symbol_cadd(tpname,tn);
		       tp = nextSibling(tp);
		       Delete(tpname);
		     }
		   }
		   if (class_level >= max_class_levels) {
		       if (!max_class_levels) {
			   max_class_levels = 16;
		       } else {
			   max_class_levels *= 2;
		       }
		       class_decl = (Node**) realloc(class_decl, sizeof(Node*) * max_class_levels);
		       if (!class_decl) {
			   Swig_error(cparse_file, cparse_line, "realloc() failed\n");
		       }
		   }
		   class_decl[class_level++] = $<node>$;
		   Delete(prefix);
		   inclass = 1;
		 }
               } cpp_members RBRACE cpp_opt_declarators {
	         (void) $<node>6;
		 if (nested_template == 0) {
		   Node *p;
		   SwigType *ty;
		   Symtab *cscope = prev_symtab;
		   Node *am = 0;
		   String *scpname = 0;
		   $$ = class_decl[--class_level];
		   inclass = 0;
		   
		   /* Check for pure-abstract class */
		   Setattr($$,"abstract", pure_abstract($7));
		   
		   /* This bit of code merges in a previously defined %extend directive (if any) */
		   
		   if (extendhash) {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     am = Getattr(extendhash,clsname);
		     if (am) {
		       merge_extensions($$,am);
		       Delattr(extendhash,clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes,scpname,$$);
		   Delete(scpname);

		   appendChild($$,$7);
		   
		   if (am) append_previous_extension($$,am);

		   p = $9;
		   if (p) {
		     set_nextSibling($$,p);
		   }
		   
		   if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString($3);
		   } else {
		     ty = NewStringf("%s %s", $2,$3);
		   }
		   while (p) {
		     Setattr(p,"storage",$1);
		     Setattr(p,"type",ty);
		     p = nextSibling(p);
		   }
		   /* Dump nested classes */
		   {
		     String *name = $3;
		     if ($9) {
		       SwigType *decltype = Getattr($9,"decl");
		       if (Cmp($1,"typedef") == 0) {
			 if (!decltype || !Len(decltype)) {
			   String *cname;
			   name = Getattr($9,"name");
			   cname = Copy(name);
			   Setattr($$,"tdname",cname);
			   Delete(cname);

			   /* Use typedef name as class name */
			   if (class_rename && (Strcmp(class_rename,$3) == 0)) {
			     Delete(class_rename);
			     class_rename = NewString(name);
			   }
			   if (!Getattr(classes,name)) {
			     Setattr(classes,name,$$);
			   }
			   Setattr($$,"decl",decltype);
			 }
		       }
		     }
		     appendChild($$,dump_nested(Char(name)));
		   }

		   if (cplus_mode != CPLUS_PUBLIC) {
		   /* we 'open' the class at the end, to allow %template
		      to add new members */
		     Node *pa = new_node("access");
		     Setattr(pa,"kind","public");
		     cplus_mode = CPLUS_PUBLIC;
		     appendChild($$,pa);
		     Delete(pa);
		   }

		   Setattr($$,"symtab",Swig_symbol_popscope());

		   Classprefix = 0;
		   if (nscope_inner) {
		     /* this is tricky */
		     /* we add the declaration in the original namespace */
		     appendChild(nscope_inner,$$);
		     Swig_symbol_setscope(Getattr(nscope_inner,"symtab"));
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols($$);
		     if (nscope) $$ = nscope;
		     /* but the variable definition in the current scope */
		     Swig_symbol_setscope(cscope);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols($9);
		   } else {
		     Delete(yyrename);
		     yyrename = Copy(class_rename);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);

		     add_symbols($$);
		     add_symbols($9);
		   }
		   Swig_symbol_setscope(cscope);
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 } else {
		    $$ = new_node("class");
		    Setattr($$,"kind",$2);
		    Setattr($$,"name",NewString($3));
		    SetFlag($$,"nestedtemplateclass");
		 }
	       }

/* An unnamed struct, possibly with a typedef */

             | storage_class cpptype LBRACE {
	       String *unnamed;
	       unnamed = make_unnamed();
	       $<node>$ = new_node("class");
	       Setline($<node>$,cparse_start_line);
	       Setattr($<node>$,"kind",$2);
	       Setattr($<node>$,"storage",$1);
	       Setattr($<node>$,"unnamed",unnamed);
	       Setattr($<node>$,"allows_typedef","1");
	       Delete(class_rename);
	       class_rename = make_name($<node>$,0,0);
	       if (strcmp($2,"class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       Swig_symbol_newscope();
	       cparse_start_line = cparse_line;
	       if (class_level >= max_class_levels) {
		   if (!max_class_levels) {
		       max_class_levels = 16;
		   } else {
		       max_class_levels *= 2;
		   }
		   class_decl = (Node**) realloc(class_decl, sizeof(Node*) * max_class_levels);
		   if (!class_decl) {
		       Swig_error(cparse_file, cparse_line, "realloc() failed\n");
		   }
	       }
	       class_decl[class_level++] = $<node>$;
	       inclass = 1;
	       Classprefix = NewStringEmpty();
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
             } cpp_members RBRACE declarator initializer c_decl_tail {
	       String *unnamed;
	       Node *n;
	       (void) $<node>4;
	       Classprefix = 0;
	       $$ = class_decl[--class_level];
	       inclass = 0;
	       unnamed = Getattr($$,"unnamed");

	       /* Check for pure-abstract class */
	       Setattr($$,"abstract", pure_abstract($5));

	       n = new_node("cdecl");
	       Setattr(n,"name",$7.id);
	       Setattr(n,"unnamed",unnamed);
	       Setattr(n,"type",unnamed);
	       Setattr(n,"decl",$7.type);
	       Setattr(n,"parms",$7.parms);
	       Setattr(n,"storage",$1);
	       if ($9) {
		 Node *p = $9;
		 set_nextSibling(n,p);
		 while (p) {
		   String *type = Copy(unnamed);
		   Setattr(p,"name",$7.id);
		   Setattr(p,"unnamed",unnamed);
		   Setattr(p,"type",type);
		   Delete(type);
		   Setattr(p,"storage",$1);
		   p = nextSibling(p);
		 }
	       }
	       set_nextSibling($$,n);
	       Delete(n);
	       {
		 /* If a proper typedef name was given, we'll use it to set the scope name */
		 String *name = 0;
		 if ($1 && (strcmp($1,"typedef") == 0)) {
		   if (!Len($7.type)) {	
		     String *scpname = 0;
		     name = $7.id;
		     Setattr($$,"tdname",name);
		     Setattr($$,"name",name);
		     Swig_symbol_setscopename(name);

		     /* If a proper name was given, we use that as the typedef, not unnamed */
		     Clear(unnamed);
		     Append(unnamed, name);
		     
		     n = nextSibling(n);
		     set_nextSibling($$,n);

		     /* Check for previous extensions */
		     if (extendhash) {
		       String *clsname = Swig_symbol_qualifiedscopename(0);
		       Node *am = Getattr(extendhash,clsname);
		       if (am) {
			 /* Merge the extension into the symbol table */
			 merge_extensions($$,am);
			 append_previous_extension($$,am);
			 Delattr(extendhash,clsname);
		       }
		       Delete(clsname);
		     }
		     if (!classes) classes = NewHash();
		     scpname = Swig_symbol_qualifiedscopename(0);
		     Setattr(classes,scpname,$$);
		     Delete(scpname);
		   } else {
		     Swig_symbol_setscopename("<unnamed>");
		   }
		 }
		 appendChild($$,$5);
		 appendChild($$,dump_nested(Char(name)));
	       }
	       /* Pop the scope */
	       Setattr($$,"symtab",Swig_symbol_popscope());
	       if (class_rename) {
		 Delete(yyrename);
		 yyrename = NewString(class_rename);
	       }
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols($$);
	       add_symbols(n);
	       Delete(unnamed);
              }
             ;

cpp_opt_declarators :  SEMI { $$ = 0; }
                    |  declarator initializer c_decl_tail {
                        $$ = new_node("cdecl");
                        Setattr($$,"name",$1.id);
                        Setattr($$,"decl",$1.type);
                        Setattr($$,"parms",$1.parms);
			set_nextSibling($$,$3);
                    }
                    ;
/* ------------------------------------------------------------
   class Name;
   ------------------------------------------------------------ */

cpp_forward_class_decl : storage_class cpptype idcolon SEMI {
              if ($1 && (Strcmp($1,"friend") == 0)) {
		/* Ignore */
                $$ = 0; 
	      } else {
		$$ = new_node("classforward");
		Setfile($$,cparse_file);
		Setline($$,cparse_line);
		Setattr($$,"kind",$2);
		Setattr($$,"name",$3);
		Setattr($$,"sym:weak", "1");
		add_symbols($$);
	      }
             }
             ;

/* ------------------------------------------------------------
   template<...> decl
   ------------------------------------------------------------ */

cpp_template_decl : TEMPLATE LESSTHAN template_parms GREATERTHAN { 
		    template_parameters = $3; 
		    if (inclass)
		      nested_template++;

		  } cpp_temp_possible {

		    /* Don't ignore templated functions declared within a class, unless the templated function is within a nested class */
		    if (nested_template <= 1) {
		      int is_nested_template_class = $6 && GetFlag($6, "nestedtemplateclass");
		      if (is_nested_template_class) {
			$$ = 0;
			/* Nested template classes would probably better be ignored like ordinary nested classes using cpp_nested, but that introduces shift/reduce conflicts */
			if (cplus_mode == CPLUS_PUBLIC) {
			  /* Treat the nested class/struct/union as a forward declaration until a proper nested class solution is implemented */
			  String *kind = Getattr($6, "kind");
			  String *name = Getattr($6, "name");
			  $$ = new_node("template");
			  Setattr($$,"kind",kind);
			  Setattr($$,"name",name);
			  Setattr($$,"sym:weak", "1");
			  Setattr($$,"templatetype","classforward");
			  Setattr($$,"templateparms", $3);
			  add_symbols($$);

			  if (GetFlag($$, "feature:nestedworkaround")) {
			    Swig_symbol_remove($$);
			    $$ = 0;
			  } else {
			    SWIG_WARN_NODE_BEGIN($$);
			    Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested template %s not currently supported (%s ignored).\n", kind, name);
			    SWIG_WARN_NODE_END($$);
			  }
			}
			Delete($6);
		      } else {
			String *tname = 0;
			int     error = 0;

			/* check if we get a namespace node with a class declaration, and retrieve the class */
			Symtab *cscope = Swig_symbol_current();
			Symtab *sti = 0;
			Node *ntop = $6;
			Node *ni = ntop;
			SwigType *ntype = ni ? nodeType(ni) : 0;
			while (ni && Strcmp(ntype,"namespace") == 0) {
			  sti = Getattr(ni,"symtab");
			  ni = firstChild(ni);
			  ntype = nodeType(ni);
			}
			if (sti) {
			  Swig_symbol_setscope(sti);
			  Delete(Namespaceprefix);
			  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
			  $6 = ni;
			}

			$$ = $6;
			if ($$) tname = Getattr($$,"name");
			
			/* Check if the class is a template specialization */
			if (($$) && (Strchr(tname,'<')) && (!is_operator(tname))) {
			  /* If a specialization.  Check if defined. */
			  Node *tempn = 0;
			  {
			    String *tbase = SwigType_templateprefix(tname);
			    tempn = Swig_symbol_clookup_local(tbase,0);
			    if (!tempn || (Strcmp(nodeType(tempn),"template") != 0)) {
			      SWIG_WARN_NODE_BEGIN(tempn);
			      Swig_warning(WARN_PARSE_TEMPLATE_SP_UNDEF, Getfile($$),Getline($$),"Specialization of non-template '%s'.\n", tbase);
			      SWIG_WARN_NODE_END(tempn);
			      tempn = 0;
			      error = 1;
			    }
			    Delete(tbase);
			  }
			  Setattr($$,"specialization","1");
			  Setattr($$,"templatetype",nodeType($$));
			  set_nodeType($$,"template");
			  /* Template partial specialization */
			  if (tempn && ($3) && ($6)) {
			    List   *tlist;
			    String *targs = SwigType_templateargs(tname);
			    tlist = SwigType_parmlist(targs);
			    /*			  Printf(stdout,"targs = '%s' %s\n", targs, tlist); */
			    if (!Getattr($$,"sym:weak")) {
			      Setattr($$,"sym:typename","1");
			    }
			    
			    if (Len(tlist) != ParmList_len(Getattr(tempn,"templateparms"))) {
			      Swig_error(Getfile($$),Getline($$),"Inconsistent argument count in template partial specialization. %d %d\n", Len(tlist), ParmList_len(Getattr(tempn,"templateparms")));
			      
			    } else {

			    /* This code builds the argument list for the partial template
			       specialization.  This is a little hairy, but the idea is as
			       follows:

			       $3 contains a list of arguments supplied for the template.
			       For example template<class T>.

			       tlist is a list of the specialization arguments--which may be
			       different.  For example class<int,T>.

			       tp is a copy of the arguments in the original template definition.
       
			       The patching algorithm walks through the list of supplied
			       arguments ($3), finds the position in the specialization arguments
			       (tlist), and then patches the name in the argument list of the
			       original template.
			    */

			    {
			      String *pn;
			      Parm *p, *p1;
			      int i, nargs;
			      Parm *tp = CopyParmList(Getattr(tempn,"templateparms"));
			      nargs = Len(tlist);
			      p = $3;
			      while (p) {
				for (i = 0; i < nargs; i++){
				  pn = Getattr(p,"name");
				  if (Strcmp(pn,SwigType_base(Getitem(tlist,i))) == 0) {
				    int j;
				    Parm *p1 = tp;
				    for (j = 0; j < i; j++) {
				      p1 = nextSibling(p1);
				    }
				    Setattr(p1,"name",pn);
				    Setattr(p1,"partialarg","1");
				  }
				}
				p = nextSibling(p);
			      }
			      p1 = tp;
			      i = 0;
			      while (p1) {
				if (!Getattr(p1,"partialarg")) {
				  Delattr(p1,"name");
				  Setattr(p1,"type", Getitem(tlist,i));
				} 
				i++;
				p1 = nextSibling(p1);
			      }
			      Setattr($$,"templateparms",tp);
			      Delete(tp);
			    }
  #if 0
			    /* Patch the parameter list */
			    if (tempn) {
			      Parm *p,*p1;
			      ParmList *tp = CopyParmList(Getattr(tempn,"templateparms"));
			      p = $3;
			      p1 = tp;
			      while (p && p1) {
				String *pn = Getattr(p,"name");
				Printf(stdout,"pn = '%s'\n", pn);
				if (pn) Setattr(p1,"name",pn);
				else Delattr(p1,"name");
				pn = Getattr(p,"type");
				if (pn) Setattr(p1,"type",pn);
				p = nextSibling(p);
				p1 = nextSibling(p1);
			      }
			      Setattr($$,"templateparms",tp);
			      Delete(tp);
			    } else {
			      Setattr($$,"templateparms",$3);
			    }
  #endif
			    Delattr($$,"specialization");
			    Setattr($$,"partialspecialization","1");
			    /* Create a specialized name for matching */
			    {
			      Parm *p = $3;
			      String *fname = NewString(Getattr($$,"name"));
			      String *ffname = 0;
			      ParmList *partialparms = 0;

			      char   tmp[32];
			      int    i, ilen;
			      while (p) {
				String *n = Getattr(p,"name");
				if (!n) {
				  p = nextSibling(p);
				  continue;
				}
				ilen = Len(tlist);
				for (i = 0; i < ilen; i++) {
				  if (Strstr(Getitem(tlist,i),n)) {
				    sprintf(tmp,"$%d",i+1);
				    Replaceid(fname,n,tmp);
				  }
				}
				p = nextSibling(p);
			      }
			      /* Patch argument names with typedef */
			      {
				Iterator tt;
				Parm *parm_current = 0;
				List *tparms = SwigType_parmlist(fname);
				ffname = SwigType_templateprefix(fname);
				Append(ffname,"<(");
				for (tt = First(tparms); tt.item; ) {
				  SwigType *rtt = Swig_symbol_typedef_reduce(tt.item,0);
				  SwigType *ttr = Swig_symbol_type_qualify(rtt,0);

				  Parm *newp = NewParmWithoutFileLineInfo(ttr, 0);
				  if (partialparms)
				    set_nextSibling(parm_current, newp);
				  else
				    partialparms = newp;
				  parm_current = newp;

				  Append(ffname,ttr);
				  tt = Next(tt);
				  if (tt.item) Putc(',',ffname);
				  Delete(rtt);
				  Delete(ttr);
				}
				Delete(tparms);
				Append(ffname,")>");
			      }
			      {
				Node *new_partial = NewHash();
				String *partials = Getattr(tempn,"partials");
				if (!partials) {
				  partials = NewList();
				  Setattr(tempn,"partials",partials);
				  Delete(partials);
				}
				/*			      Printf(stdout,"partial: fname = '%s', '%s'\n", fname, Swig_symbol_typedef_reduce(fname,0)); */
				Setattr(new_partial, "partialparms", partialparms);
				Setattr(new_partial, "templcsymname", ffname);
				Append(partials, new_partial);
			      }
			      Setattr($$,"partialargs",ffname);
			      Swig_symbol_cadd(ffname,$$);
			    }
			    }
			    Delete(tlist);
			    Delete(targs);
			  } else {
			    /* An explicit template specialization */
			    /* add default args from primary (unspecialized) template */
			    String *ty = Swig_symbol_template_deftype(tname,0);
			    String *fname = Swig_symbol_type_qualify(ty,0);
			    Swig_symbol_cadd(fname,$$);
			    Delete(ty);
			    Delete(fname);
			  }
			}  else if ($$) {
			  Setattr($$,"templatetype",nodeType($6));
			  set_nodeType($$,"template");
			  Setattr($$,"templateparms", $3);
			  if (!Getattr($$,"sym:weak")) {
			    Setattr($$,"sym:typename","1");
			  }
			  add_symbols($$);
			  default_arguments($$);
			  /* We also place a fully parameterized version in the symbol table */
			  {
			    Parm *p;
			    String *fname = NewStringf("%s<(", Getattr($$,"name"));
			    p = $3;
			    while (p) {
			      String *n = Getattr(p,"name");
			      if (!n) n = Getattr(p,"type");
			      Append(fname,n);
			      p = nextSibling(p);
			      if (p) Putc(',',fname);
			    }
			    Append(fname,")>");
			    Swig_symbol_cadd(fname,$$);
			  }
			}
			$$ = ntop;
			Swig_symbol_setscope(cscope);
			Delete(Namespaceprefix);
			Namespaceprefix = Swig_symbol_qualifiedscopename(0);
			if (error) $$ = 0;
		      }
		    } else {
		      $$ = 0;
		    }
		    template_parameters = 0;
		    if (inclass)
		      nested_template--;
                  }
                | TEMPLATE cpptype idcolon {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                   $$ = 0; 
                }
                ;

cpp_temp_possible:  c_decl {
		  $$ = $1;
                }
                | cpp_class_decl {
                   $$ = $1;
                }
                | cpp_constructor_decl {
                   $$ = $1;
                }
                | cpp_template_decl {
		  $$ = 0;
                }
                | cpp_forward_class_decl {
                  $$ = $1;
                }
                | cpp_conversion_operator {
                  $$ = $1;
                }
                ;

template_parms  : templateparameters {
		   /* Rip out the parameter names */
		  Parm *p = $1;
		  $$ = $1;

		  while (p) {
		    String *name = Getattr(p,"name");
		    if (!name) {
		      /* Hmmm. Maybe it's a 'class T' parameter */
		      char *type = Char(Getattr(p,"type"));
		      /* Template template parameter */
		      if (strncmp(type,"template<class> ",16) == 0) {
			type += 16;
		      }
		      if ((strncmp(type,"class ",6) == 0) || (strncmp(type,"typename ", 9) == 0)) {
			char *t = strchr(type,' ');
			Setattr(p,"name", t+1);
		      } else {
			/*
			 Swig_error(cparse_file, cparse_line, "Missing template parameter name\n");
			 $$.rparms = 0;
			 $$.parms = 0;
			 break; */
		      }
		    }
		    p = nextSibling(p);
		  }
                 }
                 ;

templateparameters : templateparameter templateparameterstail {
                      set_nextSibling($1,$2);
                      $$ = $1;
                   }
                   | empty { $$ = 0; }
                   ;

templateparameter : templcpptype {
		    $$ = NewParmWithoutFileLineInfo(NewString($1), 0);
                  }
                  | parm {
                    $$ = $1;
                  }
                  ;

templateparameterstail : COMMA templateparameter templateparameterstail {
                         set_nextSibling($2,$3);
                         $$ = $2;
                       }
                       | empty { $$ = 0; }
                       ;

/* Namespace support */

cpp_using_decl : USING idcolon SEMI {
                  String *uname = Swig_symbol_type_qualify($2,0);
		  String *name = Swig_scopename_last($2);
                  $$ = new_node("using");
		  Setattr($$,"uname",uname);
		  Setattr($$,"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols($$);
             }
             | USING NAMESPACE idcolon SEMI {
	       Node *n = Swig_symbol_clookup($3,0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Nothing known about namespace '%s'\n", $3);
		 $$ = 0;
	       } else {

		 while (Strcmp(nodeType(n),"using") == 0) {
		   n = Getattr(n,"node");
		 }
		 if (n) {
		   if (Strcmp(nodeType(n),"namespace") == 0) {
		     Symtab *current = Swig_symbol_current();
		     Symtab *symtab = Getattr(n,"symtab");
		     $$ = new_node("using");
		     Setattr($$,"node",n);
		     Setattr($$,"namespace", $3);
		     if (current != symtab) {
		       Swig_symbol_inherit(symtab);
		     }
		   } else {
		     Swig_error(cparse_file, cparse_line, "'%s' is not a namespace.\n", $3);
		     $$ = 0;
		   }
		 } else {
		   $$ = 0;
		 }
	       }
             }
             ;

cpp_namespace_decl : NAMESPACE idcolon LBRACE { 
                Hash *h;
                $1 = Swig_symbol_current();
		h = Swig_symbol_clookup($2,0);
		if (h && ($1 == Getattr(h,"sym:symtab")) && (Strcmp(nodeType(h),"namespace") == 0)) {
		  if (Getattr(h,"alias")) {
		    h = Getattr(h,"namespace");
		    Swig_warning(WARN_PARSE_NAMESPACE_ALIAS, cparse_file, cparse_line, "Namespace alias '%s' not allowed here. Assuming '%s'\n",
				 $2, Getattr(h,"name"));
		    $2 = Getattr(h,"name");
		  }
		  Swig_symbol_setscope(Getattr(h,"symtab"));
		} else {
		  Swig_symbol_newscope();
		  Swig_symbol_setscopename($2);
		}
		Delete(Namespaceprefix);
		Namespaceprefix = Swig_symbol_qualifiedscopename(0);
             } interface RBRACE {
                Node *n = $5;
		set_nodeType(n,"namespace");
		Setattr(n,"name",$2);
                Setattr(n,"symtab", Swig_symbol_popscope());
		Swig_symbol_setscope($1);
		$$ = n;
		Delete(Namespaceprefix);
		Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		add_symbols($$);
             } 
             | NAMESPACE LBRACE {
	       Hash *h;
	       $1 = Swig_symbol_current();
	       h = Swig_symbol_clookup((char *)"    ",0);
	       if (h && (Strcmp(nodeType(h),"namespace") == 0)) {
		 Swig_symbol_setscope(Getattr(h,"symtab"));
	       } else {
		 Swig_symbol_newscope();
		 /* we don't use "__unnamed__", but a long 'empty' name */
		 Swig_symbol_setscopename("    ");
	       }
	       Namespaceprefix = 0;
             } interface RBRACE {
	       $$ = $4;
	       set_nodeType($$,"namespace");
	       Setattr($$,"unnamed","1");
	       Setattr($$,"symtab", Swig_symbol_popscope());
	       Swig_symbol_setscope($1);
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols($$);
             }
             | NAMESPACE ID EQUAL idcolon SEMI {
	       /* Namespace alias */
	       Node *n;
	       $$ = new_node("namespace");
	       Setattr($$,"name",$2);
	       Setattr($$,"alias",$4);
	       n = Swig_symbol_clookup($4,0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Unknown namespace '%s'\n", $4);
		 $$ = 0;
	       } else {
		 if (Strcmp(nodeType(n),"namespace") != 0) {
		   Swig_error(cparse_file, cparse_line, "'%s' is not a namespace\n",$4);
		   $$ = 0;
		 } else {
		   while (Getattr(n,"alias")) {
		     n = Getattr(n,"namespace");
		   }
		   Setattr($$,"namespace",n);
		   add_symbols($$);
		   /* Set up a scope alias */
		   Swig_symbol_alias($2,Getattr(n,"symtab"));
		 }
	       }
             }
             ;

cpp_members  : cpp_member cpp_members {
                   $$ = $1;
                   /* Insert cpp_member (including any siblings) to the front of the cpp_members linked list */
		   if ($$) {
		     Node *p = $$;
		     Node *pp =0;
		     while (p) {
		       pp = p;
		       p = nextSibling(p);
		     }
		     set_nextSibling(pp,$2);
		   } else {
		     $$ = $2;
		   }
             }
             | EXTEND LBRACE { 
                  if (cplus_mode != CPLUS_PUBLIC) {
		     Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
		  }
             } cpp_members RBRACE cpp_members {
	       $$ = new_node("extend");
	       tag_nodes($4,"feature:extend",(char*) "1");
	       appendChild($$,$4);
	       set_nextSibling($$,$6);
	     }
             | include_directive { $$ = $1; }
             | empty { $$ = 0;}
	     | error {
	       int start_line = cparse_line;
	       skip_decl();
	       Swig_error(cparse_file,start_line,"Syntax error in input(3).\n");
	       exit(1);
	       } cpp_members { 
		 $$ = $3;
   	     }
             ;

/* ======================================================================
 *                         C++ Class members
 * ====================================================================== */

/* A class member.  May be data or a function. Static or virtual as well */

cpp_member   : c_declaration { $$ = $1; }
             | cpp_constructor_decl { 
                 $$ = $1; 
		 if (extendmode) {
		   String *symname;
		   symname= make_name($$,Getattr($$,"name"), Getattr($$,"decl"));
		   if (Strcmp(symname,Getattr($$,"name")) == 0) {
		     /* No renaming operation.  Set name to class name */
		     Delete(yyrename);
		     yyrename = NewString(Getattr(current_class,"sym:name"));
		   } else {
		     Delete(yyrename);
		     yyrename = symname;
		   }
		 }
		 add_symbols($$);
                 default_arguments($$);
             }
             | cpp_destructor_decl { $$ = $1; }
             | cpp_protection_decl { $$ = $1; }
             | cpp_swig_directive { $$ = $1; }
             | cpp_conversion_operator { $$ = $1; }
             | cpp_forward_class_decl { $$ = $1; }
             | cpp_nested { $$ = $1; }
             | storage_class idcolon SEMI { $$ = 0; }
             | cpp_using_decl { $$ = $1; }
             | cpp_template_decl { $$ = $1; }
             | cpp_catch_decl { $$ = 0; }
             | template_directive { $$ = $1; }
             | warn_directive { $$ = $1; }
             | anonymous_bitfield { $$ = 0; }
             | fragment_directive {$$ = $1; }
             | types_directive {$$ = $1; }
             | SEMI { $$ = 0; }
             ;

/* Possibly a constructor */
/* Note: the use of 'type' is here to resolve a shift-reduce conflict.  For example:
            typedef Foo ();
            typedef Foo (*ptr)();
*/
  
cpp_constructor_decl : storage_class type LPAREN parms RPAREN ctor_end {
              if (Classprefix) {
		 SwigType *decl = NewStringEmpty();
		 $$ = new_node("constructor");
		 Setattr($$,"storage",$1);
		 Setattr($$,"name",$2);
		 Setattr($$,"parms",$4);
		 SwigType_add_function(decl,$4);
		 Setattr($$,"decl",decl);
		 Setattr($$,"throws",$6.throws);
		 Setattr($$,"throw",$6.throwf);
		 if (Len(scanner_ccode)) {
		   String *code = Copy(scanner_ccode);
		   Setattr($$,"code",code);
		   Delete(code);
		 }
		 SetFlag($$,"feature:new");
	      } else {
		$$ = 0;
              }
              }
              ;

/* A destructor (hopefully) */

cpp_destructor_decl : NOT idtemplate LPAREN parms RPAREN cpp_end {
               String *name = NewStringf("%s",$2);
	       if (*(Char(name)) != '~') Insert(name,0,"~");
               $$ = new_node("destructor");
	       Setattr($$,"name",name);
	       Delete(name);
	       if (Len(scanner_ccode)) {
		 String *code = Copy(scanner_ccode);
		 Setattr($$,"code",code);
		 Delete(code);
	       }
	       {
		 String *decl = NewStringEmpty();
		 SwigType_add_function(decl,$4);
		 Setattr($$,"decl",decl);
		 Delete(decl);
	       }
	       Setattr($$,"throws",$6.throws);
	       Setattr($$,"throw",$6.throwf);
	       add_symbols($$);
	      }

/* A virtual destructor */

              | VIRTUAL NOT idtemplate LPAREN parms RPAREN cpp_vend {
		String *name;
		char *c = 0;
		$$ = new_node("destructor");
	       /* Check for template names.  If the class is a template
		  and the constructor is missing the template part, we
		  add it */
	        if (Classprefix) {
                  c = strchr(Char(Classprefix),'<');
                  if (c && !Strchr($3,'<')) {
                    $3 = NewStringf("%s%s",$3,c);
                  }
		}
		Setattr($$,"storage","virtual");
	        name = NewStringf("%s",$3);
		if (*(Char(name)) != '~') Insert(name,0,"~");
		Setattr($$,"name",name);
		Delete(name);
		Setattr($$,"throws",$7.throws);
		Setattr($$,"throw",$7.throwf);
		if ($7.val) {
		  Setattr($$,"value","0");
		}
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr($$,"code",code);
		  Delete(code);
		}
		{
		  String *decl = NewStringEmpty();
		  SwigType_add_function(decl,$5);
		  Setattr($$,"decl",decl);
		  Delete(decl);
		}

		add_symbols($$);
	      }
              ;


/* C++ type conversion operator */
cpp_conversion_operator : storage_class COPERATOR type pointer LPAREN parms RPAREN cpp_vend {
                 $$ = new_node("cdecl");
                 Setattr($$,"type",$3);
		 Setattr($$,"name",$2);
		 Setattr($$,"storage",$1);

		 SwigType_add_function($4,$6);
		 if ($8.qualifier) {
		   SwigType_push($4,$8.qualifier);
		 }
		 Setattr($$,"decl",$4);
		 Setattr($$,"parms",$6);
		 Setattr($$,"conversion_operator","1");
		 add_symbols($$);
              }
               | storage_class COPERATOR type AND LPAREN parms RPAREN cpp_vend {
		 SwigType *decl;
                 $$ = new_node("cdecl");
                 Setattr($$,"type",$3);
		 Setattr($$,"name",$2);
		 Setattr($$,"storage",$1);
		 decl = NewStringEmpty();
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,$6);
		 if ($8.qualifier) {
		   SwigType_push(decl,$8.qualifier);
		 }
		 Setattr($$,"decl",decl);
		 Setattr($$,"parms",$6);
		 Setattr($$,"conversion_operator","1");
		 add_symbols($$);
	       }

              | storage_class COPERATOR type LPAREN parms RPAREN cpp_vend {
		String *t = NewStringEmpty();
		$$ = new_node("cdecl");
		Setattr($$,"type",$3);
		Setattr($$,"name",$2);
		 Setattr($$,"storage",$1);
		SwigType_add_function(t,$5);
		if ($7.qualifier) {
		  SwigType_push(t,$7.qualifier);
		}
		Setattr($$,"decl",t);
		Setattr($$,"parms",$5);
		Setattr($$,"conversion_operator","1");
		add_symbols($$);
              }
              ;

/* isolated catch clause. */

cpp_catch_decl : CATCH LPAREN parms RPAREN LBRACE {
                 skip_balanced('{','}');
                 $$ = 0;
               }
               ;

/* public: */
cpp_protection_decl : PUBLIC COLON { 
                $$ = new_node("access");
		Setattr($$,"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              }

/* private: */
              | PRIVATE COLON { 
                $$ = new_node("access");
                Setattr($$,"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      }

/* protected: */

              | PROTECTED COLON { 
		$$ = new_node("access");
		Setattr($$,"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      }
              ;


/* ------------------------------------------------------------
   Named nested structs:
   struct sname { };
   struct sname { } id;
   struct sname : bases { };
   struct sname : bases { } id;
   typedef sname struct { } td;
   typedef sname struct : bases { } td;

   Adding inheritance, ie replacing 'ID' with 'idcolon inherit' 
   added one shift/reduce
   ------------------------------------------------------------ */

cpp_nested :   storage_class cpptype idcolon inherit LBRACE {
		cparse_start_line = cparse_line; skip_balanced('{','}');
		$<str>$ = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      } cpp_opt_declarators {
	        $$ = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    $$ = nested_forward_declaration($1, $2, $3, $3, $7);
		  } else if ($7) {
		    nested_new_struct($2, $<str>6, $7);
		  }
		}
		Delete($<str>6);
	      }

/* ------------------------------------------------------------
   Unnamed/anonymous nested structs:
   struct { };
   struct { } id;
   struct : bases { };
   struct : bases { } id;
   typedef struct { } td;
   typedef struct : bases { } td;
   ------------------------------------------------------------ */

              | storage_class cpptype inherit LBRACE {
		cparse_start_line = cparse_line; skip_balanced('{','}');
		$<str>$ = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      } cpp_opt_declarators {
	        $$ = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    const char *name = $6 ? Getattr($6, "name") : 0;
		    $$ = nested_forward_declaration($1, $2, 0, name, $6);
		  } else {
		    if ($6) {
		      nested_new_struct($2, $<str>5, $6);
		    } else {
		      Swig_warning(WARN_PARSE_UNNAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (ignored).\n", $2);
		    }
		  }
		}
		Delete($<str>5);
	      }


/* This unfortunately introduces 4 shift/reduce conflicts, so instead the somewhat hacky nested_template is used for ignore nested template classes. */
/*
              | TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype idcolon LBRACE { cparse_start_line = cparse_line; skip_balanced('{','}');
              } SEMI {
	        $$ = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line,"Nested %s not currently supported (%s ignored)\n", $5, $6);
		}
	      }
*/
              ;

/* These directives can be included inside a class definition */

cpp_swig_directive: pragma_directive { $$ = $1; }

/* A constant (includes #defines) inside a class */
             | constant_directive { $$ = $1; }

/* This is the new style rename */

             | name_directive { $$ = $1; }

/* rename directive */
             | rename_directive { $$ = $1; }
             | feature_directive { $$ = $1; }
             | varargs_directive { $$ = $1; }
             | insert_directive { $$ = $1; }
             | typemap_directive { $$ = $1; }
             | apply_directive { $$ = $1; }
             | clear_directive { $$ = $1; }
             | echo_directive { $$ = $1; }
             ;

cpp_end        : cpp_const SEMI {
	            Clear(scanner_ccode);
		    $$.throws = $1.throws;
		    $$.throwf = $1.throwf;
               }
               | cpp_const LBRACE { 
		    skip_balanced('{','}'); 
		    $$.throws = $1.throws;
		    $$.throwf = $1.throwf;
	       }
               ;

cpp_vend       : cpp_const SEMI { 
                     Clear(scanner_ccode);
                     $$.val = 0;
                     $$.qualifier = $1.qualifier;
                     $$.bitfield = 0;
                     $$.throws = $1.throws;
                     $$.throwf = $1.throwf;
                }
               | cpp_const EQUAL definetype SEMI { 
                     Clear(scanner_ccode);
                     $$.val = $3.val;
                     $$.qualifier = $1.qualifier;
                     $$.bitfield = 0;
                     $$.throws = $1.throws; 
                     $$.throwf = $1.throwf; 
               }
               | cpp_const LBRACE { 
                     skip_balanced('{','}');
                     $$.val = 0;
                     $$.qualifier = $1.qualifier;
                     $$.bitfield = 0;
                     $$.throws = $1.throws; 
                     $$.throwf = $1.throwf; 
               }
               ;


anonymous_bitfield :  storage_class type COLON expr SEMI { };

/* ====================================================================== 
 *                       PRIMITIVES
 * ====================================================================== */

storage_class  : EXTERN { $$ = "extern"; }
               | EXTERN string { 
                   if (strcmp($2,"C") == 0) {
		     $$ = "externc";
		   } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", $2);
		     $$ = 0;
		   }
               }
               | STATIC { $$ = "static"; }
               | TYPEDEF { $$ = "typedef"; }
               | VIRTUAL { $$ = "virtual"; }
               | FRIEND { $$ = "friend"; }
               | EXPLICIT { $$ = "explicit"; }
               | empty { $$ = 0; }
               ;

/* ------------------------------------------------------------------------------
   Function parameter lists
   ------------------------------------------------------------------------------ */

parms          : rawparms {
                 Parm *p;
		 $$ = $1;
		 p = $1;
                 while (p) {
		   Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   p = nextSibling(p);
                 }
               }
    	       ;

rawparms          : parm ptail {
                  set_nextSibling($1,$2);
                  $$ = $1;
		}
               | empty { $$ = 0; }
               ;

ptail          : COMMA parm ptail {
                 set_nextSibling($2,$3);
		 $$ = $2;
                }
               | empty { $$ = 0; }
               ;


parm           : rawtype parameter_declarator {
                   SwigType_push($1,$2.type);
		   $$ = NewParmWithoutFileLineInfo($1,$2.id);
		   Setfile($$,cparse_file);
		   Setline($$,cparse_line);
		   if ($2.defarg) {
		     Setattr($$,"value",$2.defarg);
		   }
		}

                | TEMPLATE LESSTHAN cpptype GREATERTHAN cpptype idcolon def_args {
                  $$ = NewParmWithoutFileLineInfo(NewStringf("template<class> %s %s", $5,$6), 0);
		  Setfile($$,cparse_file);
		  Setline($$,cparse_line);
                  if ($7.val) {
                    Setattr($$,"value",$7.val);
                  }
                }
                | PERIOD PERIOD PERIOD {
		  SwigType *t = NewString("v(...)");
		  $$ = NewParmWithoutFileLineInfo(t, 0);
		  Setfile($$,cparse_file);
		  Setline($$,cparse_line);
		}
		;

valparms        : rawvalparms {
                 Parm *p;
		 $$ = $1;
		 p = $1;
                 while (p) {
		   if (Getattr(p,"type")) {
		     Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   }
		   p = nextSibling(p);
                 }
               }
    	       ;

rawvalparms     : valparm valptail {
                  set_nextSibling($1,$2);
                  $$ = $1;
		}
               | empty { $$ = 0; }
               ;

valptail       : COMMA valparm valptail {
                 set_nextSibling($2,$3);
		 $$ = $2;
                }
               | empty { $$ = 0; }
               ;


valparm        : parm {
		  $$ = $1;
		  {
		    /* We need to make a possible adjustment for integer parameters. */
		    SwigType *type;
		    Node     *n = 0;

		    while (!n) {
		      type = Getattr($1,"type");
		      n = Swig_symbol_clookup(type,0);     /* See if we can find a node that matches the typename */
		      if ((n) && (Strcmp(nodeType(n),"cdecl") == 0)) {
			SwigType *decl = Getattr(n,"decl");
			if (!SwigType_isfunction(decl)) {
			  String *value = Getattr(n,"value");
			  if (value) {
			    String *v = Copy(value);
			    Setattr($1,"type",v);
			    Delete(v);
			    n = 0;
			  }
			}
		      } else {
			break;
		      }
		    }
		  }

               }
               | valexpr {
                  $$ = NewParmWithoutFileLineInfo(0,0);
                  Setfile($$,cparse_file);
		  Setline($$,cparse_line);
		  Setattr($$,"value",$1.val);
               }
               ;

def_args       : EQUAL definetype { 
                  $$ = $2; 
		  if ($2.type == T_ERROR) {
		    Swig_warning(WARN_PARSE_BAD_DEFAULT,cparse_file, cparse_line, "Can't set default argument (ignored)\n");
		    $$.val = 0;
		    $$.rawval = 0;
		    $$.bitfield = 0;
		    $$.throws = 0;
		    $$.throwf = 0;
		  }
               }
               | EQUAL definetype LBRACKET expr RBRACKET { 
		  $$ = $2;
		  if ($2.type == T_ERROR) {
		    Swig_warning(WARN_PARSE_BAD_DEFAULT,cparse_file, cparse_line, "Can't set default argument (ignored)\n");
		    $$ = $2;
		    $$.val = 0;
		    $$.rawval = 0;
		    $$.bitfield = 0;
		    $$.throws = 0;
		    $$.throwf = 0;
		  } else {
		    $$.val = NewStringf("%s[%s]",$2.val,$4.val); 
		  }		  
               }
               | EQUAL LBRACE {
		 skip_balanced('{','}');
		 $$.val = 0;
		 $$.rawval = 0;
                 $$.type = T_INT;
		 $$.bitfield = 0;
		 $$.throws = 0;
		 $$.throwf = 0;
	       }
               | COLON expr { 
		 $$.val = 0;
		 $$.rawval = 0;
		 $$.type = 0;
		 $$.bitfield = $2.val;
		 $$.throws = 0;
		 $$.throwf = 0;
	       }
               | empty {
                 $$.val = 0;
                 $$.rawval = 0;
                 $$.type = T_INT;
		 $$.bitfield = 0;
		 $$.throws = 0;
		 $$.throwf = 0;
               }
               ;

parameter_declarator : declarator def_args {
                 $$ = $1;
		 $$.defarg = $2.rawval ? $2.rawval : $2.val;
            }
            | abstract_declarator def_args {
              $$ = $1;
	      $$.defarg = $2.rawval ? $2.rawval : $2.val;
            }
            | def_args {
   	      $$.type = 0;
              $$.id = 0;
	      $$.defarg = $1.rawval ? $1.rawval : $1.val;
            }
            ;

typemap_parameter_declarator : declarator {
                 $$ = $1;
		 if (SwigType_isfunction($1.type)) {
		   Delete(SwigType_pop_function($1.type));
		 } else if (SwigType_isarray($1.type)) {
		   SwigType *ta = SwigType_pop_arrays($1.type);
		   if (SwigType_isfunction($1.type)) {
		     Delete(SwigType_pop_function($1.type));
		   } else {
		     $$.parms = 0;
		   }
		   SwigType_push($1.type,ta);
		   Delete(ta);
		 } else {
		   $$.parms = 0;
		 }
            }
            | abstract_declarator {
              $$ = $1;
	      if (SwigType_isfunction($1.type)) {
		Delete(SwigType_pop_function($1.type));
	      } else if (SwigType_isarray($1.type)) {
		SwigType *ta = SwigType_pop_arrays($1.type);
		if (SwigType_isfunction($1.type)) {
		  Delete(SwigType_pop_function($1.type));
		} else {
		  $$.parms = 0;
		}
		SwigType_push($1.type,ta);
		Delete(ta);
	      } else {
		$$.parms = 0;
	      }
            }
            | empty {
   	      $$.type = 0;
              $$.id = 0;
	      $$.parms = 0;
	      }
            ;


declarator :  pointer notso_direct_declarator {
              $$ = $2;
	      if ($$.type) {
		SwigType_push($1,$$.type);
		Delete($$.type);
	      }
	      $$.type = $1;
           }
           | pointer AND notso_direct_declarator {
              $$ = $3;
	      SwigType_add_reference($1);
              if ($$.type) {
		SwigType_push($1,$$.type);
		Delete($$.type);
	      }
	      $$.type = $1;
           }
           | direct_declarator {
              $$ = $1;
	      if (!$$.type) $$.type = NewStringEmpty();
           }
           | AND notso_direct_declarator { 
	     $$ = $2;
	     $$.type = NewStringEmpty();
	     SwigType_add_reference($$.type);
	     if ($2.type) {
	       SwigType_push($$.type,$2.type);
	       Delete($2.type);
	     }
           }
           | idcolon DSTAR notso_direct_declarator { 
	     SwigType *t = NewStringEmpty();

	     $$ = $3;
	     SwigType_add_memberpointer(t,$1);
	     if ($$.type) {
	       SwigType_push(t,$$.type);
	       Delete($$.type);
	     }
	     $$.type = t;
	     } 
           | pointer idcolon DSTAR notso_direct_declarator { 
	     SwigType *t = NewStringEmpty();
	     $$ = $4;
	     SwigType_add_memberpointer(t,$2);
	     SwigType_push($1,t);
	     if ($$.type) {
	       SwigType_push($1,$$.type);
	       Delete($$.type);
	     }
	     $$.type = $1;
	     Delete(t);
	   }
           | pointer idcolon DSTAR AND notso_direct_declarator { 
	     $$ = $5;
	     SwigType_add_memberpointer($1,$2);
	     SwigType_add_reference($1);
	     if ($$.type) {
	       SwigType_push($1,$$.type);
	       Delete($$.type);
	     }
	     $$.type = $1;
	   }
           | idcolon DSTAR AND notso_direct_declarator { 
	     SwigType *t = NewStringEmpty();
	     $$ = $4;
	     SwigType_add_memberpointer(t,$1);
	     SwigType_add_reference(t);
	     if ($$.type) {
	       SwigType_push(t,$$.type);
	       Delete($$.type);
	     } 
	     $$.type = t;
	   }
           ;

notso_direct_declarator : idcolon {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
                 $$.id = Char($1);
		 $$.type = 0;
		 $$.parms = 0;
		 $$.have_parms = 0;
                  }
                  | NOT idcolon {
                  $$.id = Char(NewStringf("~%s",$2));
                  $$.type = 0;
                  $$.parms = 0;
                  $$.have_parms = 0;
                  }

/* This generate a shift-reduce conflict with constructors */
                 | LPAREN idcolon RPAREN {
                  $$.id = Char($2);
                  $$.type = 0;
                  $$.parms = 0;
                  $$.have_parms = 0;
                  }

/*
                  | LPAREN AND idcolon RPAREN {
                     $$.id = Char($3);
                     $$.type = 0;
                     $$.parms = 0;
                     $$.have_parms = 0;
                  }
*/
/* Technically, this should be LPAREN declarator RPAREN, but we get reduce/reduce conflicts */
                  | LPAREN pointer notso_direct_declarator RPAREN {
		    $$ = $3;
		    if ($$.type) {
		      SwigType_push($2,$$.type);
		      Delete($$.type);
		    }
		    $$.type = $2;
                  }
                  | LPAREN idcolon DSTAR notso_direct_declarator RPAREN {
		    SwigType *t;
		    $$ = $4;
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,$2);
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
		    }
                  | notso_direct_declarator LBRACKET RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | notso_direct_declarator LBRACKET expr RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,$3.val);
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | notso_direct_declarator LPAREN parms RPAREN {
		    SwigType *t;
                    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_function(t,$3);
		    if (!$$.have_parms) {
		      $$.parms = $3;
		      $$.have_parms = 1;
		    }
		    if (!$$.type) {
		      $$.type = t;
		    } else {
		      SwigType_push(t, $$.type);
		      Delete($$.type);
		      $$.type = t;
		    }
		  }
                  ;

direct_declarator : idcolon {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
                 $$.id = Char($1);
		 $$.type = 0;
		 $$.parms = 0;
		 $$.have_parms = 0;
                  }

                  | NOT idcolon {
                  $$.id = Char(NewStringf("~%s",$2));
                  $$.type = 0;
                  $$.parms = 0;
                  $$.have_parms = 0;
                  }

/* This generate a shift-reduce conflict with constructors */
/*
                  | LPAREN idcolon RPAREN {
                  $$.id = Char($2);
                  $$.type = 0;
                  $$.parms = 0;
                  $$.have_parms = 0;
                  }
*/
/* Technically, this should be LPAREN declarator RPAREN, but we get reduce/reduce conflicts */
                  | LPAREN pointer direct_declarator RPAREN {
		    $$ = $3;
		    if ($$.type) {
		      SwigType_push($2,$$.type);
		      Delete($$.type);
		    }
		    $$.type = $2;
                  }
                  | LPAREN AND direct_declarator RPAREN {
                    $$ = $3;
		    if (!$$.type) {
		      $$.type = NewStringEmpty();
		    }
		    SwigType_add_reference($$.type);
                  }
                  | LPAREN idcolon DSTAR direct_declarator RPAREN {
		    SwigType *t;
		    $$ = $4;
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,$2);
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
		    }
                  | direct_declarator LBRACKET RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | direct_declarator LBRACKET expr RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,$3.val);
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | direct_declarator LPAREN parms RPAREN {
		    SwigType *t;
                    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_function(t,$3);
		    if (!$$.have_parms) {
		      $$.parms = $3;
		      $$.have_parms = 1;
		    }
		    if (!$$.type) {
		      $$.type = t;
		    } else {
		      SwigType_push(t, $$.type);
		      Delete($$.type);
		      $$.type = t;
		    }
		  }
                  ;

abstract_declarator : pointer {
		    $$.type = $1;
                    $$.id = 0;
		    $$.parms = 0;
		    $$.have_parms = 0;
                  }
                  | pointer direct_abstract_declarator { 
                     $$ = $2;
                     SwigType_push($1,$2.type);
		     $$.type = $1;
		     Delete($2.type);
                  }
                  | pointer AND {
		    $$.type = $1;
		    SwigType_add_reference($$.type);
		    $$.id = 0;
		    $$.parms = 0;
		    $$.have_parms = 0;
		  }
                  | pointer AND direct_abstract_declarator {
		    $$ = $3;
		    SwigType_add_reference($1);
		    if ($$.type) {
		      SwigType_push($1,$$.type);
		      Delete($$.type);
		    }
		    $$.type = $1;
                  }
                  | direct_abstract_declarator {
		    $$ = $1;
                  }
                  | AND direct_abstract_declarator {
		    $$ = $2;
		    $$.type = NewStringEmpty();
		    SwigType_add_reference($$.type);
		    if ($2.type) {
		      SwigType_push($$.type,$2.type);
		      Delete($2.type);
		    }
                  }
                  | AND { 
                    $$.id = 0;
                    $$.parms = 0;
		    $$.have_parms = 0;
                    $$.type = NewStringEmpty();
		    SwigType_add_reference($$.type);
                  }
                  | idcolon DSTAR { 
		    $$.type = NewStringEmpty();
                    SwigType_add_memberpointer($$.type,$1);
                    $$.id = 0;
                    $$.parms = 0;
		    $$.have_parms = 0;
      	          }
                  | pointer idcolon DSTAR { 
		    SwigType *t = NewStringEmpty();
                    $$.type = $1;
		    $$.id = 0;
		    $$.parms = 0;
		    $$.have_parms = 0;
		    SwigType_add_memberpointer(t,$2);
		    SwigType_push($$.type,t);
		    Delete(t);
                  }
                  | pointer idcolon DSTAR direct_abstract_declarator { 
		    $$ = $4;
		    SwigType_add_memberpointer($1,$2);
		    if ($$.type) {
		      SwigType_push($1,$$.type);
		      Delete($$.type);
		    }
		    $$.type = $1;
                  }
                  ;

direct_abstract_declarator : direct_abstract_declarator LBRACKET RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | direct_abstract_declarator LBRACKET expr RBRACKET { 
		    SwigType *t;
		    $$ = $1;
		    t = NewStringEmpty();
		    SwigType_add_array(t,$3.val);
		    if ($$.type) {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		    }
		    $$.type = t;
                  }
                  | LBRACKET RBRACKET { 
		    $$.type = NewStringEmpty();
		    $$.id = 0;
		    $$.parms = 0;
		    $$.have_parms = 0;
		    SwigType_add_array($$.type,(char*)"");
                  }
                  | LBRACKET expr RBRACKET { 
		    $$.type = NewStringEmpty();
		    $$.id = 0;
		    $$.parms = 0;
		    $$.have_parms = 0;
		    SwigType_add_array($$.type,$2.val);
		  }
                  | LPAREN abstract_declarator RPAREN {
                    $$ = $2;
		  }
                  | direct_abstract_declarator LPAREN parms RPAREN {
		    SwigType *t;
                    $$ = $1;
		    t = NewStringEmpty();
                    SwigType_add_function(t,$3);
		    if (!$$.type) {
		      $$.type = t;
		    } else {
		      SwigType_push(t,$$.type);
		      Delete($$.type);
		      $$.type = t;
		    }
		    if (!$$.have_parms) {
		      $$.parms = $3;
		      $$.have_parms = 1;
		    }
		  }
                  | LPAREN parms RPAREN {
                    $$.type = NewStringEmpty();
                    SwigType_add_function($$.type,$2);
		    $$.parms = $2;
		    $$.have_parms = 1;
		    $$.id = 0;
                  }
                  ;


pointer    : STAR type_qualifier pointer { 
               $$ = NewStringEmpty();
               SwigType_add_pointer($$);
	       SwigType_push($$,$2);
	       SwigType_push($$,$3);
	       Delete($3);
           }
           | STAR pointer {
	     $$ = NewStringEmpty();
	     SwigType_add_pointer($$);
	     SwigType_push($$,$2);
	     Delete($2);
	     } 
           | STAR type_qualifier { 
	     	$$ = NewStringEmpty();	
		SwigType_add_pointer($$);
	        SwigType_push($$,$2);
           }
           | STAR {
	      $$ = NewStringEmpty();
	      SwigType_add_pointer($$);
           }
           ;

type_qualifier : type_qualifier_raw {
	          $$ = NewStringEmpty();
	          if ($1) SwigType_add_qualifier($$,$1);
               }
               | type_qualifier_raw type_qualifier {
		  $$ = $2;
	          if ($1) SwigType_add_qualifier($$,$1);
               }
               ;

type_qualifier_raw :  CONST_QUAL { $$ = "const"; }
                   |  VOLATILE { $$ = "volatile"; }
                   |  REGISTER { $$ = 0; }
                   ;

/* Data type must be a built in type or an identifier for user-defined types
   This type can be preceded by a modifier. */

type            : rawtype {
                   $$ = $1;
                   Replace($$,"typename ","", DOH_REPLACE_ANY);
                }
                ;

rawtype       : type_qualifier type_right {
                   $$ = $2;
	           SwigType_push($$,$1);
               }
               | type_right { $$ = $1; }
               | type_right type_qualifier {
		  $$ = $1;
	          SwigType_push($$,$2);
	       }
               | type_qualifier type_right type_qualifier {
		  $$ = $2;
	          SwigType_push($$,$3);
	          SwigType_push($$,$1);
	       }
               ;

type_right     : primitive_type { $$ = $1;
                  /* Printf(stdout,"primitive = '%s'\n", $$);*/
                }
               | TYPE_BOOL { $$ = $1; }
               | TYPE_VOID { $$ = $1; }
               | TYPE_TYPEDEF template_decl { $$ = NewStringf("%s%s",$1,$2); }
               | ENUM idcolon { $$ = NewStringf("enum %s", $2); }
               | TYPE_RAW { $$ = $1; }

               | idcolon {
		  $$ = $1;
               }
               | cpptype idcolon { 
		 $$ = NewStringf("%s %s", $1, $2);
               }
               ;

primitive_type : primitive_type_list {
		 if (!$1.type) $1.type = NewString("int");
		 if ($1.us) {
		   $$ = NewStringf("%s %s", $1.us, $1.type);
		   Delete($1.us);
                   Delete($1.type);
		 } else {
                   $$ = $1.type;
		 }
		 if (Cmp($$,"signed int") == 0) {
		   Delete($$);
		   $$ = NewString("int");
                 } else if (Cmp($$,"signed long") == 0) {
		   Delete($$);
                   $$ = NewString("long");
                 } else if (Cmp($$,"signed short") == 0) {
		   Delete($$);
		   $$ = NewString("short");
		 } else if (Cmp($$,"signed long long") == 0) {
		   Delete($$);
		   $$ = NewString("long long");
		 }
               }
               ;

primitive_type_list : type_specifier { 
                 $$ = $1;
               }
               | type_specifier primitive_type_list {
                    if ($1.us && $2.us) {
		      Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", $2.us);
		    }
                    $$ = $2;
                    if ($1.us) $$.us = $1.us;
		    if ($1.type) {
		      if (!$2.type) $$.type = $1.type;
		      else {
			int err = 0;
			if ((Cmp($1.type,"long") == 0)) {
			  if ((Cmp($2.type,"long") == 0) || (Strncmp($2.type,"double",6) == 0)) {
			    $$.type = NewStringf("long %s", $2.type);
			  } else if (Cmp($2.type,"int") == 0) {
			    $$.type = $1.type;
			  } else {
			    err = 1;
			  }
			} else if ((Cmp($1.type,"short")) == 0) {
			  if (Cmp($2.type,"int") == 0) {
			    $$.type = $1.type;
			  } else {
			    err = 1;
			  }
			} else if (Cmp($1.type,"int") == 0) {
			  $$.type = $2.type;
			} else if (Cmp($1.type,"double") == 0) {
			  if (Cmp($2.type,"long") == 0) {
			    $$.type = NewString("long double");
			  } else if (Cmp($2.type,"complex") == 0) {
			    $$.type = NewString("double complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp($1.type,"float") == 0) {
			  if (Cmp($2.type,"complex") == 0) {
			    $$.type = NewString("float complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp($1.type,"complex") == 0) {
			  $$.type = NewStringf("%s complex", $2.type);
			} else {
			  err = 1;
			}
			if (err) {
			  Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", $1.type);
			}
		      }
		    }
               }
               ; 


type_specifier : TYPE_INT { 
		    $$.type = NewString("int");
                    $$.us = 0;
               }
               | TYPE_SHORT { 
                    $$.type = NewString("short");
                    $$.us = 0;
                }
               | TYPE_LONG { 
                    $$.type = NewString("long");
                    $$.us = 0;
                }
               | TYPE_CHAR { 
                    $$.type = NewString("char");
                    $$.us = 0;
                }
               | TYPE_WCHAR { 
                    $$.type = NewString("wchar_t");
                    $$.us = 0;
                }
               | TYPE_FLOAT { 
                    $$.type = NewString("float");
                    $$.us = 0;
                }
               | TYPE_DOUBLE { 
                    $$.type = NewString("double");
                    $$.us = 0;
                }
               | TYPE_SIGNED { 
                    $$.us = NewString("signed");
                    $$.type = 0;
                }
               | TYPE_UNSIGNED { 
                    $$.us = NewString("unsigned");
                    $$.type = 0;
                }
               | TYPE_COMPLEX { 
                    $$.type = NewString("complex");
                    $$.us = 0;
                }
               | TYPE_NON_ISO_INT8 { 
                    $$.type = NewString("__int8");
                    $$.us = 0;
                }
               | TYPE_NON_ISO_INT16 { 
                    $$.type = NewString("__int16");
                    $$.us = 0;
                }
               | TYPE_NON_ISO_INT32 { 
                    $$.type = NewString("__int32");
                    $$.us = 0;
                }
               | TYPE_NON_ISO_INT64 { 
                    $$.type = NewString("__int64");
                    $$.us = 0;
                }
               ;

definetype     : { /* scanner_check_typedef(); */ } expr {
                   $$ = $2;
		   if ($$.type == T_STRING) {
		     $$.rawval = NewStringf("\"%(escape)s\"",$$.val);
		   } else if ($$.type != T_CHAR) {
		     $$.rawval = 0;
		   }
		   $$.bitfield = 0;
		   $$.throws = 0;
		   $$.throwf = 0;
		   scanner_ignore_typedef();
                }
/*
                | string {
                   $$.val = NewString($1);
		   $$.rawval = NewStringf("\"%(escape)s\"",$$.val);
                   $$.type = T_STRING;
		   $$.bitfield = 0;
		   $$.throws = 0;
		   $$.throwf = 0;
		}
*/
                ;

/* Some stuff for handling enums */

ename          :  ID { $$ = $1; }
               |  empty { $$ = (char *) 0;}
               ;

enumlist       :  enumlist COMMA edecl { 

                  /* Ignore if there is a trailing comma in the enum list */
                  if ($3) {
                    Node *leftSibling = Getattr($1,"_last");
                    if (!leftSibling) {
                      leftSibling=$1;
                    }
                    set_nextSibling(leftSibling,$3);
                    Setattr($1,"_last",$3);
                  }
		  $$ = $1;
               }
               |  edecl { 
                   $$ = $1; 
                   if ($1) {
                     Setattr($1,"_last",$1);
                   }
               }
               ;

edecl          :  ID {
		   SwigType *type = NewSwigType(T_INT);
		   $$ = new_node("enumitem");
		   Setattr($$,"name",$1);
		   Setattr($$,"type",type);
		   SetFlag($$,"feature:immutable");
		   Delete(type);
		 }
                 | ID EQUAL etype {
		   $$ = new_node("enumitem");
		   Setattr($$,"name",$1);
		   Setattr($$,"enumvalue", $3.val);
	           if ($3.type == T_CHAR) {
		     SwigType *type = NewSwigType(T_CHAR);
		     Setattr($$,"value",NewStringf("\'%(escape)s\'", $3.val));
		     Setattr($$,"type",type);
		     Delete(type);
		   } else {
		     SwigType *type = NewSwigType(T_INT);
		     Setattr($$,"value",$1);
		     Setattr($$,"type",type);
		     Delete(type);
		   }
		   SetFlag($$,"feature:immutable");
                 }
                 | empty { $$ = 0; }
                 ;

etype            : expr {
                   $$ = $1;
		   if (($$.type != T_INT) && ($$.type != T_UINT) &&
		       ($$.type != T_LONG) && ($$.type != T_ULONG) &&
		       ($$.type != T_SHORT) && ($$.type != T_USHORT) &&
		       ($$.type != T_SCHAR) && ($$.type != T_UCHAR) &&
		       ($$.type != T_CHAR)) {
		     Swig_error(cparse_file,cparse_line,"Type error. Expecting an int\n");
		   }
		   if ($$.type == T_CHAR) $$.type = T_INT;
                }
               ;

/* Arithmetic expressions.  Used for constants, C++ templates, and other cool stuff. */

expr           : valexpr { $$ = $1; }
               | type {
		 Node *n;
		 $$.val = $1;
		 $$.type = T_INT;
		 /* Check if value is in scope */
		 n = Swig_symbol_clookup($1,0);
		 if (n) {
                   /* A band-aid for enum values used in expressions. */
                   if (Strcmp(nodeType(n),"enumitem") == 0) {
                     String *q = Swig_symbol_qualified(n);
                     if (q) {
                       $$.val = NewStringf("%s::%s", q, Getattr(n,"name"));
                       Delete(q);
                     }
                   }
		 }
               }
	       ;

valexpr        : exprnum { $$ = $1; }
               | string {
		    $$.val = NewString($1);
                    $$.type = T_STRING;
               }
               | SIZEOF LPAREN type parameter_declarator RPAREN {
		  SwigType_push($3,$4.type);
		  $$.val = NewStringf("sizeof(%s)",SwigType_str($3,0));
		  $$.type = T_ULONG;
               }
               | exprcompound { $$ = $1; }
               | CHARCONST {
		  $$.val = NewString($1);
		  if (Len($$.val)) {
		    $$.rawval = NewStringf("'%(escape)s'", $$.val);
		  } else {
		    $$.rawval = NewString("'\\0'");
		  }
		  $$.type = T_CHAR;
		  $$.bitfield = 0;
		  $$.throws = 0;
		  $$.throwf = 0;
	       }

/* grouping */
               |  LPAREN expr RPAREN %prec CAST {
   	            $$.val = NewStringf("(%s)",$2.val);
		    $$.type = $2.type;
   	       }

/* A few common casting operations */

               | LPAREN expr RPAREN expr %prec CAST {
                 $$ = $4;
		 if ($4.type != T_STRING) {
		   switch ($2.type) {
		     case T_FLOAT:
		     case T_DOUBLE:
		     case T_LONGDOUBLE:
		     case T_FLTCPLX:
		     case T_DBLCPLX:
		       $$.val = NewStringf("(%s)%s", $2.val, $4.val); /* SwigType_str and decimal points don't mix! */
		       break;
		     default:
		       $$.val = NewStringf("(%s) %s", SwigType_str($2.val,0), $4.val);
		       break;
		   }
		 }
 	       }
               | LPAREN expr pointer RPAREN expr %prec CAST {
                 $$ = $5;
		 if ($5.type != T_STRING) {
		   SwigType_push($2.val,$3);
		   $$.val = NewStringf("(%s) %s", SwigType_str($2.val,0), $5.val);
		 }
 	       }
               | LPAREN expr AND RPAREN expr %prec CAST {
                 $$ = $5;
		 if ($5.type != T_STRING) {
		   SwigType_add_reference($2.val);
		   $$.val = NewStringf("(%s) %s", SwigType_str($2.val,0), $5.val);
		 }
 	       }
               | LPAREN expr pointer AND RPAREN expr %prec CAST {
                 $$ = $6;
		 if ($6.type != T_STRING) {
		   SwigType_push($2.val,$3);
		   SwigType_add_reference($2.val);
		   $$.val = NewStringf("(%s) %s", SwigType_str($2.val,0), $6.val);
		 }
 	       }
               | AND expr {
		 $$ = $2;
                 $$.val = NewStringf("&%s",$2.val);
	       }
               | STAR expr {
		 $$ = $2;
                 $$.val = NewStringf("*%s",$2.val);
	       }
               ;

exprnum        :  NUM_INT { $$ = $1; }
               |  NUM_FLOAT { $$ = $1; }
               |  NUM_UNSIGNED { $$ = $1; }
               |  NUM_LONG { $$ = $1; }
               |  NUM_ULONG { $$ = $1; }
               |  NUM_LONGLONG { $$ = $1; }
               |  NUM_ULONGLONG { $$ = $1; }
               |  NUM_BOOL { $$ = $1; }
               ;

exprcompound   : expr PLUS expr {
		 $$.val = NewStringf("%s+%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr MINUS expr {
		 $$.val = NewStringf("%s-%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr STAR expr {
		 $$.val = NewStringf("%s*%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr SLASH expr {
		 $$.val = NewStringf("%s/%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr MODULO expr {
		 $$.val = NewStringf("%s%%%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr AND expr {
		 $$.val = NewStringf("%s&%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr OR expr {
		 $$.val = NewStringf("%s|%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr XOR expr {
		 $$.val = NewStringf("%s^%s",$1.val,$3.val);
		 $$.type = promote($1.type,$3.type);
	       }
               | expr LSHIFT expr {
		 $$.val = NewStringf("%s << %s",$1.val,$3.val);
		 $$.type = promote_type($1.type);
	       }
               | expr RSHIFT expr {
		 $$.val = NewStringf("%s >> %s",$1.val,$3.val);
		 $$.type = promote_type($1.type);
	       }
               | expr LAND expr {
		 $$.val = NewStringf("%s&&%s",$1.val,$3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
               | expr LOR expr {
		 $$.val = NewStringf("%s||%s",$1.val,$3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
               | expr EQUALTO expr {
		 $$.val = NewStringf("%s==%s",$1.val,$3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
               | expr NOTEQUALTO expr {
		 $$.val = NewStringf("%s!=%s",$1.val,$3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
/* Sadly this causes 2 reduce-reduce conflicts with templates.  FIXME resolve these.
               | expr GREATERTHAN expr {
		 $$.val = NewStringf("%s < %s", $1.val, $3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
               | expr LESSTHAN expr {
		 $$.val = NewStringf("%s > %s", $1.val, $3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
*/
               | expr GREATERTHANOREQUALTO expr {
		 $$.val = NewStringf("%s >= %s", $1.val, $3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
               | expr LESSTHANOREQUALTO expr {
		 $$.val = NewStringf("%s <= %s", $1.val, $3.val);
		 $$.type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
	       | expr QUESTIONMARK expr COLON expr %prec QUESTIONMARK {
		 $$.val = NewStringf("%s?%s:%s", $1.val, $3.val, $5.val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 $$.type = promote($3.type, $5.type);
	       }
               | MINUS expr %prec UMINUS {
		 $$.val = NewStringf("-%s",$2.val);
		 $$.type = $2.type;
	       }
               | PLUS expr %prec UMINUS {
                 $$.val = NewStringf("+%s",$2.val);
		 $$.type = $2.type;
	       }
               | NOT expr {
		 $$.val = NewStringf("~%s",$2.val);
		 $$.type = $2.type;
	       }
               | LNOT expr {
                 $$.val = NewStringf("!%s",$2.val);
		 $$.type = T_INT;
	       }
               | type LPAREN {
		 String *qty;
                 skip_balanced('(',')');
		 qty = Swig_symbol_type_qualify($1,0);
		 if (SwigType_istemplate(qty)) {
		   String *nstr = SwigType_namestr(qty);
		   Delete(qty);
		   qty = nstr;
		 }
		 $$.val = NewStringf("%s%s",qty,scanner_ccode);
		 Clear(scanner_ccode);
		 $$.type = T_INT;
		 Delete(qty);
               }
               ;

inherit        : raw_inherit {
		 $$ = $1;
               }
               ;

raw_inherit     : COLON { inherit_list = 1; } base_list { $$ = $3; inherit_list = 0; }
                | empty { $$ = 0; }
                ;

base_list      : base_specifier {
		   Hash *list = NewHash();
		   Node *base = $1;
		   Node *name = Getattr(base,"name");
		   List *lpublic = NewList();
		   List *lprotected = NewList();
		   List *lprivate = NewList();
		   Setattr(list,"public",lpublic);
		   Setattr(list,"protected",lprotected);
		   Setattr(list,"private",lprivate);
		   Delete(lpublic);
		   Delete(lprotected);
		   Delete(lprivate);
		   Append(Getattr(list,Getattr(base,"access")),name);
	           $$ = list;
               }

               | base_list COMMA base_specifier {
		   Hash *list = $1;
		   Node *base = $3;
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
                   $$ = list;
               }
               ;

base_specifier : opt_virtual idcolon {
		 $$ = NewHash();
		 Setfile($$,cparse_file);
		 Setline($$,cparse_line);
		 Setattr($$,"name",$2);
                 if (last_cpptype && (Strcmp(last_cpptype,"struct") != 0)) {
		   Setattr($$,"access","private");
		   Swig_warning(WARN_PARSE_NO_ACCESS,cparse_file,cparse_line,
				"No access specifier given for base class %s (ignored).\n",$2);
                 } else {
		   Setattr($$,"access","public");
		 }
               }
	       | opt_virtual access_specifier opt_virtual idcolon {
		 $$ = NewHash();
		 Setfile($$,cparse_file);
		 Setline($$,cparse_line);
		 Setattr($$,"name",$4);
		 Setattr($$,"access",$2);
	         if (Strcmp($2,"public") != 0) {
		   Swig_warning(WARN_PARSE_PRIVATE_INHERIT, cparse_file, 
				cparse_line,"%s inheritance ignored.\n", $2);
		 }
               }
               ;

access_specifier :  PUBLIC { $$ = (char*)"public"; }
               | PRIVATE { $$ = (char*)"private"; }
               | PROTECTED { $$ = (char*)"protected"; }
               ;


templcpptype   : CLASS { 
                   $$ = (char*)"class"; 
		   if (!inherit_list) last_cpptype = $$;
               }
               | TYPENAME { 
                   $$ = (char *)"typename"; 
		   if (!inherit_list) last_cpptype = $$;
               }
               ;

cpptype        : templcpptype {
                 $$ = $1;
               }
               | STRUCT { 
                   $$ = (char*)"struct"; 
		   if (!inherit_list) last_cpptype = $$;
               }
               | UNION {
                   $$ = (char*)"union"; 
		   if (!inherit_list) last_cpptype = $$;
               }
               ;

opt_virtual    : VIRTUAL
               | empty
               ;

cpp_const      : type_qualifier {
                    $$.qualifier = $1;
                    $$.throws = 0;
                    $$.throwf = 0;
               }
               | THROW LPAREN parms RPAREN {
                    $$.qualifier = 0;
                    $$.throws = $3;
                    $$.throwf = NewString("1");
               }
               | type_qualifier THROW LPAREN parms RPAREN {
                    $$.qualifier = $1;
                    $$.throws = $4;
                    $$.throwf = NewString("1");
               }
               | empty { 
                    $$.qualifier = 0; 
                    $$.throws = 0;
                    $$.throwf = 0;
               }
               ;

ctor_end       : cpp_const ctor_initializer SEMI { 
                    Clear(scanner_ccode); 
                    $$.have_parms = 0; 
                    $$.defarg = 0; 
		    $$.throws = $1.throws;
		    $$.throwf = $1.throwf;
               }
               | cpp_const ctor_initializer LBRACE { 
                    skip_balanced('{','}'); 
                    $$.have_parms = 0; 
                    $$.defarg = 0; 
                    $$.throws = $1.throws;
                    $$.throwf = $1.throwf;
               }
               | LPAREN parms RPAREN SEMI { 
                    Clear(scanner_ccode); 
                    $$.parms = $2; 
                    $$.have_parms = 1; 
                    $$.defarg = 0; 
		    $$.throws = 0;
		    $$.throwf = 0;
               }
               | LPAREN parms RPAREN LBRACE {
                    skip_balanced('{','}'); 
                    $$.parms = $2; 
                    $$.have_parms = 1; 
                    $$.defarg = 0; 
                    $$.throws = 0;
                    $$.throwf = 0;
               }
               | EQUAL definetype SEMI { 
                    $$.have_parms = 0; 
                    $$.defarg = $2.val; 
                    $$.throws = 0;
                    $$.throwf = 0;
               }
               ;

ctor_initializer : COLON mem_initializer_list
               | empty
               ;

mem_initializer_list : mem_initializer
               | mem_initializer_list COMMA mem_initializer
               ;

mem_initializer : idcolon LPAREN {
	            skip_balanced('(',')');
                    Clear(scanner_ccode);
            	}
                ;

template_decl : LESSTHAN valparms GREATERTHAN { 
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,$2);
                     $$ = Char(s);
		     scanner_last_id(1);
                 }
               | empty { $$ = (char*)"";  }
               ;

idstring       : ID { $$ = $1; }
               | string { $$ = $1; }
               ;

idstringopt    : idstring { $$ = $1; }
               | empty { $$ = 0; }
               ;
 
idcolon        : idtemplate idcolontail { 
                  $$ = 0;
		  if (!$$) $$ = NewStringf("%s%s", $1,$2);
      	          Delete($2);
               }
               | NONID DCOLON idtemplate idcolontail { 
		 $$ = NewStringf("::%s%s",$3,$4);
                 Delete($4);
               }
               | idtemplate {
		 $$ = NewString($1);
   	       }     
               | NONID DCOLON idtemplate {
		 $$ = NewStringf("::%s",$3);
               }
               | OPERATOR {
                 $$ = NewString($1);
	       }
               | NONID DCOLON OPERATOR {
                 $$ = NewStringf("::%s",$3);
               }
               ;

idcolontail    : DCOLON idtemplate idcolontail {
                   $$ = NewStringf("::%s%s",$2,$3);
		   Delete($3);
               }
               | DCOLON idtemplate {
                   $$ = NewStringf("::%s",$2);
               }
               | DCOLON OPERATOR {
                   $$ = NewStringf("::%s",$2);
               }
/*               | DCOLON COPERATOR {
                 $$ = NewString($2);                 
		 } */

               | DCNOT idtemplate {
		 $$ = NewStringf("::~%s",$2);
               }
               ;


idtemplate    : ID template_decl {
                  $$ = NewStringf("%s%s",$1,$2);
		  /*		  if (Len($2)) {
		    scanner_last_id(1);
		    } */
              }
              ;

/* Identifier, but no templates */
idcolonnt     : ID idcolontailnt { 
                  $$ = 0;
		  if (!$$) $$ = NewStringf("%s%s", $1,$2);
      	          Delete($2);
               }
               | NONID DCOLON ID idcolontailnt { 
		 $$ = NewStringf("::%s%s",$3,$4);
                 Delete($4);
               }
               | ID {
		 $$ = NewString($1);
   	       }     
               | NONID DCOLON ID {
		 $$ = NewStringf("::%s",$3);
               }
               | OPERATOR {
                 $$ = NewString($1);
	       }
               | NONID DCOLON OPERATOR {
                 $$ = NewStringf("::%s",$3);
               }
               ;

idcolontailnt   : DCOLON ID idcolontailnt {
                   $$ = NewStringf("::%s%s",$2,$3);
		   Delete($3);
               }
               | DCOLON ID {
                   $$ = NewStringf("::%s",$2);
               }
               | DCOLON OPERATOR {
                   $$ = NewStringf("::%s",$2);
               }
               | DCNOT ID {
		 $$ = NewStringf("::~%s",$2);
               }
               ;

/* Concatenated strings */
string         : string STRING { 
                   $$ = (char *) malloc(strlen($1)+strlen($2)+1);
                   strcpy($$,$1);
                   strcat($$,$2);
               }
               | STRING { $$ = $1;}
               ; 

stringbrace    : string {
		 $$ = NewString($1);
               }
               | LBRACE {
                  skip_balanced('{','}');
		  $$ = NewString(scanner_ccode);
               }
              | HBLOCK {
		 $$ = $1;
              }
               ;

options        : LPAREN kwargs RPAREN {
                  Hash *n;
                  $$ = NewHash();
                  n = $2;
                  while(n) {
                     String *name, *value;
                     name = Getattr(n,"name");
                     value = Getattr(n,"value");
		     if (!value) value = (String *) "1";
                     Setattr($$,name, value);
		     n = nextSibling(n);
		  }
               }   
               | empty { $$ = 0; };

 
/* Keyword arguments */
kwargs         : idstring EQUAL stringnum {
		 $$ = NewHash();
		 Setattr($$,"name",$1);
		 Setattr($$,"value",$3);
               }
               | idstring EQUAL stringnum COMMA kwargs {
		 $$ = NewHash();
		 Setattr($$,"name",$1);
		 Setattr($$,"value",$3);
		 set_nextSibling($$,$5);
               }
               | idstring {
                 $$ = NewHash();
                 Setattr($$,"name",$1);
	       }
               | idstring COMMA kwargs {
                 $$ = NewHash();
                 Setattr($$,"name",$1);
                 set_nextSibling($$,$3);
               }
               | idstring EQUAL stringtype  {
                 $$ = $3;
		 Setattr($$,"name",$1);
               }
               | idstring EQUAL stringtype COMMA kwargs {
                 $$ = $3;
		 Setattr($$,"name",$1);
		 set_nextSibling($$,$5);
               }
               ;

stringnum      : string {
		 $$ = $1;
               }
               | exprnum {
                 $$ = Char($1.val);
               }
               ;

empty          :   ;

%%

SwigType *Swig_cparse_type(String *s) {
   String *ns;
   ns = NewStringf("%s;",s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSETYPE);
   yyparse();
   /*   Printf(stdout,"typeparse: '%s' ---> '%s'\n", s, top); */
   return top;
}


Parm *Swig_cparse_parm(String *s) {
   String *ns;
   ns = NewStringf("%s;",s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARM);
   yyparse();
   /*   Printf(stdout,"typeparse: '%s' ---> '%s'\n", s, top); */
   Delete(ns);
   return top;
}


ParmList *Swig_cparse_parms(String *s, Node *file_line_node) {
   String *ns;
   char *cs = Char(s);
   if (cs && cs[0] != '(') {
     ns = NewStringf("(%s);",s);
   } else {
     ns = NewStringf("%s;",s);
   }
   Setfile(ns, Getfile(file_line_node));
   Setline(ns, Getline(file_line_node));
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARMS);
   yyparse();
   /*   Printf(stdout,"typeparse: '%s' ---> '%s'\n", s, top); */
   return top;
}

