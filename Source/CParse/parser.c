
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.4.1"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1

/* Using locations.  */
#define YYLSP_NEEDED 0



/* Copy the first part of user declarations.  */

/* Line 189 of yacc.c  */
#line 16 "parser.y"


#define yylex yylex

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
static Hash    *classes_typedefs = 0; /* Hash table of typedef classes: typedef struct X {...} Y; */
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

static String *resolve_create_node_scope(String *cname);


Hash *Swig_cparse_features(void) {
  static Hash   *features_hash = 0;
  if (!features_hash) features_hash = NewHash();
  return features_hash;
}

/* Fully qualify any template parameters */
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
      Swig_warning(WARN_PARSE_EXTEND_UNDEF,Getfile(ki.item), Getline(ki.item), "%%extend defined for an undeclared class %s.\n", SwigType_namestr(ki.key));
      SWIG_WARN_NODE_END(ki.item);
    }
  }
}

/* Check a set of declarations to see if any are pure-abstract */

static List *pure_abstracts(Node *n) {
  List *abstracts = 0;
  while (n) {
    if (Cmp(nodeType(n),"cdecl") == 0) {
      String *decl = Getattr(n,"decl");
      if (SwigType_isfunction(decl)) {
	String *init = Getattr(n,"value");
	if (Cmp(init,"0") == 0) {
	  if (!abstracts) {
	    abstracts = NewList();
	  }
	  Append(abstracts,n);
	  SetFlag(n,"abstract");
	}
      }
    } else if (Cmp(nodeType(n),"destructor") == 0) {
      if (Cmp(Getattr(n,"value"),"0") == 0) {
	if (!abstracts) {
	  abstracts = NewList();
	}
	Append(abstracts,n);
	SetFlag(n,"abstract");
      }
    }
    n = nextSibling(n);
  }
  return abstracts;
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
 * The scopes required for the symbol name are resolved and/or created, if required.
 * For example AA::BB::CC as input returns CC and creates the namespace AA then inner 
 * namespace BB in the current scope. If cname is found to already exist as a weak symbol
 * (forward reference) then the scope might be changed to match, such as when a symbol match 
 * is made via a using reference. */
static String *resolve_create_node_scope(String *cname) {
  Symtab *gscope = 0;
  Node *cname_node = 0;
  int skip_lookup = 0;
  nscope = 0;
  nscope_inner = 0;  

  if (Strncmp(cname,"::",2) == 0)
    skip_lookup = 1;

  cname_node = skip_lookup ? 0 : Swig_symbol_clookup_no_inherit(cname, 0);

  if (cname_node) {
    /* The symbol has been defined already or is in another scope.
       If it is a weak symbol, it needs replacing and if it was brought into the current scope
       via a using declaration, the scope needs adjusting appropriately for the new symbol.
       Similarly for defined templates. */
    Symtab *symtab = Getattr(cname_node, "sym:symtab");
    Node *sym_weak = Getattr(cname_node, "sym:weak");
    if ((symtab && sym_weak) || Equal(nodeType(cname_node), "template")) {
      /* Check if the scope is the current scope */
      String *current_scopename = Swig_symbol_qualifiedscopename(0);
      String *found_scopename = Swig_symbol_qualifiedscopename(symtab);
      int len;
      if (!current_scopename)
	current_scopename = NewString("");
      if (!found_scopename)
	found_scopename = NewString("");
      len = Len(current_scopename);
      if ((len > 0) && (Strncmp(current_scopename, found_scopename, len) == 0)) {
	if (Len(found_scopename) > len + 2) {
	  /* A matching weak symbol was found in non-global scope, some scope adjustment may be required */
	  String *new_cname = NewString(Char(found_scopename) + len + 2); /* skip over "::" prefix */
	  String *base = Swig_scopename_last(cname);
	  Printf(new_cname, "::%s", base);
	  cname = new_cname;
	  Delete(base);
	} else {
	  /* A matching weak symbol was found in the same non-global local scope, no scope adjustment required */
	  assert(len == Len(found_scopename));
	}
      } else {
	String *base = Swig_scopename_last(cname);
	if (Len(found_scopename) > 0) {
	  /* A matching weak symbol was found in a different scope to the local scope - probably via a using declaration */
	  cname = NewStringf("%s::%s", found_scopename, base);
	} else {
	  /* Either:
	      1) A matching weak symbol was found in a different scope to the local scope - this is actually a
	      symbol with the same name in a different scope which we don't want, so no adjustment required.
	      2) A matching weak symbol was found in the global scope - no adjustment required.
	  */
	  cname = Copy(base);
	}
	Delete(base);
      }
      Delete(current_scopename);
      Delete(found_scopename);
    }
  }

  if (Swig_scopename_check(cname)) {
    Node   *ns;
    String *prefix = Swig_scopename_prefix(cname);
    String *base = Swig_scopename_last(cname);
    if (prefix && (Strncmp(prefix,"::",2) == 0)) {
/* I don't think we can use :: global scope to declare classes and hence neither %template. - consider reporting error instead - wsfulton. */
      /* Use the global scope */
      String *nprefix = NewString(Char(prefix)+2);
      Delete(prefix);
      prefix= nprefix;
      gscope = set_scope_to_global();
    }
    if (Len(prefix) == 0) {
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
	Swig_error(cparse_file,cparse_line, "'%s' is not defined as a valid scope.\n", prefix);
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

static Node *nested_forward_declaration(const char *storage, const char *kind, String *sname, String *name, Node *cpp_opt_declarators) {
  Node *nn = 0;
  int warned = 0;

  if (sname) {
    /* Add forward declaration of the nested type */
    Node *n = new_node("classforward");
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
      SwigType *type = name;
      while (n) {
	Setattr(n, "type", type);
	Setattr(n, "storage", storage);
	if (anonymous_typedef) {
	  Setattr(n, "nodeType", "classforward");
	  Setattr(n, "sym:weak", "1");
	}
	n = nextSibling(n);
      }
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



/* Line 189 of yacc.c  */
#line 1705 "parser.tab.c"

/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     HBLOCK = 259,
     POUND = 260,
     STRING = 261,
     INCLUDE = 262,
     IMPORT = 263,
     INSERT = 264,
     CHARCONST = 265,
     NUM_INT = 266,
     NUM_FLOAT = 267,
     NUM_UNSIGNED = 268,
     NUM_LONG = 269,
     NUM_ULONG = 270,
     NUM_LONGLONG = 271,
     NUM_ULONGLONG = 272,
     NUM_BOOL = 273,
     TYPEDEF = 274,
     TYPE_INT = 275,
     TYPE_UNSIGNED = 276,
     TYPE_SHORT = 277,
     TYPE_LONG = 278,
     TYPE_FLOAT = 279,
     TYPE_DOUBLE = 280,
     TYPE_CHAR = 281,
     TYPE_WCHAR = 282,
     TYPE_VOID = 283,
     TYPE_SIGNED = 284,
     TYPE_BOOL = 285,
     TYPE_COMPLEX = 286,
     TYPE_TYPEDEF = 287,
     TYPE_RAW = 288,
     TYPE_NON_ISO_INT8 = 289,
     TYPE_NON_ISO_INT16 = 290,
     TYPE_NON_ISO_INT32 = 291,
     TYPE_NON_ISO_INT64 = 292,
     LPAREN = 293,
     RPAREN = 294,
     COMMA = 295,
     SEMI = 296,
     EXTERN = 297,
     INIT = 298,
     LBRACE = 299,
     RBRACE = 300,
     PERIOD = 301,
     CONST_QUAL = 302,
     VOLATILE = 303,
     REGISTER = 304,
     STRUCT = 305,
     UNION = 306,
     EQUAL = 307,
     SIZEOF = 308,
     MODULE = 309,
     LBRACKET = 310,
     RBRACKET = 311,
     BEGINFILE = 312,
     ENDOFFILE = 313,
     ILLEGAL = 314,
     CONSTANT = 315,
     NAME = 316,
     RENAME = 317,
     NAMEWARN = 318,
     EXTEND = 319,
     PRAGMA = 320,
     FEATURE = 321,
     VARARGS = 322,
     ENUM = 323,
     CLASS = 324,
     TYPENAME = 325,
     PRIVATE = 326,
     PUBLIC = 327,
     PROTECTED = 328,
     COLON = 329,
     STATIC = 330,
     VIRTUAL = 331,
     FRIEND = 332,
     THROW = 333,
     CATCH = 334,
     EXPLICIT = 335,
     USING = 336,
     NAMESPACE = 337,
     NATIVE = 338,
     INLINE = 339,
     TYPEMAP = 340,
     EXCEPT = 341,
     ECHO = 342,
     APPLY = 343,
     CLEAR = 344,
     SWIGTEMPLATE = 345,
     FRAGMENT = 346,
     WARN = 347,
     LESSTHAN = 348,
     GREATERTHAN = 349,
     DELETE_KW = 350,
     LESSTHANOREQUALTO = 351,
     GREATERTHANOREQUALTO = 352,
     EQUALTO = 353,
     NOTEQUALTO = 354,
     QUESTIONMARK = 355,
     TYPES = 356,
     PARMS = 357,
     NONID = 358,
     DSTAR = 359,
     DCNOT = 360,
     TEMPLATE = 361,
     OPERATOR = 362,
     COPERATOR = 363,
     PARSETYPE = 364,
     PARSEPARM = 365,
     PARSEPARMS = 366,
     CAST = 367,
     LOR = 368,
     LAND = 369,
     OR = 370,
     XOR = 371,
     AND = 372,
     RSHIFT = 373,
     LSHIFT = 374,
     MINUS = 375,
     PLUS = 376,
     MODULO = 377,
     SLASH = 378,
     STAR = 379,
     LNOT = 380,
     NOT = 381,
     UMINUS = 382,
     DCOLON = 383
   };
#endif



#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 214 of yacc.c  */
#line 1647 "parser.y"

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
  int           intvalue;
  Node         *node;



/* Line 214 of yacc.c  */
#line 1914 "parser.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */


/* Line 264 of yacc.c  */
#line 1926 "parser.tab.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int yyi)
#else
static int
YYID (yyi)
    int yyi;
#endif
{
  return yyi;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)				\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack_alloc, Stack, yysize);			\
	Stack = &yyptr->Stack_alloc;					\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  55
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   3845

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  129
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  149
/* YYNRULES -- Number of rules.  */
#define YYNRULES  470
/* YYNRULES -- Number of states.  */
#define YYNSTATES  912

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   383

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    43,    44,
      45,    46,    47,    48,    49,    50,    51,    52,    53,    54,
      55,    56,    57,    58,    59,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    74,
      75,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    93,    94,
      95,    96,    97,    98,    99,   100,   101,   102,   103,   104,
     105,   106,   107,   108,   109,   110,   111,   112,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
     125,   126,   127,   128
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint16 yyprhs[] =
{
       0,     0,     3,     5,     9,    12,    16,    19,    25,    29,
      32,    34,    36,    38,    40,    42,    44,    46,    49,    51,
      53,    55,    57,    59,    61,    63,    65,    67,    69,    71,
      73,    75,    77,    79,    81,    83,    85,    87,    89,    91,
      92,   100,   106,   110,   116,   122,   126,   129,   132,   138,
     141,   147,   150,   155,   157,   159,   167,   175,   181,   182,
     190,   192,   194,   197,   200,   202,   208,   214,   220,   224,
     229,   233,   241,   250,   256,   260,   262,   264,   268,   270,
     275,   283,   290,   292,   294,   302,   312,   321,   332,   338,
     346,   353,   362,   364,   366,   372,   377,   383,   391,   393,
     397,   404,   411,   420,   422,   425,   429,   431,   434,   438,
     445,   451,   461,   464,   466,   468,   470,   471,   478,   484,
     486,   491,   493,   495,   498,   504,   511,   516,   524,   534,
     541,   543,   545,   547,   549,   551,   553,   554,   564,   565,
     575,   577,   581,   586,   587,   594,   598,   600,   602,   604,
     606,   608,   610,   612,   615,   617,   619,   621,   625,   627,
     631,   636,   637,   644,   645,   651,   657,   660,   661,   668,
     670,   672,   673,   677,   679,   681,   683,   685,   687,   689,
     691,   693,   697,   699,   701,   703,   705,   707,   709,   711,
     713,   715,   722,   729,   737,   746,   755,   765,   773,   779,
     782,   785,   788,   789,   797,   798,   805,   807,   809,   811,
     813,   815,   817,   819,   821,   823,   825,   827,   830,   833,
     836,   841,   844,   850,   852,   855,   857,   859,   861,   863,
     865,   867,   869,   872,   874,   878,   880,   883,   891,   895,
     897,   900,   902,   906,   908,   910,   912,   915,   921,   924,
     927,   929,   932,   935,   937,   939,   941,   943,   946,   950,
     952,   955,   959,   964,   970,   975,   977,   980,   984,   989,
     995,   999,  1004,  1009,  1011,  1014,  1019,  1024,  1030,  1034,
    1039,  1044,  1046,  1049,  1052,  1056,  1058,  1061,  1063,  1066,
    1070,  1075,  1079,  1084,  1087,  1091,  1095,  1100,  1104,  1108,
    1111,  1114,  1116,  1118,  1121,  1123,  1125,  1127,  1129,  1132,
    1134,  1137,  1141,  1143,  1145,  1147,  1150,  1153,  1155,  1157,
    1160,  1162,  1164,  1167,  1169,  1171,  1173,  1175,  1177,  1179,
    1181,  1183,  1185,  1187,  1189,  1191,  1193,  1195,  1196,  1199,
    1201,  1203,  1205,  1207,  1213,  1217,  1221,  1223,  1225,  1229,
    1231,  1233,  1235,  1237,  1239,  1245,  1247,  1249,  1253,  1258,
    1264,  1270,  1277,  1280,  1283,  1285,  1287,  1289,  1291,  1293,
    1295,  1297,  1299,  1303,  1307,  1311,  1315,  1319,  1323,  1327,
    1331,  1335,  1339,  1343,  1347,  1351,  1355,  1359,  1363,  1369,
    1372,  1375,  1378,  1381,  1384,  1386,  1387,  1391,  1393,  1395,
    1399,  1400,  1404,  1405,  1411,  1413,  1415,  1417,  1419,  1421,
    1423,  1425,  1427,  1429,  1431,  1433,  1438,  1444,  1446,  1450,
    1454,  1459,  1464,  1468,  1471,  1473,  1475,  1479,  1482,  1486,
    1488,  1490,  1492,  1494,  1496,  1499,  1504,  1506,  1510,  1512,
    1516,  1520,  1523,  1526,  1529,  1532,  1535,  1540,  1542,  1546,
    1548,  1552,  1556,  1559,  1562,  1565,  1568,  1570,  1572,  1574,
    1576,  1580,  1582,  1586,  1592,  1594,  1598,  1602,  1608,  1610,
    1612
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     130,     0,    -1,   131,    -1,   109,   215,    41,    -1,   109,
       1,    -1,   110,   215,    41,    -1,   110,     1,    -1,   111,
      38,   212,    39,    41,    -1,   111,     1,    41,    -1,   131,
     132,    -1,   277,    -1,   133,    -1,   170,    -1,   178,    -1,
      41,    -1,     1,    -1,   177,    -1,     1,   108,    -1,   134,
      -1,   136,    -1,   137,    -1,   138,    -1,   139,    -1,   140,
      -1,   143,    -1,   144,    -1,   147,    -1,   148,    -1,   149,
      -1,   150,    -1,   151,    -1,   152,    -1,   155,    -1,   157,
      -1,   160,    -1,   162,    -1,   167,    -1,   168,    -1,   169,
      -1,    -1,    64,   274,   267,    44,   135,   195,    45,    -1,
      88,   166,    44,   164,    45,    -1,    89,   164,    41,    -1,
      60,     3,    52,   237,    41,    -1,    60,   231,   223,   220,
      41,    -1,    60,     1,    41,    -1,    87,     4,    -1,    87,
     272,    -1,    86,    38,     3,    39,    44,    -1,    86,    44,
      -1,    86,    38,     3,    39,    41,    -1,    86,    41,    -1,
     272,    44,   215,    45,    -1,   272,    -1,   141,    -1,    91,
      38,   142,    40,   275,    39,     4,    -1,    91,    38,   142,
      40,   275,    39,    44,    -1,    91,    38,   142,    39,    41,
      -1,    -1,   146,   274,   272,    57,   145,   131,    58,    -1,
       7,    -1,     8,    -1,    84,     4,    -1,    84,    44,    -1,
       4,    -1,     9,    38,   265,    39,   272,    -1,     9,    38,
     265,    39,     4,    -1,     9,    38,   265,    39,    44,    -1,
      54,   274,   265,    -1,    61,    38,   265,    39,    -1,    61,
      38,    39,    -1,    83,    38,     3,    39,   211,     3,    41,
      -1,    83,    38,     3,    39,   211,   231,   223,    41,    -1,
      65,   154,     3,    52,   153,    -1,    65,   154,     3,    -1,
     272,    -1,     4,    -1,    38,     3,    39,    -1,   277,    -1,
     156,   223,   265,    41,    -1,   156,    38,   275,    39,   223,
     259,    41,    -1,   156,    38,   275,    39,   272,    41,    -1,
      62,    -1,    63,    -1,    66,    38,   265,    39,   223,   259,
     158,    -1,    66,    38,   265,    40,   276,    39,   223,   259,
      41,    -1,    66,    38,   265,   159,    39,   223,   259,   158,
      -1,    66,    38,   265,    40,   276,   159,    39,   223,   259,
      41,    -1,    66,    38,   265,    39,   158,    -1,    66,    38,
     265,    40,   276,    39,    41,    -1,    66,    38,   265,   159,
      39,   158,    -1,    66,    38,   265,    40,   276,   159,    39,
      41,    -1,   273,    -1,    41,    -1,   102,    38,   212,    39,
      41,    -1,    40,   265,    52,   276,    -1,    40,   265,    52,
     276,   159,    -1,    67,    38,   161,    39,   223,   259,    41,
      -1,   212,    -1,    11,    40,   215,    -1,    85,    38,   163,
      39,   164,   273,    -1,    85,    38,   163,    39,   164,    41,
      -1,    85,    38,   163,    39,   164,    52,   166,    41,    -1,
     275,    -1,   166,   165,    -1,    40,   166,   165,    -1,   277,
      -1,   231,   222,    -1,    38,   212,    39,    -1,    38,   212,
      39,    38,   212,    39,    -1,   101,    38,   212,    39,   158,
      -1,    90,    38,   266,    39,   270,    93,   216,    94,    41,
      -1,    92,   272,    -1,   172,    -1,   176,    -1,   175,    -1,
      -1,    42,   272,    44,   171,   131,    45,    -1,   211,   231,
     223,   174,   173,    -1,    41,    -1,    40,   223,   174,   173,
      -1,    44,    -1,   220,    -1,   229,   220,    -1,    78,    38,
     212,    39,   220,    -1,   229,    78,    38,   212,    39,   220,
      -1,   211,    68,     3,    41,    -1,   211,    68,   239,    44,
     241,    45,    41,    -1,   211,    68,   239,    44,   241,    45,
     223,   174,   173,    -1,   211,   231,    38,   212,    39,   260,
      -1,   179,    -1,   183,    -1,   184,    -1,   191,    -1,   192,
      -1,   202,    -1,    -1,   211,   257,   267,   248,    44,   180,
     195,    45,   182,    -1,    -1,   211,   257,    44,   181,   195,
      45,   223,   174,   173,    -1,    41,    -1,   223,   174,   173,
      -1,   211,   257,   267,    41,    -1,    -1,   106,    93,   187,
      94,   185,   186,    -1,   106,   257,   267,    -1,   172,    -1,
     179,    -1,   199,    -1,   184,    -1,   183,    -1,   201,    -1,
     188,    -1,   189,   190,    -1,   277,    -1,   256,    -1,   215,
      -1,    40,   189,   190,    -1,   277,    -1,    81,   267,    41,
      -1,    81,    82,   267,    41,    -1,    -1,    82,   267,    44,
     193,   131,    45,    -1,    -1,    82,    44,   194,   131,    45,
      -1,    82,     3,    52,   267,    41,    -1,   198,   195,    -1,
      -1,    64,    44,   196,   195,    45,   195,    -1,   144,    -1,
     277,    -1,    -1,     1,   197,   195,    -1,   170,    -1,   199,
      -1,   200,    -1,   203,    -1,   207,    -1,   201,    -1,   183,
      -1,   204,    -1,   211,   267,    41,    -1,   191,    -1,   184,
      -1,   202,    -1,   168,    -1,   169,    -1,   210,    -1,   143,
      -1,   167,    -1,    41,    -1,   211,   231,    38,   212,    39,
     260,    -1,   126,   269,    38,   212,    39,   208,    -1,    76,
     126,   269,    38,   212,    39,   209,    -1,   211,   108,   231,
     228,    38,   212,    39,   209,    -1,   211,   108,   231,   117,
      38,   212,    39,   209,    -1,   211,   108,   231,   228,   117,
      38,   212,    39,   209,    -1,   211,   108,   231,    38,   212,
      39,   209,    -1,    79,    38,   212,    39,    44,    -1,    72,
      74,    -1,    71,    74,    -1,    73,    74,    -1,    -1,   211,
     257,   267,   248,    44,   205,   182,    -1,    -1,   211,   257,
     248,    44,   206,   182,    -1,   152,    -1,   138,    -1,   150,
      -1,   155,    -1,   157,    -1,   160,    -1,   148,    -1,   162,
      -1,   136,    -1,   137,    -1,   139,    -1,   259,    41,    -1,
     259,    44,    -1,   259,    41,    -1,   259,    52,   237,    41,
      -1,   259,    44,    -1,   211,   231,    74,   244,    41,    -1,
      42,    -1,    42,   272,    -1,    75,    -1,    19,    -1,    76,
      -1,    77,    -1,    80,    -1,   277,    -1,   213,    -1,   215,
     214,    -1,   277,    -1,    40,   215,   214,    -1,   277,    -1,
     232,   221,    -1,   106,    93,   257,    94,   257,   267,   220,
      -1,    46,    46,    46,    -1,   217,    -1,   219,   218,    -1,
     277,    -1,    40,   219,   218,    -1,   277,    -1,   215,    -1,
     245,    -1,    52,   237,    -1,    52,   237,    55,   244,    56,
      -1,    52,    44,    -1,    74,   244,    -1,   277,    -1,   223,
     220,    -1,   226,   220,    -1,   220,    -1,   223,    -1,   226,
      -1,   277,    -1,   228,   224,    -1,   228,   117,   224,    -1,
     225,    -1,   117,   224,    -1,   267,   104,   224,    -1,   228,
     267,   104,   224,    -1,   228,   267,   104,   117,   224,    -1,
     267,   104,   117,   224,    -1,   267,    -1,   126,   267,    -1,
      38,   267,    39,    -1,    38,   228,   224,    39,    -1,    38,
     267,   104,   224,    39,    -1,   224,    55,    56,    -1,   224,
      55,   244,    56,    -1,   224,    38,   212,    39,    -1,   267,
      -1,   126,   267,    -1,    38,   228,   225,    39,    -1,    38,
     117,   225,    39,    -1,    38,   267,   104,   225,    39,    -1,
     225,    55,    56,    -1,   225,    55,   244,    56,    -1,   225,
      38,   212,    39,    -1,   228,    -1,   228,   227,    -1,   228,
     117,    -1,   228,   117,   227,    -1,   227,    -1,   117,   227,
      -1,   117,    -1,   267,   104,    -1,   228,   267,   104,    -1,
     228,   267,   104,   227,    -1,   227,    55,    56,    -1,   227,
      55,   244,    56,    -1,    55,    56,    -1,    55,   244,    56,
      -1,    38,   226,    39,    -1,   227,    38,   212,    39,    -1,
      38,   212,    39,    -1,   124,   229,   228,    -1,   124,   228,
      -1,   124,   229,    -1,   124,    -1,   230,    -1,   230,   229,
      -1,    47,    -1,    48,    -1,    49,    -1,   232,    -1,   229,
     233,    -1,   233,    -1,   233,   229,    -1,   229,   233,   229,
      -1,   234,    -1,    30,    -1,    28,    -1,    32,   264,    -1,
      68,   267,    -1,    33,    -1,   267,    -1,   257,   267,    -1,
     235,    -1,   236,    -1,   236,   235,    -1,    20,    -1,    22,
      -1,    23,    -1,    26,    -1,    27,    -1,    24,    -1,    25,
      -1,    29,    -1,    21,    -1,    31,    -1,    34,    -1,    35,
      -1,    36,    -1,    37,    -1,    -1,   238,   244,    -1,     3,
      -1,   277,    -1,   138,    -1,   277,    -1,   241,    40,   240,
     242,   240,    -1,   241,    40,   240,    -1,   240,   242,   240,
      -1,   240,    -1,     3,    -1,     3,    52,   243,    -1,   244,
      -1,   245,    -1,   231,    -1,   246,    -1,   272,    -1,    53,
      38,   231,   221,    39,    -1,   247,    -1,    10,    -1,    38,
     244,    39,    -1,    38,   244,    39,   244,    -1,    38,   244,
     228,    39,   244,    -1,    38,   244,   117,    39,   244,    -1,
      38,   244,   228,   117,    39,   244,    -1,   117,   244,    -1,
     124,   244,    -1,    11,    -1,    12,    -1,    13,    -1,    14,
      -1,    15,    -1,    16,    -1,    17,    -1,    18,    -1,   244,
     121,   244,    -1,   244,   120,   244,    -1,   244,   124,   244,
      -1,   244,   123,   244,    -1,   244,   122,   244,    -1,   244,
     117,   244,    -1,   244,   115,   244,    -1,   244,   116,   244,
      -1,   244,   119,   244,    -1,   244,   118,   244,    -1,   244,
     114,   244,    -1,   244,   113,   244,    -1,   244,    98,   244,
      -1,   244,    99,   244,    -1,   244,    97,   244,    -1,   244,
      96,   244,    -1,   244,   100,   244,    74,   244,    -1,   120,
     244,    -1,   121,   244,    -1,   126,   244,    -1,   125,   244,
      -1,   231,    38,    -1,   249,    -1,    -1,    74,   250,   251,
      -1,   277,    -1,   252,    -1,   251,    40,   252,    -1,    -1,
     258,   253,   267,    -1,    -1,   258,   255,   254,   258,   267,
      -1,    72,    -1,    71,    -1,    73,    -1,    69,    -1,    70,
      -1,   256,    -1,    50,    -1,    51,    -1,    76,    -1,   277,
      -1,   229,    -1,    78,    38,   212,    39,    -1,   229,    78,
      38,   212,    39,    -1,   277,    -1,   259,   261,    41,    -1,
     259,   261,    44,    -1,    38,   212,    39,    41,    -1,    38,
     212,    39,    44,    -1,    52,   237,    41,    -1,    74,   262,
      -1,   277,    -1,   263,    -1,   262,    40,   263,    -1,   267,
      38,    -1,    93,   216,    94,    -1,   277,    -1,     3,    -1,
     272,    -1,   265,    -1,   277,    -1,   269,   268,    -1,   103,
     128,   269,   268,    -1,   269,    -1,   103,   128,   269,    -1,
     107,    -1,   103,   128,   107,    -1,   128,   269,   268,    -1,
     128,   269,    -1,   128,   107,    -1,   105,   269,    -1,     3,
     264,    -1,     3,   271,    -1,   103,   128,     3,   271,    -1,
       3,    -1,   103,   128,     3,    -1,   107,    -1,   103,   128,
     107,    -1,   128,     3,   271,    -1,   128,     3,    -1,   128,
     107,    -1,   105,     3,    -1,   272,     6,    -1,     6,    -1,
     272,    -1,    44,    -1,     4,    -1,    38,   275,    39,    -1,
     277,    -1,   265,    52,   276,    -1,   265,    52,   276,    40,
     275,    -1,   265,    -1,   265,    40,   275,    -1,   265,    52,
     141,    -1,   265,    52,   141,    40,   275,    -1,   272,    -1,
     246,    -1,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,  1802,  1802,  1815,  1819,  1822,  1825,  1828,  1831,  1836,
    1841,  1846,  1847,  1848,  1849,  1850,  1856,  1872,  1882,  1883,
    1884,  1885,  1886,  1887,  1888,  1889,  1890,  1891,  1892,  1893,
    1894,  1895,  1896,  1897,  1898,  1899,  1900,  1901,  1902,  1909,
    1909,  1995,  2005,  2016,  2037,  2059,  2070,  2079,  2098,  2104,
    2110,  2115,  2122,  2129,  2133,  2146,  2155,  2170,  2183,  2183,
    2238,  2239,  2246,  2265,  2296,  2300,  2310,  2315,  2333,  2373,
    2379,  2392,  2398,  2424,  2430,  2437,  2438,  2441,  2442,  2450,
    2496,  2542,  2553,  2556,  2583,  2589,  2595,  2601,  2609,  2615,
    2621,  2627,  2635,  2636,  2637,  2640,  2645,  2655,  2691,  2692,
    2727,  2744,  2752,  2765,  2790,  2796,  2800,  2803,  2814,  2819,
    2832,  2844,  3118,  3128,  3135,  3136,  3140,  3140,  3171,  3232,
    3236,  3258,  3264,  3270,  3276,  3282,  3295,  3310,  3320,  3398,
    3449,  3450,  3451,  3452,  3453,  3454,  3459,  3459,  3708,  3708,
    3831,  3832,  3844,  3862,  3862,  4151,  4157,  4160,  4163,  4166,
    4169,  4172,  4177,  4207,  4211,  4214,  4217,  4222,  4226,  4231,
    4241,  4272,  4272,  4301,  4301,  4323,  4350,  4365,  4365,  4375,
    4376,  4377,  4377,  4393,  4394,  4411,  4412,  4413,  4414,  4415,
    4416,  4417,  4418,  4419,  4420,  4421,  4422,  4423,  4424,  4425,
    4426,  4435,  4460,  4484,  4515,  4530,  4548,  4567,  4586,  4593,
    4600,  4608,  4629,  4629,  4656,  4656,  4692,  4695,  4699,  4702,
    4703,  4704,  4705,  4706,  4707,  4708,  4709,  4712,  4717,  4724,
    4732,  4740,  4751,  4757,  4758,  4766,  4767,  4768,  4769,  4770,
    4771,  4778,  4789,  4793,  4796,  4800,  4804,  4814,  4822,  4830,
    4843,  4847,  4850,  4854,  4858,  4886,  4894,  4905,  4919,  4928,
    4936,  4946,  4950,  4954,  4961,  4978,  4995,  5003,  5011,  5020,
    5024,  5033,  5044,  5056,  5066,  5079,  5086,  5094,  5110,  5118,
    5129,  5140,  5151,  5170,  5178,  5195,  5203,  5210,  5221,  5232,
    5243,  5262,  5268,  5274,  5281,  5290,  5293,  5302,  5309,  5316,
    5326,  5337,  5348,  5359,  5366,  5373,  5376,  5393,  5403,  5410,
    5416,  5421,  5427,  5431,  5437,  5438,  5439,  5445,  5451,  5455,
    5456,  5460,  5467,  5470,  5471,  5472,  5473,  5474,  5476,  5479,
    5484,  5509,  5512,  5566,  5570,  5574,  5578,  5582,  5586,  5590,
    5594,  5598,  5602,  5606,  5610,  5614,  5618,  5624,  5624,  5650,
    5651,  5654,  5655,  5659,  5665,  5668,  5672,  5677,  5685,  5697,
    5712,  5713,  5732,  5733,  5737,  5742,  5743,  5757,  5764,  5781,
    5788,  5795,  5803,  5807,  5813,  5814,  5815,  5816,  5817,  5818,
    5819,  5820,  5823,  5827,  5831,  5835,  5839,  5843,  5847,  5851,
    5855,  5859,  5863,  5867,  5871,  5875,  5889,  5893,  5897,  5903,
    5907,  5911,  5915,  5919,  5935,  5940,  5940,  5941,  5944,  5961,
    5970,  5970,  5986,  5986,  6002,  6003,  6004,  6008,  6012,  6018,
    6021,  6025,  6031,  6032,  6035,  6040,  6045,  6050,  6057,  6064,
    6071,  6079,  6087,  6095,  6096,  6099,  6100,  6103,  6109,  6115,
    6118,  6119,  6122,  6123,  6126,  6131,  6135,  6138,  6141,  6144,
    6149,  6153,  6156,  6163,  6169,  6178,  6183,  6187,  6190,  6193,
    6196,  6201,  6205,  6208,  6211,  6217,  6222,  6225,  6228,  6232,
    6237,  6250,  6254,  6259,  6265,  6269,  6274,  6278,  6285,  6288,
    6293
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "ID", "HBLOCK", "POUND", "STRING",
  "INCLUDE", "IMPORT", "INSERT", "CHARCONST", "NUM_INT", "NUM_FLOAT",
  "NUM_UNSIGNED", "NUM_LONG", "NUM_ULONG", "NUM_LONGLONG", "NUM_ULONGLONG",
  "NUM_BOOL", "TYPEDEF", "TYPE_INT", "TYPE_UNSIGNED", "TYPE_SHORT",
  "TYPE_LONG", "TYPE_FLOAT", "TYPE_DOUBLE", "TYPE_CHAR", "TYPE_WCHAR",
  "TYPE_VOID", "TYPE_SIGNED", "TYPE_BOOL", "TYPE_COMPLEX", "TYPE_TYPEDEF",
  "TYPE_RAW", "TYPE_NON_ISO_INT8", "TYPE_NON_ISO_INT16",
  "TYPE_NON_ISO_INT32", "TYPE_NON_ISO_INT64", "LPAREN", "RPAREN", "COMMA",
  "SEMI", "EXTERN", "INIT", "LBRACE", "RBRACE", "PERIOD", "CONST_QUAL",
  "VOLATILE", "REGISTER", "STRUCT", "UNION", "EQUAL", "SIZEOF", "MODULE",
  "LBRACKET", "RBRACKET", "BEGINFILE", "ENDOFFILE", "ILLEGAL", "CONSTANT",
  "NAME", "RENAME", "NAMEWARN", "EXTEND", "PRAGMA", "FEATURE", "VARARGS",
  "ENUM", "CLASS", "TYPENAME", "PRIVATE", "PUBLIC", "PROTECTED", "COLON",
  "STATIC", "VIRTUAL", "FRIEND", "THROW", "CATCH", "EXPLICIT", "USING",
  "NAMESPACE", "NATIVE", "INLINE", "TYPEMAP", "EXCEPT", "ECHO", "APPLY",
  "CLEAR", "SWIGTEMPLATE", "FRAGMENT", "WARN", "LESSTHAN", "GREATERTHAN",
  "DELETE_KW", "LESSTHANOREQUALTO", "GREATERTHANOREQUALTO", "EQUALTO",
  "NOTEQUALTO", "QUESTIONMARK", "TYPES", "PARMS", "NONID", "DSTAR",
  "DCNOT", "TEMPLATE", "OPERATOR", "COPERATOR", "PARSETYPE", "PARSEPARM",
  "PARSEPARMS", "CAST", "LOR", "LAND", "OR", "XOR", "AND", "RSHIFT",
  "LSHIFT", "MINUS", "PLUS", "MODULO", "SLASH", "STAR", "LNOT", "NOT",
  "UMINUS", "DCOLON", "$accept", "program", "interface", "declaration",
  "swig_directive", "extend_directive", "$@1", "apply_directive",
  "clear_directive", "constant_directive", "echo_directive",
  "except_directive", "stringtype", "fname", "fragment_directive",
  "include_directive", "$@2", "includetype", "inline_directive",
  "insert_directive", "module_directive", "name_directive",
  "native_directive", "pragma_directive", "pragma_arg", "pragma_lang",
  "rename_directive", "rename_namewarn", "feature_directive",
  "stringbracesemi", "featattr", "varargs_directive", "varargs_parms",
  "typemap_directive", "typemap_type", "tm_list", "tm_tail",
  "typemap_parm", "types_directive", "template_directive",
  "warn_directive", "c_declaration", "$@3", "c_decl", "c_decl_tail",
  "initializer", "c_enum_forward_decl", "c_enum_decl",
  "c_constructor_decl", "cpp_declaration", "cpp_class_decl", "@4", "@5",
  "cpp_opt_declarators", "cpp_forward_class_decl", "cpp_template_decl",
  "$@6", "cpp_temp_possible", "template_parms", "templateparameters",
  "templateparameter", "templateparameterstail", "cpp_using_decl",
  "cpp_namespace_decl", "$@7", "$@8", "cpp_members", "$@9", "$@10",
  "cpp_member", "cpp_constructor_decl", "cpp_destructor_decl",
  "cpp_conversion_operator", "cpp_catch_decl", "cpp_protection_decl",
  "cpp_nested", "@11", "@12", "cpp_swig_directive", "cpp_end", "cpp_vend",
  "anonymous_bitfield", "storage_class", "parms", "rawparms", "ptail",
  "parm", "valparms", "rawvalparms", "valptail", "valparm", "def_args",
  "parameter_declarator", "typemap_parameter_declarator", "declarator",
  "notso_direct_declarator", "direct_declarator", "abstract_declarator",
  "direct_abstract_declarator", "pointer", "type_qualifier",
  "type_qualifier_raw", "type", "rawtype", "type_right", "primitive_type",
  "primitive_type_list", "type_specifier", "definetype", "$@13", "ename",
  "optional_constant_directive", "enumlist", "edecl", "etype", "expr",
  "valexpr", "exprnum", "exprcompound", "inherit", "raw_inherit", "$@14",
  "base_list", "base_specifier", "@15", "@16", "access_specifier",
  "templcpptype", "cpptype", "opt_virtual", "cpp_const", "ctor_end",
  "ctor_initializer", "mem_initializer_list", "mem_initializer",
  "template_decl", "idstring", "idstringopt", "idcolon", "idcolontail",
  "idtemplate", "idcolonnt", "idcolontailnt", "string", "stringbrace",
  "options", "kwargs", "stringnum", "empty", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,   272,   273,   274,
     275,   276,   277,   278,   279,   280,   281,   282,   283,   284,
     285,   286,   287,   288,   289,   290,   291,   292,   293,   294,
     295,   296,   297,   298,   299,   300,   301,   302,   303,   304,
     305,   306,   307,   308,   309,   310,   311,   312,   313,   314,
     315,   316,   317,   318,   319,   320,   321,   322,   323,   324,
     325,   326,   327,   328,   329,   330,   331,   332,   333,   334,
     335,   336,   337,   338,   339,   340,   341,   342,   343,   344,
     345,   346,   347,   348,   349,   350,   351,   352,   353,   354,
     355,   356,   357,   358,   359,   360,   361,   362,   363,   364,
     365,   366,   367,   368,   369,   370,   371,   372,   373,   374,
     375,   376,   377,   378,   379,   380,   381,   382,   383
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint16 yyr1[] =
{
       0,   129,   130,   130,   130,   130,   130,   130,   130,   131,
     131,   132,   132,   132,   132,   132,   132,   132,   133,   133,
     133,   133,   133,   133,   133,   133,   133,   133,   133,   133,
     133,   133,   133,   133,   133,   133,   133,   133,   133,   135,
     134,   136,   137,   138,   138,   138,   139,   139,   140,   140,
     140,   140,   141,   142,   142,   143,   143,   143,   145,   144,
     146,   146,   147,   147,   148,   148,   148,   148,   149,   150,
     150,   151,   151,   152,   152,   153,   153,   154,   154,   155,
     155,   155,   156,   156,   157,   157,   157,   157,   157,   157,
     157,   157,   158,   158,   158,   159,   159,   160,   161,   161,
     162,   162,   162,   163,   164,   165,   165,   166,   166,   166,
     167,   168,   169,   170,   170,   170,   171,   170,   172,   173,
     173,   173,   174,   174,   174,   174,   175,   176,   176,   177,
     178,   178,   178,   178,   178,   178,   180,   179,   181,   179,
     182,   182,   183,   185,   184,   184,   186,   186,   186,   186,
     186,   186,   187,   188,   188,   189,   189,   190,   190,   191,
     191,   193,   192,   194,   192,   192,   195,   196,   195,   195,
     195,   197,   195,   198,   198,   198,   198,   198,   198,   198,
     198,   198,   198,   198,   198,   198,   198,   198,   198,   198,
     198,   199,   200,   200,   201,   201,   201,   201,   202,   203,
     203,   203,   205,   204,   206,   204,   207,   207,   207,   207,
     207,   207,   207,   207,   207,   207,   207,   208,   208,   209,
     209,   209,   210,   211,   211,   211,   211,   211,   211,   211,
     211,   212,   213,   213,   214,   214,   215,   215,   215,   216,
     217,   217,   218,   218,   219,   219,   220,   220,   220,   220,
     220,   221,   221,   221,   222,   222,   222,   223,   223,   223,
     223,   223,   223,   223,   223,   224,   224,   224,   224,   224,
     224,   224,   224,   225,   225,   225,   225,   225,   225,   225,
     225,   226,   226,   226,   226,   226,   226,   226,   226,   226,
     226,   227,   227,   227,   227,   227,   227,   227,   228,   228,
     228,   228,   229,   229,   230,   230,   230,   231,   232,   232,
     232,   232,   233,   233,   233,   233,   233,   233,   233,   233,
     234,   235,   235,   236,   236,   236,   236,   236,   236,   236,
     236,   236,   236,   236,   236,   236,   236,   238,   237,   239,
     239,   240,   240,   241,   241,   241,   241,   242,   242,   243,
     244,   244,   245,   245,   245,   245,   245,   245,   245,   245,
     245,   245,   245,   245,   246,   246,   246,   246,   246,   246,
     246,   246,   247,   247,   247,   247,   247,   247,   247,   247,
     247,   247,   247,   247,   247,   247,   247,   247,   247,   247,
     247,   247,   247,   247,   248,   250,   249,   249,   251,   251,
     253,   252,   254,   252,   255,   255,   255,   256,   256,   257,
     257,   257,   258,   258,   259,   259,   259,   259,   260,   260,
     260,   260,   260,   261,   261,   262,   262,   263,   264,   264,
     265,   265,   266,   266,   267,   267,   267,   267,   267,   267,
     268,   268,   268,   268,   269,   270,   270,   270,   270,   270,
     270,   271,   271,   271,   271,   272,   272,   273,   273,   273,
     274,   274,   275,   275,   275,   275,   275,   275,   276,   276,
     277
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     1,     3,     2,     3,     2,     5,     3,     2,
       1,     1,     1,     1,     1,     1,     1,     2,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       7,     5,     3,     5,     5,     3,     2,     2,     5,     2,
       5,     2,     4,     1,     1,     7,     7,     5,     0,     7,
       1,     1,     2,     2,     1,     5,     5,     5,     3,     4,
       3,     7,     8,     5,     3,     1,     1,     3,     1,     4,
       7,     6,     1,     1,     7,     9,     8,    10,     5,     7,
       6,     8,     1,     1,     5,     4,     5,     7,     1,     3,
       6,     6,     8,     1,     2,     3,     1,     2,     3,     6,
       5,     9,     2,     1,     1,     1,     0,     6,     5,     1,
       4,     1,     1,     2,     5,     6,     4,     7,     9,     6,
       1,     1,     1,     1,     1,     1,     0,     9,     0,     9,
       1,     3,     4,     0,     6,     3,     1,     1,     1,     1,
       1,     1,     1,     2,     1,     1,     1,     3,     1,     3,
       4,     0,     6,     0,     5,     5,     2,     0,     6,     1,
       1,     0,     3,     1,     1,     1,     1,     1,     1,     1,
       1,     3,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     6,     6,     7,     8,     8,     9,     7,     5,     2,
       2,     2,     0,     7,     0,     6,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     2,     2,     2,
       4,     2,     5,     1,     2,     1,     1,     1,     1,     1,
       1,     1,     2,     1,     3,     1,     2,     7,     3,     1,
       2,     1,     3,     1,     1,     1,     2,     5,     2,     2,
       1,     2,     2,     1,     1,     1,     1,     2,     3,     1,
       2,     3,     4,     5,     4,     1,     2,     3,     4,     5,
       3,     4,     4,     1,     2,     4,     4,     5,     3,     4,
       4,     1,     2,     2,     3,     1,     2,     1,     2,     3,
       4,     3,     4,     2,     3,     3,     4,     3,     3,     2,
       2,     1,     1,     2,     1,     1,     1,     1,     2,     1,
       2,     3,     1,     1,     1,     2,     2,     1,     1,     2,
       1,     1,     2,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     0,     2,     1,
       1,     1,     1,     5,     3,     3,     1,     1,     3,     1,
       1,     1,     1,     1,     5,     1,     1,     3,     4,     5,
       5,     6,     2,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     5,     2,
       2,     2,     2,     2,     1,     0,     3,     1,     1,     3,
       0,     3,     0,     5,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     4,     5,     1,     3,     3,
       4,     4,     3,     2,     1,     1,     3,     2,     3,     1,
       1,     1,     1,     1,     2,     4,     1,     3,     1,     3,
       3,     2,     2,     2,     2,     2,     4,     1,     3,     1,
       3,     3,     2,     2,     2,     2,     1,     1,     1,     1,
       3,     1,     3,     5,     1,     3,     3,     5,     1,     1,
       0
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
     470,     0,     0,     0,     0,     0,    10,     4,   470,   323,
     331,   324,   325,   328,   329,   326,   327,   314,   330,   313,
     332,   470,   317,   333,   334,   335,   336,     0,   304,   305,
     306,   410,   411,     0,   407,   408,     0,     0,   438,     0,
       0,   302,   470,   309,   312,   320,   321,   409,     0,   318,
     436,     6,     0,     0,   470,     1,    15,    64,    60,    61,
       0,   226,    14,   223,   470,     0,     0,    82,    83,   470,
     470,     0,     0,   225,   227,   228,     0,   229,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     9,    11,    18,    19,    20,    21,    22,    23,
      24,    25,   470,    26,    27,    28,    29,    30,    31,    32,
       0,    33,    34,    35,    36,    37,    38,    12,   113,   115,
     114,    16,    13,   130,   131,   132,   133,   134,   135,     0,
     230,   470,   444,   429,   315,     0,   316,     0,     0,     3,
     308,   303,   470,   337,     0,     0,   287,   301,     0,   253,
     236,   470,   259,   470,   285,   281,   273,   250,   310,   322,
     319,     0,     0,   434,     5,     8,     0,   231,   470,   233,
      17,     0,   456,   224,     0,     0,   461,     0,   470,     0,
     307,     0,     0,     0,     0,    78,     0,   470,   470,     0,
       0,   470,   163,     0,     0,    62,    63,     0,     0,    51,
      49,    46,    47,   470,     0,   470,     0,   470,   470,     0,
     112,   470,   470,     0,     0,     0,     0,     0,     0,   273,
     470,     0,     0,   356,   364,   365,   366,   367,   368,   369,
     370,   371,     0,     0,     0,     0,     0,     0,     0,     0,
     244,     0,   239,   470,   351,   307,     0,   350,   352,   355,
     353,   241,   238,   439,   437,     0,   311,   470,   287,     0,
       0,   281,   318,   248,   246,     0,   293,     0,   350,   249,
     470,     0,   260,   286,   265,   299,   300,   274,   251,   470,
       0,   252,   470,     0,   283,   257,   282,   265,   288,   443,
     442,   441,     0,     0,   232,   235,   430,     0,   431,   455,
     116,   464,     0,    68,    45,   337,     0,   470,    70,     0,
       0,     0,    74,     0,     0,     0,    98,     0,     0,   159,
       0,   470,   161,     0,     0,   103,     0,     0,     0,   107,
     254,   255,   256,    42,     0,   104,   106,   432,     0,   433,
      54,     0,    53,     0,     0,   152,   470,   156,   409,   154,
     145,     0,   430,     0,     0,     0,     0,     0,     0,     0,
     265,     0,   470,     0,   340,   470,   470,   138,   319,     0,
       0,   362,   389,   390,   363,   392,   391,   428,     0,   240,
     243,   393,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   435,
       0,   287,   281,   318,     0,   273,   297,   295,   283,     0,
     273,   288,     0,   338,   294,   281,   318,   266,   470,     0,
     298,     0,   278,     0,     0,   291,     0,   258,   284,   289,
       0,   261,   440,     7,   470,     0,   470,     0,     0,   460,
       0,     0,    69,    39,    77,     0,     0,     0,     0,     0,
       0,     0,   160,     0,     0,   470,   470,     0,     0,   108,
       0,   470,     0,     0,     0,     0,     0,   143,     0,   153,
     158,    58,     0,     0,     0,     0,    79,     0,   126,   470,
       0,   318,     0,     0,   122,   470,     0,   142,   395,     0,
     394,   397,   357,     0,   301,     0,   470,   470,   387,   386,
     384,   385,     0,   383,   382,   378,   379,   377,   381,   380,
     373,   372,   376,   375,   374,     0,     0,   288,   276,   275,
     289,     0,     0,     0,   265,   267,   288,     0,   270,     0,
     280,   279,   296,   292,     0,   262,   290,   264,   234,    66,
      67,    65,     0,   465,   466,   469,   468,   462,    43,    44,
       0,    76,    73,    75,   459,    93,   458,     0,    88,   470,
     457,    92,     0,   468,     0,     0,    99,   470,   198,   165,
     164,     0,   223,     0,     0,    50,    48,   470,    41,   105,
     447,     0,   449,     0,    57,     0,     0,   110,   470,   470,
     470,   470,     0,     0,   341,   346,     0,   342,   470,   470,
       0,   119,   121,   118,     0,   123,   171,   190,     0,     0,
       0,     0,   227,     0,   214,   215,   207,   216,   188,   169,
     212,   208,   206,   209,   210,   211,   213,   189,   185,   186,
     173,   179,   183,   182,     0,     0,   174,   175,   178,   184,
     176,   180,   177,   187,     0,   230,   470,   136,   358,     0,
     301,   300,     0,     0,     0,   242,     0,   470,   277,   247,
     268,     0,   272,   271,   263,   117,     0,     0,     0,   470,
       0,   414,     0,   417,     0,     0,     0,     0,    90,   470,
       0,   162,   224,   470,     0,   101,     0,   100,     0,     0,
       0,   445,     0,   470,     0,    52,   146,   147,   150,   149,
     144,   148,   151,     0,   157,     0,     0,    81,   347,   470,
     470,     0,   470,   337,   470,   129,     0,   470,   470,     0,
     167,   200,   199,   201,     0,     0,     0,   166,     0,     0,
     470,   318,   412,   396,   398,   400,   413,     0,   360,   359,
       0,   354,   388,   237,   269,   467,   463,    40,     0,   470,
       0,    84,   468,    95,    89,   470,     0,     0,    97,    71,
       0,     0,   109,   454,   452,   453,   448,   450,     0,    55,
      56,     0,    59,    80,     0,   345,   344,   127,   470,     0,
       0,     0,     0,   424,   470,     0,     0,   172,     0,     0,
     470,   470,     0,   470,     0,     0,   319,   181,   470,   405,
     404,   406,     0,   402,     0,   361,     0,     0,   470,    96,
       0,    91,   470,    86,    72,   102,   451,   446,     0,   348,
     349,   470,     0,     0,   422,   423,   425,     0,   418,   419,
     124,   120,   470,     0,   470,     0,     0,   470,     0,     0,
       0,     0,   204,     0,   399,   401,   470,     0,    94,   415,
       0,    85,     0,   111,   343,   128,   420,   421,     0,   427,
     125,     0,     0,   470,   139,     0,   470,   470,     0,   470,
     222,     0,   202,     0,   140,   137,   470,   416,    87,   426,
     168,   470,   192,     0,   470,     0,     0,   470,   191,   205,
       0,   403,     0,   193,     0,   217,   218,   197,   470,   470,
       0,   203,   141,   219,   221,   337,   195,   194,   470,     0,
     196,   220
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     4,     5,    92,    93,    94,   550,   614,   615,   616,
     617,    99,   340,   341,   618,   619,   590,   102,   103,   620,
     105,   621,   107,   622,   552,   184,   623,   110,   624,   558,
     448,   625,   315,   626,   324,   206,   335,   207,   627,   628,
     629,   630,   436,   118,   603,   483,   119,   120,   121,   122,
     123,   737,   486,   875,   631,   632,   588,   700,   344,   345,
     346,   469,   633,   127,   455,   321,   634,   788,   719,   635,
     636,   637,   638,   639,   640,   641,   890,   871,   642,   882,
     893,   643,   644,   259,   167,   294,   168,   241,   242,   379,
     243,   484,   150,   329,   151,   272,   152,   153,   154,   218,
      40,    41,   244,   180,    43,    44,    45,    46,   264,   265,
     363,   595,   596,   709,   819,   246,   268,   248,   249,   489,
     490,   646,   733,   734,   802,   846,   803,    47,    48,   735,
     894,   715,   782,   825,   826,   132,   301,   338,    49,   163,
      50,   583,   691,   250,   561,   175,   302,   547,   169
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -782
static const yytype_int16 yypact[] =
{
     717,  1945,  2069,    87,    80,  2674,  -782,  -782,   -48,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,   -48,  -782,  -782,  -782,  -782,  -782,    77,  -782,  -782,
    -782,  -782,  -782,   176,  -782,  -782,   -23,   177,  -782,   250,
    3576,   819,   877,   819,  -782,  -782,  3628,  -782,   176,  -782,
     239,  -782,   269,   288,  3321,  -782,    85,  -782,  -782,  -782,
     179,  -782,  -782,   342,   346,  2193,   354,  -782,  -782,   346,
     361,   375,   384,  -782,  -782,  -782,   391,  -782,   308,   192,
     407,   152,   433,   316,   530,  3372,  3372,   449,   460,   342,
     472,   380,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,   346,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
     420,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  3423,
    -782,  1758,  -782,  -782,  -782,   310,  -782,    50,   461,  -782,
     819,  -782,  1475,   432,  1882,  2439,    37,   294,   176,  -782,
    -782,   252,   137,   252,   340,   139,   412,  -782,  -782,  -782,
    -782,   518,    59,  -782,  -782,  -782,   499,  -782,   503,  -782,
    -782,   441,  -782,    95,   441,   441,  -782,   506,   180,   909,
    -782,   347,   176,   555,   563,  -782,   441,  3270,  3321,   176,
     539,   245,  -782,   553,   598,  -782,  -782,   441,   611,  -782,
    -782,  -782,   617,  3321,   601,   161,   587,   593,   441,   342,
     617,  3321,  3321,   176,   342,    97,   146,   441,   967,   548,
     206,   927,   325,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  2439,   605,  2439,  2439,  2439,  2439,  2439,  2439,
    -782,   562,  -782,   623,   627,   309,  1716,    25,  -782,  -782,
     617,  -782,  -782,  -782,   239,   575,  -782,  2378,   121,   635,
     645,   966,   583,  -782,   639,  2439,  -782,  3573,  -782,  1716,
    2378,   176,   404,   340,  -782,  -782,   565,  -782,  -782,  3321,
    2006,  -782,  3321,  2130,    37,   404,   340,   594,  1053,  -782,
    -782,   239,   660,  3321,  -782,  -782,  -782,   665,   617,  -782,
    -782,   318,   667,  -782,  -782,  -782,   274,   252,  -782,   669,
     671,   681,   675,   463,   685,   682,  -782,   692,   691,  -782,
     176,  -782,  -782,   695,   697,  -782,   700,   704,  3372,  -782,
    -782,  -782,  -782,  -782,  3372,  -782,  -782,  -782,   706,  -782,
    -782,   599,   154,   708,   655,  -782,   718,  -782,    53,  -782,
    -782,    60,   396,   164,   164,   653,   734,   145,   738,   146,
     677,  1053,    40,   743,  -782,  2563,  1060,  -782,   588,  1280,
    3474,  1145,  -782,  -782,  -782,  -782,  -782,  -782,  1758,  -782,
    -782,  -782,  2439,  2439,  2439,  2439,  2439,  2439,  2439,  2439,
    2439,  2439,  2439,  2439,  2439,  2439,  2439,  2439,  2439,  -782,
     461,   452,  1025,   678,   382,  -782,  -782,  -782,   452,   592,
     686,   164,  2439,  1716,  -782,   969,    12,  -782,  3321,  2254,
    -782,   758,  -782,  3602,   762,  -782,  3647,   404,   340,   972,
     146,   404,  -782,  -782,   503,   381,  -782,   441,  1407,  -782,
     763,   769,  -782,  -782,  -782,   589,   402,  1356,   776,  3321,
     909,   764,  -782,   779,  2775,  -782,   438,  3372,   508,   785,
     757,   593,   212,   792,   441,  3321,   736,  -782,  3321,  -782,
    -782,  -782,   164,   256,   146,    33,  -782,  1068,  -782,   775,
     797,   653,   803,   425,  -782,   319,  1651,  -782,  -782,   798,
    -782,  -782,  2439,  2315,  2500,    10,   877,   623,  1082,  1082,
    1310,  1310,  2541,  1267,  1162,  1519,  1219,  1145,  1044,  1044,
     755,   755,  -782,  -782,  -782,   176,   686,  -782,  -782,  -782,
     452,   633,  3676,   642,   686,  -782,   146,   808,  -782,  3721,
    -782,  -782,  -782,  -782,   146,   404,   340,   404,  -782,  -782,
    -782,   617,  2876,  -782,   813,  -782,   154,   834,  -782,  -782,
    1651,  -782,  -782,   617,  -782,  -782,  -782,   810,  -782,   715,
     617,  -782,   799,   122,   673,   402,  -782,   715,  -782,  -782,
    -782,  2977,   342,  3525,   850,  -782,  -782,  3321,  -782,  -782,
     299,   731,  -782,   771,  -782,   836,   838,  -782,   584,   718,
    -782,   715,   100,   146,  -782,   882,    51,  -782,  1052,  3321,
     909,  -782,  -782,  -782,   848,  -782,  -782,  -782,   849,   818,
     826,   830,   780,   518,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,   860,  1651,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  -782,  3168,   866,   837,  -782,  1716,  2439,
    2500,  1821,  2439,   878,   881,  -782,  2439,   252,  -782,  -782,
    -782,   767,  -782,  -782,   404,  -782,   441,   441,   876,  3321,
     884,   846,   736,  -782,  1407,   293,   441,   888,  -782,   715,
     890,  -782,   617,    20,   909,  -782,  3372,  -782,   895,   933,
      73,  -782,    79,  1758,   257,  -782,  -782,  -782,  -782,  -782,
    -782,  -782,  -782,  3219,  -782,  3078,   897,  -782,   887,   775,
     775,   811,  3321,  -782,   867,  -782,   903,  1060,  3321,  1651,
    -782,  -782,  -782,  -782,   518,   906,   909,  -782,  3474,   248,
     115,   904,  -782,   908,  -782,   824,  -782,  1651,  1716,  1716,
    2439,  -782,  1345,  -782,  -782,  -782,  -782,  -782,   907,  3321,
     911,  -782,   617,   913,  -782,   715,   885,   736,  -782,  -782,
     917,   918,  -782,  -782,   299,  -782,   299,  -782,   863,  -782,
    -782,   961,  -782,  -782,  2439,  -782,   882,  -782,  1060,   915,
     920,   176,   510,  -782,   252,   425,   929,  -782,  1651,   935,
    3321,  1060,   203,  2563,  2439,   941,   588,  -782,   837,  -782,
    -782,  -782,   176,  -782,   926,  1716,   945,   948,  3321,  -782,
     950,  -782,   715,  -782,  -782,  -782,  -782,  -782,   952,  -782,
    1716,   775,   425,   532,  -782,   957,  -782,   962,  -782,  -782,
    -782,  -782,   252,   963,  3321,   974,   425,  3321,   976,   -22,
     981,  1507,  -782,   971,  -782,  -782,   837,   922,  -782,  -782,
     997,  -782,   996,  -782,  -782,  -782,  -782,  -782,   176,  -782,
    -782,  1651,   999,   715,  -782,  1001,  3321,  3321,  1003,  1052,
    -782,   922,  -782,   176,  -782,  -782,  1060,  -782,  -782,  -782,
    -782,   715,  -782,   610,   715,  1004,  1008,  3321,  -782,  -782,
     922,  -782,   425,  -782,   634,  -782,  -782,  -782,   715,   715,
    1011,  -782,  -782,  -782,  -782,  -782,  -782,  -782,   715,  1013,
    -782,  -782
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -782,  -782,  -284,  -782,  -782,  -782,  -782,    21,    28,    13,
      39,  -782,   604,  -782,    41,    45,  -782,  -782,  -782,    54,
    -782,    63,  -782,    66,  -782,  -782,    78,  -782,   102,  -443,
    -530,   106,  -782,   124,  -782,  -287,   591,   -84,   125,   157,
     182,   196,  -782,   467,  -749,  -679,  -782,  -782,  -782,  -782,
     469,  -782,  -782,  -781,    -2,     6,  -782,  -782,  -782,  -782,
     590,   473,   214,  -782,  -782,  -782,  -531,  -782,  -782,  -782,
     477,  -782,   478,   228,  -782,  -782,  -782,  -782,  -782,  -782,
    -460,  -782,    -3,   -42,  -782,   643,    96,   389,  -782,   597,
     710,   -15,   600,  -782,   -71,    48,  -172,   -85,  -126,   -32,
     -26,  -782,   689,    23,   -36,  -782,  1051,  -782,  -299,  -782,
    -782,  -631,  -782,   326,  -782,   916,  -118,  -416,  -782,  -670,
    -782,  -782,  -782,   305,  -782,  -782,  -782,  -205,   -82,   259,
    -524,   241,  -782,  -782,   253,  1092,  -123,  -782,   761,    44,
    -107,  -782,  -157,   781,   542,   215,  -183,  -419,     0
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -471
static const yytype_int16 yytable[] =
{
       6,   204,   129,   124,   140,   130,   440,   348,   133,   213,
     155,   125,   166,   247,   325,   141,   867,   158,    97,   668,
     273,   133,   545,   587,    42,    42,    95,   149,   564,   286,
     254,   545,   356,    96,   677,   672,   831,   454,   785,   217,
       8,   460,   157,   680,    98,   131,   100,   222,   297,   652,
     101,   525,   303,     8,   289,   291,   255,   260,   309,   104,
     795,   759,     8,   313,   176,  -245,   299,   706,   106,   176,
     185,   108,   525,   855,   714,   270,   764,    42,   775,   776,
      55,   478,   766,   109,  -339,   337,   404,   864,    53,   409,
     889,   710,   144,  -155,   358,   868,   711,    39,    52,   822,
     352,   299,   176,   172,   727,   137,   299,   111,   307,   901,
     261,   112,   836,   131,   256,   275,   526,   471,     8,  -245,
     331,   276,   678,   135,     8,    54,   843,   653,   299,   113,
     114,   251,   273,   131,   330,   286,   278,   593,   281,   300,
      36,   707,     8,   902,    38,   316,   317,  -155,     8,     8,
     366,   157,   542,   157,   245,   757,   195,   253,   428,   142,
     299,   327,   115,   271,     8,    42,   290,     8,   295,   343,
     574,   571,   260,   155,  -431,   279,   144,   270,   133,     8,
     765,   404,   409,   354,   357,   260,   767,   116,   787,   488,
     854,   133,   280,   170,   144,   191,   196,   892,   465,   142,
      36,   117,   306,   285,    38,   332,   804,   336,   339,   362,
      42,    42,   349,   155,   353,   580,   144,   171,    36,   126,
     364,   147,    38,   809,    36,   402,    42,   240,    38,   751,
     149,   810,   305,   128,    42,    42,   192,   421,   415,   521,
     424,   837,    36,   380,   420,   157,    38,   148,    36,    36,
     461,     8,    38,    38,   543,   753,   284,   833,   545,     8,
     247,   769,   172,   348,    36,   271,   285,    36,    38,   147,
     138,    38,   271,   131,   354,   273,   286,     8,   146,    36,
      42,   585,   428,    38,   182,   147,   793,   148,   852,   286,
     148,   139,   441,    42,   306,    36,     8,   320,   399,    38,
     521,   770,    42,   536,   143,    42,   705,   157,   347,    36,
     164,     8,     8,    38,   813,   581,    42,   214,   515,   582,
     838,     6,   794,   480,   562,   474,   145,   147,     8,   165,
     880,   306,   427,   354,   754,   432,   431,   495,   131,   883,
     485,    28,    29,    30,   161,   714,   470,   142,   172,  -470,
     296,    36,   133,   172,   198,    38,   252,   199,   437,    36,
     200,   143,   133,    38,   144,   216,   157,   162,   491,   367,
     438,   143,   147,   216,   148,   559,   527,    36,   282,   567,
     147,    38,   148,   145,   174,   539,   308,   172,    42,   434,
     189,   353,   181,   145,   536,   283,    36,   604,   147,   183,
      38,   245,   591,  -470,   689,     8,   554,   427,   172,   431,
     216,    36,    36,   186,   780,    38,    38,   147,   147,   148,
     279,   518,   187,     8,   897,   540,   146,   690,    36,   188,
      31,    32,    38,   147,   295,   148,     6,   280,   906,   907,
     306,    42,   418,   555,   296,   194,   556,   172,   910,    34,
      35,   129,   124,   573,   130,     6,   130,    61,   215,   419,
     125,   336,   275,   523,   155,   600,   601,    97,   651,   602,
     605,   197,    42,   212,   240,    95,   263,   535,   537,   597,
     572,   149,    96,   745,   746,   157,   645,   208,    42,   131,
     257,    42,   594,    98,   679,   100,   157,   380,   209,   101,
    -470,  -470,   446,   447,   557,    36,   725,   144,   104,    38,
     211,    31,    32,    73,    74,    75,   288,   106,    77,   216,
     108,     8,   523,    36,  -470,   535,   147,    38,   148,   717,
      34,    35,   109,   671,   201,   688,   172,   216,   292,   129,
     124,   671,   130,   293,   147,   566,   148,   304,   125,   575,
     645,   828,   576,   562,   829,    97,   111,   716,   311,   673,
     112,   586,   730,    95,   347,   671,   312,   673,   129,   124,
      96,   130,   671,   856,   661,   247,   857,   125,   113,   114,
     319,    98,   664,   100,    97,   703,   698,   101,   130,   470,
       6,   673,    95,   551,   699,   172,   104,   322,   673,    96,
      42,   323,   761,    61,   755,   106,   909,   816,   108,   817,
      98,   115,   100,   760,   326,   140,   101,   789,   275,   420,
     109,   222,    42,   299,   651,   104,   572,   748,   333,   487,
     279,   519,  -470,   334,   106,   645,   116,   108,   463,   464,
     778,   661,   743,   370,   111,   328,   736,   280,   112,   109,
     117,   895,   361,   671,   896,   791,   377,   157,   366,    73,
      74,    75,   488,   378,    77,   381,   113,   114,   126,   400,
     779,   279,   658,   111,   406,   903,   786,   112,   904,   673,
     418,   660,   128,   133,   407,   812,   905,   411,   280,   147,
      91,   485,    42,   251,   412,   113,   114,   419,   429,   115,
     366,   433,   129,   124,   435,   130,   439,   807,   442,   597,
     597,   125,   675,   676,   783,   443,   245,   157,    97,   645,
     444,   450,   594,   594,   116,   449,    95,   445,   115,   671,
     491,   451,   452,    96,   456,    42,   457,   645,   117,   458,
     554,    42,   172,   459,    98,   462,   100,   466,   835,   467,
     101,   840,   485,   116,   179,   673,   126,   472,   468,   104,
     839,   354,    28,    29,    30,   485,   850,   117,   106,   830,
     128,   108,    42,   473,   205,   205,   876,   555,   157,   476,
     556,   477,   517,   109,   157,   126,   671,   479,   645,   240,
     520,   157,   862,   670,   136,   865,   491,   530,   736,   128,
     876,   532,   578,   156,   548,   418,   744,   111,   568,   160,
     549,   112,   673,    42,     8,   565,    42,   860,   221,   876,
     569,   597,   419,   577,   885,   886,     1,     2,     3,   113,
     114,    42,   157,   584,   594,    65,   598,   671,   557,   190,
     193,   599,   647,   671,   173,   900,   736,   662,   669,   306,
     485,   674,   777,   666,   554,   671,   172,    42,   671,   692,
      42,   645,   115,   673,   693,   202,    28,    29,    30,   673,
     210,   219,   671,   671,   667,   694,   157,   396,   397,   398,
       8,   673,   671,   695,   673,   708,   718,   116,     8,    42,
      42,   685,   721,   720,   556,   799,   800,   801,   673,   673,
     722,   117,   686,   262,   723,   726,   724,   274,   673,   277,
      42,  -170,     8,   732,    36,   142,   287,   740,    38,   126,
     741,   747,   749,   306,   750,     8,   811,   756,   216,   143,
       8,   758,   144,   128,   762,   147,   763,   148,   773,   774,
     219,   781,   784,   310,   790,   797,   806,   306,   798,   808,
     318,   145,   298,   676,   823,   298,   298,   818,   814,   815,
     306,   824,   298,   874,     8,   365,   156,   298,   832,     8,
       8,   847,     8,   834,   350,     8,   355,   274,   298,   360,
      36,   136,   219,   368,    38,   842,   848,   849,    36,   298,
     342,   851,    38,   853,   146,   351,   298,   858,   298,   793,
     859,   147,   216,   148,   142,   357,   156,   270,   861,   147,
     270,   148,    36,   863,   866,   872,    38,   205,   403,   405,
     869,   144,   410,   205,   144,    36,   216,   144,     8,    38,
      36,   416,   417,   147,    38,   148,   877,   878,   881,   216,
     884,   887,   544,   898,   216,   274,   147,   899,   148,   274,
     908,   147,   579,   148,   911,   696,     8,   697,   589,   496,
     267,   269,   704,   257,    36,   701,   702,   355,    38,    36,
      36,     8,    36,    38,    38,    36,    38,   538,   216,    38,
     144,   453,   768,   408,   359,   147,   408,   148,   497,   534,
     712,   357,   148,   271,   655,   271,   654,   159,   271,    28,
      29,    30,   821,   844,   713,   873,   357,    28,    29,    30,
     888,   879,   143,   134,   405,   405,   687,     0,   475,     0,
     274,     0,   274,     0,     0,     0,   481,     0,    36,     0,
     670,     0,    38,     0,   145,     0,     0,     0,   482,     0,
       0,     0,   408,     0,     0,     0,   205,     0,   369,     0,
     371,   372,   373,   374,   375,   376,    36,     0,     0,     0,
      38,     0,     0,   516,   394,   395,   396,   397,   398,     0,
     430,    36,   405,     0,     0,    38,   524,     0,     0,   271,
       0,   413,     0,     0,     0,   534,     0,     0,     0,     0,
     274,   274,     0,     0,   271,     0,   423,     0,     0,   426,
     392,   393,   394,   395,   396,   397,   398,   219,     0,     0,
       0,   219,     0,     0,     0,     0,   541,     0,   298,   546,
       0,     0,     0,     0,     0,     0,   553,   560,   563,     0,
       0,     0,     0,   405,   219,   274,     0,     0,   274,     0,
       0,   382,   383,   384,   385,   298,     0,   560,     0,     0,
       0,     0,     0,     0,   592,     0,     0,   156,   382,   383,
     384,   385,   684,   392,   393,   394,   395,   396,   397,   398,
       0,     0,     0,     0,     0,     0,   657,   389,   390,   391,
     392,   393,   394,   395,   396,   397,   398,   274,     0,     0,
       0,     0,     0,     0,     0,   274,     0,     0,   498,   499,
     500,   501,   502,   503,   504,   505,   506,   507,   508,   509,
     510,   511,   512,   513,   514,   382,   383,   384,   385,   492,
       0,     0,     0,     0,     0,     0,   219,     0,   522,     0,
       0,     0,     0,   729,     0,   529,   391,   392,   393,   394,
     395,   396,   397,   398,     0,     0,   560,     0,     0,     0,
       0,     0,     0,   682,   274,   560,     0,     0,     0,   296,
       0,   219,   172,   382,   383,   384,   385,   224,   225,   226,
     227,   228,   229,   230,   231,   205,   382,   383,   384,   385,
     386,   388,   389,   390,   391,   392,   393,   394,   395,   396,
     397,   398,   771,   387,   388,   389,   390,   493,   392,   393,
     394,   395,   396,   397,   494,   731,   382,   383,   648,   507,
     514,     0,     0,   172,     0,     0,     0,   792,   224,   225,
     226,   227,   228,   229,   230,   231,     0,     0,   392,   393,
     394,   395,   396,   397,   398,     0,   219,     0,     0,     0,
       0,   382,   383,   384,   385,   219,     0,   298,   298,     0,
       0,     0,     0,   560,     0,   752,     0,   298,   387,   388,
     389,   390,   391,   392,   393,   394,   395,   396,   397,   398,
       0,     0,   219,     0,     0,     0,     0,     0,     8,     0,
       0,     0,     0,     0,     0,     0,     0,   219,     0,     0,
     219,   796,     0,     0,     0,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,   257,     0,     0,     0,   219,     0,     0,
       0,    27,    28,    29,    30,    31,    32,     0,     0,     0,
     144,     0,   219,     0,     0,     0,     0,     0,   560,     0,
       0,     0,   827,    33,    34,    35,     0,     0,   870,     0,
       0,     0,     0,     0,   481,     0,     0,     0,     0,     0,
       0,     0,     0,   845,     0,   738,   374,     0,   739,     0,
       0,     0,   742,     0,     0,     0,     0,     0,    36,     0,
       0,    37,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   258,     0,     0,     0,     0,     0,     0,   147,
       0,     0,     0,   382,   383,   384,   385,   386,   219,     0,
       0,     0,     0,     0,     0,   382,   383,   384,   385,   827,
     387,   388,   389,   390,   391,   392,   393,   394,   395,   396,
     397,   398,   219,     0,   891,   390,   391,   392,   393,   394,
     395,   396,   397,   398,     0,     0,     0,     0,     0,     0,
       0,   219,   606,     0,  -470,    57,   805,     0,    58,    59,
      60,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      61,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,     0,
     820,     0,   607,    63,     0,     0,  -470,     0,  -470,  -470,
    -470,  -470,  -470,     0,     0,     0,     0,     0,     0,     0,
     841,    65,    66,    67,    68,   608,    70,    71,    72,  -470,
    -470,  -470,   609,   610,   611,     0,    73,   612,    75,     0,
      76,    77,    78,     0,     0,     0,    82,     0,    84,    85,
      86,    87,    88,    89,     0,     0,     0,     0,     0,     0,
       0,     0,    90,     0,  -470,     0,     0,    91,  -470,  -470,
       0,     8,     0,     0,   172,     0,     0,     0,   223,   224,
     225,   226,   227,   228,   229,   230,   231,   613,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,   232,     0,     0,     0,
       0,     0,     0,     0,    27,    28,    29,    30,    31,    32,
       0,   233,   382,   383,   384,   385,   386,     0,     0,     0,
       0,     0,     0,     0,     8,     0,    33,    34,    35,   387,
     388,   389,   390,   391,   392,   393,   394,   395,   396,   397,
     398,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,     0,
       0,    36,     0,     0,    37,    38,     0,     0,     0,     0,
       0,    31,    32,     0,     0,   234,     0,     0,   235,   236,
       0,     0,   237,   238,   239,     8,     0,     0,   172,    33,
      34,    35,   223,   224,   225,   226,   227,   228,   229,   230,
     231,     0,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
     232,     0,     0,     0,    36,     0,     0,     0,    38,    28,
      29,    30,    31,    32,     0,   233,     0,     0,   266,     0,
       0,     0,     0,     0,     0,   147,     7,     0,     8,     0,
      33,    34,    35,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,     0,     0,    36,     0,     0,     0,    38,
       0,    27,    28,    29,    30,    31,    32,     0,     0,   234,
       0,     0,   235,   236,     0,     0,   237,   238,   239,     8,
       0,     0,   172,    33,    34,    35,   223,   224,   225,   226,
     227,   228,   229,   230,   231,     0,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,   232,     0,     0,     0,    36,     0,
       0,    37,    38,    28,    29,    30,    31,    32,     0,   233,
       0,     0,   422,     0,     0,     0,     0,     0,     0,     0,
      51,     0,     8,     0,    33,    34,    35,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,     0,     0,    36,
       0,     0,     0,    38,     0,    27,    28,    29,    30,    31,
      32,     0,     0,   234,     0,     0,   235,   236,     0,     0,
     237,   238,   239,     8,     0,     0,   172,    33,    34,    35,
     223,   224,   225,   226,   227,   228,   229,   230,   231,     0,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,   232,     0,
       0,     0,    36,     0,     0,    37,    38,    28,    29,    30,
      31,    32,     0,   233,     0,     0,   425,     0,     0,     0,
       0,     0,     0,     0,   177,     0,   178,     0,    33,    34,
      35,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,     0,     0,    36,     0,     0,     0,    38,     0,     0,
      28,    29,    30,    31,    32,     0,     0,   234,     0,     0,
     235,   236,     0,     0,   237,   238,   239,     8,     0,     0,
     172,    33,    34,    35,   223,   224,   225,   226,   227,   228,
     229,   230,   231,     0,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,   232,     0,     0,     0,    36,     0,     0,     0,
      38,    28,    29,    30,    31,    32,     0,   233,     0,     0,
     528,     0,     0,     0,     0,     0,     0,     0,     8,     0,
       0,   172,    33,    34,    35,   223,   224,   225,   226,   227,
     228,   229,   230,   231,     0,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,   232,   649,     0,     0,    36,     0,     0,
       0,    38,    28,    29,    30,    31,    32,     0,   233,     0,
       0,   234,     0,     0,   235,   236,     0,     0,   237,   238,
     239,     8,     0,    33,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,   257,     0,    36,     0,
       0,     0,    38,     0,    27,    28,    29,    30,    31,    32,
       0,     0,   234,   144,     0,   235,   236,     0,     0,   237,
     238,   239,     8,     0,     0,   172,    33,    34,    35,   223,
     224,   225,   226,   227,   228,   229,   230,   231,     0,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,   232,     0,     0,
       0,    36,     0,     0,    37,    38,    28,    29,    30,    31,
      32,     0,   233,     0,     0,   401,     0,     0,     0,     0,
       0,     0,   147,     8,     0,     0,   172,    33,    34,    35,
     223,   224,   225,   226,   227,   228,   229,   230,   231,     0,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,   232,     0,
       0,     0,    36,     0,     0,     0,    38,    28,    29,    30,
      31,    32,     0,   233,     0,     0,   234,     0,     0,   235,
     236,     0,     0,   237,   238,   239,     8,     0,    33,    34,
      35,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,     0,     0,    36,     0,     0,     0,    38,     0,    27,
      28,    29,    30,    31,    32,   656,     0,     0,     0,     0,
     235,   236,     0,     0,   650,   238,   239,     0,     0,     0,
       0,    33,    34,    35,     0,     0,     0,   382,   383,   384,
     385,   386,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   387,   388,   389,   390,   391,   392,
     393,   394,   395,   396,   397,   398,    36,     0,     0,    37,
      38,     0,     0,     0,    -2,    56,     0,  -470,    57,     0,
     353,    58,    59,    60,     0,     0,     0,   147,     0,     0,
       0,     0,     0,    61,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,     0,     0,     0,    62,    63,     0,     0,     0,
       0,  -470,  -470,  -470,  -470,  -470,     0,     0,    64,     0,
       0,     0,     0,     0,    65,    66,    67,    68,    69,    70,
      71,    72,  -470,  -470,  -470,     0,     0,     0,     0,    73,
      74,    75,     0,    76,    77,    78,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,     0,     0,     0,
       0,     0,     0,     0,     0,    90,    56,  -470,  -470,    57,
      91,  -470,    58,    59,    60,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    61,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,     0,     0,     0,    62,    63,     0,     0,
     570,     0,  -470,  -470,  -470,  -470,  -470,     0,     0,    64,
       0,     0,     0,     0,     0,    65,    66,    67,    68,    69,
      70,    71,    72,  -470,  -470,  -470,     0,     0,     0,     0,
      73,    74,    75,     0,    76,    77,    78,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,     0,     0,
       0,     0,     0,     0,     0,     0,    90,    56,  -470,  -470,
      57,    91,  -470,    58,    59,    60,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    61,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,     0,     0,     0,    62,    63,     0,
       0,   665,     0,  -470,  -470,  -470,  -470,  -470,     0,     0,
      64,     0,     0,     0,     0,     0,    65,    66,    67,    68,
      69,    70,    71,    72,  -470,  -470,  -470,     0,     0,     0,
       0,    73,    74,    75,     0,    76,    77,    78,    79,    80,
      81,    82,    83,    84,    85,    86,    87,    88,    89,     0,
       0,     0,     0,     0,     0,     0,     0,    90,    56,  -470,
    -470,    57,    91,  -470,    58,    59,    60,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    61,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,     0,     0,     0,    62,    63,
       0,     0,   681,     0,  -470,  -470,  -470,  -470,  -470,     0,
       0,    64,     0,     0,     0,     0,     0,    65,    66,    67,
      68,    69,    70,    71,    72,  -470,  -470,  -470,     0,     0,
       0,     0,    73,    74,    75,     0,    76,    77,    78,    79,
      80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
       0,     0,     0,     0,     0,     0,     0,     0,    90,    56,
    -470,  -470,    57,    91,  -470,    58,    59,    60,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    61,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,  -470,
    -470,  -470,  -470,  -470,  -470,  -470,     0,     0,     0,    62,
      63,     0,     0,     0,     0,  -470,  -470,  -470,  -470,  -470,
       0,     0,    64,     0,     0,     0,   772,     0,    65,    66,
      67,    68,    69,    70,    71,    72,  -470,  -470,  -470,     0,
       0,     0,     0,    73,    74,    75,     0,    76,    77,    78,
      79,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,     8,     0,     0,     0,     0,     0,     0,     0,    90,
       0,  -470,     0,     0,    91,  -470,     0,     0,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    28,    29,    30,    31,    32,
       0,     0,     8,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   220,    34,    35,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    28,    29,    30,    31,
      32,    36,     0,     8,     0,    38,   728,     0,     0,     0,
       0,   314,     0,     0,     0,     0,     0,    33,    34,    35,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,     0,     0,
       0,     0,     0,     0,     0,     0,    27,    28,    29,    30,
      31,    32,    36,     0,     8,     0,    38,   728,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,    34,
      35,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,     0,
       0,     0,     0,     0,     0,     0,     0,    27,    28,    29,
      30,    31,    32,    36,     0,     8,    37,    38,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
      34,    35,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
     203,     0,     0,     0,     0,     0,     0,     0,     0,    28,
      29,    30,    31,    32,    36,     0,     8,    37,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,    34,    35,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      28,    29,    30,    31,    32,    36,     0,     8,     0,    38,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   220,    34,    35,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    28,    29,    30,    31,    32,    36,     0,   683,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,    34,    35,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    28,    29,    30,    31,    32,    36,     0,     8,
       0,    38,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,    34,    35,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    31,    32,    36,   414,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,    34,    35,     0,     9,    10,
      11,    12,    13,    14,    15,    16,     0,    18,   531,    20,
       0,     0,    23,    24,    25,    26,     0,     0,     0,   382,
     383,   384,   385,   386,     0,     0,     0,     0,     0,    36,
       0,     0,     0,    38,     0,     0,   387,   388,   389,   390,
     391,   392,   393,   394,   395,   396,   397,   398,   382,   383,
     384,   385,   386,   533,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   387,   388,   389,   390,   391,
     392,   393,   394,   395,   396,   397,   398,     0,     0,     0,
       0,     0,   659,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   382,   383,   384,   385,   386,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     387,   388,   389,   390,   391,   392,   393,   394,   395,   396,
     397,   398,   382,   383,   384,   385,   386,   663,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   387,
     388,   389,   390,   391,   392,   393,   394,   395,   396,   397,
     398,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   382,   383,   384,
     385,   386,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   387,   388,   389,   390,   391,   392,
     393,   394,   395,   396,   397,   398
};

static const yytype_int16 yycheck[] =
{
       0,    85,     5,     5,    40,     5,   305,   212,     8,    91,
      42,     5,    54,   131,   197,    41,    38,    43,     5,   550,
     146,    21,   438,   466,     1,     2,     5,    42,   447,   155,
     137,   447,   215,     5,   564,   559,   785,   321,   717,   110,
       3,   328,    42,   567,     5,    93,     5,   129,   171,    39,
       5,    39,   175,     3,   161,   162,   138,   142,   181,     5,
     730,    41,     3,   186,    64,    40,     6,   591,     5,    69,
      70,     5,    39,   822,   598,    38,     3,    54,   709,   710,
       0,    41,     3,     5,    44,   208,   258,   836,     1,   261,
     871,    40,    55,    40,   217,   117,    45,     1,     2,   778,
       3,     6,   102,     6,   635,   128,     6,     5,   179,   890,
     142,     5,   791,    93,   140,   147,   104,    57,     3,    94,
     205,   147,   565,    46,     3,    38,   796,   117,     6,     5,
       5,   131,   258,    93,   205,   261,   151,   104,   153,    44,
     103,    41,     3,   892,   107,   187,   188,    94,     3,     3,
     221,   151,   436,   153,   131,   679,     4,   107,   284,    38,
       6,   203,     5,   126,     3,   142,   107,     3,   168,   211,
     457,   455,   257,   205,    52,    38,    55,    38,   178,     3,
     107,   353,   354,   215,    38,   270,   107,     5,   719,    74,
     821,   191,    55,   108,    55,     3,    44,   876,    44,    38,
     103,     5,    38,   155,   107,   205,   737,   207,   208,     3,
     187,   188,   212,   245,   117,     3,    55,    38,   103,     5,
     220,   124,   107,   753,   103,   257,   203,   131,   107,   672,
     245,   755,    52,     5,   211,   212,    44,   279,   270,   411,
     282,    38,   103,   243,   276,   245,   107,   126,   103,   103,
     334,     3,   107,   107,   437,   674,   117,   788,   674,     3,
     378,     4,     6,   468,   103,   126,   218,   103,   107,   124,
      93,   107,   126,    93,   306,   401,   402,     3,   117,   103,
     257,   464,   408,   107,    69,   124,    38,   126,   812,   415,
     126,    41,   307,   270,    38,   103,     3,    52,   254,   107,
     472,    44,   279,   429,    52,   282,   590,   307,   212,   103,
      41,     3,     3,   107,   757,   103,   293,   102,   400,   107,
     117,   321,    74,   365,   447,   357,    74,   124,     3,    41,
     861,    38,   284,   365,    41,   291,   288,   369,    93,   863,
     366,    47,    48,    49,   105,   869,   346,    38,     6,    40,
       3,   103,   352,     6,    38,   107,    46,    41,    40,   103,
      44,    52,   362,   107,    55,   117,   366,   128,   368,    44,
      52,    52,   124,   117,   126,   446,   418,   103,    38,   450,
     124,   107,   126,    74,    38,     4,    39,     6,   365,   293,
      82,   117,    38,    74,   520,    55,   103,    78,   124,    38,
     107,   378,   473,    94,   105,     3,     4,   359,     6,   361,
     117,   103,   103,    38,   713,   107,   107,   124,   124,   126,
      38,    39,    38,     3,   884,    44,   117,   128,   103,    38,
      50,    51,   107,   124,   434,   126,   436,    55,   898,   899,
      38,   418,    38,    41,     3,    38,    44,     6,   908,    69,
      70,   454,   454,   456,   454,   455,   456,    19,    38,    55,
     454,   461,   494,   415,   496,    40,    41,   454,   494,    44,
     485,    38,   449,    93,   378,   454,    44,   429,   430,   479,
      42,   496,   454,   666,   667,   485,   486,    38,   465,    93,
      38,   468,   479,   454,   565,   454,   496,   497,    38,   454,
     104,   105,    39,    40,   102,   103,   613,    55,   454,   107,
      38,    50,    51,    75,    76,    77,   104,   454,    80,   117,
     454,     3,   474,   103,   128,   477,   124,   107,   126,   600,
      69,    70,   454,   559,     4,   577,     6,   117,    39,   542,
     542,   567,   542,    40,   124,   449,   126,    41,   542,    41,
     550,    41,    44,   676,    44,   542,   454,   599,     3,   559,
     454,   465,   644,   542,   468,   591,     3,   567,   571,   571,
     542,   571,   598,    41,   526,   693,    44,   571,   454,   454,
      41,   542,   534,   542,   571,   588,   588,   542,   588,   589,
     590,   591,   571,     4,   588,     6,   542,    44,   598,   571,
     577,     3,   686,    19,   675,   542,   905,   764,   542,   766,
     571,   454,   571,   684,     3,   651,   571,   724,   650,   651,
     542,   703,   599,     6,   650,   571,    42,   669,    41,    41,
      38,    39,    44,    40,   571,   635,   454,   571,    39,    40,
     711,   593,   657,    38,   542,    44,   646,    55,   542,   571,
     454,    41,   104,   679,    44,   726,    94,   657,   729,    75,
      76,    77,    74,    40,    80,    38,   542,   542,   454,    94,
     712,    38,    39,   571,    39,    41,   718,   571,    44,   679,
      38,    39,   454,   683,    39,   756,    52,   104,    55,   124,
     106,   717,   669,   693,    55,   571,   571,    55,   104,   542,
     771,    41,   705,   705,    39,   705,    39,   749,    39,   709,
     710,   705,    39,    40,   714,    44,   693,   717,   705,   719,
      39,    39,   709,   710,   542,    40,   705,    52,   571,   755,
     730,    39,    41,   705,    39,   712,    39,   737,   542,    39,
       4,   718,     6,    39,   705,    39,   705,    39,   790,    94,
     705,   793,   778,   571,    65,   755,   542,   104,    40,   705,
     792,   793,    47,    48,    49,   791,   808,   571,   705,   784,
     542,   705,   749,    39,    85,    86,   847,    41,   778,    41,
      44,   104,   104,   705,   784,   571,   812,    44,   788,   693,
     104,   791,   834,    78,    33,   837,   796,    39,   798,   571,
     871,    39,    45,    42,    41,    38,    39,   705,    44,    48,
      41,   705,   812,   790,     3,    39,   793,   832,   129,   890,
      41,   821,    55,    38,   866,   867,   109,   110,   111,   705,
     705,   808,   832,    41,   821,    60,    39,   863,   102,    78,
      79,    38,    44,   869,    63,   887,   846,    39,    38,    38,
     876,    52,    41,    40,     4,   881,     6,   834,   884,   128,
     837,   861,   705,   863,    93,    84,    47,    48,    49,   869,
      89,   110,   898,   899,    40,    39,   876,   122,   123,   124,
       3,   881,   908,    45,   884,     3,    38,   705,     3,   866,
     867,    41,    74,    44,    44,    71,    72,    73,   898,   899,
      74,   705,    52,   142,    74,    45,   126,   146,   908,   148,
     887,    45,     3,    76,   103,    38,   155,    39,   107,   705,
      39,    45,    38,    38,    78,     3,    41,    39,   117,    52,
       3,    41,    55,   705,    39,   124,     3,   126,    41,    52,
     179,    74,    39,   182,    38,    41,    39,    38,    40,    38,
     189,    74,   171,    40,    39,   174,   175,    94,    41,    41,
      38,    41,   181,    41,     3,    38,   205,   186,    39,     3,
       3,    45,     3,    38,   213,     3,   215,   216,   197,   218,
     103,   220,   221,   222,   107,    44,    41,    39,   103,   208,
     209,    41,   107,    41,   117,   214,   215,    40,   217,    38,
      38,   124,   117,   126,    38,    38,   245,    38,    45,   124,
      38,   126,   103,    39,    38,    44,   107,   328,   257,   258,
      39,    55,   261,   334,    55,   103,   117,    55,     3,   107,
     103,   270,   271,   124,   107,   126,    39,    41,    39,   117,
      39,    38,   438,    39,   117,   284,   124,    39,   126,   288,
      39,   124,   461,   126,    41,   588,     3,   588,   468,   370,
     144,   145,   589,    38,   103,   588,   588,   306,   107,   103,
     103,     3,   103,   107,   107,   103,   107,   434,   117,   107,
      55,   320,   693,   117,   117,   124,   117,   126,   378,   117,
      38,    38,   126,   126,   497,   126,   496,    46,   126,    47,
      48,    49,   776,   798,    52,   846,    38,    47,    48,    49,
     869,   858,    52,    21,   353,   354,   574,    -1,   357,    -1,
     359,    -1,   361,    -1,    -1,    -1,   365,    -1,   103,    -1,
      78,    -1,   107,    -1,    74,    -1,    -1,    -1,    78,    -1,
      -1,    -1,   117,    -1,    -1,    -1,   457,    -1,   232,    -1,
     234,   235,   236,   237,   238,   239,   103,    -1,    -1,    -1,
     107,    -1,    -1,   402,   120,   121,   122,   123,   124,    -1,
     117,   103,   411,    -1,    -1,   107,   415,    -1,    -1,   126,
      -1,   265,    -1,    -1,    -1,   117,    -1,    -1,    -1,    -1,
     429,   430,    -1,    -1,   126,    -1,   280,    -1,    -1,   283,
     118,   119,   120,   121,   122,   123,   124,   446,    -1,    -1,
      -1,   450,    -1,    -1,    -1,    -1,   435,    -1,   437,   438,
      -1,    -1,    -1,    -1,    -1,    -1,   445,   446,   447,    -1,
      -1,    -1,    -1,   472,   473,   474,    -1,    -1,   477,    -1,
      -1,    96,    97,    98,    99,   464,    -1,   466,    -1,    -1,
      -1,    -1,    -1,    -1,   473,    -1,    -1,   496,    96,    97,
      98,    99,   573,   118,   119,   120,   121,   122,   123,   124,
      -1,    -1,    -1,    -1,    -1,    -1,   515,   115,   116,   117,
     118,   119,   120,   121,   122,   123,   124,   526,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   534,    -1,    -1,   382,   383,
     384,   385,   386,   387,   388,   389,   390,   391,   392,   393,
     394,   395,   396,   397,   398,    96,    97,    98,    99,    39,
      -1,    -1,    -1,    -1,    -1,    -1,   565,    -1,   412,    -1,
      -1,    -1,    -1,   644,    -1,   419,   117,   118,   119,   120,
     121,   122,   123,   124,    -1,    -1,   565,    -1,    -1,    -1,
      -1,    -1,    -1,   572,   593,   574,    -1,    -1,    -1,     3,
      -1,   600,     6,    96,    97,    98,    99,    11,    12,    13,
      14,    15,    16,    17,    18,   686,    96,    97,    98,    99,
     100,   114,   115,   116,   117,   118,   119,   120,   121,   122,
     123,   124,   703,   113,   114,   115,   116,   117,   118,   119,
     120,   121,   122,   123,   124,   644,    96,    97,   492,   493,
     494,    -1,    -1,     6,    -1,    -1,    -1,   728,    11,    12,
      13,    14,    15,    16,    17,    18,    -1,    -1,   118,   119,
     120,   121,   122,   123,   124,    -1,   675,    -1,    -1,    -1,
      -1,    96,    97,    98,    99,   684,    -1,   666,   667,    -1,
      -1,    -1,    -1,   672,    -1,   674,    -1,   676,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
      -1,    -1,   711,    -1,    -1,    -1,    -1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   726,    -1,    -1,
     729,   730,    -1,    -1,    -1,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    -1,    -1,    -1,   756,    -1,    -1,
      -1,    46,    47,    48,    49,    50,    51,    -1,    -1,    -1,
      55,    -1,   771,    -1,    -1,    -1,    -1,    -1,   757,    -1,
      -1,    -1,   781,    68,    69,    70,    -1,    -1,    41,    -1,
      -1,    -1,    -1,    -1,   793,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   802,    -1,   649,   650,    -1,   652,    -1,
      -1,    -1,   656,    -1,    -1,    -1,    -1,    -1,   103,    -1,
      -1,   106,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   117,    -1,    -1,    -1,    -1,    -1,    -1,   124,
      -1,    -1,    -1,    96,    97,    98,    99,   100,   847,    -1,
      -1,    -1,    -1,    -1,    -1,    96,    97,    98,    99,   858,
     113,   114,   115,   116,   117,   118,   119,   120,   121,   122,
     123,   124,   871,    -1,   873,   116,   117,   118,   119,   120,
     121,   122,   123,   124,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   890,     1,    -1,     3,     4,   740,    -1,     7,     8,
       9,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    -1,
     774,    -1,    41,    42,    -1,    -1,    45,    -1,    47,    48,
      49,    50,    51,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     794,    60,    61,    62,    63,    64,    65,    66,    67,    68,
      69,    70,    71,    72,    73,    -1,    75,    76,    77,    -1,
      79,    80,    81,    -1,    -1,    -1,    85,    -1,    87,    88,
      89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   101,    -1,   103,    -1,    -1,   106,   107,   108,
      -1,     3,    -1,    -1,     6,    -1,    -1,    -1,    10,    11,
      12,    13,    14,    15,    16,    17,    18,   126,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    46,    47,    48,    49,    50,    51,
      -1,    53,    96,    97,    98,    99,   100,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     3,    -1,    68,    69,    70,   113,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    -1,
      -1,   103,    -1,    -1,   106,   107,    -1,    -1,    -1,    -1,
      -1,    50,    51,    -1,    -1,   117,    -1,    -1,   120,   121,
      -1,    -1,   124,   125,   126,     3,    -1,    -1,     6,    68,
      69,    70,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    -1,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    -1,    -1,    -1,   103,    -1,    -1,    -1,   107,    47,
      48,    49,    50,    51,    -1,    53,    -1,    -1,    56,    -1,
      -1,    -1,    -1,    -1,    -1,   124,     1,    -1,     3,    -1,
      68,    69,    70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    -1,   103,    -1,    -1,    -1,   107,
      -1,    46,    47,    48,    49,    50,    51,    -1,    -1,   117,
      -1,    -1,   120,   121,    -1,    -1,   124,   125,   126,     3,
      -1,    -1,     6,    68,    69,    70,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    -1,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    -1,    -1,    -1,   103,    -1,
      -1,   106,   107,    47,    48,    49,    50,    51,    -1,    53,
      -1,    -1,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       1,    -1,     3,    -1,    68,    69,    70,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    -1,    -1,   103,
      -1,    -1,    -1,   107,    -1,    46,    47,    48,    49,    50,
      51,    -1,    -1,   117,    -1,    -1,   120,   121,    -1,    -1,
     124,   125,   126,     3,    -1,    -1,     6,    68,    69,    70,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    -1,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    -1,
      -1,    -1,   103,    -1,    -1,   106,   107,    47,    48,    49,
      50,    51,    -1,    53,    -1,    -1,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     1,    -1,     3,    -1,    68,    69,
      70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,   103,    -1,    -1,    -1,   107,    -1,    -1,
      47,    48,    49,    50,    51,    -1,    -1,   117,    -1,    -1,
     120,   121,    -1,    -1,   124,   125,   126,     3,    -1,    -1,
       6,    68,    69,    70,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    -1,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    -1,    -1,    -1,   103,    -1,    -1,    -1,
     107,    47,    48,    49,    50,    51,    -1,    53,    -1,    -1,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,
      -1,     6,    68,    69,    70,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    -1,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,   103,    -1,    -1,
      -1,   107,    47,    48,    49,    50,    51,    -1,    53,    -1,
      -1,   117,    -1,    -1,   120,   121,    -1,    -1,   124,   125,
     126,     3,    -1,    68,    69,    70,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    -1,   103,    -1,
      -1,    -1,   107,    -1,    46,    47,    48,    49,    50,    51,
      -1,    -1,   117,    55,    -1,   120,   121,    -1,    -1,   124,
     125,   126,     3,    -1,    -1,     6,    68,    69,    70,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    -1,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    -1,    -1,
      -1,   103,    -1,    -1,   106,   107,    47,    48,    49,    50,
      51,    -1,    53,    -1,    -1,   117,    -1,    -1,    -1,    -1,
      -1,    -1,   124,     3,    -1,    -1,     6,    68,    69,    70,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    -1,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    -1,
      -1,    -1,   103,    -1,    -1,    -1,   107,    47,    48,    49,
      50,    51,    -1,    53,    -1,    -1,   117,    -1,    -1,   120,
     121,    -1,    -1,   124,   125,   126,     3,    -1,    68,    69,
      70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,   103,    -1,    -1,    -1,   107,    -1,    46,
      47,    48,    49,    50,    51,    74,    -1,    -1,    -1,    -1,
     120,   121,    -1,    -1,   124,   125,   126,    -1,    -1,    -1,
      -1,    68,    69,    70,    -1,    -1,    -1,    96,    97,    98,
      99,   100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,   114,   115,   116,   117,   118,
     119,   120,   121,   122,   123,   124,   103,    -1,    -1,   106,
     107,    -1,    -1,    -1,     0,     1,    -1,     3,     4,    -1,
     117,     7,     8,     9,    -1,    -1,    -1,   124,    -1,    -1,
      -1,    -1,    -1,    19,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    -1,    -1,    -1,    41,    42,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,    -1,    -1,    54,    -1,
      -1,    -1,    -1,    -1,    60,    61,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    -1,    -1,    -1,    -1,    75,
      76,    77,    -1,    79,    80,    81,    82,    83,    84,    85,
      86,    87,    88,    89,    90,    91,    92,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   101,     1,   103,     3,     4,
     106,   107,     7,     8,     9,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    -1,    -1,    41,    42,    -1,    -1,
      45,    -1,    47,    48,    49,    50,    51,    -1,    -1,    54,
      -1,    -1,    -1,    -1,    -1,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    -1,    -1,    -1,    -1,
      75,    76,    77,    -1,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   101,     1,   103,     3,
       4,   106,   107,     7,     8,     9,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    19,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    -1,    -1,    -1,    41,    42,    -1,
      -1,    45,    -1,    47,    48,    49,    50,    51,    -1,    -1,
      54,    -1,    -1,    -1,    -1,    -1,    60,    61,    62,    63,
      64,    65,    66,    67,    68,    69,    70,    -1,    -1,    -1,
      -1,    75,    76,    77,    -1,    79,    80,    81,    82,    83,
      84,    85,    86,    87,    88,    89,    90,    91,    92,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,     1,   103,
       3,     4,   106,   107,     7,     8,     9,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    19,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    -1,    -1,    -1,    41,    42,
      -1,    -1,    45,    -1,    47,    48,    49,    50,    51,    -1,
      -1,    54,    -1,    -1,    -1,    -1,    -1,    60,    61,    62,
      63,    64,    65,    66,    67,    68,    69,    70,    -1,    -1,
      -1,    -1,    75,    76,    77,    -1,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,     1,
     103,     3,     4,   106,   107,     7,     8,     9,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    19,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    -1,    -1,    -1,    41,
      42,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      -1,    -1,    54,    -1,    -1,    -1,    58,    -1,    60,    61,
      62,    63,    64,    65,    66,    67,    68,    69,    70,    -1,
      -1,    -1,    -1,    75,    76,    77,    -1,    79,    80,    81,
      82,    83,    84,    85,    86,    87,    88,    89,    90,    91,
      92,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   101,
      -1,   103,    -1,    -1,   106,   107,    -1,    -1,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
      -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,
      51,   103,    -1,     3,    -1,   107,   108,    -1,    -1,    -1,
      -1,    11,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    46,    47,    48,    49,
      50,    51,   103,    -1,     3,    -1,   107,   108,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,
      70,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    46,    47,    48,
      49,    50,    51,   103,    -1,     3,   106,   107,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,
      69,    70,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,
      48,    49,    50,    51,   103,    -1,     3,   106,   107,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      68,    69,    70,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      47,    48,    49,    50,    51,   103,    -1,     3,    -1,   107,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    68,    69,    70,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,   103,    -1,     3,    -1,
     107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    68,    69,    70,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    47,    48,    49,    50,    51,   103,    -1,     3,
      -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    68,    69,    70,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    50,    51,   103,    56,
      -1,    -1,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    68,    69,    70,    -1,    20,    21,
      22,    23,    24,    25,    26,    27,    -1,    29,    56,    31,
      -1,    -1,    34,    35,    36,    37,    -1,    -1,    -1,    96,
      97,    98,    99,   100,    -1,    -1,    -1,    -1,    -1,   103,
      -1,    -1,    -1,   107,    -1,    -1,   113,   114,   115,   116,
     117,   118,   119,   120,   121,   122,   123,   124,    96,    97,
      98,    99,   100,    56,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   113,   114,   115,   116,   117,
     118,   119,   120,   121,   122,   123,   124,    -1,    -1,    -1,
      -1,    -1,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    96,    97,    98,    99,   100,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     113,   114,   115,   116,   117,   118,   119,   120,   121,   122,
     123,   124,    96,    97,    98,    99,   100,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    96,    97,    98,
      99,   100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,   114,   115,   116,   117,   118,
     119,   120,   121,   122,   123,   124
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint16 yystos[] =
{
       0,   109,   110,   111,   130,   131,   277,     1,     3,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    46,    47,    48,
      49,    50,    51,    68,    69,    70,   103,   106,   107,   215,
     229,   230,   232,   233,   234,   235,   236,   256,   257,   267,
     269,     1,   215,     1,    38,     0,     1,     4,     7,     8,
       9,    19,    41,    42,    54,    60,    61,    62,    63,    64,
      65,    66,    67,    75,    76,    77,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
     101,   106,   132,   133,   134,   136,   137,   138,   139,   140,
     143,   144,   146,   147,   148,   149,   150,   151,   152,   155,
     156,   157,   160,   162,   167,   168,   169,   170,   172,   175,
     176,   177,   178,   179,   183,   184,   191,   192,   202,   211,
     277,    93,   264,   277,   264,    46,   267,   128,    93,    41,
     233,   229,    38,    52,    55,    74,   117,   124,   126,   220,
     221,   223,   225,   226,   227,   228,   267,   277,   229,   235,
     267,   105,   128,   268,    41,    41,   212,   213,   215,   277,
     108,    38,     6,   272,    38,   274,   277,     1,     3,   231,
     232,    38,   274,    38,   154,   277,    38,    38,    38,    82,
     267,     3,    44,   267,    38,     4,    44,    38,    38,    41,
      44,     4,   272,    38,   166,   231,   164,   166,    38,    38,
     272,    38,    93,   257,   274,    38,   117,   223,   228,   267,
      68,   231,   257,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    38,    53,   117,   120,   121,   124,   125,   126,
     215,   216,   217,   219,   231,   232,   244,   245,   246,   247,
     272,   277,    46,   107,   269,   257,   229,    38,   117,   212,
     226,   228,   267,    44,   237,   238,    56,   244,   245,   244,
      38,   126,   224,   227,   267,   228,   229,   267,   220,    38,
      55,   220,    38,    55,   117,   224,   227,   267,   104,   269,
     107,   269,    39,    40,   214,   277,     3,   265,   272,     6,
      44,   265,   275,   265,    41,    52,    38,   223,    39,   265,
     267,     3,     3,   265,    11,   161,   212,   212,   267,    41,
      52,   194,    44,     3,   163,   275,     3,   212,    44,   222,
     223,   226,   277,    41,    40,   165,   277,   265,   266,   277,
     141,   142,   272,   212,   187,   188,   189,   215,   256,   277,
     267,   272,     3,   117,   228,   267,   275,    38,   265,   117,
     267,   104,     3,   239,   277,    38,   223,    44,   267,   244,
      38,   244,   244,   244,   244,   244,   244,    94,    40,   218,
     277,    38,    96,    97,    98,    99,   100,   113,   114,   115,
     116,   117,   118,   119,   120,   121,   122,   123,   124,   268,
      94,   117,   228,   267,   225,   267,    39,    39,   117,   225,
     267,   104,    55,   244,    56,   228,   267,   267,    38,    55,
     228,   212,    56,   244,   212,    56,   244,   224,   227,   104,
     117,   224,   268,    41,   215,    39,   171,    40,    52,    39,
     237,   220,    39,    44,    39,    52,    39,    40,   159,    40,
      39,    39,    41,   267,   131,   193,    39,    39,    39,    39,
     164,   166,    39,    39,    40,    44,    39,    94,    40,   190,
     277,    57,   104,    39,   228,   267,    41,   104,    41,    44,
     212,   267,    78,   174,   220,   229,   181,    41,    74,   248,
     249,   277,    39,   117,   124,   228,   231,   219,   244,   244,
     244,   244,   244,   244,   244,   244,   244,   244,   244,   244,
     244,   244,   244,   244,   244,   257,   267,   104,    39,    39,
     104,   225,   244,   224,   267,    39,   104,   212,    56,   244,
      39,    56,    39,    56,   117,   224,   227,   224,   214,     4,
      44,   272,   131,   275,   141,   246,   272,   276,    41,    41,
     135,     4,   153,   272,     4,    41,    44,   102,   158,   223,
     272,   273,   265,   272,   276,    39,   215,   223,    44,    41,
      45,   131,    42,   211,   164,    41,    44,    38,    45,   165,
       3,   103,   107,   270,    41,   275,   215,   158,   185,   189,
     145,   223,   272,   104,   138,   240,   241,   277,    39,    38,
      40,    41,    44,   173,    78,   220,     1,    41,    64,    71,
      72,    73,    76,   126,   136,   137,   138,   139,   143,   144,
     148,   150,   152,   155,   157,   160,   162,   167,   168,   169,
     170,   183,   184,   191,   195,   198,   199,   200,   201,   202,
     203,   204,   207,   210,   211,   277,   250,    44,   244,    39,
     124,   229,    39,   117,   221,   218,    74,   267,    39,    56,
      39,   224,    39,    56,   224,    45,    40,    40,   195,    38,
      78,   229,   259,   277,    52,    39,    40,   159,   158,   223,
     259,    45,   272,     3,   231,    41,    52,   273,   212,   105,
     128,   271,   128,    93,    39,    45,   172,   179,   183,   184,
     186,   199,   201,   211,   190,   131,   259,    41,     3,   242,
      40,    45,    38,    52,   259,   260,   212,   223,    38,   197,
      44,    74,    74,    74,   126,   269,    45,   195,   108,   231,
     257,   267,    76,   251,   252,   258,   277,   180,   244,   244,
      39,    39,   244,   220,    39,   275,   275,    45,   212,    38,
      78,   158,   272,   276,    41,   223,    39,   259,    41,    41,
     223,   166,    39,     3,     3,   107,     3,   107,   216,     4,
      44,   231,    58,    41,    52,   240,   240,    41,   223,   212,
     237,    74,   261,   277,    39,   174,   212,   195,   196,   269,
      38,   223,   231,    38,    74,   248,   267,    41,    40,    71,
      72,    73,   253,   255,   195,   244,    39,   212,    38,   159,
     259,    41,   223,   158,    41,    41,   271,   271,    94,   243,
     244,   242,   174,    39,    41,   262,   263,   267,    41,    44,
     220,   173,    39,   195,    38,   212,   174,    38,   117,   228,
     212,   244,    44,   248,   252,   267,   254,    45,    41,    39,
     212,    41,   259,    41,   240,   173,    41,    44,    40,    38,
     220,    45,   212,    39,   173,   212,    38,    38,   117,    39,
      41,   206,    44,   258,    41,   182,   223,    39,    41,   263,
     195,    39,   208,   259,    39,   212,   212,    38,   260,   182,
     205,   267,   174,   209,   259,    41,    44,   209,    39,    39,
     212,   182,   173,    41,    44,    52,   209,   209,    39,   237,
     209,    41
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *yybottom, yytype_int16 *yytop)
#else
static void
yy_stack_print (yybottom, yytop)
    yytype_int16 *yybottom;
    yytype_int16 *yytop;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}

/* Prevent warnings from -Wmissing-prototypes.  */
#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */


/* The lookahead symbol.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*-------------------------.
| yyparse or yypush_parse.  |
`-------------------------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{


    int yystate;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus;

    /* The stacks and their tools:
       `yyss': related to states.
       `yyvs': related to semantic values.

       Refer to the stacks thru separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* The state stack.  */
    yytype_int16 yyssa[YYINITDEPTH];
    yytype_int16 *yyss;
    yytype_int16 *yyssp;

    /* The semantic value stack.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs;
    YYSTYPE *yyvsp;

    YYSIZE_T yystacksize;

  int yyn;
  int yyresult;
  /* Lookahead token as an internal (translated) token number.  */
  int yytoken;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;

#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  yytoken = 0;
  yyss = yyssa;
  yyvs = yyvsa;
  yystacksize = YYINITDEPTH;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY; /* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */
  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;

	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),
		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss_alloc, yyss);
	YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  if (yystate == YYFINAL)
    YYACCEPT;

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     lookahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to lookahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid lookahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the lookahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token.  */
  yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 2:

/* Line 1455 of yacc.c  */
#line 1802 "parser.y"
    {
                   if (!classes) classes = NewHash();
		   Setattr((yyvsp[(1) - (1)].node),"classes",classes); 
		   Setattr((yyvsp[(1) - (1)].node),"name",ModuleName);
		   
		   if ((!module_node) && ModuleName) {
		     module_node = new_node("module");
		     Setattr(module_node,"name",ModuleName);
		   }
		   Setattr((yyvsp[(1) - (1)].node),"module",module_node);
		   check_extensions();
	           top = (yyvsp[(1) - (1)].node);
               ;}
    break;

  case 3:

/* Line 1455 of yacc.c  */
#line 1815 "parser.y"
    {
                 top = Copy(Getattr((yyvsp[(2) - (3)].p),"type"));
		 Delete((yyvsp[(2) - (3)].p));
               ;}
    break;

  case 4:

/* Line 1455 of yacc.c  */
#line 1819 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 5:

/* Line 1455 of yacc.c  */
#line 1822 "parser.y"
    {
                 top = (yyvsp[(2) - (3)].p);
               ;}
    break;

  case 6:

/* Line 1455 of yacc.c  */
#line 1825 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 7:

/* Line 1455 of yacc.c  */
#line 1828 "parser.y"
    {
                 top = (yyvsp[(3) - (5)].pl);
               ;}
    break;

  case 8:

/* Line 1455 of yacc.c  */
#line 1831 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 9:

/* Line 1455 of yacc.c  */
#line 1836 "parser.y"
    {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   appendChild((yyvsp[(1) - (2)].node),(yyvsp[(2) - (2)].node));
                   (yyval.node) = (yyvsp[(1) - (2)].node);
               ;}
    break;

  case 10:

/* Line 1455 of yacc.c  */
#line 1841 "parser.y"
    {
                   (yyval.node) = new_node("top");
               ;}
    break;

  case 11:

/* Line 1455 of yacc.c  */
#line 1846 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 12:

/* Line 1455 of yacc.c  */
#line 1847 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 13:

/* Line 1455 of yacc.c  */
#line 1848 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 14:

/* Line 1455 of yacc.c  */
#line 1849 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 15:

/* Line 1455 of yacc.c  */
#line 1850 "parser.y"
    {
                  (yyval.node) = 0;
		  Swig_error(cparse_file, cparse_line,"Syntax error in input(1).\n");
		  exit(1);
               ;}
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 1856 "parser.y"
    { 
                  if ((yyval.node)) {
   		      add_symbols((yyval.node));
                  }
                  (yyval.node) = (yyvsp[(1) - (1)].node); 
	       ;}
    break;

  case 17:

/* Line 1455 of yacc.c  */
#line 1872 "parser.y"
    {
                  (yyval.node) = 0;
                  skip_decl();
               ;}
    break;

  case 18:

/* Line 1455 of yacc.c  */
#line 1882 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 19:

/* Line 1455 of yacc.c  */
#line 1883 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 20:

/* Line 1455 of yacc.c  */
#line 1884 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 21:

/* Line 1455 of yacc.c  */
#line 1885 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 22:

/* Line 1455 of yacc.c  */
#line 1886 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 1887 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 24:

/* Line 1455 of yacc.c  */
#line 1888 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 1889 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 26:

/* Line 1455 of yacc.c  */
#line 1890 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 27:

/* Line 1455 of yacc.c  */
#line 1891 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 28:

/* Line 1455 of yacc.c  */
#line 1892 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 29:

/* Line 1455 of yacc.c  */
#line 1893 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 30:

/* Line 1455 of yacc.c  */
#line 1894 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 31:

/* Line 1455 of yacc.c  */
#line 1895 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 1896 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 1897 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 34:

/* Line 1455 of yacc.c  */
#line 1898 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 35:

/* Line 1455 of yacc.c  */
#line 1899 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 36:

/* Line 1455 of yacc.c  */
#line 1900 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 37:

/* Line 1455 of yacc.c  */
#line 1901 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 1902 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 39:

/* Line 1455 of yacc.c  */
#line 1909 "parser.y"
    {
               Node *cls;
	       String *clsname;
	       cplus_mode = CPLUS_PUBLIC;
	       if (!classes) classes = NewHash();
	       if (!classes_typedefs) classes_typedefs = NewHash();
	       if (!extendhash) extendhash = NewHash();
	       clsname = make_class_name((yyvsp[(3) - (4)].str));
	       cls = Getattr(classes,clsname);
	       if (!cls) {
	         cls = Getattr(classes_typedefs, clsname);
		 if (!cls) {
		   /* No previous definition. Create a new scope */
		   Node *am = Getattr(extendhash,clsname);
		   if (!am) {
		     Swig_symbol_newscope();
		     Swig_symbol_setscopename((yyvsp[(3) - (4)].str));
		     prev_symtab = 0;
		   } else {
		     prev_symtab = Swig_symbol_setscope(Getattr(am,"symtab"));
		   }
		   current_class = 0;
		 } else {
		   /* Previous typedef class definition.  Use its symbol table.
		      Deprecated, just the real name should be used. 
		      Note that %extend before the class typedef never worked, only %extend after the class typdef. */
		   prev_symtab = Swig_symbol_setscope(Getattr(cls, "symtab"));
		   current_class = cls;
		   extendmode = 1;
		   SWIG_WARN_NODE_BEGIN(cls);
		   Swig_warning(WARN_PARSE_EXTEND_NAME, cparse_file, cparse_line, "Deprecated %%extend name used - the %s name '%s' should be used instead of the typedef name '%s'.\n", Getattr(cls, "kind"), SwigType_namestr(Getattr(cls, "name")), (yyvsp[(3) - (4)].str));
		   SWIG_WARN_NODE_END(cls);
		 }
	       } else {
		 /* Previous class definition.  Use its symbol table */
		 prev_symtab = Swig_symbol_setscope(Getattr(cls,"symtab"));
		 current_class = cls;
		 extendmode = 1;
	       }
	       Classprefix = NewString((yyvsp[(3) - (4)].str));
	       Namespaceprefix= Swig_symbol_qualifiedscopename(0);
	       Delete(clsname);
	     ;}
    break;

  case 40:

/* Line 1455 of yacc.c  */
#line 1951 "parser.y"
    {
               String *clsname;
	       extendmode = 0;
               (yyval.node) = new_node("extend");
	       Setattr((yyval.node),"symtab",Swig_symbol_popscope());
	       if (prev_symtab) {
		 Swig_symbol_setscope(prev_symtab);
	       }
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
               clsname = make_class_name((yyvsp[(3) - (7)].str));
	       Setattr((yyval.node),"name",clsname);

	       /* Mark members as extend */

	       tag_nodes((yyvsp[(6) - (7)].node),"feature:extend",(char*) "1");
	       if (current_class) {
		 /* We add the extension to the previously defined class */
		 appendChild((yyval.node),(yyvsp[(6) - (7)].node));
		 appendChild(current_class,(yyval.node));
	       } else {
		 /* We store the extensions in the extensions hash */
		 Node *am = Getattr(extendhash,clsname);
		 if (am) {
		   /* Append the members to the previous extend methods */
		   appendChild(am,(yyvsp[(6) - (7)].node));
		 } else {
		   appendChild((yyval.node),(yyvsp[(6) - (7)].node));
		   Setattr(extendhash,clsname,(yyval.node));
		 }
	       }
	       current_class = 0;
	       Delete(Classprefix);
	       Delete(clsname);
	       Classprefix = 0;
	       prev_symtab = 0;
	       (yyval.node) = 0;

	     ;}
    break;

  case 41:

/* Line 1455 of yacc.c  */
#line 1995 "parser.y"
    {
                    (yyval.node) = new_node("apply");
                    Setattr((yyval.node),"pattern",Getattr((yyvsp[(2) - (5)].p),"pattern"));
		    appendChild((yyval.node),(yyvsp[(4) - (5)].p));
               ;}
    break;

  case 42:

/* Line 1455 of yacc.c  */
#line 2005 "parser.y"
    {
		 (yyval.node) = new_node("clear");
		 appendChild((yyval.node),(yyvsp[(2) - (3)].p));
               ;}
    break;

  case 43:

/* Line 1455 of yacc.c  */
#line 2016 "parser.y"
    {
		   if (((yyvsp[(4) - (5)].dtype).type != T_ERROR) && ((yyvsp[(4) - (5)].dtype).type != T_SYMBOL)) {
		     SwigType *type = NewSwigType((yyvsp[(4) - (5)].dtype).type);
		     (yyval.node) = new_node("constant");
		     Setattr((yyval.node),"name",(yyvsp[(2) - (5)].id));
		     Setattr((yyval.node),"type",type);
		     Setattr((yyval.node),"value",(yyvsp[(4) - (5)].dtype).val);
		     if ((yyvsp[(4) - (5)].dtype).rawval) Setattr((yyval.node),"rawval", (yyvsp[(4) - (5)].dtype).rawval);
		     Setattr((yyval.node),"storage","%constant");
		     SetFlag((yyval.node),"feature:immutable");
		     add_symbols((yyval.node));
		     Delete(type);
		   } else {
		     if ((yyvsp[(4) - (5)].dtype).type == T_ERROR) {
		       Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE,cparse_file,cparse_line,"Unsupported constant value (ignored)\n");
		     }
		     (yyval.node) = 0;
		   }

	       ;}
    break;

  case 44:

/* Line 1455 of yacc.c  */
#line 2037 "parser.y"
    {
		 if (((yyvsp[(4) - (5)].dtype).type != T_ERROR) && ((yyvsp[(4) - (5)].dtype).type != T_SYMBOL)) {
		   SwigType_push((yyvsp[(2) - (5)].type),(yyvsp[(3) - (5)].decl).type);
		   /* Sneaky callback function trick */
		   if (SwigType_isfunction((yyvsp[(2) - (5)].type))) {
		     SwigType_add_pointer((yyvsp[(2) - (5)].type));
		   }
		   (yyval.node) = new_node("constant");
		   Setattr((yyval.node),"name",(yyvsp[(3) - (5)].decl).id);
		   Setattr((yyval.node),"type",(yyvsp[(2) - (5)].type));
		   Setattr((yyval.node),"value",(yyvsp[(4) - (5)].dtype).val);
		   if ((yyvsp[(4) - (5)].dtype).rawval) Setattr((yyval.node),"rawval", (yyvsp[(4) - (5)].dtype).rawval);
		   Setattr((yyval.node),"storage","%constant");
		   SetFlag((yyval.node),"feature:immutable");
		   add_symbols((yyval.node));
		 } else {
		     if ((yyvsp[(4) - (5)].dtype).type == T_ERROR) {
		       Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE,cparse_file,cparse_line,"Unsupported constant value\n");
		     }
		   (yyval.node) = 0;
		 }
               ;}
    break;

  case 45:

/* Line 1455 of yacc.c  */
#line 2059 "parser.y"
    {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 (yyval.node) = 0;
	       ;}
    break;

  case 46:

/* Line 1455 of yacc.c  */
#line 2070 "parser.y"
    {
		 char temp[64];
		 Replace((yyvsp[(2) - (2)].str),"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace((yyvsp[(2) - (2)].str),"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", (yyvsp[(2) - (2)].str));
		 Delete((yyvsp[(2) - (2)].str));
                 (yyval.node) = 0;
	       ;}
    break;

  case 47:

/* Line 1455 of yacc.c  */
#line 2079 "parser.y"
    {
		 char temp[64];
		 String *s = NewString((yyvsp[(2) - (2)].id));
		 Replace(s,"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace(s,"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", s);
		 Delete(s);
                 (yyval.node) = 0;
               ;}
    break;

  case 48:

/* Line 1455 of yacc.c  */
#line 2098 "parser.y"
    {
                    skip_balanced('{','}');
		    (yyval.node) = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       ;}
    break;

  case 49:

/* Line 1455 of yacc.c  */
#line 2104 "parser.y"
    {
                    skip_balanced('{','}');
		    (yyval.node) = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               ;}
    break;

  case 50:

/* Line 1455 of yacc.c  */
#line 2110 "parser.y"
    {
		 (yyval.node) = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               ;}
    break;

  case 51:

/* Line 1455 of yacc.c  */
#line 2115 "parser.y"
    {
		 (yyval.node) = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       ;}
    break;

  case 52:

/* Line 1455 of yacc.c  */
#line 2122 "parser.y"
    {		 
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[(1) - (4)].id));
		 Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (4)].p),"type"));
               ;}
    break;

  case 53:

