
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



/* Line 189 of yacc.c  */
#line 1651 "parser.tab.c"

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
#line 1593 "parser.y"

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
#line 1860 "parser.tab.c"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif


/* Copy the second part of user declarations.  */


/* Line 264 of yacc.c  */
#line 1872 "parser.tab.c"

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
#define YYLAST   3769

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  129
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  148
/* YYNRULES -- Number of rules.  */
#define YYNRULES  467
/* YYNRULES -- Number of states.  */
#define YYNSTATES  907

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
    1201,  1203,  1207,  1209,  1211,  1215,  1217,  1219,  1221,  1223,
    1225,  1227,  1233,  1235,  1237,  1241,  1246,  1252,  1258,  1265,
    1268,  1271,  1273,  1275,  1277,  1279,  1281,  1283,  1285,  1287,
    1291,  1295,  1299,  1303,  1307,  1311,  1315,  1319,  1323,  1327,
    1331,  1335,  1339,  1343,  1347,  1351,  1357,  1360,  1363,  1366,
    1369,  1372,  1374,  1375,  1379,  1381,  1383,  1387,  1388,  1392,
    1393,  1399,  1401,  1403,  1405,  1407,  1409,  1411,  1413,  1415,
    1417,  1419,  1421,  1426,  1432,  1434,  1438,  1442,  1447,  1452,
    1456,  1459,  1461,  1463,  1467,  1470,  1474,  1476,  1478,  1480,
    1482,  1484,  1487,  1492,  1494,  1498,  1500,  1504,  1508,  1511,
    1514,  1517,  1520,  1523,  1528,  1530,  1534,  1536,  1540,  1544,
    1547,  1550,  1553,  1556,  1558,  1560,  1562,  1564,  1568,  1570,
    1574,  1580,  1582,  1586,  1590,  1596,  1598,  1600
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int16 yyrhs[] =
{
     130,     0,    -1,   131,    -1,   109,   215,    41,    -1,   109,
       1,    -1,   110,   215,    41,    -1,   110,     1,    -1,   111,
      38,   212,    39,    41,    -1,   111,     1,    41,    -1,   131,
     132,    -1,   276,    -1,   133,    -1,   170,    -1,   178,    -1,
      41,    -1,     1,    -1,   177,    -1,     1,   108,    -1,   134,
      -1,   136,    -1,   137,    -1,   138,    -1,   139,    -1,   140,
      -1,   143,    -1,   144,    -1,   147,    -1,   148,    -1,   149,
      -1,   150,    -1,   151,    -1,   152,    -1,   155,    -1,   157,
      -1,   160,    -1,   162,    -1,   167,    -1,   168,    -1,   169,
      -1,    -1,    64,   273,   266,    44,   135,   195,    45,    -1,
      88,   166,    44,   164,    45,    -1,    89,   164,    41,    -1,
      60,     3,    52,   237,    41,    -1,    60,   231,   223,   220,
      41,    -1,    60,     1,    41,    -1,    87,     4,    -1,    87,
     271,    -1,    86,    38,     3,    39,    44,    -1,    86,    44,
      -1,    86,    38,     3,    39,    41,    -1,    86,    41,    -1,
     271,    44,   215,    45,    -1,   271,    -1,   141,    -1,    91,
      38,   142,    40,   274,    39,     4,    -1,    91,    38,   142,
      40,   274,    39,    44,    -1,    91,    38,   142,    39,    41,
      -1,    -1,   146,   273,   271,    57,   145,   131,    58,    -1,
       7,    -1,     8,    -1,    84,     4,    -1,    84,    44,    -1,
       4,    -1,     9,    38,   264,    39,   271,    -1,     9,    38,
     264,    39,     4,    -1,     9,    38,   264,    39,    44,    -1,
      54,   273,   264,    -1,    61,    38,   264,    39,    -1,    61,
      38,    39,    -1,    83,    38,     3,    39,   211,     3,    41,
      -1,    83,    38,     3,    39,   211,   231,   223,    41,    -1,
      65,   154,     3,    52,   153,    -1,    65,   154,     3,    -1,
     271,    -1,     4,    -1,    38,     3,    39,    -1,   276,    -1,
     156,   223,   264,    41,    -1,   156,    38,   274,    39,   223,
     258,    41,    -1,   156,    38,   274,    39,   271,    41,    -1,
      62,    -1,    63,    -1,    66,    38,   264,    39,   223,   258,
     158,    -1,    66,    38,   264,    40,   275,    39,   223,   258,
      41,    -1,    66,    38,   264,   159,    39,   223,   258,   158,
      -1,    66,    38,   264,    40,   275,   159,    39,   223,   258,
      41,    -1,    66,    38,   264,    39,   158,    -1,    66,    38,
     264,    40,   275,    39,    41,    -1,    66,    38,   264,   159,
      39,   158,    -1,    66,    38,   264,    40,   275,   159,    39,
      41,    -1,   272,    -1,    41,    -1,   102,    38,   212,    39,
      41,    -1,    40,   264,    52,   275,    -1,    40,   264,    52,
     275,   159,    -1,    67,    38,   161,    39,   223,   258,    41,
      -1,   212,    -1,    11,    40,   215,    -1,    85,    38,   163,
      39,   164,   272,    -1,    85,    38,   163,    39,   164,    41,
      -1,    85,    38,   163,    39,   164,    52,   166,    41,    -1,
     274,    -1,   166,   165,    -1,    40,   166,   165,    -1,   276,
      -1,   231,   222,    -1,    38,   212,    39,    -1,    38,   212,
      39,    38,   212,    39,    -1,   101,    38,   212,    39,   158,
      -1,    90,    38,   265,    39,   269,    93,   216,    94,    41,
      -1,    92,   271,    -1,   172,    -1,   176,    -1,   175,    -1,
      -1,    42,   271,    44,   171,   131,    45,    -1,   211,   231,
     223,   174,   173,    -1,    41,    -1,    40,   223,   174,   173,
      -1,    44,    -1,   220,    -1,   229,   220,    -1,    78,    38,
     212,    39,   220,    -1,   229,    78,    38,   212,    39,   220,
      -1,   211,    68,     3,    41,    -1,   211,    68,   239,    44,
     240,    45,    41,    -1,   211,    68,   239,    44,   240,    45,
     223,   174,   173,    -1,   211,   231,    38,   212,    39,   259,
      -1,   179,    -1,   183,    -1,   184,    -1,   191,    -1,   192,
      -1,   202,    -1,    -1,   211,   256,   266,   247,    44,   180,
     195,    45,   182,    -1,    -1,   211,   256,    44,   181,   195,
      45,   223,   174,   173,    -1,    41,    -1,   223,   174,   173,
      -1,   211,   256,   266,    41,    -1,    -1,   106,    93,   187,
      94,   185,   186,    -1,   106,   256,   266,    -1,   172,    -1,
     179,    -1,   199,    -1,   184,    -1,   183,    -1,   201,    -1,
     188,    -1,   189,   190,    -1,   276,    -1,   255,    -1,   215,
      -1,    40,   189,   190,    -1,   276,    -1,    81,   266,    41,
      -1,    81,    82,   266,    41,    -1,    -1,    82,   266,    44,
     193,   131,    45,    -1,    -1,    82,    44,   194,   131,    45,
      -1,    82,     3,    52,   266,    41,    -1,   198,   195,    -1,
      -1,    64,    44,   196,   195,    45,   195,    -1,   144,    -1,
     276,    -1,    -1,     1,   197,   195,    -1,   170,    -1,   199,
      -1,   200,    -1,   203,    -1,   207,    -1,   201,    -1,   183,
      -1,   204,    -1,   211,   266,    41,    -1,   191,    -1,   184,
      -1,   202,    -1,   168,    -1,   169,    -1,   210,    -1,   143,
      -1,   167,    -1,    41,    -1,   211,   231,    38,   212,    39,
     259,    -1,   126,   268,    38,   212,    39,   208,    -1,    76,
     126,   268,    38,   212,    39,   209,    -1,   211,   108,   231,
     228,    38,   212,    39,   209,    -1,   211,   108,   231,   117,
      38,   212,    39,   209,    -1,   211,   108,   231,   228,   117,
      38,   212,    39,   209,    -1,   211,   108,   231,    38,   212,
      39,   209,    -1,    79,    38,   212,    39,    44,    -1,    72,
      74,    -1,    71,    74,    -1,    73,    74,    -1,    -1,   211,
     256,   266,   247,    44,   205,   182,    -1,    -1,   211,   256,
     247,    44,   206,   182,    -1,   152,    -1,   138,    -1,   150,
      -1,   155,    -1,   157,    -1,   160,    -1,   148,    -1,   162,
      -1,   136,    -1,   137,    -1,   139,    -1,   258,    41,    -1,
     258,    44,    -1,   258,    41,    -1,   258,    52,   237,    41,
      -1,   258,    44,    -1,   211,   231,    74,   243,    41,    -1,
      42,    -1,    42,   271,    -1,    75,    -1,    19,    -1,    76,
      -1,    77,    -1,    80,    -1,   276,    -1,   213,    -1,   215,
     214,    -1,   276,    -1,    40,   215,   214,    -1,   276,    -1,
     232,   221,    -1,   106,    93,   256,    94,   256,   266,   220,
      -1,    46,    46,    46,    -1,   217,    -1,   219,   218,    -1,
     276,    -1,    40,   219,   218,    -1,   276,    -1,   215,    -1,
     244,    -1,    52,   237,    -1,    52,   237,    55,   243,    56,
      -1,    52,    44,    -1,    74,   243,    -1,   276,    -1,   223,
     220,    -1,   226,   220,    -1,   220,    -1,   223,    -1,   226,
      -1,   276,    -1,   228,   224,    -1,   228,   117,   224,    -1,
     225,    -1,   117,   224,    -1,   266,   104,   224,    -1,   228,
     266,   104,   224,    -1,   228,   266,   104,   117,   224,    -1,
     266,   104,   117,   224,    -1,   266,    -1,   126,   266,    -1,
      38,   266,    39,    -1,    38,   228,   224,    39,    -1,    38,
     266,   104,   224,    39,    -1,   224,    55,    56,    -1,   224,
      55,   243,    56,    -1,   224,    38,   212,    39,    -1,   266,
      -1,   126,   266,    -1,    38,   228,   225,    39,    -1,    38,
     117,   225,    39,    -1,    38,   266,   104,   225,    39,    -1,
     225,    55,    56,    -1,   225,    55,   243,    56,    -1,   225,
      38,   212,    39,    -1,   228,    -1,   228,   227,    -1,   228,
     117,    -1,   228,   117,   227,    -1,   227,    -1,   117,   227,
      -1,   117,    -1,   266,   104,    -1,   228,   266,   104,    -1,
     228,   266,   104,   227,    -1,   227,    55,    56,    -1,   227,
      55,   243,    56,    -1,    55,    56,    -1,    55,   243,    56,
      -1,    38,   226,    39,    -1,   227,    38,   212,    39,    -1,
      38,   212,    39,    -1,   124,   229,   228,    -1,   124,   228,
      -1,   124,   229,    -1,   124,    -1,   230,    -1,   230,   229,
      -1,    47,    -1,    48,    -1,    49,    -1,   232,    -1,   229,
     233,    -1,   233,    -1,   233,   229,    -1,   229,   233,   229,
      -1,   234,    -1,    30,    -1,    28,    -1,    32,   263,    -1,
      68,   266,    -1,    33,    -1,   266,    -1,   256,   266,    -1,
     235,    -1,   236,    -1,   236,   235,    -1,    20,    -1,    22,
      -1,    23,    -1,    26,    -1,    27,    -1,    24,    -1,    25,
      -1,    29,    -1,    21,    -1,    31,    -1,    34,    -1,    35,
      -1,    36,    -1,    37,    -1,    -1,   238,   243,    -1,     3,
      -1,   276,    -1,   240,    40,   241,    -1,   241,    -1,     3,
      -1,     3,    52,   242,    -1,   276,    -1,   243,    -1,   244,
      -1,   231,    -1,   245,    -1,   271,    -1,    53,    38,   231,
     221,    39,    -1,   246,    -1,    10,    -1,    38,   243,    39,
      -1,    38,   243,    39,   243,    -1,    38,   243,   228,    39,
     243,    -1,    38,   243,   117,    39,   243,    -1,    38,   243,
     228,   117,    39,   243,    -1,   117,   243,    -1,   124,   243,
      -1,    11,    -1,    12,    -1,    13,    -1,    14,    -1,    15,
      -1,    16,    -1,    17,    -1,    18,    -1,   243,   121,   243,
      -1,   243,   120,   243,    -1,   243,   124,   243,    -1,   243,
     123,   243,    -1,   243,   122,   243,    -1,   243,   117,   243,
      -1,   243,   115,   243,    -1,   243,   116,   243,    -1,   243,
     119,   243,    -1,   243,   118,   243,    -1,   243,   114,   243,
      -1,   243,   113,   243,    -1,   243,    98,   243,    -1,   243,
      99,   243,    -1,   243,    97,   243,    -1,   243,    96,   243,
      -1,   243,   100,   243,    74,   243,    -1,   120,   243,    -1,
     121,   243,    -1,   126,   243,    -1,   125,   243,    -1,   231,
      38,    -1,   248,    -1,    -1,    74,   249,   250,    -1,   276,
      -1,   251,    -1,   250,    40,   251,    -1,    -1,   257,   252,
     266,    -1,    -1,   257,   254,   253,   257,   266,    -1,    72,
      -1,    71,    -1,    73,    -1,    69,    -1,    70,    -1,   255,
      -1,    50,    -1,    51,    -1,    76,    -1,   276,    -1,   229,
      -1,    78,    38,   212,    39,    -1,   229,    78,    38,   212,
      39,    -1,   276,    -1,   258,   260,    41,    -1,   258,   260,
      44,    -1,    38,   212,    39,    41,    -1,    38,   212,    39,
      44,    -1,    52,   237,    41,    -1,    74,   261,    -1,   276,
      -1,   262,    -1,   261,    40,   262,    -1,   266,    38,    -1,
      93,   216,    94,    -1,   276,    -1,     3,    -1,   271,    -1,
     264,    -1,   276,    -1,   268,   267,    -1,   103,   128,   268,
     267,    -1,   268,    -1,   103,   128,   268,    -1,   107,    -1,
     103,   128,   107,    -1,   128,   268,   267,    -1,   128,   268,
      -1,   128,   107,    -1,   105,   268,    -1,     3,   263,    -1,
       3,   270,    -1,   103,   128,     3,   270,    -1,     3,    -1,
     103,   128,     3,    -1,   107,    -1,   103,   128,   107,    -1,
     128,     3,   270,    -1,   128,     3,    -1,   128,   107,    -1,
     105,     3,    -1,   271,     6,    -1,     6,    -1,   271,    -1,
      44,    -1,     4,    -1,    38,   274,    39,    -1,   276,    -1,
     264,    52,   275,    -1,   264,    52,   275,    40,   274,    -1,
     264,    -1,   264,    40,   274,    -1,   264,    52,   141,    -1,
     264,    52,   141,    40,   274,    -1,   271,    -1,   245,    -1,
      -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,  1747,  1747,  1760,  1764,  1767,  1770,  1773,  1776,  1781,
    1786,  1791,  1792,  1793,  1794,  1795,  1801,  1817,  1827,  1828,
    1829,  1830,  1831,  1832,  1833,  1834,  1835,  1836,  1837,  1838,
    1839,  1840,  1841,  1842,  1843,  1844,  1845,  1846,  1847,  1854,
    1854,  1926,  1936,  1947,  1968,  1990,  2001,  2010,  2029,  2035,
    2041,  2046,  2053,  2060,  2064,  2077,  2086,  2101,  2114,  2114,
    2169,  2170,  2177,  2196,  2227,  2231,  2241,  2246,  2264,  2304,
    2310,  2323,  2329,  2355,  2361,  2368,  2369,  2372,  2373,  2381,
    2427,  2473,  2484,  2487,  2514,  2520,  2526,  2532,  2540,  2546,
    2552,  2558,  2566,  2567,  2568,  2571,  2576,  2586,  2622,  2623,
    2658,  2675,  2683,  2696,  2721,  2727,  2731,  2734,  2745,  2750,
    2763,  2775,  3049,  3059,  3066,  3067,  3071,  3071,  3102,  3163,
    3167,  3189,  3195,  3201,  3207,  3213,  3226,  3241,  3251,  3329,
    3380,  3381,  3382,  3383,  3384,  3385,  3390,  3390,  3638,  3638,
    3761,  3762,  3774,  3794,  3794,  4083,  4089,  4092,  4095,  4098,
    4101,  4104,  4109,  4139,  4143,  4146,  4149,  4154,  4158,  4163,
    4173,  4204,  4204,  4233,  4233,  4255,  4282,  4297,  4297,  4307,
    4308,  4309,  4309,  4325,  4326,  4343,  4344,  4345,  4346,  4347,
    4348,  4349,  4350,  4351,  4352,  4353,  4354,  4355,  4356,  4357,
    4358,  4367,  4392,  4416,  4457,  4472,  4490,  4509,  4528,  4535,
    4542,  4550,  4571,  4571,  4597,  4597,  4633,  4636,  4640,  4643,
    4644,  4645,  4646,  4647,  4648,  4649,  4650,  4653,  4658,  4665,
    4673,  4681,  4692,  4698,  4699,  4707,  4708,  4709,  4710,  4711,
    4712,  4719,  4730,  4734,  4737,  4741,  4745,  4755,  4763,  4771,
    4784,  4788,  4791,  4795,  4799,  4827,  4835,  4846,  4860,  4869,
    4877,  4887,  4891,  4895,  4902,  4919,  4936,  4944,  4952,  4961,
    4965,  4974,  4985,  4997,  5007,  5020,  5027,  5035,  5051,  5059,
    5070,  5081,  5092,  5111,  5119,  5136,  5144,  5151,  5162,  5173,
    5184,  5203,  5209,  5215,  5222,  5231,  5234,  5243,  5250,  5257,
    5267,  5278,  5289,  5300,  5307,  5314,  5317,  5334,  5344,  5351,
    5357,  5362,  5368,  5372,  5378,  5379,  5380,  5386,  5392,  5396,
    5397,  5401,  5408,  5411,  5412,  5413,  5414,  5415,  5417,  5420,
    5425,  5450,  5453,  5507,  5511,  5515,  5519,  5523,  5527,  5531,
    5535,  5539,  5543,  5547,  5551,  5555,  5559,  5565,  5565,  5591,
    5592,  5595,  5608,  5616,  5624,  5634,  5637,  5652,  5653,  5672,
    5673,  5677,  5682,  5683,  5697,  5704,  5721,  5728,  5735,  5743,
    5747,  5753,  5754,  5755,  5756,  5757,  5758,  5759,  5760,  5763,
    5767,  5771,  5775,  5779,  5783,  5787,  5791,  5795,  5799,  5803,
    5807,  5811,  5815,  5829,  5833,  5837,  5843,  5847,  5851,  5855,
    5859,  5875,  5880,  5880,  5881,  5884,  5901,  5910,  5910,  5926,
    5926,  5942,  5943,  5944,  5948,  5952,  5958,  5961,  5965,  5971,
    5972,  5975,  5980,  5985,  5990,  5997,  6004,  6011,  6019,  6027,
    6035,  6036,  6039,  6040,  6043,  6049,  6055,  6058,  6059,  6062,
    6063,  6066,  6071,  6075,  6078,  6081,  6084,  6089,  6093,  6096,
    6103,  6109,  6118,  6123,  6127,  6130,  6133,  6136,  6141,  6145,
    6148,  6151,  6157,  6162,  6165,  6168,  6172,  6177,  6190,  6194,
    6199,  6205,  6209,  6214,  6218,  6225,  6228,  6233
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
  "enumlist", "edecl", "etype", "expr", "valexpr", "exprnum",
  "exprcompound", "inherit", "raw_inherit", "$@14", "base_list",
  "base_specifier", "@15", "@16", "access_specifier", "templcpptype",
  "cpptype", "opt_virtual", "cpp_const", "ctor_end", "ctor_initializer",
  "mem_initializer_list", "mem_initializer", "template_decl", "idstring",
  "idstringopt", "idcolon", "idcolontail", "idtemplate", "idcolonnt",
  "idcolontailnt", "string", "stringbrace", "options", "kwargs",
  "stringnum", "empty", 0
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
     239,   240,   240,   241,   241,   241,   242,   243,   243,   244,
     244,   244,   244,   244,   244,   244,   244,   244,   244,   244,
     244,   245,   245,   245,   245,   245,   245,   245,   245,   246,
     246,   246,   246,   246,   246,   246,   246,   246,   246,   246,
     246,   246,   246,   246,   246,   246,   246,   246,   246,   246,
     246,   247,   249,   248,   248,   250,   250,   252,   251,   253,
     251,   254,   254,   254,   255,   255,   256,   256,   256,   257,
     257,   258,   258,   258,   258,   259,   259,   259,   259,   259,
     260,   260,   261,   261,   262,   263,   263,   264,   264,   265,
     265,   266,   266,   266,   266,   266,   266,   267,   267,   267,
     267,   268,   269,   269,   269,   269,   269,   269,   270,   270,
     270,   270,   271,   271,   272,   272,   272,   273,   273,   274,
     274,   274,   274,   274,   274,   275,   275,   276
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
       1,     3,     1,     1,     3,     1,     1,     1,     1,     1,
       1,     5,     1,     1,     3,     4,     5,     5,     6,     2,
       2,     1,     1,     1,     1,     1,     1,     1,     1,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     5,     2,     2,     2,     2,
       2,     1,     0,     3,     1,     1,     3,     0,     3,     0,
       5,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     4,     5,     1,     3,     3,     4,     4,     3,
       2,     1,     1,     3,     2,     3,     1,     1,     1,     1,
       1,     2,     4,     1,     3,     1,     3,     3,     2,     2,
       2,     2,     2,     4,     1,     3,     1,     3,     3,     2,
       2,     2,     2,     1,     1,     1,     1,     3,     1,     3,
       5,     1,     3,     3,     5,     1,     1,     0
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint16 yydefact[] =
{
     467,     0,     0,     0,     0,     0,    10,     4,   467,   323,
     331,   324,   325,   328,   329,   326,   327,   314,   330,   313,
     332,   467,   317,   333,   334,   335,   336,     0,   304,   305,
     306,   407,   408,     0,   404,   405,     0,     0,   435,     0,
       0,   302,   467,   309,   312,   320,   321,   406,     0,   318,
     433,     6,     0,     0,   467,     1,    15,    64,    60,    61,
       0,   226,    14,   223,   467,     0,     0,    82,    83,   467,
     467,     0,     0,   225,   227,   228,     0,   229,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     9,    11,    18,    19,    20,    21,    22,    23,
      24,    25,   467,    26,    27,    28,    29,    30,    31,    32,
       0,    33,    34,    35,    36,    37,    38,    12,   113,   115,
     114,    16,    13,   130,   131,   132,   133,   134,   135,     0,
     230,   467,   441,   426,   315,     0,   316,     0,     0,     3,
     308,   303,   467,   337,     0,     0,   287,   301,     0,   253,
     236,   467,   259,   467,   285,   281,   273,   250,   310,   322,
     319,     0,     0,   431,     5,     8,     0,   231,   467,   233,
      17,     0,   453,   224,     0,     0,   458,     0,   467,     0,
     307,     0,     0,     0,     0,    78,     0,   467,   467,     0,
       0,   467,   163,     0,     0,    62,    63,     0,     0,    51,
      49,    46,    47,   467,     0,   467,     0,   467,   467,     0,
     112,   467,   467,     0,     0,     0,     0,     0,     0,   273,
     467,     0,     0,   353,   361,   362,   363,   364,   365,   366,
     367,   368,     0,     0,     0,     0,     0,     0,     0,     0,
     244,     0,   239,   467,   348,   307,     0,   347,   349,   352,
     350,   241,   238,   436,   434,     0,   311,   467,   287,     0,
       0,   281,   318,   248,   246,     0,   293,     0,   347,   249,
     467,     0,   260,   286,   265,   299,   300,   274,   251,   467,
       0,   252,   467,     0,   283,   257,   282,   265,   288,   440,
     439,   438,     0,     0,   232,   235,   427,     0,   428,   452,
     116,   461,     0,    68,    45,   337,     0,   467,    70,     0,
       0,     0,    74,     0,     0,     0,    98,     0,     0,   159,
       0,   467,   161,     0,     0,   103,     0,     0,     0,   107,
     254,   255,   256,    42,     0,   104,   106,   429,     0,   430,
      54,     0,    53,     0,     0,   152,   467,   156,   406,   154,
     145,     0,   427,     0,     0,     0,     0,     0,     0,     0,
     265,     0,   467,     0,   340,   467,   467,   138,   319,     0,
       0,   359,   386,   387,   360,   389,   388,   425,     0,   240,
     243,   390,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   432,
       0,   287,   281,   318,     0,   273,   297,   295,   283,     0,
     273,   288,     0,   338,   294,   281,   318,   266,   467,     0,
     298,     0,   278,     0,     0,   291,     0,   258,   284,   289,
       0,   261,   437,     7,   467,     0,   467,     0,     0,   457,
       0,     0,    69,    39,    77,     0,     0,     0,     0,     0,
       0,     0,   160,     0,     0,   467,   467,     0,     0,   108,
       0,   467,     0,     0,     0,     0,     0,   143,     0,   153,
     158,    58,     0,     0,     0,     0,    79,     0,   126,   467,
       0,   318,     0,     0,   122,   467,     0,   142,   392,     0,
     391,   394,   354,     0,   301,     0,   467,   467,   384,   383,
     381,   382,     0,   380,   379,   375,   376,   374,   378,   377,
     370,   369,   373,   372,   371,     0,     0,   288,   276,   275,
     289,     0,     0,     0,   265,   267,   288,     0,   270,     0,
     280,   279,   296,   292,     0,   262,   290,   264,   234,    66,
      67,    65,     0,   462,   463,   466,   465,   459,    43,    44,
       0,    76,    73,    75,   456,    93,   455,     0,    88,   467,
     454,    92,     0,   465,     0,     0,    99,   467,   198,   165,
     164,     0,   223,     0,     0,    50,    48,   467,    41,   105,
     444,     0,   446,     0,    57,     0,     0,   110,   467,   467,
     467,   467,     0,     0,   343,     0,   342,   345,   467,   467,
       0,   119,   121,   118,     0,   123,   171,   190,     0,     0,
       0,     0,   227,     0,   214,   215,   207,   216,   188,   169,
     212,   208,   206,   209,   210,   211,   213,   189,   185,   186,
     173,   179,   183,   182,     0,     0,   174,   175,   178,   184,
     176,   180,   177,   187,     0,   230,   467,   136,   355,     0,
     301,   300,     0,     0,     0,   242,     0,   467,   277,   247,
     268,     0,   272,   271,   263,   117,     0,     0,     0,   467,
       0,   411,     0,   414,     0,     0,     0,     0,    90,   467,
       0,   162,   224,   467,     0,   101,     0,   100,     0,     0,
       0,   442,     0,   467,     0,    52,   146,   147,   150,   149,
     144,   148,   151,     0,   157,     0,     0,    81,     0,   467,
       0,   467,   337,   467,   129,     0,   467,   467,     0,   167,
     200,   199,   201,     0,     0,     0,   166,     0,     0,   467,
     318,   409,   393,   395,   397,   410,     0,   357,   356,     0,
     351,   385,   237,   269,   464,   460,    40,     0,   467,     0,
      84,   465,    95,    89,   467,     0,     0,    97,    71,     0,
       0,   109,   451,   449,   450,   445,   447,     0,    55,    56,
       0,    59,    80,   344,   346,   341,   127,   467,     0,     0,
       0,     0,   421,   467,     0,     0,   172,     0,     0,   467,
     467,     0,   467,     0,     0,   319,   181,   467,   402,   401,
     403,     0,   399,     0,   358,     0,     0,   467,    96,     0,
      91,   467,    86,    72,   102,   448,   443,     0,     0,     0,
     419,   420,   422,     0,   415,   416,   124,   120,   467,     0,
     467,     0,     0,   467,     0,     0,     0,     0,   204,     0,
     396,   398,   467,     0,    94,   412,     0,    85,     0,   111,
     128,   417,   418,     0,   424,   125,     0,     0,   467,   139,
       0,   467,   467,     0,   467,   222,     0,   202,     0,   140,
     137,   467,   413,    87,   423,   168,   467,   192,     0,   467,
       0,     0,   467,   191,   205,     0,   400,     0,   193,     0,
     217,   218,   197,   467,   467,     0,   203,   141,   219,   221,
     337,   195,   194,   467,     0,   196,   220
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
      -1,     4,     5,    92,    93,    94,   550,   614,   615,   616,
     617,    99,   340,   341,   618,   619,   590,   102,   103,   620,
     105,   621,   107,   622,   552,   184,   623,   110,   624,   558,
     448,   625,   315,   626,   324,   206,   335,   207,   627,   628,
     629,   630,   436,   118,   603,   483,   119,   120,   121,   122,
     123,   736,   486,   870,   631,   632,   588,   700,   344,   345,
     346,   469,   633,   127,   455,   321,   634,   787,   718,   635,
     636,   637,   638,   639,   640,   641,   885,   866,   642,   877,
     888,   643,   644,   259,   167,   294,   168,   241,   242,   379,
     243,   484,   150,   329,   151,   272,   152,   153,   154,   218,
      40,    41,   244,   180,    43,    44,    45,    46,   264,   265,
     363,   595,   596,   773,   246,   268,   248,   249,   489,   490,
     646,   732,   733,   801,   842,   802,    47,    48,   734,   889,
     714,   781,   821,   822,   132,   301,   338,    49,   163,    50,
     583,   691,   250,   561,   175,   302,   547,   169
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -758
static const yytype_int16 yypact[] =
{
     464,  1920,  2044,    51,    56,  2649,  -758,  -758,   -33,  -758,
    -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,   -33,  -758,  -758,  -758,  -758,  -758,    91,  -758,  -758,
    -758,  -758,  -758,    82,  -758,  -758,   -54,    29,  -758,   135,
    1363,   676,   852,   676,  -758,  -758,  3552,  -758,    82,  -758,
     119,  -758,   178,   185,  3296,  -758,    34,  -758,  -758,  -758,
     125,  -758,  -758,   249,   202,  2168,   227,  -758,  -758,   202,
     291,   300,   325,  -758,  -758,  -758,   334,  -758,   192,    33,
     344,   130,   348,   488,   447,  3347,  3347,   358,   374,   249,
     379,   618,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,   202,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
     340,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  3398,
    -758,  1733,  -758,  -758,  -758,   256,  -758,    54,   359,  -758,
     676,  -758,  1452,   391,  1857,  2414,    90,   215,    82,  -758,
    -758,    13,   315,    13,   383,   882,   336,  -758,  -758,  -758,
    -758,   459,    59,  -758,  -758,  -758,   434,  -758,   438,  -758,
    -758,   144,  -758,    74,   144,   144,  -758,   452,     6,  1007,
    -758,   280,    82,   485,   500,  -758,   144,  3245,  3296,    82,
     493,   118,  -758,   501,   541,  -758,  -758,   144,   546,  -758,
    -758,  -758,   552,  3296,   522,   276,   553,   555,   144,   249,
     552,  3296,  3296,    82,   249,   193,    97,   144,   234,   503,
     122,  1032,    76,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,  2414,   571,  2414,  2414,  2414,  2414,  2414,  2414,
    -758,   521,  -758,   578,   584,   273,  3085,    52,  -758,  -758,
     552,  -758,  -758,  -758,   119,   533,  -758,  2353,   395,   589,
     594,  1037,   532,  -758,   585,  2414,  -758,  3497,  -758,  3085,
    2353,    82,   393,   383,  -758,  -758,   523,  -758,  -758,  3296,
    1981,  -758,  3296,  2105,    90,   393,   383,   557,   582,  -758,
    -758,   119,   615,  3296,  -758,  -758,  -758,   625,   552,  -758,
    -758,   154,   628,  -758,  -758,  -758,   174,    13,  -758,   631,
     633,   645,   630,   195,   651,   655,  -758,   658,   657,  -758,
      82,  -758,  -758,   661,   662,  -758,   665,   668,  3347,  -758,
    -758,  -758,  -758,  -758,  3347,  -758,  -758,  -758,   673,  -758,
    -758,   386,   212,   680,   638,  -758,   681,  -758,    73,  -758,
    -758,    70,   302,   627,   627,   623,   698,    36,   701,    97,
     635,   582,   157,   699,  -758,  2538,   792,  -758,   350,  1160,
    3449,  1412,  -758,  -758,  -758,  -758,  -758,  -758,  1733,  -758,
    -758,  -758,  2414,  2414,  2414,  2414,  2414,  2414,  2414,  2414,
    2414,  2414,  2414,  2414,  2414,  2414,  2414,  2414,  2414,  -758,
     359,   403,   719,   648,   377,  -758,  -758,  -758,   403,   497,
     656,   627,  2414,  3085,  -758,  1061,    99,  -758,  3296,  2229,
    -758,   716,  -758,  3526,   723,  -758,  3571,   393,   383,  1104,
      97,   393,  -758,  -758,   438,   264,  -758,   144,  1423,  -758,
     726,   729,  -758,  -758,  -758,   505,   320,  1296,   733,  3296,
    1007,   737,  -758,   748,  2750,  -758,   448,  3347,   260,   753,
     749,   555,   229,   752,   144,  3296,   286,  -758,  3296,  -758,
    -758,  -758,   627,   436,    97,   109,  -758,   979,  -758,   797,
     770,   623,   772,   304,  -758,   281,  1615,  -758,  -758,   769,
    -758,  -758,  2414,  2290,  2475,     2,   852,   578,  1096,  1096,
    1285,  1285,  2516,  1476,  3188,  1444,  1241,  1412,   850,   850,
     725,   725,  -758,  -758,  -758,    82,   656,  -758,  -758,  -758,
     403,   637,  3600,   710,   656,  -758,    97,   778,  -758,  3645,
    -758,  -758,  -758,  -758,    97,   393,   383,   393,  -758,  -758,
    -758,   552,  2851,  -758,   780,  -758,   212,   781,  -758,  -758,
    1615,  -758,  -758,   552,  -758,  -758,  -758,   785,  -758,   422,
     552,  -758,   766,   138,   544,   320,  -758,   422,  -758,  -758,
    -758,  2952,   249,  3500,   367,  -758,  -758,  3296,  -758,  -758,
     237,   697,  -758,   734,  -758,   794,   790,  -758,  1099,   681,
    -758,   422,   343,    97,   791,   188,  -758,  -758,   603,  3296,
    1007,  -758,  -758,  -758,   799,  -758,  -758,  -758,   808,   795,
     798,   801,   728,   459,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,  -758,   828,  1615,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,  -758,  3143,   835,   805,  -758,  3085,  2414,
    2475,  1796,  2414,   844,   847,  -758,  2414,    13,  -758,  -758,
    -758,   741,  -758,  -758,   393,  -758,   144,   144,   842,  3296,
     854,   818,   286,  -758,  1423,   860,   144,   861,  -758,   422,
     858,  -758,   552,    62,  1007,  -758,  3347,  -758,   863,   902,
      75,  -758,    81,  1733,   177,  -758,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,  3194,  -758,  3053,   865,  -758,  2414,   797,
     927,  3296,  -758,   834,  -758,   874,   792,  3296,  1615,  -758,
    -758,  -758,  -758,   459,   879,  1007,  -758,  3449,   821,   398,
     878,  -758,   881,  -758,   839,  -758,  1615,  3085,  3085,  2414,
    -758,  3612,  -758,  -758,  -758,  -758,  -758,   883,  3296,   885,
    -758,   552,   889,  -758,   422,   995,   286,  -758,  -758,   891,
     893,  -758,  -758,   237,  -758,   237,  -758,   845,  -758,  -758,
    1124,  -758,  -758,  -758,  3085,  -758,  -758,   792,   897,   901,
      82,   439,  -758,    13,   304,   904,  -758,  1615,   906,  3296,
     792,    -8,  2538,  2414,   909,   350,  -758,   805,  -758,  -758,
    -758,    82,  -758,   903,  3085,   905,   911,  3296,  -758,   919,
    -758,   422,  -758,  -758,  -758,  -758,  -758,   920,   304,   443,
    -758,   922,  -758,   926,  -758,  -758,  -758,  -758,    13,   921,
    3296,   940,   304,  3296,   942,    15,   944,  1691,  -758,   943,
    -758,  -758,   805,  1008,  -758,  -758,   949,  -758,   950,  -758,
    -758,  -758,  -758,    82,  -758,  -758,  1615,   951,   422,  -758,
     956,  3296,  3296,   958,   603,  -758,  1008,  -758,    82,  -758,
    -758,   792,  -758,  -758,  -758,  -758,   422,  -758,   472,   422,
     961,   962,  3296,  -758,  -758,  1008,  -758,   304,  -758,   486,
    -758,  -758,  -758,   422,   422,   964,  -758,  -758,  -758,  -758,
    -758,  -758,  -758,   422,   968,  -758,  -758
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
    -758,  -758,  -303,  -758,  -758,  -758,  -758,    21,    28,    35,
      40,  -758,   567,  -758,    45,    58,  -758,  -758,  -758,    61,
    -758,    63,  -758,    66,  -758,  -758,    68,  -758,    77,  -441,
    -530,    83,  -758,   100,  -758,  -293,   551,   -73,   101,   102,
     103,   107,  -758,   425,  -757,  -679,  -758,  -758,  -758,  -758,
     426,  -758,  -758,  -573,    -2,     5,  -758,  -758,  -758,  -758,
     547,   429,   124,  -758,  -758,  -758,  -534,  -758,  -758,  -758,
     431,  -758,   433,   160,  -758,  -758,  -758,  -758,  -758,  -758,
    -490,  -758,     9,   -31,  -758,   593,    42,   330,  -758,   531,
     653,   -36,   542,  -758,    31,   643,  -167,   -95,  -135,    12,
     -26,  -758,   289,    27,   -39,  -758,   983,  -758,  -298,  -758,
    -758,  -758,   332,  -758,   959,  -129,  -416,  -758,  -691,  -758,
    -758,  -758,   242,  -758,  -758,  -758,  -208,   -43,   201,  -508,
     183,  -758,  -758,   197,  1031,  -162,  -758,   736,   -13,   -65,
    -758,  -184,   851,   480,   173,  -148,  -415,     0
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -468
static const yytype_int16 yytable[] =
{
       6,   140,   247,   124,   348,   130,   149,   440,   133,   297,
     125,   273,   204,   303,   129,   141,   668,   158,   454,   309,
     286,   133,   545,   166,   313,   587,    95,   827,    42,    42,
     833,   545,   564,    96,   677,   460,   191,   784,   794,     8,
      97,   652,   157,    39,    52,    98,   337,   260,   213,   325,
     100,   672,    53,   862,   155,   358,    55,     8,   305,   680,
     131,   850,     8,   101,   176,   143,   104,   356,   106,   176,
     185,   108,   254,   109,   137,   859,   299,   192,   763,     8,
     299,    42,   111,   706,   765,     8,   222,   145,   112,    54,
     713,   404,  -245,     8,   409,   255,   289,   291,   818,   131,
       8,   726,   176,   758,   839,   113,   114,   115,   116,   834,
     331,   832,   117,  -155,   256,   278,   147,   281,   300,   653,
     367,   276,   138,   273,   678,   362,   286,   471,   270,   126,
     897,   251,   863,   542,   195,   357,    36,   135,   525,    36,
      38,   217,   170,    38,   299,   144,  -245,   296,   525,   428,
     172,   157,   571,   157,   261,   131,   316,   317,   245,   275,
     147,   253,   260,   171,   574,   128,   290,  -155,   295,    42,
     320,   756,   327,   240,   196,   260,   139,     8,   133,    36,
     343,   768,   764,    38,   786,    36,   404,   409,   766,    38,
    -428,   133,   887,    36,   437,     8,   352,    38,   478,   172,
      36,  -339,   803,   526,    38,   332,   438,   336,   339,   149,
     307,   131,   349,   593,    42,    42,   271,   155,   299,   164,
     364,   769,   808,   271,   161,    36,   165,   354,   709,    38,
      42,   750,   580,   710,   446,   447,   330,     8,    42,    42,
     174,   399,   182,   380,   521,   157,   809,   162,   421,   247,
     131,   424,   366,   829,   347,   172,   465,   155,   545,   752,
     348,   461,    28,    29,    30,   181,   273,   286,   539,   402,
     172,   441,   357,   428,   189,   214,     8,    36,   432,     8,
     286,    38,   415,   296,    42,   562,   172,   705,   420,   543,
     554,   353,   172,   884,   536,    36,    36,    42,   147,    38,
      38,   575,   252,   848,   576,   521,    42,   157,   540,    42,
     353,   142,   896,  -467,   142,   812,   585,   147,   354,   308,
      42,     6,   875,     8,   554,   143,   172,   555,   144,   183,
     556,   144,   581,   143,   480,   434,   582,    36,   186,   147,
     485,    38,   689,     8,   600,   601,   470,   145,   602,   299,
     878,   359,   133,   279,   179,   145,   713,   515,   306,   604,
     271,   555,   133,   187,   556,   690,   157,  -467,   491,   474,
     280,   554,   188,   172,   205,   205,    36,   354,   215,    36,
      38,   495,   194,    38,   707,   536,   197,   527,   557,   892,
     146,   487,    42,   146,  -467,   131,   208,   147,     8,   148,
     147,     8,   148,   901,   902,   245,  -467,  -467,   685,    31,
      32,   556,   209,   905,   779,   279,   518,   211,   221,   686,
     240,   282,   557,    36,   488,   463,   464,    38,    34,    35,
    -467,   418,   280,   142,   295,   263,     6,   216,   283,     8,
     288,   257,   172,    36,   147,    42,   148,    38,   419,   605,
     144,   201,   124,   172,   130,     6,   130,   216,   144,   125,
     149,   336,     8,   129,   147,   573,   148,    61,   651,    28,
      29,    30,   488,   292,   306,    95,    42,   559,   293,   597,
     824,   567,    96,   825,   851,   157,   645,   852,   311,    97,
     572,   566,    42,   304,    98,    42,   157,   380,    36,   100,
     670,    36,    38,   312,   591,    38,   275,   586,   155,   551,
     347,   172,   101,   890,   562,   104,   891,   106,   744,   745,
     108,   148,   109,    73,    74,    75,   198,   898,    77,   199,
     899,   111,   200,   671,   319,   279,   519,   112,   900,    36,
     124,   671,   130,    38,   323,   322,   688,   125,   724,   326,
     645,   129,   280,   216,   113,   114,   115,   116,   299,   673,
     147,   117,   148,    95,   247,   671,   328,   673,   715,   124,
      96,   130,   671,     1,     2,     3,   125,    97,   126,   815,
     129,   816,    98,   675,   676,     8,   698,   100,   130,   470,
       6,   673,    95,   699,   333,   334,   679,   703,   673,    96,
     101,   729,   904,   104,    42,   106,    97,   361,   108,   370,
     109,    98,   140,   760,   128,   377,   100,   205,   378,   111,
     357,   742,   381,   205,   651,   112,    42,   400,   406,   101,
       8,   716,   104,   407,   106,   645,   411,   108,   747,   109,
     412,   711,   113,   114,   115,   116,   735,   147,   111,   117,
      28,    29,    30,   671,   112,   712,   433,   157,   788,   496,
     222,   429,   275,   420,   435,   306,   126,   439,    31,    32,
     442,   113,   114,   115,   116,   279,   658,   443,   117,   673,
     778,   670,   445,   133,   444,    36,   785,    34,    35,    38,
     485,   449,   280,   251,   450,   126,    42,   451,   452,   430,
     456,   457,   128,   124,   458,   130,   754,   459,   271,   597,
     125,   212,   462,   782,   129,   759,   157,   806,   645,   466,
     245,   468,     8,    28,    29,    30,    95,   472,   671,   491,
      36,   128,   467,    96,    38,   240,   645,   473,    42,   477,
      97,   777,   476,   479,    42,    98,   205,   826,   418,   660,
     100,   485,   517,   148,   673,   530,   790,   257,   831,   366,
     520,   836,   532,   101,   485,   419,   104,   548,   106,   136,
     549,   108,   565,   109,   144,    42,   846,   157,   156,   418,
     743,   568,   111,   157,   160,   671,   811,   645,   112,   569,
     157,   577,   855,   584,   578,   491,   419,   735,   285,   857,
     594,   366,   860,   835,   354,   113,   114,   115,   116,   598,
     599,   673,   117,   647,   190,   193,    42,   662,   674,    42,
     666,   667,    36,   669,     8,   692,    38,   693,   157,   126,
     880,   881,   671,   694,    42,   695,   408,   717,   671,    28,
      29,    30,   735,   708,   143,   485,   219,   396,   397,   398,
     671,   895,   719,   671,   723,     8,   645,    42,   673,   792,
      42,   285,   684,     8,   673,   128,   145,   671,   671,   720,
     482,   157,   721,   725,   871,   722,   673,   671,   262,   673,
    -170,   731,   274,   739,   277,     8,   740,   746,    42,    42,
     142,   287,   748,   673,   673,   793,   749,   871,   306,   757,
     755,   753,   761,   673,   143,   762,   772,   144,   780,    42,
     798,   799,   800,   783,   173,   219,   871,   789,   310,   796,
     270,   797,   805,   807,    36,   318,   145,   427,    38,   676,
       8,   431,   813,   728,   814,   202,   819,   144,   216,   817,
     210,   156,   820,   828,   830,   147,   844,   148,   843,   350,
     845,   355,   274,   838,   360,    36,   136,   219,   368,    38,
     847,   849,   853,    36,   854,   306,   856,    38,   776,   146,
     394,   395,   396,   397,   398,   205,   147,   216,   148,   858,
     861,   156,     8,   864,   147,    36,   148,   867,   872,    38,
     876,   873,   770,   403,   405,   879,   882,   410,     8,   284,
     893,   894,   427,   903,   431,   544,   416,   417,   271,   906,
       8,     8,   579,   696,   697,   589,   791,   357,   704,   701,
     274,   702,   298,   767,   274,   298,   298,   538,   655,   159,
      36,   497,   298,   306,    38,     8,   810,   298,   654,   840,
       8,   775,   355,   868,   216,   306,   306,   883,   298,   869,
     874,   147,   134,   148,   687,     0,   453,     0,   523,   298,
     342,     0,     0,     0,     8,   351,   298,     0,   298,     0,
     365,     0,   535,   537,     0,   142,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    38,     0,     0,   405,
     405,     0,   144,   475,     0,   274,   534,   274,    36,   270,
       0,   481,    38,   267,   269,   271,     0,     8,     0,     0,
      36,    36,   216,     0,    38,    38,   144,   523,    61,   147,
     535,   148,     0,     0,   216,   216,     0,     8,     0,     0,
       0,   147,   147,   148,   148,    36,     0,     0,   516,    38,
      36,   572,   270,     0,    38,     0,     0,   405,     0,   216,
       0,   524,     0,     0,   408,     0,   147,     0,   148,   144,
       0,     0,   792,   148,    36,   274,   274,     0,    38,   661,
       0,     0,     0,     0,    73,    74,    75,   664,   408,    77,
       0,     0,   219,     0,     0,     0,   219,   271,     0,     0,
       0,   369,     0,   371,   372,   373,   374,   375,   376,   492,
       0,     0,     0,     0,     0,    91,     0,    36,   405,   219,
     274,    38,     0,   274,   392,   393,   394,   395,   396,   397,
     398,   534,     0,     0,   413,     0,     0,    36,     0,     0,
     271,    38,   156,     0,     0,     0,   661,     0,     0,   423,
       0,   216,   426,     0,     0,     0,     0,     0,   147,     0,
     148,   657,     0,     0,     0,     0,   382,   383,   384,   385,
     386,     0,   274,     0,     0,     0,     0,     0,     0,     0,
     274,     0,     0,   387,   388,   389,   390,   493,   392,   393,
     394,   395,   396,   397,   494,     0,   541,     0,   298,   546,
       0,     0,     0,     0,     0,     0,   553,   560,   563,   296,
       0,   219,   172,     0,     0,     0,     0,   224,   225,   226,
     227,   228,   229,   230,   231,   298,     0,   560,     0,     0,
       0,     0,     0,     0,   592,     0,     0,     0,     0,   274,
       0,     0,     0,     0,     0,     0,   219,   382,   383,   384,
     385,   498,   499,   500,   501,   502,   503,   504,   505,   506,
     507,   508,   509,   510,   511,   512,   513,   514,   391,   392,
     393,   394,   395,   396,   397,   398,     8,     0,     0,     0,
       0,   522,     0,     0,     0,     0,     0,     0,   529,     0,
     730,   382,   383,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,     0,     0,   392,   393,   394,   395,   396,   397,   398,
       0,   219,     0,    31,    32,     0,   560,     0,     0,     0,
     219,     0,     0,   682,     0,   560,     0,     0,     0,   172,
       0,    33,    34,    35,   224,   225,   226,   227,   228,   229,
     230,   231,     0,     0,     0,     0,   219,     0,     0,     0,
       0,   648,   507,   514,     0,     8,     0,     0,     0,     0,
       0,   219,     0,     0,   219,   795,    36,     0,     0,     0,
      38,     0,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
     257,   219,     0,     0,     0,     0,     0,     0,    27,    28,
      29,    30,    31,    32,     0,     0,   219,   144,   382,   383,
     384,   385,     0,     0,     0,     0,   823,   298,   298,     0,
      33,    34,    35,   560,     0,   751,     0,   298,   481,     0,
     392,   393,   394,   395,   396,   397,   398,   841,     0,     0,
     382,   383,   384,   385,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    36,     0,     0,    37,    38,
     390,   391,   392,   393,   394,   395,   396,   397,   398,   258,
       0,     0,   382,   383,   384,   385,   147,     0,     0,   219,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   823,
     388,   389,   390,   391,   392,   393,   394,   395,   396,   397,
     398,     0,   219,     0,   886,     0,     0,   560,   737,   374,
       0,   738,     0,     0,     0,   741,   606,     0,  -467,    57,
       0,   219,    58,    59,    60,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    61,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,     0,     0,     0,   607,    63,     0,     0,
    -467,     0,  -467,  -467,  -467,  -467,  -467,   774,     0,     0,
       0,     0,     0,     0,     0,    65,    66,    67,    68,   608,
      70,    71,    72,  -467,  -467,  -467,   609,   610,   611,     0,
      73,   612,    75,     0,    76,    77,    78,     0,   804,     0,
      82,     0,    84,    85,    86,    87,    88,    89,     0,     0,
       0,     0,     0,     0,     0,     0,    90,     0,  -467,     0,
       0,    91,  -467,  -467,     0,     0,     0,     0,     0,     0,
       0,     0,   865,     0,     0,     0,     8,     0,     0,   172,
       0,   613,     0,   223,   224,   225,   226,   227,   228,   229,
     230,   231,   837,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,   232,     0,     0,     0,     0,     0,     0,     0,    27,
      28,    29,    30,    31,    32,     0,   233,   382,   383,   384,
     385,   386,     0,     0,     0,     0,     0,     0,     0,     8,
       0,    33,    34,    35,   387,   388,   389,   390,   391,   392,
     393,   394,   395,   396,   397,   398,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,     0,     0,    36,     0,     0,    37,
      38,     0,     0,     0,     0,     0,    31,    32,     0,     0,
     234,     0,     0,   235,   236,     0,     0,   237,   238,   239,
       8,     0,     0,   172,    33,    34,    35,   223,   224,   225,
     226,   227,   228,   229,   230,   231,     0,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,   232,     0,     0,     0,    36,
       0,     0,     0,    38,    28,    29,    30,    31,    32,     0,
     233,     0,     0,   266,     0,     0,     0,     0,     0,     0,
     147,     7,     0,     8,     0,    33,    34,    35,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,     0,     0,
      36,     0,     0,     0,    38,     0,    27,    28,    29,    30,
      31,    32,     0,     0,   234,     0,     0,   235,   236,     0,
       0,   237,   238,   239,     8,     0,     0,   172,    33,    34,
      35,   223,   224,   225,   226,   227,   228,   229,   230,   231,
       0,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,    25,    26,   232,
       0,     0,     0,    36,     0,     0,    37,    38,    28,    29,
      30,    31,    32,     0,   233,     0,     0,   422,     0,     0,
       0,     0,     0,     0,     0,    51,     0,     8,     0,    33,
      34,    35,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,     0,     0,    36,     0,     0,     0,    38,     0,
      27,    28,    29,    30,    31,    32,     0,     0,   234,     0,
       0,   235,   236,     0,     0,   237,   238,   239,     8,     0,
       0,   172,    33,    34,    35,   223,   224,   225,   226,   227,
     228,   229,   230,   231,     0,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,   232,     0,     0,     0,    36,     0,     0,
      37,    38,    28,    29,    30,    31,    32,     0,   233,     0,
       0,   425,     0,     0,     0,     0,     0,     0,     0,   177,
       0,   178,     0,    33,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,     0,     0,    36,     0,
       0,     0,    38,     0,     0,    28,    29,    30,    31,    32,
       0,     0,   234,     0,     0,   235,   236,     0,     0,   237,
     238,   239,     8,     0,     0,   172,    33,    34,    35,   223,
     224,   225,   226,   227,   228,   229,   230,   231,     0,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,   232,     0,     0,
       0,    36,     0,     0,     0,    38,    28,    29,    30,    31,
      32,     0,   233,     0,     0,   528,     0,     0,     0,     0,
       0,     0,     0,     8,     0,     0,   172,    33,    34,    35,
     223,   224,   225,   226,   227,   228,   229,   230,   231,     0,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,   232,   649,
       0,     0,    36,     0,     0,     0,    38,    28,    29,    30,
      31,    32,     0,   233,     0,     0,   234,     0,     0,   235,
     236,     0,     0,   237,   238,   239,     8,     0,    33,    34,
      35,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,   257,     0,    36,     0,     0,     0,    38,     0,    27,
      28,    29,    30,    31,    32,     0,     0,   234,   144,     0,
     235,   236,     0,     0,   237,   238,   239,     8,     0,     0,
     172,    33,    34,    35,   223,   224,   225,   226,   227,   228,
     229,   230,   231,     0,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,   232,     0,     0,     0,    36,     0,     0,    37,
      38,    28,    29,    30,    31,    32,     0,   233,     0,     0,
     401,     0,     0,     0,     0,     0,     0,   147,     8,     0,
       0,   172,    33,    34,    35,   223,   224,   225,   226,   227,
     228,   229,   230,   231,     0,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,   232,     0,     0,     0,    36,     0,     0,
       0,    38,    28,    29,    30,    31,    32,     0,   233,     0,
       0,   234,     0,     0,   235,   236,     0,     0,   237,   238,
     239,     8,     0,    33,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,     0,     0,    36,     0,
       0,     0,    38,     0,    27,    28,    29,    30,    31,    32,
     656,     0,     0,     0,     0,   235,   236,     0,     0,   650,
     238,   239,     0,     0,     0,     0,    33,    34,    35,     0,
       0,     0,   382,   383,   384,   385,   386,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   387,
     388,   389,   390,   391,   392,   393,   394,   395,   396,   397,
     398,    36,     0,     0,    37,    38,     0,     0,     0,    -2,
      56,     0,  -467,    57,     0,   353,    58,    59,    60,     0,
       0,     0,   147,     0,     0,     0,     0,     0,    61,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,     0,     0,     0,
      62,    63,     0,     0,     0,     0,  -467,  -467,  -467,  -467,
    -467,     0,     0,    64,     0,     0,     0,     0,     0,    65,
      66,    67,    68,    69,    70,    71,    72,  -467,  -467,  -467,
       0,     0,     0,     0,    73,    74,    75,     0,    76,    77,
      78,    79,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,     0,     0,     0,     0,     0,     0,     0,     0,
      90,    56,  -467,  -467,    57,    91,  -467,    58,    59,    60,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    61,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,     0,     0,
       0,    62,    63,     0,     0,   570,     0,  -467,  -467,  -467,
    -467,  -467,     0,     0,    64,     0,     0,     0,     0,     0,
      65,    66,    67,    68,    69,    70,    71,    72,  -467,  -467,
    -467,     0,     0,     0,     0,    73,    74,    75,     0,    76,
      77,    78,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,     0,     0,     0,     0,     0,     0,     0,
       0,    90,    56,  -467,  -467,    57,    91,  -467,    58,    59,
      60,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      61,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,     0,
       0,     0,    62,    63,     0,     0,   665,     0,  -467,  -467,
    -467,  -467,  -467,     0,     0,    64,     0,     0,     0,     0,
       0,    65,    66,    67,    68,    69,    70,    71,    72,  -467,
    -467,  -467,     0,     0,     0,     0,    73,    74,    75,     0,
      76,    77,    78,    79,    80,    81,    82,    83,    84,    85,
      86,    87,    88,    89,     0,     0,     0,     0,     0,     0,
       0,     0,    90,    56,  -467,  -467,    57,    91,  -467,    58,
      59,    60,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    61,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
       0,     0,     0,    62,    63,     0,     0,   681,     0,  -467,
    -467,  -467,  -467,  -467,     0,     0,    64,     0,     0,     0,
       0,     0,    65,    66,    67,    68,    69,    70,    71,    72,
    -467,  -467,  -467,     0,     0,     0,     0,    73,    74,    75,
       0,    76,    77,    78,    79,    80,    81,    82,    83,    84,
      85,    86,    87,    88,    89,     0,     0,     0,     0,     0,
       0,     0,     0,    90,    56,  -467,  -467,    57,    91,  -467,
      58,    59,    60,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    61,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,  -467,
    -467,     0,     0,     0,    62,    63,     0,     0,     0,     0,
    -467,  -467,  -467,  -467,  -467,     0,     0,    64,     0,     0,
       0,   771,     0,    65,    66,    67,    68,    69,    70,    71,
      72,  -467,  -467,  -467,     0,     0,     0,     0,    73,    74,
      75,     0,    76,    77,    78,    79,    80,    81,    82,    83,
      84,    85,    86,    87,    88,    89,     8,     0,     0,     0,
       0,     0,     0,     0,    90,     0,  -467,     0,     0,    91,
    -467,     0,     0,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
      26,   382,   383,   384,   385,   386,     0,     0,     0,     0,
      28,    29,    30,    31,    32,     0,     0,     8,   387,   388,
     389,   390,   391,   392,   393,   394,   395,   396,   397,   398,
       0,   220,    34,    35,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
      25,    26,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    28,    29,    30,    31,    32,    36,     0,     8,     0,
      38,   727,     0,     0,     0,     0,   314,     0,     0,     0,
       0,     0,    33,    34,    35,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,    25,    26,     0,   382,   383,   384,   385,     0,     0,
       0,    27,    28,    29,    30,    31,    32,    36,     0,     8,
       0,    38,   727,   389,   390,   391,   392,   393,   394,   395,
     396,   397,   398,    33,    34,    35,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,    25,    26,     0,     0,     0,     0,     0,     0,
       0,     0,    27,    28,    29,    30,    31,    32,    36,     0,
       8,    37,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    33,    34,    35,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,    25,    26,   203,     0,     0,     0,     0,
       0,     0,     0,     0,    28,    29,    30,    31,    32,    36,
       0,     8,    37,    38,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,    34,    35,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,    25,    26,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    28,    29,    30,    31,    32,
      36,     0,     8,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   220,    34,    35,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,    25,    26,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    28,    29,    30,    31,
      32,    36,     0,   683,     0,    38,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,    34,    35,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,    25,    26,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    28,    29,    30,
      31,    32,    36,   414,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    33,    34,
      35,     0,     9,    10,    11,    12,    13,    14,    15,    16,
       0,    18,   531,    20,     0,     0,    23,    24,    25,    26,
       0,     0,     0,   382,   383,   384,   385,   386,     0,     0,
       0,     0,     0,    36,     0,     0,     0,    38,     0,     0,
     387,   388,   389,   390,   391,   392,   393,   394,   395,   396,
     397,   398,   382,   383,   384,   385,   386,   533,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   387,
     388,   389,   390,   391,   392,   393,   394,   395,   396,   397,
     398,     0,     0,     0,     0,     0,   659,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   382,   383,   384,
     385,   386,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   387,   388,   389,   390,   391,   392,
     393,   394,   395,   396,   397,   398,   382,   383,   384,   385,
     386,   663,     0,     0,     0,     0,     0,     0,   382,   383,
     384,   385,     0,   387,   388,   389,   390,   391,   392,   393,
     394,   395,   396,   397,   398,   387,   388,   389,   390,   391,
     392,   393,   394,   395,   396,   397,   398,     0,     0,     0,
       0,   382,   383,   384,   385,   386,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   387,   388,
     389,   390,   391,   392,   393,   394,   395,   396,   397,   398
};

static const yytype_int16 yycheck[] =
{
       0,    40,   131,     5,   212,     5,    42,   305,     8,   171,
       5,   146,    85,   175,     5,    41,   550,    43,   321,   181,
     155,    21,   438,    54,   186,   466,     5,   784,     1,     2,
      38,   447,   447,     5,   564,   328,     3,   716,   729,     3,
       5,    39,    42,     1,     2,     5,   208,   142,    91,   197,
       5,   559,     1,    38,    42,   217,     0,     3,    52,   567,
      93,   818,     3,     5,    64,    52,     5,   215,     5,    69,
      70,     5,   137,     5,   128,   832,     6,    44,     3,     3,
       6,    54,     5,   591,     3,     3,   129,    74,     5,    38,
     598,   258,    40,     3,   261,   138,   161,   162,   777,    93,
       3,   635,   102,    41,   795,     5,     5,     5,     5,   117,
     205,   790,     5,    40,   140,   151,   124,   153,    44,   117,
      44,   147,    93,   258,   565,     3,   261,    57,    38,     5,
     887,   131,   117,   436,     4,    38,   103,    46,    39,   103,
     107,   110,   108,   107,     6,    55,    94,     3,    39,   284,
       6,   151,   455,   153,   142,    93,   187,   188,   131,   147,
     124,   107,   257,    38,   457,     5,   107,    94,   168,   142,
      52,   679,   203,   131,    44,   270,    41,     3,   178,   103,
     211,     4,   107,   107,   718,   103,   353,   354,   107,   107,
      52,   191,   871,   103,    40,     3,     3,   107,    41,     6,
     103,    44,   736,   104,   107,   205,    52,   207,   208,   245,
     179,    93,   212,   104,   187,   188,   126,   205,     6,    41,
     220,    44,   752,   126,   105,   103,    41,   215,    40,   107,
     203,   672,     3,    45,    39,    40,   205,     3,   211,   212,
      38,   254,    69,   243,   411,   245,   754,   128,   279,   378,
      93,   282,   221,   787,   212,     6,    44,   245,   674,   674,
     468,   334,    47,    48,    49,    38,   401,   402,     4,   257,
       6,   307,    38,   408,    82,   102,     3,   103,   291,     3,
     415,   107,   270,     3,   257,   447,     6,   590,   276,   437,
       4,   117,     6,   866,   429,   103,   103,   270,   124,   107,
     107,    41,    46,   811,    44,   472,   279,   307,    44,   282,
     117,    38,   885,    40,    38,   756,   464,   124,   306,    39,
     293,   321,   856,     3,     4,    52,     6,    41,    55,    38,
      44,    55,   103,    52,   365,   293,   107,   103,    38,   124,
     366,   107,   105,     3,    40,    41,   346,    74,    44,     6,
     858,   117,   352,    38,    65,    74,   864,   400,    38,    78,
     126,    41,   362,    38,    44,   128,   366,    94,   368,   357,
      55,     4,    38,     6,    85,    86,   103,   365,    38,   103,
     107,   369,    38,   107,    41,   520,    38,   418,   102,   879,
     117,    41,   365,   117,    44,    93,    38,   124,     3,   126,
     124,     3,   126,   893,   894,   378,   104,   105,    41,    50,
      51,    44,    38,   903,   712,    38,    39,    38,   129,    52,
     378,    38,   102,   103,    74,    39,    40,   107,    69,    70,
     128,    38,    55,    38,   434,    44,   436,   117,    55,     3,
     104,    38,     6,   103,   124,   418,   126,   107,    55,   485,
      55,     4,   454,     6,   454,   455,   456,   117,    55,   454,
     496,   461,     3,   454,   124,   456,   126,    19,   494,    47,
      48,    49,    74,    39,    38,   454,   449,   446,    40,   479,
      41,   450,   454,    44,    41,   485,   486,    44,     3,   454,
      42,   449,   465,    41,   454,   468,   496,   497,   103,   454,
      78,   103,   107,     3,   473,   107,   494,   465,   496,     4,
     468,     6,   454,    41,   676,   454,    44,   454,   666,   667,
     454,   126,   454,    75,    76,    77,    38,    41,    80,    41,
      44,   454,    44,   559,    41,    38,    39,   454,    52,   103,
     542,   567,   542,   107,     3,    44,   577,   542,   613,     3,
     550,   542,    55,   117,   454,   454,   454,   454,     6,   559,
     124,   454,   126,   542,   693,   591,    44,   567,   599,   571,
     542,   571,   598,   109,   110,   111,   571,   542,   454,   763,
     571,   765,   542,    39,    40,     3,   588,   542,   588,   589,
     590,   591,   571,   588,    41,    40,   565,   588,   598,   571,
     542,   644,   900,   542,   577,   542,   571,   104,   542,    38,
     542,   571,   651,   686,   454,    94,   571,   328,    40,   542,
      38,   657,    38,   334,   650,   542,   599,    94,    39,   571,
       3,   600,   571,    39,   571,   635,   104,   571,   669,   571,
      55,    38,   542,   542,   542,   542,   646,   124,   571,   542,
      47,    48,    49,   679,   571,    52,    41,   657,   723,   370,
     703,   104,   650,   651,    39,    38,   542,    39,    50,    51,
      39,   571,   571,   571,   571,    38,    39,    44,   571,   679,
     711,    78,    52,   683,    39,   103,   717,    69,    70,   107,
     716,    40,    55,   693,    39,   571,   669,    39,    41,   117,
      39,    39,   542,   705,    39,   705,   675,    39,   126,   709,
     705,    93,    39,   713,   705,   684,   716,   748,   718,    39,
     693,    40,     3,    47,    48,    49,   705,   104,   754,   729,
     103,   571,    94,   705,   107,   693,   736,    39,   711,   104,
     705,   710,    41,    44,   717,   705,   457,   783,    38,    39,
     705,   777,   104,   126,   754,    39,   725,    38,   789,   728,
     104,   792,    39,   705,   790,    55,   705,    41,   705,    33,
      41,   705,    39,   705,    55,   748,   807,   777,    42,    38,
      39,    44,   705,   783,    48,   811,   755,   787,   705,    41,
     790,    38,   828,    41,    45,   795,    55,   797,   155,   830,
       3,   770,   833,   791,   792,   705,   705,   705,   705,    39,
      38,   811,   705,    44,    78,    79,   789,    39,    52,   792,
      40,    40,   103,    38,     3,   128,   107,    93,   828,   705,
     861,   862,   858,    39,   807,    45,   117,    38,   864,    47,
      48,    49,   842,    52,    52,   871,   110,   122,   123,   124,
     876,   882,    44,   879,   126,     3,   856,   830,   858,    38,
     833,   218,   573,     3,   864,   705,    74,   893,   894,    74,
      78,   871,    74,    45,   843,    74,   876,   903,   142,   879,
      45,    76,   146,    39,   148,     3,    39,    45,   861,   862,
      38,   155,    38,   893,   894,    74,    78,   866,    38,    41,
      39,    41,    39,   903,    52,     3,    41,    55,    74,   882,
      71,    72,    73,    39,    63,   179,   885,    38,   182,    41,
      38,    40,    39,    38,   103,   189,    74,   284,   107,    40,
       3,   288,    41,   644,    41,    84,    39,    55,   117,    94,
      89,   205,    41,    39,    38,   124,    41,   126,    45,   213,
      39,   215,   216,    44,   218,   103,   220,   221,   222,   107,
      41,    41,    40,   103,    38,    38,    45,   107,    41,   117,
     120,   121,   122,   123,   124,   686,   124,   117,   126,    39,
      38,   245,     3,    39,   124,   103,   126,    44,    39,   107,
      39,    41,   703,   257,   258,    39,    38,   261,     3,   117,
      39,    39,   359,    39,   361,   438,   270,   271,   126,    41,
       3,     3,   461,   588,   588,   468,   727,    38,   589,   588,
     284,   588,   171,   693,   288,   174,   175,   434,   497,    46,
     103,   378,   181,    38,   107,     3,    41,   186,   496,   797,
       3,   709,   306,   842,   117,    38,    38,   864,   197,    41,
     853,   124,    21,   126,   574,    -1,   320,    -1,   415,   208,
     209,    -1,    -1,    -1,     3,   214,   215,    -1,   217,    -1,
      38,    -1,   429,   430,    -1,    38,    -1,    -1,    -1,    -1,
      -1,    -1,   103,    -1,    -1,    -1,   107,    -1,    -1,   353,
     354,    -1,    55,   357,    -1,   359,   117,   361,   103,    38,
      -1,   365,   107,   144,   145,   126,    -1,     3,    -1,    -1,
     103,   103,   117,    -1,   107,   107,    55,   474,    19,   124,
     477,   126,    -1,    -1,   117,   117,    -1,     3,    -1,    -1,
      -1,   124,   124,   126,   126,   103,    -1,    -1,   402,   107,
     103,    42,    38,    -1,   107,    -1,    -1,   411,    -1,   117,
      -1,   415,    -1,    -1,   117,    -1,   124,    -1,   126,    55,
      -1,    -1,    38,   126,   103,   429,   430,    -1,   107,   526,
      -1,    -1,    -1,    -1,    75,    76,    77,   534,   117,    80,
      -1,    -1,   446,    -1,    -1,    -1,   450,   126,    -1,    -1,
      -1,   232,    -1,   234,   235,   236,   237,   238,   239,    39,
      -1,    -1,    -1,    -1,    -1,   106,    -1,   103,   472,   473,
     474,   107,    -1,   477,   118,   119,   120,   121,   122,   123,
     124,   117,    -1,    -1,   265,    -1,    -1,   103,    -1,    -1,
     126,   107,   496,    -1,    -1,    -1,   593,    -1,    -1,   280,
      -1,   117,   283,    -1,    -1,    -1,    -1,    -1,   124,    -1,
     126,   515,    -1,    -1,    -1,    -1,    96,    97,    98,    99,
     100,    -1,   526,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     534,    -1,    -1,   113,   114,   115,   116,   117,   118,   119,
     120,   121,   122,   123,   124,    -1,   435,    -1,   437,   438,
      -1,    -1,    -1,    -1,    -1,    -1,   445,   446,   447,     3,
      -1,   565,     6,    -1,    -1,    -1,    -1,    11,    12,    13,
      14,    15,    16,    17,    18,   464,    -1,   466,    -1,    -1,
      -1,    -1,    -1,    -1,   473,    -1,    -1,    -1,    -1,   593,
      -1,    -1,    -1,    -1,    -1,    -1,   600,    96,    97,    98,
      99,   382,   383,   384,   385,   386,   387,   388,   389,   390,
     391,   392,   393,   394,   395,   396,   397,   398,   117,   118,
     119,   120,   121,   122,   123,   124,     3,    -1,    -1,    -1,
      -1,   412,    -1,    -1,    -1,    -1,    -1,    -1,   419,    -1,
     644,    96,    97,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,   118,   119,   120,   121,   122,   123,   124,
      -1,   675,    -1,    50,    51,    -1,   565,    -1,    -1,    -1,
     684,    -1,    -1,   572,    -1,   574,    -1,    -1,    -1,     6,
      -1,    68,    69,    70,    11,    12,    13,    14,    15,    16,
      17,    18,    -1,    -1,    -1,    -1,   710,    -1,    -1,    -1,
      -1,   492,   493,   494,    -1,     3,    -1,    -1,    -1,    -1,
      -1,   725,    -1,    -1,   728,   729,   103,    -1,    -1,    -1,
     107,    -1,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,   755,    -1,    -1,    -1,    -1,    -1,    -1,    46,    47,
      48,    49,    50,    51,    -1,    -1,   770,    55,    96,    97,
      98,    99,    -1,    -1,    -1,    -1,   780,   666,   667,    -1,
      68,    69,    70,   672,    -1,   674,    -1,   676,   792,    -1,
     118,   119,   120,   121,   122,   123,   124,   801,    -1,    -1,
      96,    97,    98,    99,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   103,    -1,    -1,   106,   107,
     116,   117,   118,   119,   120,   121,   122,   123,   124,   117,
      -1,    -1,    96,    97,    98,    99,   124,    -1,    -1,   843,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   853,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,    -1,   866,    -1,   868,    -1,    -1,   756,   649,   650,
      -1,   652,    -1,    -1,    -1,   656,     1,    -1,     3,     4,
      -1,   885,     7,     8,     9,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    19,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    -1,    -1,    41,    42,    -1,    -1,
      45,    -1,    47,    48,    49,    50,    51,   708,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    60,    61,    62,    63,    64,
      65,    66,    67,    68,    69,    70,    71,    72,    73,    -1,
      75,    76,    77,    -1,    79,    80,    81,    -1,   739,    -1,
      85,    -1,    87,    88,    89,    90,    91,    92,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   101,    -1,   103,    -1,
      -1,   106,   107,   108,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    41,    -1,    -1,    -1,     3,    -1,    -1,     6,
      -1,   126,    -1,    10,    11,    12,    13,    14,    15,    16,
      17,    18,   793,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    46,
      47,    48,    49,    50,    51,    -1,    53,    96,    97,    98,
      99,   100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,
      -1,    68,    69,    70,   113,   114,   115,   116,   117,   118,
     119,   120,   121,   122,   123,   124,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    -1,    -1,   103,    -1,    -1,   106,
     107,    -1,    -1,    -1,    -1,    -1,    50,    51,    -1,    -1,
     117,    -1,    -1,   120,   121,    -1,    -1,   124,   125,   126,
       3,    -1,    -1,     6,    68,    69,    70,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    -1,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    -1,    -1,    -1,   103,
      -1,    -1,    -1,   107,    47,    48,    49,    50,    51,    -1,
      53,    -1,    -1,    56,    -1,    -1,    -1,    -1,    -1,    -1,
     124,     1,    -1,     3,    -1,    68,    69,    70,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    -1,    -1,
     103,    -1,    -1,    -1,   107,    -1,    46,    47,    48,    49,
      50,    51,    -1,    -1,   117,    -1,    -1,   120,   121,    -1,
      -1,   124,   125,   126,     3,    -1,    -1,     6,    68,    69,
      70,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      -1,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      -1,    -1,    -1,   103,    -1,    -1,   106,   107,    47,    48,
      49,    50,    51,    -1,    53,    -1,    -1,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     1,    -1,     3,    -1,    68,
      69,    70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    -1,    -1,   103,    -1,    -1,    -1,   107,    -1,
      46,    47,    48,    49,    50,    51,    -1,    -1,   117,    -1,
      -1,   120,   121,    -1,    -1,   124,   125,   126,     3,    -1,
      -1,     6,    68,    69,    70,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    -1,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    -1,    -1,    -1,   103,    -1,    -1,
     106,   107,    47,    48,    49,    50,    51,    -1,    53,    -1,
      -1,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     1,
      -1,     3,    -1,    68,    69,    70,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    -1,    -1,   103,    -1,
      -1,    -1,   107,    -1,    -1,    47,    48,    49,    50,    51,
      -1,    -1,   117,    -1,    -1,   120,   121,    -1,    -1,   124,
     125,   126,     3,    -1,    -1,     6,    68,    69,    70,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    -1,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    -1,    -1,
      -1,   103,    -1,    -1,    -1,   107,    47,    48,    49,    50,
      51,    -1,    53,    -1,    -1,    56,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,    -1,    -1,     6,    68,    69,    70,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    -1,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,   103,    -1,    -1,    -1,   107,    47,    48,    49,
      50,    51,    -1,    53,    -1,    -1,   117,    -1,    -1,   120,
     121,    -1,    -1,   124,   125,   126,     3,    -1,    68,    69,
      70,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    -1,   103,    -1,    -1,    -1,   107,    -1,    46,
      47,    48,    49,    50,    51,    -1,    -1,   117,    55,    -1,
     120,   121,    -1,    -1,   124,   125,   126,     3,    -1,    -1,
       6,    68,    69,    70,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    -1,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    -1,    -1,    -1,   103,    -1,    -1,   106,
     107,    47,    48,    49,    50,    51,    -1,    53,    -1,    -1,
     117,    -1,    -1,    -1,    -1,    -1,    -1,   124,     3,    -1,
      -1,     6,    68,    69,    70,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    -1,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    -1,    -1,    -1,   103,    -1,    -1,
      -1,   107,    47,    48,    49,    50,    51,    -1,    53,    -1,
      -1,   117,    -1,    -1,   120,   121,    -1,    -1,   124,   125,
     126,     3,    -1,    68,    69,    70,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    -1,    -1,   103,    -1,
      -1,    -1,   107,    -1,    46,    47,    48,    49,    50,    51,
      74,    -1,    -1,    -1,    -1,   120,   121,    -1,    -1,   124,
     125,   126,    -1,    -1,    -1,    -1,    68,    69,    70,    -1,
      -1,    -1,    96,    97,    98,    99,   100,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,   103,    -1,    -1,   106,   107,    -1,    -1,    -1,     0,
       1,    -1,     3,     4,    -1,   117,     7,     8,     9,    -1,
      -1,    -1,   124,    -1,    -1,    -1,    -1,    -1,    19,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    -1,    -1,    -1,
      41,    42,    -1,    -1,    -1,    -1,    47,    48,    49,    50,
      51,    -1,    -1,    54,    -1,    -1,    -1,    -1,    -1,    60,
      61,    62,    63,    64,    65,    66,    67,    68,    69,    70,
      -1,    -1,    -1,    -1,    75,    76,    77,    -1,    79,    80,
      81,    82,    83,    84,    85,    86,    87,    88,    89,    90,
      91,    92,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     101,     1,   103,     3,     4,   106,   107,     7,     8,     9,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    19,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    -1,    -1,
      -1,    41,    42,    -1,    -1,    45,    -1,    47,    48,    49,
      50,    51,    -1,    -1,    54,    -1,    -1,    -1,    -1,    -1,
      60,    61,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    -1,    -1,    -1,    -1,    75,    76,    77,    -1,    79,
      80,    81,    82,    83,    84,    85,    86,    87,    88,    89,
      90,    91,    92,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   101,     1,   103,     3,     4,   106,   107,     7,     8,
       9,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      19,    20,    21,    22,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    -1,
      -1,    -1,    41,    42,    -1,    -1,    45,    -1,    47,    48,
      49,    50,    51,    -1,    -1,    54,    -1,    -1,    -1,    -1,
      -1,    60,    61,    62,    63,    64,    65,    66,    67,    68,
      69,    70,    -1,    -1,    -1,    -1,    75,    76,    77,    -1,
      79,    80,    81,    82,    83,    84,    85,    86,    87,    88,
      89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   101,     1,   103,     3,     4,   106,   107,     7,
       8,     9,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    19,    20,    21,    22,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      -1,    -1,    -1,    41,    42,    -1,    -1,    45,    -1,    47,
      48,    49,    50,    51,    -1,    -1,    54,    -1,    -1,    -1,
      -1,    -1,    60,    61,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    -1,    -1,    -1,    -1,    75,    76,    77,
      -1,    79,    80,    81,    82,    83,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   101,     1,   103,     3,     4,   106,   107,
       7,     8,     9,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    19,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    -1,    -1,    -1,    41,    42,    -1,    -1,    -1,    -1,
      47,    48,    49,    50,    51,    -1,    -1,    54,    -1,    -1,
      -1,    58,    -1,    60,    61,    62,    63,    64,    65,    66,
      67,    68,    69,    70,    -1,    -1,    -1,    -1,    75,    76,
      77,    -1,    79,    80,    81,    82,    83,    84,    85,    86,
      87,    88,    89,    90,    91,    92,     3,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   101,    -1,   103,    -1,    -1,   106,
     107,    -1,    -1,    20,    21,    22,    23,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    96,    97,    98,    99,   100,    -1,    -1,    -1,    -1,
      47,    48,    49,    50,    51,    -1,    -1,     3,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124,
      -1,    68,    69,    70,    20,    21,    22,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    47,    48,    49,    50,    51,   103,    -1,     3,    -1,
     107,   108,    -1,    -1,    -1,    -1,    11,    -1,    -1,    -1,
      -1,    -1,    68,    69,    70,    20,    21,    22,    23,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    -1,    96,    97,    98,    99,    -1,    -1,
      -1,    46,    47,    48,    49,    50,    51,   103,    -1,     3,
      -1,   107,   108,   115,   116,   117,   118,   119,   120,   121,
     122,   123,   124,    68,    69,    70,    20,    21,    22,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    46,    47,    48,    49,    50,    51,   103,    -1,
       3,   106,   107,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    68,    69,    70,    20,    21,    22,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,   103,
      -1,     3,   106,   107,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    68,    69,    70,    20,    21,
      22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,    51,
     103,    -1,     3,    -1,   107,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,    50,
      51,   103,    -1,     3,    -1,   107,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,    70,
      20,    21,    22,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    47,    48,    49,
      50,    51,   103,    56,    -1,    -1,   107,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    68,    69,
      70,    -1,    20,    21,    22,    23,    24,    25,    26,    27,
      -1,    29,    56,    31,    -1,    -1,    34,    35,    36,    37,
      -1,    -1,    -1,    96,    97,    98,    99,   100,    -1,    -1,
      -1,    -1,    -1,   103,    -1,    -1,    -1,   107,    -1,    -1,
     113,   114,   115,   116,   117,   118,   119,   120,   121,   122,
     123,   124,    96,    97,    98,    99,   100,    56,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,
     114,   115,   116,   117,   118,   119,   120,   121,   122,   123,
     124,    -1,    -1,    -1,    -1,    -1,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    96,    97,    98,
      99,   100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,   114,   115,   116,   117,   118,
     119,   120,   121,   122,   123,   124,    96,    97,    98,    99,
     100,    56,    -1,    -1,    -1,    -1,    -1,    -1,    96,    97,
      98,    99,    -1,   113,   114,   115,   116,   117,   118,   119,
     120,   121,   122,   123,   124,   113,   114,   115,   116,   117,
     118,   119,   120,   121,   122,   123,   124,    -1,    -1,    -1,
      -1,    96,    97,    98,    99,   100,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,   114,
     115,   116,   117,   118,   119,   120,   121,   122,   123,   124
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint16 yystos[] =
{
       0,   109,   110,   111,   130,   131,   276,     1,     3,    20,
      21,    22,    23,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    46,    47,    48,
      49,    50,    51,    68,    69,    70,   103,   106,   107,   215,
     229,   230,   232,   233,   234,   235,   236,   255,   256,   266,
     268,     1,   215,     1,    38,     0,     1,     4,     7,     8,
       9,    19,    41,    42,    54,    60,    61,    62,    63,    64,
      65,    66,    67,    75,    76,    77,    79,    80,    81,    82,
      83,    84,    85,    86,    87,    88,    89,    90,    91,    92,
     101,   106,   132,   133,   134,   136,   137,   138,   139,   140,
     143,   144,   146,   147,   148,   149,   150,   151,   152,   155,
     156,   157,   160,   162,   167,   168,   169,   170,   172,   175,
     176,   177,   178,   179,   183,   184,   191,   192,   202,   211,
     276,    93,   263,   276,   263,    46,   266,   128,    93,    41,
     233,   229,    38,    52,    55,    74,   117,   124,   126,   220,
     221,   223,   225,   226,   227,   228,   266,   276,   229,   235,
     266,   105,   128,   267,    41,    41,   212,   213,   215,   276,
     108,    38,     6,   271,    38,   273,   276,     1,     3,   231,
     232,    38,   273,    38,   154,   276,    38,    38,    38,    82,
     266,     3,    44,   266,    38,     4,    44,    38,    38,    41,
      44,     4,   271,    38,   166,   231,   164,   166,    38,    38,
     271,    38,    93,   256,   273,    38,   117,   223,   228,   266,
      68,   231,   256,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    38,    53,   117,   120,   121,   124,   125,   126,
     215,   216,   217,   219,   231,   232,   243,   244,   245,   246,
     271,   276,    46,   107,   268,   256,   229,    38,   117,   212,
     226,   228,   266,    44,   237,   238,    56,   243,   244,   243,
      38,   126,   224,   227,   266,   228,   229,   266,   220,    38,
      55,   220,    38,    55,   117,   224,   227,   266,   104,   268,
     107,   268,    39,    40,   214,   276,     3,   264,   271,     6,
      44,   264,   274,   264,    41,    52,    38,   223,    39,   264,
     266,     3,     3,   264,    11,   161,   212,   212,   266,    41,
      52,   194,    44,     3,   163,   274,     3,   212,    44,   222,
     223,   226,   276,    41,    40,   165,   276,   264,   265,   276,
     141,   142,   271,   212,   187,   188,   189,   215,   255,   276,
     266,   271,     3,   117,   228,   266,   274,    38,   264,   117,
     266,   104,     3,   239,   276,    38,   223,    44,   266,   243,
      38,   243,   243,   243,   243,   243,   243,    94,    40,   218,
     276,    38,    96,    97,    98,    99,   100,   113,   114,   115,
     116,   117,   118,   119,   120,   121,   122,   123,   124,   267,
      94,   117,   228,   266,   225,   266,    39,    39,   117,   225,
     266,   104,    55,   243,    56,   228,   266,   266,    38,    55,
     228,   212,    56,   243,   212,    56,   243,   224,   227,   104,
     117,   224,   267,    41,   215,    39,   171,    40,    52,    39,
     237,   220,    39,    44,    39,    52,    39,    40,   159,    40,
      39,    39,    41,   266,   131,   193,    39,    39,    39,    39,
     164,   166,    39,    39,    40,    44,    39,    94,    40,   190,
     276,    57,   104,    39,   228,   266,    41,   104,    41,    44,
     212,   266,    78,   174,   220,   229,   181,    41,    74,   247,
     248,   276,    39,   117,   124,   228,   231,   219,   243,   243,
     243,   243,   243,   243,   243,   243,   243,   243,   243,   243,
     243,   243,   243,   243,   243,   256,   266,   104,    39,    39,
     104,   225,   243,   224,   266,    39,   104,   212,    56,   243,
      39,    56,    39,    56,   117,   224,   227,   224,   214,     4,
      44,   271,   131,   274,   141,   245,   271,   275,    41,    41,
     135,     4,   153,   271,     4,    41,    44,   102,   158,   223,
     271,   272,   264,   271,   275,    39,   215,   223,    44,    41,
      45,   131,    42,   211,   164,    41,    44,    38,    45,   165,
       3,   103,   107,   269,    41,   274,   215,   158,   185,   189,
     145,   223,   271,   104,     3,   240,   241,   276,    39,    38,
      40,    41,    44,   173,    78,   220,     1,    41,    64,    71,
      72,    73,    76,   126,   136,   137,   138,   139,   143,   144,
     148,   150,   152,   155,   157,   160,   162,   167,   168,   169,
     170,   183,   184,   191,   195,   198,   199,   200,   201,   202,
     203,   204,   207,   210,   211,   276,   249,    44,   243,    39,
     124,   229,    39,   117,   221,   218,    74,   266,    39,    56,
      39,   224,    39,    56,   224,    45,    40,    40,   195,    38,
      78,   229,   258,   276,    52,    39,    40,   159,   158,   223,
     258,    45,   271,     3,   231,    41,    52,   272,   212,   105,
     128,   270,   128,    93,    39,    45,   172,   179,   183,   184,
     186,   199,   201,   211,   190,   131,   258,    41,    52,    40,
      45,    38,    52,   258,   259,   212,   223,    38,   197,    44,
      74,    74,    74,   126,   268,    45,   195,   108,   231,   256,
     266,    76,   250,   251,   257,   276,   180,   243,   243,    39,
      39,   243,   220,    39,   274,   274,    45,   212,    38,    78,
     158,   271,   275,    41,   223,    39,   258,    41,    41,   223,
     166,    39,     3,     3,   107,     3,   107,   216,     4,    44,
     231,    58,    41,   242,   243,   241,    41,   223,   212,   237,
      74,   260,   276,    39,   174,   212,   195,   196,   268,    38,
     223,   231,    38,    74,   247,   266,    41,    40,    71,    72,
      73,   252,   254,   195,   243,    39,   212,    38,   159,   258,
      41,   223,   158,    41,    41,   270,   270,    94,   174,    39,
      41,   261,   262,   266,    41,    44,   220,   173,    39,   195,
      38,   212,   174,    38,   117,   228,   212,   243,    44,   247,
     251,   266,   253,    45,    41,    39,   212,    41,   258,    41,
     173,    41,    44,    40,    38,   220,    45,   212,    39,   173,
     212,    38,    38,   117,    39,    41,   206,    44,   257,    41,
     182,   223,    39,    41,   262,   195,    39,   208,   258,    39,
     212,   212,    38,   259,   182,   205,   266,   174,   209,   258,
      41,    44,   209,    39,    39,   212,   182,   173,    41,    44,
      52,   209,   209,    39,   237,   209,    41
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
#line 1747 "parser.y"
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
#line 1760 "parser.y"
    {
                 top = Copy(Getattr((yyvsp[(2) - (3)].p),"type"));
		 Delete((yyvsp[(2) - (3)].p));
               ;}
    break;

  case 4:

/* Line 1455 of yacc.c  */
#line 1764 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 5:

/* Line 1455 of yacc.c  */
#line 1767 "parser.y"
    {
                 top = (yyvsp[(2) - (3)].p);
               ;}
    break;

  case 6:

/* Line 1455 of yacc.c  */
#line 1770 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 7:

/* Line 1455 of yacc.c  */
#line 1773 "parser.y"
    {
                 top = (yyvsp[(3) - (5)].pl);
               ;}
    break;

  case 8:

/* Line 1455 of yacc.c  */
#line 1776 "parser.y"
    {
                 top = 0;
               ;}
    break;

  case 9:

/* Line 1455 of yacc.c  */
#line 1781 "parser.y"
    {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   appendChild((yyvsp[(1) - (2)].node),(yyvsp[(2) - (2)].node));
                   (yyval.node) = (yyvsp[(1) - (2)].node);
               ;}
    break;

  case 10:

/* Line 1455 of yacc.c  */
#line 1786 "parser.y"
    {
                   (yyval.node) = new_node("top");
               ;}
    break;

  case 11:

/* Line 1455 of yacc.c  */
#line 1791 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 12:

/* Line 1455 of yacc.c  */
#line 1792 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 13:

/* Line 1455 of yacc.c  */
#line 1793 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 14:

/* Line 1455 of yacc.c  */
#line 1794 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 15:

/* Line 1455 of yacc.c  */
#line 1795 "parser.y"
    {
                  (yyval.node) = 0;
		  Swig_error(cparse_file, cparse_line,"Syntax error in input(1).\n");
		  exit(1);
               ;}
    break;

  case 16:

/* Line 1455 of yacc.c  */
#line 1801 "parser.y"
    { 
                  if ((yyval.node)) {
   		      add_symbols((yyval.node));
                  }
                  (yyval.node) = (yyvsp[(1) - (1)].node); 
	       ;}
    break;

  case 17:

/* Line 1455 of yacc.c  */
#line 1817 "parser.y"
    {
                  (yyval.node) = 0;
                  skip_decl();
               ;}
    break;

  case 18:

/* Line 1455 of yacc.c  */
#line 1827 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 19:

/* Line 1455 of yacc.c  */
#line 1828 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 20:

/* Line 1455 of yacc.c  */
#line 1829 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 21:

/* Line 1455 of yacc.c  */
#line 1830 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 22:

/* Line 1455 of yacc.c  */
#line 1831 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 23:

/* Line 1455 of yacc.c  */
#line 1832 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 24:

/* Line 1455 of yacc.c  */
#line 1833 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 25:

/* Line 1455 of yacc.c  */
#line 1834 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 26:

/* Line 1455 of yacc.c  */
#line 1835 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 27:

/* Line 1455 of yacc.c  */
#line 1836 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 28:

/* Line 1455 of yacc.c  */
#line 1837 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 29:

/* Line 1455 of yacc.c  */
#line 1838 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 30:

/* Line 1455 of yacc.c  */
#line 1839 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 31:

/* Line 1455 of yacc.c  */
#line 1840 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 32:

/* Line 1455 of yacc.c  */
#line 1841 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 33:

/* Line 1455 of yacc.c  */
#line 1842 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 34:

/* Line 1455 of yacc.c  */
#line 1843 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 35:

/* Line 1455 of yacc.c  */
#line 1844 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 36:

/* Line 1455 of yacc.c  */
#line 1845 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 37:

/* Line 1455 of yacc.c  */
#line 1846 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 38:

/* Line 1455 of yacc.c  */
#line 1847 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 39:

/* Line 1455 of yacc.c  */
#line 1854 "parser.y"
    {
               Node *cls;
	       String *clsname;
	       cplus_mode = CPLUS_PUBLIC;
	       if (!classes) classes = NewHash();
	       if (!extendhash) extendhash = NewHash();
	       clsname = make_class_name((yyvsp[(3) - (4)].str));
	       cls = Getattr(classes,clsname);
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
#line 1882 "parser.y"
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
#line 1926 "parser.y"
    {
                    (yyval.node) = new_node("apply");
                    Setattr((yyval.node),"pattern",Getattr((yyvsp[(2) - (5)].p),"pattern"));
		    appendChild((yyval.node),(yyvsp[(4) - (5)].p));
               ;}
    break;

  case 42:

/* Line 1455 of yacc.c  */
#line 1936 "parser.y"
    {
		 (yyval.node) = new_node("clear");
		 appendChild((yyval.node),(yyvsp[(2) - (3)].p));
               ;}
    break;

  case 43:

/* Line 1455 of yacc.c  */
#line 1947 "parser.y"
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
#line 1968 "parser.y"
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
#line 1990 "parser.y"
    {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 (yyval.node) = 0;
	       ;}
    break;

  case 46:

/* Line 1455 of yacc.c  */
#line 2001 "parser.y"
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
#line 2010 "parser.y"
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
#line 2029 "parser.y"
    {
                    skip_balanced('{','}');
		    (yyval.node) = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       ;}
    break;

  case 49:

/* Line 1455 of yacc.c  */
#line 2035 "parser.y"
    {
                    skip_balanced('{','}');
		    (yyval.node) = 0;
		    Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               ;}
    break;

  case 50:

/* Line 1455 of yacc.c  */
#line 2041 "parser.y"
    {
		 (yyval.node) = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
               ;}
    break;

  case 51:

/* Line 1455 of yacc.c  */
#line 2046 "parser.y"
    {
		 (yyval.node) = 0;
		 Swig_warning(WARN_DEPRECATED_EXCEPT,cparse_file, cparse_line, "%%except is deprecated.  Use %%exception instead.\n");
	       ;}
    break;

  case 52:

/* Line 1455 of yacc.c  */
#line 2053 "parser.y"
    {		 
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[(1) - (4)].id));
		 Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (4)].p),"type"));
               ;}
    break;

  case 53:

/* Line 1455 of yacc.c  */
#line 2060 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[(1) - (1)].id));
              ;}
    break;

  case 54:

/* Line 1455 of yacc.c  */
#line 2064 "parser.y"
    {
                (yyval.node) = (yyvsp[(1) - (1)].node);
              ;}
    break;

  case 55:

/* Line 1455 of yacc.c  */
#line 2077 "parser.y"
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
#line 2086 "parser.y"
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
#line 2101 "parser.y"
    {
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[(3) - (5)].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[(3) - (5)].node),"type"));
		   Setattr((yyval.node),"emitonly","1");
		 ;}
    break;

  case 58:

/* Line 1455 of yacc.c  */
#line 2114 "parser.y"
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
#line 2123 "parser.y"
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
#line 2169 "parser.y"
    { (yyval.loc).type = (char *) "include"; ;}
    break;

  case 61:

/* Line 1455 of yacc.c  */
#line 2170 "parser.y"
    { (yyval.loc).type = (char *) "import"; ++import_mode;;}
    break;

  case 62:

/* Line 1455 of yacc.c  */
#line 2177 "parser.y"
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
#line 2196 "parser.y"
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
#line 2227 "parser.y"
    {
                 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"code",(yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 65:

/* Line 1455 of yacc.c  */
#line 2231 "parser.y"
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
#line 2241 "parser.y"
    {
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[(3) - (5)].id));
		 Setattr((yyval.node),"code",(yyvsp[(5) - (5)].str));
               ;}
    break;

  case 67:

/* Line 1455 of yacc.c  */
#line 2246 "parser.y"
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
#line 2264 "parser.y"
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
#line 2304 "parser.y"
    {
                 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 Delete(yyrename);
                 yyrename = NewString((yyvsp[(3) - (4)].id));
		 (yyval.node) = 0;
               ;}
    break;

  case 70:

/* Line 1455 of yacc.c  */
#line 2310 "parser.y"
    {
		 Swig_warning(WARN_DEPRECATED_NAME,cparse_file,cparse_line, "%%name is deprecated.  Use %%rename instead.\n");
		 (yyval.node) = 0;
		 Swig_error(cparse_file,cparse_line,"Missing argument to %%name directive.\n");
	       ;}
    break;

  case 71:

/* Line 1455 of yacc.c  */
#line 2323 "parser.y"
    {
                 (yyval.node) = new_node("native");
		 Setattr((yyval.node),"name",(yyvsp[(3) - (7)].id));
		 Setattr((yyval.node),"wrap:name",(yyvsp[(6) - (7)].id));
	         add_symbols((yyval.node));
	       ;}
    break;

  case 72:

/* Line 1455 of yacc.c  */
#line 2329 "parser.y"
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
#line 2355 "parser.y"
    {
                 (yyval.node) = new_node("pragma");
		 Setattr((yyval.node),"lang",(yyvsp[(2) - (5)].id));
		 Setattr((yyval.node),"name",(yyvsp[(3) - (5)].id));
		 Setattr((yyval.node),"value",(yyvsp[(5) - (5)].str));
	       ;}
    break;

  case 74:

/* Line 1455 of yacc.c  */
#line 2361 "parser.y"
    {
		(yyval.node) = new_node("pragma");
		Setattr((yyval.node),"lang",(yyvsp[(2) - (3)].id));
		Setattr((yyval.node),"name",(yyvsp[(3) - (3)].id));
	      ;}
    break;

  case 75:

/* Line 1455 of yacc.c  */
#line 2368 "parser.y"
    { (yyval.str) = NewString((yyvsp[(1) - (1)].id)); ;}
    break;

  case 76:

/* Line 1455 of yacc.c  */
#line 2369 "parser.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); ;}
    break;

  case 77:

/* Line 1455 of yacc.c  */
#line 2372 "parser.y"
    { (yyval.id) = (yyvsp[(2) - (3)].id); ;}
    break;

  case 78:

/* Line 1455 of yacc.c  */
#line 2373 "parser.y"
    { (yyval.id) = (char *) "swig"; ;}
    break;

  case 79:

/* Line 1455 of yacc.c  */
#line 2381 "parser.y"
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
#line 2427 "parser.y"
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
#line 2473 "parser.y"
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
#line 2484 "parser.y"
    {
		    (yyval.intvalue) = 1;
                ;}
    break;

  case 83:

/* Line 1455 of yacc.c  */
#line 2487 "parser.y"
    {
                    (yyval.intvalue) = 0;
                ;}
    break;

  case 84:

/* Line 1455 of yacc.c  */
#line 2514 "parser.y"
    {
                    String *val = (yyvsp[(7) - (7)].str) ? NewString((yyvsp[(7) - (7)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (7)].id), val, 0, (yyvsp[(5) - (7)].decl).id, (yyvsp[(5) - (7)].decl).type, (yyvsp[(5) - (7)].decl).parms, (yyvsp[(6) - (7)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 85:

/* Line 1455 of yacc.c  */
#line 2520 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (9)].id)) ? NewString((yyvsp[(5) - (9)].id)) : 0;
                    new_feature((yyvsp[(3) - (9)].id), val, 0, (yyvsp[(7) - (9)].decl).id, (yyvsp[(7) - (9)].decl).type, (yyvsp[(7) - (9)].decl).parms, (yyvsp[(8) - (9)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 86:

/* Line 1455 of yacc.c  */
#line 2526 "parser.y"
    {
                    String *val = (yyvsp[(8) - (8)].str) ? NewString((yyvsp[(8) - (8)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (8)].id), val, (yyvsp[(4) - (8)].node), (yyvsp[(6) - (8)].decl).id, (yyvsp[(6) - (8)].decl).type, (yyvsp[(6) - (8)].decl).parms, (yyvsp[(7) - (8)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 87:

/* Line 1455 of yacc.c  */
#line 2532 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (10)].id)) ? NewString((yyvsp[(5) - (10)].id)) : 0;
                    new_feature((yyvsp[(3) - (10)].id), val, (yyvsp[(6) - (10)].node), (yyvsp[(8) - (10)].decl).id, (yyvsp[(8) - (10)].decl).type, (yyvsp[(8) - (10)].decl).parms, (yyvsp[(9) - (10)].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 88:

/* Line 1455 of yacc.c  */
#line 2540 "parser.y"
    {
                    String *val = (yyvsp[(5) - (5)].str) ? NewString((yyvsp[(5) - (5)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (5)].id), val, 0, 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 89:

/* Line 1455 of yacc.c  */
#line 2546 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (7)].id)) ? NewString((yyvsp[(5) - (7)].id)) : 0;
                    new_feature((yyvsp[(3) - (7)].id), val, 0, 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 90:

/* Line 1455 of yacc.c  */
#line 2552 "parser.y"
    {
                    String *val = (yyvsp[(6) - (6)].str) ? NewString((yyvsp[(6) - (6)].str)) : NewString("1");
                    new_feature((yyvsp[(3) - (6)].id), val, (yyvsp[(4) - (6)].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 91:

/* Line 1455 of yacc.c  */
#line 2558 "parser.y"
    {
                    String *val = Len((yyvsp[(5) - (8)].id)) ? NewString((yyvsp[(5) - (8)].id)) : 0;
                    new_feature((yyvsp[(3) - (8)].id), val, (yyvsp[(6) - (8)].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  ;}
    break;

  case 92:

/* Line 1455 of yacc.c  */
#line 2566 "parser.y"
    { (yyval.str) = (yyvsp[(1) - (1)].str); ;}
    break;

  case 93:

/* Line 1455 of yacc.c  */
#line 2567 "parser.y"
    { (yyval.str) = 0; ;}
    break;

  case 94:

/* Line 1455 of yacc.c  */
#line 2568 "parser.y"
    { (yyval.str) = (yyvsp[(3) - (5)].pl); ;}
    break;

  case 95:

/* Line 1455 of yacc.c  */
#line 2571 "parser.y"
    {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[(2) - (4)].id));
		  Setattr((yyval.node),"value",(yyvsp[(4) - (4)].id));
                ;}
    break;

  case 96:

/* Line 1455 of yacc.c  */
#line 2576 "parser.y"
    {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[(2) - (5)].id));
		  Setattr((yyval.node),"value",(yyvsp[(4) - (5)].id));
                  set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
                ;}
    break;

  case 97:

/* Line 1455 of yacc.c  */
#line 2586 "parser.y"
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
#line 2622 "parser.y"
    { (yyval.pl) = (yyvsp[(1) - (1)].pl); ;}
    break;

  case 99:

/* Line 1455 of yacc.c  */
#line 2623 "parser.y"
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
#line 2658 "parser.y"
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
#line 2675 "parser.y"
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
#line 2683 "parser.y"
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
#line 2696 "parser.y"
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
#line 2721 "parser.y"
    {
                 (yyval.p) = (yyvsp[(1) - (2)].p);
		 set_nextSibling((yyval.p),(yyvsp[(2) - (2)].p));
		;}
    break;

  case 105:

/* Line 1455 of yacc.c  */
#line 2727 "parser.y"
    {
                 (yyval.p) = (yyvsp[(2) - (3)].p);
		 set_nextSibling((yyval.p),(yyvsp[(3) - (3)].p));
                ;}
    break;

  case 106:

/* Line 1455 of yacc.c  */
#line 2731 "parser.y"
    { (yyval.p) = 0;;}
    break;

  case 107:

/* Line 1455 of yacc.c  */
#line 2734 "parser.y"
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
#line 2745 "parser.y"
    {
                  (yyval.p) = new_node("typemapitem");
		  Setattr((yyval.p),"pattern",(yyvsp[(2) - (3)].pl));
		  /*		  Setattr($$,"multitype",$2); */
               ;}
    break;

  case 109:

/* Line 1455 of yacc.c  */
#line 2750 "parser.y"
    {
		 (yyval.p) = new_node("typemapitem");
		 Setattr((yyval.p),"pattern", (yyvsp[(2) - (6)].pl));
		 /*                 Setattr($$,"multitype",$2); */
		 Setattr((yyval.p),"parms",(yyvsp[(5) - (6)].pl));
               ;}
    break;

  case 110:

/* Line 1455 of yacc.c  */
#line 2763 "parser.y"
    {
                   (yyval.node) = new_node("types");
		   Setattr((yyval.node),"parms",(yyvsp[(3) - (5)].pl));
                   if ((yyvsp[(5) - (5)].str))
		     Setattr((yyval.node),"convcode",NewString((yyvsp[(5) - (5)].str)));
               ;}
    break;

  case 111:

/* Line 1455 of yacc.c  */
#line 2775 "parser.y"
    {
                  Parm *p, *tp;
		  Node *n;
		  Symtab *tscope = 0;
		  int     specialized = 0;

		  (yyval.node) = 0;

		  tscope = Swig_symbol_current();          /* Get the current scope */

		  /* If the class name is qualified, we need to create or lookup namespace entries */
		  if (!inclass) {
		    (yyvsp[(5) - (9)].str) = resolve_node_scope((yyvsp[(5) - (9)].str));
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
#line 3049 "parser.y"
    {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", (yyvsp[(2) - (2)].id));
		  (yyval.node) = 0;
               ;}
    break;

  case 113:

/* Line 1455 of yacc.c  */
#line 3059 "parser.y"
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
#line 3066 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 115:

/* Line 1455 of yacc.c  */
#line 3067 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 116:

/* Line 1455 of yacc.c  */
#line 3071 "parser.y"
    {
		  if (Strcmp((yyvsp[(2) - (3)].id),"C") == 0) {
		    cparse_externc = 1;
		  }
		;}
    break;

  case 117:

/* Line 1455 of yacc.c  */
#line 3075 "parser.y"
    {
		  cparse_externc = 0;
		  if (Strcmp((yyvsp[(2) - (6)].id),"C") == 0) {
		    Node *n = firstChild((yyvsp[(5) - (6)].node));
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[(2) - (6)].id));
		    appendChild((yyval.node),n);
		    while (n) {
		      SwigType *decl = Getattr(n,"decl");
		      if (SwigType_isfunction(decl) && Strcmp(Getattr(n, "storage"), "typedef") != 0) {
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
#line 3102 "parser.y"
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
#line 3163 "parser.y"
    { 
                   (yyval.node) = 0;
                   Clear(scanner_ccode); 
               ;}
    break;

  case 120:

/* Line 1455 of yacc.c  */
#line 3167 "parser.y"
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
#line 3189 "parser.y"
    { 
                   skip_balanced('{','}');
                   (yyval.node) = 0;
               ;}
    break;

  case 122:

/* Line 1455 of yacc.c  */
#line 3195 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(1) - (1)].dtype); 
                   (yyval.dtype).qualifier = 0;
		   (yyval.dtype).throws = 0;
		   (yyval.dtype).throwf = 0;
              ;}
    break;

  case 123:

/* Line 1455 of yacc.c  */
#line 3201 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(2) - (2)].dtype); 
		   (yyval.dtype).qualifier = (yyvsp[(1) - (2)].str);
		   (yyval.dtype).throws = 0;
		   (yyval.dtype).throwf = 0;
	      ;}
    break;

  case 124:

/* Line 1455 of yacc.c  */
#line 3207 "parser.y"
    { 
		   (yyval.dtype) = (yyvsp[(5) - (5)].dtype); 
                   (yyval.dtype).qualifier = 0;
		   (yyval.dtype).throws = (yyvsp[(3) - (5)].pl);
		   (yyval.dtype).throwf = NewString("1");
              ;}
    break;

  case 125:

/* Line 1455 of yacc.c  */
#line 3213 "parser.y"
    { 
                   (yyval.dtype) = (yyvsp[(6) - (6)].dtype); 
                   (yyval.dtype).qualifier = (yyvsp[(1) - (6)].str);
		   (yyval.dtype).throws = (yyvsp[(4) - (6)].pl);
		   (yyval.dtype).throwf = NewString("1");
              ;}
    break;

  case 126:

/* Line 1455 of yacc.c  */
#line 3226 "parser.y"
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
#line 3241 "parser.y"
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
#line 3251 "parser.y"
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
#line 3329 "parser.y"
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
#line 3380 "parser.y"
    {  (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 131:

/* Line 1455 of yacc.c  */
#line 3381 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 132:

/* Line 1455 of yacc.c  */
#line 3382 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 133:

/* Line 1455 of yacc.c  */
#line 3383 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 134:

/* Line 1455 of yacc.c  */
#line 3384 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 135:

/* Line 1455 of yacc.c  */
#line 3385 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 136:

/* Line 1455 of yacc.c  */
#line 3390 "parser.y"
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
		   scope = resolve_node_scope((yyvsp[(3) - (5)].str));
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
#line 3507 "parser.y"
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
		   Setattr((yyval.node),"abstract", pure_abstract((yyvsp[(7) - (9)].node)));
		   
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
		   Delete(scpname);

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
		   /* Dump nested classes */
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
			   if (!Getattr(classes,tdscopename)) {
			     Setattr(classes,tdscopename,(yyval.node));
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
#line 3638 "parser.y"
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
#line 3672 "parser.y"
    {
	       String *unnamed;
	       Node *n;
	       (void) (yyvsp[(4) - (9)].node);
	       Classprefix = 0;
	       (yyval.node) = class_decl[--class_level];
	       inclass = 0;
	       unnamed = Getattr((yyval.node),"unnamed");

	       /* Check for pure-abstract class */
	       Setattr((yyval.node),"abstract", pure_abstract((yyvsp[(5) - (9)].node)));

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
#line 3761 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 141:

/* Line 1455 of yacc.c  */
#line 3762 "parser.y"
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
#line 3774 "parser.y"
    {
              if ((yyvsp[(1) - (4)].id) && (Strcmp((yyvsp[(1) - (4)].id),"friend") == 0)) {
		/* Ignore */
                (yyval.node) = 0; 
	      } else {
		(yyval.node) = new_node("classforward");
		Setfile((yyval.node),cparse_file);
		Setline((yyval.node),cparse_line);
		Setattr((yyval.node),"kind",(yyvsp[(2) - (4)].id));
		Setattr((yyval.node),"name",(yyvsp[(3) - (4)].str));
		Setattr((yyval.node),"sym:weak", "1");
		add_symbols((yyval.node));
	      }
             ;}
    break;

  case 143:

/* Line 1455 of yacc.c  */
#line 3794 "parser.y"
    { 
		    template_parameters = (yyvsp[(3) - (4)].tparms); 
		    if (inclass)
		      nested_template++;

		  ;}
    break;

  case 144:

/* Line 1455 of yacc.c  */
#line 3799 "parser.y"
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
#line 4083 "parser.y"
    {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                   (yyval.node) = 0; 
                ;}
    break;

  case 146:

/* Line 1455 of yacc.c  */
#line 4089 "parser.y"
    {
		  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 147:

/* Line 1455 of yacc.c  */
#line 4092 "parser.y"
    {
                   (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 148:

/* Line 1455 of yacc.c  */
#line 4095 "parser.y"
    {
                   (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 149:

/* Line 1455 of yacc.c  */
#line 4098 "parser.y"
    {
		  (yyval.node) = 0;
                ;}
    break;

  case 150:

/* Line 1455 of yacc.c  */
#line 4101 "parser.y"
    {
                  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 151:

/* Line 1455 of yacc.c  */
#line 4104 "parser.y"
    {
                  (yyval.node) = (yyvsp[(1) - (1)].node);
                ;}
    break;

  case 152:

/* Line 1455 of yacc.c  */
#line 4109 "parser.y"
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
#line 4139 "parser.y"
    {
                      set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].pl));
                      (yyval.pl) = (yyvsp[(1) - (2)].p);
                   ;}
    break;

  case 154:

/* Line 1455 of yacc.c  */
#line 4143 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 155:

/* Line 1455 of yacc.c  */
#line 4146 "parser.y"
    {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewString((yyvsp[(1) - (1)].id)), 0);
                  ;}
    break;

  case 156:

/* Line 1455 of yacc.c  */
#line 4149 "parser.y"
    {
                    (yyval.p) = (yyvsp[(1) - (1)].p);
                  ;}
    break;

  case 157:

/* Line 1455 of yacc.c  */
#line 4154 "parser.y"
    {
                         set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].pl));
                         (yyval.pl) = (yyvsp[(2) - (3)].p);
                       ;}
    break;

  case 158:

/* Line 1455 of yacc.c  */
#line 4158 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 159:

/* Line 1455 of yacc.c  */
#line 4163 "parser.y"
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
#line 4173 "parser.y"
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
#line 4204 "parser.y"
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
#line 4222 "parser.y"
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
#line 4233 "parser.y"
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
#line 4245 "parser.y"
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
#line 4255 "parser.y"
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
#line 4282 "parser.y"
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
#line 4297 "parser.y"
    { 
                  if (cplus_mode != CPLUS_PUBLIC) {
		     Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
		  }
             ;}
    break;

  case 168:

/* Line 1455 of yacc.c  */
#line 4301 "parser.y"
    {
	       (yyval.node) = new_node("extend");
	       tag_nodes((yyvsp[(4) - (6)].node),"feature:extend",(char*) "1");
	       appendChild((yyval.node),(yyvsp[(4) - (6)].node));
	       set_nextSibling((yyval.node),(yyvsp[(6) - (6)].node));
	     ;}
    break;

  case 169:

/* Line 1455 of yacc.c  */
#line 4307 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 170:

/* Line 1455 of yacc.c  */
#line 4308 "parser.y"
    { (yyval.node) = 0;;}
    break;

  case 171:

/* Line 1455 of yacc.c  */
#line 4309 "parser.y"
    {
	       int start_line = cparse_line;
	       skip_decl();
	       Swig_error(cparse_file,start_line,"Syntax error in input(3).\n");
	       exit(1);
	       ;}
    break;

  case 172:

/* Line 1455 of yacc.c  */
#line 4314 "parser.y"
    { 
		 (yyval.node) = (yyvsp[(3) - (3)].node);
   	     ;}
    break;

  case 173:

/* Line 1455 of yacc.c  */
#line 4325 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 174:

/* Line 1455 of yacc.c  */
#line 4326 "parser.y"
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
#line 4343 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 176:

/* Line 1455 of yacc.c  */
#line 4344 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 177:

/* Line 1455 of yacc.c  */
#line 4345 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 178:

/* Line 1455 of yacc.c  */
#line 4346 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 179:

/* Line 1455 of yacc.c  */
#line 4347 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 180:

/* Line 1455 of yacc.c  */
#line 4348 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 181:

/* Line 1455 of yacc.c  */
#line 4349 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 182:

/* Line 1455 of yacc.c  */
#line 4350 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 183:

/* Line 1455 of yacc.c  */
#line 4351 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 184:

/* Line 1455 of yacc.c  */
#line 4352 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 185:

/* Line 1455 of yacc.c  */
#line 4353 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 186:

/* Line 1455 of yacc.c  */
#line 4354 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 187:

/* Line 1455 of yacc.c  */
#line 4355 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 188:

/* Line 1455 of yacc.c  */
#line 4356 "parser.y"
    {(yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 189:

/* Line 1455 of yacc.c  */
#line 4357 "parser.y"
    {(yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 190:

/* Line 1455 of yacc.c  */
#line 4358 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 191:

/* Line 1455 of yacc.c  */
#line 4367 "parser.y"
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
#line 4392 "parser.y"
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
#line 4416 "parser.y"
    {
		String *name;
		char *c = 0;
		(yyval.node) = new_node("destructor");
	       /* Check for template names.  If the class is a template
		  and the constructor is missing the template part, we
		  add it */
	        if (Classprefix) {
                  c = strchr(Char(Classprefix),'<');
                  if (c && !Strchr((yyvsp[(3) - (7)].str),'<')) {
                    (yyvsp[(3) - (7)].str) = NewStringf("%s%s",(yyvsp[(3) - (7)].str),c);
                  }
		}
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
#line 4457 "parser.y"
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
#line 4472 "parser.y"
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
#line 4490 "parser.y"
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
#line 4509 "parser.y"
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
#line 4528 "parser.y"
    {
                 skip_balanced('{','}');
                 (yyval.node) = 0;
               ;}
    break;

  case 199:

/* Line 1455 of yacc.c  */
#line 4535 "parser.y"
    { 
                (yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              ;}
    break;

  case 200:

/* Line 1455 of yacc.c  */
#line 4542 "parser.y"
    { 
                (yyval.node) = new_node("access");
                Setattr((yyval.node),"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      ;}
    break;

  case 201:

/* Line 1455 of yacc.c  */
#line 4550 "parser.y"
    { 
		(yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      ;}
    break;

  case 202:

/* Line 1455 of yacc.c  */
#line 4571 "parser.y"
    {
		cparse_start_line = cparse_line;
		skip_balanced('{','}');
		(yyval.str) = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      ;}
    break;

  case 203:

/* Line 1455 of yacc.c  */
#line 4575 "parser.y"
    {
	        (yyval.node) = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    (yyval.node) = nested_forward_declaration((yyvsp[(1) - (7)].id), (yyvsp[(2) - (7)].id), (yyvsp[(3) - (7)].str), (yyvsp[(3) - (7)].str), (yyvsp[(7) - (7)].node));
		  } else if ((yyvsp[(7) - (7)].node)) {
		    nested_new_struct((yyvsp[(2) - (7)].id), (yyvsp[(6) - (7)].str), (yyvsp[(7) - (7)].node));
		  }
		}
		Delete((yyvsp[(6) - (7)].str));
	      ;}
    break;

  case 204:

/* Line 1455 of yacc.c  */
#line 4597 "parser.y"
    {
		cparse_start_line = cparse_line;
		skip_balanced('{','}');
		(yyval.str) = NewString(scanner_ccode); /* copied as initializers overwrite scanner_ccode */
	      ;}
    break;

  case 205:

/* Line 1455 of yacc.c  */
#line 4601 "parser.y"
    {
	        (yyval.node) = 0;
		if (cplus_mode == CPLUS_PUBLIC) {
		  if (cparse_cplusplus) {
		    const char *name = (yyvsp[(6) - (6)].node) ? Getattr((yyvsp[(6) - (6)].node), "name") : 0;
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
#line 4633 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 207:

/* Line 1455 of yacc.c  */
#line 4636 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 208:

/* Line 1455 of yacc.c  */
#line 4640 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 209:

/* Line 1455 of yacc.c  */
#line 4643 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 210:

/* Line 1455 of yacc.c  */
#line 4644 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 211:

/* Line 1455 of yacc.c  */
#line 4645 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 212:

/* Line 1455 of yacc.c  */
#line 4646 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 213:

/* Line 1455 of yacc.c  */
#line 4647 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 214:

/* Line 1455 of yacc.c  */
#line 4648 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 215:

/* Line 1455 of yacc.c  */
#line 4649 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 216:

/* Line 1455 of yacc.c  */
#line 4650 "parser.y"
    { (yyval.node) = (yyvsp[(1) - (1)].node); ;}
    break;

  case 217:

/* Line 1455 of yacc.c  */
#line 4653 "parser.y"
    {
	            Clear(scanner_ccode);
		    (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws;
		    (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf;
               ;}
    break;

  case 218:

/* Line 1455 of yacc.c  */
#line 4658 "parser.y"
    { 
		    skip_balanced('{','}'); 
		    (yyval.dtype).throws = (yyvsp[(1) - (2)].dtype).throws;
		    (yyval.dtype).throwf = (yyvsp[(1) - (2)].dtype).throwf;
	       ;}
    break;

  case 219:

/* Line 1455 of yacc.c  */
#line 4665 "parser.y"
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
#line 4673 "parser.y"
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
#line 4681 "parser.y"
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
#line 4692 "parser.y"
    { ;}
    break;

  case 223:

/* Line 1455 of yacc.c  */
#line 4698 "parser.y"
    { (yyval.id) = "extern"; ;}
    break;

  case 224:

/* Line 1455 of yacc.c  */
#line 4699 "parser.y"
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
#line 4707 "parser.y"
    { (yyval.id) = "static"; ;}
    break;

  case 226:

/* Line 1455 of yacc.c  */
#line 4708 "parser.y"
    { (yyval.id) = "typedef"; ;}
    break;

  case 227:

/* Line 1455 of yacc.c  */
#line 4709 "parser.y"
    { (yyval.id) = "virtual"; ;}
    break;

  case 228:

/* Line 1455 of yacc.c  */
#line 4710 "parser.y"
    { (yyval.id) = "friend"; ;}
    break;

  case 229:

/* Line 1455 of yacc.c  */
#line 4711 "parser.y"
    { (yyval.id) = "explicit"; ;}
    break;

  case 230:

/* Line 1455 of yacc.c  */
#line 4712 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 231:

/* Line 1455 of yacc.c  */
#line 4719 "parser.y"
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
#line 4730 "parser.y"
    {
                  set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].pl));
                  (yyval.pl) = (yyvsp[(1) - (2)].p);
		;}
    break;

  case 233:

/* Line 1455 of yacc.c  */
#line 4734 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 234:

/* Line 1455 of yacc.c  */
#line 4737 "parser.y"
    {
                 set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].pl));
		 (yyval.pl) = (yyvsp[(2) - (3)].p);
                ;}
    break;

  case 235:

/* Line 1455 of yacc.c  */
#line 4741 "parser.y"
    { (yyval.pl) = 0; ;}
    break;

  case 236:

/* Line 1455 of yacc.c  */
#line 4745 "parser.y"
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
#line 4755 "parser.y"
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
#line 4763 "parser.y"
    {
		  SwigType *t = NewString("v(...)");
		  (yyval.p) = NewParmWithoutFileLineInfo(t, 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		;}
    break;

  case 239:

/* Line 1455 of yacc.c  */
#line 4771 "parser.y"
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
#line 4784 "parser.y"
    {
                  set_nextSibling((yyvsp[(1) - (2)].p),(yyvsp[(2) - (2)].p));
                  (yyval.p) = (yyvsp[(1) - (2)].p);
		;}
    break;

  case 241:

/* Line 1455 of yacc.c  */
#line 4788 "parser.y"
    { (yyval.p) = 0; ;}
    break;

  case 242:

/* Line 1455 of yacc.c  */
#line 4791 "parser.y"
    {
                 set_nextSibling((yyvsp[(2) - (3)].p),(yyvsp[(3) - (3)].p));
		 (yyval.p) = (yyvsp[(2) - (3)].p);
                ;}
    break;

  case 243:

/* Line 1455 of yacc.c  */
#line 4795 "parser.y"
    { (yyval.p) = 0; ;}
    break;

  case 244:

/* Line 1455 of yacc.c  */
#line 4799 "parser.y"
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
#line 4827 "parser.y"
    {
                  (yyval.p) = NewParmWithoutFileLineInfo(0,0);
                  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		  Setattr((yyval.p),"value",(yyvsp[(1) - (1)].dtype).val);
               ;}
    break;

  case 246:

/* Line 1455 of yacc.c  */
#line 4835 "parser.y"
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
#line 4846 "parser.y"
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
#line 4860 "parser.y"
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
#line 4869 "parser.y"
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
#line 4877 "parser.y"
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
#line 4887 "parser.y"
    {
                 (yyval.decl) = (yyvsp[(1) - (2)].decl);
		 (yyval.decl).defarg = (yyvsp[(2) - (2)].dtype).rawval ? (yyvsp[(2) - (2)].dtype).rawval : (yyvsp[(2) - (2)].dtype).val;
            ;}
    break;

  case 252:

/* Line 1455 of yacc.c  */
#line 4891 "parser.y"
    {
              (yyval.decl) = (yyvsp[(1) - (2)].decl);
	      (yyval.decl).defarg = (yyvsp[(2) - (2)].dtype).rawval ? (yyvsp[(2) - (2)].dtype).rawval : (yyvsp[(2) - (2)].dtype).val;
            ;}
    break;

  case 253:

/* Line 1455 of yacc.c  */
#line 4895 "parser.y"
    {
   	      (yyval.decl).type = 0;
              (yyval.decl).id = 0;
	      (yyval.decl).defarg = (yyvsp[(1) - (1)].dtype).rawval ? (yyvsp[(1) - (1)].dtype).rawval : (yyvsp[(1) - (1)].dtype).val;
            ;}
    break;

  case 254:

/* Line 1455 of yacc.c  */
#line 4902 "parser.y"
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
#line 4919 "parser.y"
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
#line 4936 "parser.y"
    {
   	      (yyval.decl).type = 0;
              (yyval.decl).id = 0;
	      (yyval.decl).parms = 0;
	      ;}
    break;

  case 257:

/* Line 1455 of yacc.c  */
#line 4944 "parser.y"
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
#line 4952 "parser.y"
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
#line 4961 "parser.y"
    {
              (yyval.decl) = (yyvsp[(1) - (1)].decl);
	      if (!(yyval.decl).type) (yyval.decl).type = NewStringEmpty();
           ;}
    break;

  case 260:

/* Line 1455 of yacc.c  */
#line 4965 "parser.y"
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
#line 4974 "parser.y"
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
#line 4985 "parser.y"
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
#line 4997 "parser.y"
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
#line 5007 "parser.y"
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
#line 5020 "parser.y"
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
#line 5027 "parser.y"
    {
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[(2) - (2)].str)));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 267:

/* Line 1455 of yacc.c  */
#line 5035 "parser.y"
    {
                  (yyval.decl).id = Char((yyvsp[(2) - (3)].str));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 268:

/* Line 1455 of yacc.c  */
#line 5051 "parser.y"
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
#line 5059 "parser.y"
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
#line 5070 "parser.y"
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
#line 5081 "parser.y"
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
#line 5092 "parser.y"
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
#line 5111 "parser.y"
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
#line 5119 "parser.y"
    {
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[(2) - (2)].str)));
                  (yyval.decl).type = 0;
                  (yyval.decl).parms = 0;
                  (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 275:

/* Line 1455 of yacc.c  */
#line 5136 "parser.y"
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
#line 5144 "parser.y"
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
#line 5151 "parser.y"
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
#line 5162 "parser.y"
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
#line 5173 "parser.y"
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
#line 5184 "parser.y"
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
#line 5203 "parser.y"
    {
		    (yyval.decl).type = (yyvsp[(1) - (1)].type);
                    (yyval.decl).id = 0;
		    (yyval.decl).parms = 0;
		    (yyval.decl).have_parms = 0;
                  ;}
    break;

  case 282:

/* Line 1455 of yacc.c  */
#line 5209 "parser.y"
    { 
                     (yyval.decl) = (yyvsp[(2) - (2)].decl);
                     SwigType_push((yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].decl).type);
		     (yyval.decl).type = (yyvsp[(1) - (2)].type);
		     Delete((yyvsp[(2) - (2)].decl).type);
                  ;}
    break;

  case 283:

/* Line 1455 of yacc.c  */
#line 5215 "parser.y"
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
#line 5222 "parser.y"
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
#line 5231 "parser.y"
    {
		    (yyval.decl) = (yyvsp[(1) - (1)].decl);
                  ;}
    break;

  case 286:

/* Line 1455 of yacc.c  */
#line 5234 "parser.y"
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
#line 5243 "parser.y"
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
#line 5250 "parser.y"
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
#line 5257 "parser.y"
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
#line 5267 "parser.y"
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
#line 5278 "parser.y"
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
#line 5289 "parser.y"
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
#line 5300 "parser.y"
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
#line 5307 "parser.y"
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
#line 5314 "parser.y"
    {
                    (yyval.decl) = (yyvsp[(2) - (3)].decl);
		  ;}
    break;

  case 296:

/* Line 1455 of yacc.c  */
#line 5317 "parser.y"
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
#line 5334 "parser.y"
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
#line 5344 "parser.y"
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
#line 5351 "parser.y"
    {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[(2) - (2)].type));
	     Delete((yyvsp[(2) - (2)].type));
	   ;}
    break;

  case 300:

/* Line 1455 of yacc.c  */
#line 5357 "parser.y"
    { 
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[(2) - (2)].str));
           ;}
    break;

  case 301:

/* Line 1455 of yacc.c  */
#line 5362 "parser.y"
    {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
           ;}
    break;

  case 302:

/* Line 1455 of yacc.c  */
#line 5368 "parser.y"
    {
	          (yyval.str) = NewStringEmpty();
	          if ((yyvsp[(1) - (1)].id)) SwigType_add_qualifier((yyval.str),(yyvsp[(1) - (1)].id));
               ;}
    break;

  case 303:

/* Line 1455 of yacc.c  */
#line 5372 "parser.y"
    {
		  (yyval.str) = (yyvsp[(2) - (2)].str);
	          if ((yyvsp[(1) - (2)].id)) SwigType_add_qualifier((yyval.str),(yyvsp[(1) - (2)].id));
               ;}
    break;

  case 304:

/* Line 1455 of yacc.c  */
#line 5378 "parser.y"
    { (yyval.id) = "const"; ;}
    break;

  case 305:

/* Line 1455 of yacc.c  */
#line 5379 "parser.y"
    { (yyval.id) = "volatile"; ;}
    break;

  case 306:

/* Line 1455 of yacc.c  */
#line 5380 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 307:

/* Line 1455 of yacc.c  */
#line 5386 "parser.y"
    {
                   (yyval.type) = (yyvsp[(1) - (1)].type);
                   Replace((yyval.type),"typename ","", DOH_REPLACE_ANY);
                ;}
    break;

  case 308:

/* Line 1455 of yacc.c  */
#line 5392 "parser.y"
    {
                   (yyval.type) = (yyvsp[(2) - (2)].type);
	           SwigType_push((yyval.type),(yyvsp[(1) - (2)].str));
               ;}
    break;

  case 309:

/* Line 1455 of yacc.c  */
#line 5396 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 310:

/* Line 1455 of yacc.c  */
#line 5397 "parser.y"
    {
		  (yyval.type) = (yyvsp[(1) - (2)].type);
	          SwigType_push((yyval.type),(yyvsp[(2) - (2)].str));
	       ;}
    break;

  case 311:

/* Line 1455 of yacc.c  */
#line 5401 "parser.y"
    {
		  (yyval.type) = (yyvsp[(2) - (3)].type);
	          SwigType_push((yyval.type),(yyvsp[(3) - (3)].str));
	          SwigType_push((yyval.type),(yyvsp[(1) - (3)].str));
	       ;}
    break;

  case 312:

/* Line 1455 of yacc.c  */
#line 5408 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type);
                  /* Printf(stdout,"primitive = '%s'\n", $$);*/
               ;}
    break;

  case 313:

/* Line 1455 of yacc.c  */
#line 5411 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 314:

/* Line 1455 of yacc.c  */
#line 5412 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 315:

/* Line 1455 of yacc.c  */
#line 5413 "parser.y"
    { (yyval.type) = NewStringf("%s%s",(yyvsp[(1) - (2)].type),(yyvsp[(2) - (2)].id)); ;}
    break;

  case 316:

/* Line 1455 of yacc.c  */
#line 5414 "parser.y"
    { (yyval.type) = NewStringf("enum %s", (yyvsp[(2) - (2)].str)); ;}
    break;

  case 317:

/* Line 1455 of yacc.c  */
#line 5415 "parser.y"
    { (yyval.type) = (yyvsp[(1) - (1)].type); ;}
    break;

  case 318:

/* Line 1455 of yacc.c  */
#line 5417 "parser.y"
    {
		  (yyval.type) = (yyvsp[(1) - (1)].str);
               ;}
    break;

  case 319:

/* Line 1455 of yacc.c  */
#line 5420 "parser.y"
    { 
		 (yyval.type) = NewStringf("%s %s", (yyvsp[(1) - (2)].id), (yyvsp[(2) - (2)].str));
               ;}
    break;

  case 320:

/* Line 1455 of yacc.c  */
#line 5425 "parser.y"
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
#line 5450 "parser.y"
    { 
                 (yyval.ptype) = (yyvsp[(1) - (1)].ptype);
               ;}
    break;

  case 322:

/* Line 1455 of yacc.c  */
#line 5453 "parser.y"
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
#line 5507 "parser.y"
    { 
		    (yyval.ptype).type = NewString("int");
                    (yyval.ptype).us = 0;
               ;}
    break;

  case 324:

/* Line 1455 of yacc.c  */
#line 5511 "parser.y"
    { 
                    (yyval.ptype).type = NewString("short");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 325:

/* Line 1455 of yacc.c  */
#line 5515 "parser.y"
    { 
                    (yyval.ptype).type = NewString("long");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 326:

/* Line 1455 of yacc.c  */
#line 5519 "parser.y"
    { 
                    (yyval.ptype).type = NewString("char");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 327:

/* Line 1455 of yacc.c  */
#line 5523 "parser.y"
    { 
                    (yyval.ptype).type = NewString("wchar_t");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 328:

/* Line 1455 of yacc.c  */
#line 5527 "parser.y"
    { 
                    (yyval.ptype).type = NewString("float");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 329:

/* Line 1455 of yacc.c  */
#line 5531 "parser.y"
    { 
                    (yyval.ptype).type = NewString("double");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 330:

/* Line 1455 of yacc.c  */
#line 5535 "parser.y"
    { 
                    (yyval.ptype).us = NewString("signed");
                    (yyval.ptype).type = 0;
                ;}
    break;

  case 331:

/* Line 1455 of yacc.c  */
#line 5539 "parser.y"
    { 
                    (yyval.ptype).us = NewString("unsigned");
                    (yyval.ptype).type = 0;
                ;}
    break;

  case 332:

/* Line 1455 of yacc.c  */
#line 5543 "parser.y"
    { 
                    (yyval.ptype).type = NewString("complex");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 333:

/* Line 1455 of yacc.c  */
#line 5547 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int8");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 334:

/* Line 1455 of yacc.c  */
#line 5551 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int16");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 335:

/* Line 1455 of yacc.c  */
#line 5555 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int32");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 336:

/* Line 1455 of yacc.c  */
#line 5559 "parser.y"
    { 
                    (yyval.ptype).type = NewString("__int64");
                    (yyval.ptype).us = 0;
                ;}
    break;

  case 337:

/* Line 1455 of yacc.c  */
#line 5565 "parser.y"
    { /* scanner_check_typedef(); */ ;}
    break;

  case 338:

/* Line 1455 of yacc.c  */
#line 5565 "parser.y"
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
#line 5591 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 340:

/* Line 1455 of yacc.c  */
#line 5592 "parser.y"
    { (yyval.id) = (char *) 0;;}
    break;

  case 341:

/* Line 1455 of yacc.c  */
#line 5595 "parser.y"
    { 

                  /* Ignore if there is a trailing comma in the enum list */
                  if ((yyvsp[(3) - (3)].node)) {
                    Node *leftSibling = Getattr((yyvsp[(1) - (3)].node),"_last");
                    if (!leftSibling) {
                      leftSibling=(yyvsp[(1) - (3)].node);
                    }
                    set_nextSibling(leftSibling,(yyvsp[(3) - (3)].node));
                    Setattr((yyvsp[(1) - (3)].node),"_last",(yyvsp[(3) - (3)].node));
                  }
		  (yyval.node) = (yyvsp[(1) - (3)].node);
               ;}
    break;

  case 342:

/* Line 1455 of yacc.c  */
#line 5608 "parser.y"
    { 
                   (yyval.node) = (yyvsp[(1) - (1)].node); 
                   if ((yyvsp[(1) - (1)].node)) {
                     Setattr((yyvsp[(1) - (1)].node),"_last",(yyvsp[(1) - (1)].node));
                   }
               ;}
    break;

  case 343:

/* Line 1455 of yacc.c  */
#line 5616 "parser.y"
    {
		   SwigType *type = NewSwigType(T_INT);
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[(1) - (1)].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Delete(type);
		 ;}
    break;

  case 344:

/* Line 1455 of yacc.c  */
#line 5624 "parser.y"
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

  case 345:

/* Line 1455 of yacc.c  */
#line 5634 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 346:

/* Line 1455 of yacc.c  */
#line 5637 "parser.y"
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

  case 347:

/* Line 1455 of yacc.c  */
#line 5652 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 348:

/* Line 1455 of yacc.c  */
#line 5653 "parser.y"
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

  case 349:

/* Line 1455 of yacc.c  */
#line 5672 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 350:

/* Line 1455 of yacc.c  */
#line 5673 "parser.y"
    {
		    (yyval.dtype).val = NewString((yyvsp[(1) - (1)].id));
                    (yyval.dtype).type = T_STRING;
               ;}
    break;

  case 351:

/* Line 1455 of yacc.c  */
#line 5677 "parser.y"
    {
		  SwigType_push((yyvsp[(3) - (5)].type),(yyvsp[(4) - (5)].decl).type);
		  (yyval.dtype).val = NewStringf("sizeof(%s)",SwigType_str((yyvsp[(3) - (5)].type),0));
		  (yyval.dtype).type = T_ULONG;
               ;}
    break;

  case 352:

/* Line 1455 of yacc.c  */
#line 5682 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 353:

/* Line 1455 of yacc.c  */
#line 5683 "parser.y"
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

  case 354:

/* Line 1455 of yacc.c  */
#line 5697 "parser.y"
    {
   	            (yyval.dtype).val = NewStringf("(%s)",(yyvsp[(2) - (3)].dtype).val);
		    (yyval.dtype).type = (yyvsp[(2) - (3)].dtype).type;
   	       ;}
    break;

  case 355:

/* Line 1455 of yacc.c  */
#line 5704 "parser.y"
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

  case 356:

/* Line 1455 of yacc.c  */
#line 5721 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(5) - (5)].dtype);
		 if ((yyvsp[(5) - (5)].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[(2) - (5)].dtype).val,(yyvsp[(3) - (5)].type));
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (5)].dtype).val,0), (yyvsp[(5) - (5)].dtype).val);
		 }
 	       ;}
    break;

  case 357:

/* Line 1455 of yacc.c  */
#line 5728 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(5) - (5)].dtype);
		 if ((yyvsp[(5) - (5)].dtype).type != T_STRING) {
		   SwigType_add_reference((yyvsp[(2) - (5)].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (5)].dtype).val,0), (yyvsp[(5) - (5)].dtype).val);
		 }
 	       ;}
    break;

  case 358:

/* Line 1455 of yacc.c  */
#line 5735 "parser.y"
    {
                 (yyval.dtype) = (yyvsp[(6) - (6)].dtype);
		 if ((yyvsp[(6) - (6)].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[(2) - (6)].dtype).val,(yyvsp[(3) - (6)].type));
		   SwigType_add_reference((yyvsp[(2) - (6)].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[(2) - (6)].dtype).val,0), (yyvsp[(6) - (6)].dtype).val);
		 }
 	       ;}
    break;

  case 359:

/* Line 1455 of yacc.c  */
#line 5743 "parser.y"
    {
		 (yyval.dtype) = (yyvsp[(2) - (2)].dtype);
                 (yyval.dtype).val = NewStringf("&%s",(yyvsp[(2) - (2)].dtype).val);
	       ;}
    break;

  case 360:

/* Line 1455 of yacc.c  */
#line 5747 "parser.y"
    {
		 (yyval.dtype) = (yyvsp[(2) - (2)].dtype);
                 (yyval.dtype).val = NewStringf("*%s",(yyvsp[(2) - (2)].dtype).val);
	       ;}
    break;

  case 361:

/* Line 1455 of yacc.c  */
#line 5753 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 362:

/* Line 1455 of yacc.c  */
#line 5754 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 363:

/* Line 1455 of yacc.c  */
#line 5755 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 364:

/* Line 1455 of yacc.c  */
#line 5756 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 365:

/* Line 1455 of yacc.c  */
#line 5757 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 366:

/* Line 1455 of yacc.c  */
#line 5758 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 367:

/* Line 1455 of yacc.c  */
#line 5759 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 368:

/* Line 1455 of yacc.c  */
#line 5760 "parser.y"
    { (yyval.dtype) = (yyvsp[(1) - (1)].dtype); ;}
    break;

  case 369:

/* Line 1455 of yacc.c  */
#line 5763 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s+%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 370:

/* Line 1455 of yacc.c  */
#line 5767 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s-%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 371:

/* Line 1455 of yacc.c  */
#line 5771 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s*%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 372:

/* Line 1455 of yacc.c  */
#line 5775 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s/%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 373:

/* Line 1455 of yacc.c  */
#line 5779 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s%%%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 374:

/* Line 1455 of yacc.c  */
#line 5783 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s&%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 375:

/* Line 1455 of yacc.c  */
#line 5787 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s|%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 376:

/* Line 1455 of yacc.c  */
#line 5791 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s^%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[(1) - (3)].dtype).type,(yyvsp[(3) - (3)].dtype).type);
	       ;}
    break;

  case 377:

/* Line 1455 of yacc.c  */
#line 5795 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s << %s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[(1) - (3)].dtype).type);
	       ;}
    break;

  case 378:

/* Line 1455 of yacc.c  */
#line 5799 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s >> %s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[(1) - (3)].dtype).type);
	       ;}
    break;

  case 379:

/* Line 1455 of yacc.c  */
#line 5803 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s&&%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 380:

/* Line 1455 of yacc.c  */
#line 5807 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s||%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 381:

/* Line 1455 of yacc.c  */
#line 5811 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s==%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 382:

/* Line 1455 of yacc.c  */
#line 5815 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s!=%s",(yyvsp[(1) - (3)].dtype).val,(yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 383:

/* Line 1455 of yacc.c  */
#line 5829 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s >= %s", (yyvsp[(1) - (3)].dtype).val, (yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 384:

/* Line 1455 of yacc.c  */
#line 5833 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s <= %s", (yyvsp[(1) - (3)].dtype).val, (yyvsp[(3) - (3)].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       ;}
    break;

  case 385:

/* Line 1455 of yacc.c  */
#line 5837 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("%s?%s:%s", (yyvsp[(1) - (5)].dtype).val, (yyvsp[(3) - (5)].dtype).val, (yyvsp[(5) - (5)].dtype).val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 (yyval.dtype).type = promote((yyvsp[(3) - (5)].dtype).type, (yyvsp[(5) - (5)].dtype).type);
	       ;}
    break;

  case 386:

/* Line 1455 of yacc.c  */
#line 5843 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("-%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 387:

/* Line 1455 of yacc.c  */
#line 5847 "parser.y"
    {
                 (yyval.dtype).val = NewStringf("+%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 388:

/* Line 1455 of yacc.c  */
#line 5851 "parser.y"
    {
		 (yyval.dtype).val = NewStringf("~%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = (yyvsp[(2) - (2)].dtype).type;
	       ;}
    break;

  case 389:

/* Line 1455 of yacc.c  */
#line 5855 "parser.y"
    {
                 (yyval.dtype).val = NewStringf("!%s",(yyvsp[(2) - (2)].dtype).val);
		 (yyval.dtype).type = T_INT;
	       ;}
    break;

  case 390:

/* Line 1455 of yacc.c  */
#line 5859 "parser.y"
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

  case 391:

/* Line 1455 of yacc.c  */
#line 5875 "parser.y"
    {
		 (yyval.bases) = (yyvsp[(1) - (1)].bases);
               ;}
    break;

  case 392:

/* Line 1455 of yacc.c  */
#line 5880 "parser.y"
    { inherit_list = 1; ;}
    break;

  case 393:

/* Line 1455 of yacc.c  */
#line 5880 "parser.y"
    { (yyval.bases) = (yyvsp[(3) - (3)].bases); inherit_list = 0; ;}
    break;

  case 394:

/* Line 1455 of yacc.c  */
#line 5881 "parser.y"
    { (yyval.bases) = 0; ;}
    break;

  case 395:

/* Line 1455 of yacc.c  */
#line 5884 "parser.y"
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

  case 396:

/* Line 1455 of yacc.c  */
#line 5901 "parser.y"
    {
		   Hash *list = (yyvsp[(1) - (3)].bases);
		   Node *base = (yyvsp[(3) - (3)].node);
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
                   (yyval.bases) = list;
               ;}
    break;

  case 397:

/* Line 1455 of yacc.c  */
#line 5910 "parser.y"
    {
		 (yyval.intvalue) = cparse_line;
	       ;}
    break;

  case 398:

/* Line 1455 of yacc.c  */
#line 5912 "parser.y"
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

  case 399:

/* Line 1455 of yacc.c  */
#line 5926 "parser.y"
    {
		 (yyval.intvalue) = cparse_line;
	       ;}
    break;

  case 400:

/* Line 1455 of yacc.c  */
#line 5928 "parser.y"
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

  case 401:

/* Line 1455 of yacc.c  */
#line 5942 "parser.y"
    { (yyval.id) = (char*)"public"; ;}
    break;

  case 402:

/* Line 1455 of yacc.c  */
#line 5943 "parser.y"
    { (yyval.id) = (char*)"private"; ;}
    break;

  case 403:

/* Line 1455 of yacc.c  */
#line 5944 "parser.y"
    { (yyval.id) = (char*)"protected"; ;}
    break;

  case 404:

/* Line 1455 of yacc.c  */
#line 5948 "parser.y"
    { 
                   (yyval.id) = (char*)"class"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 405:

/* Line 1455 of yacc.c  */
#line 5952 "parser.y"
    { 
                   (yyval.id) = (char *)"typename"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 406:

/* Line 1455 of yacc.c  */
#line 5958 "parser.y"
    {
                 (yyval.id) = (yyvsp[(1) - (1)].id);
               ;}
    break;

  case 407:

/* Line 1455 of yacc.c  */
#line 5961 "parser.y"
    { 
                   (yyval.id) = (char*)"struct"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 408:

/* Line 1455 of yacc.c  */
#line 5965 "parser.y"
    {
                   (yyval.id) = (char*)"union"; 
		   if (!inherit_list) last_cpptype = (yyval.id);
               ;}
    break;

  case 411:

/* Line 1455 of yacc.c  */
#line 5975 "parser.y"
    {
                    (yyval.dtype).qualifier = (yyvsp[(1) - (1)].str);
                    (yyval.dtype).throws = 0;
                    (yyval.dtype).throwf = 0;
               ;}
    break;

  case 412:

/* Line 1455 of yacc.c  */
#line 5980 "parser.y"
    {
                    (yyval.dtype).qualifier = 0;
                    (yyval.dtype).throws = (yyvsp[(3) - (4)].pl);
                    (yyval.dtype).throwf = NewString("1");
               ;}
    break;

  case 413:

/* Line 1455 of yacc.c  */
#line 5985 "parser.y"
    {
                    (yyval.dtype).qualifier = (yyvsp[(1) - (5)].str);
                    (yyval.dtype).throws = (yyvsp[(4) - (5)].pl);
                    (yyval.dtype).throwf = NewString("1");
               ;}
    break;

  case 414:

/* Line 1455 of yacc.c  */
#line 5990 "parser.y"
    { 
                    (yyval.dtype).qualifier = 0; 
                    (yyval.dtype).throws = 0;
                    (yyval.dtype).throwf = 0;
               ;}
    break;

  case 415:

/* Line 1455 of yacc.c  */
#line 5997 "parser.y"
    { 
                    Clear(scanner_ccode); 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = 0; 
		    (yyval.decl).throws = (yyvsp[(1) - (3)].dtype).throws;
		    (yyval.decl).throwf = (yyvsp[(1) - (3)].dtype).throwf;
               ;}
    break;

  case 416:

/* Line 1455 of yacc.c  */
#line 6004 "parser.y"
    { 
                    skip_balanced('{','}'); 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = 0; 
                    (yyval.decl).throws = (yyvsp[(1) - (3)].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[(1) - (3)].dtype).throwf;
               ;}
    break;

  case 417:

/* Line 1455 of yacc.c  */
#line 6011 "parser.y"
    { 
                    Clear(scanner_ccode); 
                    (yyval.decl).parms = (yyvsp[(2) - (4)].pl); 
                    (yyval.decl).have_parms = 1; 
                    (yyval.decl).defarg = 0; 
		    (yyval.decl).throws = 0;
		    (yyval.decl).throwf = 0;
               ;}
    break;

  case 418:

/* Line 1455 of yacc.c  */
#line 6019 "parser.y"
    {
                    skip_balanced('{','}'); 
                    (yyval.decl).parms = (yyvsp[(2) - (4)].pl); 
                    (yyval.decl).have_parms = 1; 
                    (yyval.decl).defarg = 0; 
                    (yyval.decl).throws = 0;
                    (yyval.decl).throwf = 0;
               ;}
    break;

  case 419:

/* Line 1455 of yacc.c  */
#line 6027 "parser.y"
    { 
                    (yyval.decl).have_parms = 0; 
                    (yyval.decl).defarg = (yyvsp[(2) - (3)].dtype).val; 
                    (yyval.decl).throws = 0;
                    (yyval.decl).throwf = 0;
               ;}
    break;

  case 424:

/* Line 1455 of yacc.c  */
#line 6043 "parser.y"
    {
	            skip_balanced('(',')');
                    Clear(scanner_ccode);
            	;}
    break;

  case 425:

/* Line 1455 of yacc.c  */
#line 6049 "parser.y"
    { 
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,(yyvsp[(2) - (3)].p));
                     (yyval.id) = Char(s);
		     scanner_last_id(1);
                 ;}
    break;

  case 426:

/* Line 1455 of yacc.c  */
#line 6055 "parser.y"
    { (yyval.id) = (char*)"";  ;}
    break;

  case 427:

/* Line 1455 of yacc.c  */
#line 6058 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 428:

/* Line 1455 of yacc.c  */
#line 6059 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 429:

/* Line 1455 of yacc.c  */
#line 6062 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id); ;}
    break;

  case 430:

/* Line 1455 of yacc.c  */
#line 6063 "parser.y"
    { (yyval.id) = 0; ;}
    break;

  case 431:

/* Line 1455 of yacc.c  */
#line 6066 "parser.y"
    { 
                  (yyval.str) = 0;
		  if (!(yyval.str)) (yyval.str) = NewStringf("%s%s", (yyvsp[(1) - (2)].str),(yyvsp[(2) - (2)].str));
      	          Delete((yyvsp[(2) - (2)].str));
               ;}
    break;

  case 432:

/* Line 1455 of yacc.c  */
#line 6071 "parser.y"
    { 
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[(3) - (4)].str),(yyvsp[(4) - (4)].str));
                 Delete((yyvsp[(4) - (4)].str));
               ;}
    break;

  case 433:

/* Line 1455 of yacc.c  */
#line 6075 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
   	       ;}
    break;

  case 434:

/* Line 1455 of yacc.c  */
#line 6078 "parser.y"
    {
		 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 435:

/* Line 1455 of yacc.c  */
#line 6081 "parser.y"
    {
                 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 436:

/* Line 1455 of yacc.c  */
#line 6084 "parser.y"
    {
                 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 437:

/* Line 1455 of yacc.c  */
#line 6089 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[(2) - (3)].str),(yyvsp[(3) - (3)].str));
		   Delete((yyvsp[(3) - (3)].str));
               ;}
    break;

  case 438:

/* Line 1455 of yacc.c  */
#line 6093 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 439:

/* Line 1455 of yacc.c  */
#line 6096 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 440:

/* Line 1455 of yacc.c  */
#line 6103 "parser.y"
    {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 441:

/* Line 1455 of yacc.c  */
#line 6109 "parser.y"
    {
                  (yyval.str) = NewStringf("%s%s",(yyvsp[(1) - (2)].id),(yyvsp[(2) - (2)].id));
		  /*		  if (Len($2)) {
		    scanner_last_id(1);
		    } */
              ;}
    break;

  case 442:

/* Line 1455 of yacc.c  */
#line 6118 "parser.y"
    { 
                  (yyval.str) = 0;
		  if (!(yyval.str)) (yyval.str) = NewStringf("%s%s", (yyvsp[(1) - (2)].id),(yyvsp[(2) - (2)].str));
      	          Delete((yyvsp[(2) - (2)].str));
               ;}
    break;

  case 443:

/* Line 1455 of yacc.c  */
#line 6123 "parser.y"
    { 
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[(3) - (4)].id),(yyvsp[(4) - (4)].str));
                 Delete((yyvsp[(4) - (4)].str));
               ;}
    break;

  case 444:

/* Line 1455 of yacc.c  */
#line 6127 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].id));
   	       ;}
    break;

  case 445:

/* Line 1455 of yacc.c  */
#line 6130 "parser.y"
    {
		 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].id));
               ;}
    break;

  case 446:

/* Line 1455 of yacc.c  */
#line 6133 "parser.y"
    {
                 (yyval.str) = NewString((yyvsp[(1) - (1)].str));
	       ;}
    break;

  case 447:

/* Line 1455 of yacc.c  */
#line 6136 "parser.y"
    {
                 (yyval.str) = NewStringf("::%s",(yyvsp[(3) - (3)].str));
               ;}
    break;

  case 448:

/* Line 1455 of yacc.c  */
#line 6141 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[(2) - (3)].id),(yyvsp[(3) - (3)].str));
		   Delete((yyvsp[(3) - (3)].str));
               ;}
    break;

  case 449:

/* Line 1455 of yacc.c  */
#line 6145 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 450:

/* Line 1455 of yacc.c  */
#line 6148 "parser.y"
    {
                   (yyval.str) = NewStringf("::%s",(yyvsp[(2) - (2)].str));
               ;}
    break;

  case 451:

/* Line 1455 of yacc.c  */
#line 6151 "parser.y"
    {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 452:

/* Line 1455 of yacc.c  */
#line 6157 "parser.y"
    { 
                   (yyval.id) = (char *) malloc(strlen((yyvsp[(1) - (2)].id))+strlen((yyvsp[(2) - (2)].id))+1);
                   strcpy((yyval.id),(yyvsp[(1) - (2)].id));
                   strcat((yyval.id),(yyvsp[(2) - (2)].id));
               ;}
    break;

  case 453:

/* Line 1455 of yacc.c  */
#line 6162 "parser.y"
    { (yyval.id) = (yyvsp[(1) - (1)].id);;}
    break;

  case 454:

/* Line 1455 of yacc.c  */
#line 6165 "parser.y"
    {
		 (yyval.str) = NewString((yyvsp[(1) - (1)].id));
               ;}
    break;

  case 455:

/* Line 1455 of yacc.c  */
#line 6168 "parser.y"
    {
                  skip_balanced('{','}');
		  (yyval.str) = NewString(scanner_ccode);
               ;}
    break;

  case 456:

/* Line 1455 of yacc.c  */
#line 6172 "parser.y"
    {
		 (yyval.str) = (yyvsp[(1) - (1)].str);
              ;}
    break;

  case 457:

/* Line 1455 of yacc.c  */
#line 6177 "parser.y"
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

  case 458:

/* Line 1455 of yacc.c  */
#line 6190 "parser.y"
    { (yyval.node) = 0; ;}
    break;

  case 459:

/* Line 1455 of yacc.c  */
#line 6194 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
		 Setattr((yyval.node),"value",(yyvsp[(3) - (3)].id));
               ;}
    break;

  case 460:

/* Line 1455 of yacc.c  */
#line 6199 "parser.y"
    {
		 (yyval.node) = NewHash();
		 Setattr((yyval.node),"name",(yyvsp[(1) - (5)].id));
		 Setattr((yyval.node),"value",(yyvsp[(3) - (5)].id));
		 set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
               ;}
    break;

  case 461:

/* Line 1455 of yacc.c  */
#line 6205 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"name",(yyvsp[(1) - (1)].id));
	       ;}
    break;

  case 462:

/* Line 1455 of yacc.c  */
#line 6209 "parser.y"
    {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
                 set_nextSibling((yyval.node),(yyvsp[(3) - (3)].node));
               ;}
    break;

  case 463:

/* Line 1455 of yacc.c  */
#line 6214 "parser.y"
    {
                 (yyval.node) = (yyvsp[(3) - (3)].node);
		 Setattr((yyval.node),"name",(yyvsp[(1) - (3)].id));
               ;}
    break;

  case 464:

/* Line 1455 of yacc.c  */
#line 6218 "parser.y"
    {
                 (yyval.node) = (yyvsp[(3) - (5)].node);
		 Setattr((yyval.node),"name",(yyvsp[(1) - (5)].id));
		 set_nextSibling((yyval.node),(yyvsp[(5) - (5)].node));
               ;}
    break;

  case 465:

/* Line 1455 of yacc.c  */
#line 6225 "parser.y"
    {
		 (yyval.id) = (yyvsp[(1) - (1)].id);
               ;}
    break;

  case 466:

/* Line 1455 of yacc.c  */
#line 6228 "parser.y"
    {
                 (yyval.id) = Char((yyvsp[(1) - (1)].dtype).val);
               ;}
    break;



/* Line 1455 of yacc.c  */
#line 11166 "parser.tab.c"
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
#line 6235 "parser.y"


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