/* Line 1455 of yacc.c  */
#line 2129 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[(1) - (1)].id));
              ;}
    break;

  case 54:

/* Line 1455 of yacc.c  */
#line 2133 "parser.y"
    {
                (yyval.node) = (yyvsp[(1) - (1)].node);
              ;}
    break;

  case 55:

/* Line 1455 of yacc.c  */
#line 2146 "parser.y"
    {
                   Hash *p = (yyvsp[(5) - (7)].node);
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[(3) - (7)].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (7)].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Setattr((yyval.node),"code",(yyvsp[(7) - (7)].str));
                 ;}
    break;

  case 56:

/* Line 1455 of yacc.c  */
#line 2155 "parser.y"
    {
		   Hash *p = (yyvsp[(5) - (7)].node);
		   String *code;
                   skip_balanced('{','}');
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[(3) - (7)].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (7)].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code",code);
		   Delete(code);
                 ;}
    break;

  case 57:

/* Line 1455 of yacc.c  */
#line 2170 "parser.y"
    {
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[(3) - (5)].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (5)].node),"type"));
		   Setattr((yyval.node),"emitonly","1");
		 ;}
    break;

  case 58:

/* Line 1455 of yacc.c  */
#line 2183 "parser.y"
    {
                     (yyvsp[(1) - (4)].loc).filename = Copy(cparse_file);
		     (yyvsp[(1) - (4)].loc).line = cparse_line;
		     scanner_set_location(NewString((yyvsp[(3) - (4)].id)),1);
                     if ((yyvsp[(2) - (4)].node)) { 
		       String *maininput = Getattr((yyvsp[(2) - (4)].node), "maininput");
		       if (maininput)
		         scanner_set_main_input_file(NewString(maininput));
		     }
               ;}
    break;

  case 59:

/* Line 1455 of yacc.c  */
#line 2192 "parser.y"
    {
                     String *mname = 0;
                     (yyval.node) = (yyvsp[(6) - (7)].node);
		     scanner_set_location((yyvsp[(1) - (7)].loc).filename,(yyvsp[(1) - (7)].loc).line+1);
		     if (strcmp((yyvsp[(1) - (7)].loc).type,"include") == 0) set_nodeType((yyval.node),"include");
		     if (strcmp((yyvsp[(1) - (7)].loc).type,"import") == 0) {
		       mname = (yyvsp[(2) - (7)].node) ? Getattr((yyvsp[(2) - (7)].node),"module") : 0;
		       set_nodeType((yyval.node),"import");
		       if (import_mode) --import_mode;
		     }
		     
		     Setattr((yyval.node),"name",(yyvsp[(3) - (7)].id));
		     /* Search for the module (if any) */
		     {
			 Node *n = firstChild((yyval.node));
			 while (n) {
			     if (Strcmp(nodeType(n),"module") == 0) {
			         if (mname) {
				   Setattr(n,"name", mname);
				   mname = 0;
				 }
				 Setattr((yyval.node),"module",Getattr(n,"name"));
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
			   appendChild(nint,firstChild((yyval.node)));
			   (yyval.node) = nint;
			   Setattr((yyval.node),"module",mname);
			 }
		     }
		     Setattr((yyval.node),"options",(yyvsp[(2) - (7)].node));
               ;}
    break;

  case 60:

/* Line 1455 of yacc.c  */
#line 2238 "parser.y"
    { (yyval.loc).type = (char *) "include"; ;}
    break;

  case 61:

/* Line 1455 of yacc.c  */
#line 2239 "parser.y"
    { (yyval.loc).type = (char *) "import"; ++import_mode;;}
    break;

  case 62:

/* Line 1455 of yacc.c  */
#line 2246 "parser.y"
    {
                 String *cpps;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		   (yyval.node) = 0;
		 } else {
		   (yyval.node) = new_node("insert");
		   Setattr((yyval.node),"code",(yyvsp[(2) - (2)].str));
		   /* Need to run through the preprocessor */
		   Seek((yyvsp[(2) - (2)].str),0,SEEK_SET);
		   Setline((yyvsp[(2) - (2)].str),cparse_start_line);
		   Setfile((yyvsp[(2) - (2)].str),cparse_file);
		   cpps = Preprocessor_parse((yyvsp[(2) - (2)].str));
		   start_inline(Char(cpps), cparse_start_line);
		   Delete((yyvsp[(2) - (2)].str));
		   Delete(cpps);
		 }
		 
	       ;}
    break;

  case 63:

/* Line 1455 of yacc.c  */
#line 2265 "parser.y"
    {
                 String *cpps;
		 int start_line = cparse_line;
		 skip_balanced('{','}');
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		   
		   (yyval.node) = 0;
		 } else {
		   String *code;
                   (yyval.node) = new_node("insert");
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code", code);
		   Delete(code);		   
		   cpps=Copy(scanner_ccode);
		   start_inline(Char(cpps), start_line);
		   Delete(cpps);
		 }
               ;}
    break;

  case 64:

/* Line 1455 of yacc.c  */
#line 2296 "parser.y"
    {
                 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"code",(yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 65:

/* Line 1455 of yacc.c  */
#line 2300 "parser.y"
    {
		 String *code = NewStringEmpty();
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[(3) - (5)].id));
		 Setattr((yyval.node),"code",code);
		 if (Swig_insert_file((yyvsp[(5) - (5)].id),code) < 0) {
		   Swig_error(cparse_file, cparse_line, "Couldn't find '%s'.\n", (yyvsp[(5) - (5)].id));
		   (yyval.node) = 0;
		 } 
               ;}
    break;

  case 66:

/* Line 1455 of yacc.c  */
#line 2310 "parser.y"
    {
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[(3) - (5)].id));
		 Setattr((yyval.node),"code",(yyvsp[(5) - (5)].str));
               ;}
    break;

  case 67:

/* Line 1455 of yacc.c  */
#line 2315 "parser.y"
    {
		 String *code;
                 skip_balanced('{','}');
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[(3) - (5)].id));
		 Delitem(scanner_ccode,0);
		 Delitem(scanner_ccode,DOH_END);
		 code = Copy(scanner_ccode);
		 Setattr((yyval.node),"code", code);
		 Delete(code);
	       ;}
    break;

  case 68:

/* Line 1455 of yacc.c  */
#line 2333 "parser.y"
    {
                 (yyval.node) = new_node("module");
		 if ((yyvsp[(2) - (3)].node)) {
		   Setattr((yyval.node),"options",(yyvsp[(2) - (3)].node));
		   if (Getattr((yyvsp[(2) - (3)].node),"directors")) {
		     Wrapper_director_mode_set(1);
		   } 
		   if (Getattr((yyvsp[(2) - (3)].node),"dirprot")) {
		     Wrapper_director_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[(2) - (3)].node),"allprotected")) {
		     Wrapper_all_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[(2) - (3)].node),"templatereduce")) {
		     template_reduce = 1;
		   }
		   if (Getattr((yyvsp[(2) - (3)].node),"notemplatereduce")) {
		     template_reduce = 0;
		   }
		 }
		 if (!ModuleName) ModuleName = NewString((yyvsp[(3) - (3)].id));
		 if (!import_mode) {
		   /* first module included, we apply global
		      ModuleName, which can be modify by -module */
		   String *mname = Copy(ModuleName);
		   Setattr((yyval.node),"name",mname);
		   Delete(mname);
		 } else { 
		   /* import mode, we just pass the idstring */
		   Setattr((yyval.node),"name",(yyvsp[(3) - (3)].id));   
		 }		 
		 if (!module_node) module_node = (yyval.node);
	       ;}
    break;

  case 69:

/* Line 1455 of yacc.c  */
#line 2373 "parser.y"
    {
                 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 Delete(yyrename);
                 yyrename = NewString((yyvsp[(3) - (4)].id));
		 (yyval.node) = 0;
               ;}
    break;

  case 70:

/* Line 1455 of yacc.c  */
#line 2379 "parser.y"
    {
		 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 (yyval.node) = 0;
		 Swig_error(cparse_file,cparse_line,"Missing argument to %%name directive.\n");
	       ;}
    break;

  case 71:

/* Line 1455 of yacc.c  */
#line 2392 "parser.y"
    {
                 (yyval.node) = new_node("native");
		 Setattr((yyval.node),"name",(yyvsp[(3) - (7)].id));
		 Setattr((yyval.node),"wrap:name",(yyvsp[(6) - (7)].id));
	         add_symbols((yyval.node));
	       ;}
    break;

  case 72:

/* Line 1455 of yacc.c  */
#line 2398 "parser.y"
    {
		 if (!SwigType_isfunction((yyvsp[(7) - (8)].decl).type)) {
		   Swig_error(cparse_file,cparse_line,"%%native declaration '%s' is not a function.\n", (yyvsp[(7) - (8)].decl).id);
		   (yyval.node) = 0;
		 } else {
		     Delete(SwigType_pop_function((yyvsp[(7) - (8)].decl).type));
		     /* Need check for function here */
		     SwigType_push((yyvsp[(6) - (8)].type),(yyvsp[(7) - (8)].decl).type);
		     (yyval.node) = new_node("native");
	             Setattr((yyval.node),"name",(yyvsp[(3) - (8)].id));
		     Setattr((yyval.node),"wrap:name",(yyvsp[(7) - (8)].decl).id);
		     Setattr((yyval.node),"type",(yyvsp[(6) - (8)].type));
		     Setattr((yyval.node),"parms",(yyvsp[(7) - (8)].decl).parms);
		     Setattr((yyval.node),"decl",(yyvsp[(7) - (8)].decl).type);
		 }
	         add_symbols((yyval.node));
	       ;}
    break;

  case 73:

/* Line 1455 of yacc.c  */
#line 2424 "parser.y"
    {
                 (yyval.node) = new_node("pragma");
		 Setattr((yyval.node),"lang",(yyvsp[(2) - (5)].id));
		 Setattr((yyval.node),"name",(yyvsp[(3) - (5)].id));
		 Setattr((yyval.node),"value",(yyvsp[(5) - (5)].str));
	       ;}
    break;

  case 74:

/* Line 1455 of yacc.c  */
#line 2430 "parser.y"
    {
		(yyval.node) = new_node("pragma");
		Setattr((yyval.node),"lang",(yyvsp[(2) - (3)].id));
		Setattr((yyval.node),"name",(yyvsp[(3) - (3)].id));
	      ;}
    break;

  case 75:

/* Line 1455 of yacc.c  */
#line 2437 "parser.y"
    { (yyval.str) = NewString((yyvsp[(1) - (1)].id)); ;}
    break;

  case 76:

/* Line 1455 of yacc.c  */
#line 2438 "parser.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); ;}
    break;

  case 77:

/* Line 1455 of yacc.c  */
#line 2441 "parser.y"
    { (yyval.id) = (yyvsp[(2) - (3)].id); ;}
    break;

  case 78:

/* Line 1455 of yacc.c  */
#line 2442 "parser.y"
    { (yyval.id) = (char *) "swig"; ;}
    break;

  case 79:

/* Line 1455 of yacc.c  */
#line 2450 "parser.y"
    {
                SwigType *t = (yyvsp[(2) - (4)].decl).type;
		Hash *kws = NewHash();
		String *fixname;
		fixname = feature_identifier_fix((yyvsp[(2) - (4)].decl).id);
		Setattr(kws,"name",(yyvsp[(3) - (4)].id));
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[(1) - (4)].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[(2) - (4)].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[(1) - (4)].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[(2) - (4)].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[(1) - (4)].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[(2) - (4)].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[(1) - (4)].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[(2) - (4)].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              ;}
    break;

  case 80:

/* Line 1455 of yacc.c  */
#line 2496 "parser.y"
    {
		String *fixname;
		Hash *kws = (yyvsp[(3) - (7)].node);
		SwigType *t = (yyvsp[(5) - (7)].decl).type;
		fixname = feature_identifier_fix((yyvsp[(5) - (7)].decl).id);
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if ((yyvsp[(6) - (7)].dtype).qualifier) SwigType_push(t,(yyvsp[(6) - (7)].dtype).qualifier);
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[(1) - (7)].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[(5) - (7)].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[(1) - (7)].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[(5) - (7)].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[(1) - (7)].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[(5) - (7)].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[(1) - (7)].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[(5) - (7)].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              ;}
    break;

  case 81:

/* Line 1455 of yacc.c  */
#line 2542 "parser.y"
    {
		if ((yyvsp[(1) - (6)].intvalue)) {
		  Swig_name_rename_add(Namespaceprefix,(yyvsp[(5) - (6)].id),0,(yyvsp[(3) - (6)].node),0);
		} else {
		  Swig_name_namewarn_add(Namespaceprefix,(yyvsp[(5) - (6)].id),0,(yyvsp[(3) - (6)].node));
		}
		(yyval.node) = 0;
		scanner_clear_rename();
              ;}
    break;

  case 82:

/* Line 1455 of yacc.c  */
#line 2553 "parser.y"
    {
		    (yyval.intvalue) = 1;
                ;}
    break;

  case 83:

/* Line 1455 of yacc.c  */
#line 2556 "parser.y"
    {
                    (yyval.intvalue) = 0;
                ;}
    break;

  case 84:

/* Line 1455 of yacc.c  */
#line 2583 "parser.y"
    {
                    String *val = (yyvsp[(7) - (7)].str) ? NewString((yyvsp[(7) - (7)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (7)].id), val, 0, (yyvsp[(5) - (7)].decl).id, (yyvsp[(5) - (7)].decl).type, (yyvsp[(5) - (7)].decl).parms, (yyvsp[(6) - (7)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 85:

/* Line 1455 of yacc.c  */
#line 2589 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (9)].id)) ? NewString((yyvsp[(5) - (9)].id)) : 0;
                    new_feature((yyvsp[(3) - (9)].id), val, 0, (yyvsp[(7) - (9)].decl).id, (yyvsp[(7) - (9)].decl).type, (yyvsp[(7) - (9)].decl).parms, (yyvsp[(8) - (9)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 86:

/* Line 1455 of yacc.c  */
#line 2595 "parser.y"
    {
                    String *val = (yyvsp[(8) - (8)].str) ? NewString((yyvsp[(8) - (8)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (8)].id), val, (yyvsp[(4) - (8)].node), (yyvsp[(6) - (8)].decl).id, (yyvsp[(6) - (8)].decl).type, (yyvsp[(6) - (8)].decl).parms, (yyvsp[(7) - (8)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 87:

/* Line 1455 of yacc.c  */
#line 2601 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (10)].id)) ? NewString((yyvsp[(5) - (10)].id)) : 0;
                    new_feature((yyvsp[(3) - (10)].id), val, (yyvsp[(6) - (10)].node), (yyvsp[(8) - (10)].decl).id, (yyvsp[(8) - (10)].decl).type, (yyvsp[(8) - (10)].decl).parms, (yyvsp[(9) - (10)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 88:

/* Line 1455 of yacc.c  */
#line 2609 "parser.y"
    {
                    String *val = (yyvsp[(5) - (5)].str) ? NewString((yyvsp[(5) - (5)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (5)].id), val, 0, 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 89:

/* Line 1455 of yacc.c  */
#line 2615 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (7)].id)) ? NewString((yyvsp[(5) - (7)].id)) : 0;
                    new_feature((yyvsp[(3) - (7)].id), val, 0, 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 90:

/* Line 1455 of yacc.c  */
#line 2621 "parser.y"
    {
                    String *val = (yyvsp[(6) - (6)].str) ? NewString((yyvsp[(6) - (6)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (6)].id), val, (yyvsp[(4) - (6)].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 91:

/* Line 1455 of yacc.c  */
#line 2627 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (8)].id)) ? NewString((yyvsp[(5) - (8)].id)) : 0;
                    new_feature((yyvsp[(3) - (8)].id), val, (yyvsp[(6) - (8)].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 92:

/* Line 1455 of yacc.c  */
#line 2635 "parser.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); ;}
    break;

  case 93:

/* Line 1455 of yacc.c  */
#line 2636 "parser.y"
    { (yyval.str) = 0; ;}
    break;

  case 94:

/* Line 1455 of yacc.c  */
#line 2637 "parser.y"
    { (yyval.str) = (yyvsp[(3) - (5)].pl); ;}
    break;

  case 95:

/* Line 1455 of yacc.c  */
#line 2640 "parser.y"
    {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[(2) - (4)].id));
		  Setattr((yyval.node),"value",(yyvsp[(4) - (4)].id));
                ;}
    break;

  case 96:

/* Line 1455 of yacc.c  */
#line 2645 "parser.y"
    {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[(2) - (5)].id));
		  Setattr((yyval.node),"value",(yyvsp[(4) - (5)].id));
                  set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
                ;}
    break;

  case 97:

/* Line 1455 of yacc.c  */
#line 2655 "parser.y"
    {
                 Parm *val;
		 String *name;
		 SwigType *t;
		 if (Namespaceprefix) name = NewStringf("%s::%s", Namespaceprefix, (yyvsp[(5) - (7)].decl).id);
		 else name = NewString((yyvsp[(5) - (7)].decl).id);
		 val = (yyvsp[(3) - (7)].pl);
		 if ((yyvsp[(5) - (7)].decl).parms) {
		   Setmeta(val,"parms",(yyvsp[(5) - (7)].decl).parms);
		 }
		 t = (yyvsp[(5) - (7)].decl).type;
		 if (!Len(t)) t = 0;
		 if (t) {
		   if ((yyvsp[(6) - (7)].dtype).qualifier) SwigType_push(t,(yyvsp[(6) - (7)].dtype).qualifier);
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
		 (yyval.node) = 0;
              ;}
    break;

  case 98:

/* Line 1455 of yacc.c  */
#line 2691 "parser.y"
    { (yyval.pl) = (yyvsp[(1) - (1)].pl); ;}
    break;

  case 99:

/* Line 1455 of yacc.c  */
#line 2692 "parser.y"
    { 
		  int i;
		  int n;
		  Parm *p;
		  n = atoi(Char((yyvsp[(1) - (3)].dtype).val));
		  if (n <= 0) {
		    Swig_error(cparse_file, cparse_line,"Argument count in %%varargs must be positive.\n");
		    (yyval.pl) = 0;
		  } else {
		    String *name = Getattr((yyvsp[(3) - (3)].p), "name");
		    (yyval.pl) = Copy((yyvsp[(3) - (3)].p));
		    if (name)
		      Setattr((yyval.pl), "name", NewStringf("%s%d", name, n));
		    for (i = 1; i < n; i++) {
		      p = Copy((yyvsp[(3) - (3)].p));
		      name = Getattr(p, "name");
		      if (name)
		        Setattr(p, "name", NewStringf("%s%d", name, n-i));
		      set_nextSibling(p,(yyval.pl));
		      Delete((yyval.pl));
		      (yyval.pl) = p;
		    }
		  }
                ;}
    break;

  case 100:

/* Line 1455 of yacc.c  */
#line 2727 "parser.y"
    {
		   (yyval.node) = 0;
		   if ((yyvsp[(3) - (6)].tmap).method) {
		     String *code = 0;
		     (yyval.node) = new_node("typemap");
		     Setattr((yyval.node),"method",(yyvsp[(3) - (6)].tmap).method);
		     if ((yyvsp[(3) - (6)].tmap).kwargs) {
		       ParmList *kw = (yyvsp[(3) - (6)].tmap).kwargs;
                       code = remove_block(kw, (yyvsp[(6) - (6)].str));
		       Setattr((yyval.node),"kwargs", (yyvsp[(3) - (6)].tmap).kwargs);
		     }
		     code = code ? code : NewString((yyvsp[(6) - (6)].str));
		     Setattr((yyval.node),"code", code);
		     Delete(code);
		     appendChild((yyval.node),(yyvsp[(5) - (6)].p));
		   }
	       ;}
    break;

  case 101:

/* Line 1455 of yacc.c  */
#line 2744 "parser.y"
    {
		 (yyval.node) = 0;
		 if ((yyvsp[(3) - (6)].tmap).method) {
		   (yyval.node) = new_node("typemap");
		   Setattr((yyval.node),"method",(yyvsp[(3) - (6)].tmap).method);
		   appendChild((yyval.node),(yyvsp[(5) - (6)].p));
		 }
	       ;}
    break;

  case 102:

/* Line 1455 of yacc.c  */
#line 2752 "parser.y"
    {
		   (yyval.node) = 0;
		   if ((yyvsp[(3) - (8)].tmap).method) {
		     (yyval.node) = new_node("typemapcopy");
		     Setattr((yyval.node),"method",(yyvsp[(3) - (8)].tmap).method);
		     Setattr((yyval.node),"pattern", Getattr((yyvsp[(7) - (8)].p),"pattern"));
		     appendChild((yyval.node),(yyvsp[(5) - (8)].p));
		   }
	       ;}
    break;

  case 103:

/* Line 1455 of yacc.c  */
#line 2765 "parser.y"
    {
		 Hash *p;
		 String *name;
		 p = nextSibling((yyvsp[(1) - (1)].node));
		 if (p && (!Getattr(p,"value"))) {
 		   /* this is the deprecated two argument typemap form */
 		   Swig_warning(WARN_DEPRECATED_TYPEMAP_LANG,cparse_file, cparse_line,
				"Specifying the language name in %%typemap is deprecated - use #ifdef SWIG<LANG> instead.\n");
		   /* two argument typemap form */
		   name = Getattr((yyvsp[(1) - (1)].node),"name");
		   if (!name || (Strcmp(name,typemap_lang))) {
		     (yyval.tmap).method = 0;
		     (yyval.tmap).kwargs = 0;
		   } else {
		     (yyval.tmap).method = Getattr(p,"name");
		     (yyval.tmap).kwargs = nextSibling(p);
		   }
		 } else {
		   /* one-argument typemap-form */
		   (yyval.tmap).method = Getattr((yyvsp[(1) - (1)].node),"name");
		   (yyval.tmap).kwargs = p;
		 }
                ;}
    break;

  case 104:

/* Line 1455 of yacc.c  */
#line 2790 "parser.y"
    {
                 (yyval.p) = (yyvsp[(1) - (2)].p);
		 set_nextSibling((yyval.p),(yyvsp[(2) - (2)].p));
		;}
    break;

  case 105:

/* Line 1455 of yacc.c  */
#line 2796 "parser.y"
    {
                 (yyval.p) = (yyvsp[(2) - (3)].p);
		 set_nextSibling((yyval.p),(yyvsp[(3) - (3)].p));
                ;}
    break;

  case 106:

/* Line 1455 of yacc.c  */
#line 2800 "parser.y"
    { (yyval.p) = 0;;}
    break;

  case 107:

/* Line 1455 of yacc.c  */
#line 2803 "parser.y"
    {
                  Parm *parm;
		  SwigType_push((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).type);
		  (yyval.p) = new_node("typemapitem");
		  parm = NewParmWithoutFileLineInfo((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).id);
		  Setattr((yyval.p),"pattern",parm);
		  Setattr((yyval.p),"parms", (yyvsp[(2) - (2)].decl).parms);
		  Delete(parm);
		  /*		  $$ = NewParmWithoutFileLineInfo($1,$2.id);
				  Setattr($$,"parms",$2.parms); */
                ;}
    break;

  case 108:

/* Line 1455 of yacc.c  */
#line 2814 "parser.y"
    {
                  (yyval.p) = new_node("typemapitem");
		  Setattr((yyval.p),"pattern",(yyvsp[(2) - (3)].pl));
		  /*		  Setattr($$,"multitype",$2); */
               ;}
    break;

  case 109:

/* Line 1455 of yacc.c  */
#line 2819 "parser.y"
    {
		 (yyval.p) = new_node("typemapitem");
		 Setattr((yyval.p),"pattern", (yyvsp[(2) - (6)].pl));
		 /*                 Setattr($$,"multitype",$2); */
		 Setattr((yyval.p),"parms",(yyvsp[(5) - (6)].pl));
               ;}
    break;

  case 110:

/* Line 1455 of yacc.c  */
#line 2832 "parser.y"
    {
                   (yyval.node) = new_node("types");
		   Setattr((yyval.node),"parms",(yyvsp[(3) - (5)].pl));
                   if ((yyvsp[(5) - (5)].str))
		     Setattr((yyval.node),"convcode",NewString((yyvsp[(5) - (5)].str)));
               ;}
    break;

  case 111:

/* Line 1455 of yacc.c  */
#line 2844 "parser.y"
    {
                  Parm *p, *tp;
		  Node *n;
		  Symtab *tscope = 0;
		  int     specialized = 0;

		  (yyval.node) = 0;

		  tscope = Swig_symbol_current();          /* Get the current scope */

		  /* If the class name is qualified, we need to create or lookup namespace entries */
		  if (!inclass) {
		    (yyvsp[(5) - (9)].str) = resolve_create_node_scope((yyvsp[(5) - (9)].str));
		  }

		  /*
		    We use the new namespace entry 'nscope' only to
		    emit the template node. The template parameters are
		    resolved in the current 'tscope'.

		    This is closer to the C++ (typedef) behavior.
		  */
		  n = Swig_cparse_template_locate((yyvsp[(5) - (9)].str),(yyvsp[(7) - (9)].p),tscope);

		  /* Patch the argument types to respect namespaces */
		  p = (yyvsp[(7) - (9)].p);
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
                        if (nnisclass && !specialized && ((ParmList_len((yyvsp[(7) - (9)].p)) > ParmList_len(tparms)))) {
                          Swig_error(cparse_file, cparse_line, "Too many template parameters. Maximum of %d.\n", ParmList_len(tparms));
                        } else if (nnisclass && !specialized && ((ParmList_len((yyvsp[(7) - (9)].p)) < ParmList_numrequired(tparms)))) {
                          Swig_error(cparse_file, cparse_line, "Not enough template parameters specified. %d required.\n", ParmList_numrequired(tparms));
                        } else if (!nnisclass && ((ParmList_len((yyvsp[(7) - (9)].p)) != ParmList_len(tparms)))) {
                          /* must be an overloaded templated method - ignore it as it is overloaded with a different number of template parameters */
                          nn = Getattr(nn,"sym:nextSibling"); /* repeat for overloaded templated functions */
                          continue;
                        } else {
			  String *tname = Copy((yyvsp[(5) - (9)].str));
                          int def_supplied = 0;
                          /* Expand the template */
			  Node *templ = Swig_symbol_clookup((yyvsp[(5) - (9)].str),0);
			  Parm *targs = templ ? Getattr(templ,"templateparms") : 0;

                          ParmList *temparms;
                          if (specialized) temparms = CopyParmList((yyvsp[(7) - (9)].p));
                          else temparms = CopyParmList(tparms);

                          /* Create typedef's and arguments */
                          p = (yyvsp[(7) - (9)].p);
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
                          if ((yyvsp[(3) - (9)].id) && !inclass) {
			    /*
			       Comment this out for 1.3.28. We need to
			       re-enable it later but first we need to
			       move %ignore from using %rename to use
			       %feature(ignore).

			       String *symname = Swig_name_make(templnode,0,$3,0,0);
			    */
			    String *symname = (yyvsp[(3) - (9)].id);
                            Swig_cparse_template_expand(templnode,symname,temparms,tscope);
                            Setattr(templnode,"sym:name",symname);
                          } else {
                            static int cnt = 0;
                            String *nname = NewStringf("__dummy_%d__", cnt++);
                            Swig_cparse_template_expand(templnode,nname,temparms,tscope);
                            Setattr(templnode,"sym:name",nname);
			    Delete(nname);
                            Setattr(templnode,"feature:onlychildren", "typemap,typemapitem,typemapcopy,typedef,types,fragment");

			    if ((yyvsp[(3) - (9)].id)) {
			      Swig_warning(WARN_PARSE_NESTED_TEMPLATE, cparse_file, cparse_line, "Named nested template instantiations not supported. Processing as if no name was given to %%template().\n");
			    }
                          }
                          Delattr(templnode,"templatetype");
                          Setattr(templnode,"template",nn);
                          Setfile(templnode,cparse_file);
                          Setline(templnode,cparse_line);
                          Delete(temparms);

                          add_symbols_copy(templnode);

                          if (Strcmp(nodeType(templnode),"class") == 0) {

                            /* Identify pure abstract methods */
                            Setattr(templnode,"abstracts", pure_abstracts(firstChild(templnode)));

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
                                /*			    Printf(stdout,"%s: %s %p %p\n", Getattr(templnode,"name"), clsname, Swig_symbol_current(), Getattr(templnode,"symtab")); */
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
                            if (nscope) (yyval.node) = nscope;
                          }
                        } else {
                          /* global namespace */
                          if (!linklistend) {
                            (yyval.node) = templnode;
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
                ;}
    break;

  case 112:

/* Line 1455 of yacc.c  */
#line 3118 "parser.y"
    {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", (yyvsp[(2) - (2)].id));
		  (yyval.node) = 0;
               ;}
    break;

  case 113:

/* Line 1455 of yacc.c  */
#line 3128 "parser.y"
    {
                    (yyval.node) = (yyvsp[(1) - (1)].node); 
                    if ((yyval.node)) {
   		      add_symbols((yyval.node));
                      default_arguments((yyval.node));
   	            }
                ;}
    break;

  case 114:

/* Line 1455 of yacc.c  */
#line 3135 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 115:

/* Line 1455 of yacc.c  */
#line 3136 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 116:

/* Line 1455 of yacc.c  */
#line 3140 "parser.y"
    {
		  if (Strcmp((yyvsp[(2) - (3)].id),"C") == 0) {
		    cparse_externc = 1;
		  }
		;}
    break;

  case 117:

/* Line 1455 of yacc.c  */
#line 3144 "parser.y"
    {
		  cparse_externc = 0;
		  if (Strcmp((yyvsp[(2) - (6)].id),"C") == 0) {
		    Node *n = firstChild((yyvsp[(5) - (6)].node));
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[(2) - (6)].id));
		    appendChild((yyval.node),n);
		    while (n) {
		      SwigType *decl = Getattr(n,"decl");
		      if (SwigType_isfunction(decl) && !Equal(Getattr(n, "storage"), "typedef")) {
			Setattr(n,"storage","externc");
		      }
		      n = nextSibling(n);
		    }
		  } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[(2) - (6)].id));
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[(2) - (6)].id));
		    appendChild((yyval.node),firstChild((yyvsp[(5) - (6)].node)));
		  }
                ;}
    break;

  case 118:

/* Line 1455 of yacc.c  */
#line 3171 "parser.y"
    {
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[(4) - (5)].dtype).qualifier) SwigType_push((yyvsp[(3) - (5)].decl).type,(yyvsp[(4) - (5)].dtype).qualifier);
	      Setattr((yyval.node),"type",(yyvsp[(2) - (5)].type));
	      Setattr((yyval.node),"storage",(yyvsp[(1) - (5)].id));
	      Setattr((yyval.node),"name",(yyvsp[(3) - (5)].decl).id);
	      Setattr((yyval.node),"decl",(yyvsp[(3) - (5)].decl).type);
	      Setattr((yyval.node),"parms",(yyvsp[(3) - (5)].decl).parms);
	      Setattr((yyval.node),"value",(yyvsp[(4) - (5)].dtype).val);
	      Setattr((yyval.node),"throws",(yyvsp[(4) - (5)].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[(4) - (5)].dtype).throwf);
	      if (!(yyvsp[(5) - (5)].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[(5) - (5)].node);
		/* Inherit attributes */
		while (n) {
		  String *type = Copy((yyvsp[(2) - (5)].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[(1) - (5)].id));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }
	      if ((yyvsp[(4) - (5)].dtype).bitfield) {
		Setattr((yyval.node),"bitfield", (yyvsp[(4) - (5)].dtype).bitfield);
	      }

	      /* Look for "::" declarations (ignored) */
	      if (Strstr((yyvsp[(3) - (5)].decl).id,"::")) {
                /* This is a special case. If the scope name of the declaration exactly
                   matches that of the declaration, then we will allow it. Otherwise, delete. */
                String *p = Swig_scopename_prefix((yyvsp[(3) - (5)].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p,Namespaceprefix) == 0) ||
		      (inclass && Strcmp(p,Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[(3) - (5)].decl).id);
		    Setattr((yyval.node),"name",lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[(5) - (5)].node);
		  }
		  Delete(p);
		} else {
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[(5) - (5)].node);
		}
	      } else {
		set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
	      }
           ;}
    break;

  case 119:

/* Line 1455 of yacc.c  */
#line 3232 "parser.y"
    { 
                   (yyval.node) = 0;
                   Clear(scanner_ccode); 
               ;}
    break;

  case 120:

/* Line 1455 of yacc.c  */
#line 3236 "parser.y"
    {
		 (yyval.node) = new_node("cdecl");
		 if ((yyvsp[(3) - (4)].dtype).qualifier) SwigType_push((yyvsp[(2) - (4)].decl).type,(yyvsp[(3) - (4)].dtype).qualifier);
		 Setattr((yyval.node),"name",(yyvsp[(2) - (4)].decl).id);
		 Setattr((yyval.node),"decl",(yyvsp[(2) - (4)].decl).type);
		 Setattr((yyval.node),"parms",(yyvsp[(2) - (4)].decl).parms);
		 Setattr((yyval.node),"value",(yyvsp[(3) - (4)].dtype).val);
		 Setattr((yyval.node),"throws",(yyvsp[(3) - (4)].dtype).throws);
		 Setattr((yyval.node),"throw",(yyvsp[(3) - (4)].dtype).throwf);
		 if ((yyvsp[(3) - (4)].dtype).bitfield) {
		   Setattr((yyval.node),"bitfield", (yyvsp[(3) - (4)].dtype).bitfield);
		 }
		 if (!(yyvsp[(4) - (4)].node)) {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr((yyval.node),"code",code);
		     Delete(code);
		   }
		 } else {
		   set_nextSibling((yyval.node),(yyvsp[(4) - (4)].node));
		 }
	       ;}
    break;

  case 121:

/* Line 1455 of yacc.c  */
#line 3258 "parser.y"
    { 
                   skip_balanced('{','}');
                   (yyval.node) = 0;
               ;}
    break;

  case 122:

/* Line 1455 of yacc.c  */
#line 3264 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(1) - (1)].dtype); 
                   (yyval.dtype).qualifier = 0;
		   (yyval.dtype).throws = 0;
		   (yyval.dtype).throwf = 0;
              ;}
    break;

  case 123:

/* Line 1455 of yacc.c  */
#line 3270 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(2) - (2)].dtype); 
		   (yyval.dtype).qualifier = (yyvsp[(1) - (2)].str);
		   (yyval.dtype).throws = 0;
		   (yyval.dtype).throwf = 0;
	      ;}
    break;

  case 124:

/* Line 1455 of yacc.c  */
#line 3276 "parser.y"
    { 
		   (yyval.dtype) = (yyvsp[(5) - (5)].dtype); 
                   (yyval.dtype).qualifier = 0;
		   (yyval.dtype).throws = (yyvsp[(3) - (5)].pl);
		   (yyval.dtype).throwf = NewString("1");
              ;}
    break;

  case 125:

/* Line 1455 of yacc.c  */
#line 3282 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(6) - (6)].dtype); 
                   (yyval.dtype).qualifier = (yyvsp[(1) - (6)].str);
		   (yyval.dtype).throws = (yyvsp[(4) - (6)].pl);
		   (yyval.dtype).throwf = NewString("1");
              ;}
    break;

  case 126:

/* Line 1455 of yacc.c  */
#line 3295 "parser.y"
    {
		   SwigType *ty = 0;
		   (yyval.node) = new_node("enumforward");
		   ty = NewStringf("enum %s", (yyvsp[(3) - (4)].id));
		   Setattr((yyval.node),"name",(yyvsp[(3) - (4)].id));
		   Setattr((yyval.node),"type",ty);
		   Setattr((yyval.node),"sym:weak", "1");
		   add_symbols((yyval.node));
	      ;}
    break;

  case 127:

/* Line 1455 of yacc.c  */
#line 3310 "parser.y"
    {
		  SwigType *ty = 0;
                  (yyval.node) = new_node("enum");
		  ty = NewStringf("enum %s", (yyvsp[(3) - (7)].id));
		  Setattr((yyval.node),"name",(yyvsp[(3) - (7)].id));
		  Setattr((yyval.node),"type",ty);
		  appendChild((yyval.node),(yyvsp[(5) - (7)].node));
		  add_symbols((yyval.node));       /* Add to tag space */
		  add_symbols((yyvsp[(5) - (7)].node));       /* Add enum values to id space */
               ;}
    break;

  case 128:

/* Line 1455 of yacc.c  */
#line 3320 "parser.y"
    {
		 Node *n;
		 SwigType *ty = 0;
		 String   *unnamed = 0;
		 int       unnamedinstance = 0;

		 (yyval.node) = new_node("enum");
		 if ((yyvsp[(3) - (9)].id)) {
		   Setattr((yyval.node),"name",(yyvsp[(3) - (9)].id));
		   ty = NewStringf("enum %s", (yyvsp[(3) - (9)].id));
		 } else if ((yyvsp[(7) - (9)].decl).id) {
		   unnamed = make_unnamed();
		   ty = NewStringf("enum %s", unnamed);
		   Setattr((yyval.node),"unnamed",unnamed);
                   /* name is not set for unnamed enum instances, e.g. enum { foo } Instance; */
		   if ((yyvsp[(1) - (9)].id) && Cmp((yyvsp[(1) - (9)].id),"typedef") == 0) {
		     Setattr((yyval.node),"name",(yyvsp[(7) - (9)].decl).id);
                   } else {
                     unnamedinstance = 1;
                   }
		   Setattr((yyval.node),"storage",(yyvsp[(1) - (9)].id));
		 }
		 if ((yyvsp[(7) - (9)].decl).id && Cmp((yyvsp[(1) - (9)].id),"typedef") == 0) {
		   Setattr((yyval.node),"tdname",(yyvsp[(7) - (9)].decl).id);
                   Setattr((yyval.node),"allows_typedef","1");
                 }
		 appendChild((yyval.node),(yyvsp[(5) - (9)].node));
		 n = new_node("cdecl");
		 Setattr(n,"type",ty);
		 Setattr(n,"name",(yyvsp[(7) - (9)].decl).id);
		 Setattr(n,"storage",(yyvsp[(1) - (9)].id));
		 Setattr(n,"decl",(yyvsp[(7) - (9)].decl).type);
		 Setattr(n,"parms",(yyvsp[(7) - (9)].decl).parms);
		 Setattr(n,"unnamed",unnamed);

                 if (unnamedinstance) {
		   SwigType *cty = NewString("enum ");
		   Setattr((yyval.node),"type",cty);
		   SetFlag((yyval.node),"unnamedinstance");
		   SetFlag(n,"unnamedinstance");
		   Delete(cty);
                 }
		 if ((yyvsp[(9) - (9)].node)) {
		   Node *p = (yyvsp[(9) - (9)].node);
		   set_nextSibling(n,p);
		   while (p) {
		     SwigType *cty = Copy(ty);
		     Setattr(p,"type",cty);
		     Setattr(p,"unnamed",unnamed);
		     Setattr(p,"storage",(yyvsp[(1) - (9)].id));
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
                 if ((yyvsp[(7) - (9)].decl).id && (yyvsp[(3) - (9)].id) && Cmp((yyvsp[(1) - (9)].id),"typedef") == 0) {
		   String *name = NewString((yyvsp[(7) - (9)].decl).id);
                   Setattr((yyval.node), "parser:makename", name);
		   Delete(name);
                 }

		 add_symbols((yyval.node));       /* Add enum to tag space */
		 set_nextSibling((yyval.node),n);
		 Delete(n);
		 add_symbols((yyvsp[(5) - (9)].node));       /* Add enum values to id space */
	         add_symbols(n);
		 Delete(unnamed);
	       ;}
    break;

  case 129:

/* Line 1455 of yacc.c  */
#line 3398 "parser.y"
    {
                   /* This is a sick hack.  If the ctor_end has parameters,
                      and the parms parameter only has 1 parameter, this
                      could be a declaration of the form:

                         type (id)(parms)

			 Otherwise it's an error. */
                    int err = 0;
                    (yyval.node) = 0;

		    if ((ParmList_len((yyvsp[(4) - (6)].pl)) == 1) && (!Swig_scopename_check((yyvsp[(2) - (6)].type)))) {
		      SwigType *ty = Getattr((yyvsp[(4) - (6)].pl),"type");
		      String *name = Getattr((yyvsp[(4) - (6)].pl),"name");
		      err = 1;
		      if (!name) {
			(yyval.node) = new_node("cdecl");
			Setattr((yyval.node),"type",(yyvsp[(2) - (6)].type));
			Setattr((yyval.node),"storage",(yyvsp[(1) - (6)].id));
			Setattr((yyval.node),"name",ty);

			if ((yyvsp[(6) - (6)].decl).have_parms) {
			  SwigType *decl = NewStringEmpty();
			  SwigType_add_function(decl,(yyvsp[(6) - (6)].decl).parms);
			  Setattr((yyval.node),"decl",decl);
			  Setattr((yyval.node),"parms",(yyvsp[(6) - (6)].decl).parms);
			  if (Len(scanner_ccode)) {
			    String *code = Copy(scanner_ccode);
			    Setattr((yyval.node),"code",code);
			    Delete(code);
			  }
			}
			if ((yyvsp[(6) - (6)].decl).defarg) {
			  Setattr((yyval.node),"value",(yyvsp[(6) - (6)].decl).defarg);
			}
			Setattr((yyval.node),"throws",(yyvsp[(6) - (6)].decl).throws);
			Setattr((yyval.node),"throw",(yyvsp[(6) - (6)].decl).throwf);
			err = 0;
		      }
		    }
		    if (err) {
		      Swig_error(cparse_file,cparse_line,"Syntax error in input(2).\n");
		      exit(1);
		    }
                ;}
    break;

  case 130:

/* Line 1455 of yacc.c  */
#line 3449 "parser.y"
    {  (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 131:

/* Line 1455 of yacc.c  */
#line 3450 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 132:

/* Line 1455 of yacc.c  */
#line 3451 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 133:

/* Line 1455 of yacc.c  */
#line 3452 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 134:

/* Line 1455 of yacc.c  */
#line 3453 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 135:

/* Line 1455 of yacc.c  */
#line 3454 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 136:

/* Line 1455 of yacc.c  */
#line 3459 "parser.y"
    {
                 if (nested_template == 0) {
                   String *prefix;
                   List *bases = 0;
		   Node *scope = 0;
		   (yyval.node) = new_node("class");
		   Setline((yyval.node),cparse_start_line);
		   Setattr((yyval.node),"kind",(yyvsp[(2) - (5)].id));
		   if ((yyvsp[(4) - (5)].bases)) {
		     Setattr((yyval.node),"baselist", Getattr((yyvsp[(4) - (5)].bases),"public"));
		     Setattr((yyval.node),"protectedbaselist", Getattr((yyvsp[(4) - (5)].bases),"protected"));
		     Setattr((yyval.node),"privatebaselist", Getattr((yyvsp[(4) - (5)].bases),"private"));
		   }
		   Setattr((yyval.node),"allows_typedef","1");

		   /* preserve the current scope */
		   prev_symtab = Swig_symbol_current();
		  
		   /* If the class name is qualified.  We need to create or lookup namespace/scope entries */
		   scope = resolve_create_node_scope((yyvsp[(3) - (5)].str));
		   Setfile(scope,cparse_file);
		   Setline(scope,cparse_line);
		   (yyvsp[(3) - (5)].str) = scope;
		   
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
		       String *name = NewStringf("%s::%s", Namespaceprefix, (yyvsp[(3) - (5)].str));		       
		       (yyvsp[(3) - (5)].str) = name;
		       Namespaceprefix = 0;
		       nscope_inner = 0;
		     }
		   }
		   Setattr((yyval.node),"name",(yyvsp[(3) - (5)].str));

		   Delete(class_rename);
                   class_rename = make_name((yyval.node),(yyvsp[(3) - (5)].str),0);
		   Classprefix = NewString((yyvsp[(3) - (5)].str));
		   /* Deal with inheritance  */
		   if ((yyvsp[(4) - (5)].bases)) {
		     bases = make_inherit_list((yyvsp[(3) - (5)].str),Getattr((yyvsp[(4) - (5)].bases),"public"));
		   }
		   prefix = SwigType_istemplate_templateprefix((yyvsp[(3) - (5)].str));
		   if (prefix) {
		     String *fbase, *tbase;
		     if (Namespaceprefix) {
		       fbase = NewStringf("%s::%s", Namespaceprefix,(yyvsp[(3) - (5)].str));
		       tbase = NewStringf("%s::%s", Namespaceprefix, prefix);
		     } else {
		       fbase = Copy((yyvsp[(3) - (5)].str));
		       tbase = Copy(prefix);
		     }
		     Swig_name_inherit(tbase,fbase);
		     Delete(fbase);
		     Delete(tbase);
		   }
                   if (strcmp((yyvsp[(2) - (5)].id),"class") == 0) {
		     cplus_mode = CPLUS_PRIVATE;
		   } else {
		     cplus_mode = CPLUS_PUBLIC;
		   }
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename((yyvsp[(3) - (5)].str));
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
		   class_decl[class_level++] = (yyval.node);
		   Delete(prefix);
		   inclass = 1;
		 }
               ;}
    break;

  case 137:

/* Line 1455 of yacc.c  */
#line 3576 "parser.y"
    {
	         (void) (yyvsp[(6) - (9)].node);
		 if (nested_template == 0) {
		   Node *p;
		   SwigType *ty;
		   Symtab *cscope = prev_symtab;
		   Node *am = 0;
		   String *scpname = 0;
		   (yyval.node) = class_decl[--class_level];
		   inclass = 0;
		   
		   /* Check for pure-abstract class */
		   Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[(7) - (9)].node)));
		   
		   /* This bit of code merges in a previously defined %extend directive (if any) */
		   
		   if (extendhash) {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     am = Getattr(extendhash,clsname);
		     if (am) {
		       merge_extensions((yyval.node),am);
		       Delattr(extendhash,clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes,scpname,(yyval.node));

		   appendChild((yyval.node),(yyvsp[(7) - (9)].node));
		   
		   if (am) append_previous_extension((yyval.node),am);

		   p = (yyvsp[(9) - (9)].node);
		   if (p) {
		     set_nextSibling((yyval.node),p);
		   }
		   
		   if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString((yyvsp[(3) - (9)].str));
		   } else {
		     ty = NewStringf("%s %s", (yyvsp[(2) - (9)].id),(yyvsp[(3) - (9)].str));
		   }
		   while (p) {
		     Setattr(p,"storage",(yyvsp[(1) - (9)].id));
		     Setattr(p,"type",ty);
		     p = nextSibling(p);
		   }
		   /* Class typedefs */
		   {
		     String *name = (yyvsp[(3) - (9)].str);
		     if ((yyvsp[(9) - (9)].node)) {
		       SwigType *decltype = Getattr((yyvsp[(9) - (9)].node),"decl");
		       if (Cmp((yyvsp[(1) - (9)].id),"typedef") == 0) {
			 if (!decltype || !Len(decltype)) {
			   String *cname;
			   String *tdscopename;
			   String *class_scope = Swig_symbol_qualifiedscopename(cscope);
			   name = Getattr((yyvsp[(9) - (9)].node),"name");
			   cname = Copy(name);
			   Setattr((yyval.node),"tdname",cname);
			   tdscopename = class_scope ? NewStringf("%s::%s", class_scope, name) : Copy(name);

			   /* Use typedef name as class name */
			   if (class_rename && (Strcmp(class_rename,(yyvsp[(3) - (9)].str)) == 0)) {
			     Delete(class_rename);
			     class_rename = NewString(name);
			   }
			   if (!classes_typedefs) classes_typedefs = NewHash();
			   if (!Equal(scpname, tdscopename) && !Getattr(classes_typedefs, tdscopename)) {
			     Setattr(classes_typedefs, tdscopename, (yyval.node));
			   }
			   Setattr((yyval.node),"decl",decltype);
			   Delete(class_scope);
			   Delete(cname);
			   Delete(tdscopename);
			 }
		       }
		     }
		     appendChild((yyval.node),dump_nested(Char(name)));
		   }
		   Delete(scpname);

		   if (cplus_mode != CPLUS_PUBLIC) {
		   /* we 'open' the class at the end, to allow %template
		      to add new members */
		     Node *pa = new_node("access");
		     Setattr(pa,"kind","public");
		     cplus_mode = CPLUS_PUBLIC;
		     appendChild((yyval.node),pa);
		     Delete(pa);
		   }

		   Setattr((yyval.node),"symtab",Swig_symbol_popscope());

		   Classprefix = 0;
		   if (nscope_inner) {
		     /* this is tricky */
		     /* we add the declaration in the original namespace */
		     appendChild(nscope_inner,(yyval.node));
		     Swig_symbol_setscope(Getattr(nscope_inner,"symtab"));
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols((yyval.node));
		     if (nscope) (yyval.node) = nscope;
		     /* but the variable definition in the current scope */
		     Swig_symbol_setscope(cscope);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols((yyvsp[(9) - (9)].node));
		   } else {
		     Delete(yyrename);
		     yyrename = Copy(class_rename);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);

		     add_symbols((yyval.node));
		     add_symbols((yyvsp[(9) - (9)].node));
		   }
		   Swig_symbol_setscope(cscope);
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 } else {
		    (yyval.node) = new_node("class");
		    Setattr((yyval.node),"kind",(yyvsp[(2) - (9)].id));
		    Setattr((yyval.node),"name",NewString((yyvsp[(3) - (9)].str)));
		    SetFlag((yyval.node),"nestedtemplateclass");
		 }
	       ;}
    break;

  case 138:

/* Line 1455 of yacc.c  */
#line 3708 "parser.y"
    {
	       String *unnamed;
	       unnamed = make_unnamed();
	       (yyval.node) = new_node("class");
	       Setline((yyval.node),cparse_start_line);
	       Setattr((yyval.node),"kind",(yyvsp[(2) - (3)].id));
	       Setattr((yyval.node),"storage",(yyvsp[(1) - (3)].id));
	       Setattr((yyval.node),"unnamed",unnamed);
	       Setattr((yyval.node),"allows_typedef","1");
	       Delete(class_rename);
	       class_rename = make_name((yyval.node),0,0);
	       if (strcmp((yyvsp[(2) - (3)].id),"class") == 0) {
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
	       class_decl[class_level++] = (yyval.node);
	       inclass = 1;
	       Classprefix = NewStringEmpty();
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
             ;}
    break;

  case 139:

/* Line 1455 of yacc.c  */
#line 3742 "parser.y"
    {
	       String *unnamed;
	       Node *n;
	       (void) (yyvsp[(4) - (9)].node);
	       Classprefix = 0;
	       (yyval.node) = class_decl[--class_level];
	       inclass = 0;
	       unnamed = Getattr((yyval.node),"unnamed");

	       /* Check for pure-abstract class */
	       Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[(5) - (9)].node)));

	       n = new_node("cdecl");
	       Setattr(n,"name",(yyvsp[(7) - (9)].decl).id);
	       Setattr(n,"unnamed",unnamed);
	       Setattr(n,"type",unnamed);
	       Setattr(n,"decl",(yyvsp[(7) - (9)].decl).type);
	       Setattr(n,"parms",(yyvsp[(7) - (9)].decl).parms);
	       Setattr(n,"storage",(yyvsp[(1) - (9)].id));
	       if ((yyvsp[(9) - (9)].node)) {
		 Node *p = (yyvsp[(9) - (9)].node);
		 set_nextSibling(n,p);
		 while (p) {
		   String *type = Copy(unnamed);
		   Setattr(p,"name",(yyvsp[(7) - (9)].decl).id);
		   Setattr(p,"unnamed",unnamed);
		   Setattr(p,"type",type);
		   Delete(type);
		   Setattr(p,"storage",(yyvsp[(1) - (9)].id));
		   p = nextSibling(p);
		 }
	       }
	       set_nextSibling((yyval.node),n);
	       Delete(n);
	       {
		 /* If a proper typedef name was given, we'll use it to set the scope name */
		 String *name = 0;
		 if ((yyvsp[(1) - (9)].id) && (strcmp((yyvsp[(1) - (9)].id),"typedef") == 0)) {
		   if (!Len((yyvsp[(7) - (9)].decl).type)) {	
		     String *scpname = 0;
		     name = (yyvsp[(7) - (9)].decl).id;
		     Setattr((yyval.node),"tdname",name);
		     Setattr((yyval.node),"name",name);
		     Swig_symbol_setscopename(name);

		     /* If a proper name was given, we use that as the typedef, not unnamed */
		     Clear(unnamed);
		     Append(unnamed, name);
		     
		     n = nextSibling(n);
		     set_nextSibling((yyval.node),n);

		     /* Check for previous extensions */
		     if (extendhash) {
		       String *clsname = Swig_symbol_qualifiedscopename(0);
		       Node *am = Getattr(extendhash,clsname);
		       if (am) {
			 /* Merge the extension into the symbol table */
			 merge_extensions((yyval.node),am);
			 append_previous_extension((yyval.node),am);
			 Delattr(extendhash,clsname);
		       }
		       Delete(clsname);
		     }
		     if (!classes) classes = NewHash();
		     scpname = Swig_symbol_qualifiedscopename(0);
		     Setattr(classes,scpname,(yyval.node));
		     Delete(scpname);
		   } else {
		     Swig_symbol_setscopename("<unnamed>");
		   }
		 }
		 appendChild((yyval.node),(yyvsp[(5) - (9)].node));
		 appendChild((yyval.node),dump_nested(Char(name)));
	       }
	       /* Pop the scope */
	       Setattr((yyval.node),"symtab",Swig_symbol_popscope());
	       if (class_rename) {
		 Delete(yyrename);
		 yyrename = NewString(class_rename);
	       }
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols((yyval.node));
	       add_symbols(n);
	       Delete(unnamed);
              ;}
    break;

  case 140:

/* Line 1455 of yacc.c  */
#line 3831 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 141:

/* Line 1455 of yacc.c  */
#line 3832 "parser.y"
    {
                        (yyval.node) = new_node("cdecl");
                        Setattr((yyval.node),"name",(yyvsp[(1) - (3)].decl).id);
                        Setattr((yyval.node),"decl",(yyvsp[(1) - (3)].decl).type);
                        Setattr((yyval.node),"parms",(yyvsp[(1) - (3)].decl).parms);
			set_nextSibling((yyval.node),(yyvsp[(3) - (3)].node));
                    ;}
    break;

  case 142:

/* Line 1455 of yacc.c  */
#line 3844 "parser.y"
    {
              if ((yyvsp[(1) - (4)].id) && (Strcmp((yyvsp[(1) - (4)].id),"friend") == 0)) {
		/* Ignore */
                (yyval.node) = 0; 
	      } else {
		(yyval.node) = new_node("classforward");
		Setattr((yyval.node),"kind",(yyvsp[(2) - (4)].id));
		Setattr((yyval.node),"name",(yyvsp[(3) - (4)].str));
		Setattr((yyval.node),"sym:weak", "1");
		add_symbols((yyval.node));
	      }
             ;}
    break;

  case 143:

/* Line 1455 of yacc.c  */
#line 3862 "parser.y"
    { 
		    template_parameters = (yyvsp[(3) - (4)].tparms); 
		    if (inclass)
		      nested_template++;

		  ;}
    break;

  case 144:

/* Line 1455 of yacc.c  */
#line 3867 "parser.y"
    {

		    /* Don't ignore templated functions declared within a class, unless the templated function is within a nested class */
		    if (nested_template <= 1) {
		      int is_nested_template_class = (yyvsp[(6) - (6)].node) && GetFlag((yyvsp[(6) - (6)].node), "nestedtemplateclass");
		      if (is_nested_template_class) {
			(yyval.node) = 0;
			/* Nested template classes would probably better be ignored like ordinary nested classes using cpp_nested, but that introduces shift/reduce conflicts */
			if (cplus_mode == CPLUS_PUBLIC) {
			  /* Treat the nested class/struct/union as a forward declaration until a proper nested class solution is implemented */
			  String *kind = Getattr((yyvsp[(6) - (6)].node), "kind");
			  String *name = Getattr((yyvsp[(6) - (6)].node), "name");
			  (yyval.node) = new_node("template");
			  Setattr((yyval.node),"kind",kind);
			  Setattr((yyval.node),"name",name);
			  Setattr((yyval.node),"sym:weak", "1");
			  Setattr((yyval.node),"templatetype","classforward");
			  Setattr((yyval.node),"templateparms", (yyvsp[(3) - (6)].tparms));
			  add_symbols((yyval.node));

			  if (GetFlag((yyval.node), "feature:nestedworkaround")) {
			    Swig_symbol_remove((yyval.node));
			    (yyval.node) = 0;
			  } else {
			    SWIG_WARN_NODE_BEGIN((yyval.node));
			    Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested template %s not currently supported (%s ignored).\n", kind, name);
			    SWIG_WARN_NODE_END((yyval.node));
			  }
			}
			Delete((yyvsp[(6) - (6)].node));
		      } else {
			String *tname = 0;
			int     error = 0;

			/* check if we get a namespace node with a class declaration, and retrieve the class */
			Symtab *cscope = Swig_symbol_current();
			Symtab *sti = 0;
			Node *ntop = (yyvsp[(6) - (6)].node);
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
			  (yyvsp[(6) - (6)].node) = ni;
			}

			(yyval.node) = (yyvsp[(6) - (6)].node);
			if ((yyval.node)) tname = Getattr((yyval.node),"name");
			
			/* Check if the class is a template specialization */
			if (((yyval.node)) && (Strchr(tname,'<')) && (!is_operator(tname))) {
			  /* If a specialization.  Check if defined. */
			  Node *tempn = 0;
			  {
			    String *tbase = SwigType_templateprefix(tname);
			    tempn = Swig_symbol_clookup_local(tbase,0);
			    if (!tempn || (Strcmp(nodeType(tempn),"template") != 0)) {
			      SWIG_WARN_NODE_BEGIN(tempn);
			      Swig_warning(WARN_PARSE_TEMPLATE_SP_UNDEF, Getfile((yyval.node)),Getline((yyval.node)),"Specialization of non-template '%s'.\n", tbase);
			      SWIG_WARN_NODE_END(tempn);
			      tempn = 0;
			      error = 1;
			    }
			    Delete(tbase);
			  }
			  Setattr((yyval.node),"specialization","1");
			  Setattr((yyval.node),"templatetype",nodeType((yyval.node)));
			  set_nodeType((yyval.node),"template");
			  /* Template partial specialization */
			  if (tempn && ((yyvsp[(3) - (6)].tparms)) && ((yyvsp[(6) - (6)].node))) {
			    List   *tlist;
			    String *targs = SwigType_templateargs(tname);
			    tlist = SwigType_parmlist(targs);
			    /*			  Printf(stdout,"targs = '%s' %s\n", targs, tlist); */
			    if (!Getattr((yyval.node),"sym:weak")) {
			      Setattr((yyval.node),"sym:typename","1");
			    }
			    
			    if (Len(tlist) != ParmList_len(Getattr(tempn,"templateparms"))) {
			      Swig_error(Getfile((yyval.node)),Getline((yyval.node)),"Inconsistent argument count in template partial specialization. %d %d\n", Len(tlist), ParmList_len(Getattr(tempn,"templateparms")));
			      
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
			      p = (yyvsp[(3) - (6)].tparms);
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
			      Setattr((yyval.node),"templateparms",tp);
			      Delete(tp);
			    }
  #if 0
			    /* Patch the parameter list */
			    if (tempn) {
			      Parm *p,*p1;
			      ParmList *tp = CopyParmList(Getattr(tempn,"templateparms"));
			      p = (yyvsp[(3) - (6)].tparms);
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
			      Setattr((yyval.node),"templateparms",tp);
			      Delete(tp);
			    } else {
			      Setattr((yyval.node),"templateparms",(yyvsp[(3) - (6)].tparms));
			    }
  #endif
			    Delattr((yyval.node),"specialization");
			    Setattr((yyval.node),"partialspecialization","1");
			    /* Create a specialized name for matching */
			    {
			      Parm *p = (yyvsp[(3) - (6)].tparms);
			      String *fname = NewString(Getattr((yyval.node),"name"));
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
			      Setattr((yyval.node),"partialargs",ffname);
			      Swig_symbol_cadd(ffname,(yyval.node));
			    }
			    }
			    Delete(tlist);
			    Delete(targs);
			  } else {
			    /* An explicit template specialization */
			    /* add default args from primary (unspecialized) template */
			    String *ty = Swig_symbol_template_deftype(tname,0);
			    String *fname = Swig_symbol_type_qualify(ty,0);
			    Swig_symbol_cadd(fname,(yyval.node));
			    Delete(ty);
			    Delete(fname);
			  }
			}  else if ((yyval.node)) {
			  Setattr((yyval.node),"templatetype",nodeType((yyvsp[(6) - (6)].node)));
			  set_nodeType((yyval.node),"template");
			  Setattr((yyval.node),"templateparms", (yyvsp[(3) - (6)].tparms));
			  if (!Getattr((yyval.node),"sym:weak")) {
			    Setattr((yyval.node),"sym:typename","1");
			  }
			  add_symbols((yyval.node));
			  default_arguments((yyval.node));
			  /* We also place a fully parameterized version in the symbol table */
			  {
			    Parm *p;
			    String *fname = NewStringf("%s<(", Getattr((yyval.node),"name"));
			    p = (yyvsp[(3) - (6)].tparms);
			    while (p) {
			      String *n = Getattr(p,"name");
			      if (!n) n = Getattr(p,"type");
			      Append(fname,n);
			      p = nextSibling(p);
			      if (p) Putc(',',fname);
			    }
			    Append(fname,")>");
			    Swig_symbol_cadd(fname,(yyval.node));
			  }
			}
			(yyval.node) = ntop;
			Swig_symbol_setscope(cscope);
			Delete(Namespaceprefix);
			Namespaceprefix = Swig_symbol_qualifiedscopename(0);
			if (error) (yyval.node) = 0;
		      }
		    } else {
		      (yyval.node) = 0;
		    }
		    template_parameters = 0;
		    if (inclass)
		      nested_template--;
                  ;}
    break;

  case 145:

/* Line 1455 of yacc.c  */
#line 4151 "parser.y"
    {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                   (yyval.node) = 0; 
                ;}
    break;

  case 146:

/* Line 1455 of yacc.c  */
#line 4157 "parser.y"
    {
		  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 147:

/* Line 1455 of yacc.c  */
#line 4160 "parser.y"
    {
                   (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 148:

/* Line 1455 of yacc.c  */
#line 4163 "parser.y"
    {
                   (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 149:

/* Line 1455 of yacc.c  */
#line 4166 "parser.y"
    {
		  (yyval.node) = 0;
                ;}
    break;

  case 150:

/* Line 1455 of yacc.c  */
#line 4169 "parser.y"
    {
                  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 151:

/* Line 1455 of yacc.c  */
#line 4172 "parser.y"
    {
                  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 152:

/* Line 1455 of yacc.c  */
#line 4177 "parser.y"
    {
		   /* Rip out the parameter names */
		  Parm *p = (yyvsp[(1) - (1)].pl);
		  (yyval.tparms) = (yyvsp[(1) - (1)].pl);

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
                 ;}
    break;

  case 153:

/* Line 1455 of yacc.c  */
#line 4207 "parser.y"
    {
                      set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].pl));
                      (yyval.pl) = (yyvsp[(1) - (2)].p);
                   ;}
    break;

  case 154:

/* Line 1455 of yacc.c  */
#line 4211 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 155:

/* Line 1455 of yacc.c  */
#line 4214 "parser.y"
    {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewString((yyvsp[(1) - (1)].id)), 0);
                  ;}
    break;

  case 156:

/* Line 1455 of yacc.c  */
#line 4217 "parser.y"
    {
                    (yyval.p) = (yyvsp[(1) - (1)].p);
                  ;}
    break;

  case 157:

/* Line 1455 of yacc.c  */
#line 4222 "parser.y"
    {
                         set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].pl));
                         (yyval.pl) = (yyvsp[(2) - (3)].p);
                       ;}
    break;

  case 158:

/* Line 1455 of yacc.c  */
#line 4226 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 159:

/* Line 1455 of yacc.c  */
#line 4231 "parser.y"
    {
                  String *uname = Swig_symbol_type_qualify((yyvsp[(2) - (3)].str),0);
		  String *name = Swig_scopename_last((yyvsp[(2) - (3)].str));
                  (yyval.node) = new_node("using");
		  Setattr((yyval.node),"uname",uname);
		  Setattr((yyval.node),"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols((yyval.node));
             ;}
    break;

  case 160:

/* Line 1455 of yacc.c  */
#line 4241 "parser.y"
    {
	       Node *n = Swig_symbol_clookup((yyvsp[(3) - (4)].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Nothing known about namespace '%s'\n", (yyvsp[(3) - (4)].str));
		 (yyval.node) = 0;
	       } else {

		 while (Strcmp(nodeType(n),"using") == 0) {
		   n = Getattr(n,"node");
		 }
		 if (n) {
		   if (Strcmp(nodeType(n),"namespace") == 0) {
		     Symtab *current = Swig_symbol_current();
		     Symtab *symtab = Getattr(n,"symtab");
		     (yyval.node) = new_node("using");
		     Setattr((yyval.node),"node",n);
		     Setattr((yyval.node),"namespace", (yyvsp[(3) - (4)].str));
		     if (current != symtab) {
		       Swig_symbol_inherit(symtab);
		     }
		   } else {
		     Swig_error(cparse_file, cparse_line, "'%s' is not a namespace.\n", (yyvsp[(3) - (4)].str));
		     (yyval.node) = 0;
		   }
		 } else {
		   (yyval.node) = 0;
		 }
	       }
             ;}
    break;

  case 161:

/* Line 1455 of yacc.c  */
#line 4272 "parser.y"
    { 
                Hash *h;
                (yyvsp[(1) - (3)].node) = Swig_symbol_current();
		h = Swig_symbol_clookup((yyvsp[(2) - (3)].str),0);
		if (h && ((yyvsp[(1) - (3)].node) == Getattr(h,"sym:symtab")) && (Strcmp(nodeType(h),"namespace") == 0)) {
		  if (Getattr(h,"alias")) {
		    h = Getattr(h,"namespace");
		    Swig_warning(WARN_PARSE_NAMESPACE_ALIAS, cparse_file, cparse_line, "Namespace alias '%s' not allowed here. Assuming '%s'\n",
				 (yyvsp[(2) - (3)].str), Getattr(h,"name"));
		    (yyvsp[(2) - (3)].str) = Getattr(h,"name");
		  }
		  Swig_symbol_setscope(Getattr(h,"symtab"));
		} else {
		  Swig_symbol_newscope();
		  Swig_symbol_setscopename((yyvsp[(2) - (3)].str));
		}
		Delete(Namespaceprefix);
		Namespaceprefix = Swig_symbol_qualifiedscopename(0);
             ;}
    break;

  case 162:

/* Line 1455 of yacc.c  */
#line 4290 "parser.y"
    {
                Node *n = (yyvsp[(5) - (6)].node);
		set_nodeType(n,"namespace");
		Setattr(n,"name",(yyvsp[(2) - (6)].str));
                Setattr(n,"symtab", Swig_symbol_popscope());
		Swig_symbol_setscope((yyvsp[(1) - (6)].node));
		(yyval.node) = n;
		Delete(Namespaceprefix);
		Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		add_symbols((yyval.node));
             ;}
    break;

  case 163:

/* Line 1455 of yacc.c  */
#line 4301 "parser.y"
    {
	       Hash *h;
	       (yyvsp[(1) - (2)].node) = Swig_symbol_current();
	       h = Swig_symbol_clookup((char *)"    ",0);
	       if (h && (Strcmp(nodeType(h),"namespace") == 0)) {
		 Swig_symbol_setscope(Getattr(h,"symtab"));
	       } else {
		 Swig_symbol_newscope();
		 /* we don't use "__unnamed__", but a long 'empty' name */
		 Swig_symbol_setscopename("    ");
	       }
	       Namespaceprefix = 0;
             ;}
    break;

  case 164:

/* Line 1455 of yacc.c  */
#line 4313 "parser.y"
    {
	       (yyval.node) = (yyvsp[(4) - (5)].node);
	       set_nodeType((yyval.node),"namespace");
	       Setattr((yyval.node),"unnamed","1");
	       Setattr((yyval.node),"symtab", Swig_symbol_popscope());
	       Swig_symbol_setscope((yyvsp[(1) - (5)].node));
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols((yyval.node));
             ;}
    break;

  case 165:

/* Line 1455 of yacc.c  */
#line 4323 "parser.y"
    {
	       /* Namespace alias */
	       Node *n;
	       (yyval.node) = new_node("namespace");
	       Setattr((yyval.node),"name",(yyvsp[(2) - (5)].id));
	       Setattr((yyval.node),"alias",(yyvsp[(4) - (5)].str));
	       n = Swig_symbol_clookup((yyvsp[(4) - (5)].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Unknown namespace '%s'\n", (yyvsp[(4) - (5)].str));
		 (yyval.node) = 0;
	       } else {
		 if (Strcmp(nodeType(n),"namespace") != 0) {
		   Swig_error(cparse_file, cparse_line, "'%s' is not a namespace\n",(yyvsp[(4) - (5)].str));
		   (yyval.node) = 0;
		 } else {
		   while (Getattr(n,"alias")) {
		     n = Getattr(n,"namespace");
		   }
		   Setattr((yyval.node),"namespace",n);
		   add_symbols((yyval.node));
		   /* Set up a scope alias */
		   Swig_symbol_alias((yyvsp[(2) - (5)].id),Getattr(n,"symtab"));
		 }
	       }
             ;}
    break;

  case 166:

/* Line 1455 of yacc.c  */
#line 4350 "parser.y"
    {
                   (yyval.node) = (yyvsp[(1) - (2)].node);
                   /* Insert cpp_member (including any siblings) to the front of the cpp_members linked list */
		   if ((yyval.node)) {
		     Node *p = (yyval.node);
		     Node *pp =0;
		     while (p) {
		       pp = p;
		       p = nextSibling(p);
		     }
		     set_nextSibling(pp,(yyvsp[(2) - (2)].node));
		   } else {
		     (yyval.node) = (yyvsp[(2) - (2)].node);
		   }
             ;}
    break;

  case 167:

/* Line 1455 of yacc.c  */
#line 4365 "parser.y"
    { 
                  if (cplus_mode != CPLUS_PUBLIC) {
		     Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
		  }
             ;}
    break;

  case 168:

/* Line 1455 of yacc.c  */
#line 4369 "parser.y"
    {
	       (yyval.node) = new_node("extend");
	       tag_nodes((yyvsp[(4) - (6)].node),"feature:extend",(char*) "1");
	       appendChild((yyval.node),(yyvsp[(4) - (6)].node));
	       set_nextSibling((yyval.node),(yyvsp[(6) - (6)].node));
	     ;}
    break;

  case 169:

/* Line 1455 of yacc.c  */
#line 4375 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 170:

/* Line 1455 of yacc.c  */
#line 4376 "parser.y"
    { (yyval.node) = 0;;}
    break;

  case 171:

/* Line 1455 of yacc.c  */
#line 4377 "parser.y"
    {
	       int start_line = cparse_line;
	       skip_decl();
	       Swig_error(cparse_file,start_line,"Syntax error in input(3).\n");
	       exit(1);
	       ;}
    break;

  case 172:

/* Line 1455 of yacc.c  */
#line 4382 "parser.y"
    { 
		 (yyval.node) = (yyvsp[(3) - (3)].node);
   	     ;}
    break;

  case 173:

/* Line 1455 of yacc.c  */
#line 4393 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 174:

/* Line 1455 of yacc.c  */
#line 4394 "parser.y"
    { 
                 (yyval.node) = (yyvsp[(1) - (1)].node); 
		 if (extendmode) {
		   String *symname;
		   symname= make_name((yyval.node),Getattr((yyval.node),"name"), Getattr((yyval.node),"decl"));
		   if (Strcmp(symname,Getattr((yyval.node),"name")) == 0) {
		     /* No renaming operation.  Set name to class name */
		     Delete(yyrename);
		     yyrename = NewString(Getattr(current_class,"sym:name"));
		   } else {
		     Delete(yyrename);
		     yyrename = symname;
		   }
		 }
		 add_symbols((yyval.node));
                 default_arguments((yyval.node));
             ;}
    break;

  case 175:

/* Line 1455 of yacc.c  */
#line 4411 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 176:

/* Line 1455 of yacc.c  */
#line 4412 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 177:

/* Line 1455 of yacc.c  */
#line 4413 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 178:

/* Line 1455 of yacc.c  */
#line 4414 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 179:

/* Line 1455 of yacc.c  */
#line 4415 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 180:

/* Line 1455 of yacc.c  */
#line 4416 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 181:

/* Line 1455 of yacc.c  */
#line 4417 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 182:

/* Line 1455 of yacc.c  */
#line 4418 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 183:

/* Line 1455 of yacc.c  */
#line 4419 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 184:

/* Line 1455 of yacc.c  */
#line 4420 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 185:

/* Line 1455 of yacc.c  */
#line 4421 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 186:

/* Line 1455 of yacc.c  */
#line 4422 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 187:

/* Line 1455 of yacc.c  */
#line 4423 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 188:

/* Line 1455 of yacc.c  */
#line 4424 "parser.y"
    {(yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 189:

/* Line 1455 of yacc.c  */
#line 4425 "parser.y"
    {(yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 190:

/* Line 1455 of yacc.c  */
#line 4426 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 191:

/* Line 1455 of yacc.c  */
#line 4435 "parser.y"
    {
              if (Classprefix) {
		 SwigType *decl = NewStringEmpty();
		 (yyval.node) = new_node("constructor");
		 Setattr((yyval.node),"storage",(yyvsp[(1) - (6)].id));
		 Setattr((yyval.node),"name",(yyvsp[(2) - (6)].type));
		 Setattr((yyval.node),"parms",(yyvsp[(4) - (6)].pl));
		 SwigType_add_function(decl,(yyvsp[(4) - (6)].pl));
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"throws",(yyvsp[(6) - (6)].decl).throws);
		 Setattr((yyval.node),"throw",(yyvsp[(6) - (6)].decl).throwf);
		 if (Len(scanner_ccode)) {
		   String *code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code",code);
		   Delete(code);
		 }
		 SetFlag((yyval.node),"feature:new");
	      } else {
		(yyval.node) = 0;
              }
              ;}
    break;

  case 192:

/* Line 1455 of yacc.c  */
#line 4460 "parser.y"
    {
               String *name = NewStringf("%s",(yyvsp[(2) - (6)].str));
	       if (*(Char(name)) != '~') Insert(name,0,"~");
               (yyval.node) = new_node("destructor");
	       Setattr((yyval.node),"name",name);
	       Delete(name);
	       if (Len(scanner_ccode)) {
		 String *code = Copy(scanner_ccode);
		 Setattr((yyval.node),"code",code);
		 Delete(code);
	       }
	       {
		 String *decl = NewStringEmpty();
		 SwigType_add_function(decl,(yyvsp[(4) - (6)].pl));
		 Setattr((yyval.node),"decl",decl);
		 Delete(decl);
	       }
	       Setattr((yyval.node),"throws",(yyvsp[(6) - (6)].dtype).throws);
	       Setattr((yyval.node),"throw",(yyvsp[(6) - (6)].dtype).throwf);
	       add_symbols((yyval.node));
	      ;}
    break;

  case 193:

/* Line 1455 of yacc.c  */
#line 4484 "parser.y"
    {
		String *name;
		(yyval.node) = new_node("destructor");
		Setattr((yyval.node),"storage","virtual");
	        name = NewStringf("%s",(yyvsp[(3) - (7)].str));
		if (*(Char(name)) != '~') Insert(name,0,"~");
		Setattr((yyval.node),"name",name);
		Delete(name);
		Setattr((yyval.node),"throws",(yyvsp[(7) - (7)].dtype).throws);
		Setattr((yyval.node),"throw",(yyvsp[(7) - (7)].dtype).throwf);
		if ((yyvsp[(7) - (7)].dtype).val) {
		  Setattr((yyval.node),"value","0");
		}
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
		{
		  String *decl = NewStringEmpty();
		  SwigType_add_function(decl,(yyvsp[(5) - (7)].pl));
		  Setattr((yyval.node),"decl",decl);
		  Delete(decl);
		}

		add_symbols((yyval.node));
	      ;}
    break;

  case 194:

/* Line 1455 of yacc.c  */
#line 4515 "parser.y"
    {
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[(3) - (8)].type));
		 Setattr((yyval.node),"name",(yyvsp[(2) - (8)].str));
		 Setattr((yyval.node),"storage",(yyvsp[(1) - (8)].id));

		 SwigType_add_function((yyvsp[(4) - (8)].type),(yyvsp[(6) - (8)].pl));
		 if ((yyvsp[(8) - (8)].dtype).qualifier) {
		   SwigType_push((yyvsp[(4) - (8)].type),(yyvsp[(8) - (8)].dtype).qualifier);
		 }
		 Setattr((yyval.node),"decl",(yyvsp[(4) - (8)].type));
		 Setattr((yyval.node),"parms",(yyvsp[(6) - (8)].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
              ;}
    break;

  case 195:

/* Line 1455 of yacc.c  */
#line 4530 "parser.y"
    {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[(3) - (8)].type));
		 Setattr((yyval.node),"name",(yyvsp[(2) - (8)].str));
		 Setattr((yyval.node),"storage",(yyvsp[(1) - (8)].id));
		 decl = NewStringEmpty();
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[(6) - (8)].pl));
		 if ((yyvsp[(8) - (8)].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[(8) - (8)].dtype).qualifier);
		 }
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[(6) - (8)].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
	       ;}
    break;

  case 196:

/* Line 1455 of yacc.c  */
#line 4548 "parser.y"
    {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[(3) - (9)].type));
		 Setattr((yyval.node),"name",(yyvsp[(2) - (9)].str));
		 Setattr((yyval.node),"storage",(yyvsp[(1) - (9)].id));
		 decl = NewStringEmpty();
		 SwigType_add_pointer(decl);
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[(7) - (9)].pl));
		 if ((yyvsp[(9) - (9)].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[(9) - (9)].dtype).qualifier);
		 }
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[(7) - (9)].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
	       ;}
    break;

  case 197:

/* Line 1455 of yacc.c  */
#line 4567 "parser.y"
    {
		String *t = NewStringEmpty();
		(yyval.node) = new_node("cdecl");
		Setattr((yyval.node),"type",(yyvsp[(3) - (7)].type));
		Setattr((yyval.node),"name",(yyvsp[(2) - (7)].str));
		 Setattr((yyval.node),"storage",(yyvsp[(1) - (7)].id));
		SwigType_add_function(t,(yyvsp[(5) - (7)].pl));
		if ((yyvsp[(7) - (7)].dtype).qualifier) {
		  SwigType_push(t,(yyvsp[(7) - (7)].dtype).qualifier);
		}
		Setattr((yyval.node),"decl",t);
		Setattr((yyval.node),"parms",(yyvsp[(5) - (7)].pl));
		Setattr((yyval.node),"conversion_operator","1");
		add_symbols((yyval.node));
              ;}
    break;

  case 198:

/* Line 1455 of yacc.c  */
#line 4586 "parser.y"
    {
                 skip_balanced('{','}');
                 (yyval.node) = 0;
               ;}
    break;

  case 199:

/* Line 1455 of yacc.c  */
#line 4593 "parser.y"
    { 
                (yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              ;}
    break;

  case 200:

/* Line 1455 of yacc.c  */
#line 4600 "parser.y"
    { 
                (yyval.node) = new_node("access");
                Setattr((yyval.node),"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      ;}
    break;

  case 201:

/* Line 1455 of yacc.c  */
#line 4608 "parser.y"
    { 
		(yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      ;}
    break;

  case 202:

/* Line 1455 of yacc.c  */
#line 4629 "parser.y"
    {
		cparse_start_line = cparse_line;
		skip_balanced('{','}');
		(yyval.str) = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      ;}
    break;

  case 203:

/* Line 1455 of yacc.c  */
#line 4633 "parser.y"
    {
	        (yyval.node) = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    String *name = Copy((yyvsp[(3) - (7)].str));
		    (yyval.node) = nested_forward_declaration((yyvsp[(1) - (7)].id), (yyvsp[(2) - (7)].id), (yyvsp[(3) - (7)].str), name, (yyvsp[(7) - (7)].node));
		  } else if ((yyvsp[(7) - (7)].node)) {
		    nested_new_struct((yyvsp[(2) - (7)].id), (yyvsp[(6) - (7)].str), (yyvsp[(7) - (7)].node));
		  }
		}
		Delete((yyvsp[(6) - (7)].str));
	      ;}
    break;

  case 204:

/* Line 1455 of yacc.c  */
#line 4656 "parser.y"
    {
		cparse_start_line = cparse_line;
		skip_balanced('{','}');
		(yyval.str) = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      ;}
    break;

  case 205:

/* Line 1455 of yacc.c  */
#line 4660 "parser.y"
    {
	        (yyval.node) = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    String *name = (yyvsp[(6) - (6)].node) ? Copy(Getattr((yyvsp[(6) - (6)].node), "name")) : 0;
		    (yyval.node) = nested_forward_declaration((yyvsp[(1) - (6)].id), (yyvsp[(2) - (6)].id), 0, name, (yyvsp[(6) - (6)].node));
		  } else {
		    if ((yyvsp[(6) - (6)].node)) {
		      nested_new_struct((yyvsp[(2) - (6)].id), (yyvsp[(5) - (6)].str), (yyvsp[(6) - (6)].node));
		    } else {
		      Swig_warning(WARN_PARSE_UNNAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (ignored).\n", (yyvsp[(2) - (6)].id));
		    }
		  }
		}
		Delete((yyvsp[(5) - (6)].str));
	      ;}
    break;

  case 206:

/* Line 1455 of yacc.c  */
#line 4692 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 207:

/* Line 1455 of yacc.c  */
#line 4695 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 208:

/* Line 1455 of yacc.c  */
#line 4699 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 209:

/* Line 1455 of yacc.c  */
#line 4702 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 210:

/* Line 1455 of yacc.c  */
#line 4703 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 211:

/* Line 1455 of yacc.c  */
#line 4704 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 212:

/* Line 1455 of yacc.c  */
#line 4705 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 213:

/* Line 1455 of yacc.c  */
#line 4706 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 214:

/* Line 1455 of yacc.c  */
#line 4707 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 215:

/* Line 1455 of yacc.c  */
#line 4708 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 216:

/* Line 1455 of yacc.c  */
#line 4709 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 217:

/* Line 1455 of yacc.c  */
#line 4712 "parser.y"
    {
	            Clear(scanner_ccode);
		    (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws;
		    (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf;
               ;}
    break;

  case 218:

/* Line 1455 of yacc.c  */
#line 4717 "parser.y"
    { 
		    skip_balanced('{','}'); 
		    (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws;
		    (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf;
	       ;}
    break;

  case 219:

/* Line 1455 of yacc.c  */
#line 4724 "parser.y"
    { 
                     Clear(scanner_ccode);
                     (yyval.dtype).val = 0;
                     (yyval.dtype).qualifier = (yyvsp[(1) - (2)].dtype).qualifier;
                     (yyval.dtype).bitfield = 0;
                     (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws;
                     (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf;
                ;}
    break;

  case 220:

/* Line 1455 of yacc.c  */
#line 4732 "parser.y"
    { 
                     Clear(scanner_ccode);
                     (yyval.dtype).val = (yyvsp[(3) - (4)].dtype).val;
                     (yyval.dtype).qualifier = (yyvsp[(1) - (4)].dtype).qualifier;
                     (yyval.dtype).bitfield = 0;
                     (yyval.dtype).throws = (yyvsp[(1) - (4)].dtype).throws; 
                     (yyval.dtype).throwf = (yyvsp[(1) - (4)].dtype).throwf; 
               ;}
    break;

  case 221:

/* Line 1455 of yacc.c  */
#line 4740 "parser.y"
    { 
                     skip_balanced('{','}');
                     (yyval.dtype).val = 0;
                     (yyval.dtype).qualifier = (yyvsp[(1) - (2)].dtype).qualifier;
                     (yyval.dtype).bitfield = 0;
                     (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws; 
                     (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf; 
               ;}
    break;

  case 222:

/* Line 1455 of yacc.c  */
#line 4751 "parser.y"
    { ;}
    break;

  case 223:

/* Line 1455 of yacc.c  */
#line 4757 "parser.y"
    { (yyval.id) = "extern"; ;}
    break;

  case 224:

/* Line 1455 of yacc.c  */
#line 4758 "parser.y"
    { 
                   if (strcmp((yyvsp[(2) - (2)].id),"C") == 0) {
		     (yyval.id) = "externc";
		   } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[(2) - (2)].id));
		     (yyval.id) = 0;
		   }
               ;}
    break;

  case 225:

/* Line 1455 of yacc.c  */
#line 4766 "parser.y"
    { (yyval.id) = "static"; ;}
    break;

  case 226:

/* Line 1455 of yacc.c  */
#line 4767 "parser.y"
    { (yyval.id) = "typedef"; ;}
    break;

  case 227:

/* Line 1455 of yacc.c  */
#line 4768 "parser.y"
    { (yyval.id) = "virtual"; ;}
    break;

  case 228:

/* Line 1455 of yacc.c  */
#line 4769 "parser.y"
    { (yyval.id) = "friend"; ;}
    break;

  case 229:

/* Line 1455 of yacc.c  */
#line 4770 "parser.y"
    { (yyval.id) = "explicit"; ;}
    break;

  case 230:

/* Line 1455 of yacc.c  */
#line 4771 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 231:

/* Line 1455 of yacc.c  */
#line 4778 "parser.y"
    {
                 Parm *p;
		 (yyval.pl) = (yyvsp[(1) - (1)].pl);
		 p = (yyvsp[(1) - (1)].pl);
                 while (p) {
		   Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   p = nextSibling(p);
                 }
               ;}
    break;

  case 232:

/* Line 1455 of yacc.c  */
#line 4789 "parser.y"
    {
                  set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].pl));
                  (yyval.pl) = (yyvsp[(1) - (2)].p);
		;}
    break;

  case 233:

/* Line 1455 of yacc.c  */
#line 4793 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 234:

/* Line 1455 of yacc.c  */
#line 4796 "parser.y"
    {
                 set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].pl));
		 (yyval.pl) = (yyvsp[(2) - (3)].p);
                ;}
    break;

  case 235:

/* Line 1455 of yacc.c  */
#line 4800 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 236:

/* Line 1455 of yacc.c  */
#line 4804 "parser.y"
    {
                   SwigType_push((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).type);
		   (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).id);
		   Setfile((yyval.p),cparse_file);
		   Setline((yyval.p),cparse_line);
		   if ((yyvsp[(2) - (2)].decl).defarg) {
		     Setattr((yyval.p),"value",(yyvsp[(2) - (2)].decl).defarg);
		   }
		;}
    break;

  case 237:

/* Line 1455 of yacc.c  */
#line 4814 "parser.y"
    {
                  (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template<class> %s %s", (yyvsp[(5) - (7)].id),(yyvsp[(6) - (7)].str)), 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
                  if ((yyvsp[(7) - (7)].dtype).val) {
                    Setattr((yyval.p),"value",(yyvsp[(7) - (7)].dtype).val);
                  }
                ;}
    break;

  case 238:

/* Line 1455 of yacc.c  */
#line 4822 "parser.y"
    {
		  SwigType *t = NewString("v(...)");
		  (yyval.p) = NewParmWithoutFileLineInfo(t, 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		;}
    break;

  case 239:

/* Line 1455 of yacc.c  */
#line 4830 "parser.y"
    {
                 Parm *p;
		 (yyval.p) = (yyvsp[(1) - (1)].p);
		 p = (yyvsp[(1) - (1)].p);
                 while (p) {
		   if (Getattr(p,"type")) {
		     Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   }
		   p = nextSibling(p);
                 }
               ;}
    break;

  case 240:

/* Line 1455 of yacc.c  */
#line 4843 "parser.y"
    {
                  set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].p));
                  (yyval.p) = (yyvsp[(1) - (2)].p);
		;}
    break;

  case 241:

/* Line 1455 of yacc.c  */
#line 4847 "parser.y"
    { (yyval.p) = 0; ;}
    break;

  case 242:

/* Line 1455 of yacc.c  */
#line 4850 "parser.y"
    {
                 set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].p));
		 (yyval.p) = (yyvsp[(2) - (3)].p);
                ;}
    break;

  case 243:

/* Line 1455 of yacc.c  */
#line 4854 "parser.y"
    { (yyval.p) = 0; ;}
    break;

  case 244:

/* Line 1455 of yacc.c  */
#line 4858 "parser.y"
    {
		  (yyval.p) = (yyvsp[(1) - (1)].p);
		  {
		    /* We need to make a possible adjustment for integer parameters. */
		    SwigType *type;
		    Node     *n = 0;

		    while (!n) {
		      type = Getattr((yyvsp[(1) - (1)].p),"type");
		      n = Swig_symbol_clookup(type,0);     /* See if we can find a node that matches the typename */
		      if ((n) && (Strcmp(nodeType(n),"cdecl") == 0)) {
			SwigType *decl = Getattr(n,"decl");
			if (!SwigType_isfunction(decl)) {
			  String *value = Getattr(n,"value");
			  if (value) {
			    String *v = Copy(value);
			    Setattr((yyvsp[(1) - (1)].p),"type",v);
			    Delete(v);
			    n = 0;
			  }
			}
		      } else {
			break;
		      }
		    }
		  }

               ;}
    break;

  case 245:

/* Line 1455 of yacc.c  */
#line 4886 "parser.y"
    {
                  (yyval.p) = NewParmWithoutFileLineInfo(0,0);
                  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		  Setattr((yyval.p),"value",(yyvsp[(1) - (1)].dtype).val);
               ;}
    break;

  case 246:

/* Line 1455 of yacc.c  */
#line 4894 "parser.y"
    { 
                  (yyval.dtype) = (yyvsp[(2) - (2)].dtype); 
		  if ((yyvsp[(2) - (2)].dtype).type == T_ERROR) {
		    Swig_warning(WARN_PARSE_BAD_DEFAULT,cparse_file, cparse_line, "Can't set default argument (ignored)\n");
		    (yyval.dtype).val = 0;
		    (yyval.dtype).rawval = 0;
		    (yyval.dtype).bitfield = 0;
		    (yyval.dtype).throws = 0;
		    (yyval.dtype).throwf = 0;
		  }
               ;}
    break;

  case 247:

/* Line 1455 of yacc.c  */
#line 4905 "parser.y"
    { 
		  (yyval.dtype) = (yyvsp[(2) - (5)].dtype);
		  if ((yyvsp[(2) - (5)].dtype).type == T_ERROR) {
		    Swig_warning(WARN_PARSE_BAD_DEFAULT,cparse_file, cparse_line, "Can't set default argument (ignored)\n");
		    (yyval.dtype) = (yyvsp[(2) - (5)].dtype);
		    (yyval.dtype).val = 0;
		    (yyval.dtype).rawval = 0;
		    (yyval.dtype).bitfield = 0;
		    (yyval.dtype).throws = 0;
		    (yyval.dtype).throwf = 0;
		  } else {
		    (yyval.dtype).val = NewStringf("%s[%s]",(yyvsp[(2) - (5)].dtype).val,(yyvsp[(4) - (5)].dtype).val); 
		  }		  
               ;}
    break;

  case 248:

/* Line 1455 of yacc.c  */
#line 4919 "parser.y"
    {
		 skip_balanced('{','}');
		 (yyval.dtype).val = 0;
		 (yyval.dtype).rawval = 0;
                 (yyval.dtype).type = T_INT;
		 (yyval.dtype).bitfield = 0;
		 (yyval.dtype).throws = 0;
		 (yyval.dtype).throwf = 0;
	       ;}
    break;

  case 249:

/* Line 1455 of yacc.c  */
#line 4928 "parser.y"
    { 
		 (yyval.dtype).val = 0;
		 (yyval.dtype).rawval = 0;
		 (yyval.dtype).type = 0;
		 (yyval.dtype).bitfield = (yyvsp[(2) - (2)].dtype).val;
		 (yyval.dtype).throws = 0;
		 (yyval.dtype).throwf = 0;
	       ;}
    break;

  case 250:

/* Line 1455 of yacc.c  */
#line 4936 "parser.y"
    {
                 (yyval.dtype).val = 0;
                 (yyval.dtype).rawval = 0;
                 (yyval.dtype).type = T_INT;
		 (yyval.dtype).bitfield = 0;
		 (yyval.dtype).throws = 0;
		 (yyval.dtype).throwf = 0;
               ;}
    break;

  case 251:

/* Line 1455 of yacc.c  */
#line 4946 "parser.y"
    {
                 (yyval.decl) = (yyvsp[(1) - (2)].decl);
		 (yyval.decl).defarg = (yyvsp[(2) - (2)].dtype).rawval ? (yyvsp[(2) - (2)].dtype).rawval : (yyvsp[(2) - (2)].dtype).val;
            ;}
    break;

  case 252:

/* Line 1455 of yacc.c  */
#line 4950 "parser.y"
    {
              (yyval.decl) = (yyvsp[(1) - (2)].decl);
	      (yyval.decl).defarg = (yyvsp[(2) - (2)].dtype).rawval ? (yyvsp[(2) - (2)].dtype).rawval : (yyvsp[(2) - (2)].dtype).val;
            ;}
    break;

  case 253:

/* Line 1455 of yacc.c  */
#line 4954 "parser.y"
    {
   	      (yyval.decl).type = 0;
              (yyval.decl).id = 0;
	      (yyval.decl).defarg = (yyvsp[(1) - (1)].dtype).rawval ? (yyvsp[(1) - (1)].dtype).rawval : (yyvsp[(1) - (1)].dtype).val;
            ;}
    break;

  case 254:

/* Line 1455 of yacc.c  */
#line 4961 "parser.y"
    {
                 (yyval.decl) = (yyvsp[(1) - (1)].decl);
		 if (SwigType_isfunction((yyvsp[(1) - (1)].decl).type)) {
		   Delete(SwigType_pop_function((yyvsp[(1) - (1)].decl).type));
		 } else if (SwigType_isarray((yyvsp[(1) - (1)].decl).type)) {
		   SwigType *ta = SwigType_pop_arrays((yyvsp[(1) - (1)].decl).type);
		   if (SwigType_isfunction((yyvsp[(1) - (1)].decl).type)) {
		     Delete(SwigType_pop_function((yyvsp[(1) - (1)].decl).type));
		   } else {
		     (yyval.decl).parms = 0;
		   }
		   SwigType_push((yyvsp[(1) - (1)].decl).type,ta);
		   Delete(ta);
		 } else {
		   (yyval.decl).parms = 0;
		 }
            ;}
    break;

  case 255:

/* Line 1455 of yacc.c  */
#line 4978 "parser.y"
    {
              (yyval.decl) = (yyvsp[(1) - (1)].decl);
	      if (SwigType_isfunction((yyvsp[(1) - (1)].decl).type)) {
		Delete(SwigType_pop_function((yyvsp[(1) - (1)].decl).type));
	      } else if (SwigType_isarray((yyvsp[(1) - (1)].decl).type)) {
		SwigType *ta = SwigType_pop_arrays((yyvsp[(1) - (1)].decl).type);
		if (SwigType_isfunction((yyvsp[(1) - (1)].decl).type)) {
		  Delete(SwigType_pop_function((yyvsp[(1) - (1)].decl).type));
		} else {
		  (yyval.decl).parms = 0;
		}
		SwigType_push((yyvsp[(1) - (1)].decl).type,ta);
		Delete(ta);
	      } else {
		(yyval.decl).parms = 0;
	      }
            ;}
    break;

  case 256:

/* Line 1455 of yacc.c  */
#line 4995 "parser.y"
    {
   	      (yyval.decl).type = 0;
              (yyval.decl).id = 0;
	      (yyval.decl).parms = 0;
	      ;}
    break;

  case 257:

/* Line 1455 of yacc.c  */
#line 5003 "parser.y"
    {
              (yyval.decl) = (yyvsp[(2) - (2)].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[(1) - (2)].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[(1) - (2)].type);
           ;}
    break;

  case 258:

/* Line 1455 of yacc.c  */
#line 5011 "parser.y"
    {
              (yyval.decl) = (yyvsp[(3) - (3)].decl);
	      SwigType_add_reference((yyvsp[(1) - (3)].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[(1) - (3)].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[(1) - (3)].type);
           ;}
    break;

  case 259:

/* Line 1455 of yacc.c  */
#line 5020 "parser.y"
    {
              (yyval.decl) = (yyvsp[(1) - (1)].decl);
	      if (!(yyval.decl).type) (yyval.decl).type = NewStringEmpty();
           ;}
    break;

  case 260:

/* Line 1455 of yacc.c  */
#line 5024 "parser.y"
    { 
	     (yyval.decl) = (yyvsp[(2) - (2)].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     if ((yyvsp[(2) - (2)].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[(2) - (2)].decl).type);
	       Delete((yyvsp[(2) - (2)].decl).type);
	     }
           ;}
    break;

  case 261:

/* Line 1455 of yacc.c  */
#line 5033 "parser.y"
    { 
	     SwigType *t = NewStringEmpty();

	     (yyval.decl) = (yyvsp[(3) - (3)].decl);
	     SwigType_add_memberpointer(t,(yyvsp[(1) - (3)].str));
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = t;
	     ;}
    break;

  case 262:

/* Line 1455 of yacc.c  */
#line 5044 "parser.y"
    { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[(4) - (4)].decl);
	     SwigType_add_memberpointer(t,(yyvsp[(2) - (4)].str));
	     SwigType_push((yyvsp[(1) - (4)].type),t);
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[(1) - (4)].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[(1) - (4)].type);
	     Delete(t);
	   ;}
    break;

  case 263:

/* Line 1455 of yacc.c  */
#line 5056 "parser.y"
    { 
	     (yyval.decl) = (yyvsp[(5) - (5)].decl);
	     SwigType_add_memberpointer((yyvsp[(1) - (5)].type),(yyvsp[(2) - (5)].str));
	     SwigType_add_reference((yyvsp[(1) - (5)].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[(1) - (5)].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[(1) - (5)].type);
	   ;}
    break;

  case 264:

/* Line 1455 of yacc.c  */
#line 5066 "parser.y"
    { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[(4) - (4)].decl);
	     SwigType_add_memberpointer(t,(yyvsp[(1) - (4)].str));
	     SwigType_add_reference(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   ;}
    break;

  case 265:

/* Line 1455 of yacc.c  */
#line 5079 "parser.y"
    {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
                 (yyval.decl).id = Char((yyvsp[(1) - (1)].str));
		 (yyval.decl).type = 0;
		 (yyval.decl).parms = 0;
		 (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 266:

/* Line 1455 of yacc.c  */
#line 5086 "parser.y"
    {
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[(2) - (2)].str)));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 267:

/* Line 1455 of yacc.c  */
#line 5094 "parser.y"
    {
                  (yyval.decl).id = Char((yyvsp[(2) - (3)].str));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 268:

/* Line 1455 of yacc.c  */
#line 5110 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(3) - (4)].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[(2) - (4)].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[(2) - (4)].type);
                  ;}
    break;

  case 269:

/* Line 1455 of yacc.c  */
#line 5118 "parser.y"
    {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(4) - (5)].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[(2) - (5)].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		    ;}
    break;

  case 270:

/* Line 1455 of yacc.c  */
#line 5129 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (3)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 271:

/* Line 1455 of yacc.c  */
#line 5140 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[(3) - (4)].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 272:

/* Line 1455 of yacc.c  */
#line 5151 "parser.y"
    {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[(3) - (4)].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[(3) - (4)].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  ;}
    break;

  case 273:

/* Line 1455 of yacc.c  */
#line 5170 "parser.y"
    {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
                 (yyval.decl).id = Char((yyvsp[(1) - (1)].str));
		 (yyval.decl).type = 0;
		 (yyval.decl).parms = 0;
		 (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 274:

/* Line 1455 of yacc.c  */
#line 5178 "parser.y"
    {
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[(2) - (2)].str)));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 275:

/* Line 1455 of yacc.c  */
#line 5195 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(3) - (4)].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[(2) - (4)].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[(2) - (4)].type);
                  ;}
    break;

  case 276:

/* Line 1455 of yacc.c  */
#line 5203 "parser.y"
    {
                    (yyval.decl) = (yyvsp[(3) - (4)].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_reference((yyval.decl).type);
                  ;}
    break;

  case 277:

/* Line 1455 of yacc.c  */
#line 5210 "parser.y"
    {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(4) - (5)].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[(2) - (5)].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		    ;}
    break;

  case 278:

/* Line 1455 of yacc.c  */
#line 5221 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (3)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 279:

/* Line 1455 of yacc.c  */
#line 5232 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[(3) - (4)].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 280:

/* Line 1455 of yacc.c  */
#line 5243 "parser.y"
    {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[(3) - (4)].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[(3) - (4)].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  ;}
    break;

  case 281:

/* Line 1455 of yacc.c  */
#line 5262 "parser.y"
    {
		    (yyval.decl).type = (yyvsp[(1) - (1)].type);
                    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 282:

/* Line 1455 of yacc.c  */
#line 5268 "parser.y"
    { 
                     (yyval.decl) = (yyvsp[(2) - (2)].decl);
                     SwigType_push((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).type);
		     (yyval.decl).type = (yyvsp[(1) - (2)].type);
		     Delete((yyvsp[(2) - (2)].decl).type);
                  ;}
    break;

  case 283:

/* Line 1455 of yacc.c  */
#line 5274 "parser.y"
    {
		    (yyval.decl).type = (yyvsp[(1) - (2)].type);
		    SwigType_add_reference((yyval.decl).type);
		    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
		  ;}
    break;

  case 284:

/* Line 1455 of yacc.c  */
#line 5281 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(3) - (3)].decl);
		    SwigType_add_reference((yyvsp[(1) - (3)].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[(1) - (3)].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[(1) - (3)].type);
                  ;}
    break;

  case 285:

/* Line 1455 of yacc.c  */
#line 5290 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(1) - (1)].decl);
                  ;}
    break;

  case 286:

/* Line 1455 of yacc.c  */
#line 5293 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(2) - (2)].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[(2) - (2)].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[(2) - (2)].decl).type);
		      Delete((yyvsp[(2) - (2)].decl).type);
		    }
                  ;}
    break;

  case 287:

/* Line 1455 of yacc.c  */
#line 5302 "parser.y"
    { 
                    (yyval.decl).id = 0;
                    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
                  ;}
    break;

  case 288:

/* Line 1455 of yacc.c  */
#line 5309 "parser.y"
    { 
		    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_memberpointer((yyval.decl).type,(yyvsp[(1) - (2)].str));
                    (yyval.decl).id = 0;
                    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
      	          ;}
    break;

  case 289:

/* Line 1455 of yacc.c  */
#line 5316 "parser.y"
    { 
		    SwigType *t = NewStringEmpty();
                    (yyval.decl).type = (yyvsp[(1) - (3)].type);
		    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
		    SwigType_add_memberpointer(t,(yyvsp[(2) - (3)].str));
		    SwigType_push((yyval.decl).type,t);
		    Delete(t);
                  ;}
    break;

  case 290:

/* Line 1455 of yacc.c  */
#line 5326 "parser.y"
    { 
		    (yyval.decl) = (yyvsp[(4) - (4)].decl);
		    SwigType_add_memberpointer((yyvsp[(1) - (4)].type),(yyvsp[(2) - (4)].str));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[(1) - (4)].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[(1) - (4)].type);
                  ;}
    break;

  case 291:

/* Line 1455 of yacc.c  */
#line 5337 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (3)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(char*)"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 292:

/* Line 1455 of yacc.c  */
#line 5348 "parser.y"
    { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[(3) - (4)].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  ;}
    break;

  case 293:

/* Line 1455 of yacc.c  */
#line 5359 "parser.y"
    { 
		    (yyval.decl).type = NewStringEmpty();
		    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
		    SwigType_add_array((yyval.decl).type,(char*)"");
                  ;}
    break;

  case 294:

/* Line 1455 of yacc.c  */
#line 5366 "parser.y"
    { 
		    (yyval.decl).type = NewStringEmpty();
		    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
		    SwigType_add_array((yyval.decl).type,(yyvsp[(2) - (3)].dtype).val);
		  ;}
    break;

  case 295:

/* Line 1455 of yacc.c  */
#line 5373 "parser.y"
    {
                    (yyval.decl) = (yyvsp[(2) - (3)].decl);
		  ;}
    break;

  case 296:

/* Line 1455 of yacc.c  */
#line 5376 "parser.y"
    {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[(1) - (4)].decl);
		    t = NewStringEmpty();
                    SwigType_add_function(t,(yyvsp[(3) - (4)].pl));
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[(3) - (4)].pl);
		      (yyval.decl).have_parms = 1;
		    }
		  ;}
    break;

  case 297:

/* Line 1455 of yacc.c  */
#line 5393 "parser.y"
    {
                    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_function((yyval.decl).type,(yyvsp[(2) - (3)].pl));
		    (yyval.decl).parms = (yyvsp[(2) - (3)].pl);
		    (yyval.decl).have_parms = 1;
		    (yyval.decl).id = 0;
                  ;}
    break;

  case 298:

/* Line 1455 of yacc.c  */
#line 5403 "parser.y"
    { 
             (yyval.type) = NewStringEmpty();
             SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[(2) - (3)].str));
	     SwigType_push((yyval.type),(yyvsp[(3) - (3)].type));
	     Delete((yyvsp[(3) - (3)].type));
           ;}
    break;

  case 299:

/* Line 1455 of yacc.c  */
#line 5410 "parser.y"
    {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[(2) - (2)].type));
	     Delete((yyvsp[(2) - (2)].type));
	   ;}
    break;

  case 300:

/* Line 1455 of yacc.c  */
#line 5416 "parser.y"
    { 
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[(2) - (2)].str));
           ;}
    break;

  case 301:

/* Line 1455 of yacc.c  */
#line 5421 "parser.y"
    {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
           ;}
    break;

  case 302:

/* Line 1455 of yacc.c  */
#line 5427 "parser.y"
    {
	          (yyval.str) = NewStringEmpty();
	          if ((yyvsp[(1) - (1)].id)) SwigType_add_qualifier((yyval.str),(yyvsp[(1) - (1)].id));
               ;}
    break;

  case 303:

/* Line 1455 of yacc.c  */
#line 5431 "parser.y"
    {
		  (yyval.str) = (yyvsp[(2) - (2)].str);
	          if ((yyvsp[(1) - (2)].id)) SwigType_add_qualifier((yyval.str),(yyvsp[(1) - (2)].id));
               ;}
    break;

  case 304:

/* Line 1455 of yacc.c  */
#line 5437 "parser.y"
    { (yyval.id) = "const"; ;}
    break;

  case 305:

/* Line 1455 of yacc.c  */
#line 5438 "parser.y"
    { (yyval.id) = "volatile"; ;}
    break;

  case 306:

/* Line 1455 of yacc.c  */
#line 5439 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 307:

/* Line 1455 of yacc.c  */
#line 5445 "parser.y"
    {
                   (yyval.type) = (yyvsp[(1) - (1)].type);
                   Replace((yyval.type),"typename ","", DOH_REPLACE_ANY);
                ;}
    break;

  case 308:

/* Line 1455 of yacc.c  */
#line 5451 "parser.y"
    {
                   (yyval.type) = (yyvsp[(2) - (2)].type);
	           SwigType_push((yyval.type),(yyvsp[(1) - (2)].str));
               ;}
    break;

  case 309:

/* Line 1455 of yacc.c  */
#line 5455 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 310:

/* Line 1455 of yacc.c  */
#line 5456 "parser.y"
    {
		  (yyval.type) = (yyvsp[(1) - (2)].type);
	          SwigType_push((yyval.type),(yyvsp[(2) - (2)].str));
	       ;}
    break;

  case 311:

/* Line 1455 of yacc.c  */
#line 5460 "parser.y"
    {
		  (yyval.type) = (yyvsp[(2) - (3)].type);
	          SwigType_push((yyval.type),(yyvsp[(3) - (3)].str));
	          SwigType_push((yyval.type),(yyvsp[(1) - (3)].str));
	       ;}
    break;

  case 312:

/* Line 1455 of yacc.c  */
#line 5467 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type);
                  /* Printf(stdout,"primitive = '%s'\n", $$);*/
               ;}
    break;

  case 313:

/* Line 1455 of yacc.c  */
#line 5470 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 314:

/* Line 1455 of yacc.c  */
#line 5471 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 315:

/* Line 1455 of yacc.c  */
#line 5472 "parser.y"
    { (yyval.type) = NewStringf("%s%s",(yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].id)); ;}
    break;

  case 316:

/* Line 1455 of yacc.c  */
#line 5473 "parser.y"
    { (yyval.type) = NewStringf("enum %s", (yyvsp[(2) - (2)].str)); ;}
    break;

  case 317:

/* Line 1455 of yacc.c  */
#line 5474 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 318:

/* Line 1455 of yacc.c  */
#line 5476 "parser.y"
    {
		  (yyval.type) = (yyvsp[(1) - (1)].str);
               ;}
    break;

  case 319:

/* Line 1455 of yacc.c  */
#line 5479 "parser.y"
    { 
		 (yyval.type) = NewStringf("%s %s", (yyvsp[(1) - (2)].id), (yyvsp[(2) - (2)].str));
               ;}
    break;

  case 320:

/* Line 1455 of yacc.c  */
#line 5484 "parser.y"
    {
		 if (!(yyvsp[(1) - (1)].ptype).type) (yyvsp[(1) - (1)].ptype).type = NewString("int");
		 if ((yyvsp[(1) - (1)].ptype).us) {
		   (yyval.type) = NewStringf("%s %s", (yyvsp[(1) - (1)].ptype).us, (yyvsp[(1) - (1)].ptype).type);
		   Delete((yyvsp[(1) - (1)].ptype).us);
                   Delete((yyvsp[(1) - (1)].ptype).type);
		 } else {
                   (yyval.type) = (yyvsp[(1) - (1)].ptype).type;
		 }
		 if (Cmp((yyval.type),"signed int") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("int");
                 } else if (Cmp((yyval.type),"signed long") == 0) {
		   Delete((yyval.type));
                   (yyval.type) = NewString("long");
                 } else if (Cmp((yyval.type),"signed short") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("short");
		 } else if (Cmp((yyval.type),"signed long long") == 0) {
		   Delete((yyval.type));
		   (yyval.type) = NewString("long long");
		 }
               ;}
    break;

  case 321:

/* Line 1455 of yacc.c  */
#line 5509 "parser.y"
    { 
                 (yyval.ptype) = (yyvsp[(1) - (1)].ptype);
               ;}
    break;

  case 322:

/* Line 1455 of yacc.c  */
#line 5512 "parser.y"
    {
                    if ((yyvsp[(1) - (2)].ptype).us && (yyvsp[(2) - (2)].ptype).us) {
		      Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[(2) - (2)].ptype).us);
		    }
                    (yyval.ptype) = (yyvsp[(2) - (2)].ptype);
                    if ((yyvsp[(1) - (2)].ptype).us) (yyval.ptype).us = (yyvsp[(1) - (2)].ptype).us;
		    if ((yyvsp[(1) - (2)].ptype).type) {
		      if (!(yyvsp[(2) - (2)].ptype).type) (yyval.ptype).type = (yyvsp[(1) - (2)].ptype).type;
		      else {
			int err = 0;
			if ((Cmp((yyvsp[(1) - (2)].ptype).type,"long") == 0)) {
			  if ((Cmp((yyvsp[(2) - (2)].ptype).type,"long") == 0) || (Strncmp((yyvsp[(2) - (2)].ptype).type,"double",6) == 0)) {
			    (yyval.ptype).type = NewStringf("long %s", (yyvsp[(2) - (2)].ptype).type);
			  } else if (Cmp((yyvsp[(2) - (2)].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[(1) - (2)].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if ((Cmp((yyvsp[(1) - (2)].ptype).type,"short")) == 0) {
			  if (Cmp((yyvsp[(2) - (2)].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[(1) - (2)].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[(1) - (2)].ptype).type,"int") == 0) {
			  (yyval.ptype).type = (yyvsp[(2) - (2)].ptype).type;
			} else if (Cmp((yyvsp[(1) - (2)].ptype).type,"double") == 0) {
			  if (Cmp((yyvsp[(2) - (2)].ptype).type,"long") == 0) {
			    (yyval.ptype).type = NewString("long double");
			  } else if (Cmp((yyvsp[(2) - (2)].ptype).type,"complex") == 0) {
			    (yyval.ptype).type = NewString("double complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[(1) - (2)].ptype).type,"float") == 0) {
			  if (Cmp((yyvsp[(2) - (2)].ptype).type,"complex") == 0) {
			    (yyval.ptype).type = NewString("float complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[(1) - (2)].ptype).type,"complex") == 0) {
			  (yyval.ptype).type = NewStringf("%s complex", (yyvsp[(2) - (2)].ptype).type);
			} else {
			  err = 1;
			}
			if (err) {
			  Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[(1) - (2)].ptype).type);
			}
		      }
		    }
               ;}
    break;

  case 323:

/* Line 1455 of yacc.c  */
#line 5566 "parser.y"
    { 
		    (yyval.ptype).type = NewString("int");
                    (yyval.ptype).us = 0;
               ;}
    break;

  case 324:

/* Line 1455 of yacc.c  */
#line 5570 "parser.y"
    { 
                    (yyval.ptype).type = NewString("short");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 325:

/* Line 1455 of yacc.c  */
#line 5574 "parser.y"
    { 
                    (yyval.ptype).type = NewString("long");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 326:

/* Line 1455 of yacc.c  */
#line 5578 "parser.y"
    { 
                    (yyval.ptype).type = NewString("char");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 327:

/* Line 1455 of yacc.c  */
#line 5582 "parser.y"
    { 
                    (yyval.ptype).type = NewString("wchar_t");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 328:

/* Line 1455 of yacc.c  */
#line 5586 "parser.y"
    { 
                    (yyval.ptype).type = NewString("float");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 329:

/* Line 1455 of yacc.c  */
#line 5590 "parser.y"
    { 
                    (yyval.ptype).type = NewString("double");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 330:

/* Line 1455 of yacc.c  */
#line 5594 "parser.y"
    { 
                    (yyval.ptype).us = NewString("signed");
                    (yyval.ptype).type = 0;
                ;}
    break;

  case 331:

/* Line 1455 of yacc.c  */
#line 5598 "parser.y"
    { 
                    (yyval.ptype).us = NewString("unsigned");
                    (yyval.ptype).type = 0;
                ;}
    break;

  case 332:

/* Line 1455 of yacc.c  */
#line 5602 "parser.y"
    { 
                    (yyval.ptype).type = NewString("complex");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 333:

/* Line 1455 of yacc.c  */
#line 5606 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int8");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 334:

/* Line 1455 of yacc.c  */
#line 5610 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int16");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 335:

/* Line 1455 of yacc.c  */
#line 5614 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int32");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 336:

/* Line 1455 of yacc.c  */
#line 5618 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int64");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 337:

/* Line 1455 of yacc.c  */
#line 5624 "parser.y"
    { /* scanner_check_typedef(); */ ;}
    break;

  case 338:

/* Line 1455 of yacc.c  */
#line 5624 "parser.y"
    {
                   (yyval.dtype) = (yyvsp[(2) - (2)].dtype);
		   if ((yyval.dtype).type == T_STRING) {
		     (yyval.dtype).rawval = NewStringf("\"%(escape)s\"",(yyval.dtype).val);
		   } else if ((yyval.dtype).type != T_CHAR) {
		     (yyval.dtype).rawval = 0;
		   }
		   (yyval.dtype).bitfield = 0;
		   (yyval.dtype).throws = 0;
		   (yyval.dtype).throwf = 0;
		   scanner_ignore_typedef();
                ;}
    break;

  case 339:

/* Line 1455 of yacc.c  */
#line 5650 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 340:

/* Line 1455 of yacc.c  */
#line 5651 "parser.y"
    { (yyval.id) = (char *) 0;;}
    break;

  case 341:

/* Line 1455 of yacc.c  */
#line 5654 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 342:

/* Line 1455 of yacc.c  */
#line 5655 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 343:

/* Line 1455 of yacc.c  */
#line 5659 "parser.y"
    {
		 Node *leftSibling = Getattr((yyvsp[(1) - (5)].node),"_last");
		 set_nextSibling(leftSibling,(yyvsp[(4) - (5)].node));
		 Setattr((yyvsp[(1) - (5)].node),"_last",(yyvsp[(4) - (5)].node));
		 (yyval.node) = (yyvsp[(1) - (5)].node);
	       ;}
    break;

  case 344:

/* Line 1455 of yacc.c  */
#line 5665 "parser.y"
    {
		 (yyval.node) = (yyvsp[(1) - (3)].node);
	       ;}
    break;

  case 345:

/* Line 1455 of yacc.c  */
#line 5668 "parser.y"
    {
		 Setattr((yyvsp[(2) - (3)].node),"_last",(yyvsp[(2) - (3)].node));
		 (yyval.node) = (yyvsp[(2) - (3)].node);
	       ;}
    break;

  case 346:

/* Line 1455 of yacc.c  */
#line 5672 "parser.y"
    {
		 (yyval.node) = 0;
	       ;}
    break;

  case 347:

/* Line 1455 of yacc.c  */
#line 5677 "parser.y"
    {
		   SwigType *type = NewSwigType(T_INT);
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[(1) - (1)].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Delete(type);
		 ;}
    break;

  case 348:

/* Line 1455 of yacc.c  */
#line 5685 "parser.y"
    {
		   SwigType *type = NewSwigType((yyvsp[(3) - (3)].dtype).type == T_BOOL ? T_BOOL : ((yyvsp[(3) - (3)].dtype).type == T_CHAR ? T_CHAR : T_INT));
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Setattr((yyval.node),"enumvalue", (yyvsp[(3) - (3)].dtype).val);
		   Setattr((yyval.node),"value",(yyvsp[(1) - (3)].id));
		   Delete(type);
                 ;}
    break;

  case 349:

/* Line 1455 of yacc.c  */
#line 5697 "parser.y"
    {
                   (yyval.dtype) = (yyvsp[(1) - (1)].dtype);
		   if (((yyval.dtype).type != T_INT) && ((yyval.dtype).type != T_UINT) &&
		       ((yyval.dtype).type != T_LONG) && ((yyval.dtype).type != T_ULONG) &&
		       ((yyval.dtype).type != T_LONGLONG) && ((yyval.dtype).type != T_ULONGLONG) &&
		       ((yyval.dtype).type != T_SHORT) && ((yyval.dtype).type != T_USHORT) &&
		       ((yyval.dtype).type != T_SCHAR) && ((yyval.dtype).type != T_UCHAR) &&
		       ((yyval.dtype).type != T_CHAR) && ((yyval.dtype).type != T_BOOL)) {
		     Swig_error(cparse_file,cparse_line,"Type error. Expecting an integral type\n");
		   }
                ;}
    break;

  case 350:

/* Line 1455 of yacc.c  */
#line 5712 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 351:

/* Line 1455 of yacc.c  */
#line 5713 "parser.y"
    {
		 Node *n;
		 (yyval.dtype).val = (yyvsp[(1) - (1)].type);
		 (yyval.dtype).type = T_INT;
		 /* Check if value is in scope */
		 n = Swig_symbol_clookup((yyvsp[(1) - (1)].type),0);
		 if (n) {
                   /* A band-aid for enum values used in expressions. */
                   if (Strcmp(nodeType(n),"enumitem") == 0) {
                     String *q = Swig_symbol_qualified(n);
                     if (q) {
                       (yyval.dtype).val = NewStringf("%s::%s", q, Getattr(n,"name"));
                       Delete(q);
                     }
                   }
		 }
               ;}
    break;

  case 352:

/* Line 1455 of yacc.c  */
#line 5732 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 353:

/* Line 1455 of yacc.c  */
#line 5733 "parser.y"
    {
		    (yyval.dtype).val = NewString((yyvsp[(1) - (1)].id));
                    (yyval.dtype).type = T_STRING;
               ;}
    break;

  case 354:

/* Line 1455 of yacc.c  */
#line 5737 "parser.y"
    {
		  SwigType_push((yyvsp[(3) - (5)].type),(yyvsp[(4) - (5)].decl).type);
		  (yyval.dtype).val = NewStringf("sizeof(%s)",SwigType_str((yyvsp[(3) - (5)].type),0));
		  (yyval.dtype).type = T_ULONG;
               ;}
    break;

  case 355:

/* Line 1455 of yacc.c  */
#line 5742 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 356:

/* Line 1455 of yacc.c  */
#line 5743 "parser.y"
    {
		  (yyval.dtype).val = NewString((yyvsp[(1) - (1)].str));
		  if (Len((yyval.dtype).val)) {
		    (yyval.dtype).rawval = NewStringf("'%(escape)s'", (yyval.dtype).val);
		  } else {
		    (yyval.dtype).rawval = NewString("'\\0'");
		  }
		  (yyval.dtype).type = T_CHAR;
		  (yyval.dtype).bitfield = 0;
		  (yyval.dtype).throws = 0;
		  (yyval.dtype).throwf = 0;
	       ;}
    break;

  case 357:

/* Line 1455 of yacc.c  */
#line 5757 "parser.y"
    {
   	            (yyval.dtype).val = NewStringf("(%s)",(yyvsp[(2) - (3)].dtype).val);
		    (yyval.dtype).type = (yyvsp[(2) - (3)].dtype).type;
   	       ;}
    break;

  case 358:

/* Line 1455 of yacc.c  */
#line 5764 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(4) - (4)].dtype);
		 if ((yyvsp[(4) - (4)].dtype).type != T_STRING) {
		   switch ((yyvsp[(2) - (4)].dtype).type) {
		     case T_FLOAT:
		     case T_DOUBLE:
		     case T_LONGDOUBLE:
		     case T_FLTCPLX:
		     case T_DBLCPLX:
		       (yyval.dtype).val = NewStringf("(%s)%s", (yyvsp[(2) - (4)].dtype).val, (yyvsp[(4) - (4)].dtype).val); /* SwigType_str and decimal points don't mix! */
		       break;
		     default:
		       (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (4)].dtype).val,0), (yyvsp[(4) - (4)].dtype).val);
		       break;
		   }
		 }
 	       ;}
    break;

  case 359:

/* Line 1455 of yacc.c  */
#line 5781 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(5) - (5)].dtype);
		 if ((yyvsp[(5) - (5)].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[(2) - (5)].dtype).val,(yyvsp[(3) - (5)].type));
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (5)].dtype).val,0), (yyvsp[(5) - (5)].dtype).val);
		 }
 	       ;}
    break;

  case 360:

/* Line 1455 of yacc.c  */
#line 5788 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(5) - (5)].dtype);
		 if ((yyvsp[(5) - (5)].dtype).type != T_STRING) {
		   SwigType_add_reference((yyvsp[(2) - (5)].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (5)].dtype).val,0), (yyvsp[(5) - (5)].dtype).val);
		 }
 	       ;}
    break;

  case 361:

/* Line 1455 of yacc.c  */
#line 5795 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(6) - (6)].dtype);
		 if ((yyvsp[(6) - (6)].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[(2) - (6)].dtype).val,(yyvsp[(3) - (6)].type));
		   SwigType_add_reference((yyvsp[(2) - (6)].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (6)].dtype).val,0), (yyvsp[(6) - (6)].dtype).val);
		 }
 	       ;}
    break;

  case 362:

/* Line 1455 of yacc.c  */
#line 5803 "parser.y"
    {
		 (yyval.dtype) = (yyvsp[(2) - (2)].dtype);
                 (yyval.dtype).val = NewStringf("&%s",(yyvsp[(2) - (2)].dtype).val);
	       ;}
    break;

  case 363:

/* Line 1455 of yacc.c  */
#line 5807 "parser.y"
    {
		 (yyval.dtype) = (yyvsp[(2) - (2)].dtype);
                 (yyval.dtype).val = NewStringf("*%s",(yyvsp[(2) - (2)].dtype).val);
	       ;}
    break;

  case 364:

/* Line 1455 of yacc.c  */
#line 5813 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 365:

/* Line 1455 of yacc.c  */
#line 5814 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 366:

/* Line 1455 of yacc.c  */
#line 5815 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 367:

/* Line 1455 of yacc.c  */
#line 5816 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 368:

/* Line 1455 of yacc.c  */
#line 5817 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 369:

/* Line 1455 of yacc.c  */
#line 5818 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 370:

/* Line 1455 of yacc.c  */
#line 5819 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 371:

/* Line 1455 of yacc.c  */
#line 5820 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 372:

/* Line 1455 of yacc.c  */
#line 5823 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s+%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 373:

/* Line 1455 of yacc.c  */
#line 5827 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s-%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 374:

/* Line 1455 of yacc.c  */
#line 5831 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s*%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 375:

/* Line 1455 of yacc.c  */
#line 5835 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s/%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 376:

/* Line 1455 of yacc.c  */
#line 5839 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s%%%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 377:

/* Line 1455 of yacc.c  */
#line 5843 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s&%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 378:

/* Line 1455 of yacc.c  */
#line 5847 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s|%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 379:

/* Line 1455 of yacc.c  */
#line 5851 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s^%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 380:

/* Line 1455 of yacc.c  */
#line 5855 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s << %s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[(1) - (3)].dtype).type);
	       ;}
    break;

  case 381:

/* Line 1455 of yacc.c  */
#line 5859 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s >> %s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[(1) - (3)].dtype).type);
	       ;}
    break;

  case 382:

/* Line 1455 of yacc.c  */
#line 5863 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s&&%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 383:

/* Line 1455 of yacc.c  */
#line 5867 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s||%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 384:

/* Line 1455 of yacc.c  */
#line 5871 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s==%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 385:

/* Line 1455 of yacc.c  */
#line 5875 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s!=%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 386:

/* Line 1455 of yacc.c  */
#line 5889 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s >= %s", (yyvsp[(1) - (3)].dtype).val, (yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 387:

/* Line 1455 of yacc.c  */
#line 5893 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s <= %s", (yyvsp[(1) - (3)].dtype).val, (yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 388:

/* Line 1455 of yacc.c  */
#line 5897 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s?%s:%s", (yyvsp[(1) - (5)].dtype).val, (yyvsp[(3) - (5)].dtype).val, (yyvsp[(5) - (5)].dtype).val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 (yyval.dtype).type = promote((yyvsp[(3) - (5)].dtype).type, (yyvsp[(5) - (5)].dtype).type);
	       ;}
    break;

  case 389:

/* Line 1455 of yacc.c  */
#line 5903 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("-%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 390:

/* Line 1455 of yacc.c  */
#line 5907 "parser.y"
    {
                 (yyval.dtype).val = NewStringf("+%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 391:

/* Line 1455 of yacc.c  */
#line 5911 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("~%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 392:

/* Line 1455 of yacc.c  */
#line 5915 "parser.y"
    {
                 (yyval.dtype).val = NewStringf("!%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = T_INT;
	       ;}
    break;

  case 393:

/* Line 1455 of yacc.c  */
#line 5919 "parser.y"
    {
		 String *qty;
                 skip_balanced('(',')');
		 qty = Swig_symbol_type_qualify((yyvsp[(1) - (2)].type),0);
		 if (SwigType_istemplate(qty)) {
		   String *nstr = SwigType_namestr(qty);
		   Delete(qty);
		   qty = nstr;
		 }
		 (yyval.dtype).val = NewStringf("%s%s",qty,scanner_ccode);
		 Clear(scanner_ccode);
		 (yyval.dtype).type = T_INT;
		 Delete(qty);
               ;}
    break;

  case 394:

/* Line 1455 of yacc.c  */
#line 5935 "parser.y"
    {
		 (yyval.bases) = (yyvsp[(1) - (1)].bases);
               ;}
    break;

  case 395:

/* Line 1455 of yacc.c  */
#line 5940 "parser.y"
    { inherit_list = 1; ;}
    break;

  case 396:

/* Line 1455 of yacc.c  */
#line 5940 "parser.y"
    { (yyval.bases) = (yyvsp[(3) - (3)].bases); inherit_list = 0; ;}
    break;

  case 397:

/* Line 1455 of yacc.c  */
#line 5941 "parser.y"
    { (yyval.bases) = 0; ;}
    break;

  case 398:

/* Line 1455 of yacc.c  */
#line 5944 "parser.y"
    {
		   Hash *list = NewHash();
		   Node *base = (yyvsp[(1) - (1)].node);
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
	           (yyval.bases) = list;
               ;}
    break;

  case 399:

/* Line 1455 of yacc.c  */
#line 5961 "parser.y"
    {
		   Hash *list = (yyvsp[(1) - (3)].bases);
		   Node *base = (yyvsp[(3) - (3)].node);
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
                   (yyval.bases) = list;
               ;}
    break;

  case 400:

/* Line 1455 of yacc.c  */
#line 5970 "parser.y"
    {
		 (yyval.intvalue) = cparse_line;
	       ;}
    break;

  case 401:

/* Line 1455 of yacc.c  */
#line 5972 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node),cparse_file);
		 Setline((yyval.node),(yyvsp[(2) - (3)].intvalue));
		 Setattr((yyval.node),"name",(yyvsp[(3) - (3)].str));
		 Setfile((yyvsp[(3) - (3)].str),cparse_file);
		 Setline((yyvsp[(3) - (3)].str),(yyvsp[(2) - (3)].intvalue));
                 if (last_cpptype && (Strcmp(last_cpptype,"struct") != 0)) {
		   Setattr((yyval.node),"access","private");
		   Swig_warning(WARN_PARSE_NO_ACCESS, Getfile((yyval.node)), Getline((yyval.node)), "No access specifier given for base class '%s' (ignored).\n", SwigType_namestr((yyvsp[(3) - (3)].str)));
                 } else {
		   Setattr((yyval.node),"access","public");
		 }
               ;}
    break;

  case 402:

/* Line 1455 of yacc.c  */
#line 5986 "parser.y"
    {
		 (yyval.intvalue) = cparse_line;
	       ;}
    break;

  case 403:

/* Line 1455 of yacc.c  */
#line 5988 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node),cparse_file);
		 Setline((yyval.node),(yyvsp[(3) - (5)].intvalue));
		 Setattr((yyval.node),"name",(yyvsp[(5) - (5)].str));
		 Setfile((yyvsp[(5) - (5)].str),cparse_file);
		 Setline((yyvsp[(5) - (5)].str),(yyvsp[(3) - (5)].intvalue));
		 Setattr((yyval.node),"access",(yyvsp[(2) - (5)].id));
	         if (Strcmp((yyvsp[(2) - (5)].id),"public") != 0) {
		   Swig_warning(WARN_PARSE_PRIVATE_INHERIT, Getfile((yyval.node)), Getline((yyval.node)), "%s inheritance from base '%s' (ignored).\n", (yyvsp[(2) - (5)].id), SwigType_namestr((yyvsp[(5) - (5)].str)));
		 }
               ;}
    break;

  case 404:

/* Line 1455 of yacc.c  */
#line 6002 "parser.y"
    { (yyval.id) = (char*)"public"; ;}
    break;

  case 405:

/* Line 1455 of yacc.c  */
#line 6003 "parser.y"
    { (yyval.id) = (char*)"private"; ;}
    break;

  case 406:

/* Line 1455 of yacc.c  */
#line 6004 "parser.y"
    { (yyval.id) = (char*)"protected"; ;}
    break;

  case 407:

/* Line 1455 of yacc.c  */
#line 6008 "parser.y"
    { 
                   (yyval.id) = (char*)"class"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 408:

/* Line 1455 of yacc.c  */
#line 6012 "parser.y"
    { 
                   (yyval.id) = (char *)"typename"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 409:

/* Line 1455 of yacc.c  */
#line 6018 "parser.y"
    {
                 (yyval.id) = (yyvsp[(1) - (1)].id);
               ;}
    break;

  case 410:

/* Line 1455 of yacc.c  */
#line 6021 "parser.y"
    { 
                   (yyval.id) = (char*)"struct"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 411:

/* Line 1455 of yacc.c  */
#line 6025 "parser.y"
    {
                   (yyval.id) = (char*)"union"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 414:

/* Line 1455 of yacc.c  */
#line 6035 "parser.y"
    {
                    (yyval.dtype).qualifier = (yyvsp[(1) - (1)].str);
                    (yyval.dtype).throws = 0;
                    (yyval.dtype).throwf = 0;
               ;}
    break;

  case 415:

/* Line 1455 of yacc.c  */
#line 6040 "parser.y"
    {
                    (yyval.dtype).qualifier = 0;
                    (yyval.dtype).throws = (yyvsp[(3) - (4)].pl);
                    (yyval.dtype).throwf = NewString("1");
               ;}
    break;

  case 416:

/* Line 1455 of yacc.c  */
#line 6045 "parser.y"
    {
                    (yyval.dtype).qualifier = (yyvsp[(1) - (5)].str);
                    (yyval.dtype).throws = (yyvsp[(4) - (5)].pl);
                    (yyval.dtype).throwf = NewString("1");
               ;}
    break;

  case 417:

/* Line 1455 of yacc.c  */
#line 6050 "parser.y"
    { 
                    (yyval.dtype).qualifier = 0; 
                    (yyval.dtype).throws = 0;
                    (yyval.dtype).throwf = 0;
               ;}
    break;

  case 418:

/* Line 1455 of yacc.c  */
#line 6057 "parser.y"
    { 
                    Clear(scanner_ccode); 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = 0; 
		    (yyval.decl).throws = (yyvsp[(1) - (3)].dtype).throws;
		    (yyval.decl).throwf = (yyvsp[(1) - (3)].dtype).throwf;
               ;}
    break;

  case 419:

/* Line 1455 of yacc.c  */
#line 6064 "parser.y"
    { 
                    skip_balanced('{','}'); 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = 0; 
                    (yyval.decl).throws = (yyvsp[(1) - (3)].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[(1) - (3)].dtype).throwf;
               ;}
    break;

  case 420:

/* Line 1455 of yacc.c  */
#line 6071 "parser.y"
    { 
                    Clear(scanner_ccode); 
                    (yyval.decl).parms = (yyvsp[(2) - (4)].pl); 
                    (yyval.decl).have_parms = 1; 
                    (yyval.decl).defarg = 0; 
		    (yyval.decl).throws = 0;
		    (yyval.decl).throwf = 0;
               ;}
    break;

  case 421:

/* Line 1455 of yacc.c  */
#line 6079 "parser.y"
    {
                    skip_balanced('{','}'); 
                    (yyval.decl).parms = (yyvsp[(2) - (4)].pl); 
                    (yyval.decl).have_parms = 1; 
                    (yyval.decl).defarg = 0; 
                    (yyval.decl).throws = 0;
                    (yyval.decl).throwf = 0;
               ;}
    break;

  case 422:

/* Line 1455 of yacc.c  */
#line 6087 "parser.y"
    { 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = (yyvsp[(2) - (3)].dtype).val; 
                    (yyval.decl).throws = 0;
                    (yyval.decl).throwf = 0;
               ;}
    break;

  case 427:

/* Line 1455 of yacc.c  */
#line 6103 "parser.y"
    {
	            skip_balanced('(',')');
                    Clear(scanner_ccode);
            	;}
    break;

  case 428:

/* Line 1455 of yacc.c  */
#line 6109 "parser.y"
    { 
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,(yyvsp[(2) - (3)].p));
                     (yyval.id) = Char(s);
		     scanner_last_id(1);
                 ;}
    break;

  case 429:

/* Line 1455 of yacc.c  */
#line 6115 "parser.y"
    { (yyval.id) = (char*)"";  ;}
    break;

  case 430:

/* Line 1455 of yacc.c  */
#line 6118 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 431:

/* Line 1455 of yacc.c  */
#line 6119 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 432:

/* Line 1455 of yacc.c  */
#line 6122 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 433:

/* Line 1455 of yacc.c  */
#line 6123 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 434:

/* Line 1455 of yacc.c  */
#line 6126 "parser.y"
    { 
                  (yyval.str) = 0;
		  if (!(yyval.str)) (yyval.str) = NewStringf("%s%s", (yyvsp[(1) - (2)].str),(yyvsp[(2) - (2)].str));
      	          Delete((yyvsp[(2) - (2)].str));
               ;}
    break;

  case 435:

/* Line 1455 of yacc.c  */
#line 6131 "parser.y"
    { 
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[(3) - (4)].str),(yyvsp[(4) - (4)].str));
                 Delete((yyvsp[(4) - (4)].str));
               ;}
    break;

  case 436:

/* Line 1455 of yacc.c  */
#line 6135 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
   	       ;}
    break;

  case 437:

/* Line 1455 of yacc.c  */
#line 6138 "parser.y"
    {
		 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 438:

/* Line 1455 of yacc.c  */
#line 6141 "parser.y"
    {
                 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 439:

/* Line 1455 of yacc.c  */
#line 6144 "parser.y"
    {
                 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 440:

/* Line 1455 of yacc.c  */
#line 6149 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[(2) - (3)].str),(yyvsp[(3) - (3)].str));
		   Delete((yyvsp[(3) - (3)].str));
               ;}
    break;

  case 441:

/* Line 1455 of yacc.c  */
#line 6153 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 442:

/* Line 1455 of yacc.c  */
#line 6156 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 443:

/* Line 1455 of yacc.c  */
#line 6163 "parser.y"
    {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 444:

/* Line 1455 of yacc.c  */
#line 6169 "parser.y"
    {
                  (yyval.str) = NewStringf("%s%s",(yyvsp[(1) - (2)].id),(yyvsp[(2) - (2)].id));
		  /*		  if (Len($2)) {
		    scanner_last_id(1);
		    } */
              ;}
    break;

  case 445:

/* Line 1455 of yacc.c  */
#line 6178 "parser.y"
    { 
                  (yyval.str) = 0;
		  if (!(yyval.str)) (yyval.str) = NewStringf("%s%s", (yyvsp[(1) - (2)].id),(yyvsp[(2) - (2)].str));
      	          Delete((yyvsp[(2) - (2)].str));
               ;}
    break;

  case 446:

/* Line 1455 of yacc.c  */
#line 6183 "parser.y"
    { 
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[(3) - (4)].id),(yyvsp[(4) - (4)].str));
                 Delete((yyvsp[(4) - (4)].str));
               ;}
    break;

  case 447:

/* Line 1455 of yacc.c  */
#line 6187 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].id));
   	       ;}
    break;

  case 448:

/* Line 1455 of yacc.c  */
#line 6190 "parser.y"
    {
		 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].id));
               ;}
    break;

  case 449:

/* Line 1455 of yacc.c  */
#line 6193 "parser.y"
    {
                 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 450:

/* Line 1455 of yacc.c  */
#line 6196 "parser.y"
    {
                 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 451:

/* Line 1455 of yacc.c  */
#line 6201 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[(2) - (3)].id),(yyvsp[(3) - (3)].str));
		   Delete((yyvsp[(3) - (3)].str));
               ;}
    break;

  case 452:

/* Line 1455 of yacc.c  */
#line 6205 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 453:

/* Line 1455 of yacc.c  */
#line 6208 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 454:

/* Line 1455 of yacc.c  */
#line 6211 "parser.y"
    {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 455:

/* Line 1455 of yacc.c  */
#line 6217 "parser.y"
    { 
                   (yyval.id) = (char *) malloc(strlen((yyvsp[(1) - (2)].id))+strlen((yyvsp[(2) - (2)].id))+1);
                   strcpy((yyval.id),(yyvsp[(1) - (2)].id));
                   strcat((yyval.id),(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 456:

/* Line 1455 of yacc.c  */
#line 6222 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id);;}
    break;

  case 457:

/* Line 1455 of yacc.c  */
#line 6225 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].id));
               ;}
    break;

  case 458:

/* Line 1455 of yacc.c  */
#line 6228 "parser.y"
    {
                  skip_balanced('{','}');
		  (yyval.str) = NewString(scanner_ccode);
               ;}
    break;

  case 459:

/* Line 1455 of yacc.c  */
#line 6232 "parser.y"
    {
		 (yyval.str) = (yyvsp[(1) - (1)].str);
              ;}
    break;

  case 460:

/* Line 1455 of yacc.c  */
#line 6237 "parser.y"
    {
                  Hash *n;
                  (yyval.node) = NewHash();
                  n = (yyvsp[(2) - (3)].node);
                  while(n) {
                     String *name, *value;
                     name = Getattr(n,"name");
                     value = Getattr(n,"value");
		     if (!value) value = (String *) "1";
                     Setattr((yyval.node),name, value);
		     n = nextSibling(n);
		  }
               ;}
    break;

  case 461:

/* Line 1455 of yacc.c  */
#line 6250 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 462:

/* Line 1455 of yacc.c  */
#line 6254 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
		 Setattr((yyval.node),"value",(yyvsp[(3) - (3)].id));
               ;}
    break;

  case 463:

/* Line 1455 of yacc.c  */
#line 6259 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setattr((yyval.node),"name",(yyvsp[(1) - (5)].id));
		 Setattr((yyval.node),"value",(yyvsp[(3) - (5)].id));
		 set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
               ;}
    break;

  case 464:

/* Line 1455 of yacc.c  */
#line 6265 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"name",(yyvsp[(1) - (1)].id));
	       ;}
    break;

  case 465:

/* Line 1455 of yacc.c  */
#line 6269 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
                 set_nextSibling((yyval.node),(yyvsp[(3) - (3)].node));
               ;}
    break;

  case 466:

/* Line 1455 of yacc.c  */
#line 6274 "parser.y"
    {
                 (yyval.node) = (yyvsp[(3) - (3)].node);
		 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
               ;}
    break;

  case 467:

/* Line 1455 of yacc.c  */
#line 6278 "parser.y"
    {
                 (yyval.node) = (yyvsp[(3) - (5)].node);
		 Setattr((yyval.node),"name",(yyvsp[(1) - (5)].id));
		 set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
               ;}
    break;

  case 468:

/* Line 1455 of yacc.c  */
#line 6285 "parser.y"
    {
		 (yyval.id) = (yyvsp[(1) - (1)].id);
               ;}
    break;

  case 469:

/* Line 1455 of yacc.c  */
#line 6288 "parser.y"
    {
                 (yyval.id) = Char((yyvsp[(1) - (1)].dtype).val);
               ;}
    break;



/* Line 1455 of yacc.c  */
#line 11264 "parser.tab.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;

  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse lookahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#if !defined(yyoverflow) || YYERROR_VERBOSE
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}



/* Line 1675 of yacc.c  */
#line 6295 "parser.y"


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


