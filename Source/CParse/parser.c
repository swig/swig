/* A Bison parser, made by GNU Bison 3.8.2.  */

/* Bison implementation for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2021 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

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

/* DO NOT RELY ON FEATURES THAT ARE NOT DOCUMENTED in the manual,
   especially those whose name start with YY_ or yy_.  They are
   private implementation details that can be changed or removed.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output, and Bison version.  */
#define YYBISON 30802

/* Bison version string.  */
#define YYBISON_VERSION "3.8.2"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Push parsers.  */
#define YYPUSH 0

/* Pull parsers.  */
#define YYPULL 1




/* First part of user prologue.  */
#line 33 "parser.y"

/* doh.h uses #pragma GCC poison with GCC to prevent direct calls to certain
 * standard C library functions being introduced, but those cause errors due
 * to checks like `#if defined YYMALLOC || defined malloc` in the bison
 * template code.  We can't easily arrange to include headers after that
 * template code, so instead we disable the problematic poisoning for this
 * file.
 */
#define DOH_NO_POISON_MALLOC_FREE

#include "swig.h"
#include "cparse.h"
#include "preprocessor.h"
#include <ctype.h>

#define YYMALLOC Malloc
#define YYFREE Free

/* -----------------------------------------------------------------------------
 *                               Externals
 * ----------------------------------------------------------------------------- */

int  yyparse(void);

/* NEW Variables */

static void    *top = 0;      /* Top of the generated parse tree */
static int      unnamed = 0;  /* Unnamed datatype counter */
static Hash    *classes = 0;        /* Hash table of classes */
static Hash    *classes_typedefs = 0; /* Hash table of typedef classes: typedef struct X {...} Y; */
static Symtab  *prev_symtab = 0;
static Node    *current_class = 0;
String  *ModuleName = 0;
static Node    *module_node = 0;
static String  *Classprefix = 0;  
static String  *Namespaceprefix = 0;
static int      inclass = 0;
static Node    *currentOuterClass = 0; /* for nested classes */
static String  *last_cpptype = 0;
static int      inherit_list = 0;
static Parm    *template_parameters = 0;
static int      parsing_template_declaration = 0;
static int      extendmode   = 0;
static int      compact_default_args = 0;
static int      template_reduce = 0;
static int      cparse_externc = 0;
int		ignore_nested_classes = 0;
int		kwargs_supported = 0;

/* -----------------------------------------------------------------------------
 *                            Doxygen Comment Globals
 * ----------------------------------------------------------------------------- */
static String *currentDeclComment = NULL; /* Comment of C/C++ declaration. */

/* -----------------------------------------------------------------------------
 *                            Assist Functions
 * ----------------------------------------------------------------------------- */


 
/* Called by the parser (yyparse) when an error is found.*/
static void yyerror (const char *e) {
  (void)e;
}

static Node *new_node(const_String_or_char_ptr tag) {
  Node *n = Swig_cparse_new_node(tag);
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
    if (strcmp(ckey,"nested:outer") == 0) { /* don't copy outer classes links, they will be updated later */
      Setattr(nn, key, k.item);
      continue;
    }
    /* defaultargs will be patched back in later in update_defaultargs() */
    if (strcmp(ckey,"defaultargs") == 0) {
      Setattr(nn, "needs_defaultargs", "1");
      continue;
    }
    /* same for abstracts, which contains pointers to the source node children, and so will need to be patch too */
    if (strcmp(ckey,"abstracts") == 0) {
      SetFlag(nn, "needs_abstracts");
      continue;
    }
    /* Looks okay.  Just copy the data using Copy */
    ci = Copy(k.item);
    Setattr(nn, key, ci);
    Delete(ci);
  }
  return nn;
}

static void set_comment(Node *n, String *comment) {
  String *name;
  Parm *p;
  if (!n || !comment)
    return;

  if (Getattr(n, "doxygen"))
    Append(Getattr(n, "doxygen"), comment);
  else {
    Setattr(n, "doxygen", comment);
    /* This is the first comment, populate it with @params, if any */
    p = Getattr(n, "parms");
    while (p) {
      if (Getattr(p, "doxygen"))
	Printv(comment, "\n@param ", Getattr(p, "name"), Getattr(p, "doxygen"), NIL);
      p=nextSibling(p);
    }
  }
  
  /* Append same comment to every generated overload */
  name = Getattr(n, "name");
  if (!name)
    return;
  n = nextSibling(n);
  while (n && Getattr(n, "name") && Strcmp(Getattr(n, "name"), name) == 0) {
    Setattr(n, "doxygen", comment);
    n = nextSibling(n);
  }
}

/* -----------------------------------------------------------------------------
 *                              Variables
 * ----------------------------------------------------------------------------- */

static int cplus_mode  = 0;

/* C++ modes */

#define  CPLUS_PUBLIC    1
#define  CPLUS_PRIVATE   2
#define  CPLUS_PROTECTED 3

/* storage classes */

#define SWIG_STORAGE_CLASS_EXTERNC	0x0001
#define SWIG_STORAGE_CLASS_EXTERNCPP	0x0002
#define SWIG_STORAGE_CLASS_EXTERN	0x0004
#define SWIG_STORAGE_CLASS_STATIC	0x0008
#define SWIG_STORAGE_CLASS_TYPEDEF	0x0010
#define SWIG_STORAGE_CLASS_VIRTUAL	0x0020
#define SWIG_STORAGE_CLASS_FRIEND	0x0040
#define SWIG_STORAGE_CLASS_EXPLICIT	0x0080
#define SWIG_STORAGE_CLASS_CONSTEXPR	0x0100
#define SWIG_STORAGE_CLASS_THREAD_LOCAL	0x0200

/* Test if multiple bits are set in x. */
static int multiple_bits_set(unsigned x) { return (x & (x - 1)) != 0; }

static const char* storage_class_string(int c) {
  switch (c) {
    case SWIG_STORAGE_CLASS_EXTERNC:
      return "extern \"C\"";
    case SWIG_STORAGE_CLASS_EXTERNCPP:
      return "extern \"C++\"";
    case SWIG_STORAGE_CLASS_EXTERN:
      return "extern";
    case SWIG_STORAGE_CLASS_STATIC:
      return "static";
    case SWIG_STORAGE_CLASS_TYPEDEF:
      return "typedef";
    case SWIG_STORAGE_CLASS_VIRTUAL:
      return "virtual";
    case SWIG_STORAGE_CLASS_FRIEND:
      return "friend";
    case SWIG_STORAGE_CLASS_EXPLICIT:
      return "explicit";
    case SWIG_STORAGE_CLASS_CONSTEXPR:
      return "constexpr";
    case SWIG_STORAGE_CLASS_THREAD_LOCAL:
      return "thread_local";
  }
  assert(0);
  return "<unknown>";
}

/* include types */
static int   import_mode = 0;

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
  if (t <= T_UCHAR || t == T_CHAR || t == T_WCHAR) return T_INT;
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

static String *resolve_create_node_scope(String *cname, int is_class_definition, int *errored);


Hash *Swig_cparse_features(void) {
  static Hash   *features_hash = 0;
  if (!features_hash) features_hash = NewHash();
  return features_hash;
}

/* -----------------------------------------------------------------------------
 * feature_identifier_fix()
 *
 * If a template, return template with all template parameters fully resolved.
 *
 * This is a copy and modification of typemap_identifier_fix.
 * ----------------------------------------------------------------------------- */

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

static void set_access_mode(Node *n) {
  if (cplus_mode == CPLUS_PUBLIC)
    Setattr(n, "access", "public");
  else if (cplus_mode == CPLUS_PROTECTED)
    Setattr(n, "access", "protected");
  else
    Setattr(n, "access", "private");
}

static void restore_access_mode(Node *n) {
  String *mode = Getattr(n, "access");
  if (Strcmp(mode, "private") == 0)
    cplus_mode = CPLUS_PRIVATE;
  else if (Strcmp(mode, "protected") == 0)
    cplus_mode = CPLUS_PROTECTED;
  else
    cplus_mode = CPLUS_PUBLIC;
}

/* Generate the symbol table name for an object */
/* This is a bit of a mess. Need to clean up */
static String *add_oldname = 0;



static String *make_name(Node *n, String *name,SwigType *decl) {
  String *made_name = 0;
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

  if (parsing_template_declaration)
    SetFlag(n, "parsing_template_declaration");
  made_name = Swig_name_make(n, Namespaceprefix, name, decl, add_oldname);
  Delattr(n, "parsing_template_declaration");

  return made_name;
}

/* Generate an unnamed identifier */
static String *make_unnamed(void) {
  unnamed++;
  return NewStringf("$unnamed%d$",unnamed);
}

static int is_operator(String *name) {
  return Strncmp(name,"operator ", 9) == 0;
}

/* Add declaration list to symbol table */
static int  add_only_one = 0;

static void add_symbols(Node *n) {
  String *decl;
  String *wrn = 0;

  while (n) {
    String *symname = 0;
    String *old_prefix = 0;
    Symtab *old_scope = 0;
    int isfriend = inclass && Strstr(Getattr(n, "storage"), "friend") != NULL;
    int iscdecl = Cmp(nodeType(n),"cdecl") == 0;
    int only_csymbol = 0;
    
    if (inclass) {
      String *name = Getattr(n, "name");
      if (isfriend) {
	/* Friends methods in a class are declared in the namespace enclosing the class (outer most class if a nested class) */
	String *prefix = name ? Swig_scopename_prefix(name) : 0;
	Node *outer = currentOuterClass;
	Symtab *namespace_symtab;
	old_prefix = Namespaceprefix;
	old_scope = Swig_symbol_current();

	assert(outer);
	while (Getattr(outer, "nested:outer")) {
	  outer = Getattr(outer, "nested:outer");
	}
	namespace_symtab = Getattr(outer, "sym:symtab");
	if (!namespace_symtab)
	  namespace_symtab = Getattr(outer, "unofficial:symtab");
	Swig_symbol_setscope(namespace_symtab);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);

	if (!prefix) {
	  /* To check - this should probably apply to operators too */
	  if (name && !is_operator(name) && Namespaceprefix) {
	    String *friendusing = NewStringf("using namespace %s;", Namespaceprefix);
	    Setattr(n, "friendusing", friendusing);
	    Delete(friendusing);
	  }
	} else {
	  /* Qualified friend declarations should not be possible as they are ignored in the parse tree */
	  assert(0);
	}
      } else if (Equal(nodeType(n), "using")) {
	String *uname = Getattr(n, "uname");
	Node *cls = currentOuterClass;
	String *nprefix = 0;
	String *nlast = 0;
	Swig_scopename_split(uname, &nprefix, &nlast);
	if (Swig_item_in_list(Getattr(cls, "baselist"), nprefix) || Swig_item_in_list(Getattr(cls, "protectedbaselist"), nprefix) || Swig_item_in_list(Getattr(cls, "privatebaselist"), nprefix)) {
	  String *plain_name = SwigType_istemplate(nprefix) ? SwigType_templateprefix(nprefix) : nprefix;
	  if (Equal(nlast, plain_name)) {
	    /* Using declaration looks like it is using a constructor in an immediate base class - change the constructor name for this class.
	     * C++11 requires using declarations for inheriting base constructors to be in the immediate base class.
	     * Note that we don't try and look up the constructor in the base class as the constructor may be an implicit/implied constructor and hence not exist. */
	    Symtab *stab = Swig_symbol_current();
	    String *nname = Getattr(stab, "name");
	    Setattr(n, "name", nname);
	    SetFlag(n, "usingctor");
	  }
	}
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
      }
    }

    if (!isfriend && (inclass || extendmode)) {
      Setattr(n,"ismember","1");
    }

    if (extendmode) {
      if (!Getattr(n, "template"))
        SetFlag(n,"isextendmember");
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
	  if (Cmp(nodeType(n),"destructor") == 0) {
	    /* Needed for "unref" feature */
	    only_csymbol = 0;
	  }
	}
      } else {
	Setattr(n, "access", "public");
      }
    } else if (extendmode && !inclass) {
      Setattr(n, "access", "public");
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
	    if (storage && (Strstr(storage, "constexpr") || (Strstr(storage, "static") && !SwigType_ismutable(ty)))) {
	      SetFlag(n, "hasconsttype");
	    }
	    Delete(tmp);
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
	if (parsing_template_declaration)
	  SetFlag(n, "parsing_template_declaration");
	wrn = Swig_name_warning(n, Namespaceprefix, symname,0);
	Delattr(n, "parsing_template_declaration");
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
      if (parsing_template_declaration)
	SetFlag(n, "parsing_template_declaration");
      wrn = Swig_name_warning(n, Namespaceprefix,symname,fun);
      Delattr(n, "parsing_template_declaration");
      
      Delete(fdecl);
      Delete(fun);
      
    }
    if (!symname) {
      n = nextSibling(n);
      continue;
    }

    if (GetFlag(n, "valueignored")) {
      SWIG_WARN_NODE_BEGIN(n);
      Swig_warning(WARN_PARSE_ASSIGNED_VALUE, Getfile(n), Getline(n), "Value assigned to %s not used due to limited parsing implementation.\n", SwigType_namestr(Getattr(n, "name")));
      SWIG_WARN_NODE_END(n);
    }

    if (cparse_cplusplus) {
      String *value = Getattr(n, "value");
      if (value && Strcmp(value, "delete") == 0) {
	/* C++11 deleted definition / deleted function */
        SetFlag(n,"deleted");
        SetFlag(n,"feature:ignore");
      }
      if (SwigType_isrvalue_reference(Getattr(n, "refqualifier"))) {
	/* Ignore rvalue ref-qualifiers by default
	 * Use Getattr instead of GetFlag to handle explicit ignore and explicit not ignore */
	if (!(Getattr(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(WARN_TYPE_RVALUE_REF_QUALIFIER_IGNORED, Getfile(n), Getline(n),
	      "Method with rvalue ref-qualifier %s ignored.\n", Swig_name_decl(n));
	  SWIG_WARN_NODE_END(n);
	  SetFlag(n, "feature:ignore");
	}
      }
      if (Equal(Getattr(n, "type"), "auto")) {
	/* Ignore functions with an auto return type and no trailing return type
	 * Use Getattr instead of GetFlag to handle explicit ignore and explicit not ignore */
	if (!(Getattr(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  if (SwigType_isfunction(Getattr(n, "decl")))
	    Swig_warning(WARN_CPP14_AUTO, Getfile(n), Getline(n), "Unable to deduce auto return type for '%s' (ignored).\n", Swig_name_decl(n));
	  else
	    Swig_warning(WARN_CPP11_AUTO, Getfile(n), Getline(n), "Unable to deduce auto type for variable '%s' (ignored).\n", Swig_name_decl(n));
	  SWIG_WARN_NODE_END(n);
	  SetFlag(n, "feature:ignore");
	}
      }
    }
    if (only_csymbol || GetFlag(n, "feature:ignore") || Strncmp(symname, "$ignore", 7) == 0) {
      /* Only add to C symbol table and continue */
      Swig_symbol_add(0, n);
      if (!only_csymbol && !GetFlag(n, "feature:ignore")) {
	/* Print the warning attached to $ignore name, if any */
        char *c = Char(symname) + 7;
	if (strlen(c)) {
	  SWIG_WARN_NODE_BEGIN(n);
	  Swig_warning(0,Getfile(n), Getline(n), "%s\n",c+1);
	  SWIG_WARN_NODE_END(n);
	}
	/* If the symbol was ignored via "rename" and is visible, set also feature:ignore*/
	SetFlag(n, "feature:ignore");
      }
      if (!GetFlag(n, "feature:ignore") && Strcmp(symname,"$ignore") == 0) {
	/* Add feature:ignore if the symbol was explicitly ignored, regardless of visibility */
	SetFlag(n, "feature:ignore");
      }
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
	  Swig_symbol_conflict_warn(n, c, symname, inclass);
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
  int    emode = 0;
  while (n) {
    if (Equal(nodeType(n), "access")) {
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
      Node *oldCurrentOuterClass = 0;
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
      if (Equal(nodeType(n), "class")) {
	/* add_symbols() above sets "sym:symtab", so "unofficial:symtab" is not required */
	old_inclass = inclass;
	oldCurrentOuterClass = currentOuterClass;
	inclass = 1;
	currentOuterClass = n;
	if (Strcmp(Getattr(n,"kind"),"class") == 0) {
	  cplus_mode = CPLUS_PRIVATE;
	} else {
	  cplus_mode = CPLUS_PUBLIC;
	}
      }
      if (Equal(nodeType(n), "extend")) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }

      if (Getattr(n, "requires_symtab")) {
	Swig_symbol_newscope();
	Swig_symbol_setscopename(Getattr(n, "name"));
	Delete(Namespaceprefix);
	Namespaceprefix = Swig_symbol_qualifiedscopename(0);
      }

      add_symbols_copy(firstChild(n));

      if (Equal(nodeType(n), "extend")) {
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
      if (Equal(nodeType(n), "class")) {
	inclass = old_inclass;
	currentOuterClass = oldCurrentOuterClass;
      }
    } else {
      if (Equal(nodeType(n), "extend")) {
	emode = cplus_mode;
	cplus_mode = CPLUS_PUBLIC;
      }
      add_symbols_copy(firstChild(n));
      if (Equal(nodeType(n), "extend")) {
	cplus_mode = emode;
      }
    }
    n = nextSibling(n);
  }
}

/* Add in the "defaultargs" attribute for functions in instantiated templates.
 * n should be any instantiated template (class or start of linked list of functions). */
static void update_defaultargs(Node *n) {
  if (n) {
    Node *firstdefaultargs = n;
    update_defaultargs(firstChild(n));
    n = nextSibling(n);
    /* recursively loop through nodes of all types, but all we really need are the overloaded functions */
    while (n) {
      update_defaultargs(firstChild(n));
      if (!Getattr(n, "defaultargs")) {
	if (Getattr(n, "needs_defaultargs")) {
	  Setattr(n, "defaultargs", firstdefaultargs);
	  Delattr(n, "needs_defaultargs");
	} else {
	  firstdefaultargs = n;
	}
      } else {
	/* Functions added in with %extend (for specialized template classes) will already have default args patched up */
	assert(Getattr(n, "defaultargs") == firstdefaultargs);
      }
      n = nextSibling(n);
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

/* Recompute the "abstracts" attribute for the classes in instantiated templates, similarly to update_defaultargs() above. */
static void update_abstracts(Node *n) {
  for (; n; n = nextSibling(n)) {
    Node* const child = firstChild(n);
    if (!child)
      continue;

    update_abstracts(child);

    if (Getattr(n, "needs_abstracts")) {
      Setattr(n, "abstracts", pure_abstracts(child));
      Delattr(n, "needs_abstracts");
    }
  }
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

/* Use typedef name as class name */

static void add_typedef_name(Node *n, Node *declnode, String *oldName, Symtab *cscope, String *scpname) {
  String *class_rename = 0;
  SwigType *decl = Getattr(declnode, "decl");
  if (!decl || !Len(decl)) {
    String *cname;
    String *tdscopename;
    String *class_scope = Swig_symbol_qualifiedscopename(cscope);
    String *name = Getattr(declnode, "name");
    cname = Copy(name);
    Setattr(n, "tdname", cname);
    tdscopename = class_scope ? NewStringf("%s::%s", class_scope, name) : Copy(name);
    class_rename = Getattr(n, "class_rename");
    if (class_rename && (Strcmp(class_rename, oldName) == 0))
      Setattr(n, "class_rename", NewString(name));
    if (!classes_typedefs) classes_typedefs = NewHash();
    if (!Equal(scpname, tdscopename) && !Getattr(classes_typedefs, tdscopename)) {
      Setattr(classes_typedefs, tdscopename, n);
    }
    Setattr(n, "decl", decl);
    Delete(class_scope);
    Delete(cname);
    Delete(tdscopename);
  }
}

/* If the class name is qualified.  We need to create or lookup namespace entries */

static Symtab *set_scope_to_global(void) {
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
     int len = Len(inputcode);
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

/*
#define RESOLVE_DEBUG 1
*/
static Node *nscope = 0;
static Node *nscope_inner = 0;

/* Remove the scope prefix from cname and return the base name without the prefix.
 * The scopes required for the symbol name are resolved and/or created, if required.
 * For example AA::BB::CC as input returns CC and creates the namespace AA then inner 
 * namespace BB in the current scope. */
static String *resolve_create_node_scope(String *cname_in, int is_class_definition, int *errored) {
  Symtab *gscope = 0;
  Node *cname_node = 0;
  String *cname = cname_in;
  String *last = Swig_scopename_last(cname);
  nscope = 0;
  nscope_inner = 0;  
  *errored = 0;

  if (Strncmp(cname, "::", 2) == 0) {
    if (is_class_definition) {
      Swig_error(cparse_file, cparse_line, "Using the unary scope operator :: in class definition '%s' is invalid.\n", SwigType_namestr(cname));
      *errored = 1;
      return last;
    }
    cname = NewString(Char(cname) + 2);
  }
  if (is_class_definition) {
    /* Only lookup symbols which are in scope via a using declaration but not via a using directive.
       For example find y via 'using x::y' but not y via a 'using namespace x'. */
    cname_node = Swig_symbol_clookup_no_inherit(cname, 0);
    if (!cname_node) {
      Node *full_lookup_node = Swig_symbol_clookup(cname, 0);
      if (full_lookup_node) {
       /* This finds a symbol brought into scope via both a using directive and a using declaration. */
	Node *last_node = Swig_symbol_clookup_no_inherit(last, 0);
	if (last_node == full_lookup_node)
	  cname_node = last_node;
      }
    }
  } else {
    /* For %template, the template needs to be in scope via any means. */
    cname_node = Swig_symbol_clookup(cname, 0);
  }
#if RESOLVE_DEBUG
  if (!cname_node)
    Printf(stdout, "symbol does not yet exist (%d): [%s]\n", is_class_definition, cname_in);
  else
    Printf(stdout, "symbol does exist (%d): [%s]\n", is_class_definition, cname_in);
#endif

  if (cname_node) {
    /* The symbol has been defined already or is in another scope.
       If it is a weak symbol, it needs replacing and if it was brought into the current scope,
       the scope needs adjusting appropriately for the new symbol.
       Similarly for defined templates. */
    Symtab *symtab = Getattr(cname_node, "sym:symtab");
    Node *sym_weak = Getattr(cname_node, "sym:weak");
    if ((symtab && sym_weak) || Equal(nodeType(cname_node), "template")) {
      /* Check if the scope is the current scope */
      String *current_scopename = Swig_symbol_qualifiedscopename(0);
      String *found_scopename = Swig_symbol_qualifiedscopename(symtab);
      if (!current_scopename)
	current_scopename = NewString("");
      if (!found_scopename)
	found_scopename = NewString("");

      {
	int fail = 1;
	List *current_scopes = Swig_scopename_tolist(current_scopename);
	List *found_scopes = Swig_scopename_tolist(found_scopename);
        Iterator cit = First(current_scopes);
	Iterator fit = First(found_scopes);
#if RESOLVE_DEBUG
Printf(stdout, "comparing current: [%s] found: [%s]\n", current_scopename, found_scopename);
#endif
	for (; fit.item && cit.item; fit = Next(fit), cit = Next(cit)) {
	  String *current = cit.item;
	  String *found = fit.item;
#if RESOLVE_DEBUG
	  Printf(stdout, "  looping %s %s\n", current, found);
#endif
	  if (Strcmp(current, found) != 0)
	    break;
	}

	if (!cit.item) {
	  String *subscope = NewString("");
	  for (; fit.item; fit = Next(fit)) {
	    if (Len(subscope) > 0)
	      Append(subscope, "::");
	    Append(subscope, fit.item);
	  }
	  if (Len(subscope) > 0)
	    cname = NewStringf("%s::%s", subscope, last);
	  else
	    cname = Copy(last);
#if RESOLVE_DEBUG
	  Printf(stdout, "subscope to create: [%s] cname: [%s]\n", subscope, cname);
#endif
	  fail = 0;
	  Delete(subscope);
	} else {
	  if (is_class_definition) {
	    if (!fit.item) {
	      /* It is valid to define a new class with the same name as one forward declared in a parent scope */
	      fail = 0;
	    } else if (Swig_scopename_check(cname)) {
	      /* Classes defined with scope qualifiers must have a matching forward declaration in matching scope */
	      fail = 1;
	    } else {
	      /* This may let through some invalid cases */
	      fail = 0;
	    }
#if RESOLVE_DEBUG
	    Printf(stdout, "scope for class definition, fail: %d\n", fail);
#endif
	  } else {
#if RESOLVE_DEBUG
	    Printf(stdout, "no matching base scope for template\n");
#endif
	    fail = 1;
	  }
	}

	Delete(found_scopes);
	Delete(current_scopes);

	if (fail) {
	  String *cname_resolved = NewStringf("%s::%s", found_scopename, last);
	  Swig_error(cparse_file, cparse_line, "'%s' resolves to '%s' and was incorrectly instantiated in scope '%s' instead of within scope '%s'.\n",
	    SwigType_namestr(cname_in), SwigType_namestr(cname_resolved), SwigType_namestr(current_scopename), SwigType_namestr(found_scopename));
	  *errored = 1;
	  Delete(cname_resolved);
	}
      }

      Delete(current_scopename);
      Delete(found_scopename);
    }
  } else if (!is_class_definition) {
    /* A template instantiation requires a template to be found in scope */
    Swig_error(cparse_file, cparse_line, "Template '%s' undefined.\n", SwigType_namestr(cname_in));
    *errored = 1;
  }

  if (*errored)
    return last;

  if (Swig_scopename_check(cname) && !*errored) {
    Node   *ns;
    String *prefix = Swig_scopename_prefix(cname);
    if (Len(prefix) == 0) {
      String *base = Copy(last);
      /* Use the global scope, but we need to add a 'global' namespace.  */
      if (!gscope) gscope = set_scope_to_global();
      /* note that this namespace is not the "unnamed" one,
	 and we don't use Setattr(nscope,"name", ""),
	 because the unnamed namespace is private */
      nscope = new_node("namespace");
      Setattr(nscope,"symtab", gscope);;
      nscope_inner = nscope;
      Delete(last);
      return base;
    }
    /* Try to locate the scope */
    ns = Swig_symbol_clookup(prefix,0);
    if (!ns) {
      Swig_error(cparse_file, cparse_line, "Undefined scope '%s'\n", SwigType_namestr(prefix));
      *errored = 1;
    } else {
      Symtab *nstab = Getattr(ns,"symtab");
      if (!nstab) {
	Swig_error(cparse_file, cparse_line, "'%s' is not defined as a valid scope.\n", SwigType_namestr(prefix));
	*errored = 1;
	ns = 0;
      } else {
	/* Check if the node scope is the current scope */
	String *tname = Swig_symbol_qualifiedscopename(0);
	String *nname = Swig_symbol_qualifiedscopename(nstab);
	if (tname && (Strcmp(tname,nname) == 0)) {
	  ns = 0;
	  cname = Copy(last);
	}
	Delete(tname);
	Delete(nname);
      }
      if (ns) {
	/* we will try to create a new node using the namespaces we
	   can find in the scope name */
	List *scopes = Swig_scopename_tolist(prefix);
	String *sname;
	Iterator si;

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
	cname = Copy(last);
	Delete(scopes);
      }
    }
    Delete(prefix);
  }
  Delete(last);

  return cname;
}
 
/* look for simple typedef name in typedef list */
static String *try_to_find_a_name_for_unnamed_structure(const String *storage, Node *decls) {
  String *name = 0;
  Node *n = decls;
  if (storage && Equal(storage, "typedef")) {
    for (; n; n = nextSibling(n)) {
      if (!Len(Getattr(n, "decl"))) {
	name = Copy(Getattr(n, "name"));
	break;
      }
    }
  }
  return name;
}

/* traverse copied tree segment, and update outer class links*/
static void update_nested_classes(Node *n)
{
  Node *c = firstChild(n);
  while (c) {
    if (Getattr(c, "nested:outer"))
      Setattr(c, "nested:outer", n);
    update_nested_classes(c);
    c = nextSibling(c);
  }
}

/* -----------------------------------------------------------------------------
 * nested_forward_declaration()
 * 
 * Nested struct handling for C++ code if the nested classes are disabled.
 * Create the nested class/struct/union as a forward declaration.
 * ----------------------------------------------------------------------------- */

static Node *nested_forward_declaration(const String *storage, const String *kind, String *sname, String *name, Node *cpp_opt_declarators) {
  Node *nn = 0;

  if (sname) {
    /* Add forward declaration of the nested type */
    Node *n = new_node("classforward");
    Setattr(n, "kind", kind);
    Setattr(n, "name", sname);
    Setattr(n, "storage", storage);
    Setattr(n, "sym:weak", "1");
    SetFlag(n, "nested:forward");
    add_symbols(n);
    nn = n;
  }

  /* Add any variable instances. Also add in any further typedefs of the nested type.
     Note that anonymous typedefs (eg typedef struct {...} a, b;) are treated as class forward declarations */
  if (cpp_opt_declarators) {
    int storage_typedef = (storage && Equal(storage, "typedef"));
    int variable_of_anonymous_type = !sname && !storage_typedef;
    if (!variable_of_anonymous_type) {
      int anonymous_typedef = !sname && storage_typedef;
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

  if (!currentOuterClass || !GetFlag(currentOuterClass, "nested")) {
    if (nn && Equal(nodeType(nn), "classforward")) {
      Node *n = nn;
      if (!GetFlag(n, "feature:ignore")) {
	SWIG_WARN_NODE_BEGIN(n);
	Swig_warning(WARN_PARSE_NAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (%s ignored)\n", kind, SwigType_namestr(sname ? sname : name));
	SWIG_WARN_NODE_END(n);
      }
    } else {
      Swig_warning(WARN_PARSE_UNNAMED_NESTED_CLASS, cparse_file, cparse_line, "Nested %s not currently supported (ignored).\n", kind);
    }
  }

  return nn;
}


Node *Swig_cparse(File *f) {
  scanner_file(f);
  top = 0;
  if (yyparse() == 2) {
    Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
    Exit(EXIT_FAILURE);
  }
  return (Node *)top;
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
  if (!cparse_cplusplus || cparse_externc)
    return 1;
  if (Swig_storage_isexternc(n)) {
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
	|| (GetFlag(function,"feature:kwargs") && kwargs_supported)) {
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

        /* copy specific attributes for global (or in a namespace) template functions - these are not class template methods */
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
 * mark_nodes_as_extend()
 *
 * Used by the %extend to mark subtypes with "feature:extend".
 * template instances declared within %extend are skipped
 * ----------------------------------------------------------------------------- */

static void mark_nodes_as_extend(Node *n) {
  for (; n; n = nextSibling(n)) {
    if (Getattr(n, "template") && Strcmp(nodeType(n), "class") == 0)
      continue;
    /* Fix me: extend is not a feature. Replace with isextendmember? */
    Setattr(n, "feature:extend", "1");
    mark_nodes_as_extend(firstChild(n));
  }
}

/* -----------------------------------------------------------------------------
 * add_qualifier_to_declarator()
 *
 * Normally the qualifier is pushed on to the front of the type.
 * Adding a qualifier to a pointer to member function is a special case.
 * For example       : typedef double (Cls::*pmf)(void) const;
 * The qualifier is  : q(const).
 * The declarator is : m(Cls).f(void).
 * We need           : m(Cls).q(const).f(void).
 * ----------------------------------------------------------------------------- */

static String *add_qualifier_to_declarator(SwigType *type, SwigType *qualifier) {
  int is_pointer_to_member_function = 0;
  String *decl = Copy(type);
  String *poppedtype = NewString("");
  assert(qualifier);

  while (decl) {
    if (SwigType_ismemberpointer(decl)) {
      String *memberptr = SwigType_pop(decl);
      if (SwigType_isfunction(decl)) {
	is_pointer_to_member_function = 1;
	SwigType_push(decl, qualifier);
	SwigType_push(decl, memberptr);
	Insert(decl, 0, poppedtype);
	Delete(memberptr);
	break;
      } else {
	Append(poppedtype, memberptr);
      }
      Delete(memberptr);
    } else {
      String *popped = SwigType_pop(decl);
      if (!popped)
	break;
      Append(poppedtype, popped);
      Delete(popped);
    }
  }

  if (!is_pointer_to_member_function) {
    Delete(decl);
    decl = Copy(type);
    SwigType_push(decl, qualifier);
  }

  Delete(poppedtype);
  return decl;
}


#line 1643 "parser.c"

# ifndef YY_CAST
#  ifdef __cplusplus
#   define YY_CAST(Type, Val) static_cast<Type> (Val)
#   define YY_REINTERPRET_CAST(Type, Val) reinterpret_cast<Type> (Val)
#  else
#   define YY_CAST(Type, Val) ((Type) (Val))
#   define YY_REINTERPRET_CAST(Type, Val) ((Type) (Val))
#  endif
# endif
# ifndef YY_NULLPTR
#  if defined __cplusplus
#   if 201103L <= __cplusplus
#    define YY_NULLPTR nullptr
#   else
#    define YY_NULLPTR 0
#   endif
#  else
#   define YY_NULLPTR ((void*)0)
#  endif
# endif

#include "parser.h"
/* Symbol kind.  */
enum yysymbol_kind_t
{
  YYSYMBOL_YYEMPTY = -2,
  YYSYMBOL_YYEOF = 0,                      /* END  */
  YYSYMBOL_YYerror = 1,                    /* error  */
  YYSYMBOL_YYUNDEF = 2,                    /* "invalid token"  */
  YYSYMBOL_ID = 3,                         /* ID  */
  YYSYMBOL_HBLOCK = 4,                     /* HBLOCK  */
  YYSYMBOL_POUND = 5,                      /* POUND  */
  YYSYMBOL_STRING = 6,                     /* STRING  */
  YYSYMBOL_WSTRING = 7,                    /* WSTRING  */
  YYSYMBOL_INCLUDE = 8,                    /* INCLUDE  */
  YYSYMBOL_IMPORT = 9,                     /* IMPORT  */
  YYSYMBOL_INSERT = 10,                    /* INSERT  */
  YYSYMBOL_CHARCONST = 11,                 /* CHARCONST  */
  YYSYMBOL_WCHARCONST = 12,                /* WCHARCONST  */
  YYSYMBOL_NUM_INT = 13,                   /* NUM_INT  */
  YYSYMBOL_NUM_DOUBLE = 14,                /* NUM_DOUBLE  */
  YYSYMBOL_NUM_FLOAT = 15,                 /* NUM_FLOAT  */
  YYSYMBOL_NUM_LONGDOUBLE = 16,            /* NUM_LONGDOUBLE  */
  YYSYMBOL_NUM_UNSIGNED = 17,              /* NUM_UNSIGNED  */
  YYSYMBOL_NUM_LONG = 18,                  /* NUM_LONG  */
  YYSYMBOL_NUM_ULONG = 19,                 /* NUM_ULONG  */
  YYSYMBOL_NUM_LONGLONG = 20,              /* NUM_LONGLONG  */
  YYSYMBOL_NUM_ULONGLONG = 21,             /* NUM_ULONGLONG  */
  YYSYMBOL_NUM_BOOL = 22,                  /* NUM_BOOL  */
  YYSYMBOL_TYPEDEF = 23,                   /* TYPEDEF  */
  YYSYMBOL_TYPE_INT = 24,                  /* TYPE_INT  */
  YYSYMBOL_TYPE_UNSIGNED = 25,             /* TYPE_UNSIGNED  */
  YYSYMBOL_TYPE_SHORT = 26,                /* TYPE_SHORT  */
  YYSYMBOL_TYPE_LONG = 27,                 /* TYPE_LONG  */
  YYSYMBOL_TYPE_FLOAT = 28,                /* TYPE_FLOAT  */
  YYSYMBOL_TYPE_DOUBLE = 29,               /* TYPE_DOUBLE  */
  YYSYMBOL_TYPE_CHAR = 30,                 /* TYPE_CHAR  */
  YYSYMBOL_TYPE_WCHAR = 31,                /* TYPE_WCHAR  */
  YYSYMBOL_TYPE_VOID = 32,                 /* TYPE_VOID  */
  YYSYMBOL_TYPE_SIGNED = 33,               /* TYPE_SIGNED  */
  YYSYMBOL_TYPE_BOOL = 34,                 /* TYPE_BOOL  */
  YYSYMBOL_TYPE_COMPLEX = 35,              /* TYPE_COMPLEX  */
  YYSYMBOL_TYPE_NON_ISO_INT8 = 36,         /* TYPE_NON_ISO_INT8  */
  YYSYMBOL_TYPE_NON_ISO_INT16 = 37,        /* TYPE_NON_ISO_INT16  */
  YYSYMBOL_TYPE_NON_ISO_INT32 = 38,        /* TYPE_NON_ISO_INT32  */
  YYSYMBOL_TYPE_NON_ISO_INT64 = 39,        /* TYPE_NON_ISO_INT64  */
  YYSYMBOL_LPAREN = 40,                    /* LPAREN  */
  YYSYMBOL_RPAREN = 41,                    /* RPAREN  */
  YYSYMBOL_COMMA = 42,                     /* COMMA  */
  YYSYMBOL_SEMI = 43,                      /* SEMI  */
  YYSYMBOL_EXTERN = 44,                    /* EXTERN  */
  YYSYMBOL_LBRACE = 45,                    /* LBRACE  */
  YYSYMBOL_RBRACE = 46,                    /* RBRACE  */
  YYSYMBOL_PERIOD = 47,                    /* PERIOD  */
  YYSYMBOL_ELLIPSIS = 48,                  /* ELLIPSIS  */
  YYSYMBOL_CONST_QUAL = 49,                /* CONST_QUAL  */
  YYSYMBOL_VOLATILE = 50,                  /* VOLATILE  */
  YYSYMBOL_REGISTER = 51,                  /* REGISTER  */
  YYSYMBOL_STRUCT = 52,                    /* STRUCT  */
  YYSYMBOL_UNION = 53,                     /* UNION  */
  YYSYMBOL_EQUAL = 54,                     /* EQUAL  */
  YYSYMBOL_SIZEOF = 55,                    /* SIZEOF  */
  YYSYMBOL_ALIGNOF = 56,                   /* ALIGNOF  */
  YYSYMBOL_MODULE = 57,                    /* MODULE  */
  YYSYMBOL_LBRACKET = 58,                  /* LBRACKET  */
  YYSYMBOL_RBRACKET = 59,                  /* RBRACKET  */
  YYSYMBOL_BEGINFILE = 60,                 /* BEGINFILE  */
  YYSYMBOL_ENDOFFILE = 61,                 /* ENDOFFILE  */
  YYSYMBOL_CONSTANT = 62,                  /* CONSTANT  */
  YYSYMBOL_RENAME = 63,                    /* RENAME  */
  YYSYMBOL_NAMEWARN = 64,                  /* NAMEWARN  */
  YYSYMBOL_EXTEND = 65,                    /* EXTEND  */
  YYSYMBOL_PRAGMA = 66,                    /* PRAGMA  */
  YYSYMBOL_FEATURE = 67,                   /* FEATURE  */
  YYSYMBOL_VARARGS = 68,                   /* VARARGS  */
  YYSYMBOL_ENUM = 69,                      /* ENUM  */
  YYSYMBOL_CLASS = 70,                     /* CLASS  */
  YYSYMBOL_TYPENAME = 71,                  /* TYPENAME  */
  YYSYMBOL_PRIVATE = 72,                   /* PRIVATE  */
  YYSYMBOL_PUBLIC = 73,                    /* PUBLIC  */
  YYSYMBOL_PROTECTED = 74,                 /* PROTECTED  */
  YYSYMBOL_COLON = 75,                     /* COLON  */
  YYSYMBOL_STATIC = 76,                    /* STATIC  */
  YYSYMBOL_VIRTUAL = 77,                   /* VIRTUAL  */
  YYSYMBOL_FRIEND = 78,                    /* FRIEND  */
  YYSYMBOL_THROW = 79,                     /* THROW  */
  YYSYMBOL_CATCH = 80,                     /* CATCH  */
  YYSYMBOL_EXPLICIT = 81,                  /* EXPLICIT  */
  YYSYMBOL_STATIC_ASSERT = 82,             /* STATIC_ASSERT  */
  YYSYMBOL_CONSTEXPR = 83,                 /* CONSTEXPR  */
  YYSYMBOL_THREAD_LOCAL = 84,              /* THREAD_LOCAL  */
  YYSYMBOL_DECLTYPE = 85,                  /* DECLTYPE  */
  YYSYMBOL_AUTO = 86,                      /* AUTO  */
  YYSYMBOL_NOEXCEPT = 87,                  /* NOEXCEPT  */
  YYSYMBOL_OVERRIDE = 88,                  /* OVERRIDE  */
  YYSYMBOL_FINAL = 89,                     /* FINAL  */
  YYSYMBOL_USING = 90,                     /* USING  */
  YYSYMBOL_NAMESPACE = 91,                 /* NAMESPACE  */
  YYSYMBOL_NATIVE = 92,                    /* NATIVE  */
  YYSYMBOL_INLINE = 93,                    /* INLINE  */
  YYSYMBOL_TYPEMAP = 94,                   /* TYPEMAP  */
  YYSYMBOL_ECHO = 95,                      /* ECHO  */
  YYSYMBOL_APPLY = 96,                     /* APPLY  */
  YYSYMBOL_CLEAR = 97,                     /* CLEAR  */
  YYSYMBOL_SWIGTEMPLATE = 98,              /* SWIGTEMPLATE  */
  YYSYMBOL_FRAGMENT = 99,                  /* FRAGMENT  */
  YYSYMBOL_WARN = 100,                     /* WARN  */
  YYSYMBOL_LESSTHAN = 101,                 /* LESSTHAN  */
  YYSYMBOL_GREATERTHAN = 102,              /* GREATERTHAN  */
  YYSYMBOL_DELETE_KW = 103,                /* DELETE_KW  */
  YYSYMBOL_DEFAULT = 104,                  /* DEFAULT  */
  YYSYMBOL_LESSTHANOREQUALTO = 105,        /* LESSTHANOREQUALTO  */
  YYSYMBOL_GREATERTHANOREQUALTO = 106,     /* GREATERTHANOREQUALTO  */
  YYSYMBOL_EQUALTO = 107,                  /* EQUALTO  */
  YYSYMBOL_NOTEQUALTO = 108,               /* NOTEQUALTO  */
  YYSYMBOL_LESSEQUALGREATER = 109,         /* LESSEQUALGREATER  */
  YYSYMBOL_ARROW = 110,                    /* ARROW  */
  YYSYMBOL_QUESTIONMARK = 111,             /* QUESTIONMARK  */
  YYSYMBOL_TYPES = 112,                    /* TYPES  */
  YYSYMBOL_PARMS = 113,                    /* PARMS  */
  YYSYMBOL_NONID = 114,                    /* NONID  */
  YYSYMBOL_DSTAR = 115,                    /* DSTAR  */
  YYSYMBOL_DCNOT = 116,                    /* DCNOT  */
  YYSYMBOL_TEMPLATE = 117,                 /* TEMPLATE  */
  YYSYMBOL_OPERATOR = 118,                 /* OPERATOR  */
  YYSYMBOL_CONVERSIONOPERATOR = 119,       /* CONVERSIONOPERATOR  */
  YYSYMBOL_PARSETYPE = 120,                /* PARSETYPE  */
  YYSYMBOL_PARSEPARM = 121,                /* PARSEPARM  */
  YYSYMBOL_PARSEPARMS = 122,               /* PARSEPARMS  */
  YYSYMBOL_DOXYGENSTRING = 123,            /* DOXYGENSTRING  */
  YYSYMBOL_DOXYGENPOSTSTRING = 124,        /* DOXYGENPOSTSTRING  */
  YYSYMBOL_LOR = 125,                      /* LOR  */
  YYSYMBOL_LAND = 126,                     /* LAND  */
  YYSYMBOL_OR = 127,                       /* OR  */
  YYSYMBOL_XOR = 128,                      /* XOR  */
  YYSYMBOL_AND = 129,                      /* AND  */
  YYSYMBOL_LSHIFT = 130,                   /* LSHIFT  */
  YYSYMBOL_RSHIFT = 131,                   /* RSHIFT  */
  YYSYMBOL_PLUS = 132,                     /* PLUS  */
  YYSYMBOL_MINUS = 133,                    /* MINUS  */
  YYSYMBOL_STAR = 134,                     /* STAR  */
  YYSYMBOL_SLASH = 135,                    /* SLASH  */
  YYSYMBOL_MODULO = 136,                   /* MODULO  */
  YYSYMBOL_UMINUS = 137,                   /* UMINUS  */
  YYSYMBOL_NOT = 138,                      /* NOT  */
  YYSYMBOL_LNOT = 139,                     /* LNOT  */
  YYSYMBOL_CAST = 140,                     /* CAST  */
  YYSYMBOL_DCOLON = 141,                   /* DCOLON  */
  YYSYMBOL_YYACCEPT = 142,                 /* $accept  */
  YYSYMBOL_program = 143,                  /* program  */
  YYSYMBOL_interface = 144,                /* interface  */
  YYSYMBOL_declaration = 145,              /* declaration  */
  YYSYMBOL_swig_directive = 146,           /* swig_directive  */
  YYSYMBOL_extend_directive = 147,         /* extend_directive  */
  YYSYMBOL_148_1 = 148,                    /* $@1  */
  YYSYMBOL_apply_directive = 149,          /* apply_directive  */
  YYSYMBOL_clear_directive = 150,          /* clear_directive  */
  YYSYMBOL_constant_directive = 151,       /* constant_directive  */
  YYSYMBOL_echo_directive = 152,           /* echo_directive  */
  YYSYMBOL_stringtype = 153,               /* stringtype  */
  YYSYMBOL_fname = 154,                    /* fname  */
  YYSYMBOL_fragment_directive = 155,       /* fragment_directive  */
  YYSYMBOL_include_directive = 156,        /* include_directive  */
  YYSYMBOL_157_2 = 157,                    /* @2  */
  YYSYMBOL_includetype = 158,              /* includetype  */
  YYSYMBOL_inline_directive = 159,         /* inline_directive  */
  YYSYMBOL_insert_directive = 160,         /* insert_directive  */
  YYSYMBOL_module_directive = 161,         /* module_directive  */
  YYSYMBOL_native_directive = 162,         /* native_directive  */
  YYSYMBOL_pragma_directive = 163,         /* pragma_directive  */
  YYSYMBOL_pragma_arg = 164,               /* pragma_arg  */
  YYSYMBOL_pragma_lang = 165,              /* pragma_lang  */
  YYSYMBOL_rename_directive = 166,         /* rename_directive  */
  YYSYMBOL_rename_namewarn = 167,          /* rename_namewarn  */
  YYSYMBOL_feature_directive = 168,        /* feature_directive  */
  YYSYMBOL_stringbracesemi = 169,          /* stringbracesemi  */
  YYSYMBOL_featattr = 170,                 /* featattr  */
  YYSYMBOL_varargs_directive = 171,        /* varargs_directive  */
  YYSYMBOL_varargs_parms = 172,            /* varargs_parms  */
  YYSYMBOL_typemap_directive = 173,        /* typemap_directive  */
  YYSYMBOL_typemap_type = 174,             /* typemap_type  */
  YYSYMBOL_tm_list = 175,                  /* tm_list  */
  YYSYMBOL_tm_list_builder = 176,          /* tm_list_builder  */
  YYSYMBOL_typemap_parm = 177,             /* typemap_parm  */
  YYSYMBOL_types_directive = 178,          /* types_directive  */
  YYSYMBOL_template_directive = 179,       /* template_directive  */
  YYSYMBOL_warn_directive = 180,           /* warn_directive  */
  YYSYMBOL_c_declaration = 181,            /* c_declaration  */
  YYSYMBOL_182_3 = 182,                    /* $@3  */
  YYSYMBOL_c_decl = 183,                   /* c_decl  */
  YYSYMBOL_c_decl_tail = 184,              /* c_decl_tail  */
  YYSYMBOL_initializer = 185,              /* initializer  */
  YYSYMBOL_cpp_alternate_rettype = 186,    /* cpp_alternate_rettype  */
  YYSYMBOL_cpp_lambda_decl = 187,          /* cpp_lambda_decl  */
  YYSYMBOL_lambda_introducer = 188,        /* lambda_introducer  */
  YYSYMBOL_lambda_template = 189,          /* lambda_template  */
  YYSYMBOL_lambda_body = 190,              /* lambda_body  */
  YYSYMBOL_lambda_tail = 191,              /* lambda_tail  */
  YYSYMBOL_192_4 = 192,                    /* $@4  */
  YYSYMBOL_c_enum_key = 193,               /* c_enum_key  */
  YYSYMBOL_c_enum_inherit = 194,           /* c_enum_inherit  */
  YYSYMBOL_c_enum_forward_decl = 195,      /* c_enum_forward_decl  */
  YYSYMBOL_c_enum_decl = 196,              /* c_enum_decl  */
  YYSYMBOL_c_constructor_decl = 197,       /* c_constructor_decl  */
  YYSYMBOL_cpp_declaration = 198,          /* cpp_declaration  */
  YYSYMBOL_cpp_class_decl = 199,           /* cpp_class_decl  */
  YYSYMBOL_200_5 = 200,                    /* @5  */
  YYSYMBOL_201_6 = 201,                    /* @6  */
  YYSYMBOL_cpp_opt_declarators = 202,      /* cpp_opt_declarators  */
  YYSYMBOL_cpp_forward_class_decl = 203,   /* cpp_forward_class_decl  */
  YYSYMBOL_cpp_template_decl = 204,        /* cpp_template_decl  */
  YYSYMBOL_205_7 = 205,                    /* $@7  */
  YYSYMBOL_cpp_template_possible = 206,    /* cpp_template_possible  */
  YYSYMBOL_template_parms = 207,           /* template_parms  */
  YYSYMBOL_template_parms_builder = 208,   /* template_parms_builder  */
  YYSYMBOL_templateparameter = 209,        /* templateparameter  */
  YYSYMBOL_cpp_using_decl = 210,           /* cpp_using_decl  */
  YYSYMBOL_cpp_namespace_decl = 211,       /* cpp_namespace_decl  */
  YYSYMBOL_212_8 = 212,                    /* @8  */
  YYSYMBOL_213_9 = 213,                    /* @9  */
  YYSYMBOL_cpp_members = 214,              /* cpp_members  */
  YYSYMBOL_cpp_members_builder = 215,      /* cpp_members_builder  */
  YYSYMBOL_cpp_member_no_dox = 216,        /* cpp_member_no_dox  */
  YYSYMBOL_cpp_member = 217,               /* cpp_member  */
  YYSYMBOL_218_10 = 218,                   /* $@10  */
  YYSYMBOL_cpp_constructor_decl = 219,     /* cpp_constructor_decl  */
  YYSYMBOL_cpp_destructor_decl = 220,      /* cpp_destructor_decl  */
  YYSYMBOL_cpp_conversion_operator = 221,  /* cpp_conversion_operator  */
  YYSYMBOL_cpp_catch_decl = 222,           /* cpp_catch_decl  */
  YYSYMBOL_cpp_static_assert = 223,        /* cpp_static_assert  */
  YYSYMBOL_cpp_protection_decl = 224,      /* cpp_protection_decl  */
  YYSYMBOL_cpp_swig_directive = 225,       /* cpp_swig_directive  */
  YYSYMBOL_cpp_vend = 226,                 /* cpp_vend  */
  YYSYMBOL_anonymous_bitfield = 227,       /* anonymous_bitfield  */
  YYSYMBOL_anon_bitfield_type = 228,       /* anon_bitfield_type  */
  YYSYMBOL_storage_class = 229,            /* storage_class  */
  YYSYMBOL_storage_class_list = 230,       /* storage_class_list  */
  YYSYMBOL_storage_class_raw = 231,        /* storage_class_raw  */
  YYSYMBOL_parms = 232,                    /* parms  */
  YYSYMBOL_rawparms = 233,                 /* rawparms  */
  YYSYMBOL_parm_no_dox = 234,              /* parm_no_dox  */
  YYSYMBOL_parm = 235,                     /* parm  */
  YYSYMBOL_valparms = 236,                 /* valparms  */
  YYSYMBOL_valparms_builder = 237,         /* valparms_builder  */
  YYSYMBOL_valparm = 238,                  /* valparm  */
  YYSYMBOL_def_args = 239,                 /* def_args  */
  YYSYMBOL_parameter_declarator = 240,     /* parameter_declarator  */
  YYSYMBOL_plain_declarator = 241,         /* plain_declarator  */
  YYSYMBOL_declarator = 242,               /* declarator  */
  YYSYMBOL_notso_direct_declarator = 243,  /* notso_direct_declarator  */
  YYSYMBOL_direct_declarator = 244,        /* direct_declarator  */
  YYSYMBOL_abstract_declarator = 245,      /* abstract_declarator  */
  YYSYMBOL_direct_abstract_declarator = 246, /* direct_abstract_declarator  */
  YYSYMBOL_pointer = 247,                  /* pointer  */
  YYSYMBOL_cv_ref_qualifier = 248,         /* cv_ref_qualifier  */
  YYSYMBOL_ref_qualifier = 249,            /* ref_qualifier  */
  YYSYMBOL_type_qualifier = 250,           /* type_qualifier  */
  YYSYMBOL_type_qualifier_raw = 251,       /* type_qualifier_raw  */
  YYSYMBOL_type = 252,                     /* type  */
  YYSYMBOL_rawtype = 253,                  /* rawtype  */
  YYSYMBOL_type_right = 254,               /* type_right  */
  YYSYMBOL_decltype = 255,                 /* decltype  */
  YYSYMBOL_256_11 = 256,                   /* @11  */
  YYSYMBOL_decltypeexpr = 257,             /* decltypeexpr  */
  YYSYMBOL_primitive_type = 258,           /* primitive_type  */
  YYSYMBOL_primitive_type_list = 259,      /* primitive_type_list  */
  YYSYMBOL_type_specifier = 260,           /* type_specifier  */
  YYSYMBOL_definetype = 261,               /* definetype  */
  YYSYMBOL_default_delete = 262,           /* default_delete  */
  YYSYMBOL_deleted_definition = 263,       /* deleted_definition  */
  YYSYMBOL_explicit_default = 264,         /* explicit_default  */
  YYSYMBOL_ename = 265,                    /* ename  */
  YYSYMBOL_constant_directives = 266,      /* constant_directives  */
  YYSYMBOL_optional_ignored_defines = 267, /* optional_ignored_defines  */
  YYSYMBOL_enumlist = 268,                 /* enumlist  */
  YYSYMBOL_enumlist_item = 269,            /* enumlist_item  */
  YYSYMBOL_edecl_with_dox = 270,           /* edecl_with_dox  */
  YYSYMBOL_edecl = 271,                    /* edecl  */
  YYSYMBOL_etype = 272,                    /* etype  */
  YYSYMBOL_expr = 273,                     /* expr  */
  YYSYMBOL_exprmem = 274,                  /* exprmem  */
  YYSYMBOL_exprsimple = 275,               /* exprsimple  */
  YYSYMBOL_valexpr = 276,                  /* valexpr  */
  YYSYMBOL_exprnum = 277,                  /* exprnum  */
  YYSYMBOL_exprcompound = 278,             /* exprcompound  */
  YYSYMBOL_variadic_opt = 279,             /* variadic_opt  */
  YYSYMBOL_inherit = 280,                  /* inherit  */
  YYSYMBOL_raw_inherit = 281,              /* raw_inherit  */
  YYSYMBOL_282_12 = 282,                   /* $@12  */
  YYSYMBOL_base_list = 283,                /* base_list  */
  YYSYMBOL_base_specifier = 284,           /* base_specifier  */
  YYSYMBOL_285_13 = 285,                   /* @13  */
  YYSYMBOL_286_14 = 286,                   /* @14  */
  YYSYMBOL_access_specifier = 287,         /* access_specifier  */
  YYSYMBOL_templcpptype = 288,             /* templcpptype  */
  YYSYMBOL_cpptype = 289,                  /* cpptype  */
  YYSYMBOL_classkey = 290,                 /* classkey  */
  YYSYMBOL_classkeyopt = 291,              /* classkeyopt  */
  YYSYMBOL_opt_virtual = 292,              /* opt_virtual  */
  YYSYMBOL_virt_specifier_seq = 293,       /* virt_specifier_seq  */
  YYSYMBOL_virt_specifier_seq_opt = 294,   /* virt_specifier_seq_opt  */
  YYSYMBOL_class_virt_specifier_opt = 295, /* class_virt_specifier_opt  */
  YYSYMBOL_exception_specification = 296,  /* exception_specification  */
  YYSYMBOL_qualifiers_exception_specification = 297, /* qualifiers_exception_specification  */
  YYSYMBOL_cpp_const = 298,                /* cpp_const  */
  YYSYMBOL_ctor_end = 299,                 /* ctor_end  */
  YYSYMBOL_ctor_initializer = 300,         /* ctor_initializer  */
  YYSYMBOL_mem_initializer_list = 301,     /* mem_initializer_list  */
  YYSYMBOL_mem_initializer = 302,          /* mem_initializer  */
  YYSYMBOL_less_valparms_greater = 303,    /* less_valparms_greater  */
  YYSYMBOL_identifier = 304,               /* identifier  */
  YYSYMBOL_idstring = 305,                 /* idstring  */
  YYSYMBOL_idstringopt = 306,              /* idstringopt  */
  YYSYMBOL_idcolon = 307,                  /* idcolon  */
  YYSYMBOL_idcolontail = 308,              /* idcolontail  */
  YYSYMBOL_idtemplate = 309,               /* idtemplate  */
  YYSYMBOL_idtemplatetemplate = 310,       /* idtemplatetemplate  */
  YYSYMBOL_idcolonnt = 311,                /* idcolonnt  */
  YYSYMBOL_idcolontailnt = 312,            /* idcolontailnt  */
  YYSYMBOL_string = 313,                   /* string  */
  YYSYMBOL_wstring = 314,                  /* wstring  */
  YYSYMBOL_stringbrace = 315,              /* stringbrace  */
  YYSYMBOL_options = 316,                  /* options  */
  YYSYMBOL_kwargs = 317,                   /* kwargs  */
  YYSYMBOL_kwargs_builder = 318,           /* kwargs_builder  */
  YYSYMBOL_stringnum = 319                 /* stringnum  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;


/* Second part of user prologue.  */
#line 1882 "parser.y"


// Default-initialised instances of token types to avoid uninitialised fields.
// The compiler will initialise all fields to zero or NULL for us.

static const struct Decl default_decl;
static const struct Define default_dtype;

/* C++ decltype/auto type deduction. */
static SwigType *deduce_type(const struct Define *dtype) {
  Node *n;
  if (!dtype->val) return NULL;
  n = Swig_symbol_clookup(dtype->val, 0);
  if (n) {
    if (Strcmp(nodeType(n),"enumitem") == 0) {
      /* For an enumitem, the "type" attribute gives us the underlying integer
       * type - we want the "type" attribute from the enum itself, which is
       * "parentNode".
       */
      n = Getattr(n, "parentNode");
    }
    return Getattr(n, "type");
  } else if (dtype->type != T_AUTO && dtype->type != T_UNKNOWN) {
    /* Try to deduce the type from the T_* type code. */
    String *deduced_type = NewSwigType(dtype->type);
    if (Len(deduced_type) > 0) return deduced_type;
    Delete(deduced_type);
  }
  return NULL;
}

// Append scanner_ccode to expr.  Some cleaning up of the code may be done.
static void append_expr_from_scanner(String *expr) {
  if (Strchr(scanner_ccode, '"') == NULL) {
    // Append scanner_ccode, changing any whitespace character to a space.
    int len = Len(scanner_ccode);
    for (int i = 0; i < len; ++i) {
      char ch = Char(scanner_ccode)[i];
      if (isspace((unsigned char)ch)) ch = ' ';
      Putc(ch, expr);
    }
  } else {
    // The code contains a double quote so leave it be as changing a
    // backslash-escaped linefeed character (i.e. `\` followed by byte 0x0a)
    // in a string literal into a space will insert a space into the string
    // literal's value.  An expression containing a double quote won't work if
    // used in a context where a swig_type_info is generated as the typename
    // gets substituted into a string literal without any escaping which will
    // result in invalid code due to the double quotes.
    Append(expr, scanner_ccode);
  }
  Clear(scanner_ccode);
}

static Node *new_enum_node(SwigType *enum_base_type) {
  Node *n = new_node("enum");
  if (enum_base_type) {
    switch (SwigType_type(enum_base_type)) {
      case T_USER:
	// We get T_USER if the underlying type is a typedef.  Unfortunately we
	// aren't able to resolve a typedef at this point, so we have to assume
	// it's a typedef to an integral or boolean type.
	break;
      case T_BOOL:
      case T_SCHAR:
      case T_UCHAR:
      case T_SHORT:
      case T_USHORT:
      case T_INT:
      case T_UINT:
      case T_LONG:
      case T_ULONG:
      case T_LONGLONG:
      case T_ULONGLONG:
      case T_CHAR:
      case T_WCHAR:
	break;
      default:
	Swig_error(cparse_file, cparse_line, "Underlying type of enum must be an integral type\n");
    }
    Setattr(n, "enumbase", enum_base_type);
  }
  return n;
}


#line 2083 "parser.c"


#ifdef short
# undef short
#endif

/* On compilers that do not define __PTRDIFF_MAX__ etc., make sure
   <limits.h> and (if available) <stdint.h> are included
   so that the code can choose integer types of a good width.  */

#ifndef __PTRDIFF_MAX__
# include <limits.h> /* INFRINGES ON USER NAME SPACE */
# if defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stdint.h> /* INFRINGES ON USER NAME SPACE */
#  define YY_STDINT_H
# endif
#endif

/* Narrow types that promote to a signed type and that can represent a
   signed or unsigned integer of at least N bits.  In tables they can
   save space and decrease cache pressure.  Promoting to a signed type
   helps avoid bugs in integer arithmetic.  */

#ifdef __INT_LEAST8_MAX__
typedef __INT_LEAST8_TYPE__ yytype_int8;
#elif defined YY_STDINT_H
typedef int_least8_t yytype_int8;
#else
typedef signed char yytype_int8;
#endif

#ifdef __INT_LEAST16_MAX__
typedef __INT_LEAST16_TYPE__ yytype_int16;
#elif defined YY_STDINT_H
typedef int_least16_t yytype_int16;
#else
typedef short yytype_int16;
#endif

/* Work around bug in HP-UX 11.23, which defines these macros
   incorrectly for preprocessor constants.  This workaround can likely
   be removed in 2023, as HPE has promised support for HP-UX 11.23
   (aka HP-UX 11i v2) only through the end of 2022; see Table 2 of
   <https://h20195.www2.hpe.com/V2/getpdf.aspx/4AA4-7673ENW.pdf>.  */
#ifdef __hpux
# undef UINT_LEAST8_MAX
# undef UINT_LEAST16_MAX
# define UINT_LEAST8_MAX 255
# define UINT_LEAST16_MAX 65535
#endif

#if defined __UINT_LEAST8_MAX__ && __UINT_LEAST8_MAX__ <= __INT_MAX__
typedef __UINT_LEAST8_TYPE__ yytype_uint8;
#elif (!defined __UINT_LEAST8_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST8_MAX <= INT_MAX)
typedef uint_least8_t yytype_uint8;
#elif !defined __UINT_LEAST8_MAX__ && UCHAR_MAX <= INT_MAX
typedef unsigned char yytype_uint8;
#else
typedef short yytype_uint8;
#endif

#if defined __UINT_LEAST16_MAX__ && __UINT_LEAST16_MAX__ <= __INT_MAX__
typedef __UINT_LEAST16_TYPE__ yytype_uint16;
#elif (!defined __UINT_LEAST16_MAX__ && defined YY_STDINT_H \
       && UINT_LEAST16_MAX <= INT_MAX)
typedef uint_least16_t yytype_uint16;
#elif !defined __UINT_LEAST16_MAX__ && USHRT_MAX <= INT_MAX
typedef unsigned short yytype_uint16;
#else
typedef int yytype_uint16;
#endif

#ifndef YYPTRDIFF_T
# if defined __PTRDIFF_TYPE__ && defined __PTRDIFF_MAX__
#  define YYPTRDIFF_T __PTRDIFF_TYPE__
#  define YYPTRDIFF_MAXIMUM __PTRDIFF_MAX__
# elif defined PTRDIFF_MAX
#  ifndef ptrdiff_t
#   include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  endif
#  define YYPTRDIFF_T ptrdiff_t
#  define YYPTRDIFF_MAXIMUM PTRDIFF_MAX
# else
#  define YYPTRDIFF_T long
#  define YYPTRDIFF_MAXIMUM LONG_MAX
# endif
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif defined __STDC_VERSION__ && 199901 <= __STDC_VERSION__
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned
# endif
#endif

#define YYSIZE_MAXIMUM                                  \
  YY_CAST (YYPTRDIFF_T,                                 \
           (YYPTRDIFF_MAXIMUM < YY_CAST (YYSIZE_T, -1)  \
            ? YYPTRDIFF_MAXIMUM                         \
            : YY_CAST (YYSIZE_T, -1)))

#define YYSIZEOF(X) YY_CAST (YYPTRDIFF_T, sizeof (X))


/* Stored state numbers (used for stacks). */
typedef yytype_int16 yy_state_t;

/* State numbers in computations.  */
typedef int yy_state_fast_t;

#ifndef YY_
# if defined YYENABLE_NLS && YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(Msgid) Msgid
# endif
#endif


#ifndef YY_ATTRIBUTE_PURE
# if defined __GNUC__ && 2 < __GNUC__ + (96 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define YY_ATTRIBUTE_PURE
# endif
#endif

#ifndef YY_ATTRIBUTE_UNUSED
# if defined __GNUC__ && 2 < __GNUC__ + (7 <= __GNUC_MINOR__)
#  define YY_ATTRIBUTE_UNUSED __attribute__ ((__unused__))
# else
#  define YY_ATTRIBUTE_UNUSED
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YY_USE(E) ((void) (E))
#else
# define YY_USE(E) /* empty */
#endif

/* Suppress an incorrect diagnostic about yylval being uninitialized.  */
#if defined __GNUC__ && ! defined __ICC && 406 <= __GNUC__ * 100 + __GNUC_MINOR__
# if __GNUC__ * 100 + __GNUC_MINOR__ < 407
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")
# else
#  define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN                           \
    _Pragma ("GCC diagnostic push")                                     \
    _Pragma ("GCC diagnostic ignored \"-Wuninitialized\"")              \
    _Pragma ("GCC diagnostic ignored \"-Wmaybe-uninitialized\"")
# endif
# define YY_IGNORE_MAYBE_UNINITIALIZED_END      \
    _Pragma ("GCC diagnostic pop")
#else
# define YY_INITIAL_VALUE(Value) Value
#endif
#ifndef YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
# define YY_IGNORE_MAYBE_UNINITIALIZED_END
#endif
#ifndef YY_INITIAL_VALUE
# define YY_INITIAL_VALUE(Value) /* Nothing. */
#endif

#if defined __cplusplus && defined __GNUC__ && ! defined __ICC && 6 <= __GNUC__
# define YY_IGNORE_USELESS_CAST_BEGIN                          \
    _Pragma ("GCC diagnostic push")                            \
    _Pragma ("GCC diagnostic ignored \"-Wuseless-cast\"")
# define YY_IGNORE_USELESS_CAST_END            \
    _Pragma ("GCC diagnostic pop")
#endif
#ifndef YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_BEGIN
# define YY_IGNORE_USELESS_CAST_END
#endif


#define YY_ASSERT(E) ((void) (0 && (E)))

#if !defined yyoverflow

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
#    if ! defined _ALLOCA_H && ! defined EXIT_SUCCESS
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
      /* Use EXIT_SUCCESS as a witness for stdlib.h.  */
#     ifndef EXIT_SUCCESS
#      define EXIT_SUCCESS 0
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's 'empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (0)
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
#  if (defined __cplusplus && ! defined EXIT_SUCCESS \
       && ! ((defined YYMALLOC || defined malloc) \
             && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef EXIT_SUCCESS
#    define EXIT_SUCCESS 0
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined EXIT_SUCCESS
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined EXIT_SUCCESS
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* !defined yyoverflow */

#if (! defined yyoverflow \
     && (! defined __cplusplus \
         || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yy_state_t yyss_alloc;
  YYSTYPE yyvs_alloc;
};

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (YYSIZEOF (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (YYSIZEOF (yy_state_t) + YYSIZEOF (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

# define YYCOPY_NEEDED 1

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack_alloc, Stack)                           \
    do                                                                  \
      {                                                                 \
        YYPTRDIFF_T yynewbytes;                                         \
        YYCOPY (&yyptr->Stack_alloc, Stack, yysize);                    \
        Stack = &yyptr->Stack_alloc;                                    \
        yynewbytes = yystacksize * YYSIZEOF (*Stack) + YYSTACK_GAP_MAXIMUM; \
        yyptr += yynewbytes / YYSIZEOF (*yyptr);                        \
      }                                                                 \
    while (0)

#endif

#if defined YYCOPY_NEEDED && YYCOPY_NEEDED
/* Copy COUNT objects from SRC to DST.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(Dst, Src, Count) \
      __builtin_memcpy (Dst, Src, YY_CAST (YYSIZE_T, (Count)) * sizeof (*(Src)))
#  else
#   define YYCOPY(Dst, Src, Count)              \
      do                                        \
        {                                       \
          YYPTRDIFF_T yyi;                      \
          for (yyi = 0; yyi < (Count); yyi++)   \
            (Dst)[yyi] = (Src)[yyi];            \
        }                                       \
      while (0)
#  endif
# endif
#endif /* !YYCOPY_NEEDED */

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  59
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   9428

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  142
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  178
/* YYNRULES -- Number of rules.  */
#define YYNRULES  634
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1157

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   396


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX) YY_CAST (yysymbol_kind_t, YYX)

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,  1978,  1978,  1990,  1994,  1997,  2000,  2003,  2006,  2011,
    2020,  2025,  2034,  2039,  2040,  2041,  2042,  2043,  2052,  2068,
    2079,  2080,  2081,  2082,  2083,  2084,  2085,  2086,  2087,  2088,
    2089,  2090,  2091,  2092,  2093,  2094,  2095,  2096,  2097,  2104,
    2104,  2186,  2196,  2210,  2228,  2246,  2264,  2268,  2279,  2288,
    2301,  2308,  2312,  2323,  2333,  2348,  2361,  2361,  2422,  2423,
    2430,  2448,  2482,  2487,  2497,  2503,  2521,  2564,  2571,  2598,
    2604,  2611,  2612,  2615,  2616,  2623,  2669,  2715,  2726,  2729,
    2756,  2762,  2770,  2776,  2784,  2785,  2786,  2789,  2795,  2802,
    2838,  2839,  2873,  2892,  2902,  2917,  2939,  2944,  2947,  2958,
    2969,  2974,  2987,  2999,  3243,  3253,  3260,  3261,  3265,  3265,
    3298,  3304,  3314,  3326,  3333,  3416,  3464,  3529,  3574,  3614,
    3631,  3646,  3650,  3677,  3681,  3692,  3693,  3699,  3700,  3701,
    3702,  3706,  3707,  3711,  3715,  3720,  3725,  3736,  3742,  3748,
    3756,  3761,  3764,  3767,  3771,  3772,  3772,  3784,  3787,  3790,
    3799,  3802,  3809,  3832,  3861,  3959,  4016,  4017,  4018,  4019,
    4020,  4021,  4030,  4030,  4277,  4277,  4432,  4433,  4445,  4464,
    4464,  4668,  4674,  4680,  4686,  4692,  4693,  4694,  4695,  4698,
    4699,  4702,  4705,  4710,  4713,  4724,  4732,  4740,  4748,  4773,
    4784,  4794,  4825,  4825,  4883,  4883,  4905,  4932,  4935,  4940,
    4943,  4948,  4954,  4957,  4987,  4988,  5005,  5006,  5007,  5008,
    5009,  5010,  5011,  5012,  5013,  5014,  5015,  5016,  5017,  5018,
    5019,  5020,  5021,  5023,  5024,  5028,  5032,  5032,  5051,  5089,
    5130,  5151,  5174,  5198,  5223,  5248,  5256,  5263,  5270,  5278,
    5286,  5289,  5291,  5292,  5293,  5294,  5295,  5296,  5297,  5298,
    5301,  5305,  5310,  5317,  5320,  5321,  5322,  5324,  5330,  5372,
    5375,  5376,  5384,  5385,  5395,  5396,  5397,  5398,  5399,  5400,
    5401,  5408,  5420,  5421,  5425,  5430,  5436,  5443,  5450,  5455,
    5467,  5475,  5476,  5482,  5490,  5495,  5498,  5509,  5537,  5547,
    5550,  5558,  5564,  5570,  5576,  5582,  5590,  5613,  5630,  5649,
    5668,  5673,  5681,  5690,  5699,  5703,  5712,  5723,  5734,  5746,
    5756,  5770,  5779,  5789,  5799,  5809,  5821,  5833,  5846,  5857,
    5868,  5880,  5894,  5899,  5905,  5917,  5925,  5936,  5947,  5958,
    5977,  5983,  5996,  6004,  6011,  6018,  6029,  6041,  6052,  6064,
    6075,  6086,  6106,  6120,  6125,  6131,  6137,  6143,  6152,  6161,
    6162,  6171,  6180,  6186,  6192,  6197,  6203,  6211,  6222,  6233,
    6244,  6249,  6254,  6257,  6274,  6292,  6302,  6307,  6311,  6316,
    6323,  6326,  6331,  6338,  6342,  6348,  6352,  6358,  6359,  6360,
    6366,  6372,  6376,  6377,  6381,  6386,  6392,  6393,  6394,  6395,
    6397,  6400,  6403,  6406,  6406,  6423,  6426,  6439,  6465,  6466,
    6520,  6524,  6528,  6532,  6536,  6540,  6544,  6548,  6552,  6556,
    6560,  6564,  6568,  6572,  6578,  6579,  6582,  6583,  6587,  6595,
    6604,  6605,  6608,  6609,  6613,  6614,  6624,  6628,  6633,  6639,
    6649,  6660,  6671,  6676,  6681,  6682,  6688,  6696,  6714,  6732,
    6733,  6760,  6764,  6768,  6772,  6776,  6781,  6809,  6810,  6811,
    6817,  6823,  6829,  6841,  6849,  6857,  6864,  6874,  6881,  6882,
    6885,  6895,  6934,  6944,  6954,  6964,  6975,  6986,  7007,  7030,
    7031,  7032,  7033,  7034,  7035,  7036,  7037,  7038,  7039,  7042,
    7047,  7052,  7057,  7062,  7067,  7072,  7077,  7082,  7087,  7092,
    7097,  7102,  7107,  7116,  7127,  7132,  7137,  7154,  7159,  7164,
    7169,  7174,  7179,  7184,  7189,  7194,  7199,  7204,  7209,  7214,
    7219,  7228,  7238,  7243,  7248,  7254,  7269,  7276,  7302,  7313,
    7318,  7325,  7328,  7333,  7336,  7336,  7337,  7340,  7357,  7366,
    7366,  7385,  7385,  7404,  7405,  7406,  7409,  7414,  7421,  7422,
    7426,  7432,  7435,  7438,  7443,  7444,  7447,  7448,  7451,  7454,
    7457,  7460,  7465,  7466,  7471,  7474,  7479,  7484,  7488,  7492,
    7498,  7503,  7509,  7514,  7517,  7524,  7525,  7530,  7540,  7550,
    7556,  7562,  7568,  7582,  7583,  7586,  7587,  7588,  7589,  7592,
    7604,  7610,  7619,  7620,  7621,  7624,  7625,  7626,  7629,  7630,
    7633,  7637,  7641,  7644,  7647,  7650,  7655,  7661,  7665,  7668,
    7672,  7678,  7681,  7688,  7689,  7697,  7701,  7705,  7708,  7711,
    7714,  7720,  7724,  7727,  7731,  7737,  7742,  7744,  7750,  7756,
    7762,  7765,  7766,  7770,  7773,  7786,  7790,  7795,  7802,  7811,
    7816,  7823,  7828,  7837,  7838
};
#endif

/** Accessing symbol of state STATE.  */
#define YY_ACCESSING_SYMBOL(State) YY_CAST (yysymbol_kind_t, yystos[State])

#if YYDEBUG || 0
/* The user-facing name of the symbol whose (internal) number is
   YYSYMBOL.  No bounds checking.  */
static const char *yysymbol_name (yysymbol_kind_t yysymbol) YY_ATTRIBUTE_UNUSED;

/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "END", "error", "\"invalid token\"", "ID", "HBLOCK", "POUND", "STRING",
  "WSTRING", "INCLUDE", "IMPORT", "INSERT", "CHARCONST", "WCHARCONST",
  "NUM_INT", "NUM_DOUBLE", "NUM_FLOAT", "NUM_LONGDOUBLE", "NUM_UNSIGNED",
  "NUM_LONG", "NUM_ULONG", "NUM_LONGLONG", "NUM_ULONGLONG", "NUM_BOOL",
  "TYPEDEF", "TYPE_INT", "TYPE_UNSIGNED", "TYPE_SHORT", "TYPE_LONG",
  "TYPE_FLOAT", "TYPE_DOUBLE", "TYPE_CHAR", "TYPE_WCHAR", "TYPE_VOID",
  "TYPE_SIGNED", "TYPE_BOOL", "TYPE_COMPLEX", "TYPE_NON_ISO_INT8",
  "TYPE_NON_ISO_INT16", "TYPE_NON_ISO_INT32", "TYPE_NON_ISO_INT64",
  "LPAREN", "RPAREN", "COMMA", "SEMI", "EXTERN", "LBRACE", "RBRACE",
  "PERIOD", "ELLIPSIS", "CONST_QUAL", "VOLATILE", "REGISTER", "STRUCT",
  "UNION", "EQUAL", "SIZEOF", "ALIGNOF", "MODULE", "LBRACKET", "RBRACKET",
  "BEGINFILE", "ENDOFFILE", "CONSTANT", "RENAME", "NAMEWARN", "EXTEND",
  "PRAGMA", "FEATURE", "VARARGS", "ENUM", "CLASS", "TYPENAME", "PRIVATE",
  "PUBLIC", "PROTECTED", "COLON", "STATIC", "VIRTUAL", "FRIEND", "THROW",
  "CATCH", "EXPLICIT", "STATIC_ASSERT", "CONSTEXPR", "THREAD_LOCAL",
  "DECLTYPE", "AUTO", "NOEXCEPT", "OVERRIDE", "FINAL", "USING",
  "NAMESPACE", "NATIVE", "INLINE", "TYPEMAP", "ECHO", "APPLY", "CLEAR",
  "SWIGTEMPLATE", "FRAGMENT", "WARN", "LESSTHAN", "GREATERTHAN",
  "DELETE_KW", "DEFAULT", "LESSTHANOREQUALTO", "GREATERTHANOREQUALTO",
  "EQUALTO", "NOTEQUALTO", "LESSEQUALGREATER", "ARROW", "QUESTIONMARK",
  "TYPES", "PARMS", "NONID", "DSTAR", "DCNOT", "TEMPLATE", "OPERATOR",
  "CONVERSIONOPERATOR", "PARSETYPE", "PARSEPARM", "PARSEPARMS",
  "DOXYGENSTRING", "DOXYGENPOSTSTRING", "LOR", "LAND", "OR", "XOR", "AND",
  "LSHIFT", "RSHIFT", "PLUS", "MINUS", "STAR", "SLASH", "MODULO", "UMINUS",
  "NOT", "LNOT", "CAST", "DCOLON", "$accept", "program", "interface",
  "declaration", "swig_directive", "extend_directive", "$@1",
  "apply_directive", "clear_directive", "constant_directive",
  "echo_directive", "stringtype", "fname", "fragment_directive",
  "include_directive", "@2", "includetype", "inline_directive",
  "insert_directive", "module_directive", "native_directive",
  "pragma_directive", "pragma_arg", "pragma_lang", "rename_directive",
  "rename_namewarn", "feature_directive", "stringbracesemi", "featattr",
  "varargs_directive", "varargs_parms", "typemap_directive",
  "typemap_type", "tm_list", "tm_list_builder", "typemap_parm",
  "types_directive", "template_directive", "warn_directive",
  "c_declaration", "$@3", "c_decl", "c_decl_tail", "initializer",
  "cpp_alternate_rettype", "cpp_lambda_decl", "lambda_introducer",
  "lambda_template", "lambda_body", "lambda_tail", "$@4", "c_enum_key",
  "c_enum_inherit", "c_enum_forward_decl", "c_enum_decl",
  "c_constructor_decl", "cpp_declaration", "cpp_class_decl", "@5", "@6",
  "cpp_opt_declarators", "cpp_forward_class_decl", "cpp_template_decl",
  "$@7", "cpp_template_possible", "template_parms",
  "template_parms_builder", "templateparameter", "cpp_using_decl",
  "cpp_namespace_decl", "@8", "@9", "cpp_members", "cpp_members_builder",
  "cpp_member_no_dox", "cpp_member", "$@10", "cpp_constructor_decl",
  "cpp_destructor_decl", "cpp_conversion_operator", "cpp_catch_decl",
  "cpp_static_assert", "cpp_protection_decl", "cpp_swig_directive",
  "cpp_vend", "anonymous_bitfield", "anon_bitfield_type", "storage_class",
  "storage_class_list", "storage_class_raw", "parms", "rawparms",
  "parm_no_dox", "parm", "valparms", "valparms_builder", "valparm",
  "def_args", "parameter_declarator", "plain_declarator", "declarator",
  "notso_direct_declarator", "direct_declarator", "abstract_declarator",
  "direct_abstract_declarator", "pointer", "cv_ref_qualifier",
  "ref_qualifier", "type_qualifier", "type_qualifier_raw", "type",
  "rawtype", "type_right", "decltype", "@11", "decltypeexpr",
  "primitive_type", "primitive_type_list", "type_specifier", "definetype",
  "default_delete", "deleted_definition", "explicit_default", "ename",
  "constant_directives", "optional_ignored_defines", "enumlist",
  "enumlist_item", "edecl_with_dox", "edecl", "etype", "expr", "exprmem",
  "exprsimple", "valexpr", "exprnum", "exprcompound", "variadic_opt",
  "inherit", "raw_inherit", "$@12", "base_list", "base_specifier", "@13",
  "@14", "access_specifier", "templcpptype", "cpptype", "classkey",
  "classkeyopt", "opt_virtual", "virt_specifier_seq",
  "virt_specifier_seq_opt", "class_virt_specifier_opt",
  "exception_specification", "qualifiers_exception_specification",
  "cpp_const", "ctor_end", "ctor_initializer", "mem_initializer_list",
  "mem_initializer", "less_valparms_greater", "identifier", "idstring",
  "idstringopt", "idcolon", "idcolontail", "idtemplate",
  "idtemplatetemplate", "idcolonnt", "idcolontailnt", "string", "wstring",
  "stringbrace", "options", "kwargs", "kwargs_builder", "stringnum", YY_NULLPTR
};

static const char *
yysymbol_name (yysymbol_kind_t yysymbol)
{
  return yytname[yysymbol];
}
#endif

#define YYPACT_NINF (-1037)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-602)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     700,  7575,  7675,    48,    91,  7026, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
     384,   129,   129,   131, -1037, -1037,   -43,   105,  8491,   459,
   -1037,   253,  8701, -1037,  1345,   909, -1037, -1037, -1037,  4296,
   -1037,   459,   105, -1037,   217, -1037,   260, -1037,  8077, -1037,
     224, -1037, -1037, -1037,   308, -1037, -1037,    20,   353,  8241,
   -1037, -1037,   353,   362,   366,   420, -1037, -1037, -1037,   435,
   -1037,   467, -1037, -1037,  1115,    58,   480,   216,   564,   635,
    8561,  8561,   577,   590,   485,   605,  8771, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,   353, -1037,
   -1037, -1037, -1037, -1037, -1037,  1790, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037,  8631,  1192, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037,   179,  2756, -1037, -1037, -1037,
   -1037, -1037,   909,  6664, -1037,  2622,  3292,    43,   415,  1444,
     909,   459, -1037, -1037,   246,   458,   246,   504,  1438,   446,
     909, -1037, -1037, -1037,   159,   187, -1037, -1037,   613, -1037,
      63, -1037,   539, -1037,  8961,   238,   539,   539,   294,  1844,
     640,    28,   461,   159,   159,   539,  7877,  8077, -1037,   459,
     459,   515, -1037,   115,   651,   159, -1037, -1037,   539, -1037,
     703,  8077,   668,  1351,   674,   691, -1037,   539,   485,   703,
    8077, -1037, -1037,   459,  7977,   459,   459, -1037, -1037,   459,
     309,   485,  1551,   339,   977,   539,   512,  1451,   629,  1844,
     459,  6514,   319,   485, -1037,  2376,   159, -1037, -1037,   217,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037,  6240,  8420,   728,   730,  6240,  6240,  6240,
    6240,  6240,  6240, -1037,   638,   735, -1037,   732,  1298,  3661,
      70, -1037,    51, -1037, -1037,     1,   582,   618,   909,  6776,
    1841,  1841,   747,   754,  1457,   686, -1037, -1037, -1037,   751,
   -1037, -1037, -1037,  3661, -1037, -1037,  6369,   776,  6776,  2710,
     459,   615,   504, -1037, -1037,  2710,   615,   504, -1037,   909,
   -1037, -1037,  8077,  3426, -1037,  8077,  3560,  2710,  1980,  2114,
     909,   615,   504, -1037,   708,  1073, -1037, -1037,   217,   818,
    7775, -1037,   788, -1037, -1037,   791,   703,   459,   459, -1037,
   -1037,   783,   800,   807, -1037, -1037, -1037,   941,   246,   662,
    2890, -1037, -1037, -1037, -1037,   459,   811,   808,   812,   823,
     827, -1037,   832,   831,   834, -1037,  8701, -1037,   459, -1037,
     837,   843, -1037,   845,  8561, -1037, -1037,   664, -1037, -1037,
    8561, -1037,   848, -1037,   741,   268,   849,   382,   793,   790,
     854, -1037, -1037,    16,   857, -1037, -1037, -1037, -1037,   121,
    2762,  2762,  1485,   520,   786,   864,   197,  2710,  2710,   873,
    8077,  2710,  2196,  2248,   803,  1094,  1571,    40,   846,   235,
    6888,  1571, -1037,   875, -1037,   625,   703,   885, -1037,  2344,
     105, -1037,  6635,   835, -1037,   892,   732, -1037, -1037, -1037,
    1949, -1037, -1037, -1037, -1037, -1037, -1037,  2756, -1037,  3694,
    3828,  3962,  4096,  6240,  6240,  4230,  4364,  4498,  4632,  4766,
    4900,  5034,  5168,  5302,  5436,  5570,  5704, -1037,   932,   938,
     939,   947, -1037, -1037, -1037,   416,   416,  6894,   836,   411,
   -1037,   482, -1037, -1037,   416,   416,   623,   839,   392, -1037,
   -1037,  8077,  1693,    15,   615, -1037,  8077,  5838,   615,   915,
   -1037,  9228,   921, -1037,  9260,   615,  2710,   615,   504, -1037,
    2710,   615,   504, -1037,   909,  1293,  2710,   916,  2330,   615,
     909, -1037, -1037,  8077, -1037,  8077,   443,   935, -1037, -1037,
    2302, -1037,   539,   929,  8077,   940,   933, -1037,   654,  2846,
     946,  8077,  1844,   937, -1037, -1037,  1351,  7138,   948, -1037,
    1192,  8561,   949,   955,  8077, -1037,   587,   959,   539,  8077,
     380, -1037, -1037,  7977,   919,  7977, -1037,  8077, -1037,   392,
    1736,  6548,    21, -1037,   964,  2710,  2710,  2062,   971,   406,
     925,   936, -1037, -1037,   521, -1037,   363, -1037, -1037, -1037,
      24,  1974,  9030,   637,   979,   786,   244,   944, -1037, -1037,
   -1037,   952, -1037, -1037, -1037,  6508,  5972,  3024,  3158,  6374,
     350,  6106,   159, -1037, -1037,  1623, -1037,  1623, -1037,  1495,
   -1037,  1495,  1725,  3527, -1037,  3929, -1037,  2882, -1037,  4063,
   -1037,  2999, -1037,  1949, -1037,   777, -1037,   777, -1037,   898,
   -1037,   898, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037,   839,   909, -1037, -1037, -1037,   678,   996,   997,
     392,   999,   666,   839, -1037,  1211,  1000, -1037,  9292,  1571,
   -1037,   363, -1037,   615,   615,  2710,   994,  2628,   615,   504,
     615,  2710,  2710,   615, -1037, -1037, -1037, -1037,   703,  8077,
    7250, -1037, -1037,   268, -1037,   989, -1037,  1003, -1037, -1037,
   -1037, -1037,   703,   995,   281,  1008,   116, -1037,  1571, -1037,
    1009, -1037, -1037,  7362,  8701,   560,  8077, -1037,  1010,   912,
   -1037,   349,   953, -1037,  1017,  1016, -1037, -1037, -1037,  1024,
   -1037,   703, -1037,   966,   459,   862, -1037,  1028, -1037,   392,
    1571,    59,  2710, -1037,  8077,  6240, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037,  9100,  1030, -1037,   973,  1035, -1037, -1037,
    1018,  6819,  2108,  6240,   553, -1037, -1037,  1039, -1037,   924,
    2494,  1041, -1037,  1043,  2991,  6240,  6240,  8701,  6240,  1047,
    1048,  1049,  3125,  1053,  6240, -1037, -1037,  1055,  1058, -1037,
   -1037,   859, -1037, -1037, -1037, -1037,   615,  2710,  2710,   615,
     615,   615,  1059, -1037,  2302,   363,  2494,  2302,   539,  1061,
   -1037,  1571,  1062, -1037, -1037,  1844,   107, -1037,  8561, -1037,
    1063,   363,   125,   159,   493, -1037,  2756,   399, -1037,  8077,
     486,  1052,    20,  8866, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037,  8311, -1037,  7474,  1067, -1037,  1070,  3259,   725, -1037,
   -1037,   442, -1037,  1018, -1037,    50,  1066,   229,  8077,  2890,
    1065,  1042, -1037,  1077,  3661, -1037,  1844, -1037, -1037, -1037,
     944, -1037, -1037, -1037,   459, -1037, -1037, -1037,  1071,  1050,
    1056,  1057,  9149, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037,  1082,  8141,  1006, -1037, -1037, -1037, -1037,
   -1037, -1037, -1037, -1037,  1678, -1037, -1037, -1037, -1037, -1037,
   -1037,  6240,  6240, -1037, -1037, -1037,  3795, -1037, -1037, -1037,
     615,   615, -1037, -1037, -1037,   246,  1087,   703,  1008,  1680,
     380, -1037,  1092, -1037,  1097, -1037, -1037, -1037,   349, -1037,
   -1037,   349,  1037, -1037, -1037,  1100,   252,  8701,  7977,  1844,
    8701,  6546, -1037, -1037,   725, -1037, -1037,   303,  8077, -1037,
     506, -1037,   159,  1018, -1037,  1089,  1783,    -8, -1037,  1102,
    1107,  1108,   740,   459,   649, -1037,  1571, -1037,   129,   944,
   -1037, -1037, -1037, -1037, -1037,  1797,  9232, -1037, -1037,  1081,
    1083,   159,  1084,  1085,   329,  2494, -1037, -1037,  1114, -1037,
   -1037, -1037,  1571, -1037, -1037, -1037, -1037, -1037,  1123,  1124,
   -1037,   246,  1351,  1072,   157,   305,  6888, -1037,   553,  1134,
   -1037, -1037, -1037, -1037, -1037,  6240, -1037,  1571,  1018, -1037,
    1018,   694, -1037,  1133,  1136,  1132,   575, -1037, -1037,   303,
   -1037,   459,  2494, -1037, -1037,  1571,  1152,  6240, -1037,  1147,
   -1037,  1151, -1037, -1037, -1037,  1155, -1037,  2242,  8077,  1161,
    1169,   123,  1175, -1037,  1571,  1174, -1037,  3661,   303, -1037,
   -1037, -1037, -1037, -1037,   459, -1037, -1037, -1037,   553,   129,
    1172,   303,  8077,  3393,  1797, -1037, -1037,  1180,  8077,  8077,
    8077,  1182,  6819,   181, -1037,   553,  1177, -1037, -1037, -1037,
     553,  1185, -1037, -1037,  1571,  1189,  1190,  1194,  8077, -1037,
    8701,   506, -1037, -1037, -1037,  1571, -1037,    33,  1571,  1571,
    1571,  1197,  1195, -1037, -1037, -1037, -1037,  2890, -1037, -1037,
   -1037,  1571,   506,  1196, -1037, -1037, -1037
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
      12,     0,     0,     0,     0,     0,     4,   582,   400,   408,
     401,   402,   405,   406,   403,   404,   388,   407,   387,   409,
     410,   411,   412,   413,   280,   377,   378,   379,   539,   540,
     147,   522,   522,     0,   583,   584,     0,   594,     0,     0,
     281,     0,     0,   375,   292,   382,   392,   386,   397,   398,
     538,     0,   601,   390,   592,     6,     0,     8,   278,     1,
      17,    62,    58,    59,     0,   265,    16,   262,   625,     0,
      78,    79,   625,    74,     0,     0,   264,   266,   267,     0,
     268,     0,   269,   270,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    10,    11,     9,
      13,    20,    21,    22,    23,    24,    25,    26,   625,    27,
      28,    29,    30,    31,    32,     0,    33,    34,    35,    36,
      37,    38,    14,   105,   110,   107,   106,    18,    15,   156,
     157,   158,   159,   160,   161,   113,     0,   258,   260,   149,
     148,   521,   536,   537,   393,     0,   284,   595,   282,   389,
       3,   376,   381,   278,   385,     0,     0,   594,   522,   522,
     369,     0,   295,   279,   292,   304,   292,   349,   522,   330,
     383,   399,   391,   602,     0,     0,   590,     5,     0,   271,
     272,    19,     0,   616,     0,   263,     0,     0,     0,     0,
     380,   601,   545,     0,     0,     0,   278,   278,   236,     0,
       0,     0,   194,   601,     0,     0,    60,    61,     0,    48,
      49,   278,     0,   300,     0,    96,    97,   589,     0,   104,
     278,   129,   128,     0,   182,     0,     0,   136,   127,     0,
     131,     0,     0,     0,     0,     0,   304,     0,   330,     0,
     421,     0,   526,   262,   261,     0,     0,   596,   603,   593,
     620,   451,   452,   469,   470,   471,   472,   473,   474,   475,
     476,   477,   478,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   287,     0,   283,   285,   440,   380,     0,
     448,   458,   439,   447,   459,   390,   449,   450,   384,   278,
     522,   522,     0,     0,   522,   390,   291,   418,   419,   289,
     415,   416,   417,   414,   439,   360,     0,     0,   278,   521,
       0,   306,   351,   353,   322,   521,   305,   350,   352,   368,
     331,   293,   278,     0,   294,   278,     0,   521,   522,   522,
     367,   301,   344,   343,   322,   354,   600,   599,   598,     0,
     278,   274,   273,   586,   585,     0,   587,     0,     0,   615,
     108,   629,     0,   626,    66,    47,    46,     0,   292,   304,
       0,   542,   543,   541,   544,     0,     0,    70,    88,     0,
       0,    90,     0,     0,     0,   189,     0,    12,     0,   192,
       0,     0,    95,     0,     0,    99,   297,   304,   298,    42,
       0,   588,     0,    52,     0,    51,     0,     0,     0,     0,
     181,   183,   188,   538,     0,   130,   171,   133,   132,     0,
       0,     0,     0,   585,     0,     0,     0,     0,     0,     0,
     278,     0,     0,     0,   322,     0,   566,   330,   151,   601,
     278,   566,   524,     0,   523,   391,   263,     0,   394,     0,
       0,   591,     0,   458,   453,     0,     0,   457,   454,   455,
     467,   518,   517,   468,   519,   520,   581,     0,   446,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   445,     0,     0,
       0,     0,   619,   618,   617,   522,   522,   522,   390,     0,
     330,     0,   365,   362,   522,   522,     0,   330,   354,   290,
     361,   278,   522,   390,   315,   323,   278,     0,   314,     0,
     339,     0,     0,   358,     0,   311,   521,   303,   348,   346,
     521,   302,   347,   345,   366,   356,     0,     0,     0,   307,
     355,   597,     7,   278,   275,   278,     0,     0,   173,    12,
       0,   624,     0,     0,   278,     0,     0,    73,     0,     0,
       0,     0,     0,     0,   190,   191,   300,     0,     0,    12,
     259,     0,   100,     0,   278,    98,     0,     0,     0,     0,
       0,   135,   134,   182,   169,     0,   185,   278,    56,     0,
       0,     0,     0,    75,     0,     0,     0,     0,     0,   557,
     548,   549,   374,   373,   562,   372,   370,   558,   563,   565,
       0,     0,     0,     0,     0,   390,   292,   547,   164,   168,
     554,   526,   396,   395,   604,   460,     0,     0,     0,   369,
       0,     0,     0,   286,   514,   496,   513,   495,   509,   491,
     510,   492,   515,     0,   508,   490,   507,   489,   503,   485,
     504,   486,   502,   484,   505,   487,   506,   488,   497,   479,
     498,   480,   499,   481,   500,   482,   501,   483,   444,   442,
     443,   441,     0,   354,   334,   333,   332,   356,     0,     0,
     355,     0,     0,   322,   324,   354,     0,   327,     0,   341,
     340,   363,   359,   313,   312,     0,     0,     0,   308,   357,
     316,     0,     0,   310,   277,   276,    64,    65,    63,   278,
       0,   631,   634,   633,   627,   630,    44,     0,    43,    39,
      72,    69,    71,     0,   633,    88,     0,    91,   566,   235,
       0,   195,   196,     0,     0,     0,   278,    41,     0,     0,
     609,   607,     0,    55,     0,     0,   623,    85,   622,     0,
     102,   621,    84,     0,     0,   259,   184,     0,    12,     0,
     566,     0,     0,   341,   278,     0,   560,   551,   550,   564,
     371,   118,   117,     0,     0,   140,   142,     0,   150,   152,
     425,   566,     0,     0,     0,   125,   546,   525,   527,   529,
       0,     0,   461,     0,     0,     0,     0,   368,     0,     0,
       0,     0,     0,     0,     0,   335,   337,     0,     0,   342,
     325,     0,   329,   328,   296,   364,   317,     0,     0,   309,
     321,   320,     0,   109,     0,   341,     0,     0,     0,     0,
      82,   566,     0,   111,   193,     0,   601,    93,     0,    92,
       0,   341,     0,     0,     0,   605,   284,     0,    50,   278,
       0,     0,   262,     0,   175,   176,   179,   178,   170,   177,
     180,     0,   172,     0,     0,    77,     0,     0,   553,   120,
     141,     0,   119,   422,   424,   432,     0,   426,   278,     0,
     563,   574,   155,     0,   126,   124,     0,   121,   123,   114,
     547,   534,   533,   535,     0,   531,   201,   222,     0,     0,
       0,     0,   259,   247,   248,   241,   249,   220,   216,   245,
     240,   242,   243,   244,   246,   221,   217,   218,   204,   211,
     210,   214,   213,     0,   259,   223,   202,   205,   206,   209,
     215,   207,   208,   219,     0,   162,   511,   493,   464,   463,
     462,     0,     0,   512,   494,   456,   516,   336,   338,   326,
     319,   318,   174,   632,   628,   292,     0,   633,    88,     0,
       0,    89,     0,    67,     0,   101,   299,   610,   608,   614,
     613,   612,     0,    53,    54,     0,   292,     0,   182,     0,
       0,     0,    57,    76,   556,   561,   552,   292,   278,   143,
       0,   423,     0,   425,   434,   436,     0,   425,   428,   427,
       0,     0,     0,     0,     0,   115,   566,   528,   522,   547,
     226,   238,   237,   239,   224,     0,   259,   203,   225,   388,
     387,     0,     0,   386,   390,     0,   466,   465,     0,    40,
      87,    83,   566,    80,    68,    94,   606,   611,     0,     0,
     187,   292,   300,     0,   330,     0,   278,   559,     0,     0,
     145,   144,   139,   435,   433,     0,   153,   566,   425,   429,
     425,     0,   571,     0,   573,   575,     0,   567,   568,   292,
     530,     0,     0,   166,   165,   566,     0,     0,   212,     0,
      45,     0,   103,    86,   186,     0,   169,     0,   278,     0,
       0,     0,     0,   116,   566,     0,   437,   438,   292,   431,
     430,   569,   570,   572,     0,   577,   579,   580,     0,   522,
       0,   292,   278,     0,     0,    81,   112,     0,   278,   278,
     278,     0,   566,     0,   146,     0,   576,   122,   532,   227,
       0,     0,   253,   163,   566,     0,     0,     0,   278,   228,
       0,     0,   154,   578,   167,   566,   234,     0,   566,   566,
     566,     0,     0,   137,   229,   250,   252,     0,   232,   231,
     230,   566,     0,     0,   233,   138,   251
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
   -1037, -1037,  -350, -1037, -1037, -1037, -1037,     8,    26,    35,
      61,  -522, -1037,    69,    74, -1037, -1037, -1037,    75, -1037,
   -1037,    80, -1037, -1037,    81, -1037,    94,  -694,  -686,    96,
   -1037,   102, -1037,  -340, -1037,   -65,   108,   110,   128,   140,
   -1037,   496,  -735,  -947,  -176, -1037, -1037, -1037, -1036,  -760,
   -1037,   -44, -1037, -1037, -1037, -1037, -1037,    42, -1037, -1037,
     139,    55,    66, -1037, -1037,  -563, -1037,   669,   146, -1037,
   -1037, -1037,  -797, -1037,  -858,   332, -1037,   502, -1037,   507,
     170, -1037, -1037, -1037,  -132, -1037, -1037,    34, -1037,  1112,
     451, -1037,  1215,    71,   421, -1037,   799,   -41, -1037,  -549,
      77,  1086,    60,   -20,  -126,   558,  -630,   663,    14,   142,
       6,   177,   -31,   -84, -1037, -1037,   -76,  1209, -1037,  -332,
    -153, -1037, -1037, -1037,   400,   282,  -924, -1037, -1037,   284,
   -1037,   901, -1037,   595,  -137,  -485, -1037,   -27,   653, -1037,
   -1037, -1037,   387, -1037, -1037, -1037,  -208,    13, -1037, -1037,
     272,  -574, -1037, -1037,  -577,   593,   429,   162, -1037, -1037,
     183,   -14,  1002,    64, -1037,    -1,  -168,  -139,  1105, -1037,
    -309,  1096, -1037,   556,   119,  -187, -1037,  -535
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     4,     5,    99,   100,   101,   816,   893,   894,   895,
     896,   393,   394,   897,   898,   748,   108,   109,   899,   111,
     112,   900,   711,   194,   901,   115,   902,   740,   550,   903,
     370,   904,   381,   214,   215,   216,   905,   906,   907,   908,
     539,   123,   879,   774,   225,   124,   766,   861,   980,  1042,
    1085,    39,   603,   125,   126,   127,   128,   909,  1015,   780,
    1064,   910,   911,   745,   848,   399,   400,   401,   912,   133,
     559,   377,   913,   914,   915,   916,  1062,   917,   918,   919,
     920,   135,   921,   922,  1136,   923,  1012,   924,   137,   138,
     292,   179,    40,   180,   274,   275,   276,   775,   163,   385,
     386,   311,   236,   293,   167,   237,   594,   595,    42,    43,
     277,   190,    45,    46,   245,   438,    47,    48,    49,   299,
     343,   301,   302,   428,   864,   865,   866,   867,   983,   984,
    1086,   303,   280,   281,   304,   283,   284,   333,   433,   434,
     607,   777,   778,   884,   999,   885,    50,    51,   364,   365,
     779,   597,   977,   611,   598,   599,  1137,   872,   994,  1054,
    1055,   173,    52,   351,   392,   285,   176,    54,   249,   732,
     835,   286,   287,   742,   187,   352,   353,   704
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      53,    53,   300,   162,   142,   143,   248,   720,   347,   282,
     743,   152,   227,   102,   715,   756,   403,   759,   701,   946,
     228,   382,   820,   147,   166,   212,   183,   557,   545,   819,
    1038,   103,   312,   317,  1004,   336,   248,    53,   149,   136,
     104,    53,   332,   169,   563,   415,   307,   129,   480,    57,
     172,   805,   226,     7,    69,   702,   674,    53,  -292,   170,
     130,     7,   674,  1049,   702,   349,   105,   761,    53,   762,
     155,   131,    41,    56,   106,   189,  1145,  1131,  1146,   107,
     110,   441,   360,   201,   204,   113,   114,  1147,    58,    53,
      53,    59,   240,  -288,   601,   230,   213,   213,   145,   116,
     227,   117,   855,   202,   165,   340,  1152,   118,   228,   229,
     477,   481,  1098,   119,   238,   120,  1048,   478,  -292,     7,
     736,   164,   183,   321,  1089,   324,  1090,   349,     7,   146,
     675,   313,   318,   121,   763,    53,   752,   184,    34,    35,
     226,  1115,   241,   147,   146,   122,    34,    35,  1004,   242,
     953,   132,   295,  -288,  1120,   425,   357,   314,   314,   737,
     320,   738,     7,  1110,   312,   317,   288,   334,   332,   378,
     531,   144,    36,   982,   319,   134,    37,   141,    44,    44,
     479,   578,     7,   230,   151,   945,   341,   342,   238,   700,
       7,   192,   235,   388,   870,    53,    53,   348,   373,   374,
       7,   956,   518,   522,    34,    35,   146,   300,   146,   723,
      53,  1077,   169,    34,    35,    44,   146,   273,  1069,    53,
     206,   725,   397,    53,   404,   405,   979,   231,   406,   739,
      36,   414,   314,   314,   157,    44,   424,   162,   427,   149,
     238,   435,   233,   957,   349,   234,   345,    34,    35,   359,
     160,   354,  1111,   150,   161,     7,  1023,   330,   166,   368,
     177,   207,  1020,   313,   318,  1100,   358,    34,    35,   767,
     446,   987,   425,   387,   349,    34,    35,   169,  -420,   944,
    -420,   391,   948,   350,   976,    34,    35,   349,   488,   490,
     490,  1130,   943,   497,   355,   402,   246,   247,   772,   419,
     155,   519,   523,  1083,   246,   337,   155,   503,   314,   505,
    -420,    36,   151,   569,   314,    37,   426,   543,   431,   773,
     282,    53,     7,   278,    53,   565,   314,   314,   314,   702,
      44,   160,   702,   174,   314,  -587,   146,   356,   165,    53,
      34,    35,     7,   181,   524,  1078,   537,   538,   182,   530,
     489,   491,   988,   989,   496,   164,   414,   155,   175,   312,
     317,   332,   576,  1117,   546,   403,    36,   403,   518,   522,
      37,  1143,  1068,    44,    44,    53,   332,   558,   773,   416,
    1132,   734,   556,    53,   736,  1134,   183,   417,    44,    53,
     213,   788,  1155,   186,   432,     7,   213,    44,   853,   689,
    1037,    44,   193,   963,  -257,  1033,   195,    34,    35,   490,
     490,   490,    25,    26,    27,   582,   314,   314,     7,    53,
     314,   314,   314,   737,   314,   738,   614,    34,    35,   605,
     151,  1079,   153,    36,  1080,   407,   139,    37,   408,   160,
     596,    25,    26,    27,   964,   596,   755,   696,   300,   183,
     156,   420,   664,    36,   140,   308,   289,    37,   313,   318,
     196,   151,     7,   309,   141,   833,    44,   519,   523,   323,
     489,   491,   496,   156,   156,   197,   789,   310,   669,   790,
      34,    35,   978,  1075,   330,    44,   662,   979,   697,   592,
     834,   183,   593,   739,   590,   591,     7,   169,   322,    44,
      53,   673,    44,    34,    35,    53,    36,   198,   571,   178,
     157,   572,   670,   361,   362,   314,   323,    44,   158,   314,
     205,   159,   420,   665,   314,   314,   160,   314,   273,    36,
     161,   363,    53,    37,    53,   870,   388,   991,    28,    29,
     323,   689,     7,    53,   325,   183,  1040,    34,    35,  1041,
      53,   238,   420,   310,   875,   169,    31,    32,   375,   669,
      53,   335,   326,    53,   736,   102,   183,   213,    53,   376,
     323,   768,    53,    36,    53,   668,    53,    37,   169,   238,
     314,    34,    35,   103,   314,   314,   314,   858,   349,   482,
       7,   136,   104,   749,   724,   876,   877,    44,   878,   129,
     588,    53,   168,   827,   208,   738,   705,    44,   589,   590,
     591,   960,   130,   713,   828,  1096,   387,   217,   105,   300,
    1097,   146,   717,   131,   483,   484,   106,    34,    35,   718,
     218,   107,   110,   787,   278,  -601,  -601,   113,   114,   209,
     735,   183,   297,   298,   402,   220,   402,   371,   372,  1026,
     798,   116,  1027,   117,   339,   506,   668,   750,   710,   118,
     183,  -601,   383,   420,   666,   119,   151,   120,   609,   169,
    -555,   396,   151,   507,   314,    34,    35,   530,    44,   227,
     769,   323,   770,    44,   314,   121,   314,   228,   154,   530,
     314,   314,  1057,   596,  1058,   596,   379,   122,    53,   282,
    -555,   729,   544,   132,   564,   730,   506,   800,   102,   349,
      44,   294,    44,   384,   610,   238,   300,   389,   289,   226,
     323,    44,   323,    53,   507,    53,   103,   134,    44,   798,
     825,   102,   596,   390,   136,   104,   156,  1091,   151,  1092,
     456,    44,   129,   841,   425,   767,    44,   797,   169,   103,
      44,   314,    44,    53,    44,   130,   152,   136,   104,   227,
     403,   105,   230,   954,   596,   129,   131,   228,   448,   106,
     449,   168,   458,   509,   107,   110,   512,   457,   130,   851,
     113,   114,   567,   568,   105,   596,    53,   845,   492,   131,
     412,   534,   106,   821,   116,   493,   117,   107,   110,   226,
     846,   498,   118,   113,   114,   863,   314,   314,   119,   499,
     120,   847,   151,   590,   591,  1153,   501,   116,   532,   117,
       1,     2,     3,   525,   238,   118,   797,    53,   121,   596,
     535,   119,   536,   120,   213,   596,   168,   540,    53,  1053,
     122,   541,   230,   297,   298,   596,   132,   487,  1013,   542,
      53,   121,   547,   966,   549,   600,   229,   971,   443,   447,
     606,   102,   548,   122,   242,   551,   502,    53,   552,   132,
     134,   584,  1066,   553,   554,   238,    44,   555,   560,   103,
     240,   604,   713,   998,   561,    65,   562,   136,   104,   566,
     570,   151,   574,   134,   573,   129,   575,   577,   863,   506,
     939,   579,   952,    44,  1018,   580,   842,   273,   130,   472,
     473,   474,   475,   476,   105,   412,   583,   507,   587,   131,
     608,   602,   106,  1014,   300,  1030,   612,   107,   110,   151,
     971,    44,   622,   113,   114,   658,   621,   242,    76,    77,
      78,   659,   660,    80,     7,    82,    83,   116,   238,   117,
     661,   663,   671,   996,   667,   118,   679,   676,    25,    26,
      27,   119,   681,   120,   691,  1031,    53,    53,  1034,    53,
     238,  1060,   706,  1032,   581,   699,  1035,    53,   709,   843,
       7,   121,   719,   708,   694,   238,   695,   716,   412,   726,
    1074,   722,  1056,   122,   300,   707,   881,   882,   883,   132,
     620,   727,   733,  1144,   238,   753,  1148,  1149,  1150,   744,
     596,   754,   388,   278,   757,   728,    44,   416,   863,  1154,
     771,   776,   863,   134,   758,   418,  1022,   432,   747,    34,
      35,   169,   474,   475,   476,   605,   596,   795,   796,   402,
     799,   802,   807,   814,   815,    44,   426,   279,   431,   817,
     818,   831,   823,   832,   836,    36,   168,   306,   837,    37,
    1099,   596,   838,  1047,   839,    34,    35,   410,   840,   852,
     411,   191,  1118,   859,   860,   160,     7,    53,   862,   596,
      69,   880,  1065,   863,   926,   863,   925,   203,   931,   932,
     933,    36,   387,  1056,   935,    37,   937,     7,   596,   938,
     942,    53,   949,   238,   955,   951,   967,    53,    53,    53,
     973,   974,   986,   416,   168,   310,  1000,   993,     7,   992,
     995,   526,    25,    26,    27,  1001,   596,    53,  1005,    53,
    1008,  1002,  1003,  1019,   416,  1024,  1142,   168,   596,  1028,
    1025,  1029,   526,  1045,  1050,    44,   439,   822,  1051,   596,
     812,  1052,   596,   596,   596,    44,  -256,  1070,  -255,  1067,
    -254,    34,    35,   185,   442,   596,  1072,  1073,   450,   451,
     452,   453,   454,   455,  1076,  1084,  1093,   830,  1094,   854,
    1095,  1065,    34,    35,   344,   210,   199,    36,   344,   344,
     219,    37,  1102,  1104,  1105,   366,   367,   344,  1106,   527,
     871,  1108,   528,    34,    35,   856,   200,   380,    36,  1109,
     344,   310,    37,    44,     7,    65,  1112,  1114,  1119,   344,
     527,  1124,  1128,   528,   511,  1133,  1135,   514,   168,    36,
    1138,  1139,   310,    37,   413,  1140,   243,   344,  1151,  1156,
     979,   844,   429,  1123,   746,   316,  1007,   849,   440,   244,
     950,   416,   850,   148,   331,    44,   623,   962,   171,   760,
      25,    26,    27,   981,   781,  1044,  1043,   997,    76,    77,
      78,  1061,   804,    80,  1129,    82,    83,  1116,   346,    44,
     338,   829,   346,   346,     0,    44,    44,    44,     0,     0,
     965,   346,     0,     0,     0,     0,     7,     0,     0,    34,
      35,     7,     0,     0,   346,    44,     0,   168,     0,     0,
       0,     0,     0,   346,   395,     0,     0,     0,     0,   990,
     316,     0,     0,   331,     0,    36,     0,   409,   346,    37,
       0,   346,     0,   308,     0,     0,     0,     0,   153,   436,
    -292,   685,     0,     0,     0,     0,   154,     0,     7,   310,
       0,   156,   155,     0,     7,     0,   156,     0,   279,     0,
     625,   627,   629,   631,   632,   633,   635,   637,   639,   641,
     643,   645,   647,   649,   651,   653,   655,   657,     0,     0,
       0,    34,    35,     0,     0,   153,    34,    35,     0,     0,
       0,   153,     0,   154,     0,   504,     0,     0,     0,   155,
    -292,   508,     0,   156,     0,     0,     0,    36,   678,   156,
       0,    37,    36,   515,   517,   521,   157,     0,     0,   686,
       0,   529,   687,     0,   158,  1059,     0,   159,     0,  1039,
       0,   310,   160,    34,    35,     0,   161,     0,     0,    34,
      35,     7,     0,     0,     0,     0,     0,     7,     0,     0,
       0,  1071,     0,     0,     7,     0,     0,     0,     0,    36,
       7,     0,     0,   157,     0,    36,     0,     0,     0,   157,
       0,   158,     0,     0,   159,     0,  1088,   158,   308,   160,
     159,     0,     0,   161,   308,   160,   327,  1082,     7,   161,
       0,   416,   315,     0,  1101,     0,   156,   153,     0,   421,
       0,     0,   156,   504,   508,   141,     0,   515,   517,   521,
       0,   529,     0,  1113,     0,   156,   782,   784,   637,   643,
     653,     0,   792,     0,     0,   357,    34,    35,     0,  1107,
       0,     0,    34,    35,     0,     0,     0,     0,     0,    34,
      35,   871,     0,     0,   344,    34,    35,     0,     0,     0,
       0,   344,    36,  1121,     7,     0,    37,   183,    36,  1125,
    1126,  1127,    37,     0,   328,    36,     0,   329,   731,    37,
     344,    36,   330,    34,    35,   157,   310,   422,     0,  1141,
     423,     0,   310,   494,     0,   330,   495,     0,   672,   310,
     168,   330,     0,  1081,   412,   161,     0,     0,     0,    36,
     459,   460,   683,   157,   463,     0,   684,     0,     0,     0,
       0,   688,   690,     0,   693,     0,     0,     0,     0,   330,
      25,    26,    27,   161,   793,   470,   471,   472,   473,   474,
     475,   476,   698,     0,     0,     0,   703,     0,   346,    34,
      35,     0,     0,     0,   712,   714,     0,     0,     0,     0,
     588,     0,     0,     0,   297,   298,   857,     0,   589,   590,
     591,     0,     0,     0,   346,    36,   741,   672,     0,    37,
       0,   683,   684,   688,   874,     0,   751,   410,     0,     0,
     411,     7,     0,     7,     0,   160,   928,   929,     0,   930,
       0,     0,     0,     0,     0,   936,     7,   592,     0,     0,
     593,     0,     8,     9,    10,    11,    12,    13,    14,    15,
    1009,    17,  1010,    19,    20,    21,    22,    23,     0,     0,
     357,     0,     0,  1021,     0,     0,   826,    25,    26,    27,
      28,    29,   463,   308,     0,     0,     0,   279,     0,     7,
       0,   141,   183,     0,     0,     0,     0,    30,    31,    32,
       0,   156,     0,   470,   471,   472,   473,   474,   475,   476,
       0,   801,     0,    33,   239,     0,    34,    35,    34,    35,
       0,   806,     0,   809,     0,     0,   357,   810,   811,     0,
       0,    34,    35,     0,     0,     0,     7,     0,     0,     0,
       0,     0,    36,     7,    36,     0,    37,   970,   157,     0,
       7,     0,     0,     0,     0,     0,   233,    36,     0,   234,
       0,    37,   741,     0,   160,     0,  1011,     0,   161,   494,
     344,   741,   495,   357,    34,    35,  1046,   330,     0,     0,
     232,   310,  1016,  1017,   958,   959,   961,   357,   801,     0,
    1063,     0,     0,     0,     7,     0,     0,     7,     0,     0,
      36,     0,     0,     0,   157,   470,   471,   472,   473,   474,
     475,   476,   233,     0,     0,   234,     0,   985,     0,     0,
     160,    34,    35,     0,   161,     0,     0,     0,    34,    35,
       0,   153,     0,     0,   357,    34,    35,     0,     0,   141,
       0,     0,     0,   940,   941,     0,     0,    36,     0,   156,
       0,   157,     0,     0,    36,     0,     0,     0,   157,   233,
     703,    36,   234,   947,   346,   157,   233,   160,     0,   234,
       0,   161,     0,   233,   160,     0,   234,     0,   161,    34,
      35,   160,    34,    35,     0,   161,     0,     0,   436,     0,
       0,     0,     0,     0,     0,     0,  1087,     0,     0,     0,
       0,     0,     0,     0,     0,    36,     0,     0,    36,   157,
       0,     0,   157,     0,     0,     0,     0,     0,  1103,     0,
     233,     0,     0,   234,     0,   764,     0,     7,   160,   161,
     183,   250,   161,     7,   985,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
     308,     0,     0,    25,    26,    27,    28,    29,   516,   264,
     265,     0,   765,     0,     0,     0,     0,     0,   156,     0,
       0,     0,     0,    30,    31,    32,   741,     0,     0,     0,
       0,     0,     0,     0,   459,   460,   461,   462,   463,    33,
       0,   266,    34,    35,     0,     7,     0,     0,    34,    35,
       0,     0,     0,     0,     0,     0,     0,   297,   298,   470,
     471,   472,   473,   474,   475,   476,     0,     0,    36,     0,
       0,     0,    37,     0,    36,     0,     0,     0,    37,     0,
       0,     0,   416,   267,     0,     0,   268,   269,   270,   873,
     685,     7,   271,   272,   183,   250,     0,     7,   310,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     0,
      34,    35,     0,   296,   308,     0,     0,    25,    26,    27,
      28,    29,   520,   264,   265,     0,     0,     0,     0,     0,
       0,     0,   156,     0,     0,     0,    36,    30,    31,    32,
      37,     0,     0,     0,     0,     0,     0,     0,   686,     0,
       0,   687,     0,    33,     0,   266,    34,    35,     0,     7,
     310,     0,    34,    35,     0,     0,     0,     0,     0,     0,
       0,   297,   298,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,    36,     0,
       0,     0,    37,     0,     0,     0,   416,   267,     0,     0,
     268,   269,   270,   764,   585,     7,   271,   272,   183,   250,
       0,     7,   310,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,    34,    35,     0,     0,   416,     0,
       0,    25,    26,    27,    28,    29,   586,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   183,     0,
      36,    30,    31,    32,    37,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     0,    33,     0,   266,
      34,    35,     0,     7,   310,     0,    34,    35,     0,     0,
       0,     0,     0,     0,     0,   297,   298,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,    36,     0,     0,     0,    37,     0,     0,     0,
     416,   267,     0,     0,   268,   269,   270,   437,   692,     7,
     271,   272,   183,   250,     0,   613,   310,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,    34,    35,
       0,     0,     0,     0,     0,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,    30,    31,    32,    37,   459,
     460,   461,   462,   463,     0,   464,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,   310,   465,
     466,   467,   468,   469,   470,   471,   472,   473,   474,   475,
     476,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,   886,     0,  -259,    61,     0,
       0,     0,    62,    63,    64,   267,     0,     0,   268,   269,
     270,     0,     0,     0,   271,   272,     0,    65,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,     0,     0,     0,   887,    67,     0,
    -199,     0,     0,  -259,  -259,  -259,  -259,  -259,     0,     0,
       0,     0,     0,     0,     0,     0,    69,    70,    71,   888,
      73,    74,    75,  -259,  -259,  -259,   889,   890,   891,     0,
      76,    77,    78,     0,    79,    80,    81,    82,    83,  -259,
    -259,     0,  -259,  -259,    84,     0,     0,     0,    88,    89,
      90,    91,    92,    93,    94,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    95,     0,  -259,     0,
       0,    96,  -259,  -259,     0,     0,     0,   892,     0,     0,
       0,     0,     0,     0,     0,     7,     0,     0,   183,   250,
       0,     7,  -259,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,   296,   416,     0,
       0,    25,    26,    27,    28,    29,   808,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     7,     0,     0,    34,    35,     0,     0,
       0,     0,     0,     0,     0,   297,   298,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,    36,     0,     0,     0,    37,     0,     0,     0,
     416,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     7,   310,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,    34,    35,
       0,     0,   357,     0,    24,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,    30,    31,    32,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,   310,     7,
      34,    35,   183,     0,     0,     0,     0,     0,     0,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
      36,     0,     0,     0,    37,     0,    36,     0,     0,    38,
     157,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
     161,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,     0,     0,    34,    35,     0,     0,     0,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,   297,
     298,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,     0,     0,     0,     0,     0,   459,   460,   461,
     462,   463,     0,   297,   298,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,   467,
     468,   469,   470,   471,   472,   473,   474,   475,   476,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,   927,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,   785,     0,     0,     0,     0,
       0,     0,   636,    25,    26,    27,    28,    29,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,   459,   460,   461,   462,
     463,     0,   464,     0,   459,   460,   461,   462,   463,    33,
       0,   266,    34,    35,     0,     0,   465,   466,   467,   468,
     469,   470,   471,   472,   473,   474,   475,   476,   469,   470,
     471,   472,   473,   474,   475,   476,     0,     0,    36,     0,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   267,     0,     0,   268,   269,   270,     0,
       0,     7,   271,   272,   183,   250,   934,     0,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,   786,
       0,     0,     0,     0,     0,     0,   642,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
     459,   460,   461,   462,   463,     0,   464,     0,     0,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
     465,   466,   467,   468,   469,   470,   471,   472,   473,   474,
     475,   476,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   267,     0,     0,
     268,   269,   270,     0,     0,     7,   271,   272,   183,   250,
     975,     0,     0,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,     0,     0,     0,
       0,    25,    26,    27,    28,    29,     0,   264,   265,     0,
       0,   305,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,   459,   460,   461,   462,   463,     0,
     464,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     0,   465,   466,   467,   468,   469,   470,
     471,   472,   473,   474,   475,   476,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     0,  1122,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,     0,     0,
       0,     0,     0,     0,     0,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,   510,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,   459,   460,
     461,   462,   463,     0,   464,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,   465,   466,
     467,   468,   469,   470,   471,   472,   473,   474,   475,   476,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
       0,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,   794,     0,     0,     0,     0,     0,     0,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,   513,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,   459,   460,   461,   462,   463,     0,   464,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,   465,   466,   467,   468,   469,   470,   471,   472,
     473,   474,   475,   476,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,     0,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
       0,     0,   624,    25,    26,    27,    28,    29,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,   459,   460,   461,   462,
     463,     0,   464,     0,     0,     0,     0,     0,     0,    33,
       0,   266,    34,    35,     0,     0,   465,   466,   467,   468,
     469,   470,   471,   472,   473,   474,   475,   476,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    36,     0,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   267,     0,     0,   268,   269,   270,     0,
       0,     7,   271,   272,   183,   250,     0,     0,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     0,
       0,     0,     0,     0,     0,     0,   626,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
     459,   460,   461,   462,   463,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
     465,   466,   467,   468,   469,   470,   471,   472,   473,   474,
     475,   476,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   267,     0,     0,
     268,   269,   270,     0,     0,     7,   271,   272,   183,   250,
       0,     0,     0,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,     0,     0,     0,
     628,    25,    26,    27,    28,    29,     0,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,   459,   460,   461,   462,   463,     0,
       0,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     0,     0,   466,   467,   468,   469,   470,
     471,   472,   473,   474,   475,   476,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     0,     0,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,     0,     0,
       0,     0,     0,     0,   630,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,   459,   460,
     461,   462,   463,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,     0,     0,
       0,   468,   469,   470,   471,   472,   473,   474,   475,   476,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
       0,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,     0,     0,     0,     0,     0,     0,   634,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       8,     9,    10,    11,    12,    13,    14,    15,     0,    17,
       0,    19,    20,    21,    22,    23,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,     0,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
       0,     0,   636,    25,    26,    27,    28,    29,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
       0,   266,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    36,     0,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   267,     0,     0,   268,   269,   270,     0,
       0,     7,   271,   272,   183,   250,     0,     0,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     0,
       0,     0,     0,     0,     0,     0,   638,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   267,     0,     0,
     268,   269,   270,     0,     0,     7,   271,   272,   183,   250,
       0,     0,     0,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,     0,     0,     0,
     640,    25,    26,    27,    28,    29,     0,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     0,     0,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,     0,     0,
       0,     0,     0,     0,   642,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
       0,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,     0,     0,     0,     0,     0,     0,   644,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,     0,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
       0,     0,   646,    25,    26,    27,    28,    29,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
       0,   266,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    36,     0,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   267,     0,     0,   268,   269,   270,     0,
       0,     7,   271,   272,   183,   250,     0,     0,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     0,
       0,     0,     0,     0,     0,     0,   648,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   267,     0,     0,
     268,   269,   270,     0,     0,     7,   271,   272,   183,   250,
       0,     0,     0,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,     0,     0,     0,
     650,    25,    26,    27,    28,    29,     0,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     0,     0,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,     0,     0,
       0,     0,     0,     0,   652,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
       0,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,     0,     0,     0,     0,     0,     0,   654,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,     0,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
       0,     0,   656,    25,    26,    27,    28,    29,     0,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
       0,   266,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    36,     0,
       0,     0,    37,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   267,     0,     0,   268,   269,   270,     0,
       0,     7,   271,   272,   183,   250,     0,     0,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     0,
       0,     0,     0,     0,     0,     0,     0,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,   677,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   267,     0,     0,
     268,   269,   270,     0,     0,     7,   271,   272,   183,   250,
       0,     0,     0,   251,   252,   253,   254,   255,   256,   257,
     258,   259,   260,   261,   262,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,   263,     0,     0,     0,     0,     0,     0,     0,
     783,    25,    26,    27,    28,    29,     0,   264,   265,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    30,    31,    32,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    33,     0,   266,
      34,    35,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,     0,     0,
      37,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   267,     0,     0,   268,   269,   270,     0,     0,     7,
     271,   272,   183,   250,     0,     0,     0,   251,   252,   253,
     254,   255,   256,   257,   258,   259,   260,   261,   262,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   263,     0,     0,     0,
       0,     0,     0,     0,   791,    25,    26,    27,    28,    29,
       0,   264,   265,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,   266,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   267,     0,     0,   268,   269,
     270,     0,     0,     7,   271,   272,   183,   250,     0,     0,
       0,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     263,     0,     0,     0,     0,     0,     0,     0,     0,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    36,     0,     0,     0,    37,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   267,
       0,     0,   268,   269,   270,     0,     0,     7,   271,   272,
     183,   250,     0,     0,     0,   251,   252,   253,   254,   255,
     256,   257,   258,   259,   260,   261,   262,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   263,     0,     0,     0,     0,     0,
       0,     0,   652,    25,    26,    27,    28,    29,   500,   264,
     265,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    33,
       0,   266,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   459,   460,   461,   462,   463,     0,
     464,     0,     0,     0,     0,     0,     0,     0,    36,     0,
       0,     0,    37,     0,   465,   466,   467,   468,   469,   470,
     471,   472,   473,   474,   475,   476,   268,   269,     0,     0,
       0,     7,   271,   272,   183,   250,     0,     7,     0,   251,
     252,   253,   254,   255,   256,   257,   258,   259,   260,   261,
     262,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,   263,     7,
       0,     7,     0,     0,   430,     0,     0,    25,    26,    27,
      28,    29,     0,   264,   265,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,  1036,     0,   416,     0,
       0,     0,     0,    33,     0,   266,    34,    35,     0,     0,
       0,     0,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,    36,     0,
       0,     0,   157,     0,    34,    35,    34,    35,     0,     0,
     233,     0,     0,   234,     0,     0,   271,   272,   160,     0,
       0,     0,   161,     0,     0,     0,     0,     0,     0,     0,
      36,     0,    36,     0,   157,     0,    37,     7,     0,     0,
       0,     0,   233,     0,     0,   234,   615,     0,     0,     0,
     160,     0,   330,     0,   161,     0,   310,     0,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,   289,     0,     0,     0,     0,     0,
       0,     0,    24,    25,    26,    27,    28,    29,     0,     0,
       0,     0,   156,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    30,    31,    32,     0,   616,     0,     0,
     459,   460,   461,   462,   463,     0,   464,     0,     0,    33,
       0,     0,    34,    35,     0,     0,     0,     0,     0,     0,
     465,   617,   467,   468,   618,   470,   471,   472,   473,   619,
     475,   476,     0,     0,     0,     0,     0,     0,    36,     7,
       0,     0,    37,     0,     0,     0,     0,    38,     0,     0,
     290,     0,     0,   291,     0,     0,     0,     0,   160,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,   289,     0,     0,     0,
       0,     0,     0,     0,    24,    25,    26,    27,    28,    29,
       0,     0,     0,     0,   156,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   868,
       0,    33,     0,     0,    34,    35,     0,     0,    25,    26,
      27,     0,     0,   869,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     7,     0,     0,    37,     0,     0,     7,   588,    38,
       0,     0,   485,     0,     0,   486,   589,   590,   591,     0,
     160,     0,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,     0,     0,
       0,     0,     0,     0,   289,     0,    24,    25,    26,    27,
      28,    29,   141,     0,     0,   592,     0,     0,   593,     0,
       0,     0,   156,     0,     0,     0,     0,    30,    31,    32,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    33,     0,     0,    34,    35,     0,     0,
       0,     0,    34,    35,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    36,     0,     0,     0,    37,     0,    36,     0,
       0,    38,    37,     0,   410,     0,     0,   411,     0,     0,
     494,     0,   160,   495,     0,     0,    -2,    60,   330,  -259,
      61,     0,     0,     0,    62,    63,    64,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    65,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,     0,     0,     0,    66,
      67,     0,     0,     0,     0,  -259,  -259,  -259,  -259,  -259,
       0,     0,     0,    68,     0,     0,     0,     0,    69,    70,
      71,    72,    73,    74,    75,  -259,  -259,  -259,     0,     0,
       0,     0,    76,    77,    78,     0,    79,    80,    81,    82,
      83,  -259,  -259,     0,  -259,  -259,    84,    85,    86,    87,
      88,    89,    90,    91,    92,    93,    94,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    95,    60,
    -259,  -259,    61,    96,  -259,     0,    62,    63,    64,    97,
      98,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    65,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,     0,     0,
       0,    66,    67,     0,   721,     0,     0,  -259,  -259,  -259,
    -259,  -259,     0,     0,     0,    68,     0,     0,     0,     0,
      69,    70,    71,    72,    73,    74,    75,  -259,  -259,  -259,
       0,     0,     0,     0,    76,    77,    78,     0,    79,    80,
      81,    82,    83,  -259,  -259,     0,  -259,  -259,    84,    85,
      86,    87,    88,    89,    90,    91,    92,    93,    94,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      95,    60,  -259,  -259,    61,    96,  -259,     0,    62,    63,
      64,    97,    98,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    65,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
       0,     0,     0,    66,    67,     0,   813,     0,     0,  -259,
    -259,  -259,  -259,  -259,     0,     0,     0,    68,     0,     0,
       0,     0,    69,    70,    71,    72,    73,    74,    75,  -259,
    -259,  -259,     0,     0,     0,     0,    76,    77,    78,     0,
      79,    80,    81,    82,    83,  -259,  -259,     0,  -259,  -259,
      84,    85,    86,    87,    88,    89,    90,    91,    92,    93,
      94,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    95,    60,  -259,  -259,    61,    96,  -259,     0,
      62,    63,    64,    97,    98,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    65,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,     0,     0,     0,    66,    67,     0,   824,     0,
       0,  -259,  -259,  -259,  -259,  -259,     0,     0,     0,    68,
       0,     0,     0,     0,    69,    70,    71,    72,    73,    74,
      75,  -259,  -259,  -259,     0,     0,     0,     0,    76,    77,
      78,     0,    79,    80,    81,    82,    83,  -259,  -259,     0,
    -259,  -259,    84,    85,    86,    87,    88,    89,    90,    91,
      92,    93,    94,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    95,    60,  -259,  -259,    61,    96,
    -259,     0,    62,    63,    64,    97,    98,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    65,  -259,  -259,
    -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,  -259,
    -259,  -259,  -259,  -259,     0,     0,     0,    66,    67,     0,
       0,     0,     0,  -259,  -259,  -259,  -259,  -259,     0,     0,
       0,    68,     0,     0,     0,   972,    69,    70,    71,    72,
      73,    74,    75,  -259,  -259,  -259,     0,     0,     0,     0,
      76,    77,    78,     0,    79,    80,    81,    82,    83,  -259,
    -259,     0,  -259,  -259,    84,    85,    86,    87,    88,    89,
      90,    91,    92,    93,    94,     0,     6,     0,     7,     0,
       0,     0,     0,     0,     0,     0,    95,     0,  -259,     0,
       0,    96,  -259,     0,     0,     0,     0,    97,    98,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,     0,
       0,     0,     0,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,     0,    34,    35,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    55,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    36,
       0,     0,     0,    37,     0,     0,     0,     0,    38,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,     0,
       0,     0,     0,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,     0,    34,    35,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    36,
       0,     0,     0,    37,     0,     0,     0,     0,    38,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,     0,     0,     0,     0,     0,
       0,     0,     0,    24,    25,    26,    27,    28,    29,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    30,    31,    32,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      33,     0,     0,    34,    35,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,    36,
     369,     0,     0,    37,     0,     0,     0,     0,    38,   533,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    24,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,     0,    34,    35,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    36,     0,     0,     0,    37,     0,     0,     0,     0,
      38,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    24,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    30,    31,    32,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,     0,    34,    35,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    36,     0,     0,   398,    37,     0,     0,     0,     0,
      38,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,     0,     0,     0,
       0,     0,     0,     0,     0,    24,    25,    26,    27,    28,
      29,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    61,    30,    31,    32,    62,
      63,    64,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    33,     0,    65,    34,    35,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   887,    67,     0,  -197,     0,     0,
       0,    36,     0,     0,     0,    37,     0,     0,     0,     0,
      38,     0,     0,    69,    70,    71,   888,    73,    74,    75,
       0,     0,     0,   889,   890,   891,     0,    76,    77,    78,
       0,    79,    80,    81,    82,    83,     0,     0,     0,     0,
       0,    84,     0,     0,     0,    88,    89,    90,    91,    92,
      93,    94,   188,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,    95,     0,     0,     0,     0,    96,     0,
       0,     0,     0,     0,  1006,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,     0,    36,     0,     0,     0,    37,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,   969,     0,    34,
      35,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     7,     0,    36,   183,   250,     0,    37,
     970,   251,   252,   253,   254,   255,   256,   257,   258,   259,
     260,   261,   262,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
     444,     0,     0,     0,     0,     0,     0,     0,   445,    25,
      26,    27,    28,    29,     0,   264,   265,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,   266,    34,    35,
       0,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,    36,     0,     0,     0,    37,    24,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,   211,     0,     0,     0,    36,     0,     0,     0,    37,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,     0,    36,     0,     0,     0,    37,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,   239,     0,    34,
      35,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,     0,     0,     0,     0,    36,     0,     0,     0,    37,
      25,    26,    27,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     7,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     0,     8,     9,    10,    11,    12,
      13,    14,    15,   221,    17,   222,    19,    20,    21,    22,
      23,     0,     0,     0,     0,    36,     0,     0,     0,    37,
     223,     0,     0,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     0,     0,     0,     0,     0,     7,
       0,     0,   224,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    36,     0,     0,     0,    37,
       8,     9,    10,    11,    12,    13,    14,    15,   221,    17,
     222,    19,    20,    21,    22,    23,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   223,     0,     0,    28,    29,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    30,    31,    32,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    33,     0,     0,    34,    35,     0,     0,     0,     0,
       0,     0,     0,     0,     7,     0,     0,   968,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      36,     0,     0,     0,    37,     8,     9,    10,    11,    12,
      13,    14,    15,   221,    17,   222,    19,    20,    21,    22,
      23,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     223,     0,     0,    28,    29,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      30,    31,    32,     7,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    33,     0,     0,    34,
      35,     0,     0,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
       0,     0,     0,     0,     0,    36,     0,     0,     0,    37,
       0,     0,    28,    29,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
      31,    32,     0,     7,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,     0,    34,    35,
       0,     0,     0,     0,     8,     9,    10,    11,    12,    13,
      14,    15,   221,    17,   222,    19,    20,    21,    22,    23,
       0,     0,     0,     0,    36,     0,     0,     0,    37,   223,
       0,     0,     0,    61,     0,     0,     0,    62,    63,    64,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    30,
       0,     0,    65,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    33,     0,     0,    34,    35,
       0,     0,   887,    67,     0,  -200,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    69,    70,    71,    36,    73,    74,    75,    37,     0,
       0,   889,   890,   891,     0,    76,    77,    78,     0,    79,
      80,    81,    82,    83,     0,     0,    61,     0,     0,    84,
      62,    63,    64,    88,    89,    90,    91,    92,    93,    94,
       0,     0,     0,     0,     0,    65,     0,     0,     0,     0,
       0,    95,     0,     0,     0,     0,    96,     0,     0,     0,
       0,     0,     0,     0,     0,   887,    67,     0,  -198,     0,
       0,     0,     0,     0,     0,     0,     0,   680,     0,     0,
       0,     0,     0,     0,    69,    70,    71,     0,    73,    74,
      75,     0,     0,     0,   889,   890,   891,     0,    76,    77,
      78,     0,    79,    80,    81,    82,    83,     0,     0,   682,
       0,     0,    84,     0,     0,     0,    88,    89,    90,    91,
      92,    93,    94,   459,   460,   461,   462,   463,     0,   464,
       0,     0,     0,     0,    95,     0,     0,     0,     0,    96,
       0,   803,     0,   465,   466,   467,   468,   469,   470,   471,
     472,   473,   474,   475,   476,   459,   460,   461,   462,   463,
       0,   464,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,   465,   466,   467,   468,   469,
     470,   471,   472,   473,   474,   475,   476,   459,   460,   461,
     462,   463,     0,   464,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,   465,   466,   467,
     468,   469,   470,   471,   472,   473,   474,   475,   476
};

static const yytype_int16 yycheck[] =
{
       1,     2,   155,    44,    31,    32,   145,   556,   184,   146,
     573,    42,    96,     5,   549,   589,   224,   594,   540,   816,
      96,   208,   716,    37,    44,    90,     6,   377,   360,   715,
     977,     5,   158,   159,   892,   174,   175,    38,    39,     5,
       5,    42,   168,    44,   384,   232,     3,     5,    47,     1,
      51,   681,    96,     3,    62,   540,    41,    58,    42,    45,
       5,     3,    41,   987,   549,     6,     5,    43,    69,    45,
      54,     5,     1,     2,     5,    69,    43,  1113,    45,     5,
       5,   249,    54,    84,    85,     5,     5,    54,    40,    90,
      91,     0,   136,    42,    54,    96,    90,    91,   141,     5,
     184,     5,    43,    45,    44,    42,  1142,     5,   184,    96,
      40,   110,  1059,     5,   115,     5,   124,    47,   102,     3,
       4,    44,     6,   164,  1048,   166,  1050,     6,     3,   101,
     115,   158,   159,     5,   110,   136,   115,   117,    88,    89,
     184,  1088,   136,   157,   101,     5,    88,    89,  1006,   136,
      43,     5,   153,   102,  1101,   115,    40,   158,   159,    43,
     161,    45,     3,    40,   290,   291,   152,   168,   294,    54,
     338,    40,   114,   123,   160,     5,   118,    48,     1,     2,
     110,    60,     3,   184,    42,   815,   123,   124,   189,   539,
       3,    72,   115,   213,   771,   196,   197,   184,   199,   200,
       3,   831,   328,   329,    88,    89,   101,   360,   101,   559,
     211,    54,   213,    88,    89,    38,   101,   146,  1015,   220,
       4,   561,   223,   224,   225,   226,    45,   108,   229,   113,
     114,   232,   233,   234,   118,    58,   237,   278,   239,   240,
     241,   242,   126,   118,     6,   129,   182,    88,    89,   189,
     134,   187,   129,     0,   138,     3,   950,   134,   278,   195,
       0,    45,   948,   290,   291,  1062,   189,    88,    89,   601,
     264,    42,   115,   213,     6,    88,    89,   278,    43,   814,
      45,   217,   817,    45,   858,    88,    89,     6,   289,   290,
     291,   110,   814,   294,     0,   224,   117,   118,    54,   235,
      54,   328,   329,  1038,   117,   118,    54,   308,   309,   310,
      75,   114,   170,    45,   315,   118,   239,   358,   241,    75,
     457,   322,     3,   146,   325,   390,   327,   328,   329,   814,
     153,   134,   817,   116,   335,    54,   101,    43,   278,   340,
      88,    89,     3,   119,   330,    40,   347,   348,    40,   335,
     290,   291,   123,   124,   294,   278,   357,    54,   141,   485,
     486,   487,   403,  1098,   365,   573,   114,   575,   494,   495,
     118,  1131,    43,   196,   197,   376,   502,   378,    75,    40,
    1115,   568,   376,   384,     4,  1120,     6,    48,   211,   390,
     384,    41,  1152,    40,    75,     3,   390,   220,   748,   525,
     974,   224,    40,     4,    75,   968,    40,    88,    89,   410,
     411,   412,    49,    50,    51,   416,   417,   418,     3,   420,
     421,   422,   423,    43,   425,    45,   440,    88,    89,   430,
     288,   126,    40,   114,   129,   126,    52,   118,   129,   134,
     426,    49,    50,    51,    45,   431,    40,     4,   601,     6,
      58,    40,    41,   114,    70,    40,    40,   118,   485,   486,
      40,   319,     3,    48,    48,   116,   289,   494,   495,    58,
     410,   411,   412,    58,    58,    40,   126,   138,   498,   129,
      88,    89,    40,  1032,   134,   308,   487,    45,    45,   126,
     141,     6,   129,   113,    88,    89,     3,   498,    40,   322,
     501,   502,   325,    88,    89,   506,   114,    40,   126,    58,
     118,   129,   498,    52,    53,   516,    58,   340,   126,   520,
      40,   129,    40,    41,   525,   526,   134,   528,   457,   114,
     138,    70,   533,   118,   535,  1112,   556,   869,    52,    53,
      58,   667,     3,   544,    40,     6,    40,    88,    89,    43,
     551,   552,    40,   138,     1,   556,    70,    71,    43,   579,
     561,   115,    58,   564,     4,   557,     6,   561,   569,    54,
      58,   602,   573,   114,   575,   498,   577,   118,   579,   580,
     581,    88,    89,   557,   585,   586,   587,   763,     6,     7,
       3,   557,   557,   579,   560,    42,    43,   420,    45,   557,
      79,   602,    44,    43,    40,    45,   542,   430,    87,    88,
      89,   118,   557,   549,    54,    40,   556,    40,   557,   772,
      45,   101,   551,   557,     6,     7,   557,    88,    89,   552,
      40,   557,   557,   619,   457,   115,   116,   557,   557,     4,
     569,     6,   103,   104,   573,    40,   575,   196,   197,   958,
     670,   557,   961,   557,    41,    40,   579,   580,     4,   557,
       6,   141,   211,    40,    41,   557,   524,   557,    43,   670,
      45,   220,   530,    58,   675,    88,    89,   663,   501,   763,
      43,    58,    45,   506,   685,   557,   687,   763,    48,   675,
     691,   692,    43,   679,    45,   681,    45,   557,   699,   836,
      75,   114,    40,   557,    40,   118,    40,    41,   700,     6,
     533,   153,   535,    45,    89,   716,   869,    43,    40,   763,
      58,   544,    58,   724,    58,   726,   700,   557,   551,   749,
     724,   723,   718,    42,   700,   700,    58,    43,   596,    45,
     102,   564,   700,   744,   115,  1077,   569,   670,   749,   723,
     573,   752,   575,   754,   577,   700,   787,   723,   723,   843,
     968,   700,   763,   828,   750,   723,   700,   843,    40,   700,
      40,   213,    40,   322,   700,   700,   325,    42,   723,   745,
     700,   700,    41,    42,   723,   771,   787,   745,    41,   723,
     232,   340,   723,   716,   700,    41,   700,   723,   723,   843,
     745,   115,   700,   723,   723,   770,   807,   808,   700,    58,
     700,   745,   670,    88,    89,  1147,    40,   723,     0,   723,
     120,   121,   122,   115,   825,   723,   749,   828,   700,   815,
      42,   723,    41,   723,   828,   821,   278,    54,   839,   992,
     700,    41,   843,   103,   104,   831,   700,   289,   924,    42,
     851,   723,    41,   840,    42,   426,   843,   851,   263,   264,
     431,   853,    54,   723,   851,    42,   308,   868,    41,   723,
     700,   420,  1011,    41,    43,   876,   699,    43,    41,   853,
     924,   430,   818,   884,    41,    23,    41,   853,   853,    41,
      41,   749,   102,   723,   101,   853,    42,    40,   863,    40,
      41,   115,   825,   726,   945,    41,    44,   836,   853,   132,
     133,   134,   135,   136,   853,   357,    43,    58,   115,   853,
      45,    75,   853,   924,  1077,   966,    41,   853,   853,   787,
     924,   754,    40,   853,   853,     3,   101,   924,    76,    77,
      78,     3,     3,    81,     3,    83,    84,   853,   949,   853,
       3,   115,   501,   876,   115,   853,    41,   506,    49,    50,
      51,   853,    41,   853,    48,   966,   967,   968,   969,   970,
     971,   998,    43,   967,   416,    40,   970,   978,    45,   117,
       3,   853,    45,    43,   533,   986,   535,    41,   430,    40,
    1031,    43,   993,   853,  1147,   544,    72,    73,    74,   853,
     442,    46,    43,  1135,  1005,    41,  1138,  1139,  1140,    90,
     996,    40,  1032,   836,    89,   564,   839,    40,   983,  1151,
      41,    77,   987,   853,    88,    48,   949,    75,   577,    88,
      89,  1032,   134,   135,   136,  1036,  1022,    41,    41,   968,
      41,    41,    48,    54,    41,   868,   969,   146,   971,    54,
      42,    41,    43,   141,   101,   114,   498,   156,    41,   118,
    1061,  1047,    46,   986,    40,    88,    89,   126,   102,    41,
     129,    69,  1099,    43,   101,   134,     3,  1078,    43,  1065,
      62,    42,  1005,  1048,    41,  1050,    45,    85,    41,    41,
      41,   114,  1032,  1094,    41,   118,    41,     3,  1084,    41,
      41,  1102,    41,  1104,    41,    43,    54,  1108,  1109,  1110,
      43,    41,    46,    40,   556,   138,    45,    75,     3,    54,
      43,    48,    49,    50,    51,    75,  1112,  1128,    46,  1130,
     124,    75,    75,    46,    40,    43,  1130,   579,  1124,   102,
      43,    41,    48,    54,    42,   968,   245,   718,    41,  1135,
     699,    43,  1138,  1139,  1140,   978,    75,    43,    75,    75,
      75,    88,    89,    67,   263,  1151,    43,    43,   267,   268,
     269,   270,   271,   272,   102,    41,    43,   726,    42,   750,
      48,  1104,    88,    89,   182,    89,    71,   114,   186,   187,
      94,   118,    40,    46,    43,   193,   194,   195,    43,   126,
     771,    40,   129,    88,    89,   754,    91,   205,   114,    40,
     208,   138,   118,  1036,     3,    23,    41,    43,    46,   217,
     126,    41,    40,   129,   323,    48,    41,   326,   670,   114,
      41,    41,   138,   118,   232,    41,    44,   235,    41,    43,
      45,   745,   240,  1104,   575,   159,   914,   745,   246,   137,
     821,    40,   745,    38,   168,  1078,   457,   836,    49,   596,
      49,    50,    51,   863,   611,   983,   982,   880,    76,    77,
      78,   999,   679,    81,  1112,    83,    84,  1094,   182,  1102,
     175,   725,   186,   187,    -1,  1108,  1109,  1110,    -1,    -1,
     839,   195,    -1,    -1,    -1,    -1,     3,    -1,    -1,    88,
      89,     3,    -1,    -1,   208,  1128,    -1,   749,    -1,    -1,
      -1,    -1,    -1,   217,   218,    -1,    -1,    -1,    -1,   868,
     234,    -1,    -1,   237,    -1,   114,    -1,   231,   232,   118,
      -1,   235,    -1,    40,    -1,    -1,    -1,    -1,    40,   243,
      42,    48,    -1,    -1,    -1,    -1,    48,    -1,     3,   138,
      -1,    58,    54,    -1,     3,    -1,    58,    -1,   457,    -1,
     459,   460,   461,   462,   463,   464,   465,   466,   467,   468,
     469,   470,   471,   472,   473,   474,   475,   476,    -1,    -1,
      -1,    88,    89,    -1,    -1,    40,    88,    89,    -1,    -1,
      -1,    40,    -1,    48,    -1,   309,    -1,    -1,    -1,    54,
     102,   315,    -1,    58,    -1,    -1,    -1,   114,   507,    58,
      -1,   118,   114,   327,   328,   329,   118,    -1,    -1,   126,
      -1,   335,   129,    -1,   126,   996,    -1,   129,    -1,   978,
      -1,   138,   134,    88,    89,    -1,   138,    -1,    -1,    88,
      89,     3,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,
      -1,  1022,    -1,    -1,     3,    -1,    -1,    -1,    -1,   114,
       3,    -1,    -1,   118,    -1,   114,    -1,    -1,    -1,   118,
      -1,   126,    -1,    -1,   129,    -1,  1047,   126,    40,   134,
     129,    -1,    -1,   138,    40,   134,    48,  1036,     3,   138,
      -1,    40,    48,    -1,  1065,    -1,    58,    40,    -1,    48,
      -1,    -1,    58,   417,   418,    48,    -1,   421,   422,   423,
      -1,   425,    -1,  1084,    -1,    58,   615,   616,   617,   618,
     619,    -1,   621,    -1,    -1,    40,    88,    89,    -1,  1078,
      -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    88,
      89,  1112,    -1,    -1,   542,    88,    89,    -1,    -1,    -1,
      -1,   549,   114,  1102,     3,    -1,   118,     6,   114,  1108,
    1109,  1110,   118,    -1,   126,   114,    -1,   129,   566,   118,
     568,   114,   134,    88,    89,   118,   138,   126,    -1,  1128,
     129,    -1,   138,   126,    -1,   134,   129,    -1,   502,   138,
    1032,   134,    -1,  1035,  1036,   138,    -1,    -1,    -1,   114,
     105,   106,   516,   118,   109,    -1,   520,    -1,    -1,    -1,
      -1,   525,   526,    -1,   528,    -1,    -1,    -1,    -1,   134,
      49,    50,    51,   138,   622,   130,   131,   132,   133,   134,
     135,   136,   536,    -1,    -1,    -1,   540,    -1,   542,    88,
      89,    -1,    -1,    -1,   548,   549,    -1,    -1,    -1,    -1,
      79,    -1,    -1,    -1,   103,   104,   755,    -1,    87,    88,
      89,    -1,    -1,    -1,   568,   114,   570,   581,    -1,   118,
      -1,   585,   586,   587,   773,    -1,   580,   126,    -1,    -1,
     129,     3,    -1,     3,    -1,   134,   785,   786,    -1,   788,
      -1,    -1,    -1,    -1,    -1,   794,     3,   126,    -1,    -1,
     129,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    -1,
      40,    -1,    -1,    43,    -1,    -1,   724,    49,    50,    51,
      52,    53,   109,    40,    -1,    -1,    -1,   836,    -1,     3,
      -1,    48,     6,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    58,    -1,   130,   131,   132,   133,   134,   135,   136,
      -1,   675,    -1,    85,    86,    -1,    88,    89,    88,    89,
      -1,   685,    -1,   687,    -1,    -1,    40,   691,   692,    -1,
      -1,    88,    89,    -1,    -1,    -1,     3,    -1,    -1,    -1,
      -1,    -1,   114,     3,   114,    -1,   118,   119,   118,    -1,
       3,    -1,    -1,    -1,    -1,    -1,   126,   114,    -1,   129,
      -1,   118,   716,    -1,   134,    -1,   138,    -1,   138,   126,
     818,   725,   129,    40,    88,    89,    43,   134,    -1,    -1,
      40,   138,   931,   932,   832,   833,   834,    40,   752,    -1,
      43,    -1,    -1,    -1,     3,    -1,    -1,     3,    -1,    -1,
     114,    -1,    -1,    -1,   118,   130,   131,   132,   133,   134,
     135,   136,   126,    -1,    -1,   129,    -1,   865,    -1,    -1,
     134,    88,    89,    -1,   138,    -1,    -1,    -1,    88,    89,
      -1,    40,    -1,    -1,    40,    88,    89,    -1,    -1,    48,
      -1,    -1,    -1,   807,   808,    -1,    -1,   114,    -1,    58,
      -1,   118,    -1,    -1,   114,    -1,    -1,    -1,   118,   126,
     814,   114,   129,   817,   818,   118,   126,   134,    -1,   129,
      -1,   138,    -1,   126,   134,    -1,   129,    -1,   138,    88,
      89,   134,    88,    89,    -1,   138,    -1,    -1,   842,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,  1045,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,   114,   118,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,  1067,    -1,
     126,    -1,    -1,   129,    -1,     1,    -1,     3,   134,   138,
       6,     7,   138,     3,   982,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      40,    -1,    -1,    49,    50,    51,    52,    53,    48,    55,
      56,    -1,    58,    -1,    -1,    -1,    -1,    -1,    58,    -1,
      -1,    -1,    -1,    69,    70,    71,   950,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   105,   106,   107,   108,   109,    85,
      -1,    87,    88,    89,    -1,     3,    -1,    -1,    88,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   103,   104,   130,
     131,   132,   133,   134,   135,   136,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    40,   129,    -1,    -1,   132,   133,   134,     1,
      48,     3,   138,   139,     6,     7,    -1,     3,   138,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      88,    89,    -1,    45,    40,    -1,    -1,    49,    50,    51,
      52,    53,    48,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,   114,    69,    70,    71,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   126,    -1,
      -1,   129,    -1,    85,    -1,    87,    88,    89,    -1,     3,
     138,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   103,   104,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    40,   129,    -1,    -1,
     132,   133,   134,     1,    48,     3,   138,   139,     6,     7,
      -1,     3,   138,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    88,    89,    -1,    -1,    40,    -1,
      -1,    49,    50,    51,    52,    53,    48,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     6,    -1,
     114,    69,    70,    71,   118,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,     3,   138,    -1,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   103,   104,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      40,   129,    -1,    -1,   132,   133,   134,     1,    48,     3,
     138,   139,     6,     7,    -1,    41,   138,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    88,    89,
      -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    69,    70,    71,   118,   105,
     106,   107,   108,   109,    -1,   111,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,   138,   125,
     126,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,     1,    -1,     3,     4,    -1,
      -1,    -1,     8,     9,    10,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,    -1,   138,   139,    -1,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    -1,    -1,    -1,    43,    44,    -1,
      46,    -1,    -1,    49,    50,    51,    52,    53,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    72,    73,    74,    -1,
      76,    77,    78,    -1,    80,    81,    82,    83,    84,    85,
      86,    -1,    88,    89,    90,    -1,    -1,    -1,    94,    95,
      96,    97,    98,    99,   100,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,   114,    -1,
      -1,   117,   118,   119,    -1,    -1,    -1,   123,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,     6,     7,
      -1,     3,   138,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    45,    40,    -1,
      -1,    49,    50,    51,    52,    53,    48,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,     3,    -1,    -1,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   103,   104,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      40,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,     3,   138,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    88,    89,
      -1,    -1,    40,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    69,    70,    71,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,   138,     3,
      88,    89,     6,    -1,    -1,    -1,    -1,    -1,    -1,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
     114,    -1,    -1,    -1,   118,    -1,   114,    -1,    -1,   123,
     118,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
     138,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    88,    89,    -1,    -1,    -1,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,   103,
     104,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   105,   106,   107,
     108,   109,    -1,   103,   104,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    41,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,   105,   106,   107,   108,
     109,    -1,   111,    -1,   105,   106,   107,   108,   109,    85,
      -1,    87,    88,    89,    -1,    -1,   125,   126,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,   129,   130,
     131,   132,   133,   134,   135,   136,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,    -1,    -1,   132,   133,   134,    -1,
      -1,     3,   138,   139,     6,     7,    41,    -1,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    41,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
     105,   106,   107,   108,   109,    -1,   111,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,
     132,   133,   134,    -1,    -1,     3,   138,   139,     6,     7,
      41,    -1,    -1,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    49,    50,    51,    52,    53,    -1,    55,    56,    -1,
      -1,    59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,   105,   106,   107,   108,   109,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    -1,   125,   126,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,    -1,    43,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    59,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,   105,   106,
     107,   108,   109,    -1,   111,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,   125,   126,
     127,   128,   129,   130,   131,   132,   133,   134,   135,   136,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
      -1,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    75,    -1,    -1,    -1,    -1,    -1,    -1,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    59,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,   105,   106,   107,   108,   109,    -1,   111,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,   125,   126,   127,   128,   129,   130,   131,   132,
     133,   134,   135,   136,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    -1,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,   105,   106,   107,   108,
     109,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    88,    89,    -1,    -1,   125,   126,   127,   128,
     129,   130,   131,   132,   133,   134,   135,   136,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,    -1,    -1,   132,   133,   134,    -1,
      -1,     3,   138,   139,     6,     7,    -1,    -1,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
     105,   106,   107,   108,   109,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,
     132,   133,   134,    -1,    -1,     3,   138,   139,     6,     7,
      -1,    -1,    -1,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    -1,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,   105,   106,   107,   108,   109,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    -1,    -1,   126,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,    -1,    -1,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,   105,   106,
     107,   108,   109,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,    -1,    -1,
      -1,   128,   129,   130,   131,   132,   133,   134,   135,   136,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
      -1,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      24,    25,    26,    27,    28,    29,    30,    31,    -1,    33,
      -1,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    -1,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,    -1,    -1,   132,   133,   134,    -1,
      -1,     3,   138,   139,     6,     7,    -1,    -1,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,
     132,   133,   134,    -1,    -1,     3,   138,   139,     6,     7,
      -1,    -1,    -1,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    -1,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,    -1,    -1,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
      -1,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    -1,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,    -1,    -1,   132,   133,   134,    -1,
      -1,     3,   138,   139,     6,     7,    -1,    -1,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,
     132,   133,   134,    -1,    -1,     3,   138,   139,     6,     7,
      -1,    -1,    -1,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    -1,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,    -1,    -1,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
      -1,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    -1,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   129,    -1,    -1,   132,   133,   134,    -1,
      -1,     3,   138,   139,     6,     7,    -1,    -1,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,
     132,   133,   134,    -1,    -1,     3,   138,   139,     6,     7,
      -1,    -1,    -1,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      48,    49,    50,    51,    52,    53,    -1,    55,    56,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    87,
      88,    89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,
     118,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   129,    -1,    -1,   132,   133,   134,    -1,    -1,     3,
     138,   139,     6,     7,    -1,    -1,    -1,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    55,    56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    87,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   129,    -1,    -1,   132,   133,
     134,    -1,    -1,     3,   138,   139,     6,     7,    -1,    -1,
      -1,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   129,
      -1,    -1,   132,   133,   134,    -1,    -1,     3,   138,   139,
       6,     7,    -1,    -1,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    59,    55,
      56,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    85,
      -1,    87,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   105,   106,   107,   108,   109,    -1,
     111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,    -1,
      -1,    -1,   118,    -1,   125,   126,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,   132,   133,    -1,    -1,
      -1,     3,   138,   139,     6,     7,    -1,     3,    -1,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,     3,
      -1,     3,    -1,    -1,    40,    -1,    -1,    49,    50,    51,
      52,    53,    -1,    55,    56,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    40,    -1,    40,    -1,
      -1,    -1,    -1,    85,    -1,    87,    88,    89,    -1,    -1,
      -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,   114,    -1,
      -1,    -1,   118,    -1,    88,    89,    88,    89,    -1,    -1,
     126,    -1,    -1,   129,    -1,    -1,   138,   139,   134,    -1,
      -1,    -1,   138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,   114,    -1,   118,    -1,   118,     3,    -1,    -1,
      -1,    -1,   126,    -1,    -1,   129,    41,    -1,    -1,    -1,
     134,    -1,   134,    -1,   138,    -1,   138,    -1,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    48,    49,    50,    51,    52,    53,    -1,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    69,    70,    71,    -1,   102,    -1,    -1,
     105,   106,   107,   108,   109,    -1,   111,    -1,    -1,    85,
      -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
     125,   126,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,    -1,    -1,    -1,    -1,    -1,    -1,   114,     3,
      -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    -1,    -1,
     126,    -1,    -1,   129,    -1,    -1,    -1,    -1,   134,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,    53,
      -1,    -1,    -1,    -1,    58,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    40,
      -1,    85,    -1,    -1,    88,    89,    -1,    -1,    49,    50,
      51,    -1,    -1,    54,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,     3,    -1,    -1,   118,    -1,    -1,     3,    79,   123,
      -1,    -1,   126,    -1,    -1,   129,    87,    88,    89,    -1,
     134,    -1,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    -1,
      -1,    -1,    -1,    -1,    40,    -1,    48,    49,    50,    51,
      52,    53,    48,    -1,    -1,   126,    -1,    -1,   129,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    69,    70,    71,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    85,    -1,    -1,    88,    89,    -1,    -1,
      -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   114,    -1,    -1,    -1,   118,    -1,   114,    -1,
      -1,   123,   118,    -1,   126,    -1,    -1,   129,    -1,    -1,
     126,    -1,   134,   129,    -1,    -1,     0,     1,   134,     3,
       4,    -1,    -1,    -1,     8,     9,    10,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    23,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    43,
      44,    -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,
      -1,    -1,    -1,    57,    -1,    -1,    -1,    -1,    62,    63,
      64,    65,    66,    67,    68,    69,    70,    71,    -1,    -1,
      -1,    -1,    76,    77,    78,    -1,    80,    81,    82,    83,
      84,    85,    86,    -1,    88,    89,    90,    91,    92,    93,
      94,    95,    96,    97,    98,    99,   100,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   112,     1,
     114,     3,     4,   117,   118,    -1,     8,     9,    10,   123,
     124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    -1,    -1,
      -1,    43,    44,    -1,    46,    -1,    -1,    49,    50,    51,
      52,    53,    -1,    -1,    -1,    57,    -1,    -1,    -1,    -1,
      62,    63,    64,    65,    66,    67,    68,    69,    70,    71,
      -1,    -1,    -1,    -1,    76,    77,    78,    -1,    80,    81,
      82,    83,    84,    85,    86,    -1,    88,    89,    90,    91,
      92,    93,    94,    95,    96,    97,    98,    99,   100,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     112,     1,   114,     3,     4,   117,   118,    -1,     8,     9,
      10,   123,   124,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,    -1,    43,    44,    -1,    46,    -1,    -1,    49,
      50,    51,    52,    53,    -1,    -1,    -1,    57,    -1,    -1,
      -1,    -1,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    71,    -1,    -1,    -1,    -1,    76,    77,    78,    -1,
      80,    81,    82,    83,    84,    85,    86,    -1,    88,    89,
      90,    91,    92,    93,    94,    95,    96,    97,    98,    99,
     100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   112,     1,   114,     3,     4,   117,   118,    -1,
       8,     9,    10,   123,   124,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    23,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    -1,    -1,    -1,    43,    44,    -1,    46,    -1,
      -1,    49,    50,    51,    52,    53,    -1,    -1,    -1,    57,
      -1,    -1,    -1,    -1,    62,    63,    64,    65,    66,    67,
      68,    69,    70,    71,    -1,    -1,    -1,    -1,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    85,    86,    -1,
      88,    89,    90,    91,    92,    93,    94,    95,    96,    97,
      98,    99,   100,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   112,     1,   114,     3,     4,   117,
     118,    -1,     8,     9,    10,   123,   124,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    -1,    -1,    -1,    43,    44,    -1,
      -1,    -1,    -1,    49,    50,    51,    52,    53,    -1,    -1,
      -1,    57,    -1,    -1,    -1,    61,    62,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    -1,    -1,    -1,    -1,
      76,    77,    78,    -1,    80,    81,    82,    83,    84,    85,
      86,    -1,    88,    89,    90,    91,    92,    93,    94,    95,
      96,    97,    98,    99,   100,    -1,     1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   112,    -1,   114,    -1,
      -1,   117,   118,    -1,    -1,    -1,    -1,   123,   124,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,
      -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,
      -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,   123,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    48,    49,    50,    51,    52,    53,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      85,    -1,    -1,    88,    89,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   114,
      13,    -1,    -1,   118,    -1,    -1,    -1,    -1,   123,   124,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    -1,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,
     123,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    -1,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   114,    -1,    -1,   117,   118,    -1,    -1,    -1,    -1,
     123,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    48,    49,    50,    51,    52,
      53,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,     4,    69,    70,    71,     8,
       9,    10,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    85,    -1,    23,    88,    89,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    43,    44,    -1,    46,    -1,    -1,
      -1,   114,    -1,    -1,    -1,   118,    -1,    -1,    -1,    -1,
     123,    -1,    -1,    62,    63,    64,    65,    66,    67,    68,
      -1,    -1,    -1,    72,    73,    74,    -1,    76,    77,    78,
      -1,    80,    81,    82,    83,    84,    -1,    -1,    -1,    -1,
      -1,    90,    -1,    -1,    -1,    94,    95,    96,    97,    98,
      99,   100,     1,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,   117,    -1,
      -1,    -1,    -1,    -1,   123,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    86,    -1,    88,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,     3,    -1,   114,     6,     7,    -1,   118,
     119,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    48,    49,
      50,    51,    52,    53,    -1,    55,    56,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    87,    88,    89,
      -1,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    48,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    86,    -1,    88,
      89,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      49,    50,    51,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      49,    -1,    -1,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,
      -1,    -1,   101,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    49,    -1,    -1,    52,    53,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    69,    70,    71,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    85,    -1,    -1,    88,    89,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     3,    -1,    -1,   101,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     114,    -1,    -1,    -1,   118,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    -1,    -1,    52,    53,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      69,    70,    71,     3,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,
      89,    -1,    -1,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,
      -1,    -1,    52,    53,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      70,    71,    -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,    89,
      -1,    -1,    -1,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      -1,    -1,    -1,    -1,   114,    -1,    -1,    -1,   118,    49,
      -1,    -1,    -1,     4,    -1,    -1,    -1,     8,     9,    10,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    69,
      -1,    -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    85,    -1,    -1,    88,    89,
      -1,    -1,    43,    44,    -1,    46,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    62,    63,    64,   114,    66,    67,    68,   118,    -1,
      -1,    72,    73,    74,    -1,    76,    77,    78,    -1,    80,
      81,    82,    83,    84,    -1,    -1,     4,    -1,    -1,    90,
       8,     9,    10,    94,    95,    96,    97,    98,    99,   100,
      -1,    -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,
      -1,   112,    -1,    -1,    -1,    -1,   117,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    43,    44,    -1,    46,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    59,    -1,    -1,
      -1,    -1,    -1,    -1,    62,    63,    64,    -1,    66,    67,
      68,    -1,    -1,    -1,    72,    73,    74,    -1,    76,    77,
      78,    -1,    80,    81,    82,    83,    84,    -1,    -1,    59,
      -1,    -1,    90,    -1,    -1,    -1,    94,    95,    96,    97,
      98,    99,   100,   105,   106,   107,   108,   109,    -1,   111,
      -1,    -1,    -1,    -1,   112,    -1,    -1,    -1,    -1,   117,
      -1,    59,    -1,   125,   126,   127,   128,   129,   130,   131,
     132,   133,   134,   135,   136,   105,   106,   107,   108,   109,
      -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   125,   126,   127,   128,   129,
     130,   131,   132,   133,   134,   135,   136,   105,   106,   107,
     108,   109,    -1,   111,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   125,   126,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,   120,   121,   122,   143,   144,     1,     3,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    48,    49,    50,    51,    52,    53,
      69,    70,    71,    85,    88,    89,   114,   118,   123,   193,
     234,   235,   250,   251,   253,   254,   255,   258,   259,   260,
     288,   289,   304,   307,   309,     1,   235,     1,    40,     0,
       1,     4,     8,     9,    10,    23,    43,    44,    57,    62,
      63,    64,    65,    66,    67,    68,    76,    77,    78,    80,
      81,    82,    83,    84,    90,    91,    92,    93,    94,    95,
      96,    97,    98,    99,   100,   112,   117,   123,   124,   145,
     146,   147,   149,   150,   151,   152,   155,   156,   158,   159,
     160,   161,   162,   163,   166,   167,   168,   171,   173,   178,
     179,   180,   181,   183,   187,   195,   196,   197,   198,   199,
     203,   204,   210,   211,   222,   223,   229,   230,   231,    52,
      70,    48,   279,   279,    40,   141,   101,   303,   234,   307,
       0,   251,   254,    40,    48,    54,    58,   118,   126,   129,
     134,   138,   239,   240,   242,   244,   245,   246,   247,   307,
     250,   259,   307,   303,   116,   141,   308,     0,   232,   233,
     235,   119,    40,     6,   117,   313,    40,   316,     1,   252,
     253,   304,   316,    40,   165,    40,    40,    40,    40,    71,
      91,   307,    45,   304,   307,    40,     4,    45,    40,     4,
     313,    40,   177,   252,   175,   176,   177,    40,    40,   313,
      40,    32,    34,    49,   101,   186,   193,   255,   258,   289,
     307,   316,    40,   126,   129,   242,   244,   247,   307,    86,
     193,   252,   289,    44,   231,   256,   117,   118,   309,   310,
       7,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    40,    55,    56,    87,   129,   132,   133,
     134,   138,   139,   235,   236,   237,   238,   252,   253,   273,
     274,   275,   276,   277,   278,   307,   313,   314,   250,    40,
     126,   129,   232,   245,   247,   307,    45,   103,   104,   261,
     262,   263,   264,   273,   276,    59,   273,     3,    40,    48,
     138,   243,   246,   279,   307,    48,   243,   246,   279,   250,
     307,   239,    40,    58,   239,    40,    58,    48,   126,   129,
     134,   243,   246,   279,   307,   115,   309,   118,   310,    41,
      42,   123,   124,   262,   304,   305,   313,   186,   289,     6,
      45,   305,   317,   318,   305,     0,    43,    40,   242,   244,
      54,    52,    53,    70,   290,   291,   304,   304,   305,    13,
     172,   232,   232,   307,   307,    43,    54,   213,    54,    45,
     304,   174,   317,   232,    45,   241,   242,   244,   245,    43,
      42,   305,   306,   153,   154,   313,   232,   307,   117,   207,
     208,   209,   235,   288,   307,   307,   307,   126,   129,   313,
     126,   129,   247,   304,   307,   317,    40,    48,    48,   305,
      40,    48,   126,   129,   307,   115,   242,   307,   265,   304,
      40,   242,    75,   280,   281,   307,   313,     1,   257,   273,
     304,   308,   273,   275,    40,    48,   252,   275,    40,    40,
     273,   273,   273,   273,   273,   273,   102,    42,    40,   105,
     106,   107,   108,   109,   111,   125,   126,   127,   128,   129,
     130,   131,   132,   133,   134,   135,   136,    40,    47,   110,
      47,   110,     7,     6,     7,   126,   129,   247,   307,   244,
     307,   244,    41,    41,   126,   129,   244,   307,   115,    58,
      59,    40,   247,   307,   243,   307,    40,    58,   243,   232,
      59,   273,   232,    59,   273,   243,    48,   243,   246,   279,
      48,   243,   246,   279,   250,   115,    48,   126,   129,   243,
     250,   308,     0,   124,   232,    42,    41,   307,   307,   182,
      54,    41,    42,   239,    40,   261,   307,    41,    54,    42,
     170,    42,    41,    41,    43,    43,   252,   144,   307,   212,
      41,    41,    41,   175,    40,   177,    41,    41,    42,    45,
      41,   126,   129,   101,   102,    42,   239,    40,    60,   115,
      41,   247,   307,    43,   232,    48,    48,   115,    79,    87,
      88,    89,   126,   129,   248,   249,   250,   293,   296,   297,
     298,    54,    75,   194,   232,   307,   298,   282,    45,    43,
      89,   295,    41,    41,   303,    41,   102,   126,   129,   134,
     247,   101,    40,   238,    48,   273,    48,   273,    48,   273,
      48,   273,   273,   273,    48,   273,    48,   273,    48,   273,
      48,   273,    48,   273,    48,   273,    48,   273,    48,   273,
      48,   273,    48,   273,    48,   273,    48,   273,     3,     3,
       3,     3,   307,   115,    41,    41,    41,   115,   242,   245,
     250,   232,   243,   307,    41,   115,   232,    59,   273,    41,
      59,    41,    59,   243,   243,    48,   126,   129,   243,   246,
     243,    48,    48,   243,   232,   232,     4,    45,   313,    40,
     144,   153,   277,   313,   319,   305,    43,   232,    43,    45,
       4,   164,   313,   305,   313,   319,    41,   235,   242,    45,
     241,    46,    43,   144,   229,   175,    40,    46,   232,   114,
     118,   304,   311,    43,   317,   235,     4,    43,    45,   113,
     169,   313,   315,   207,    90,   205,   209,   232,   157,   250,
     242,   313,   115,    41,    40,    40,   293,    89,    88,   296,
     249,    43,    45,   110,     1,    58,   188,   261,   254,    43,
      45,    41,    54,    75,   185,   239,    77,   283,   284,   292,
     201,   280,   273,    48,   273,    41,    41,   250,    41,   126,
     129,    48,   273,   304,    75,    41,    41,   242,   245,    41,
      41,   243,    41,    59,   297,   248,   243,    48,    48,   243,
     243,   243,   232,    46,    54,    41,   148,    54,    42,   170,
     169,   242,   298,    43,    46,   252,   304,    43,    54,   315,
     232,    41,   141,   116,   141,   312,   101,    41,    46,    40,
     102,   307,    44,   117,   183,   199,   203,   204,   206,   219,
     221,   229,    41,   144,   298,    43,   232,   273,   186,    43,
     101,   189,    43,   151,   266,   267,   268,   269,    40,    54,
     296,   298,   299,     1,   273,     1,    42,    43,    45,   184,
      42,    72,    73,    74,   285,   287,     1,    43,    65,    72,
      73,    74,   123,   149,   150,   151,   152,   155,   156,   160,
     163,   166,   168,   171,   173,   178,   179,   180,   181,   199,
     203,   204,   210,   214,   215,   216,   217,   219,   220,   221,
     222,   224,   225,   227,   229,    45,    41,    41,   273,   273,
     273,    41,    41,    41,    41,    41,   273,    41,    41,    41,
     243,   243,    41,   153,   319,   248,   214,   313,   319,    41,
     298,    43,   242,    43,   177,    41,   248,   118,   304,   304,
     118,   304,   236,     4,    45,   232,   289,    54,   101,    86,
     119,   252,    61,    43,    41,    41,   293,   294,    40,    45,
     190,   266,   123,   270,   271,   304,    46,    42,   123,   124,
     232,   261,    54,    75,   300,    43,   242,   284,   307,   286,
      45,    75,    75,    75,   216,    46,   123,   217,   124,    32,
      34,   138,   228,   258,   307,   200,   273,   273,   239,    46,
     170,    43,   242,   169,    43,    43,   312,   312,   102,    41,
     239,   307,   252,   207,   307,   252,    40,   293,   185,   232,
      40,    43,   191,   271,   267,    54,    43,   242,   124,   268,
      42,    41,    43,   262,   301,   302,   307,    43,    45,   298,
     279,   292,   218,    43,   202,   242,   309,    75,    43,   214,
      43,   298,    43,    43,   239,   241,   102,    54,    40,   126,
     129,   247,   232,   184,    41,   192,   272,   273,   298,   268,
     268,    43,    45,    43,    42,    48,    40,    45,   185,   307,
     214,   298,    40,   273,    46,    43,    43,   232,    40,    40,
      40,   129,    41,   298,    43,   185,   302,   184,   279,    46,
     185,   232,    43,   202,    41,   232,   232,   232,    40,   299,
     110,   190,   184,    48,   184,    41,   226,   298,    41,    41,
      41,   232,   252,   191,   226,    43,    45,    54,   226,   226,
     226,    41,   190,   261,   226,   191,    43
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   142,   143,   143,   143,   143,   143,   143,   143,   144,
     144,   144,   144,   145,   145,   145,   145,   145,   145,   145,
     146,   146,   146,   146,   146,   146,   146,   146,   146,   146,
     146,   146,   146,   146,   146,   146,   146,   146,   146,   148,
     147,   149,   150,   151,   151,   151,   151,   151,   152,   152,
     153,   154,   154,   155,   155,   155,   157,   156,   158,   158,
     159,   159,   160,   160,   160,   160,   161,   162,   162,   163,
     163,   164,   164,   165,   165,   166,   166,   166,   167,   167,
     168,   168,   168,   168,   169,   169,   169,   170,   170,   171,
     172,   172,   173,   173,   173,   174,   175,   176,   176,   177,
     177,   177,   178,   179,   180,   181,   181,   181,   182,   181,
     181,   181,   181,   181,   183,   183,   183,   183,   183,   183,
     183,   184,   184,   184,   184,   185,   185,   186,   186,   186,
     186,   186,   186,   186,   186,   186,   186,   187,   187,   187,
     188,   189,   189,   190,   191,   192,   191,   193,   193,   193,
     194,   194,   195,   196,   196,   197,   198,   198,   198,   198,
     198,   198,   200,   199,   201,   199,   202,   202,   203,   205,
     204,   204,   204,   204,   204,   206,   206,   206,   206,   206,
     206,   207,   207,   208,   208,   209,   209,   209,   209,   210,
     210,   210,   212,   211,   213,   211,   211,   214,   214,   214,
     214,   214,   215,   215,   216,   216,   216,   216,   216,   216,
     216,   216,   216,   216,   216,   216,   216,   216,   216,   216,
     216,   216,   216,   217,   217,   217,   218,   217,   219,   220,
     221,   221,   221,   221,   221,   222,   223,   224,   224,   224,
     225,   225,   225,   225,   225,   225,   225,   225,   225,   225,
     226,   226,   226,   227,   228,   228,   228,   228,   229,   229,
     230,   230,   231,   231,   231,   231,   231,   231,   231,   231,
     231,   232,   233,   233,   233,   233,   233,   233,   233,   234,
     234,   235,   235,   236,   236,   237,   237,   238,   238,   239,
     239,   239,   239,   240,   240,   240,   240,   241,   241,   241,
     241,   242,   242,   242,   242,   242,   242,   242,   242,   242,
     242,   242,   242,   242,   242,   242,   242,   242,   242,   242,
     242,   242,   243,   243,   243,   243,   243,   243,   243,   243,
     244,   244,   244,   244,   244,   244,   244,   244,   244,   244,
     244,   244,   244,   245,   245,   245,   245,   245,   245,   245,
     245,   245,   245,   245,   245,   245,   245,   245,   246,   246,
     246,   246,   246,   246,   246,   246,   247,   247,   247,   247,
     248,   248,   248,   249,   249,   250,   250,   251,   251,   251,
     252,   253,   253,   253,   253,   253,   254,   254,   254,   254,
     254,   254,   254,   256,   255,   257,   257,   258,   259,   259,
     260,   260,   260,   260,   260,   260,   260,   260,   260,   260,
     260,   260,   260,   260,   261,   261,   262,   262,   263,   264,
     265,   265,   266,   266,   267,   267,   268,   268,   268,   268,
     268,   268,   268,   269,   270,   270,   271,   271,   272,   273,
     273,   274,   274,   274,   274,   274,   274,   275,   275,   275,
     275,   275,   275,   275,   275,   275,   275,   275,   276,   276,
     276,   276,   276,   276,   276,   276,   276,   276,   276,   277,
     277,   277,   277,   277,   277,   277,   277,   277,   277,   278,
     278,   278,   278,   278,   278,   278,   278,   278,   278,   278,
     278,   278,   278,   278,   278,   278,   278,   278,   278,   278,
     278,   278,   278,   278,   278,   278,   278,   278,   278,   278,
     278,   278,   278,   278,   278,   278,   278,   278,   278,   278,
     278,   279,   279,   280,   282,   281,   281,   283,   283,   285,
     284,   286,   284,   287,   287,   287,   288,   288,   289,   289,
     289,   290,   290,   290,   291,   291,   292,   292,   293,   293,
     293,   293,   294,   294,   295,   295,   296,   296,   296,   296,
     296,   296,   297,   297,   297,   298,   298,   299,   299,   299,
     299,   299,   299,   300,   300,   301,   301,   301,   301,   302,
     302,   303,   304,   304,   304,   305,   305,   305,   306,   306,
     307,   307,   307,   307,   307,   307,   307,   308,   308,   308,
     308,   309,   309,   310,   310,   311,   311,   311,   311,   311,
     311,   312,   312,   312,   312,   313,   313,   314,   314,   314,
     314,   315,   315,   315,   316,   316,   317,   318,   318,   318,
     318,   318,   318,   319,   319
};

/* YYR2[RULE-NUM] -- Number of symbols on the right-hand side of rule RULE-NUM.  */
static const yytype_int8 yyr2[] =
{
       0,     2,     1,     3,     2,     3,     2,     5,     2,     2,
       2,     2,     0,     1,     1,     1,     1,     1,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     0,
       8,     5,     3,     5,     5,     9,     3,     3,     2,     2,
       4,     1,     1,     7,     7,     5,     0,     7,     1,     1,
       2,     2,     1,     5,     5,     5,     3,     7,     8,     5,
       3,     1,     1,     3,     0,     4,     7,     6,     1,     1,
       8,    10,     6,     8,     1,     1,     5,     5,     0,     7,
       1,     3,     6,     6,     8,     1,     1,     1,     3,     2,
       3,     6,     5,     9,     2,     1,     1,     1,     0,     6,
       1,     6,    10,     1,     6,     7,     9,     5,     5,     6,
       6,     1,     5,     1,     1,     1,     2,     1,     1,     1,
       2,     1,     2,     2,     3,     3,     1,    12,    14,     8,
       1,     1,     0,     1,     1,     0,     3,     1,     2,     2,
       2,     0,     5,     8,    11,     6,     1,     1,     1,     1,
       1,     1,     0,    10,     0,     8,     1,     4,     4,     0,
       6,     3,     6,     4,     7,     1,     1,     1,     1,     1,
       1,     1,     0,     1,     3,     2,     7,     6,     1,     3,
       4,     4,     0,     6,     0,     5,     5,     1,     2,     0,
       1,     1,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     3,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     2,     0,     5,     6,     7,
       8,     8,     8,     9,     7,     5,     2,     2,     2,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       2,     4,     2,     5,     1,     1,     1,     1,     1,     0,
       1,     2,     1,     2,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     2,     2,     3,     4,     4,     0,     2,
       1,     1,     2,     1,     0,     1,     3,     1,     1,     2,
       3,     2,     0,     2,     2,     1,     5,     1,     1,     5,
       0,     2,     3,     3,     1,     2,     2,     3,     4,     5,
       4,     3,     4,     4,     3,     3,     4,     5,     6,     6,
       5,     5,     1,     2,     3,     4,     5,     3,     4,     4,
       1,     2,     4,     4,     4,     5,     6,     5,     6,     3,
       4,     4,     5,     2,     2,     3,     3,     3,     3,     1,
       2,     2,     2,     2,     2,     3,     3,     4,     3,     4,
       2,     3,     3,     4,     5,     3,     3,     2,     2,     1,
       1,     2,     1,     1,     1,     1,     2,     1,     1,     1,
       1,     2,     1,     2,     3,     2,     1,     1,     1,     2,
       1,     2,     1,     0,     4,     2,     2,     1,     1,     2,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     0,     1,     2,     1,     0,     1,     2,     2,     3,
       4,     4,     1,     3,     1,     2,     1,     3,     1,     1,
       1,     3,     3,     3,     3,     2,     2,     1,     1,     1,
       1,     1,     1,     2,     2,     2,     5,     2,     1,     1,
       3,     4,     5,     5,     5,     6,     6,     2,     2,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     5,     5,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     5,     5,     3,     3,     3,     5,     2,     2,     2,
       2,     1,     0,     1,     0,     3,     0,     1,     3,     0,
       4,     0,     6,     1,     1,     1,     2,     2,     1,     1,
       1,     1,     1,     1,     1,     0,     1,     0,     1,     1,
       2,     2,     1,     0,     1,     0,     4,     1,     1,     5,
       2,     4,     1,     1,     2,     1,     0,     3,     3,     4,
       4,     3,     4,     2,     0,     1,     3,     2,     4,     2,
       2,     3,     1,     1,     1,     1,     1,     1,     1,     0,
       2,     4,     1,     3,     1,     2,     3,     3,     2,     2,
       2,     1,     2,     1,     3,     2,     4,     1,     3,     1,
       3,     3,     2,     2,     2,     2,     1,     2,     2,     2,
       1,     1,     1,     1,     3,     0,     1,     3,     5,     1,
       3,     3,     5,     1,     1
};


enum { YYENOMEM = -2 };

#define yyerrok         (yyerrstatus = 0)
#define yyclearin       (yychar = YYEMPTY)

#define YYACCEPT        goto yyacceptlab
#define YYABORT         goto yyabortlab
#define YYERROR         goto yyerrorlab
#define YYNOMEM         goto yyexhaustedlab


#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)                                    \
  do                                                              \
    if (yychar == YYEMPTY)                                        \
      {                                                           \
        yychar = (Token);                                         \
        yylval = (Value);                                         \
        YYPOPSTACK (yylen);                                       \
        yystate = *yyssp;                                         \
        goto yybackup;                                            \
      }                                                           \
    else                                                          \
      {                                                           \
        yyerror (YY_("syntax error: cannot back up")); \
        YYERROR;                                                  \
      }                                                           \
  while (0)

/* Backward compatibility with an undocumented macro.
   Use YYerror or YYUNDEF. */
#define YYERRCODE YYUNDEF


/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)                        \
do {                                            \
  if (yydebug)                                  \
    YYFPRINTF Args;                             \
} while (0)




# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)                    \
do {                                                                      \
  if (yydebug)                                                            \
    {                                                                     \
      YYFPRINTF (stderr, "%s ", Title);                                   \
      yy_symbol_print (stderr,                                            \
                  Kind, Value); \
      YYFPRINTF (stderr, "\n");                                           \
    }                                                                     \
} while (0)


/*-----------------------------------.
| Print this symbol's value on YYO.  |
`-----------------------------------*/

static void
yy_symbol_value_print (FILE *yyo,
                       yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  FILE *yyoutput = yyo;
  YY_USE (yyoutput);
  if (!yyvaluep)
    return;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/*---------------------------.
| Print this symbol on YYO.  |
`---------------------------*/

static void
yy_symbol_print (FILE *yyo,
                 yysymbol_kind_t yykind, YYSTYPE const * const yyvaluep)
{
  YYFPRINTF (yyo, "%s %s (",
             yykind < YYNTOKENS ? "token" : "nterm", yysymbol_name (yykind));

  yy_symbol_value_print (yyo, yykind, yyvaluep);
  YYFPRINTF (yyo, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

static void
yy_stack_print (yy_state_t *yybottom, yy_state_t *yytop)
{
  YYFPRINTF (stderr, "Stack now");
  for (; yybottom <= yytop; yybottom++)
    {
      int yybot = *yybottom;
      YYFPRINTF (stderr, " %d", yybot);
    }
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)                            \
do {                                                            \
  if (yydebug)                                                  \
    yy_stack_print ((Bottom), (Top));                           \
} while (0)


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

static void
yy_reduce_print (yy_state_t *yyssp, YYSTYPE *yyvsp,
                 int yyrule)
{
  int yylno = yyrline[yyrule];
  int yynrhs = yyr2[yyrule];
  int yyi;
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %d):\n",
             yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      YYFPRINTF (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr,
                       YY_ACCESSING_SYMBOL (+yyssp[yyi + 1 - yynrhs]),
                       &yyvsp[(yyi + 1) - (yynrhs)]);
      YYFPRINTF (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)          \
do {                                    \
  if (yydebug)                          \
    yy_reduce_print (yyssp, yyvsp, Rule); \
} while (0)

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args) ((void) 0)
# define YY_SYMBOL_PRINT(Title, Kind, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef YYINITDEPTH
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






/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

static void
yydestruct (const char *yymsg,
            yysymbol_kind_t yykind, YYSTYPE *yyvaluep)
{
  YY_USE (yyvaluep);
  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yykind, yyvaluep, yylocationp);

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  YY_USE (yykind);
  YY_IGNORE_MAYBE_UNINITIALIZED_END
}


/* Lookahead token kind.  */
int yychar;

/* The semantic value of the lookahead symbol.  */
YYSTYPE yylval;
/* Number of syntax errors so far.  */
int yynerrs;




/*----------.
| yyparse.  |
`----------*/

int
yyparse (void)
{
    yy_state_fast_t yystate = 0;
    /* Number of tokens to shift before error messages enabled.  */
    int yyerrstatus = 0;

    /* Refer to the stacks through separate pointers, to allow yyoverflow
       to reallocate them elsewhere.  */

    /* Their size.  */
    YYPTRDIFF_T yystacksize = YYINITDEPTH;

    /* The state stack: array, bottom, top.  */
    yy_state_t yyssa[YYINITDEPTH];
    yy_state_t *yyss = yyssa;
    yy_state_t *yyssp = yyss;

    /* The semantic value stack: array, bottom, top.  */
    YYSTYPE yyvsa[YYINITDEPTH];
    YYSTYPE *yyvs = yyvsa;
    YYSTYPE *yyvsp = yyvs;

  int yyn;
  /* The return value of yyparse.  */
  int yyresult;
  /* Lookahead symbol kind.  */
  yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yychar = YYEMPTY; /* Cause a token to be read.  */

  goto yysetstate;


/*------------------------------------------------------------.
| yynewstate -- push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;


/*--------------------------------------------------------------------.
| yysetstate -- set current state (the top of the stack) to yystate.  |
`--------------------------------------------------------------------*/
yysetstate:
  YYDPRINTF ((stderr, "Entering state %d\n", yystate));
  YY_ASSERT (0 <= yystate && yystate < YYNSTATES);
  YY_IGNORE_USELESS_CAST_BEGIN
  *yyssp = YY_CAST (yy_state_t, yystate);
  YY_IGNORE_USELESS_CAST_END
  YY_STACK_PRINT (yyss, yyssp);

  if (yyss + yystacksize - 1 <= yyssp)
#if !defined yyoverflow && !defined YYSTACK_RELOCATE
    YYNOMEM;
#else
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYPTRDIFF_T yysize = yyssp - yyss + 1;

# if defined yyoverflow
      {
        /* Give user a chance to reallocate the stack.  Use copies of
           these so that the &'s don't force the real ones into
           memory.  */
        yy_state_t *yyss1 = yyss;
        YYSTYPE *yyvs1 = yyvs;

        /* Each stack pointer address is followed by the size of the
           data in use in that stack, in bytes.  This used to be a
           conditional around just the two extra args, but that might
           be undefined if yyoverflow is a macro.  */
        yyoverflow (YY_("memory exhausted"),
                    &yyss1, yysize * YYSIZEOF (*yyssp),
                    &yyvs1, yysize * YYSIZEOF (*yyvsp),
                    &yystacksize);
        yyss = yyss1;
        yyvs = yyvs1;
      }
# else /* defined YYSTACK_RELOCATE */
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
        YYNOMEM;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
        yystacksize = YYMAXDEPTH;

      {
        yy_state_t *yyss1 = yyss;
        union yyalloc *yyptr =
          YY_CAST (union yyalloc *,
                   YYSTACK_ALLOC (YY_CAST (YYSIZE_T, YYSTACK_BYTES (yystacksize))));
        if (! yyptr)
          YYNOMEM;
        YYSTACK_RELOCATE (yyss_alloc, yyss);
        YYSTACK_RELOCATE (yyvs_alloc, yyvs);
#  undef YYSTACK_RELOCATE
        if (yyss1 != yyssa)
          YYSTACK_FREE (yyss1);
      }
# endif

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;

      YY_IGNORE_USELESS_CAST_BEGIN
      YYDPRINTF ((stderr, "Stack size increased to %ld\n",
                  YY_CAST (long, yystacksize)));
      YY_IGNORE_USELESS_CAST_END

      if (yyss + yystacksize - 1 <= yyssp)
        YYABORT;
    }
#endif /* !defined yyoverflow && !defined YYSTACK_RELOCATE */


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
  if (yypact_value_is_default (yyn))
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* YYCHAR is either empty, or end-of-input, or a valid lookahead.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token\n"));
      yychar = yylex ();
    }

  if (yychar <= END)
    {
      yychar = END;
      yytoken = YYSYMBOL_YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else if (yychar == YYerror)
    {
      /* The scanner already issued an error message, process directly
         to error recovery.  But do not keep the error token as
         lookahead, it is too special and may lead us to an endless
         loop in error recovery. */
      yychar = YYUNDEF;
      yytoken = YYSYMBOL_YYerror;
      goto yyerrlab1;
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
      if (yytable_value_is_error (yyn))
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
  yystate = yyn;
  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END

  /* Discard the shifted token.  */
  yychar = YYEMPTY;
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
| yyreduce -- do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     '$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
  case 2: /* program: interface  */
#line 1978 "parser.y"
                            {
                   if (!classes) classes = NewHash();
		   Setattr((yyvsp[0].node),"classes",classes); 
		   Setattr((yyvsp[0].node),"name",ModuleName);
		   
		   if ((!module_node) && ModuleName) {
		     module_node = new_node("module");
		     Setattr(module_node,"name",ModuleName);
		   }
		   Setattr((yyvsp[0].node),"module",module_node);
	           top = (yyvsp[0].node);
               }
#line 5520 "parser.c"
    break;

  case 3: /* program: PARSETYPE parm END  */
#line 1990 "parser.y"
                                    {
                 top = Copy(Getattr((yyvsp[-1].p),"type"));
		 Delete((yyvsp[-1].p));
               }
#line 5529 "parser.c"
    break;

  case 4: /* program: PARSETYPE error  */
#line 1994 "parser.y"
                                 {
                 top = 0;
               }
#line 5537 "parser.c"
    break;

  case 5: /* program: PARSEPARM parm END  */
#line 1997 "parser.y"
                                    {
                 top = (yyvsp[-1].p);
               }
#line 5545 "parser.c"
    break;

  case 6: /* program: PARSEPARM error  */
#line 2000 "parser.y"
                                 {
                 top = 0;
               }
#line 5553 "parser.c"
    break;

  case 7: /* program: PARSEPARMS LPAREN parms RPAREN END  */
#line 2003 "parser.y"
                                                    {
                 top = (yyvsp[-2].pl);
               }
#line 5561 "parser.c"
    break;

  case 8: /* program: PARSEPARMS error  */
#line 2006 "parser.y"
                                  {
                 top = 0;
               }
#line 5569 "parser.c"
    break;

  case 9: /* interface: interface declaration  */
#line 2011 "parser.y"
                                           {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   if (currentDeclComment != NULL) {
		     set_comment((yyvsp[0].node), currentDeclComment);
		     currentDeclComment = NULL;
                   }                                      
                   appendChild((yyvsp[-1].node),(yyvsp[0].node));
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5583 "parser.c"
    break;

  case 10: /* interface: interface DOXYGENSTRING  */
#line 2020 "parser.y"
                                             {
		   Delete(currentDeclComment);
                   currentDeclComment = (yyvsp[0].str); 
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5593 "parser.c"
    break;

  case 11: /* interface: interface DOXYGENPOSTSTRING  */
#line 2025 "parser.y"
                                                 {
                   Node *node = lastChild((yyvsp[-1].node));
                   if (node) {
                     set_comment(node, (yyvsp[0].str));
		   } else {
		     Delete((yyvsp[0].str));
		   }
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5607 "parser.c"
    break;

  case 12: /* interface: %empty  */
#line 2034 "parser.y"
                        {
                   (yyval.node) = new_node("top");
               }
#line 5615 "parser.c"
    break;

  case 16: /* declaration: SEMI  */
#line 2042 "parser.y"
                      { (yyval.node) = 0; }
#line 5621 "parser.c"
    break;

  case 17: /* declaration: error  */
#line 2043 "parser.y"
                       {
		  if (cparse_unknown_directive) {
		      Swig_error(cparse_file, cparse_line, "Unknown directive '%s'.\n", cparse_unknown_directive);
		  } else {
		      Swig_error(cparse_file, cparse_line, "Syntax error in input(1).\n");
		  }
		  Exit(EXIT_FAILURE);
               }
#line 5634 "parser.c"
    break;

  case 18: /* declaration: c_constructor_decl  */
#line 2052 "parser.y"
                                    { 
                  if ((yyval.node)) {
   		      add_symbols((yyval.node));
                  }
                  (yyval.node) = (yyvsp[0].node); 
	       }
#line 5645 "parser.c"
    break;

  case 19: /* declaration: error CONVERSIONOPERATOR  */
#line 2068 "parser.y"
                                          {
                  (yyval.node) = 0;
		  Delete((yyvsp[0].str));
                  skip_decl();
               }
#line 5655 "parser.c"
    break;

  case 39: /* $@1: %empty  */
#line 2104 "parser.y"
                                                             {
               Node *cls;
	       String *clsname;
	       extendmode = 1;
	       cplus_mode = CPLUS_PUBLIC;
	       if (!classes) classes = NewHash();
	       if (!classes_typedefs) classes_typedefs = NewHash();
	       clsname = make_class_name((yyvsp[-1].str));
	       cls = Getattr(classes,clsname);
	       if (!cls) {
	         cls = Getattr(classes_typedefs, clsname);
		 if (!cls) {
		   /* No previous definition. Create a new scope */
		   Node *am = Getattr(Swig_extend_hash(),clsname);
		   if (!am) {
		     Swig_symbol_newscope();
		     Swig_symbol_setscopename((yyvsp[-1].str));
		     prev_symtab = 0;
		   } else {
		     prev_symtab = Swig_symbol_setscope(Getattr(am,"symtab"));
		   }
		   current_class = 0;
		 } else {
		   /* Previous typedef class definition.  Use its symbol table.
		      Deprecated, just the real name should be used. 
		      Note that %extend before the class typedef never worked, only %extend after the class typedef. */
		   prev_symtab = Swig_symbol_setscope(Getattr(cls, "symtab"));
		   current_class = cls;
		   SWIG_WARN_NODE_BEGIN(cls);
		   Swig_warning(WARN_PARSE_EXTEND_NAME, cparse_file, cparse_line, "Deprecated %%extend name used - the %s name '%s' should be used instead of the typedef name '%s'.\n", Getattr(cls, "kind"), SwigType_namestr(Getattr(cls, "name")), (yyvsp[-1].str));
		   SWIG_WARN_NODE_END(cls);
		 }
	       } else {
		 /* Previous class definition.  Use its symbol table */
		 prev_symtab = Swig_symbol_setscope(Getattr(cls,"symtab"));
		 current_class = cls;
	       }
	       Classprefix = NewString((yyvsp[-1].str));
	       Namespaceprefix= Swig_symbol_qualifiedscopename(0);
	       Delete(clsname);
	     }
#line 5701 "parser.c"
    break;

  case 40: /* extend_directive: EXTEND options classkeyopt idcolon LBRACE $@1 cpp_members RBRACE  */
#line 2144 "parser.y"
                                  {
               String *clsname;
	       extendmode = 0;
               (yyval.node) = new_node("extend");
	       Setattr((yyval.node),"symtab",Swig_symbol_popscope());
	       if (prev_symtab) {
		 Swig_symbol_setscope(prev_symtab);
	       }
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
               clsname = make_class_name((yyvsp[-4].str));
	       Setattr((yyval.node),"name",clsname);

	       mark_nodes_as_extend((yyvsp[-1].node));
	       if (current_class) {
		 /* We add the extension to the previously defined class */
		 appendChild((yyval.node), (yyvsp[-1].node));
		 appendChild(current_class,(yyval.node));
	       } else {
		 /* We store the extensions in the extensions hash */
		 Node *am = Getattr(Swig_extend_hash(),clsname);
		 if (am) {
		   /* Append the members to the previous extend methods */
		   appendChild(am, (yyvsp[-1].node));
		 } else {
		   appendChild((yyval.node), (yyvsp[-1].node));
		   Setattr(Swig_extend_hash(),clsname,(yyval.node));
		 }
	       }
	       current_class = 0;
	       Delete(Classprefix);
	       Delete(clsname);
	       Classprefix = 0;
	       prev_symtab = 0;
	       (yyval.node) = 0;

	     }
#line 5742 "parser.c"
    break;

  case 41: /* apply_directive: APPLY typemap_parm LBRACE tm_list RBRACE  */
#line 2186 "parser.y"
                                                           {
                    (yyval.node) = new_node("apply");
                    Setattr((yyval.node),"pattern",Getattr((yyvsp[-3].p),"pattern"));
		    appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 5752 "parser.c"
    break;

  case 42: /* clear_directive: CLEAR tm_list SEMI  */
#line 2196 "parser.y"
                                     {
		 (yyval.node) = new_node("clear");
		 appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 5761 "parser.c"
    break;

  case 43: /* constant_directive: CONSTANT identifier EQUAL definetype SEMI  */
#line 2210 "parser.y"
                                                                {
		 SwigType *type = NewSwigType((yyvsp[-1].dtype).type);
		 if (Len(type) > 0) {
		   (yyval.node) = new_node("constant");
		   Setattr((yyval.node), "name", (yyvsp[-3].id));
		   Setattr((yyval.node), "type", type);
		   Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		   if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		   if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		   Setattr((yyval.node), "storage", "%constant");
		   SetFlag((yyval.node), "feature:immutable");
		   add_symbols((yyval.node));
		   Delete(type);
		 } else {
		   Swig_warning(WARN_PARSE_UNSUPPORTED_VALUE, cparse_file, cparse_line, "Unsupported constant value (ignored)\n");
		   (yyval.node) = 0;
		 }
	       }
#line 5784 "parser.c"
    break;

  case 44: /* constant_directive: CONSTANT type declarator def_args SEMI  */
#line 2228 "parser.y"
                                                        {
		 SwigType_push((yyvsp[-3].type), (yyvsp[-2].decl).type);
		 /* Sneaky callback function trick */
		 if (SwigType_isfunction((yyvsp[-3].type))) {
		   SwigType_add_pointer((yyvsp[-3].type));
		 }
		 (yyval.node) = new_node("constant");
		 Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
		 Setattr((yyval.node), "type", (yyvsp[-3].type));
		 Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node), "storage", "%constant");
		 SetFlag((yyval.node), "feature:immutable");
		 add_symbols((yyval.node));
               }
#line 5805 "parser.c"
    break;

  case 45: /* constant_directive: CONSTANT type direct_declarator LPAREN parms RPAREN cv_ref_qualifier def_args SEMI  */
#line 2246 "parser.y"
                                                                                                    {
		 SwigType_add_function((yyvsp[-7].type), (yyvsp[-4].pl));
		 SwigType_push((yyvsp[-7].type), (yyvsp[-2].dtype).qualifier);
		 SwigType_push((yyvsp[-7].type), (yyvsp[-6].decl).type);
		 /* Sneaky callback function trick */
		 if (SwigType_isfunction((yyvsp[-7].type))) {
		   SwigType_add_pointer((yyvsp[-7].type));
		 }
		 (yyval.node) = new_node("constant");
		 Setattr((yyval.node), "name", (yyvsp[-6].decl).id);
		 Setattr((yyval.node), "type", (yyvsp[-7].type));
		 Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node), "storage", "%constant");
		 SetFlag((yyval.node), "feature:immutable");
		 add_symbols((yyval.node));
	       }
#line 5828 "parser.c"
    break;

  case 46: /* constant_directive: CONSTANT error SEMI  */
#line 2264 "parser.y"
                                     {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 (yyval.node) = 0;
	       }
#line 5837 "parser.c"
    break;

  case 47: /* constant_directive: CONSTANT error END  */
#line 2268 "parser.y"
                                    {
		 Swig_error(cparse_file,cparse_line,"Missing semicolon (';') after %%constant.\n");
		 Exit(EXIT_FAILURE);
	       }
#line 5846 "parser.c"
    break;

  case 48: /* echo_directive: ECHO HBLOCK  */
#line 2279 "parser.y"
                             {
		 char temp[64];
		 Replace((yyvsp[0].str),"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace((yyvsp[0].str),"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
                 (yyval.node) = 0;
	       }
#line 5860 "parser.c"
    break;

  case 49: /* echo_directive: ECHO string  */
#line 2288 "parser.y"
                             {
		 char temp[64];
		 String *s = (yyvsp[0].str);
		 Replace(s,"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace(s,"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", s);
		 Delete(s);
                 (yyval.node) = 0;
               }
#line 5875 "parser.c"
    break;

  case 50: /* stringtype: string LBRACE parm RBRACE  */
#line 2301 "parser.y"
                                          {		 
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[-3].str));
		 Setattr((yyval.node),"type",Getattr((yyvsp[-1].p),"type"));
               }
#line 5885 "parser.c"
    break;

  case 51: /* fname: string  */
#line 2308 "parser.y"
                       {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[0].str));
              }
#line 5894 "parser.c"
    break;

  case 53: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN HBLOCK  */
#line 2323 "parser.y"
                                                                     {
                   Hash *p = (yyvsp[-2].node);
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-4].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-4].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Setattr((yyval.node),"code",(yyvsp[0].str));
		   Delete((yyvsp[0].str));
                 }
#line 5909 "parser.c"
    break;

  case 54: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN LBRACE  */
#line 2333 "parser.y"
                                                                    {
		   Hash *p = (yyvsp[-2].node);
		   String *code;
		   if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-4].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-4].node),"type"));
		   Setattr((yyval.node),"section",Getattr(p,"name"));
		   Setattr((yyval.node),"kwargs",nextSibling(p));
		   Delitem(scanner_ccode,0);
		   Delitem(scanner_ccode,DOH_END);
		   code = Copy(scanner_ccode);
		   Setattr((yyval.node),"code",code);
		   Delete(code);
                 }
#line 5929 "parser.c"
    break;

  case 55: /* fragment_directive: FRAGMENT LPAREN fname RPAREN SEMI  */
#line 2348 "parser.y"
                                                     {
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-2].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-2].node),"type"));
		   Setattr((yyval.node),"emitonly","1");
		 }
#line 5940 "parser.c"
    break;

  case 56: /* @2: %empty  */
#line 2361 "parser.y"
                                                             {
		     (yyval.loc).filename = Copy(cparse_file);
		     (yyval.loc).line = cparse_line;
		     scanner_set_location((yyvsp[-1].str),1);
                     if ((yyvsp[-2].node)) { 
		       String *maininput = Getattr((yyvsp[-2].node), "maininput");
		       if (maininput)
		         scanner_set_main_input_file(NewString(maininput));
		     }
               }
#line 5955 "parser.c"
    break;

  case 57: /* include_directive: includetype options string BEGINFILE @2 interface ENDOFFILE  */
#line 2370 "parser.y"
                                          {
                     String *mname = 0;
                     (yyval.node) = (yyvsp[-1].node);
		     scanner_set_location((yyvsp[-2].loc).filename, (yyvsp[-2].loc).line + 1);
		     Delete((yyvsp[-2].loc).filename);
		     switch ((yyvsp[-6].includetype)) {
		       case INCLUDE_INCLUDE:
			 set_nodeType((yyval.node), "include");
			 break;
		       case INCLUDE_IMPORT:
			 mname = (yyvsp[-5].node) ? Getattr((yyvsp[-5].node), "module") : 0;
			 set_nodeType((yyval.node), "import");
			 if (import_mode) --import_mode;
			 break;
		     }
		     
		     Setattr((yyval.node),"name",(yyvsp[-4].str));
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
                           Setattr(mnode,"options",(yyvsp[-5].node));
			   appendChild(nint,mnode);
			   Delete(mnode);
			   appendChild(nint,firstChild((yyval.node)));
			   (yyval.node) = nint;
			   Setattr((yyval.node),"module",mname);
			 }
		     }
		     Setattr((yyval.node),"options",(yyvsp[-5].node));
               }
#line 6010 "parser.c"
    break;

  case 58: /* includetype: INCLUDE  */
#line 2422 "parser.y"
                         { (yyval.includetype) = INCLUDE_INCLUDE; }
#line 6016 "parser.c"
    break;

  case 59: /* includetype: IMPORT  */
#line 2423 "parser.y"
                         { (yyval.includetype) = INCLUDE_IMPORT; ++import_mode;}
#line 6022 "parser.c"
    break;

  case 60: /* inline_directive: INLINE HBLOCK  */
#line 2430 "parser.y"
                                 {
                 String *cpps;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		   (yyval.node) = 0;
		 } else {
		   (yyval.node) = new_node("insert");
		   Setattr((yyval.node),"code",(yyvsp[0].str));
		   /* Need to run through the preprocessor */
		   Seek((yyvsp[0].str),0,SEEK_SET);
		   Setline((yyvsp[0].str),cparse_start_line);
		   Setfile((yyvsp[0].str),cparse_file);
		   cpps = Preprocessor_parse((yyvsp[0].str));
		   scanner_start_inline(cpps, cparse_start_line);
		   Delete(cpps);
		 }
		 Delete((yyvsp[0].str));
	       }
#line 6045 "parser.c"
    break;

  case 61: /* inline_directive: INLINE LBRACE  */
#line 2448 "parser.y"
                               {
                 String *cpps;
		 int start_line = cparse_line;
		 if (Namespaceprefix) {
		   Swig_error(cparse_file, cparse_start_line, "%%inline directive inside a namespace is disallowed.\n");
		 }
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 if (Namespaceprefix) {
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
		   scanner_start_inline(cpps, start_line);
		   Delete(cpps);
		 }
               }
#line 6072 "parser.c"
    break;

  case 62: /* insert_directive: HBLOCK  */
#line 2482 "parser.y"
                          {
                 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 6082 "parser.c"
    break;

  case 63: /* insert_directive: INSERT LPAREN idstring RPAREN string  */
#line 2487 "parser.y"
                                                      {
		 String *code = NewStringEmpty();
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Setattr((yyval.node),"code",code);
		 if (Swig_insert_file((yyvsp[0].str),code) < 0) {
		   Swig_error(cparse_file, cparse_line, "Couldn't find '%s'.\n", (yyvsp[0].str));
		   (yyval.node) = 0;
		 } 
               }
#line 6097 "parser.c"
    break;

  case 64: /* insert_directive: INSERT LPAREN idstring RPAREN HBLOCK  */
#line 2497 "parser.y"
                                                      {
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 6108 "parser.c"
    break;

  case 65: /* insert_directive: INSERT LPAREN idstring RPAREN LBRACE  */
#line 2503 "parser.y"
                                                      {
		 String *code;
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Delitem(scanner_ccode,0);
		 Delitem(scanner_ccode,DOH_END);
		 code = Copy(scanner_ccode);
		 Setattr((yyval.node),"code", code);
		 Delete(code);
	       }
#line 6124 "parser.c"
    break;

  case 66: /* module_directive: MODULE options idstring  */
#line 2521 "parser.y"
                                          {
                 (yyval.node) = new_node("module");
		 if ((yyvsp[-1].node)) {
		   Setattr((yyval.node),"options",(yyvsp[-1].node));
		   if (Getattr((yyvsp[-1].node),"directors")) {
		     Wrapper_director_mode_set(1);
		     if (!cparse_cplusplus) {
		       Swig_error(cparse_file, cparse_line, "Directors are not supported for C code and require the -c++ option\n");
		     }
		   } 
		   if (Getattr((yyvsp[-1].node),"dirprot")) {
		     Wrapper_director_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[-1].node),"allprotected")) {
		     Wrapper_all_protected_mode_set(1);
		   } 
		   if (Getattr((yyvsp[-1].node),"templatereduce")) {
		     template_reduce = 1;
		   }
		   if (Getattr((yyvsp[-1].node),"notemplatereduce")) {
		     template_reduce = 0;
		   }
		 }
		 if (!ModuleName) ModuleName = NewString((yyvsp[0].id));
		 if (!import_mode) {
		   /* first module included, we apply global
		      ModuleName, which can be modify by -module */
		   String *mname = Copy(ModuleName);
		   Setattr((yyval.node),"name",mname);
		   Delete(mname);
		 } else { 
		   /* import mode, we just pass the idstring */
		   Setattr((yyval.node),"name",(yyvsp[0].id));   
		 }		 
		 if (!module_node) module_node = (yyval.node);
	       }
#line 6165 "parser.c"
    break;

  case 67: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class identifier SEMI  */
#line 2564 "parser.y"
                                                                                                  {
                 (yyval.node) = new_node("native");
		 Setattr((yyval.node),"name",(yyvsp[-4].id));
		 Setattr((yyval.node),"wrap:name",(yyvsp[-1].id));
		 Delete((yyvsp[-2].str));
	         add_symbols((yyval.node));
	       }
#line 6177 "parser.c"
    break;

  case 68: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class type declarator SEMI  */
#line 2571 "parser.y"
                                                                                    {
		 if (!SwigType_isfunction((yyvsp[-1].decl).type)) {
		   Swig_error(cparse_file,cparse_line,"%%native declaration '%s' is not a function.\n", (yyvsp[-1].decl).id);
		   (yyval.node) = 0;
		 } else {
		     Delete(SwigType_pop_function((yyvsp[-1].decl).type));
		     /* Need check for function here */
		     SwigType_push((yyvsp[-2].type),(yyvsp[-1].decl).type);
		     (yyval.node) = new_node("native");
	             Setattr((yyval.node),"name",(yyvsp[-5].id));
		     Setattr((yyval.node),"wrap:name",(yyvsp[-1].decl).id);
		     Setattr((yyval.node),"type",(yyvsp[-2].type));
		     Setattr((yyval.node),"parms",(yyvsp[-1].decl).parms);
		     Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		 }
		 Delete((yyvsp[-3].str));
	         add_symbols((yyval.node));
	       }
#line 6200 "parser.c"
    break;

  case 69: /* pragma_directive: PRAGMA pragma_lang identifier EQUAL pragma_arg  */
#line 2598 "parser.y"
                                                                  {
                 (yyval.node) = new_node("pragma");
		 Setattr((yyval.node),"lang",(yyvsp[-3].id));
		 Setattr((yyval.node),"name",(yyvsp[-2].id));
		 Setattr((yyval.node),"value",(yyvsp[0].str));
	       }
#line 6211 "parser.c"
    break;

  case 70: /* pragma_directive: PRAGMA pragma_lang identifier  */
#line 2604 "parser.y"
                                              {
		(yyval.node) = new_node("pragma");
		Setattr((yyval.node),"lang",(yyvsp[-1].id));
		Setattr((yyval.node),"name",(yyvsp[0].id));
	      }
#line 6221 "parser.c"
    break;

  case 73: /* pragma_lang: LPAREN identifier RPAREN  */
#line 2615 "parser.y"
                                         { (yyval.id) = (yyvsp[-1].id); }
#line 6227 "parser.c"
    break;

  case 74: /* pragma_lang: %empty  */
#line 2616 "parser.y"
                       { (yyval.id) = "swig"; }
#line 6233 "parser.c"
    break;

  case 75: /* rename_directive: rename_namewarn declarator idstring SEMI  */
#line 2623 "parser.y"
                                                            {
                SwigType *t = (yyvsp[-2].decl).type;
		Hash *kws = NewHash();
		String *fixname;
		fixname = feature_identifier_fix((yyvsp[-2].decl).id);
		Setattr(kws,"name",(yyvsp[-1].id));
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[-3].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[-3].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[-3].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[-2].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[-3].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[-2].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6284 "parser.c"
    break;

  case 76: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN declarator cpp_const SEMI  */
#line 2669 "parser.y"
                                                                               {
		String *fixname;
		Hash *kws = (yyvsp[-4].node);
		SwigType *t = (yyvsp[-2].decl).type;
		fixname = feature_identifier_fix((yyvsp[-2].decl).id);
		if (!Len(t)) t = 0;
		/* Special declarator check */
		if (t) {
		  if ((yyvsp[-1].dtype).qualifier) SwigType_push(t,(yyvsp[-1].dtype).qualifier);
		  if (SwigType_isfunction(t)) {
		    SwigType *decl = SwigType_pop_function(t);
		    if (SwigType_ispointer(t)) {
		      String *nname = NewStringf("*%s",fixname);
		      if ((yyvsp[-6].intvalue)) {
			Swig_name_rename_add(Namespaceprefix, nname,decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,nname,decl,kws);
		      }
		      Delete(nname);
		    } else {
		      if ((yyvsp[-6].intvalue)) {
			Swig_name_rename_add(Namespaceprefix,(fixname),decl,kws,(yyvsp[-2].decl).parms);
		      } else {
			Swig_name_namewarn_add(Namespaceprefix,(fixname),decl,kws);
		      }
		    }
		    Delete(decl);
		  } else if (SwigType_ispointer(t)) {
		    String *nname = NewStringf("*%s",fixname);
		    if ((yyvsp[-6].intvalue)) {
		      Swig_name_rename_add(Namespaceprefix,(nname),0,kws,(yyvsp[-2].decl).parms);
		    } else {
		      Swig_name_namewarn_add(Namespaceprefix,(nname),0,kws);
		    }
		    Delete(nname);
		  }
		} else {
		  if ((yyvsp[-6].intvalue)) {
		    Swig_name_rename_add(Namespaceprefix,(fixname),0,kws,(yyvsp[-2].decl).parms);
		  } else {
		    Swig_name_namewarn_add(Namespaceprefix,(fixname),0,kws);
		  }
		}
                (yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6335 "parser.c"
    break;

  case 77: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN string SEMI  */
#line 2715 "parser.y"
                                                                 {
		if ((yyvsp[-5].intvalue)) {
		  Swig_name_rename_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node),0);
		} else {
		  Swig_name_namewarn_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node));
		}
		(yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6349 "parser.c"
    break;

  case 78: /* rename_namewarn: RENAME  */
#line 2726 "parser.y"
                         {
		    (yyval.intvalue) = 1;
                }
#line 6357 "parser.c"
    break;

  case 79: /* rename_namewarn: NAMEWARN  */
#line 2729 "parser.y"
                           {
                    (yyval.intvalue) = 0;
                }
#line 6365 "parser.c"
    break;

  case 80: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN declarator cpp_const stringbracesemi  */
#line 2756 "parser.y"
                                                                                                 {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-5].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6376 "parser.c"
    break;

  case 81: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN declarator cpp_const SEMI  */
#line 2762 "parser.y"
                                                                                                      {
                    String *val = Len((yyvsp[-5].str)) ? (yyvsp[-5].str) : 0;
                    new_feature((yyvsp[-7].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6387 "parser.c"
    break;

  case 82: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN stringbracesemi  */
#line 2770 "parser.y"
                                                                            {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-3].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6398 "parser.c"
    break;

  case 83: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN SEMI  */
#line 2776 "parser.y"
                                                                                 {
                    String *val = Len((yyvsp[-3].str)) ? (yyvsp[-3].str) : 0;
                    new_feature((yyvsp[-5].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6409 "parser.c"
    break;

  case 85: /* stringbracesemi: SEMI  */
#line 2785 "parser.y"
                       { (yyval.str) = 0; }
#line 6415 "parser.c"
    break;

  case 86: /* stringbracesemi: PARMS LPAREN parms RPAREN SEMI  */
#line 2786 "parser.y"
                                                 { (yyval.str) = (yyvsp[-2].pl); }
#line 6421 "parser.c"
    break;

  case 87: /* featattr: COMMA idstring EQUAL stringnum featattr  */
#line 2789 "parser.y"
                                                              {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[-3].id));
		  Setattr((yyval.node),"value",(yyvsp[-1].str));
		  if ((yyvsp[0].node)) set_nextSibling((yyval.node), (yyvsp[0].node));
		}
#line 6432 "parser.c"
    break;

  case 88: /* featattr: %empty  */
#line 2795 "parser.y"
                         {
		  (yyval.node) = 0;
		}
#line 6440 "parser.c"
    break;

  case 89: /* varargs_directive: VARARGS LPAREN varargs_parms RPAREN declarator cpp_const SEMI  */
#line 2802 "parser.y"
                                                                                  {
                 Parm *val;
		 String *name;
		 SwigType *t;
		 if (Namespaceprefix) name = NewStringf("%s::%s", Namespaceprefix, (yyvsp[-2].decl).id);
		 else name = NewString((yyvsp[-2].decl).id);
		 val = (yyvsp[-4].pl);
		 if ((yyvsp[-2].decl).parms) {
		   Setmeta(val,"parms",(yyvsp[-2].decl).parms);
		 }
		 t = (yyvsp[-2].decl).type;
		 if (!Len(t)) t = 0;
		 if (t) {
		   if ((yyvsp[-1].dtype).qualifier) SwigType_push(t,(yyvsp[-1].dtype).qualifier);
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
              }
#line 6480 "parser.c"
    break;

  case 91: /* varargs_parms: NUM_INT COMMA parm  */
#line 2839 "parser.y"
                                     { 
		  int i;
		  int n;
		  Parm *p;
		  n = atoi(Char((yyvsp[-2].dtype).val));
		  if (n <= 0) {
		    Swig_error(cparse_file, cparse_line,"Argument count in %%varargs must be positive.\n");
		    (yyval.pl) = 0;
		  } else {
		    String *name = Getattr((yyvsp[0].p), "name");
		    (yyval.pl) = Copy((yyvsp[0].p));
		    if (name)
		      Setattr((yyval.pl), "name", NewStringf("%s%d", name, n));
		    for (i = 1; i < n; i++) {
		      p = Copy((yyvsp[0].p));
		      name = Getattr(p, "name");
		      if (name)
		        Setattr(p, "name", NewStringf("%s%d", name, n-i));
		      set_nextSibling(p,(yyval.pl));
		      Delete((yyval.pl));
		      (yyval.pl) = p;
		    }
		  }
                }
#line 6509 "parser.c"
    break;

  case 92: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list stringbrace  */
#line 2873 "parser.y"
                                                                            {
		   (yyval.node) = 0;
		   if ((yyvsp[-3].tmap).method) {
		     String *code = 0;
		     (yyval.node) = new_node("typemap");
		     Setattr((yyval.node),"method",(yyvsp[-3].tmap).method);
		     if ((yyvsp[-3].tmap).kwargs) {
		       ParmList *kw = (yyvsp[-3].tmap).kwargs;
                       code = remove_block(kw, (yyvsp[0].str));
		       Setattr((yyval.node),"kwargs", (yyvsp[-3].tmap).kwargs);
		     }
		     code = code ? code : NewString((yyvsp[0].str));
		     Setattr((yyval.node),"code", code);
		     Delete(code);
		     appendChild((yyval.node),(yyvsp[-1].p));
		     Delete((yyvsp[-3].tmap).kwargs);
		     Delete((yyvsp[-3].tmap).method);
		   }
	       }
#line 6533 "parser.c"
    break;

  case 93: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list SEMI  */
#line 2892 "parser.y"
                                                                 {
		 (yyval.node) = 0;
		 if ((yyvsp[-3].tmap).method) {
		   (yyval.node) = new_node("typemap");
		   Setattr((yyval.node),"method",(yyvsp[-3].tmap).method);
		   appendChild((yyval.node),(yyvsp[-1].p));
		   Delete((yyvsp[-3].tmap).method);
		 }
		 Delete((yyvsp[-3].tmap).kwargs);
	       }
#line 6548 "parser.c"
    break;

  case 94: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list EQUAL typemap_parm SEMI  */
#line 2902 "parser.y"
                                                                                    {
		   (yyval.node) = 0;
		   if ((yyvsp[-5].tmap).method) {
		     (yyval.node) = new_node("typemapcopy");
		     Setattr((yyval.node),"method",(yyvsp[-5].tmap).method);
		     Setattr((yyval.node),"pattern", Getattr((yyvsp[-1].p),"pattern"));
		     appendChild((yyval.node),(yyvsp[-3].p));
		     Delete((yyvsp[-5].tmap).method);
		   }
		   Delete((yyvsp[-5].tmap).kwargs);
	       }
#line 6564 "parser.c"
    break;

  case 95: /* typemap_type: kwargs  */
#line 2917 "parser.y"
                        {
		 String *name = Getattr((yyvsp[0].node), "name");
		 Hash *p = nextSibling((yyvsp[0].node));
		 (yyval.tmap).method = name;
		 (yyval.tmap).kwargs = p;
		 if (Getattr((yyvsp[0].node), "value")) {
		   Swig_error(cparse_file, cparse_line,
			      "%%typemap method shouldn't have a value specified.\n");
		 }
		 while (p) {
		   if (!Getattr(p, "value")) {
		     Swig_error(cparse_file, cparse_line,
				"%%typemap attribute '%s' is missing its value.  If this is specifying the target language, that's no longer supported: use #ifdef SWIG<LANG> instead.\n",
				Getattr(p, "name"));
		     /* Set to empty value to avoid segfaults later. */
		     Setattr(p, "value", NewStringEmpty());
		   }
		   p = nextSibling(p);
		 }
                }
#line 6589 "parser.c"
    break;

  case 96: /* tm_list: tm_list_builder  */
#line 2939 "parser.y"
                                 {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
	       }
#line 6597 "parser.c"
    break;

  case 97: /* tm_list_builder: typemap_parm  */
#line 2944 "parser.y"
                              {
                 (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6605 "parser.c"
    break;

  case 98: /* tm_list_builder: tm_list_builder COMMA typemap_parm  */
#line 2947 "parser.y"
                                                        {
		 // Build a linked list in the order specified, but avoiding
		 // a right recursion rule because "Right recursion uses up
		 // space on the Bison stack in proportion to the number of
		 // elements in the sequence".
		 set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		 (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		 (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6619 "parser.c"
    break;

  case 99: /* typemap_parm: type plain_declarator  */
#line 2958 "parser.y"
                                       {
                  Parm *parm;
		  SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		  (yyval.p) = new_node("typemapitem");
		  parm = NewParmWithoutFileLineInfo((yyvsp[-1].type),(yyvsp[0].decl).id);
		  Setattr((yyval.p),"pattern",parm);
		  Setattr((yyval.p),"parms", (yyvsp[0].decl).parms);
		  Delete(parm);
		  /*		  $$ = NewParmWithoutFileLineInfo($type,$plain_declarator.id);
				  Setattr($$,"parms",$plain_declarator.parms); */
                }
#line 6635 "parser.c"
    break;

  case 100: /* typemap_parm: LPAREN parms RPAREN  */
#line 2969 "parser.y"
                                     {
                  (yyval.p) = new_node("typemapitem");
		  Setattr((yyval.p),"pattern",(yyvsp[-1].pl));
		  /*		  Setattr($$,"multitype",$parms); */
               }
#line 6645 "parser.c"
    break;

  case 101: /* typemap_parm: LPAREN parms RPAREN LPAREN parms RPAREN  */
#line 2974 "parser.y"
                                                                      {
		 (yyval.p) = new_node("typemapitem");
		 Setattr((yyval.p),"pattern", (yyvsp[-4].pl));
		 /*                 Setattr($$,"multitype",$in); */
		 Setattr((yyval.p),"parms",(yyvsp[-1].pl));
               }
#line 6656 "parser.c"
    break;

  case 102: /* types_directive: TYPES LPAREN parms RPAREN stringbracesemi  */
#line 2987 "parser.y"
                                                            {
                   (yyval.node) = new_node("types");
		   Setattr((yyval.node),"parms",(yyvsp[-2].pl));
                   if ((yyvsp[0].str))
		     Setattr((yyval.node),"convcode",NewString((yyvsp[0].str)));
               }
#line 6667 "parser.c"
    break;

  case 103: /* template_directive: SWIGTEMPLATE LPAREN idstringopt RPAREN idcolonnt LESSTHAN valparms GREATERTHAN SEMI  */
#line 2999 "parser.y"
                                                                                                        {
                  Parm *p;
		  Node *n = 0;
		  Node *outer_class = currentOuterClass;
		  Symtab *tscope = 0;
		  String *symname = (yyvsp[-6].id) ? NewString((yyvsp[-6].id)) : 0;
		  int errored_flag = 0;
		  String *idcolonnt;

		  (yyval.node) = 0;

		  tscope = Swig_symbol_current();          /* Get the current scope */

		  /* If the class name is qualified, we need to create or lookup namespace entries */
		  idcolonnt = resolve_create_node_scope((yyvsp[-4].str), 0, &errored_flag);

		  if (!errored_flag) {
		    if (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0)
		      outer_class = nscope_inner;

		    /*
		      We use the new namespace entry 'nscope' only to
		      emit the template node. The template parameters are
		      resolved in the current 'tscope'.

		      This is closer to the C++ (typedef) behavior.
		    */
		    n = Swig_cparse_template_locate(idcolonnt, (yyvsp[-2].p), symname, tscope);
		  }

		  /* Patch the argument types to respect namespaces */
		  p = (yyvsp[-2].p);
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
                    Node *linkliststart = 0;
                    while (nn) {
                      Node *templnode = 0;
                      if (GetFlag(nn, "instantiate")) {
			Delattr(nn, "instantiate");
			{
			  int nnisclass = (Strcmp(Getattr(nn, "templatetype"), "class") == 0); /* class template not a classforward nor function template */
			  Parm *tparms = Getattr(nn, "templateparms");
			  int specialized = !tparms; /* fully specialized (an explicit specialization) */
			  String *tname = Copy(idcolonnt);
			  Node *primary_template = Swig_symbol_clookup(tname, 0);

			  /* Expand the template */
			  ParmList *temparms = Swig_cparse_template_parms_expand((yyvsp[-2].p), primary_template, nn);

                          templnode = copy_node(nn);
			  update_nested_classes(templnode); /* update classes nested within template */
                          /* We need to set the node name based on name used to instantiate */
                          Setattr(templnode,"name",tname);
			  Delete(tname);
                          if (!specialized) {
                            Delattr(templnode,"sym:typename");
                          } else {
                            Setattr(templnode,"sym:typename","1");
                          }
			  /* for now, nested %template is allowed only in the same scope as the template declaration */
                          if (symname && !(nnisclass && ((outer_class && (outer_class != Getattr(nn, "nested:outer")))
			    ||(extendmode && current_class && (current_class != Getattr(nn, "nested:outer")))))) {
			    /*
			       Comment this out for 1.3.28. We need to
			       re-enable it later but first we need to
			       move %ignore from using %rename to use
			       %feature(ignore).

			       String *symname = Swig_name_make(templnode, 0, symname, 0, 0);
			    */
                            Swig_cparse_template_expand(templnode, symname, temparms, tscope);
                            Setattr(templnode, "sym:name", symname);
                          } else {
                            static int cnt = 0;
                            String *nname = NewStringf("__dummy_%d__", cnt++);
                            Swig_cparse_template_expand(templnode,nname,temparms,tscope);
                            Setattr(templnode,"sym:name",nname);
                            SetFlag(templnode,"hidden");
			    Delete(nname);
                            Setattr(templnode,"feature:onlychildren", "typemap,typemapitem,typemapcopy,typedef,types,fragment,apply");
			    if (symname) {
			      Swig_warning(WARN_PARSE_NESTED_TEMPLATE, cparse_file, cparse_line, "Named nested template instantiations not supported. Processing as if no name was given to %%template().\n");
			    }
                          }
                          Delattr(templnode,"templatetype");
                          Setattr(templnode,"template",nn);
                          Setfile(templnode,cparse_file);
                          Setline(templnode,cparse_line);
                          Delete(temparms);
			  if (outer_class && nnisclass) {
			    SetFlag(templnode, "nested");
			    Setattr(templnode, "nested:outer", outer_class);
			  }
                          add_symbols_copy(templnode);

			  if (Equal(nodeType(templnode), "classforward") && !(GetFlag(templnode, "feature:ignore") || GetFlag(templnode, "hidden"))) {
			    SWIG_WARN_NODE_BEGIN(templnode);
			    /* A full template class definition is required in order to wrap a template class as a proxy class so this %template is ineffective. */
			    if (GetFlag(templnode, "nested:forward"))
			      Swig_warning(WARN_PARSE_TEMPLATE_NESTED, cparse_file, cparse_line, "Unsupported template nested class '%s' cannot be used to instantiate a full template class with name '%s'.\n", Swig_name_decl(templnode), Getattr(templnode, "sym:name"));
			    else
			      Swig_warning(WARN_PARSE_TEMPLATE_FORWARD, cparse_file, cparse_line, "Template forward class '%s' cannot be used to instantiate a full template class with name '%s'.\n", Swig_name_decl(templnode), Getattr(templnode, "sym:name"));
			    SWIG_WARN_NODE_END(templnode);
			  }

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
                                List *bases = Swig_make_inherit_list(Getattr(templnode,"name"),baselist, Namespaceprefix);
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

                            /* Merge in %extend methods for this class.
			       This only merges methods within %extend for a template specialized class such as
			         template<typename T> class K {}; %extend K<int> { ... }
			       The copy_node() call above has already added in the generic %extend methods such as
			         template<typename T> class K {}; %extend K { ... } */

			    /* !!! This may be broken.  We may have to add the
			       %extend methods at the beginning of the class */
                            {
                              String *stmp = 0;
                              String *clsname;
                              Node *am;
                              if (Namespaceprefix) {
                                clsname = stmp = NewStringf("%s::%s", Namespaceprefix, Getattr(templnode,"name"));
                              } else {
                                clsname = Getattr(templnode,"name");
                              }
                              am = Getattr(Swig_extend_hash(),clsname);
                              if (am) {
                                Symtab *st = Swig_symbol_current();
                                Swig_symbol_setscope(Getattr(templnode,"symtab"));
                                /*			    Printf(stdout,"%s: %s %p %p\n", Getattr(templnode,"name"), clsname, Swig_symbol_current(), Getattr(templnode,"symtab")); */
                                Swig_extend_merge(templnode,am);
                                Swig_symbol_setscope(st);
				Swig_extend_append_previous(templnode,am);
                                Delattr(Swig_extend_hash(),clsname);
                              }
			      if (stmp) Delete(stmp);
                            }

                            /* Add to classes hash */
			    if (!classes)
			      classes = NewHash();

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

                        /* all the overloaded function templates are added into a linked list */
                        if (!linkliststart)
                          linkliststart = templnode;
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
                      nn = Getattr(nn,"sym:nextSibling"); /* repeat for overloaded function templates. If a class template there will never be a sibling. */
                    }
                    update_defaultargs(linkliststart);
                    update_abstracts(linkliststart);
		  }
	          Swig_symbol_setscope(tscope);
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  Delete(symname);
                }
#line 6910 "parser.c"
    break;

  case 104: /* warn_directive: WARN string  */
#line 3243 "parser.y"
                             {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", (yyvsp[0].str));
		  (yyval.node) = 0;
               }
#line 6919 "parser.c"
    break;

  case 105: /* c_declaration: c_decl  */
#line 3253 "parser.y"
                         {
                    (yyval.node) = (yyvsp[0].node); 
                    if ((yyval.node)) {
   		      add_symbols((yyval.node));
                      default_arguments((yyval.node));
   	            }
                }
#line 6931 "parser.c"
    break;

  case 108: /* $@3: %empty  */
#line 3265 "parser.y"
                                       {
		  if (Strcmp((yyvsp[-1].str),"C") == 0) {
		    cparse_externc = 1;
		  }
		}
#line 6941 "parser.c"
    break;

  case 109: /* c_declaration: EXTERN string LBRACE $@3 interface RBRACE  */
#line 3269 "parser.y"
                                   {
		  cparse_externc = 0;
		  if (Strcmp((yyvsp[-4].str),"C") == 0) {
		    Node *n = firstChild((yyvsp[-1].node));
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[-4].str));
		    appendChild((yyval.node),n);
		    while (n) {
		      String *s = Getattr(n, "storage");
		      if (s) {
			if (Strstr(s, "thread_local")) {
			  Insert(s,0,"externc ");
			} else if (!Equal(s, "typedef")) {
			  Setattr(n,"storage","externc");
			}
		      } else {
			Setattr(n,"storage","externc");
		      }
		      n = nextSibling(n);
		    }
		  } else {
		    if (!Equal((yyvsp[-4].str),"C++")) {
		      Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[-4].str));
		    }
		    (yyval.node) = new_node("extern");
		    Setattr((yyval.node),"name",(yyvsp[-4].str));
		    appendChild((yyval.node),firstChild((yyvsp[-1].node)));
		  }
                }
#line 6975 "parser.c"
    break;

  case 110: /* c_declaration: cpp_lambda_decl  */
#line 3298 "parser.y"
                                  {
		  (yyval.node) = (yyvsp[0].node);
		  SWIG_WARN_NODE_BEGIN((yyval.node));
		  Swig_warning(WARN_CPP11_LAMBDA, cparse_file, cparse_line, "Lambda expressions and closures are not fully supported yet.\n");
		  SWIG_WARN_NODE_END((yyval.node));
		}
#line 6986 "parser.c"
    break;

  case 111: /* c_declaration: USING idcolon EQUAL type plain_declarator SEMI  */
#line 3304 "parser.y"
                                                                 {
		  /* Convert using statement to a typedef statement */
		  (yyval.node) = new_node("cdecl");
		  Setattr((yyval.node),"type",(yyvsp[-2].type));
		  Setattr((yyval.node),"storage","typedef");
		  Setattr((yyval.node),"name",(yyvsp[-4].str));
		  Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		  SetFlag((yyval.node),"typealias");
		  add_symbols((yyval.node));
		}
#line 7001 "parser.c"
    break;

  case 112: /* c_declaration: TEMPLATE LESSTHAN template_parms GREATERTHAN USING idcolon EQUAL type plain_declarator SEMI  */
#line 3314 "parser.y"
                                                                                                              {
		  /* Convert alias template to a "template" typedef statement */
		  (yyval.node) = new_node("template");
		  Setattr((yyval.node),"type",(yyvsp[-2].type));
		  Setattr((yyval.node),"storage","typedef");
		  Setattr((yyval.node),"name",(yyvsp[-4].str));
		  Setattr((yyval.node),"decl",(yyvsp[-1].decl).type);
		  Setattr((yyval.node),"templateparms",(yyvsp[-7].tparms));
		  Setattr((yyval.node),"templatetype","cdecl");
		  SetFlag((yyval.node),"aliastemplate");
		  add_symbols((yyval.node));
		}
#line 7018 "parser.c"
    break;

  case 114: /* c_decl: storage_class type declarator cpp_const initializer c_decl_tail  */
#line 3333 "parser.y"
                                                                          {
	      String *decl = (yyvsp[-3].decl).type;
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-2].dtype).qualifier)
	        decl = add_qualifier_to_declarator((yyvsp[-3].decl).type, (yyvsp[-2].dtype).qualifier);
	      Setattr((yyval.node),"refqualifier",(yyvsp[-2].dtype).refqualifier);
	      Setattr((yyval.node),"type",(yyvsp[-4].type));
	      Setattr((yyval.node),"storage",(yyvsp[-5].str));
	      Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
	      Setattr((yyval.node),"decl",decl);
	      Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
	      Setattr((yyval.node),"value",(yyvsp[-1].dtype).val);
	      if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
	      if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
	      Setattr((yyval.node),"throws",(yyvsp[-2].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[-2].dtype).throwf);
	      Setattr((yyval.node),"noexcept",(yyvsp[-2].dtype).nexcept);
	      Setattr((yyval.node),"final",(yyvsp[-2].dtype).final);
	      if ((yyvsp[-1].dtype).val && (yyvsp[-1].dtype).type) {
		/* store initializer type as it might be different to the declared type */
		SwigType *valuetype = NewSwigType((yyvsp[-1].dtype).type);
		if (Len(valuetype) > 0) {
		  Setattr((yyval.node), "valuetype", valuetype);
		} else {
		  /* If we can't determine the initializer type use the declared type. */
		  Setattr((yyval.node), "valuetype", (yyvsp[-4].type));
		}
		Delete(valuetype);
	      }
	      if (!(yyvsp[0].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[0].node);
		/* Inherit attributes */
		while (n) {
		  String *type = Copy((yyvsp[-4].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[-5].str));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }
	      if ((yyvsp[-1].dtype).bitfield) {
		Setattr((yyval.node),"bitfield", (yyvsp[-1].dtype).bitfield);
	      }

	      if ((yyvsp[-3].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-3].decl).id);
		if (p) {
		  /* This is a special case. If the scope name of the declaration exactly
		     matches that of the declaration, then we will allow it. Otherwise, delete. */
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-3].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node), (yyvsp[0].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[0].node);
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-3].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[0].node);
		} else {
		  set_nextSibling((yyval.node), (yyvsp[0].node));
		}
	      } else {
		Swig_error(cparse_file, cparse_line, "Missing symbol name for global declaration\n");
		(yyval.node) = 0;
	      }

	      if ((yyvsp[-2].dtype).qualifier && (yyvsp[-5].str) && Strstr((yyvsp[-5].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-5].str));
           }
#line 7106 "parser.c"
    break;

  case 115: /* c_decl: storage_class type declarator cpp_const EQUAL error SEMI  */
#line 3416 "parser.y"
                                                                      {
	      String *decl = (yyvsp[-4].decl).type;
	      (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-3].dtype).qualifier)
	        decl = add_qualifier_to_declarator((yyvsp[-4].decl).type, (yyvsp[-3].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-3].dtype).refqualifier);
	      Setattr((yyval.node), "type", (yyvsp[-5].type));
	      Setattr((yyval.node), "storage", (yyvsp[-6].str));
	      Setattr((yyval.node), "name", (yyvsp[-4].decl).id);
	      Setattr((yyval.node), "decl", decl);
	      Setattr((yyval.node), "parms", (yyvsp[-4].decl).parms);

	      /* Set dummy value to avoid adding in code for handling missing value in later stages */
	      Setattr((yyval.node), "value", "*parse error*");
	      SetFlag((yyval.node), "valueignored");

	      Setattr((yyval.node), "throws", (yyvsp[-3].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-3].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-3].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-3].dtype).final);

	      if ((yyvsp[-4].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-4].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-4].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-4].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-3].dtype).qualifier && (yyvsp[-6].str) && Strstr((yyvsp[-6].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-6].str));
	   }
#line 7157 "parser.c"
    break;

  case 116: /* c_decl: storage_class AUTO declarator cpp_const ARROW cpp_alternate_rettype virt_specifier_seq_opt initializer c_decl_tail  */
#line 3464 "parser.y"
                                                                                                                                {
              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-5].dtype).qualifier) SwigType_push((yyvsp[-6].decl).type, (yyvsp[-5].dtype).qualifier);
	      Setattr((yyval.node),"refqualifier",(yyvsp[-5].dtype).refqualifier);
	      Setattr((yyval.node),"type",(yyvsp[-3].type));
	      Setattr((yyval.node),"storage",(yyvsp[-8].str));
	      Setattr((yyval.node),"name",(yyvsp[-6].decl).id);
	      Setattr((yyval.node),"decl",(yyvsp[-6].decl).type);
	      Setattr((yyval.node),"parms",(yyvsp[-6].decl).parms);
	      Setattr((yyval.node),"throws",(yyvsp[-5].dtype).throws);
	      Setattr((yyval.node),"throw",(yyvsp[-5].dtype).throwf);
	      Setattr((yyval.node),"noexcept",(yyvsp[-5].dtype).nexcept);
	      Setattr((yyval.node),"final",(yyvsp[-5].dtype).final);
	      if (!(yyvsp[0].node)) {
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
	      } else {
		Node *n = (yyvsp[0].node);
		while (n) {
		  String *type = Copy((yyvsp[-3].type));
		  Setattr(n,"type",type);
		  Setattr(n,"storage",(yyvsp[-8].str));
		  n = nextSibling(n);
		  Delete(type);
		}
	      }

	      if ((yyvsp[-6].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-6].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-6].decl).id);
		    Setattr((yyval.node),"name",lstr);
		    Delete(lstr);
		    set_nextSibling((yyval.node), (yyvsp[0].node));
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = (yyvsp[0].node);
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-6].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = (yyvsp[0].node);
		}
	      } else {
		set_nextSibling((yyval.node), (yyvsp[0].node));
	      }

	      if ((yyvsp[-5].dtype).qualifier && (yyvsp[-8].str) && Strstr((yyvsp[-8].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-8].str));
           }
#line 7220 "parser.c"
    break;

  case 117: /* c_decl: storage_class AUTO declarator cpp_const LBRACE  */
#line 3529 "parser.y"
                                                            {
	      if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);

              (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-4].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);

	      if ((yyvsp[-2].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-4].str) && Strstr((yyvsp[-4].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-4].str));
	   }
#line 7266 "parser.c"
    break;

  case 118: /* c_decl: storage_class AUTO declarator cpp_const SEMI  */
#line 3574 "parser.y"
                                                          {
	      (yyval.node) = new_node("cdecl");
	      if ((yyvsp[-1].dtype).qualifier) SwigType_push((yyvsp[-2].decl).type, (yyvsp[-1].dtype).qualifier);
	      Setattr((yyval.node), "refqualifier", (yyvsp[-1].dtype).refqualifier);
	      Setattr((yyval.node), "type", NewString("auto"));
	      Setattr((yyval.node), "storage", (yyvsp[-4].str));
	      Setattr((yyval.node), "name", (yyvsp[-2].decl).id);
	      Setattr((yyval.node), "decl", (yyvsp[-2].decl).type);
	      Setattr((yyval.node), "parms", (yyvsp[-2].decl).parms);
	      Setattr((yyval.node), "throws", (yyvsp[-1].dtype).throws);
	      Setattr((yyval.node), "throw", (yyvsp[-1].dtype).throwf);
	      Setattr((yyval.node), "noexcept", (yyvsp[-1].dtype).nexcept);
	      Setattr((yyval.node), "final", (yyvsp[-1].dtype).final);

	      if ((yyvsp[-2].decl).id) {
		/* Ignore all scoped declarations, could be 1. out of class function definition 2. friend function declaration 3. ... */
		String *p = Swig_scopename_prefix((yyvsp[-2].decl).id);
		if (p) {
		  if ((Namespaceprefix && Strcmp(p, Namespaceprefix) == 0) ||
		      (Classprefix && Strcmp(p, Classprefix) == 0)) {
		    String *lstr = Swig_scopename_last((yyvsp[-2].decl).id);
		    Setattr((yyval.node), "name", lstr);
		    Delete(lstr);
		  } else {
		    Delete((yyval.node));
		    (yyval.node) = 0;
		  }
		  Delete(p);
		} else if (Strncmp((yyvsp[-2].decl).id, "::", 2) == 0) {
		  /* global scope declaration/definition ignored */
		  Delete((yyval.node));
		  (yyval.node) = 0;
		}
	      }

	      if ((yyvsp[-1].dtype).qualifier && (yyvsp[-4].str) && Strstr((yyvsp[-4].str), "static"))
		Swig_error(cparse_file, cparse_line, "Static function %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)));
	      Delete((yyvsp[-4].str));
	   }
#line 7310 "parser.c"
    break;

  case 119: /* c_decl: storage_class AUTO idcolon EQUAL definetype SEMI  */
#line 3614 "parser.y"
                                                              {
	      SwigType *type = deduce_type(&(yyvsp[-1].dtype));
	      if (!type)
		type = NewString("auto");
	      (yyval.node) = new_node("cdecl");
	      Setattr((yyval.node), "type", type);
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-3].str));
	      Setattr((yyval.node), "decl", NewStringEmpty());
	      Setattr((yyval.node), "value", (yyvsp[-1].dtype).val);
	      if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
	      if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
	      Setattr((yyval.node), "valuetype", type);
	      Delete((yyvsp[-5].str));
	      Delete(type);
	   }
#line 7331 "parser.c"
    break;

  case 120: /* c_decl: storage_class AUTO idcolon EQUAL error SEMI  */
#line 3631 "parser.y"
                                                         {
	      SwigType *type = NewString("auto");
	      (yyval.node) = new_node("cdecl");
	      Setattr((yyval.node), "type", type);
	      Setattr((yyval.node), "storage", (yyvsp[-5].str));
	      Setattr((yyval.node), "name", (yyvsp[-3].str));
	      Setattr((yyval.node), "decl", NewStringEmpty());
	      Setattr((yyval.node), "valuetype", type);
	      Delete((yyvsp[-5].str));
	      Delete(type);
	   }
#line 7347 "parser.c"
    break;

  case 121: /* c_decl_tail: SEMI  */
#line 3646 "parser.y"
                      { 
                   (yyval.node) = 0;
                   Clear(scanner_ccode); 
               }
#line 7356 "parser.c"
    break;

  case 122: /* c_decl_tail: COMMA declarator cpp_const initializer c_decl_tail  */
#line 3650 "parser.y"
                                                                        {
		 (yyval.node) = new_node("cdecl");
		 if ((yyvsp[-2].dtype).qualifier) SwigType_push((yyvsp[-3].decl).type,(yyvsp[-2].dtype).qualifier);
		 Setattr((yyval.node),"refqualifier",(yyvsp[-2].dtype).refqualifier);
		 Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
		 Setattr((yyval.node),"decl",(yyvsp[-3].decl).type);
		 Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
		 Setattr((yyval.node),"value",(yyvsp[-1].dtype).val);
		 if ((yyvsp[-1].dtype).stringval) Setattr((yyval.node), "stringval", (yyvsp[-1].dtype).stringval);
		 if ((yyvsp[-1].dtype).numval) Setattr((yyval.node), "numval", (yyvsp[-1].dtype).numval);
		 Setattr((yyval.node),"throws",(yyvsp[-2].dtype).throws);
		 Setattr((yyval.node),"throw",(yyvsp[-2].dtype).throwf);
		 Setattr((yyval.node),"noexcept",(yyvsp[-2].dtype).nexcept);
		 Setattr((yyval.node),"final",(yyvsp[-2].dtype).final);
		 if ((yyvsp[-1].dtype).bitfield) {
		   Setattr((yyval.node),"bitfield", (yyvsp[-1].dtype).bitfield);
		 }
		 if (!(yyvsp[0].node)) {
		   if (Len(scanner_ccode)) {
		     String *code = Copy(scanner_ccode);
		     Setattr((yyval.node),"code",code);
		     Delete(code);
		   }
		 } else {
		   set_nextSibling((yyval.node), (yyvsp[0].node));
		 }
	       }
#line 7388 "parser.c"
    break;

  case 123: /* c_decl_tail: LBRACE  */
#line 3677 "parser.y"
                        { 
                   if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                   (yyval.node) = 0;
               }
#line 7397 "parser.c"
    break;

  case 124: /* c_decl_tail: error  */
#line 3681 "parser.y"
                       {
		   (yyval.node) = 0;
		   if (yychar == RPAREN) {
		       Swig_error(cparse_file, cparse_line, "Unexpected closing parenthesis (')').\n");
		   } else {
		       Swig_error(cparse_file, cparse_line, "Syntax error - possibly a missing semicolon (';').\n");
		   }
		   Exit(EXIT_FAILURE);
               }
#line 7411 "parser.c"
    break;

  case 126: /* initializer: COLON expr  */
#line 3693 "parser.y"
                           {
		(yyval.dtype) = default_dtype;
		(yyval.dtype).bitfield = (yyvsp[0].dtype).val;
	      }
#line 7420 "parser.c"
    break;

  case 130: /* cpp_alternate_rettype: c_enum_key idcolon  */
#line 3702 "parser.y"
                                   {
		(yyval.type) = (yyvsp[0].str);
		Insert((yyval.type), 0, "enum ");
	      }
#line 7429 "parser.c"
    break;

  case 131: /* cpp_alternate_rettype: idcolon  */
#line 3706 "parser.y"
                        { (yyval.type) = (yyvsp[0].str); }
#line 7435 "parser.c"
    break;

  case 132: /* cpp_alternate_rettype: idcolon AND  */
#line 3707 "parser.y"
                            {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_reference((yyval.type));
              }
#line 7444 "parser.c"
    break;

  case 133: /* cpp_alternate_rettype: idcolon LAND  */
#line 3711 "parser.y"
                             {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 7453 "parser.c"
    break;

  case 134: /* cpp_alternate_rettype: CONST_QUAL idcolon AND  */
#line 3715 "parser.y"
                                       {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_reference((yyval.type));
              }
#line 7463 "parser.c"
    break;

  case 135: /* cpp_alternate_rettype: CONST_QUAL idcolon LAND  */
#line 3720 "parser.y"
                                        {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 7473 "parser.c"
    break;

  case 137: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template LPAREN parms RPAREN cpp_const lambda_body lambda_tail  */
#line 3736 "parser.y"
                                                                                                                                           {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-9].str));
		  Delete((yyvsp[-11].str));
		  add_symbols((yyval.node));
	        }
#line 7484 "parser.c"
    break;

  case 138: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template LPAREN parms RPAREN cpp_const ARROW type lambda_body lambda_tail  */
#line 3742 "parser.y"
                                                                                                                                                      {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-11].str));
		  Delete((yyvsp[-13].str));
		  add_symbols((yyval.node));
		}
#line 7495 "parser.c"
    break;

  case 139: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template lambda_body lambda_tail  */
#line 3748 "parser.y"
                                                                                                             {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-5].str));
		  Delete((yyvsp[-7].str));
		  add_symbols((yyval.node));
		}
#line 7506 "parser.c"
    break;

  case 140: /* lambda_introducer: LBRACKET  */
#line 3756 "parser.y"
                             {
		  if (skip_balanced('[',']') < 0) Exit(EXIT_FAILURE);
	        }
#line 7514 "parser.c"
    break;

  case 141: /* lambda_template: LESSTHAN  */
#line 3761 "parser.y"
                           {
		  if (skip_balanced('<','>') < 0) Exit(EXIT_FAILURE);
		}
#line 7522 "parser.c"
    break;

  case 143: /* lambda_body: LBRACE  */
#line 3767 "parser.y"
                     {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		}
#line 7530 "parser.c"
    break;

  case 145: /* $@4: %empty  */
#line 3772 "parser.y"
                         {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		}
#line 7538 "parser.c"
    break;

  case 146: /* lambda_tail: LPAREN $@4 SEMI  */
#line 3774 "parser.y"
                       {
		}
#line 7545 "parser.c"
    break;

  case 147: /* c_enum_key: ENUM  */
#line 3784 "parser.y"
                  {
		   (yyval.id) = "enum";
	      }
#line 7553 "parser.c"
    break;

  case 148: /* c_enum_key: ENUM CLASS  */
#line 3787 "parser.y"
                           {
		   (yyval.id) = "enum class";
	      }
#line 7561 "parser.c"
    break;

  case 149: /* c_enum_key: ENUM STRUCT  */
#line 3790 "parser.y"
                            {
		   (yyval.id) = "enum struct";
	      }
#line 7569 "parser.c"
    break;

  case 150: /* c_enum_inherit: COLON type_right  */
#line 3799 "parser.y"
                                  {
                   (yyval.type) = (yyvsp[0].type);
              }
#line 7577 "parser.c"
    break;

  case 151: /* c_enum_inherit: %empty  */
#line 3802 "parser.y"
                       { (yyval.type) = 0; }
#line 7583 "parser.c"
    break;

  case 152: /* c_enum_forward_decl: storage_class c_enum_key ename c_enum_inherit SEMI  */
#line 3809 "parser.y"
                                                                         {
		   SwigType *ty = 0;
		   int scopedenum = (yyvsp[-2].id) && !Equal((yyvsp[-3].id), "enum");
		   (yyval.node) = new_node("enumforward");
		   ty = NewStringf("enum %s", (yyvsp[-2].id));
		   Setattr((yyval.node),"enumkey",(yyvsp[-3].id));
		   if (scopedenum)
		     SetFlag((yyval.node), "scopedenum");
		   Setattr((yyval.node),"name",(yyvsp[-2].id));
		   Setattr((yyval.node), "enumbase", (yyvsp[-1].type));
		   Setattr((yyval.node),"type",ty);
		   Setattr((yyval.node),"sym:weak", "1");
		   Delete((yyvsp[-4].str));
		   add_symbols((yyval.node));
	      }
#line 7603 "parser.c"
    break;

  case 153: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE SEMI  */
#line 3832 "parser.y"
                                                                                         {
		  SwigType *ty = 0;
		  int scopedenum = (yyvsp[-5].id) && !Equal((yyvsp[-6].id), "enum");
		  (yyval.node) = new_enum_node((yyvsp[-4].type));
		  ty = NewStringf("enum %s", (yyvsp[-5].id));
		  Setattr((yyval.node),"enumkey",(yyvsp[-6].id));
		  if (scopedenum)
		    SetFlag((yyval.node), "scopedenum");
		  Setattr((yyval.node),"name",(yyvsp[-5].id));
		  Setattr((yyval.node),"type",ty);
		  appendChild((yyval.node),(yyvsp[-2].node));
		  add_symbols((yyval.node));      /* Add to tag space */

		  if (scopedenum) {
		    Swig_symbol_newscope();
		    Swig_symbol_setscopename((yyvsp[-5].id));
		    Delete(Namespaceprefix);
		    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  }

		  add_symbols((yyvsp[-2].node));      /* Add enum values to appropriate enum or enum class scope */

		  if (scopedenum) {
		    Setattr((yyval.node),"symtab", Swig_symbol_popscope());
		    Delete(Namespaceprefix);
		    Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  }
		  Delete((yyvsp[-7].str));
               }
#line 7637 "parser.c"
    break;

  case 154: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE declarator cpp_const initializer c_decl_tail  */
#line 3861 "parser.y"
                                                                                                                                   {
		 Node *n;
		 SwigType *ty = 0;
		 String   *unnamed = 0;
		 int       unnamedinstance = 0;
		 int scopedenum = (yyvsp[-8].id) && !Equal((yyvsp[-9].id), "enum");

		 (yyval.node) = new_enum_node((yyvsp[-7].type));
		 Setattr((yyval.node),"enumkey",(yyvsp[-9].id));
		 if (scopedenum)
		   SetFlag((yyval.node), "scopedenum");
		 if ((yyvsp[-8].id)) {
		   Setattr((yyval.node),"name",(yyvsp[-8].id));
		   ty = NewStringf("enum %s", (yyvsp[-8].id));
		 } else if ((yyvsp[-3].decl).id) {
		   unnamed = make_unnamed();
		   ty = NewStringf("enum %s", unnamed);
		   Setattr((yyval.node),"unnamed",unnamed);
                   /* name is not set for unnamed enum instances, e.g. enum { foo } Instance; */
		   if ((yyvsp[-10].str) && Cmp((yyvsp[-10].str),"typedef") == 0) {
		     Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
                   } else {
                     unnamedinstance = 1;
                   }
		   Setattr((yyval.node),"storage",(yyvsp[-10].str));
		 }
		 if ((yyvsp[-3].decl).id && Cmp((yyvsp[-10].str),"typedef") == 0) {
		   Setattr((yyval.node),"tdname",(yyvsp[-3].decl).id);
                   Setattr((yyval.node),"allows_typedef","1");
                 }
		 appendChild((yyval.node),(yyvsp[-5].node));
		 n = new_node("cdecl");
		 Setattr(n,"type",ty);
		 Setattr(n,"name",(yyvsp[-3].decl).id);
		 Setattr(n,"storage",(yyvsp[-10].str));
		 Setattr(n,"decl",(yyvsp[-3].decl).type);
		 Setattr(n,"parms",(yyvsp[-3].decl).parms);
		 Setattr(n,"unnamed",unnamed);

                 if (unnamedinstance) {
		   SwigType *cty = NewString("enum ");
		   Setattr((yyval.node),"type",cty);
		   SetFlag((yyval.node),"unnamedinstance");
		   SetFlag(n,"unnamedinstance");
		   Delete(cty);
                 }
		 if ((yyvsp[0].node)) {
		   Node *p = (yyvsp[0].node);
		   set_nextSibling(n,p);
		   while (p) {
		     SwigType *cty = Copy(ty);
		     Setattr(p,"type",cty);
		     Setattr(p,"unnamed",unnamed);
		     Setattr(p,"storage",(yyvsp[-10].str));
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
                 if ((yyvsp[-3].decl).id && (yyvsp[-8].id) && Cmp((yyvsp[-10].str),"typedef") == 0) {
		   String *name = NewString((yyvsp[-3].decl).id);
                   Setattr((yyval.node), "parser:makename", name);
		   Delete(name);
                 }

		 add_symbols((yyval.node));       /* Add enum to tag space */
		 set_nextSibling((yyval.node),n);
		 Delete(n);

		 if (scopedenum) {
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename((yyvsp[-8].id));
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 }

		 add_symbols((yyvsp[-5].node));      /* Add enum values to appropriate enum or enum class scope */

		 if (scopedenum) {
		   Setattr((yyval.node),"symtab", Swig_symbol_popscope());
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 }

	         add_symbols(n);
		 Delete((yyvsp[-10].str));
		 Delete(unnamed);
	       }
#line 7738 "parser.c"
    break;

  case 155: /* c_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 3959 "parser.y"
                                                                     {
                   /* This is a sick hack.  If the ctor_end has parameters,
                      and the parms parameter only has 1 parameter, this
                      could be a declaration of the form:

                         type (id)(parms)

			 Otherwise it's an error. */
                    int err = 0;
                    (yyval.node) = 0;

		    if ((ParmList_len((yyvsp[-2].pl)) == 1) && (!Swig_scopename_check((yyvsp[-4].type)))) {
		      SwigType *ty = Getattr((yyvsp[-2].pl),"type");
		      String *name = Getattr((yyvsp[-2].pl),"name");
		      err = 1;
		      if (!name) {
			(yyval.node) = new_node("cdecl");
			Setattr((yyval.node),"type",(yyvsp[-4].type));
			Setattr((yyval.node),"storage",(yyvsp[-5].str));
			Setattr((yyval.node),"name",ty);

			if ((yyvsp[0].decl).have_parms) {
			  SwigType *decl = NewStringEmpty();
			  SwigType_add_function(decl,(yyvsp[0].decl).parms);
			  Setattr((yyval.node),"decl",decl);
			  Setattr((yyval.node),"parms",(yyvsp[0].decl).parms);
			  if (Len(scanner_ccode)) {
			    String *code = Copy(scanner_ccode);
			    Setattr((yyval.node),"code",code);
			    Delete(code);
			  }
			}
			if ((yyvsp[0].decl).defarg)
			  Setattr((yyval.node), "value", (yyvsp[0].decl).defarg);
			if ((yyvsp[0].decl).stringdefarg)
			  Setattr((yyval.node), "stringval", (yyvsp[0].decl).stringdefarg);
			if ((yyvsp[0].decl).numdefarg)
			  Setattr((yyval.node), "numval", (yyvsp[0].decl).numdefarg);
			Setattr((yyval.node),"throws",(yyvsp[0].decl).throws);
			Setattr((yyval.node),"throw",(yyvsp[0].decl).throwf);
			Setattr((yyval.node),"noexcept",(yyvsp[0].decl).nexcept);
			Setattr((yyval.node),"final",(yyvsp[0].decl).final);
			err = 0;
		      }
		    }
		    Delete((yyvsp[-5].str));
		    if (err) {
		      Swig_error(cparse_file,cparse_line,"Syntax error in input(2).\n");
		      Exit(EXIT_FAILURE);
		    }
                }
#line 7794 "parser.c"
    break;

  case 162: /* @5: %empty  */
#line 4030 "parser.y"
                                                                                            {
                   String *prefix;
                   List *bases = 0;
		   Node *scope = 0;
		   int errored_flag = 0;
		   String *code;
		   (yyval.node) = new_node("class");
		   Setattr((yyval.node),"kind",(yyvsp[-4].type));
		   if ((yyvsp[-1].bases)) {
		     Setattr((yyval.node),"baselist", Getattr((yyvsp[-1].bases),"public"));
		     Setattr((yyval.node),"protectedbaselist", Getattr((yyvsp[-1].bases),"protected"));
		     Setattr((yyval.node),"privatebaselist", Getattr((yyvsp[-1].bases),"private"));
		   }
		   Setattr((yyval.node),"allows_typedef","1");

		   /* Temporary unofficial symtab for use until add_symbols() adds "sym:symtab" */
		   Setattr((yyval.node), "unofficial:symtab", Swig_symbol_current());
		  
		   /* If the class name is qualified.  We need to create or lookup namespace/scope entries */
		   scope = resolve_create_node_scope((yyvsp[-3].str), 1, &errored_flag);
		   /* save nscope_inner to the class - it may be overwritten in nested classes*/
		   Setattr((yyval.node), "nested:innerscope", nscope_inner);
		   Setattr((yyval.node), "nested:nscope", nscope);
		   Setfile(scope,cparse_file);
		   Setline(scope,cparse_line);
		   Setattr((yyval.node), "name", scope);

		   if (currentOuterClass) {
		     SetFlag((yyval.node), "nested");
		     Setattr((yyval.node), "nested:outer", currentOuterClass);
		     set_access_mode((yyval.node));
		   }
		   Swig_features_get(Swig_cparse_features(), Namespaceprefix, Getattr((yyval.node), "name"), 0, (yyval.node));
		   /* save yyrename to the class attribute, to be used later in add_symbols()*/
		   Setattr((yyval.node), "class_rename", make_name((yyval.node), scope, 0));
		   Setattr((yyval.node), "Classprefix", scope);
		   Classprefix = NewString(scope);
		   /* Deal with inheritance  */
		   if ((yyvsp[-1].bases))
		     bases = Swig_make_inherit_list(scope, Getattr((yyvsp[-1].bases), "public"), Namespaceprefix);
		   prefix = SwigType_istemplate_templateprefix(scope);
		   if (prefix) {
		     String *fbase, *tbase;
		     if (Namespaceprefix) {
		       fbase = NewStringf("%s::%s", Namespaceprefix, scope);
		       tbase = NewStringf("%s::%s", Namespaceprefix, prefix);
		     } else {
		       fbase = Copy(scope);
		       tbase = Copy(prefix);
		     }
		     Swig_name_inherit(tbase,fbase);
		     Delete(fbase);
		     Delete(tbase);
		   }
                   if (Strcmp((yyvsp[-4].type), "class") == 0) {
		     cplus_mode = CPLUS_PRIVATE;
		   } else {
		     cplus_mode = CPLUS_PUBLIC;
		   }
		   if (!cparse_cplusplus) {
		     set_scope_to_global();
		   }
		   Swig_symbol_newscope();
		   Swig_symbol_setscopename(scope);
		   Swig_inherit_base_symbols(bases);
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
		   Delete(prefix);
		   inclass = 1;
		   currentOuterClass = (yyval.node);
		   if (cparse_cplusplusout) {
		     /* save the structure declaration to declare it in global scope for C++ to see */
		     code = get_raw_text_balanced('{', '}');
		     Setattr((yyval.node), "code", code);
		     Delete(code);
		   }
               }
#line 7892 "parser.c"
    break;

  case 163: /* cpp_class_decl: storage_class cpptype idcolon class_virt_specifier_opt inherit LBRACE @5 cpp_members RBRACE cpp_opt_declarators  */
#line 4122 "parser.y"
                                                              {
		   Node *p;
		   SwigType *ty;
		   Symtab *cscope;
		   Node *am = 0;
		   String *scpname = 0;
		   (yyval.node) = currentOuterClass;
		   currentOuterClass = Getattr((yyval.node), "nested:outer");
		   nscope_inner = Getattr((yyval.node), "nested:innerscope");
		   nscope = Getattr((yyval.node), "nested:nscope");
		   Delattr((yyval.node), "nested:innerscope");
		   Delattr((yyval.node), "nested:nscope");
		   if (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0) { /* actual parent class for this class */
		     Node* forward_declaration = Swig_symbol_clookup_no_inherit(Getattr((yyval.node),"name"), Getattr(nscope_inner, "symtab"));
		     if (forward_declaration) {
		       Setattr((yyval.node), "access", Getattr(forward_declaration, "access"));
		     }
		     Setattr((yyval.node), "nested:outer", nscope_inner);
		     SetFlag((yyval.node), "nested");
                   }
		   if (!currentOuterClass)
		     inclass = 0;
		   cscope = Getattr((yyval.node), "unofficial:symtab");
		   Delattr((yyval.node), "unofficial:symtab");
		   
		   /* Check for pure-abstract class */
		   Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[-2].node)));
		   
		   /* This bit of code merges in a previously defined %extend directive (if any) */
		   {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     am = Getattr(Swig_extend_hash(), clsname);
		     if (am) {
		       Swig_extend_merge((yyval.node), am);
		       Delattr(Swig_extend_hash(), clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes, scpname, (yyval.node));

		   appendChild((yyval.node), (yyvsp[-2].node));
		   
		   if (am) 
		     Swig_extend_append_previous((yyval.node), am);

		   p = (yyvsp[0].node);
		   if (p && !nscope_inner) {
		     if (!cparse_cplusplus && currentOuterClass)
		       appendChild(currentOuterClass, p);
		     else
		      appendSibling((yyval.node), p);
		   }
		   
		   if (nscope_inner) {
		     ty = NewString(scpname); /* if the class is declared out of scope, let the declarator use fully qualified type*/
		   } else if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString(Getattr((yyvsp[-3].node), "name"));
		   } else {
		     ty = NewStringf("%s %s", (yyvsp[-8].type), Getattr((yyvsp[-3].node), "name"));
		   }
		   while (p) {
		     Setattr(p, "storage", (yyvsp[-9].str));
		     Setattr(p, "type" ,ty);
		     if (!cparse_cplusplus && currentOuterClass && (!Getattr(currentOuterClass, "name"))) {
		       SetFlag(p, "hasconsttype");
		     }
		     p = nextSibling(p);
		   }
		   if ((yyvsp[0].node) && Cmp((yyvsp[-9].str),"typedef") == 0)
		     add_typedef_name((yyval.node), (yyvsp[0].node), Getattr((yyvsp[-3].node), "name"), cscope, scpname);
		   Delete(scpname);

		   if (cplus_mode != CPLUS_PUBLIC) {
		   /* we 'open' the class at the end, to allow %template
		      to add new members */
		     Node *pa = new_node("access");
		     Setattr(pa, "kind", "public");
		     cplus_mode = CPLUS_PUBLIC;
		     appendChild((yyval.node), pa);
		     Delete(pa);
		   }
		   if (currentOuterClass)
		     restore_access_mode((yyval.node));
		   Setattr((yyval.node), "symtab", Swig_symbol_popscope());
		   Classprefix = Getattr((yyval.node), "Classprefix");
		   Delattr((yyval.node), "Classprefix");
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   if (cplus_mode == CPLUS_PRIVATE) {
		     (yyval.node) = 0; /* skip private nested classes */
		   } else if (cparse_cplusplus && currentOuterClass && ignore_nested_classes && !GetFlag((yyval.node), "feature:flatnested")) {
		     (yyval.node) = nested_forward_declaration((yyvsp[-9].str), (yyvsp[-8].type), Getattr((yyvsp[-3].node), "name"), Copy(Getattr((yyvsp[-3].node), "name")), (yyvsp[0].node));
		   } else if (nscope_inner) {
		     /* this is tricky */
		     /* we add the declaration in the original namespace */
		     if (Strcmp(nodeType(nscope_inner), "class") == 0 && cparse_cplusplus && ignore_nested_classes && !GetFlag((yyval.node), "feature:flatnested"))
		       (yyval.node) = nested_forward_declaration((yyvsp[-9].str), (yyvsp[-8].type), Getattr((yyvsp[-3].node), "name"), Copy(Getattr((yyvsp[-3].node), "name")), (yyvsp[0].node));
		     appendChild(nscope_inner, (yyval.node));
		     Swig_symbol_setscope(Getattr(nscope_inner, "symtab"));
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     yyrename = Copy(Getattr((yyval.node), "class_rename"));
		     add_symbols((yyval.node));
		     Delattr((yyval.node), "class_rename");
		     /* but the variable definition in the current scope */
		     Swig_symbol_setscope(cscope);
		     Delete(Namespaceprefix);
		     Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		     add_symbols((yyvsp[0].node));
		     if (nscope) {
		       (yyval.node) = nscope; /* here we return recreated namespace tower instead of the class itself */
		       if ((yyvsp[0].node)) {
			 appendSibling((yyval.node), (yyvsp[0].node));
		       }
		     } else if (!SwigType_istemplate(ty) && template_parameters == 0) { /* for template we need the class itself */
		       (yyval.node) = (yyvsp[0].node);
		     }
		   } else {
		     Delete(yyrename);
		     yyrename = 0;
		     if (!cparse_cplusplus && currentOuterClass) { /* nested C structs go into global scope*/
		       Node *outer = currentOuterClass;
		       while (Getattr(outer, "nested:outer"))
			 outer = Getattr(outer, "nested:outer");
		       appendSibling(outer, (yyval.node));
		       Swig_symbol_setscope(cscope); /* declaration goes in the parent scope */
		       add_symbols((yyvsp[0].node));
		       set_scope_to_global();
		       Delete(Namespaceprefix);
		       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		       yyrename = Copy(Getattr((yyval.node), "class_rename"));
		       add_symbols((yyval.node));
		       if (!cparse_cplusplusout)
			 Delattr((yyval.node), "nested:outer");
		       Delattr((yyval.node), "class_rename");
		       (yyval.node) = 0;
		     } else {
		       yyrename = Copy(Getattr((yyval.node), "class_rename"));
		       add_symbols((yyval.node));
		       add_symbols((yyvsp[0].node));
		       Delattr((yyval.node), "class_rename");
		     }
		   }
		   Delete(ty);
		   Swig_symbol_setscope(cscope);
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   Classprefix = currentOuterClass ? Getattr(currentOuterClass, "Classprefix") : 0;
		   Delete((yyvsp[-9].str));
	       }
#line 8049 "parser.c"
    break;

  case 164: /* @6: %empty  */
#line 4277 "parser.y"
                                                          {
	       String *unnamed;
	       String *code;
	       unnamed = make_unnamed();
	       (yyval.node) = new_node("class");
	       Setattr((yyval.node),"kind",(yyvsp[-2].type));
	       if ((yyvsp[-1].bases)) {
		 Setattr((yyval.node),"baselist", Getattr((yyvsp[-1].bases),"public"));
		 Setattr((yyval.node),"protectedbaselist", Getattr((yyvsp[-1].bases),"protected"));
		 Setattr((yyval.node),"privatebaselist", Getattr((yyvsp[-1].bases),"private"));
	       }
	       Setattr((yyval.node),"storage",(yyvsp[-3].str));
	       Setattr((yyval.node),"unnamed",unnamed);
	       Setattr((yyval.node),"allows_typedef","1");

	       /* Temporary unofficial symtab for use until add_symbols() adds "sym:symtab" */
	       Setattr((yyval.node), "unofficial:symtab", Swig_symbol_current());

	       if (currentOuterClass) {
		 SetFlag((yyval.node), "nested");
		 Setattr((yyval.node), "nested:outer", currentOuterClass);
		 set_access_mode((yyval.node));
	       }
	       Swig_features_get(Swig_cparse_features(), Namespaceprefix, 0, 0, (yyval.node));
	       /* save yyrename to the class attribute, to be used later in add_symbols()*/
	       Setattr((yyval.node), "class_rename", make_name((yyval.node),0,0));
	       if (Strcmp((yyvsp[-2].type), "class") == 0) {
		 cplus_mode = CPLUS_PRIVATE;
	       } else {
		 cplus_mode = CPLUS_PUBLIC;
	       }
	       Swig_symbol_newscope();
	       cparse_start_line = cparse_line;
	       currentOuterClass = (yyval.node);
	       inclass = 1;
	       Classprefix = 0;
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       /* save the structure declaration to make a typedef for it later*/
	       code = get_raw_text_balanced('{', '}');
	       Setattr((yyval.node), "code", code);
	       Delete(code);
	     }
#line 8097 "parser.c"
    break;

  case 165: /* cpp_class_decl: storage_class cpptype inherit LBRACE @6 cpp_members RBRACE cpp_opt_declarators  */
#line 4319 "parser.y"
                                                            {
	       String *unnamed;
               List *bases = 0;
	       String *name = 0;
	       Node *n;
	       Symtab *cscope;
	       Classprefix = 0;
	       (void)(yyvsp[-3].node);
	       (yyval.node) = currentOuterClass;
	       currentOuterClass = Getattr((yyval.node), "nested:outer");
	       if (!currentOuterClass)
		 inclass = 0;
	       else
		 restore_access_mode((yyval.node));

	       cscope = Getattr((yyval.node), "unofficial:symtab");
	       Delattr((yyval.node), "unofficial:symtab");

	       unnamed = Getattr((yyval.node),"unnamed");
               /* Check for pure-abstract class */
	       Setattr((yyval.node),"abstracts", pure_abstracts((yyvsp[-2].node)));
	       n = (yyvsp[0].node);
	       if (cparse_cplusplus && currentOuterClass && ignore_nested_classes && !GetFlag((yyval.node), "feature:flatnested")) {
		 String *name = n ? Copy(Getattr(n, "name")) : 0;
		 (yyval.node) = nested_forward_declaration((yyvsp[-7].str), (yyvsp[-6].type), 0, name, n);
	       } else if (n) {
	         appendSibling((yyval.node),n);
		 /* If a proper typedef name was given, we'll use it to set the scope name */
		 name = try_to_find_a_name_for_unnamed_structure((yyvsp[-7].str), n);
		 if (name) {
		   String *scpname = 0;
		   SwigType *ty;
		   Setattr((yyval.node),"tdname",name);
		   Setattr((yyval.node),"name",name);
		   Swig_symbol_setscopename(name);
		   if ((yyvsp[-5].bases))
		     bases = Swig_make_inherit_list(name,Getattr((yyvsp[-5].bases),"public"),Namespaceprefix);
		   Swig_inherit_base_symbols(bases);

		     /* If a proper name was given, we use that as the typedef, not unnamed */
		   Clear(unnamed);
		   Append(unnamed, name);
		   if (cparse_cplusplus && !cparse_externc) {
		     ty = NewString(name);
		   } else {
		     ty = NewStringf("%s %s", (yyvsp[-6].type),name);
		   }
		   while (n) {
		     Setattr(n,"storage",(yyvsp[-7].str));
		     Setattr(n, "type", ty);
		     if (!cparse_cplusplus && currentOuterClass && (!Getattr(currentOuterClass, "name"))) {
		       SetFlag(n,"hasconsttype");
		     }
		     n = nextSibling(n);
		   }
		   n = (yyvsp[0].node);

		   /* Check for previous extensions */
		   {
		     String *clsname = Swig_symbol_qualifiedscopename(0);
		     Node *am = Getattr(Swig_extend_hash(),clsname);
		     if (am) {
		       /* Merge the extension into the symbol table */
		       Swig_extend_merge((yyval.node),am);
		       Swig_extend_append_previous((yyval.node),am);
		       Delattr(Swig_extend_hash(),clsname);
		     }
		     Delete(clsname);
		   }
		   if (!classes) classes = NewHash();
		   scpname = Swig_symbol_qualifiedscopename(0);
		   Setattr(classes,scpname,(yyval.node));
		   Delete(scpname);
		 } else { /* no suitable name was found for a struct */
		   Setattr((yyval.node), "nested:unnamed", Getattr(n, "name")); /* save the name of the first declarator for later use in name generation*/
		   while (n) { /* attach unnamed struct to the declarators, so that they would receive proper type later*/
		     Setattr(n, "nested:unnamedtype", (yyval.node));
		     Setattr(n, "storage", (yyvsp[-7].str));
		     n = nextSibling(n);
		   }
		   n = (yyvsp[0].node);
		   Swig_symbol_setscopename("<unnamed>");
		 }
		 appendChild((yyval.node),(yyvsp[-2].node));
		 /* Pop the scope */
		 Setattr((yyval.node),"symtab",Swig_symbol_popscope());
		 if (name) {
		   Delete(yyrename);
		   yyrename = Copy(Getattr((yyval.node), "class_rename"));
		   Delete(Namespaceprefix);
		   Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		   add_symbols((yyval.node));
		   add_symbols(n);
		   Delattr((yyval.node), "class_rename");
		 } else if (cparse_cplusplus)
		   (yyval.node) = 0; /* ignore unnamed structs for C++ */
		   Delete(unnamed);
	       } else { /* unnamed struct without declarator*/
		 Swig_symbol_popscope();
	         Delete(Namespaceprefix);
		 Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		 add_symbols((yyvsp[-2].node));
		 Delete((yyval.node));
		 (yyval.node) = (yyvsp[-2].node); /* pass member list to outer class/namespace (instead of self)*/
	       }
	       Swig_symbol_setscope(cscope);
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       Classprefix = currentOuterClass ? Getattr(currentOuterClass, "Classprefix") : 0;
	       Delete((yyvsp[-7].str));
              }
#line 8213 "parser.c"
    break;

  case 166: /* cpp_opt_declarators: SEMI  */
#line 4432 "parser.y"
                            { (yyval.node) = 0; }
#line 8219 "parser.c"
    break;

  case 167: /* cpp_opt_declarators: declarator cpp_const initializer c_decl_tail  */
#line 4433 "parser.y"
                                                                    {
                        (yyval.node) = new_node("cdecl");
                        Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
                        Setattr((yyval.node),"decl",(yyvsp[-3].decl).type);
                        Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
			set_nextSibling((yyval.node), (yyvsp[0].node));
                    }
#line 8231 "parser.c"
    break;

  case 168: /* cpp_forward_class_decl: storage_class cpptype idcolon SEMI  */
#line 4445 "parser.y"
                                                            {
	      if ((yyvsp[-3].str) && Strstr((yyvsp[-3].str), "friend")) {
		/* Ignore */
                (yyval.node) = 0; 
	      } else {
		(yyval.node) = new_node("classforward");
		Setattr((yyval.node),"kind",(yyvsp[-2].type));
		Setattr((yyval.node),"name",(yyvsp[-1].str));
		Setattr((yyval.node),"sym:weak", "1");
		add_symbols((yyval.node));
	      }
	      Delete((yyvsp[-3].str));
             }
#line 8249 "parser.c"
    break;

  case 169: /* $@7: %empty  */
#line 4464 "parser.y"
                                                                 { 
		    if (currentOuterClass)
		      Setattr(currentOuterClass, "template_parameters", template_parameters);
		    template_parameters = (yyvsp[-1].tparms); 
		    parsing_template_declaration = 1;
		  }
#line 8260 "parser.c"
    break;

  case 170: /* cpp_template_decl: TEMPLATE LESSTHAN template_parms GREATERTHAN $@7 cpp_template_possible  */
#line 4469 "parser.y"
                                          {
			String *tname = 0;
			int     error = 0;

			/* check if we get a namespace node with a class declaration, and retrieve the class */
			Symtab *cscope = Swig_symbol_current();
			Symtab *sti = 0;
			Node *ntop = (yyvsp[0].node);
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
			  (yyval.node) = ni;
			} else {
			  (yyval.node) = (yyvsp[0].node);
			}

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
			  if (tempn && ((yyvsp[-3].tparms)) && ((yyval.node))) {
			    ParmList *primary_templateparms = Getattr(tempn, "templateparms");
			    String *targs = SwigType_templateargs(tname); /* tname contains name and specialized template parameters, for example: X<(p.T,TT)> */
			    List *tlist = SwigType_parmlist(targs);
			    int specialization_parms_len = Len(tlist);
			    if (!Getattr((yyval.node),"sym:weak")) {
			      Setattr((yyval.node),"sym:typename","1");
			    }
			    Setattr((yyval.node), "primarytemplate", tempn);
			    Setattr((yyval.node), "templateparms", (yyvsp[-3].tparms));
			    Delattr((yyval.node), "specialization");
			    Setattr((yyval.node), "partialspecialization", "1");
			    
			    if (specialization_parms_len > ParmList_len(primary_templateparms)) {
			      Swig_error(Getfile((yyval.node)), Getline((yyval.node)), "Template partial specialization has more arguments than primary template %d %d.\n", specialization_parms_len, ParmList_len(primary_templateparms));
			      
			    } else if (specialization_parms_len < ParmList_numrequired(primary_templateparms)) {
			      Swig_error(Getfile((yyval.node)), Getline((yyval.node)), "Template partial specialization has fewer arguments than primary template %d %d.\n", specialization_parms_len, ParmList_len(primary_templateparms));
			    } else {
			      /* Create a specialized name with template parameters replaced with $ variables, such as, X<(T1,p.T2) => X<($1,p.$2)> */
			      Parm *p = (yyvsp[-3].tparms);
			      String *fname = NewString(tname);
			      String *ffname = 0;
			      ParmList *partialparms = 0;

			      char   tmp[32];
			      int i = 0;
			      while (p) {
				String *name = Getattr(p,"name");
				++i;
				if (!name) {
				  p = nextSibling(p);
				  continue;
				}
				sprintf(tmp, "$%d", i);
				Replaceid(fname, name, tmp);
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
				/* Replace each primary template parameter's name and value with $ variables, such as, class Y,class T=Y => class $1,class $2=$1 */
				ParmList *primary_templateparms_copy = CopyParmList(primary_templateparms);
				p = primary_templateparms_copy;
				i = 0;
				while (p) {
				  String *name = Getattr(p, "name");
				  Parm *pp = nextSibling(p);
				  ++i;
				  sprintf(tmp, "$%d", i);
				  while (pp) {
				    Replaceid(Getattr(pp, "value"), name, tmp);
				    pp = nextSibling(pp);
				  }
				  Setattr(p, "name", NewString(tmp));
				  p = nextSibling(p);
				}
				/* Modify partialparms by adding in missing default values ($ variables) from primary template parameters */
				partialparms = Swig_cparse_template_partialargs_expand(partialparms, tempn, primary_templateparms_copy);
				Delete(primary_templateparms_copy);
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
			} else if ((yyval.node)) {
			  Setattr((yyval.node), "templatetype", nodeType((yyval.node)));
			  set_nodeType((yyval.node),"template");
			  Setattr((yyval.node),"templateparms", (yyvsp[-3].tparms));
			  if (!Getattr((yyval.node),"sym:weak")) {
			    Setattr((yyval.node),"sym:typename","1");
			  }
			  add_symbols((yyval.node));
			  default_arguments((yyval.node));
			  /* We also place a fully parameterized version in the symbol table */
			  {
			    Parm *p;
			    String *fname = NewStringf("%s<(", Getattr((yyval.node),"name"));
			    p = (yyvsp[-3].tparms);
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
			if (error || (nscope_inner && Strcmp(nodeType(nscope_inner), "class") == 0)) {
			  (yyval.node) = 0;
			}
			if (currentOuterClass)
			  template_parameters = Getattr(currentOuterClass, "template_parameters");
			else
			  template_parameters = 0;
			parsing_template_declaration = 0;
                }
#line 8462 "parser.c"
    break;

  case 171: /* cpp_template_decl: TEMPLATE cpptype idcolon  */
#line 4668 "parser.y"
                                           {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8471 "parser.c"
    break;

  case 172: /* cpp_template_decl: TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN  */
#line 4674 "parser.y"
                                                                             {
			Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8480 "parser.c"
    break;

  case 173: /* cpp_template_decl: EXTERN TEMPLATE cpptype idcolon  */
#line 4680 "parser.y"
                                                  {
		  Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
                }
#line 8489 "parser.c"
    break;

  case 174: /* cpp_template_decl: EXTERN TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN  */
#line 4686 "parser.y"
                                                                                    {
			Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8498 "parser.c"
    break;

  case 178: /* cpp_template_possible: cpp_template_decl  */
#line 4695 "parser.y"
                                    {
		  (yyval.node) = 0;
                }
#line 8506 "parser.c"
    break;

  case 181: /* template_parms: template_parms_builder  */
#line 4702 "parser.y"
                                        {
		 (yyval.tparms) = (yyvsp[0].pbuilder).parms;
	       }
#line 8514 "parser.c"
    break;

  case 182: /* template_parms: %empty  */
#line 4705 "parser.y"
                        {
		 (yyval.tparms) = 0;
	       }
#line 8522 "parser.c"
    break;

  case 183: /* template_parms_builder: templateparameter  */
#line 4710 "parser.y"
                                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 8530 "parser.c"
    break;

  case 184: /* template_parms_builder: template_parms_builder COMMA templateparameter  */
#line 4713 "parser.y"
                                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 8544 "parser.c"
    break;

  case 185: /* templateparameter: templcpptype def_args  */
#line 4724 "parser.y"
                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[-1].type), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		    if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
		  }
#line 8557 "parser.c"
    break;

  case 186: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype idcolon def_args  */
#line 4732 "parser.y"
                                                                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s %s", ParmList_str_defaultargs((yyvsp[-4].tparms)), (yyvsp[-2].type), (yyvsp[-1].str)), (yyvsp[-1].str));
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 8570 "parser.c"
    break;

  case 187: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype def_args  */
#line 4740 "parser.y"
                                                                                  {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s", ParmList_str_defaultargs((yyvsp[-3].tparms)), (yyvsp[-1].type)), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 8583 "parser.c"
    break;

  case 188: /* templateparameter: parm  */
#line 4748 "parser.y"
                         {
		    Parm *p = (yyvsp[0].p);
		    String *name = Getattr(p, "name");
		    (yyval.p) = (yyvsp[0].p);

		    /* Correct the 'type name' parameter string, split into the appropriate "name" and "type" attributes */
		    if (!name) {
		      String *type = Getattr(p, "type");
		      if ((Strncmp(type, "class ", 6) == 0) || (Strncmp(type, "typename ", 9) == 0)) {
			/* A 'class T' parameter */
			const char *t = Strchr(type, ' ');
			Setattr(p, "name", t + 1);
			Setattr(p, "type", NewStringWithSize(type, (int)(t - Char(type))));
		      } else if ((Strncmp(type, "v.class ", 8) == 0) || (Strncmp(type, "v.typename ", 11) == 0)) {
			/* Variadic template args */
			const char *t = Strchr(type, ' ');
			Setattr(p, "name", t + 1);
			Setattr(p, "type", NewStringWithSize(type, (int)(t - Char(type))));
		      }
		    }
                  }
#line 8609 "parser.c"
    break;

  case 189: /* cpp_using_decl: USING idcolon SEMI  */
#line 4773 "parser.y"
                                    {
                  String *uname = Swig_symbol_type_qualify((yyvsp[-1].str),0);
                  /* Possible TODO: In testcase using_member_multiple_inherit class Susing3, uname is "Susing1::usingmethod" instead of "Susing2::usingmethod" */
		  String *name = Swig_scopename_last((yyvsp[-1].str));
                  (yyval.node) = new_node("using");
		  Setattr((yyval.node),"uname",uname);
		  Setattr((yyval.node),"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols((yyval.node));
             }
#line 8625 "parser.c"
    break;

  case 190: /* cpp_using_decl: USING TYPENAME idcolon SEMI  */
#line 4784 "parser.y"
                                           {
		  String *uname = Swig_symbol_type_qualify((yyvsp[-1].str),0);
		  String *name = Swig_scopename_last((yyvsp[-1].str));
		  (yyval.node) = new_node("using");
		  Setattr((yyval.node),"uname",uname);
		  Setattr((yyval.node),"name", name);
		  Delete(uname);
		  Delete(name);
		  add_symbols((yyval.node));
	     }
#line 8640 "parser.c"
    break;

  case 191: /* cpp_using_decl: USING NAMESPACE idcolon SEMI  */
#line 4794 "parser.y"
                                            {
	       Node *n = Swig_symbol_clookup((yyvsp[-1].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Nothing known about namespace '%s'\n", SwigType_namestr((yyvsp[-1].str)));
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
		     Setattr((yyval.node),"namespace", (yyvsp[-1].str));
		     if (current != symtab) {
		       Swig_symbol_inherit(symtab);
		     }
		   } else {
		     Swig_error(cparse_file, cparse_line, "'%s' is not a namespace.\n", SwigType_namestr((yyvsp[-1].str)));
		     (yyval.node) = 0;
		   }
		 } else {
		   (yyval.node) = 0;
		 }
	       }
             }
#line 8674 "parser.c"
    break;

  case 192: /* @8: %empty  */
#line 4825 "parser.y"
                                                    {
                Hash *h;
		Node *parent_ns = 0;
		List *scopes = Swig_scopename_tolist((yyvsp[-1].str));
		int ilen = Len(scopes);
		int i;

/*
Printf(stdout, "==== Namespace %s creation...\n", $idcolon);
*/
		(yyval.node) = 0;
		for (i = 0; i < ilen; i++) {
		  Node *ns = new_node("namespace");
		  Symtab *current_symtab = Swig_symbol_current();
		  String *scopename = Getitem(scopes, i);
		  Setattr(ns, "name", scopename);
		  (yyval.node) = ns;
		  if (parent_ns)
		    appendChild(parent_ns, ns);
		  parent_ns = ns;
		  h = Swig_symbol_clookup(scopename, 0);
		  if (h && (current_symtab == Getattr(h, "sym:symtab")) && (Strcmp(nodeType(h), "namespace") == 0)) {
/*
Printf(stdout, "  Scope %s [found C++17 style]\n", scopename);
*/
		    if (Getattr(h, "alias")) {
		      h = Getattr(h, "namespace");
		      Swig_warning(WARN_PARSE_NAMESPACE_ALIAS, cparse_file, cparse_line, "Namespace alias '%s' not allowed here. Assuming '%s'\n",
				   scopename, Getattr(h, "name"));
		      scopename = Getattr(h, "name");
		    }
		    Swig_symbol_setscope(Getattr(h, "symtab"));
		  } else {
/*
Printf(stdout, "  Scope %s [creating single scope C++17 style]\n", scopename);
*/
		    h = Swig_symbol_newscope();
		    Swig_symbol_setscopename(scopename);
		  }
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		}
		Delete(scopes);
             }
#line 8723 "parser.c"
    break;

  case 193: /* cpp_namespace_decl: NAMESPACE idcolon LBRACE @8 interface RBRACE  */
#line 4868 "parser.y"
                                      {
		Node *n = (yyvsp[-2].node);
		Node *top_ns = 0;
		do {
		  Setattr(n, "symtab", Swig_symbol_popscope());
		  Delete(Namespaceprefix);
		  Namespaceprefix = Swig_symbol_qualifiedscopename(0);
		  add_symbols(n);
		  top_ns = n;
		  n = parentNode(n);
		} while(n);
		appendChild((yyvsp[-2].node), firstChild((yyvsp[-1].node)));
		Delete((yyvsp[-1].node));
		(yyval.node) = top_ns;
             }
#line 8743 "parser.c"
    break;

  case 194: /* @9: %empty  */
#line 4883 "parser.y"
                                      {
	       Hash *h;
	       (yyval.node) = Swig_symbol_current();
	       h = Swig_symbol_clookup("    ",0);
	       if (h && (Strcmp(nodeType(h),"namespace") == 0)) {
		 Swig_symbol_setscope(Getattr(h,"symtab"));
	       } else {
		 Swig_symbol_newscope();
		 /* we don't use "__unnamed__", but a long 'empty' name */
		 Swig_symbol_setscopename("    ");
	       }
	       Namespaceprefix = 0;
             }
#line 8761 "parser.c"
    break;

  case 195: /* cpp_namespace_decl: NAMESPACE LBRACE @9 interface RBRACE  */
#line 4895 "parser.y"
                                      {
	       (yyval.node) = (yyvsp[-1].node);
	       set_nodeType((yyval.node),"namespace");
	       Setattr((yyval.node),"unnamed","1");
	       Setattr((yyval.node),"symtab", Swig_symbol_popscope());
	       Swig_symbol_setscope((yyvsp[-2].node));
	       Delete(Namespaceprefix);
	       Namespaceprefix = Swig_symbol_qualifiedscopename(0);
	       add_symbols((yyval.node));
             }
#line 8776 "parser.c"
    break;

  case 196: /* cpp_namespace_decl: NAMESPACE identifier EQUAL idcolon SEMI  */
#line 4905 "parser.y"
                                                       {
	       /* Namespace alias */
	       Node *n;
	       (yyval.node) = new_node("namespace");
	       Setattr((yyval.node),"name",(yyvsp[-3].id));
	       Setattr((yyval.node),"alias",(yyvsp[-1].str));
	       n = Swig_symbol_clookup((yyvsp[-1].str),0);
	       if (!n) {
		 Swig_error(cparse_file, cparse_line, "Unknown namespace '%s'\n", SwigType_namestr((yyvsp[-1].str)));
		 (yyval.node) = 0;
	       } else {
		 if (Strcmp(nodeType(n),"namespace") != 0) {
		   Swig_error(cparse_file, cparse_line, "'%s' is not a namespace\n", SwigType_namestr((yyvsp[-1].str)));
		   (yyval.node) = 0;
		 } else {
		   while (Getattr(n,"alias")) {
		     n = Getattr(n,"namespace");
		   }
		   Setattr((yyval.node),"namespace",n);
		   add_symbols((yyval.node));
		   /* Set up a scope alias */
		   Swig_symbol_alias((yyvsp[-3].id),Getattr(n,"symtab"));
		 }
	       }
             }
#line 8806 "parser.c"
    break;

  case 197: /* cpp_members: cpp_members_builder  */
#line 4932 "parser.y"
                                  {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 8814 "parser.c"
    break;

  case 198: /* cpp_members: cpp_members_builder DOXYGENSTRING  */
#line 4935 "parser.y"
                                                   {
		 /* Quietly ignore misplaced doxygen string after a member, like Doxygen does */
		 (yyval.node) = (yyvsp[-1].nodebuilder).node;
		 Delete((yyvsp[0].str));
	       }
#line 8824 "parser.c"
    break;

  case 199: /* cpp_members: %empty  */
#line 4940 "parser.y"
                        {
		 (yyval.node) = 0;
	       }
#line 8832 "parser.c"
    break;

  case 200: /* cpp_members: DOXYGENSTRING  */
#line 4943 "parser.y"
                               {
		 /* Quietly ignore misplaced doxygen string in empty class, like Doxygen does */
		 (yyval.node) = 0;
		 Delete((yyvsp[0].str));
	       }
#line 8842 "parser.c"
    break;

  case 201: /* cpp_members: error  */
#line 4948 "parser.y"
                       {
		 Swig_error(cparse_file, cparse_line, "Syntax error in input(3).\n");
		 Exit(EXIT_FAILURE);
	       }
#line 8851 "parser.c"
    break;

  case 202: /* cpp_members_builder: cpp_member  */
#line 4954 "parser.y"
                                 {
	     (yyval.nodebuilder).node = (yyval.nodebuilder).last = (yyvsp[0].node);
	   }
#line 8859 "parser.c"
    break;

  case 203: /* cpp_members_builder: cpp_members_builder cpp_member  */
#line 4957 "parser.y"
                                                {
	     // Build a linked list in the order specified, but avoiding
	     // a right recursion rule because "Right recursion uses up
	     // space on the Bison stack in proportion to the number of
	     // elements in the sequence".
	     if ((yyvsp[0].node)) {
	       if ((yyvsp[-1].nodebuilder).node) {
		 Node *last = (yyvsp[-1].nodebuilder).last;
		 /* Advance to the last sibling. */
		 for (Node *p = last; p; p = nextSibling(p)) {
		   last = p;
		 }
		 set_nextSibling(last, (yyvsp[0].node));
		 set_previousSibling((yyvsp[0].node), last);
		 (yyval.nodebuilder).node = (yyvsp[-1].nodebuilder).node;
	       } else {
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = (yyvsp[0].node);
	       }
	     } else {
	       (yyval.nodebuilder) = (yyvsp[-1].nodebuilder);
	     }
	   }
#line 8886 "parser.c"
    break;

  case 205: /* cpp_member_no_dox: cpp_constructor_decl  */
#line 4988 "parser.y"
                                    { 
                 (yyval.node) = (yyvsp[0].node); 
		 if (extendmode && current_class) {
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
             }
#line 8908 "parser.c"
    break;

  case 212: /* cpp_member_no_dox: storage_class idcolon SEMI  */
#line 5011 "parser.y"
                                          { (yyval.node) = 0; Delete((yyvsp[-2].str)); }
#line 8914 "parser.c"
    break;

  case 219: /* cpp_member_no_dox: anonymous_bitfield  */
#line 5018 "parser.y"
                                  { (yyval.node) = 0; }
#line 8920 "parser.c"
    break;

  case 222: /* cpp_member_no_dox: SEMI  */
#line 5021 "parser.y"
                    { (yyval.node) = 0; }
#line 8926 "parser.c"
    break;

  case 224: /* cpp_member: DOXYGENSTRING cpp_member_no_dox  */
#line 5024 "parser.y"
                                               {
	         (yyval.node) = (yyvsp[0].node);
		 set_comment((yyvsp[0].node), (yyvsp[-1].str));
	     }
#line 8935 "parser.c"
    break;

  case 225: /* cpp_member: cpp_member_no_dox DOXYGENPOSTSTRING  */
#line 5028 "parser.y"
                                                   {
	         (yyval.node) = (yyvsp[-1].node);
		 set_comment((yyvsp[-1].node), (yyvsp[0].str));
	     }
#line 8944 "parser.c"
    break;

  case 226: /* $@10: %empty  */
#line 5032 "parser.y"
                             {
	       extendmode = 1;
	       if (cplus_mode != CPLUS_PUBLIC) {
		 Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
	       }
	     }
#line 8955 "parser.c"
    break;

  case 227: /* cpp_member: EXTEND LBRACE $@10 cpp_members RBRACE  */
#line 5037 "parser.y"
                                  {
	       extendmode = 0;
	       (yyval.node) = new_node("extend");
	       mark_nodes_as_extend((yyvsp[-1].node));
	       appendChild((yyval.node), (yyvsp[-1].node));
	     }
#line 8966 "parser.c"
    break;

  case 228: /* cpp_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 5051 "parser.y"
                                                                       {
	      /* Cannot be a constructor declaration/definition if parsed as a friend destructor/constructor
	         or a badly declared friend function without return type */
	      int isfriend = Strstr((yyvsp[-5].str), "friend") != NULL;
	      if (!isfriend && (inclass || extendmode)) {
	        String *name = SwigType_templateprefix((yyvsp[-4].type)); /* A constructor can optionally be declared with template parameters before C++20, strip these off */
		SwigType *decl = NewStringEmpty();
		(yyval.node) = new_node("constructor");
		Setattr((yyval.node),"storage",(yyvsp[-5].str));
		Setattr((yyval.node), "name", name);
		Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		SwigType_add_function(decl,(yyvsp[-2].pl));
		Setattr((yyval.node),"decl",decl);
		Setattr((yyval.node),"throws",(yyvsp[0].decl).throws);
		Setattr((yyval.node),"throw",(yyvsp[0].decl).throwf);
		Setattr((yyval.node),"noexcept",(yyvsp[0].decl).nexcept);
		Setattr((yyval.node),"final",(yyvsp[0].decl).final);
		if (Len(scanner_ccode)) {
		  String *code = Copy(scanner_ccode);
		  Setattr((yyval.node),"code",code);
		  Delete(code);
		}
		SetFlag((yyval.node),"feature:new");
		if ((yyvsp[0].decl).defarg)
		  Setattr((yyval.node), "value", (yyvsp[0].decl).defarg);
		if ((yyvsp[0].decl).stringdefarg)
		  Setattr((yyval.node), "stringval", (yyvsp[0].decl).stringdefarg);
		if ((yyvsp[0].decl).numdefarg)
		  Setattr((yyval.node), "numval", (yyvsp[0].decl).numdefarg);
	      } else {
		(yyval.node) = 0;
              }
	      Delete((yyvsp[-5].str));
              }
#line 9005 "parser.c"
    break;

  case 229: /* cpp_destructor_decl: storage_class NOT idtemplate LPAREN parms RPAREN cpp_vend  */
#line 5089 "parser.y"
                                                                                {
	       String *name = SwigType_templateprefix((yyvsp[-4].str)); /* A destructor can optionally be declared with template parameters before C++20, strip these off */
	       Insert(name, 0, "~");
	       (yyval.node) = new_node("destructor");
	       Setattr((yyval.node), "storage", (yyvsp[-6].str));
	       Setattr((yyval.node), "name", name);
	       Delete(name);
	       if (Len(scanner_ccode)) {
		 String *code = Copy(scanner_ccode);
		 Setattr((yyval.node), "code", code);
		 Delete(code);
	       }
	       {
		 String *decl = NewStringEmpty();
		 SwigType_add_function(decl, (yyvsp[-2].pl));
		 Setattr((yyval.node), "decl", decl);
		 Delete(decl);
	       }
	       Setattr((yyval.node), "throws", (yyvsp[0].dtype).throws);
	       Setattr((yyval.node), "throw", (yyvsp[0].dtype).throwf);
	       Setattr((yyval.node), "noexcept", (yyvsp[0].dtype).nexcept);
	       Setattr((yyval.node), "final", (yyvsp[0].dtype).final);
	       if ((yyvsp[0].dtype).val) {
		 if (Equal((yyvsp[0].dtype).val, "0")) {
		   if (!Strstr((yyvsp[-6].str), "virtual"))
		     Swig_error(cparse_file, cparse_line, "Destructor %s uses a pure specifier but is not virtual.\n", Swig_name_decl((yyval.node)));
		 } else if (!(Equal((yyvsp[0].dtype).val, "delete") || Equal((yyvsp[0].dtype).val, "default"))) {
		   Swig_error(cparse_file, cparse_line, "Destructor %s has an invalid pure specifier, only = 0 is allowed.\n", Swig_name_decl((yyval.node)));
		 }
		 Setattr((yyval.node), "value", (yyvsp[0].dtype).val);
	       }
	       /* TODO: check all storage decl-specifiers are valid */
	       if ((yyvsp[0].dtype).qualifier)
		 Swig_error(cparse_file, cparse_line, "Destructor %s %s cannot have a qualifier.\n", Swig_name_decl((yyval.node)), SwigType_str((yyvsp[0].dtype).qualifier, 0));
	       add_symbols((yyval.node));
	       Delete((yyvsp[-6].str));
	      }
#line 9047 "parser.c"
    break;

  case 230: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer LPAREN parms RPAREN cpp_vend  */
#line 5130 "parser.y"
                                                                                                     {
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));

		 SwigType_add_function((yyvsp[-4].type),(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push((yyvsp[-4].type),(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",(yyvsp[-4].type));
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
              }
#line 9073 "parser.c"
    break;

  case 231: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type AND LPAREN parms RPAREN cpp_vend  */
#line 5151 "parser.y"
                                                                                        {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));
		 decl = NewStringEmpty();
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
	       }
#line 9101 "parser.c"
    break;

  case 232: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LAND LPAREN parms RPAREN cpp_vend  */
#line 5174 "parser.y"
                                                                                         {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-5].type));
		 Setattr((yyval.node),"name",(yyvsp[-6].str));
		 Setattr((yyval.node),"storage",(yyvsp[-7].str));
		 decl = NewStringEmpty();
		 SwigType_add_rvalue_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-6].str));
		 Delete((yyvsp[-7].str));
	       }
#line 9129 "parser.c"
    break;

  case 233: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer AND LPAREN parms RPAREN cpp_vend  */
#line 5198 "parser.y"
                                                                                                {
		 SwigType *decl;
                 (yyval.node) = new_node("cdecl");
                 Setattr((yyval.node),"type",(yyvsp[-6].type));
		 Setattr((yyval.node),"name",(yyvsp[-7].str));
		 Setattr((yyval.node),"storage",(yyvsp[-8].str));
		 decl = NewStringEmpty();
		 SwigType_add_pointer(decl);
		 SwigType_add_reference(decl);
		 SwigType_add_function(decl,(yyvsp[-2].pl));
		 if ((yyvsp[0].dtype).qualifier) {
		   SwigType_push(decl,(yyvsp[0].dtype).qualifier);
		 }
		 if ((yyvsp[0].dtype).val) {
		   Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		 }
		 Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		 Setattr((yyval.node),"decl",decl);
		 Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		 Setattr((yyval.node),"conversion_operator","1");
		 add_symbols((yyval.node));
		 Delete((yyvsp[-7].str));
		 Delete((yyvsp[-8].str));
	       }
#line 9158 "parser.c"
    break;

  case 234: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LPAREN parms RPAREN cpp_vend  */
#line 5223 "parser.y"
                                                                                   {
		String *t = NewStringEmpty();
		(yyval.node) = new_node("cdecl");
		Setattr((yyval.node),"type",(yyvsp[-4].type));
		Setattr((yyval.node),"name",(yyvsp[-5].str));
		 Setattr((yyval.node),"storage",(yyvsp[-6].str));
		SwigType_add_function(t,(yyvsp[-2].pl));
		if ((yyvsp[0].dtype).qualifier) {
		  SwigType_push(t,(yyvsp[0].dtype).qualifier);
		}
		if ((yyvsp[0].dtype).val) {
		  Setattr((yyval.node),"value",(yyvsp[0].dtype).val);
		}
		Setattr((yyval.node),"refqualifier",(yyvsp[0].dtype).refqualifier);
		Setattr((yyval.node),"decl",t);
		Setattr((yyval.node),"parms",(yyvsp[-2].pl));
		Setattr((yyval.node),"conversion_operator","1");
		add_symbols((yyval.node));
		Delete((yyvsp[-5].str));
		Delete((yyvsp[-6].str));
              }
#line 9184 "parser.c"
    break;

  case 235: /* cpp_catch_decl: CATCH LPAREN parms RPAREN LBRACE  */
#line 5248 "parser.y"
                                                  {
                 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                 (yyval.node) = 0;
               }
#line 9193 "parser.c"
    break;

  case 236: /* cpp_static_assert: STATIC_ASSERT LPAREN  */
#line 5256 "parser.y"
                                         {
                if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
                (yyval.node) = 0;
              }
#line 9202 "parser.c"
    break;

  case 237: /* cpp_protection_decl: PUBLIC COLON  */
#line 5263 "parser.y"
                                   { 
                (yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              }
#line 9212 "parser.c"
    break;

  case 238: /* cpp_protection_decl: PRIVATE COLON  */
#line 5270 "parser.y"
                              { 
                (yyval.node) = new_node("access");
                Setattr((yyval.node),"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      }
#line 9222 "parser.c"
    break;

  case 239: /* cpp_protection_decl: PROTECTED COLON  */
#line 5278 "parser.y"
                                { 
		(yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      }
#line 9232 "parser.c"
    break;

  case 250: /* cpp_vend: cpp_const SEMI  */
#line 5301 "parser.y"
                                { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 9241 "parser.c"
    break;

  case 251: /* cpp_vend: cpp_const EQUAL definetype SEMI  */
#line 5305 "parser.y"
                                                 { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-3].dtype);
                     (yyval.dtype).val = (yyvsp[-1].dtype).val;
               }
#line 9251 "parser.c"
    break;

  case 252: /* cpp_vend: cpp_const LBRACE  */
#line 5310 "parser.y"
                                  { 
                     if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 9260 "parser.c"
    break;

  case 253: /* anonymous_bitfield: storage_class anon_bitfield_type COLON expr SEMI  */
#line 5317 "parser.y"
                                                                       { Delete((yyvsp[-4].str)); }
#line 9266 "parser.c"
    break;

  case 257: /* anon_bitfield_type: idcolon  */
#line 5324 "parser.y"
                         { (yyval.type) = (yyvsp[0].str); }
#line 9272 "parser.c"
    break;

  case 258: /* storage_class: storage_class_list  */
#line 5330 "parser.y"
                                    {
		 String *r = NewStringEmpty();

		 /* Check for invalid combinations. */
		 if (multiple_bits_set((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERN |
					     SWIG_STORAGE_CLASS_STATIC))) {
		   Swig_error(cparse_file, cparse_line, "Storage class can't be both 'static' and 'extern'");
		 }
		 if (multiple_bits_set((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERNC |
					     SWIG_STORAGE_CLASS_EXTERN |
					     SWIG_STORAGE_CLASS_EXTERNCPP))) {
		   Swig_error(cparse_file, cparse_line, "Declaration can only be one of 'extern', 'extern \"C\"' and 'extern \"C++\"'");
		 }

		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_TYPEDEF) {
		   Append(r, "typedef ");
		 } else {
		   if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_EXTERNC)
		     Append(r, "externc ");
		   if ((yyvsp[0].intvalue) & (SWIG_STORAGE_CLASS_EXTERN|SWIG_STORAGE_CLASS_EXTERNCPP))
		     Append(r, "extern ");
		   if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_STATIC)
		     Append(r, "static ");
		 }
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_VIRTUAL)
		   Append(r, "virtual ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_FRIEND)
		   Append(r, "friend ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_EXPLICIT)
		   Append(r, "explicit ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_CONSTEXPR)
		   Append(r, "constexpr ");
		 if ((yyvsp[0].intvalue) & SWIG_STORAGE_CLASS_THREAD_LOCAL)
		   Append(r, "thread_local ");
		 if (Len(r) == 0) {
		   Delete(r);
		   (yyval.str) = 0;
		 } else {
		   Chop(r);
		   (yyval.str) = r;
		 }
	       }
#line 9319 "parser.c"
    break;

  case 259: /* storage_class: %empty  */
#line 5372 "parser.y"
                        { (yyval.str) = 0; }
#line 9325 "parser.c"
    break;

  case 261: /* storage_class_list: storage_class_list storage_class_raw  */
#line 5376 "parser.y"
                                                          {
		  if ((yyvsp[-1].intvalue) & (yyvsp[0].intvalue)) {
		    Swig_error(cparse_file, cparse_line, "Repeated storage class or type specifier '%s'\n", storage_class_string((yyvsp[0].intvalue)));
		  }
		  (yyval.intvalue) = (yyvsp[-1].intvalue) | (yyvsp[0].intvalue);
	       }
#line 9336 "parser.c"
    break;

  case 262: /* storage_class_raw: EXTERN  */
#line 5384 "parser.y"
                            { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERN; }
#line 9342 "parser.c"
    break;

  case 263: /* storage_class_raw: EXTERN string  */
#line 5385 "parser.y"
                               {
		   if (Strcmp((yyvsp[0].str),"C") == 0) {
		     (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERNC;
		   } else if (Strcmp((yyvsp[0].str),"C++") == 0) {
		     (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERNCPP;
		   } else {
		     Swig_warning(WARN_PARSE_UNDEFINED_EXTERN,cparse_file, cparse_line,"Unrecognized extern type \"%s\".\n", (yyvsp[0].str));
		     (yyval.intvalue) = 0;
		   }
	       }
#line 9357 "parser.c"
    break;

  case 264: /* storage_class_raw: STATIC  */
#line 5395 "parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_STATIC; }
#line 9363 "parser.c"
    break;

  case 265: /* storage_class_raw: TYPEDEF  */
#line 5396 "parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_TYPEDEF; }
#line 9369 "parser.c"
    break;

  case 266: /* storage_class_raw: VIRTUAL  */
#line 5397 "parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_VIRTUAL; }
#line 9375 "parser.c"
    break;

  case 267: /* storage_class_raw: FRIEND  */
#line 5398 "parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_FRIEND; }
#line 9381 "parser.c"
    break;

  case 268: /* storage_class_raw: EXPLICIT  */
#line 5399 "parser.y"
                          { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXPLICIT; }
#line 9387 "parser.c"
    break;

  case 269: /* storage_class_raw: CONSTEXPR  */
#line 5400 "parser.y"
                           { (yyval.intvalue) = SWIG_STORAGE_CLASS_CONSTEXPR; }
#line 9393 "parser.c"
    break;

  case 270: /* storage_class_raw: THREAD_LOCAL  */
#line 5401 "parser.y"
                              { (yyval.intvalue) = SWIG_STORAGE_CLASS_THREAD_LOCAL; }
#line 9399 "parser.c"
    break;

  case 271: /* parms: rawparms  */
#line 5408 "parser.y"
                          {
                 Parm *p;
		 (yyval.pl) = (yyvsp[0].pl);
		 p = (yyvsp[0].pl);
                 while (p) {
		   Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   p = nextSibling(p);
                 }
               }
#line 9413 "parser.c"
    break;

  case 272: /* rawparms: parm  */
#line 5420 "parser.y"
                       { (yyval.pl) = (yyvsp[0].p); }
#line 9419 "parser.c"
    break;

  case 273: /* rawparms: parm DOXYGENPOSTSTRING  */
#line 5421 "parser.y"
                                         {
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 9428 "parser.c"
    break;

  case 274: /* rawparms: parm DOXYGENSTRING  */
#line 5425 "parser.y"
                                     {
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 9438 "parser.c"
    break;

  case 275: /* rawparms: parm COMMA parms  */
#line 5430 "parser.y"
                                   {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-2].p), (yyvsp[0].pl));
		  }
		  (yyval.pl) = (yyvsp[-2].p);
		}
#line 9449 "parser.c"
    break;

  case 276: /* rawparms: parm DOXYGENPOSTSTRING COMMA parms  */
#line 5436 "parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-2].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 9461 "parser.c"
    break;

  case 277: /* rawparms: parm COMMA DOXYGENPOSTSTRING parms  */
#line 5443 "parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-1].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 9473 "parser.c"
    break;

  case 278: /* rawparms: %empty  */
#line 5450 "parser.y"
                         {
		  (yyval.pl) = 0;
		}
#line 9481 "parser.c"
    break;

  case 279: /* parm_no_dox: rawtype parameter_declarator  */
#line 5455 "parser.y"
                                               {
                   SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		   (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[-1].type),(yyvsp[0].decl).id);
		   Setfile((yyval.p),cparse_file);
		   Setline((yyval.p),cparse_line);
		   if ((yyvsp[0].decl).defarg)
		     Setattr((yyval.p), "value", (yyvsp[0].decl).defarg);
		   if ((yyvsp[0].decl).stringdefarg)
		     Setattr((yyval.p), "stringval", (yyvsp[0].decl).stringdefarg);
		   if ((yyvsp[0].decl).numdefarg)
		     Setattr((yyval.p), "numval", (yyvsp[0].decl).numdefarg);
		}
#line 9498 "parser.c"
    break;

  case 280: /* parm_no_dox: ELLIPSIS  */
#line 5467 "parser.y"
                           {
		  SwigType *t = NewString("v(...)");
		  (yyval.p) = NewParmWithoutFileLineInfo(t, 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		}
#line 9509 "parser.c"
    break;

  case 282: /* parm: DOXYGENSTRING parm_no_dox  */
#line 5476 "parser.y"
                                            {
		  (yyval.p) = (yyvsp[0].p);
		  set_comment((yyvsp[0].p), (yyvsp[-1].str));
		}
#line 9518 "parser.c"
    break;

  case 283: /* valparms: valparms_builder  */
#line 5482 "parser.y"
                            {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
                 for (Parm *p = (yyval.p); p; p = nextSibling(p)) {
		   if (Getattr(p,"type")) {
		     Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   }
                 }
	       }
#line 9531 "parser.c"
    break;

  case 284: /* valparms: %empty  */
#line 5490 "parser.y"
                        {
		 (yyval.p) = 0;
	       }
#line 9539 "parser.c"
    break;

  case 285: /* valparms_builder: valparm  */
#line 5495 "parser.y"
                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9547 "parser.c"
    break;

  case 286: /* valparms_builder: valparms_builder COMMA valparm  */
#line 5498 "parser.y"
                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9561 "parser.c"
    break;

  case 287: /* valparm: parm  */
#line 5509 "parser.y"
                      {
		  (yyval.p) = (yyvsp[0].p);
		  {
		    /* We need to make a possible adjustment for integer parameters. */
		    SwigType *type;
		    Node     *n = 0;

		    while (!n) {
		      type = Getattr((yyvsp[0].p),"type");
		      n = Swig_symbol_clookup(type,0);     /* See if we can find a node that matches the typename */
		      if ((n) && (Strcmp(nodeType(n),"cdecl") == 0)) {
			SwigType *decl = Getattr(n,"decl");
			if (!SwigType_isfunction(decl)) {
			  String *value = Getattr(n,"value");
			  if (value) {
			    String *v = Copy(value);
			    Setattr((yyvsp[0].p),"type",v);
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
#line 9594 "parser.c"
    break;

  case 288: /* valparm: valexpr  */
#line 5537 "parser.y"
                         {
                  (yyval.p) = NewParmWithoutFileLineInfo(0,0);
                  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		  Setattr((yyval.p),"value",(yyvsp[0].dtype).val);
		  if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		  if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
               }
#line 9607 "parser.c"
    break;

  case 289: /* def_args: EQUAL definetype  */
#line 5547 "parser.y"
                                  { 
                 (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 9615 "parser.c"
    break;

  case 290: /* def_args: EQUAL definetype LBRACKET  */
#line 5550 "parser.y"
                                           {
		 if (skip_balanced('[', ']') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).type = T_UNKNOWN;
		 (yyval.dtype).val = (yyvsp[-1].dtype).val;
		 Append((yyval.dtype).val, scanner_ccode);
		 Clear(scanner_ccode);
               }
#line 9628 "parser.c"
    break;

  case 291: /* def_args: EQUAL LBRACE  */
#line 5558 "parser.y"
                              {
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewString(scanner_ccode);
		 (yyval.dtype).type = T_UNKNOWN;
	       }
#line 9639 "parser.c"
    break;

  case 292: /* def_args: %empty  */
#line 5564 "parser.y"
                        {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).type = T_UNKNOWN;
               }
#line 9648 "parser.c"
    break;

  case 293: /* parameter_declarator: declarator def_args  */
#line 5570 "parser.y"
                                           {
                 (yyval.decl) = (yyvsp[-1].decl);
		 (yyval.decl).defarg = (yyvsp[0].dtype).val;
		 (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
		 (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9659 "parser.c"
    break;

  case 294: /* parameter_declarator: abstract_declarator def_args  */
#line 5576 "parser.y"
                                           {
	      (yyval.decl) = (yyvsp[-1].decl);
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9670 "parser.c"
    break;

  case 295: /* parameter_declarator: def_args  */
#line 5582 "parser.y"
                       {
	      (yyval.decl) = default_decl;
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9681 "parser.c"
    break;

  case 296: /* parameter_declarator: direct_declarator LPAREN parms RPAREN qualifiers_exception_specification  */
#line 5590 "parser.y"
                                                                                       {
	      SwigType *t;
	      (yyval.decl) = (yyvsp[-4].decl);
	      t = NewStringEmpty();
	      SwigType_add_function(t,(yyvsp[-2].pl));
	      if ((yyvsp[0].dtype).qualifier)
		SwigType_push(t, (yyvsp[0].dtype).qualifier);
	      if ((yyvsp[0].dtype).nexcept)
		SwigType_add_qualifier(t, "noexcept");
	      if (!(yyval.decl).have_parms) {
		(yyval.decl).parms = (yyvsp[-2].pl);
		(yyval.decl).have_parms = 1;
	      }
	      if (!(yyval.decl).type) {
		(yyval.decl).type = t;
	      } else {
		SwigType_push(t, (yyval.decl).type);
		Delete((yyval.decl).type);
		(yyval.decl).type = t;
	      }
	    }
#line 9707 "parser.c"
    break;

  case 297: /* plain_declarator: declarator  */
#line 5613 "parser.y"
                              {
                 (yyval.decl) = (yyvsp[0].decl);
		 if (SwigType_isfunction((yyvsp[0].decl).type)) {
		   Delete(SwigType_pop_function((yyvsp[0].decl).type));
		 } else if (SwigType_isarray((yyvsp[0].decl).type)) {
		   SwigType *ta = SwigType_pop_arrays((yyvsp[0].decl).type);
		   if (SwigType_isfunction((yyvsp[0].decl).type)) {
		     Delete(SwigType_pop_function((yyvsp[0].decl).type));
		   } else {
		     (yyval.decl).parms = 0;
		   }
		   SwigType_push((yyvsp[0].decl).type,ta);
		   Delete(ta);
		 } else {
		   (yyval.decl).parms = 0;
		 }
            }
#line 9729 "parser.c"
    break;

  case 298: /* plain_declarator: abstract_declarator  */
#line 5630 "parser.y"
                                  {
              (yyval.decl) = (yyvsp[0].decl);
	      if (SwigType_isfunction((yyvsp[0].decl).type)) {
		Delete(SwigType_pop_function((yyvsp[0].decl).type));
	      } else if (SwigType_isarray((yyvsp[0].decl).type)) {
		SwigType *ta = SwigType_pop_arrays((yyvsp[0].decl).type);
		if (SwigType_isfunction((yyvsp[0].decl).type)) {
		  Delete(SwigType_pop_function((yyvsp[0].decl).type));
		} else {
		  (yyval.decl).parms = 0;
		}
		SwigType_push((yyvsp[0].decl).type,ta);
		Delete(ta);
	      } else {
		(yyval.decl).parms = 0;
	      }
            }
#line 9751 "parser.c"
    break;

  case 299: /* plain_declarator: direct_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 5649 "parser.y"
                                                                     {
	      SwigType *t;
	      (yyval.decl) = (yyvsp[-4].decl);
	      t = NewStringEmpty();
	      SwigType_add_function(t, (yyvsp[-2].pl));
	      if ((yyvsp[0].dtype).qualifier)
	        SwigType_push(t, (yyvsp[0].dtype).qualifier);
	      if (!(yyval.decl).have_parms) {
		(yyval.decl).parms = (yyvsp[-2].pl);
		(yyval.decl).have_parms = 1;
	      }
	      if (!(yyval.decl).type) {
		(yyval.decl).type = t;
	      } else {
		SwigType_push(t, (yyval.decl).type);
		Delete((yyval.decl).type);
		(yyval.decl).type = t;
	      }
	    }
#line 9775 "parser.c"
    break;

  case 300: /* plain_declarator: %empty  */
#line 5668 "parser.y"
                     {
	      (yyval.decl) = default_decl;
	    }
#line 9783 "parser.c"
    break;

  case 301: /* declarator: pointer notso_direct_declarator  */
#line 5673 "parser.y"
                                              {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-1].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-1].type);
           }
#line 9796 "parser.c"
    break;

  case 302: /* declarator: pointer AND notso_direct_declarator  */
#line 5681 "parser.y"
                                                 {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 9810 "parser.c"
    break;

  case 303: /* declarator: pointer LAND notso_direct_declarator  */
#line 5690 "parser.y"
                                                  {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_rvalue_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 9824 "parser.c"
    break;

  case 304: /* declarator: direct_declarator  */
#line 5699 "parser.y"
                               {
              (yyval.decl) = (yyvsp[0].decl);
	      if (!(yyval.decl).type) (yyval.decl).type = NewStringEmpty();
           }
#line 9833 "parser.c"
    break;

  case 305: /* declarator: AND notso_direct_declarator  */
#line 5703 "parser.y"
                                         {
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 9847 "parser.c"
    break;

  case 306: /* declarator: LAND notso_direct_declarator  */
#line 5712 "parser.y"
                                          {
	     /* Introduced in C++11, move operator && */
             /* Adds one S/R conflict */
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_rvalue_reference((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 9863 "parser.c"
    break;

  case 307: /* declarator: idcolon DSTAR notso_direct_declarator  */
#line 5723 "parser.y"
                                                   { 
	     SwigType *t = NewStringEmpty();

	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-2].str));
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = t;
	     }
#line 9879 "parser.c"
    break;

  case 308: /* declarator: pointer idcolon DSTAR notso_direct_declarator  */
#line 5734 "parser.y"
                                                           { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-2].str));
	     SwigType_push((yyvsp[-3].type),t);
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-3].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-3].type);
	     Delete(t);
	   }
#line 9896 "parser.c"
    break;

  case 309: /* declarator: pointer idcolon DSTAR AND notso_direct_declarator  */
#line 5746 "parser.y"
                                                               { 
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-4].type),(yyvsp[-3].str));
	     SwigType_add_reference((yyvsp[-4].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-4].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-4].type);
	   }
#line 9911 "parser.c"
    break;

  case 310: /* declarator: idcolon DSTAR AND notso_direct_declarator  */
#line 5756 "parser.y"
                                                       { 
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_reference(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 9927 "parser.c"
    break;

  case 311: /* declarator: pointer ELLIPSIS notso_direct_declarator  */
#line 5770 "parser.y"
                                                       {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 9941 "parser.c"
    break;

  case 312: /* declarator: pointer AND ELLIPSIS notso_direct_declarator  */
#line 5779 "parser.y"
                                                          {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_reference((yyvsp[-3].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-3].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 9956 "parser.c"
    break;

  case 313: /* declarator: pointer LAND ELLIPSIS notso_direct_declarator  */
#line 5789 "parser.y"
                                                           {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_rvalue_reference((yyvsp[-3].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-3].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 9971 "parser.c"
    break;

  case 314: /* declarator: AND ELLIPSIS notso_direct_declarator  */
#line 5799 "parser.y"
                                                  {
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     SwigType_add_variadic((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 9986 "parser.c"
    break;

  case 315: /* declarator: LAND ELLIPSIS notso_direct_declarator  */
#line 5809 "parser.y"
                                                   {
	     /* Introduced in C++11, move operator && */
             /* Adds one S/R conflict */
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_rvalue_reference((yyval.decl).type);
	     SwigType_add_variadic((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 10003 "parser.c"
    break;

  case 316: /* declarator: idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 5821 "parser.y"
                                                            {
	     SwigType *t = NewStringEmpty();

	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = t;
	     }
#line 10020 "parser.c"
    break;

  case 317: /* declarator: pointer idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 5833 "parser.y"
                                                                    {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-3].str));
	     SwigType_add_variadic(t);
	     SwigType_push((yyvsp[-4].type),t);
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-4].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-4].type);
	     Delete(t);
	   }
#line 10038 "parser.c"
    break;

  case 318: /* declarator: pointer idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 5846 "parser.y"
                                                                        {
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-5].type),(yyvsp[-4].str));
	     SwigType_add_reference((yyvsp[-5].type));
	     SwigType_add_variadic((yyvsp[-5].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-5].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-5].type);
	   }
#line 10054 "parser.c"
    break;

  case 319: /* declarator: pointer idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 5857 "parser.y"
                                                                         {
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer((yyvsp[-5].type),(yyvsp[-4].str));
	     SwigType_add_rvalue_reference((yyvsp[-5].type));
	     SwigType_add_variadic((yyvsp[-5].type));
	     if ((yyval.decl).type) {
	       SwigType_push((yyvsp[-5].type),(yyval.decl).type);
	       Delete((yyval.decl).type);
	     }
	     (yyval.decl).type = (yyvsp[-5].type);
	   }
#line 10070 "parser.c"
    break;

  case 320: /* declarator: idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 5868 "parser.y"
                                                                {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-4].str));
	     SwigType_add_reference(t);
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 10087 "parser.c"
    break;

  case 321: /* declarator: idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 5880 "parser.y"
                                                                 {
	     SwigType *t = NewStringEmpty();
	     (yyval.decl) = (yyvsp[0].decl);
	     SwigType_add_memberpointer(t,(yyvsp[-4].str));
	     SwigType_add_rvalue_reference(t);
	     SwigType_add_variadic(t);
	     if ((yyval.decl).type) {
	       SwigType_push(t,(yyval.decl).type);
	       Delete((yyval.decl).type);
	     } 
	     (yyval.decl).type = t;
	   }
#line 10104 "parser.c"
    break;

  case 322: /* notso_direct_declarator: idcolon  */
#line 5894 "parser.y"
                                  {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 10114 "parser.c"
    break;

  case 323: /* notso_direct_declarator: NOT idcolon  */
#line 5899 "parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 10123 "parser.c"
    break;

  case 324: /* notso_direct_declarator: LPAREN idcolon RPAREN  */
#line 5905 "parser.y"
                                         {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char((yyvsp[-1].str));
                  }
#line 10132 "parser.c"
    break;

  case 325: /* notso_direct_declarator: LPAREN pointer notso_direct_declarator RPAREN  */
#line 5917 "parser.y"
                                                                      {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10145 "parser.c"
    break;

  case 326: /* notso_direct_declarator: LPAREN idcolon DSTAR notso_direct_declarator RPAREN  */
#line 5925 "parser.y"
                                                                            {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		    }
#line 10161 "parser.c"
    break;

  case 327: /* notso_direct_declarator: notso_direct_declarator LBRACKET RBRACKET  */
#line 5936 "parser.y"
                                                                  { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10177 "parser.c"
    break;

  case 328: /* notso_direct_declarator: notso_direct_declarator LBRACKET expr RBRACKET  */
#line 5947 "parser.y"
                                                                       { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10193 "parser.c"
    break;

  case 329: /* notso_direct_declarator: notso_direct_declarator LPAREN parms RPAREN  */
#line 5958 "parser.y"
                                                                    {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  }
#line 10215 "parser.c"
    break;

  case 330: /* direct_declarator: idcolon  */
#line 5977 "parser.y"
                            {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 10225 "parser.c"
    break;

  case 331: /* direct_declarator: NOT idcolon  */
#line 5983 "parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 10234 "parser.c"
    break;

  case 332: /* direct_declarator: LPAREN pointer direct_declarator RPAREN  */
#line 5996 "parser.y"
                                                                {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10247 "parser.c"
    break;

  case 333: /* direct_declarator: LPAREN AND direct_declarator RPAREN  */
#line 6004 "parser.y"
                                                            {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_reference((yyval.decl).type);
                  }
#line 10259 "parser.c"
    break;

  case 334: /* direct_declarator: LPAREN LAND direct_declarator RPAREN  */
#line 6011 "parser.y"
                                                             {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_rvalue_reference((yyval.decl).type);
                  }
#line 10271 "parser.c"
    break;

  case 335: /* direct_declarator: LPAREN idcolon DSTAR declarator RPAREN  */
#line 6018 "parser.y"
                                                           {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t,(yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 10287 "parser.c"
    break;

  case 336: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier declarator RPAREN  */
#line 6029 "parser.y"
                                                                          {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-4].str));
		    SwigType_push(t, (yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 10304 "parser.c"
    break;

  case 337: /* direct_declarator: LPAREN idcolon DSTAR abstract_declarator RPAREN  */
#line 6041 "parser.y"
                                                                    {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-3].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 10320 "parser.c"
    break;

  case 338: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier abstract_declarator RPAREN  */
#line 6052 "parser.y"
                                                                                   {
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-1].decl);
		    t = NewStringEmpty();
		    SwigType_add_memberpointer(t, (yyvsp[-4].str));
		    SwigType_push(t, (yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
		  }
#line 10337 "parser.c"
    break;

  case 339: /* direct_declarator: direct_declarator LBRACKET RBRACKET  */
#line 6064 "parser.y"
                                                            { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10353 "parser.c"
    break;

  case 340: /* direct_declarator: direct_declarator LBRACKET expr RBRACKET  */
#line 6075 "parser.y"
                                                                 { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10369 "parser.c"
    break;

  case 341: /* direct_declarator: direct_declarator LPAREN parms RPAREN  */
#line 6086 "parser.y"
                                                              {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t, (yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		  }
#line 10391 "parser.c"
    break;

  case 342: /* direct_declarator: OPERATOR ID LPAREN parms RPAREN  */
#line 6106 "parser.y"
                                                   {
		    (yyval.decl) = default_decl;
		    SwigType *t;
                    Append((yyvsp[-4].str), " "); /* intervening space is mandatory */
		    Append((yyvsp[-4].str), (yyvsp[-3].id));
		    (yyval.decl).id = Char((yyvsp[-4].str));
		    t = NewStringEmpty();
		    SwigType_add_function(t,(yyvsp[-1].pl));
		    (yyval.decl).parms = (yyvsp[-1].pl);
		    (yyval.decl).have_parms = 1;
		    (yyval.decl).type = t;
		  }
#line 10408 "parser.c"
    break;

  case 343: /* abstract_declarator: pointer variadic_opt  */
#line 6120 "parser.y"
                                           {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-1].type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10418 "parser.c"
    break;

  case 344: /* abstract_declarator: pointer direct_abstract_declarator  */
#line 6125 "parser.y"
                                                       { 
                     (yyval.decl) = (yyvsp[0].decl);
                     SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		     (yyval.decl).type = (yyvsp[-1].type);
		     Delete((yyvsp[0].decl).type);
                  }
#line 10429 "parser.c"
    break;

  case 345: /* abstract_declarator: pointer AND variadic_opt  */
#line 6131 "parser.y"
                                             {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 10440 "parser.c"
    break;

  case 346: /* abstract_declarator: pointer LAND variadic_opt  */
#line 6137 "parser.y"
                                              {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 10451 "parser.c"
    break;

  case 347: /* abstract_declarator: pointer AND direct_abstract_declarator  */
#line 6143 "parser.y"
                                                           {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10465 "parser.c"
    break;

  case 348: /* abstract_declarator: pointer LAND direct_abstract_declarator  */
#line 6152 "parser.y"
                                                            {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_rvalue_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10479 "parser.c"
    break;

  case 350: /* abstract_declarator: AND direct_abstract_declarator  */
#line 6162 "parser.y"
                                                   {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 10493 "parser.c"
    break;

  case 351: /* abstract_declarator: LAND direct_abstract_declarator  */
#line 6171 "parser.y"
                                                    {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 10507 "parser.c"
    break;

  case 352: /* abstract_declarator: AND variadic_opt  */
#line 6180 "parser.y"
                                     {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10518 "parser.c"
    break;

  case 353: /* abstract_declarator: LAND variadic_opt  */
#line 6186 "parser.y"
                                      {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10529 "parser.c"
    break;

  case 354: /* abstract_declarator: idcolon DSTAR  */
#line 6192 "parser.y"
                                  { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_memberpointer((yyval.decl).type,(yyvsp[-1].str));
      	          }
#line 10539 "parser.c"
    break;

  case 355: /* abstract_declarator: idcolon DSTAR type_qualifier  */
#line 6197 "parser.y"
                                                 {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_memberpointer((yyval.decl).type, (yyvsp[-2].str));
		    SwigType_push((yyval.decl).type, (yyvsp[0].str));
		  }
#line 10550 "parser.c"
    break;

  case 356: /* abstract_declarator: pointer idcolon DSTAR  */
#line 6203 "parser.y"
                                          { 
		    (yyval.decl) = default_decl;
		    SwigType *t = NewStringEmpty();
                    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_memberpointer(t,(yyvsp[-1].str));
		    SwigType_push((yyval.decl).type,t);
		    Delete(t);
                  }
#line 10563 "parser.c"
    break;

  case 357: /* abstract_declarator: pointer idcolon DSTAR direct_abstract_declarator  */
#line 6211 "parser.y"
                                                                     { 
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_memberpointer((yyvsp[-3].type),(yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-3].type);
                  }
#line 10577 "parser.c"
    break;

  case 358: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET RBRACKET  */
#line 6222 "parser.y"
                                                                              { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-2].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,"");
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10593 "parser.c"
    break;

  case 359: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET expr RBRACKET  */
#line 6233 "parser.y"
                                                                          { 
		    SwigType *t;
		    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
		    SwigType_add_array(t,(yyvsp[-1].dtype).val);
		    if ((yyval.decl).type) {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = t;
                  }
#line 10609 "parser.c"
    break;

  case 360: /* direct_abstract_declarator: LBRACKET RBRACKET  */
#line 6244 "parser.y"
                                      { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,"");
                  }
#line 10619 "parser.c"
    break;

  case 361: /* direct_abstract_declarator: LBRACKET expr RBRACKET  */
#line 6249 "parser.y"
                                           { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,(yyvsp[-1].dtype).val);
		  }
#line 10629 "parser.c"
    break;

  case 362: /* direct_abstract_declarator: LPAREN abstract_declarator RPAREN  */
#line 6254 "parser.y"
                                                      {
                    (yyval.decl) = (yyvsp[-1].decl);
		  }
#line 10637 "parser.c"
    break;

  case 363: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN  */
#line 6257 "parser.y"
                                                                       {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-3].decl);
		    t = NewStringEmpty();
                    SwigType_add_function(t,(yyvsp[-1].pl));
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-1].pl);
		      (yyval.decl).have_parms = 1;
		    }
		  }
#line 10659 "parser.c"
    break;

  case 364: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 6274 "parser.y"
                                                                                        {
		    SwigType *t;
                    (yyval.decl) = (yyvsp[-4].decl);
		    t = NewStringEmpty();
                    SwigType_add_function(t,(yyvsp[-2].pl));
		    SwigType_push(t, (yyvsp[0].dtype).qualifier);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = t;
		    } else {
		      SwigType_push(t,(yyval.decl).type);
		      Delete((yyval.decl).type);
		      (yyval.decl).type = t;
		    }
		    if (!(yyval.decl).have_parms) {
		      (yyval.decl).parms = (yyvsp[-2].pl);
		      (yyval.decl).have_parms = 1;
		    }
		  }
#line 10682 "parser.c"
    break;

  case 365: /* direct_abstract_declarator: LPAREN parms RPAREN  */
#line 6292 "parser.y"
                                        {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_function((yyval.decl).type,(yyvsp[-1].pl));
		    (yyval.decl).parms = (yyvsp[-1].pl);
		    (yyval.decl).have_parms = 1;
                  }
#line 10694 "parser.c"
    break;

  case 366: /* pointer: pointer STAR type_qualifier  */
#line 6302 "parser.y"
                                             {
	     (yyval.type) = (yyvsp[-2].type);
             SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 10704 "parser.c"
    break;

  case 367: /* pointer: pointer STAR  */
#line 6307 "parser.y"
                              {
	     (yyval.type) = (yyvsp[-1].type);
	     SwigType_add_pointer((yyval.type));
	   }
#line 10713 "parser.c"
    break;

  case 368: /* pointer: STAR type_qualifier  */
#line 6311 "parser.y"
                                 {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 10723 "parser.c"
    break;

  case 369: /* pointer: STAR  */
#line 6316 "parser.y"
                  {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
           }
#line 10732 "parser.c"
    break;

  case 370: /* cv_ref_qualifier: type_qualifier  */
#line 6323 "parser.y"
                                  {
		  (yyval.dtype).qualifier = (yyvsp[0].str);
	       }
#line 10740 "parser.c"
    break;

  case 371: /* cv_ref_qualifier: type_qualifier ref_qualifier  */
#line 6326 "parser.y"
                                              {
		  (yyval.dtype).qualifier = (yyvsp[-1].str);
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 10750 "parser.c"
    break;

  case 372: /* cv_ref_qualifier: ref_qualifier  */
#line 6331 "parser.y"
                               {
		  (yyval.dtype).qualifier = NewStringEmpty();
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 10760 "parser.c"
    break;

  case 373: /* ref_qualifier: AND  */
#line 6338 "parser.y"
                    {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_reference((yyval.str));
	       }
#line 10769 "parser.c"
    break;

  case 374: /* ref_qualifier: LAND  */
#line 6342 "parser.y"
                      {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_rvalue_reference((yyval.str));
	       }
#line 10778 "parser.c"
    break;

  case 375: /* type_qualifier: type_qualifier_raw  */
#line 6348 "parser.y"
                                    {
	          (yyval.str) = NewStringEmpty();
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 10787 "parser.c"
    break;

  case 376: /* type_qualifier: type_qualifier type_qualifier_raw  */
#line 6352 "parser.y"
                                                       {
		  (yyval.str) = (yyvsp[-1].str);
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 10796 "parser.c"
    break;

  case 377: /* type_qualifier_raw: CONST_QUAL  */
#line 6358 "parser.y"
                                 { (yyval.id) = "const"; }
#line 10802 "parser.c"
    break;

  case 378: /* type_qualifier_raw: VOLATILE  */
#line 6359 "parser.y"
                               { (yyval.id) = "volatile"; }
#line 10808 "parser.c"
    break;

  case 379: /* type_qualifier_raw: REGISTER  */
#line 6360 "parser.y"
                               { (yyval.id) = 0; }
#line 10814 "parser.c"
    break;

  case 380: /* type: rawtype  */
#line 6366 "parser.y"
                                    {
                   (yyval.type) = (yyvsp[0].type);
                   Replace((yyval.type),"typename ","", DOH_REPLACE_ANY);
                }
#line 10823 "parser.c"
    break;

  case 381: /* rawtype: type_qualifier type_right  */
#line 6372 "parser.y"
                                           {
                   (yyval.type) = (yyvsp[0].type);
	           SwigType_push((yyval.type),(yyvsp[-1].str));
               }
#line 10832 "parser.c"
    break;

  case 383: /* rawtype: type_right type_qualifier  */
#line 6377 "parser.y"
                                           {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	       }
#line 10841 "parser.c"
    break;

  case 384: /* rawtype: type_qualifier type_right type_qualifier  */
#line 6381 "parser.y"
                                                                                            {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	          SwigType_push((yyval.type),(yyvsp[-2].str));
	       }
#line 10851 "parser.c"
    break;

  case 385: /* rawtype: rawtype ELLIPSIS  */
#line 6386 "parser.y"
                                      {
		  (yyval.type) = (yyvsp[-1].type);
		  SwigType_add_variadic((yyval.type));
	       }
#line 10860 "parser.c"
    break;

  case 389: /* type_right: c_enum_key idcolon  */
#line 6395 "parser.y"
                                    { (yyval.type) = NewStringf("enum %s", (yyvsp[0].str)); }
#line 10866 "parser.c"
    break;

  case 390: /* type_right: idcolon  */
#line 6397 "parser.y"
                                   {
		  (yyval.type) = (yyvsp[0].str);
               }
#line 10874 "parser.c"
    break;

  case 391: /* type_right: cpptype idcolon  */
#line 6400 "parser.y"
                                           {
		 (yyval.type) = NewStringf("%s %s", (yyvsp[-1].type), (yyvsp[0].str));
               }
#line 10882 "parser.c"
    break;

  case 393: /* @11: %empty  */
#line 6406 "parser.y"
                                      {
		 (yyval.str) = get_raw_text_balanced('(', ')');
	       }
#line 10890 "parser.c"
    break;

  case 394: /* decltype: DECLTYPE LPAREN @11 decltypeexpr  */
#line 6408 "parser.y"
                                    {
		 String *expr = (yyvsp[-1].str);
		 if ((yyvsp[0].type)) {
		   (yyval.type) = (yyvsp[0].type);
		 } else {
		   (yyval.type) = NewStringf("decltype%s", expr);
		   /* expr includes parentheses but don't include them in the warning message. */
		   Delitem(expr, 0);
		   Delitem(expr, DOH_END);
		   Swig_warning(WARN_CPP11_DECLTYPE, cparse_file, cparse_line, "Unable to deduce decltype for '%s'.\n", expr);
		 }
		 Delete(expr);
	       }
#line 10908 "parser.c"
    break;

  case 395: /* decltypeexpr: expr RPAREN  */
#line 6423 "parser.y"
                             {
		 (yyval.type) = deduce_type(&(yyvsp[-1].dtype));
	       }
#line 10916 "parser.c"
    break;

  case 396: /* decltypeexpr: error RPAREN  */
#line 6426 "parser.y"
                              {
		 /* Avoid a parse error if we can't parse the expression
		  * decltype() is applied to.
		  *
		  * Set $$ to 0 here to trigger the decltype rule above to
		  * issue a warning.
		  */
		 (yyval.type) = 0;
		 if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		 Clear(scanner_ccode);
	       }
#line 10932 "parser.c"
    break;

  case 397: /* primitive_type: primitive_type_list  */
#line 6439 "parser.y"
                                     {
		 String *type = (yyvsp[0].ptype).type;
		 if (!type) type = NewString("int");
		 if ((yyvsp[0].ptype).us) {
		   (yyval.type) = NewStringf("%s %s", (yyvsp[0].ptype).us, type);
		   Delete((yyvsp[0].ptype).us);
                   Delete(type);
		 } else {
                   (yyval.type) = type;
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
               }
#line 10961 "parser.c"
    break;

  case 399: /* primitive_type_list: type_specifier primitive_type_list  */
#line 6466 "parser.y"
                                                        {
                    if ((yyvsp[-1].ptype).us && (yyvsp[0].ptype).us) {
		      Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[0].ptype).us);
		    }
                    (yyval.ptype) = (yyvsp[0].ptype);
                    if ((yyvsp[-1].ptype).us) (yyval.ptype).us = (yyvsp[-1].ptype).us;
		    if ((yyvsp[-1].ptype).type) {
		      if (!(yyvsp[0].ptype).type) (yyval.ptype).type = (yyvsp[-1].ptype).type;
		      else {
			int err = 0;
			if ((Cmp((yyvsp[-1].ptype).type,"long") == 0)) {
			  if ((Cmp((yyvsp[0].ptype).type,"long") == 0) || (Strncmp((yyvsp[0].ptype).type,"double",6) == 0)) {
			    (yyval.ptype).type = NewStringf("long %s", (yyvsp[0].ptype).type);
			  } else if (Cmp((yyvsp[0].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[-1].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if ((Cmp((yyvsp[-1].ptype).type,"short")) == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"int") == 0) {
			    (yyval.ptype).type = (yyvsp[-1].ptype).type;
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"int") == 0) {
			  (yyval.ptype).type = (yyvsp[0].ptype).type;
			} else if (Cmp((yyvsp[-1].ptype).type,"double") == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"long") == 0) {
			    (yyval.ptype).type = NewString("long double");
			  } else if (Cmp((yyvsp[0].ptype).type,"_Complex") == 0) {
			    (yyval.ptype).type = NewString("double _Complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"float") == 0) {
			  if (Cmp((yyvsp[0].ptype).type,"_Complex") == 0) {
			    (yyval.ptype).type = NewString("float _Complex");
			  } else {
			    err = 1;
			  }
			} else if (Cmp((yyvsp[-1].ptype).type,"_Complex") == 0) {
			  (yyval.ptype).type = NewStringf("%s _Complex", (yyvsp[0].ptype).type);
			} else {
			  err = 1;
			}
			if (err) {
			  Swig_error(cparse_file, cparse_line, "Extra %s specifier.\n", (yyvsp[-1].ptype).type);
			}
		      }
		    }
               }
#line 11017 "parser.c"
    break;

  case 400: /* type_specifier: TYPE_INT  */
#line 6520 "parser.y"
                          { 
		    (yyval.ptype).type = NewString("int");
                    (yyval.ptype).us = 0;
               }
#line 11026 "parser.c"
    break;

  case 401: /* type_specifier: TYPE_SHORT  */
#line 6524 "parser.y"
                            { 
                    (yyval.ptype).type = NewString("short");
                    (yyval.ptype).us = 0;
                }
#line 11035 "parser.c"
    break;

  case 402: /* type_specifier: TYPE_LONG  */
#line 6528 "parser.y"
                           { 
                    (yyval.ptype).type = NewString("long");
                    (yyval.ptype).us = 0;
                }
#line 11044 "parser.c"
    break;

  case 403: /* type_specifier: TYPE_CHAR  */
#line 6532 "parser.y"
                           { 
                    (yyval.ptype).type = NewString("char");
                    (yyval.ptype).us = 0;
                }
#line 11053 "parser.c"
    break;

  case 404: /* type_specifier: TYPE_WCHAR  */
#line 6536 "parser.y"
                            { 
                    (yyval.ptype).type = NewString("wchar_t");
                    (yyval.ptype).us = 0;
                }
#line 11062 "parser.c"
    break;

  case 405: /* type_specifier: TYPE_FLOAT  */
#line 6540 "parser.y"
                            { 
                    (yyval.ptype).type = NewString("float");
                    (yyval.ptype).us = 0;
                }
#line 11071 "parser.c"
    break;

  case 406: /* type_specifier: TYPE_DOUBLE  */
#line 6544 "parser.y"
                             { 
                    (yyval.ptype).type = NewString("double");
                    (yyval.ptype).us = 0;
                }
#line 11080 "parser.c"
    break;

  case 407: /* type_specifier: TYPE_SIGNED  */
#line 6548 "parser.y"
                             { 
                    (yyval.ptype).us = NewString("signed");
                    (yyval.ptype).type = 0;
                }
#line 11089 "parser.c"
    break;

  case 408: /* type_specifier: TYPE_UNSIGNED  */
#line 6552 "parser.y"
                               { 
                    (yyval.ptype).us = NewString("unsigned");
                    (yyval.ptype).type = 0;
                }
#line 11098 "parser.c"
    break;

  case 409: /* type_specifier: TYPE_COMPLEX  */
#line 6556 "parser.y"
                              { 
                    (yyval.ptype).type = NewString("_Complex");
                    (yyval.ptype).us = 0;
                }
#line 11107 "parser.c"
    break;

  case 410: /* type_specifier: TYPE_NON_ISO_INT8  */
#line 6560 "parser.y"
                                   { 
                    (yyval.ptype).type = NewString("__int8");
                    (yyval.ptype).us = 0;
                }
#line 11116 "parser.c"
    break;

  case 411: /* type_specifier: TYPE_NON_ISO_INT16  */
#line 6564 "parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int16");
                    (yyval.ptype).us = 0;
                }
#line 11125 "parser.c"
    break;

  case 412: /* type_specifier: TYPE_NON_ISO_INT32  */
#line 6568 "parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int32");
                    (yyval.ptype).us = 0;
                }
#line 11134 "parser.c"
    break;

  case 413: /* type_specifier: TYPE_NON_ISO_INT64  */
#line 6572 "parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int64");
                    (yyval.ptype).us = 0;
                }
#line 11143 "parser.c"
    break;

  case 418: /* deleted_definition: DELETE_KW  */
#line 6587 "parser.y"
                               {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("delete");
		  (yyval.dtype).type = T_STRING;
		}
#line 11153 "parser.c"
    break;

  case 419: /* explicit_default: DEFAULT  */
#line 6595 "parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("default");
		  (yyval.dtype).type = T_STRING;
		}
#line 11163 "parser.c"
    break;

  case 421: /* ename: %empty  */
#line 6605 "parser.y"
                         { (yyval.id) = 0; }
#line 11169 "parser.c"
    break;

  case 426: /* enumlist: enumlist_item  */
#line 6624 "parser.y"
                                {
		  Setattr((yyvsp[0].node),"_last",(yyvsp[0].node));
		  (yyval.node) = (yyvsp[0].node);
		}
#line 11178 "parser.c"
    break;

  case 427: /* enumlist: enumlist_item DOXYGENPOSTSTRING  */
#line 6628 "parser.y"
                                                  {
		  Setattr((yyvsp[-1].node),"_last",(yyvsp[-1].node));
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11188 "parser.c"
    break;

  case 428: /* enumlist: enumlist_item DOXYGENSTRING  */
#line 6633 "parser.y"
                                              {
		  Setattr((yyvsp[-1].node), "_last", (yyvsp[-1].node));
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11199 "parser.c"
    break;

  case 429: /* enumlist: enumlist_item COMMA enumlist  */
#line 6639 "parser.y"
                                                   {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-2].node), (yyvsp[0].node));
		    Setattr((yyvsp[-2].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-2].node),"_last",(yyvsp[-2].node));
		  }
		  (yyval.node) = (yyvsp[-2].node);
		}
#line 11214 "parser.c"
    break;

  case 430: /* enumlist: enumlist_item DOXYGENPOSTSTRING COMMA enumlist  */
#line 6649 "parser.y"
                                                                     {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-3].node), (yyvsp[0].node));
		    Setattr((yyvsp[-3].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-3].node),"_last",(yyvsp[-3].node));
		  }
		  set_comment((yyvsp[-3].node), (yyvsp[-2].str));
		  (yyval.node) = (yyvsp[-3].node);
		}
#line 11230 "parser.c"
    break;

  case 431: /* enumlist: enumlist_item COMMA DOXYGENPOSTSTRING enumlist  */
#line 6660 "parser.y"
                                                                     {
		  if ((yyvsp[0].node)) {
		    set_nextSibling((yyvsp[-3].node), (yyvsp[0].node));
		    Setattr((yyvsp[-3].node),"_last",Getattr((yyvsp[0].node),"_last"));
		    Setattr((yyvsp[0].node),"_last",NULL);
		  } else {
		    Setattr((yyvsp[-3].node),"_last",(yyvsp[-3].node));
		  }
		  set_comment((yyvsp[-3].node), (yyvsp[-1].str));
		  (yyval.node) = (yyvsp[-3].node);
		}
#line 11246 "parser.c"
    break;

  case 432: /* enumlist: optional_ignored_defines  */
#line 6671 "parser.y"
                                           {
		  (yyval.node) = 0;
		}
#line 11254 "parser.c"
    break;

  case 433: /* enumlist_item: optional_ignored_defines edecl_with_dox optional_ignored_defines  */
#line 6676 "parser.y"
                                                                                   {
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11262 "parser.c"
    break;

  case 435: /* edecl_with_dox: DOXYGENSTRING edecl  */
#line 6682 "parser.y"
                                      {
		  (yyval.node) = (yyvsp[0].node);
		  set_comment((yyvsp[0].node), (yyvsp[-1].str));
		}
#line 11271 "parser.c"
    break;

  case 436: /* edecl: identifier  */
#line 6688 "parser.y"
                             {
		   SwigType *type = NewSwigType(T_INT);
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[0].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Delete(type);
		 }
#line 11284 "parser.c"
    break;

  case 437: /* edecl: identifier EQUAL etype  */
#line 6696 "parser.y"
                                          {
		   SwigType *type = NewSwigType((yyvsp[0].dtype).type == T_BOOL ? T_BOOL : ((yyvsp[0].dtype).type == T_CHAR ? T_CHAR : T_INT));
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[-2].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Setattr((yyval.node),"enumvalue", (yyvsp[0].dtype).val);
		   if ((yyvsp[0].dtype).stringval) {
		     Setattr((yyval.node), "enumstringval", (yyvsp[0].dtype).stringval);
		   }
		   if ((yyvsp[0].dtype).numval) {
		     Setattr((yyval.node), "enumnumval", (yyvsp[0].dtype).numval);
		   }
		   Setattr((yyval.node),"value",(yyvsp[-2].id));
		   Delete(type);
                 }
#line 11305 "parser.c"
    break;

  case 438: /* etype: expr  */
#line 6714 "parser.y"
                        {
                   (yyval.dtype) = (yyvsp[0].dtype);
		   /* We get T_USER here for a typedef - unfortunately we can't
		    * currently resolve typedefs at this stage of parsing. */
		   if (((yyval.dtype).type != T_INT) && ((yyval.dtype).type != T_UINT) &&
		       ((yyval.dtype).type != T_LONG) && ((yyval.dtype).type != T_ULONG) &&
		       ((yyval.dtype).type != T_LONGLONG) && ((yyval.dtype).type != T_ULONGLONG) &&
		       ((yyval.dtype).type != T_SHORT) && ((yyval.dtype).type != T_USHORT) &&
		       ((yyval.dtype).type != T_SCHAR) && ((yyval.dtype).type != T_UCHAR) &&
		       ((yyval.dtype).type != T_CHAR) && ((yyval.dtype).type != T_BOOL) &&
		       ((yyval.dtype).type != T_UNKNOWN) && ((yyval.dtype).type != T_USER)) {
		     Swig_error(cparse_file,cparse_line,"Type error. Expecting an integral type\n");
		   }
                }
#line 11324 "parser.c"
    break;

  case 440: /* expr: type  */
#line 6733 "parser.y"
                      {
		 Node *n;
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = (yyvsp[0].type);
		 (yyval.dtype).type = T_UNKNOWN;
		 /* Check if value is in scope */
		 n = Swig_symbol_clookup((yyvsp[0].type),0);
		 if (n) {
                   /* A band-aid for enum values used in expressions. */
                   if (Strcmp(nodeType(n),"enumitem") == 0) {
                     String *q = Swig_symbol_qualified(n);
                     if (q) {
                       (yyval.dtype).val = NewStringf("%s::%s", q, Getattr(n,"name"));
		       (yyval.dtype).type = SwigType_type(Getattr(n, "type"));
                       Delete(q);
                     }
		   } else {
		     SwigType *type = Getattr(n, "type");
		     if (type) {
		       (yyval.dtype).type = SwigType_type(type);
		     }
		   }
		 }
               }
#line 11353 "parser.c"
    break;

  case 441: /* exprmem: idcolon ARROW ID  */
#line 6760 "parser.y"
                                  {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s->%s", (yyvsp[-2].str), (yyvsp[0].id));
	       }
#line 11362 "parser.c"
    break;

  case 442: /* exprmem: exprmem ARROW ID  */
#line 6764 "parser.y"
                                      {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, "->%s", (yyvsp[0].id));
	       }
#line 11371 "parser.c"
    break;

  case 443: /* exprmem: idcolon PERIOD ID  */
#line 6768 "parser.y"
                                   {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s.%s", (yyvsp[-2].str), (yyvsp[0].id));
	       }
#line 11380 "parser.c"
    break;

  case 444: /* exprmem: exprmem PERIOD ID  */
#line 6772 "parser.y"
                                       {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, ".%s", (yyvsp[0].id));
	       }
#line 11389 "parser.c"
    break;

  case 445: /* exprmem: exprmem LPAREN  */
#line 6776 "parser.y"
                                    {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = (yyvsp[-1].dtype);
		 append_expr_from_scanner((yyval.dtype).val);
	       }
#line 11399 "parser.c"
    break;

  case 446: /* exprmem: type LPAREN  */
#line 6781 "parser.y"
                             {
		 (yyval.dtype) = default_dtype;
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);

		 String *qty = Swig_symbol_type_qualify((yyvsp[-1].type), 0);
		 if (SwigType_istemplate(qty)) {
		   String *nstr = SwigType_namestr(qty);
		   Delete(qty);
		   qty = nstr;
		 }
		 /* Try to deduce the type - this could be a C++ "constructor
		  * cast" such as `double(4)` or a function call such as
		  * `some_func()`.  In the latter case we get T_USER, but that
		  * is wrong so we map it to T_UNKNOWN until we can actually
		  * deduce the return type of a function call (which is
		  * complicated because the return type can vary between
		  * overloaded forms).
		  */
		 (yyval.dtype).type = SwigType_type(qty);
		 if ((yyval.dtype).type == T_USER) (yyval.dtype).type = T_UNKNOWN;
		 (yyval.dtype).unary_arg_type = 0;

		 (yyval.dtype).val = qty;
		 append_expr_from_scanner((yyval.dtype).val);
	       }
#line 11429 "parser.c"
    break;

  case 449: /* exprsimple: string  */
#line 6811 "parser.y"
                        {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_STRING;
	       }
#line 11440 "parser.c"
    break;

  case 450: /* exprsimple: wstring  */
#line 6817 "parser.y"
                         {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_WSTRING;
	       }
#line 11451 "parser.c"
    break;

  case 451: /* exprsimple: CHARCONST  */
#line 6823 "parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("'%(escape)s'", (yyvsp[0].str));
		  (yyval.dtype).type = T_CHAR;
	       }
#line 11462 "parser.c"
    break;

  case 452: /* exprsimple: WCHARCONST  */
#line 6829 "parser.y"
                            {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L'%(escape)s'", (yyvsp[0].str));
		  (yyval.dtype).type = T_WCHAR;
	       }
#line 11473 "parser.c"
    break;

  case 453: /* exprsimple: SIZEOF LPAREN  */
#line 6841 "parser.y"
                               {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("sizeof");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_ULONG;
               }
#line 11485 "parser.c"
    break;

  case 454: /* exprsimple: ALIGNOF LPAREN  */
#line 6849 "parser.y"
                                {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("alignof");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 11497 "parser.c"
    break;

  case 455: /* exprsimple: NOEXCEPT LPAREN  */
#line 6857 "parser.y"
                                 {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("noexcept");
		  append_expr_from_scanner((yyval.dtype).val);
		  (yyval.dtype).type = T_BOOL;
	       }
#line 11509 "parser.c"
    break;

  case 456: /* exprsimple: SIZEOF ELLIPSIS LPAREN identifier RPAREN  */
#line 6864 "parser.y"
                                                          {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof...(%s)", (yyvsp[-1].id));
		  (yyval.dtype).type = T_ULONG;
               }
#line 11519 "parser.c"
    break;

  case 457: /* exprsimple: SIZEOF exprsimple  */
#line 6874 "parser.y"
                                       {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof(%s)", (yyvsp[0].dtype).val);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 11529 "parser.c"
    break;

  case 460: /* valexpr: LPAREN expr RPAREN  */
#line 6885 "parser.y"
                                                {
	            (yyval.dtype) = default_dtype;
		    (yyval.dtype).val = NewStringf("(%s)",(yyvsp[-1].dtype).val);
		    (yyval.dtype).stringval = Copy((yyvsp[-1].dtype).stringval);
		    (yyval.dtype).numval = Copy((yyvsp[-1].dtype).numval);
		    (yyval.dtype).type = (yyvsp[-1].dtype).type;
	       }
#line 11541 "parser.c"
    break;

  case 461: /* valexpr: LPAREN expr RPAREN expr  */
#line 6895 "parser.y"
                                                              {
		 int cast_type_code = SwigType_type((yyvsp[-2].dtype).val);
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   switch ((yyvsp[-2].dtype).type) {
		     case T_FLOAT:
		     case T_DOUBLE:
		     case T_LONGDOUBLE:
		     case T_FLTCPLX:
		     case T_DBLCPLX:
		       (yyval.dtype).val = NewStringf("(%s)%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val); /* SwigType_str and decimal points don't mix! */
		       break;
		     default:
		       (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-2].dtype).val,0), (yyvsp[0].dtype).val);
		       break;
		   }
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
		 /* As well as C-style casts, this grammar rule currently also
		  * matches a binary operator with a LHS in parentheses for
		  * binary operators which also have an unary form, e.g.:
		  *
		  * (6)*7
		  * (6)&7
		  * (6)+7
		  * (6)-7
		  */
		 if (cast_type_code != T_USER && cast_type_code != T_UNKNOWN) {
		   /* $lhs is definitely a type so we know this is a cast. */
		   (yyval.dtype).type = cast_type_code;
		 } else if ((yyvsp[0].dtype).type == 0 || (yyvsp[0].dtype).unary_arg_type == 0) {
		   /* Not one of the cases above, so we know this is a cast. */
		   (yyval.dtype).type = cast_type_code;
		 } else {
		   (yyval.dtype).type = promote((yyvsp[-2].dtype).type, (yyvsp[0].dtype).unary_arg_type);
		 }
 	       }
#line 11585 "parser.c"
    break;

  case 462: /* valexpr: LPAREN expr pointer RPAREN expr  */
#line 6934 "parser.y"
                                                                      {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-3].dtype).val,(yyvsp[-2].type));
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 11600 "parser.c"
    break;

  case 463: /* valexpr: LPAREN expr AND RPAREN expr  */
#line 6944 "parser.y"
                                                                  {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_add_reference((yyvsp[-3].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 11615 "parser.c"
    break;

  case 464: /* valexpr: LPAREN expr LAND RPAREN expr  */
#line 6954 "parser.y"
                                                                   {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_add_rvalue_reference((yyvsp[-3].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-3].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 11630 "parser.c"
    break;

  case 465: /* valexpr: LPAREN expr pointer AND RPAREN expr  */
#line 6964 "parser.y"
                                                                          {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-4].dtype).val,(yyvsp[-3].type));
		   SwigType_add_reference((yyvsp[-4].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-4].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 11646 "parser.c"
    break;

  case 466: /* valexpr: LPAREN expr pointer LAND RPAREN expr  */
#line 6975 "parser.y"
                                                                           {
                 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).unary_arg_type = 0;
		 if ((yyvsp[0].dtype).type != T_STRING) {
		   SwigType_push((yyvsp[-4].dtype).val,(yyvsp[-3].type));
		   SwigType_add_rvalue_reference((yyvsp[-4].dtype).val);
		   (yyval.dtype).val = NewStringf("(%s) %s", SwigType_str((yyvsp[-4].dtype).val,0), (yyvsp[0].dtype).val);
		   (yyval.dtype).stringval = 0;
		   (yyval.dtype).numval = 0;
		 }
 	       }
#line 11662 "parser.c"
    break;

  case 467: /* valexpr: AND expr  */
#line 6986 "parser.y"
                          {
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).val = NewStringf("&%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).stringval = 0;
		 (yyval.dtype).numval = 0;
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)&7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
		 switch ((yyval.dtype).type) {
		   case T_CHAR:
		     (yyval.dtype).type = T_STRING;
		     break;
		   case T_WCHAR:
		     (yyval.dtype).type = T_WSTRING;
		     break;
		   default:
		     (yyval.dtype).type = T_POINTER;
		 }
	       }
#line 11688 "parser.c"
    break;

  case 468: /* valexpr: STAR expr  */
#line 7007 "parser.y"
                           {
		 (yyval.dtype) = (yyvsp[0].dtype);
		 (yyval.dtype).val = NewStringf("*%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).stringval = 0;
		 (yyval.dtype).numval = 0;
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)*7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
		 switch ((yyval.dtype).type) {
		   case T_STRING:
		     (yyval.dtype).type = T_CHAR;
		     break;
		   case T_WSTRING:
		     (yyval.dtype).type = T_WCHAR;
		     break;
		   default:
		     (yyval.dtype).type = T_UNKNOWN;
		 }
	       }
#line 11714 "parser.c"
    break;

  case 479: /* exprcompound: expr PLUS expr  */
#line 7042 "parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s+%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11724 "parser.c"
    break;

  case 480: /* exprcompound: expr MINUS expr  */
#line 7047 "parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s-%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11734 "parser.c"
    break;

  case 481: /* exprcompound: expr STAR expr  */
#line 7052 "parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11744 "parser.c"
    break;

  case 482: /* exprcompound: expr SLASH expr  */
#line 7057 "parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11754 "parser.c"
    break;

  case 483: /* exprcompound: expr MODULO expr  */
#line 7062 "parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11764 "parser.c"
    break;

  case 484: /* exprcompound: expr AND expr  */
#line 7067 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11774 "parser.c"
    break;

  case 485: /* exprcompound: expr OR expr  */
#line 7072 "parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11784 "parser.c"
    break;

  case 486: /* exprcompound: expr XOR expr  */
#line 7077 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11794 "parser.c"
    break;

  case 487: /* exprcompound: expr LSHIFT expr  */
#line 7082 "parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11804 "parser.c"
    break;

  case 488: /* exprcompound: expr RSHIFT expr  */
#line 7087 "parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11814 "parser.c"
    break;

  case 489: /* exprcompound: expr LAND expr  */
#line 7092 "parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11824 "parser.c"
    break;

  case 490: /* exprcompound: expr LOR expr  */
#line 7097 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11834 "parser.c"
    break;

  case 491: /* exprcompound: expr EQUALTO expr  */
#line 7102 "parser.y"
                                             {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11844 "parser.c"
    break;

  case 492: /* exprcompound: expr NOTEQUALTO expr  */
#line 7107 "parser.y"
                                                {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11854 "parser.c"
    break;

  case 493: /* exprcompound: LPAREN expr GREATERTHAN expr RPAREN  */
#line 7116 "parser.y"
                                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11864 "parser.c"
    break;

  case 494: /* exprcompound: LPAREN exprsimple LESSTHAN expr RPAREN  */
#line 7127 "parser.y"
                                                                  {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11874 "parser.c"
    break;

  case 495: /* exprcompound: expr GREATERTHANOREQUALTO expr  */
#line 7132 "parser.y"
                                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11884 "parser.c"
    break;

  case 496: /* exprcompound: expr LESSTHANOREQUALTO expr  */
#line 7137 "parser.y"
                                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11894 "parser.c"
    break;

  case 497: /* exprcompound: expr PLUS ELLIPSIS  */
#line 7154 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s+...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11904 "parser.c"
    break;

  case 498: /* exprcompound: expr MINUS ELLIPSIS  */
#line 7159 "parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s-...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11914 "parser.c"
    break;

  case 499: /* exprcompound: expr STAR ELLIPSIS  */
#line 7164 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11924 "parser.c"
    break;

  case 500: /* exprcompound: expr SLASH ELLIPSIS  */
#line 7169 "parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11934 "parser.c"
    break;

  case 501: /* exprcompound: expr MODULO ELLIPSIS  */
#line 7174 "parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11944 "parser.c"
    break;

  case 502: /* exprcompound: expr AND ELLIPSIS  */
#line 7179 "parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11954 "parser.c"
    break;

  case 503: /* exprcompound: expr OR ELLIPSIS  */
#line 7184 "parser.y"
                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11964 "parser.c"
    break;

  case 504: /* exprcompound: expr XOR ELLIPSIS  */
#line 7189 "parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11974 "parser.c"
    break;

  case 505: /* exprcompound: expr LSHIFT ELLIPSIS  */
#line 7194 "parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11984 "parser.c"
    break;

  case 506: /* exprcompound: expr RSHIFT ELLIPSIS  */
#line 7199 "parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11994 "parser.c"
    break;

  case 507: /* exprcompound: expr LAND ELLIPSIS  */
#line 7204 "parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12004 "parser.c"
    break;

  case 508: /* exprcompound: expr LOR ELLIPSIS  */
#line 7209 "parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12014 "parser.c"
    break;

  case 509: /* exprcompound: expr EQUALTO ELLIPSIS  */
#line 7214 "parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12024 "parser.c"
    break;

  case 510: /* exprcompound: expr NOTEQUALTO ELLIPSIS  */
#line 7219 "parser.y"
                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12034 "parser.c"
    break;

  case 511: /* exprcompound: LPAREN expr GREATERTHAN ELLIPSIS RPAREN  */
#line 7228 "parser.y"
                                                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > ...)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12044 "parser.c"
    break;

  case 512: /* exprcompound: LPAREN exprsimple LESSTHAN ELLIPSIS RPAREN  */
#line 7238 "parser.y"
                                                                 {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12054 "parser.c"
    break;

  case 513: /* exprcompound: expr GREATERTHANOREQUALTO ELLIPSIS  */
#line 7243 "parser.y"
                                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12064 "parser.c"
    break;

  case 514: /* exprcompound: expr LESSTHANOREQUALTO ELLIPSIS  */
#line 7248 "parser.y"
                                                      {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12074 "parser.c"
    break;

  case 515: /* exprcompound: expr LESSEQUALGREATER expr  */
#line 7254 "parser.y"
                                                      {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <=> %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 /* `<=>` returns one of `std::strong_ordering`,
		  * `std::partial_ordering` or `std::weak_ordering`.  The main
		  * thing to do with the return value in this context is to
		  * compare it with another ordering of the same type or
		  * with a literal 0.  We set .type = T_USER here which does
		  * what we want for the comparison operators, and also means
		  * that deduce_type() won't deduce a type for this (which is
		  * better than it deducing the wrong type).
		  */
		 (yyval.dtype).type = T_USER;
		 (yyval.dtype).unary_arg_type = 0;
	       }
#line 12094 "parser.c"
    break;

  case 516: /* exprcompound: expr QUESTIONMARK expr COLON expr  */
#line 7269 "parser.y"
                                                                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s?%s:%s", (yyvsp[-4].dtype).val, (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type, (yyvsp[0].dtype).type);
	       }
#line 12106 "parser.c"
    break;

  case 517: /* exprcompound: MINUS expr  */
#line 7276 "parser.y"
                                             {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("-%s",(yyvsp[0].dtype).val);
		 if ((yyvsp[0].dtype).numval) {
		   switch ((yyvsp[0].dtype).type) {
		     case T_CHAR: // Unsigned on some architectures.
		     case T_UCHAR:
		     case T_USHORT:
		     case T_UINT:
		     case T_ULONG:
		     case T_ULONGLONG:
		       // Avoid negative numval with an unsigned type.
		       break;
		     default:
		       (yyval.dtype).numval = NewStringf("-%s", (yyvsp[0].dtype).numval);
		       break;
		   }
		   Delete((yyvsp[0].dtype).numval);
		 }
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)-7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
	       }
#line 12137 "parser.c"
    break;

  case 518: /* exprcompound: PLUS expr  */
#line 7302 "parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).val = NewStringf("+%s",(yyvsp[0].dtype).val);
		 (yyval.dtype).numval = (yyvsp[0].dtype).numval;
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
		 /* Record the type code for expr so we can properly handle
		  * cases such as (6)+7 which get parsed using this rule then
		  * the rule for a C-style cast.
		  */
		 (yyval.dtype).unary_arg_type = (yyvsp[0].dtype).type;
	       }
#line 12153 "parser.c"
    break;

  case 519: /* exprcompound: NOT expr  */
#line 7313 "parser.y"
                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("~%s",(yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
	       }
#line 12163 "parser.c"
    break;

  case 520: /* exprcompound: LNOT expr  */
#line 7318 "parser.y"
                               {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).val = NewStringf("!%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12173 "parser.c"
    break;

  case 521: /* variadic_opt: ELLIPSIS  */
#line 7325 "parser.y"
                         {
		(yyval.intvalue) = 1;
	      }
#line 12181 "parser.c"
    break;

  case 522: /* variadic_opt: %empty  */
#line 7328 "parser.y"
                       {
	        (yyval.intvalue) = 0;
	      }
#line 12189 "parser.c"
    break;

  case 524: /* $@12: %empty  */
#line 7336 "parser.y"
                        { inherit_list = 1; }
#line 12195 "parser.c"
    break;

  case 525: /* raw_inherit: COLON $@12 base_list  */
#line 7336 "parser.y"
                                                        { (yyval.bases) = (yyvsp[0].bases); inherit_list = 0; }
#line 12201 "parser.c"
    break;

  case 526: /* raw_inherit: %empty  */
#line 7337 "parser.y"
                         { (yyval.bases) = 0; }
#line 12207 "parser.c"
    break;

  case 527: /* base_list: base_specifier  */
#line 7340 "parser.y"
                                {
		   Hash *list = NewHash();
		   Node *base = (yyvsp[0].node);
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
               }
#line 12228 "parser.c"
    break;

  case 528: /* base_list: base_list COMMA base_specifier  */
#line 7357 "parser.y"
                                                    {
		   Hash *list = (yyvsp[-2].bases);
		   Node *base = (yyvsp[0].node);
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
                   (yyval.bases) = list;
               }
#line 12240 "parser.c"
    break;

  case 529: /* @13: %empty  */
#line 7366 "parser.y"
                                       {
		 (yyval.intvalue) = cparse_line;
	       }
#line 12248 "parser.c"
    break;

  case 530: /* base_specifier: opt_virtual @13 idcolon variadic_opt  */
#line 7368 "parser.y"
                                            {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node), cparse_file);
		 Setline((yyval.node), (yyvsp[-2].intvalue));
		 Setattr((yyval.node), "name", (yyvsp[-1].str));
		 Setfile((yyvsp[-1].str), cparse_file);
		 Setline((yyvsp[-1].str), (yyvsp[-2].intvalue));
                 if (last_cpptype && (Strcmp(last_cpptype,"struct") != 0)) {
		   Setattr((yyval.node),"access","private");
		   Swig_warning(WARN_PARSE_NO_ACCESS, Getfile((yyval.node)), Getline((yyval.node)), "No access specifier given for base class '%s' (ignored).\n", SwigType_namestr((yyvsp[-1].str)));
                 } else {
		   Setattr((yyval.node),"access","public");
		 }
		 if ((yyvsp[0].intvalue)) {
		   SwigType_add_variadic(Getattr((yyval.node), "name"));
		 }
               }
#line 12270 "parser.c"
    break;

  case 531: /* @14: %empty  */
#line 7385 "parser.y"
                                                        {
		 (yyval.intvalue) = cparse_line;
	       }
#line 12278 "parser.c"
    break;

  case 532: /* base_specifier: opt_virtual access_specifier @14 opt_virtual idcolon variadic_opt  */
#line 7387 "parser.y"
                                                        {
		 (yyval.node) = NewHash();
		 Setfile((yyval.node), cparse_file);
		 Setline((yyval.node), (yyvsp[-3].intvalue));
		 Setattr((yyval.node), "name", (yyvsp[-1].str));
		 Setfile((yyvsp[-1].str), cparse_file);
		 Setline((yyvsp[-1].str), (yyvsp[-3].intvalue));
		 Setattr((yyval.node), "access", (yyvsp[-4].id));
		 if (Strcmp((yyvsp[-4].id), "public") != 0) {
		   Swig_warning(WARN_PARSE_PRIVATE_INHERIT, Getfile((yyval.node)), Getline((yyval.node)), "%s inheritance from base '%s' (ignored).\n", (yyvsp[-4].id), SwigType_namestr((yyvsp[-1].str)));
		 }
		 if ((yyvsp[0].intvalue)) {
		   SwigType_add_variadic(Getattr((yyval.node), "name"));
		 }
               }
#line 12298 "parser.c"
    break;

  case 533: /* access_specifier: PUBLIC  */
#line 7404 "parser.y"
                           { (yyval.id) = "public"; }
#line 12304 "parser.c"
    break;

  case 534: /* access_specifier: PRIVATE  */
#line 7405 "parser.y"
                         { (yyval.id) = "private"; }
#line 12310 "parser.c"
    break;

  case 535: /* access_specifier: PROTECTED  */
#line 7406 "parser.y"
                           { (yyval.id) = "protected"; }
#line 12316 "parser.c"
    break;

  case 536: /* templcpptype: CLASS variadic_opt  */
#line 7409 "parser.y"
                                    {
                   (yyval.type) = NewString("class");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 12326 "parser.c"
    break;

  case 537: /* templcpptype: TYPENAME variadic_opt  */
#line 7414 "parser.y"
                                       {
                   (yyval.type) = NewString("typename");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 12336 "parser.c"
    break;

  case 539: /* cpptype: STRUCT  */
#line 7422 "parser.y"
                        {
                   (yyval.type) = NewString("struct");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 12345 "parser.c"
    break;

  case 540: /* cpptype: UNION  */
#line 7426 "parser.y"
                       {
                   (yyval.type) = NewString("union");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 12354 "parser.c"
    break;

  case 541: /* classkey: CLASS  */
#line 7432 "parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("class");
               }
#line 12362 "parser.c"
    break;

  case 542: /* classkey: STRUCT  */
#line 7435 "parser.y"
                        {
		   if (!inherit_list) last_cpptype = NewString("struct");
               }
#line 12370 "parser.c"
    break;

  case 543: /* classkey: UNION  */
#line 7438 "parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("union");
               }
#line 12378 "parser.c"
    break;

  case 548: /* virt_specifier_seq: OVERRIDE  */
#line 7451 "parser.y"
                              {
                   (yyval.str) = 0;
	       }
#line 12386 "parser.c"
    break;

  case 549: /* virt_specifier_seq: FINAL  */
#line 7454 "parser.y"
                       {
                   (yyval.str) = NewString("1");
	       }
#line 12394 "parser.c"
    break;

  case 550: /* virt_specifier_seq: FINAL OVERRIDE  */
#line 7457 "parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 12402 "parser.c"
    break;

  case 551: /* virt_specifier_seq: OVERRIDE FINAL  */
#line 7460 "parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 12410 "parser.c"
    break;

  case 553: /* virt_specifier_seq_opt: %empty  */
#line 7466 "parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 12418 "parser.c"
    break;

  case 554: /* class_virt_specifier_opt: FINAL  */
#line 7471 "parser.y"
                                 {
                   (yyval.str) = NewString("1");
               }
#line 12426 "parser.c"
    break;

  case 555: /* class_virt_specifier_opt: %empty  */
#line 7474 "parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 12434 "parser.c"
    break;

  case 556: /* exception_specification: THROW LPAREN parms RPAREN  */
#line 7479 "parser.y"
                                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-1].pl);
                    (yyval.dtype).throwf = NewString("1");
	       }
#line 12444 "parser.c"
    break;

  case 557: /* exception_specification: NOEXCEPT  */
#line 7484 "parser.y"
                          {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
	       }
#line 12453 "parser.c"
    break;

  case 558: /* exception_specification: virt_specifier_seq  */
#line 7488 "parser.y"
                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12462 "parser.c"
    break;

  case 559: /* exception_specification: THROW LPAREN parms RPAREN virt_specifier_seq  */
#line 7492 "parser.y"
                                                              {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-2].pl);
                    (yyval.dtype).throwf = NewString("1");
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12473 "parser.c"
    break;

  case 560: /* exception_specification: NOEXCEPT virt_specifier_seq  */
#line 7498 "parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
		    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12483 "parser.c"
    break;

  case 561: /* exception_specification: NOEXCEPT LPAREN expr RPAREN  */
#line 7503 "parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = (yyvsp[-1].dtype).val;
	       }
#line 12492 "parser.c"
    break;

  case 562: /* qualifiers_exception_specification: cv_ref_qualifier  */
#line 7509 "parser.y"
                                                      {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).qualifier = (yyvsp[0].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[0].dtype).refqualifier;
               }
#line 12502 "parser.c"
    break;

  case 563: /* qualifiers_exception_specification: exception_specification  */
#line 7514 "parser.y"
                                         {
		    (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 12510 "parser.c"
    break;

  case 564: /* qualifiers_exception_specification: cv_ref_qualifier exception_specification  */
#line 7517 "parser.y"
                                                          {
		    (yyval.dtype) = (yyvsp[0].dtype);
                    (yyval.dtype).qualifier = (yyvsp[-1].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[-1].dtype).refqualifier;
               }
#line 12520 "parser.c"
    break;

  case 566: /* cpp_const: %empty  */
#line 7525 "parser.y"
                        {
                 (yyval.dtype) = default_dtype;
               }
#line 12528 "parser.c"
    break;

  case 567: /* ctor_end: cpp_const ctor_initializer SEMI  */
#line 7530 "parser.y"
                                                 { 
                    Clear(scanner_ccode); 
		    (yyval.decl) = default_decl;
		    (yyval.decl).throws = (yyvsp[-2].dtype).throws;
		    (yyval.decl).throwf = (yyvsp[-2].dtype).throwf;
		    (yyval.decl).nexcept = (yyvsp[-2].dtype).nexcept;
		    (yyval.decl).final = (yyvsp[-2].dtype).final;
                    if ((yyvsp[-2].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
               }
#line 12543 "parser.c"
    break;

  case 568: /* ctor_end: cpp_const ctor_initializer LBRACE  */
#line 7540 "parser.y"
                                                   { 
                    if ((yyvsp[-2].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
                    if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		    (yyval.decl) = default_decl;
                    (yyval.decl).throws = (yyvsp[-2].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[-2].dtype).throwf;
                    (yyval.decl).nexcept = (yyvsp[-2].dtype).nexcept;
                    (yyval.decl).final = (yyvsp[-2].dtype).final;
               }
#line 12558 "parser.c"
    break;

  case 569: /* ctor_end: LPAREN parms RPAREN SEMI  */
#line 7550 "parser.y"
                                          { 
                    Clear(scanner_ccode); 
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 12569 "parser.c"
    break;

  case 570: /* ctor_end: LPAREN parms RPAREN LBRACE  */
#line 7556 "parser.y"
                                            {
                    if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 12580 "parser.c"
    break;

  case 571: /* ctor_end: EQUAL definetype SEMI  */
#line 7562 "parser.y"
                                       { 
		    (yyval.decl) = default_decl;
                    (yyval.decl).defarg = (yyvsp[-1].dtype).val; 
		    (yyval.decl).stringdefarg = (yyvsp[-1].dtype).stringval;
		    (yyval.decl).numdefarg = (yyvsp[-1].dtype).numval;
               }
#line 12591 "parser.c"
    break;

  case 572: /* ctor_end: exception_specification EQUAL default_delete SEMI  */
#line 7568 "parser.y"
                                                                   {
		    (yyval.decl) = default_decl;
                    (yyval.decl).defarg = (yyvsp[-1].dtype).val;
		    (yyval.decl).stringdefarg = (yyvsp[-1].dtype).stringval;
		    (yyval.decl).numdefarg = (yyvsp[-1].dtype).numval;
                    (yyval.decl).throws = (yyvsp[-3].dtype).throws;
                    (yyval.decl).throwf = (yyvsp[-3].dtype).throwf;
                    (yyval.decl).nexcept = (yyvsp[-3].dtype).nexcept;
                    (yyval.decl).final = (yyvsp[-3].dtype).final;
                    if ((yyvsp[-3].dtype).qualifier)
                      Swig_error(cparse_file, cparse_line, "Constructor cannot have a qualifier.\n");
               }
#line 12608 "parser.c"
    break;

  case 579: /* mem_initializer: idcolon LPAREN  */
#line 7592 "parser.y"
                                 {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 12617 "parser.c"
    break;

  case 580: /* mem_initializer: idcolon LBRACE  */
#line 7604 "parser.y"
                                 {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 12626 "parser.c"
    break;

  case 581: /* less_valparms_greater: LESSTHAN valparms GREATERTHAN  */
#line 7610 "parser.y"
                                                      {
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,(yyvsp[-1].p));
		     (yyval.str) = s;
		     scanner_last_id(1);
                }
#line 12637 "parser.c"
    break;

  case 583: /* identifier: OVERRIDE  */
#line 7620 "parser.y"
                          { (yyval.id) = Swig_copy_string("override"); }
#line 12643 "parser.c"
    break;

  case 584: /* identifier: FINAL  */
#line 7621 "parser.y"
                       { (yyval.id) = Swig_copy_string("final"); }
#line 12649 "parser.c"
    break;

  case 586: /* idstring: default_delete  */
#line 7625 "parser.y"
                                { (yyval.id) = Char((yyvsp[0].dtype).val); }
#line 12655 "parser.c"
    break;

  case 587: /* idstring: string  */
#line 7626 "parser.y"
                        { (yyval.id) = Char((yyvsp[0].str)); }
#line 12661 "parser.c"
    break;

  case 589: /* idstringopt: %empty  */
#line 7630 "parser.y"
                        { (yyval.id) = 0; }
#line 12667 "parser.c"
    break;

  case 590: /* idcolon: idtemplate idcolontail  */
#line 7633 "parser.y"
                                        { 
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 12676 "parser.c"
    break;

  case 591: /* idcolon: NONID DCOLON idtemplatetemplate idcolontail  */
#line 7637 "parser.y"
                                                             {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 12685 "parser.c"
    break;

  case 592: /* idcolon: idtemplate  */
#line 7641 "parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].str));
   	       }
#line 12693 "parser.c"
    break;

  case 593: /* idcolon: NONID DCOLON idtemplatetemplate  */
#line 7644 "parser.y"
                                                 {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 12701 "parser.c"
    break;

  case 594: /* idcolon: OPERATOR  */
#line 7647 "parser.y"
                                    {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 12709 "parser.c"
    break;

  case 595: /* idcolon: OPERATOR less_valparms_greater  */
#line 7650 "parser.y"
                                                {
		 (yyval.str) = (yyvsp[-1].str);
		 Append((yyval.str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 12719 "parser.c"
    break;

  case 596: /* idcolon: NONID DCOLON OPERATOR  */
#line 7655 "parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 12728 "parser.c"
    break;

  case 597: /* idcolontail: DCOLON idtemplatetemplate idcolontail  */
#line 7661 "parser.y"
                                                           {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 12737 "parser.c"
    break;

  case 598: /* idcolontail: DCOLON idtemplatetemplate  */
#line 7665 "parser.y"
                                           {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 12745 "parser.c"
    break;

  case 599: /* idcolontail: DCOLON OPERATOR  */
#line 7668 "parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 12754 "parser.c"
    break;

  case 600: /* idcolontail: DCNOT idtemplate  */
#line 7672 "parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].str));
               }
#line 12762 "parser.c"
    break;

  case 601: /* idtemplate: identifier  */
#line 7678 "parser.y"
                           {
		(yyval.str) = NewString((yyvsp[0].id));
	      }
#line 12770 "parser.c"
    break;

  case 602: /* idtemplate: identifier less_valparms_greater  */
#line 7681 "parser.y"
                                                 {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 12780 "parser.c"
    break;

  case 604: /* idtemplatetemplate: TEMPLATE identifier less_valparms_greater  */
#line 7689 "parser.y"
                                                          {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 12790 "parser.c"
    break;

  case 605: /* idcolonnt: identifier idcolontailnt  */
#line 7697 "parser.y"
                                         {
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].id), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 12799 "parser.c"
    break;

  case 606: /* idcolonnt: NONID DCOLON identifier idcolontailnt  */
#line 7701 "parser.y"
                                                       {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 12808 "parser.c"
    break;

  case 607: /* idcolonnt: identifier  */
#line 7705 "parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].id));
   	       }
#line 12816 "parser.c"
    break;

  case 608: /* idcolonnt: NONID DCOLON identifier  */
#line 7708 "parser.y"
                                         {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 12824 "parser.c"
    break;

  case 609: /* idcolonnt: OPERATOR  */
#line 7711 "parser.y"
                          {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 12832 "parser.c"
    break;

  case 610: /* idcolonnt: NONID DCOLON OPERATOR  */
#line 7714 "parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 12841 "parser.c"
    break;

  case 611: /* idcolontailnt: DCOLON identifier idcolontailnt  */
#line 7720 "parser.y"
                                                      {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 12850 "parser.c"
    break;

  case 612: /* idcolontailnt: DCOLON identifier  */
#line 7724 "parser.y"
                                   {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 12858 "parser.c"
    break;

  case 613: /* idcolontailnt: DCOLON OPERATOR  */
#line 7727 "parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 12867 "parser.c"
    break;

  case 614: /* idcolontailnt: DCNOT identifier  */
#line 7731 "parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].id));
               }
#line 12875 "parser.c"
    break;

  case 615: /* string: string STRING  */
#line 7737 "parser.y"
                                   { 
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12885 "parser.c"
    break;

  case 617: /* wstring: wstring WSTRING  */
#line 7744 "parser.y"
                                     {
		   // Concatenated wide strings: L"str1" L"str2"
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12896 "parser.c"
    break;

  case 618: /* wstring: wstring STRING  */
#line 7750 "parser.y"
                                    {
		   // Concatenated wide string and normal string literal: L"str1" "str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12907 "parser.c"
    break;

  case 619: /* wstring: string WSTRING  */
#line 7756 "parser.y"
                                    {
		   // Concatenated normal string and wide string literal: "str1" L"str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12918 "parser.c"
    break;

  case 622: /* stringbrace: LBRACE  */
#line 7766 "parser.y"
                        {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  (yyval.str) = NewString(scanner_ccode);
               }
#line 12927 "parser.c"
    break;

  case 624: /* options: LPAREN kwargs RPAREN  */
#line 7773 "parser.y"
                                      {
                  Hash *n;
                  (yyval.node) = NewHash();
                  n = (yyvsp[-1].node);
                  while(n) {
                     String *name, *value;
                     name = Getattr(n,"name");
                     value = Getattr(n,"value");
		     if (!value) value = (String *) "1";
                     Setattr((yyval.node),name, value);
		     n = nextSibling(n);
		  }
               }
#line 12945 "parser.c"
    break;

  case 625: /* options: %empty  */
#line 7786 "parser.y"
                        { (yyval.node) = 0; }
#line 12951 "parser.c"
    break;

  case 626: /* kwargs: kwargs_builder  */
#line 7790 "parser.y"
                                {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 12959 "parser.c"
    break;

  case 627: /* kwargs_builder: idstring EQUAL stringnum  */
#line 7795 "parser.y"
                                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 12971 "parser.c"
    break;

  case 628: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringnum  */
#line 7802 "parser.y"
                                                                   {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 12985 "parser.c"
    break;

  case 629: /* kwargs_builder: idstring  */
#line 7811 "parser.y"
                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 12995 "parser.c"
    break;

  case 630: /* kwargs_builder: kwargs_builder COMMA idstring  */
#line 7816 "parser.y"
                                                   {
		 (yyval.nodebuilder) = (yyvsp[-2].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 13007 "parser.c"
    break;

  case 631: /* kwargs_builder: idstring EQUAL stringtype  */
#line 7823 "parser.y"
                                           {
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 13017 "parser.c"
    break;

  case 632: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringtype  */
#line 7828 "parser.y"
                                                                    {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 13029 "parser.c"
    break;

  case 634: /* stringnum: exprnum  */
#line 7838 "parser.y"
                         {
		 (yyval.str) = (yyvsp[0].dtype).val;
               }
#line 13037 "parser.c"
    break;


#line 13041 "parser.c"

      default: break;
    }
  /* User semantic actions sometimes alter yychar, and that requires
     that yytoken be updated with the new translation.  We take the
     approach of translating immediately before every use of yytoken.
     One alternative is translating here after every semantic action,
     but that translation would be missed if the semantic action invokes
     YYABORT, YYACCEPT, or YYERROR immediately after altering yychar or
     if it invokes YYBACKUP.  In the case of YYABORT or YYACCEPT, an
     incorrect destructor might then be invoked immediately.  In the
     case of YYERROR or YYBACKUP, subsequent parser actions might lead
     to an incorrect destructor call or verbose syntax error message
     before the lookahead is translated.  */
  YY_SYMBOL_PRINT ("-> $$ =", YY_CAST (yysymbol_kind_t, yyr1[yyn]), &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;

  *++yyvsp = yyval;

  /* Now 'shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */
  {
    const int yylhs = yyr1[yyn] - YYNTOKENS;
    const int yyi = yypgoto[yylhs] + *yyssp;
    yystate = (0 <= yyi && yyi <= YYLAST && yycheck[yyi] == *yyssp
               ? yytable[yyi]
               : yydefgoto[yylhs]);
  }

  goto yynewstate;


/*--------------------------------------.
| yyerrlab -- here on detecting error.  |
`--------------------------------------*/
yyerrlab:
  /* Make sure we have latest lookahead translation.  See comments at
     user semantic actions for why this is necessary.  */
  yytoken = yychar == YYEMPTY ? YYSYMBOL_YYEMPTY : YYTRANSLATE (yychar);
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
      yyerror (YY_("syntax error"));
    }

  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse lookahead token after an
         error, discard it.  */

      if (yychar <= END)
        {
          /* Return failure if at end of input.  */
          if (yychar == END)
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
  /* Pacify compilers when the user code never invokes YYERROR and the
     label yyerrorlab therefore never appears in user code.  */
  if (0)
    YYERROR;
  ++yynerrs;

  /* Do not reclaim the symbols of the rule whose action triggered
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
  yyerrstatus = 3;      /* Each real token shifted decrements this.  */

  /* Pop stack until we find a state that shifts the error token.  */
  for (;;)
    {
      yyn = yypact[yystate];
      if (!yypact_value_is_default (yyn))
        {
          yyn += YYSYMBOL_YYerror;
          if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYSYMBOL_YYerror)
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
                  YY_ACCESSING_SYMBOL (yystate), yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  YY_IGNORE_MAYBE_UNINITIALIZED_BEGIN
  *++yyvsp = yylval;
  YY_IGNORE_MAYBE_UNINITIALIZED_END


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", YY_ACCESSING_SYMBOL (yyn), yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturnlab;


/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturnlab;


/*-----------------------------------------------------------.
| yyexhaustedlab -- YYNOMEM (memory exhaustion) comes here.  |
`-----------------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  goto yyreturnlab;


/*----------------------------------------------------------.
| yyreturnlab -- parsing is finished, clean up and return.  |
`----------------------------------------------------------*/
yyreturnlab:
  if (yychar != YYEMPTY)
    {
      /* Make sure we have latest lookahead translation.  See comments at
         user semantic actions for why this is necessary.  */
      yytoken = YYTRANSLATE (yychar);
      yydestruct ("Cleanup: discarding lookahead",
                  yytoken, &yylval);
    }
  /* Do not reclaim the symbols of the rule whose action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
                  YY_ACCESSING_SYMBOL (+*yyssp), yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif

  return yyresult;
}

#line 7843 "parser.y"


SwigType *Swig_cparse_type(String *s) {
   String *ns;
   ns = NewString(s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSETYPE);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"typeparse: '%s' ---> '%s'\n", s, top); */
   return (SwigType *)top;
}


Parm *Swig_cparse_parm(String *s) {
   String *ns;
   ns = NewString(s);
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARM);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"parmparse: '%s' ---> '%s'\n", s, top); */
   Delete(ns);
   return (Parm *)top;
}


ParmList *Swig_cparse_parms(String *s, Node *file_line_node) {
   String *ns;
   char *cs = Char(s);
   if (cs && cs[0] != '(') {
     ns = NewStringf("(%s)",s);
   } else {
     ns = NewString(s);
   }
   Setfile(ns, Getfile(file_line_node));
   Setline(ns, Getline(file_line_node));
   Seek(ns,0,SEEK_SET);
   scanner_file(ns);
   top = 0;
   scanner_next_token(PARSEPARMS);
   if (yyparse() == 2) {
      Swig_error(cparse_file, cparse_line, "Parser exceeded stack depth or ran out of memory\n");
      Exit(EXIT_FAILURE);
   }
   /*   Printf(stdout,"parmsparse: '%s' ---> '%s'\n", s, top); */
   return (ParmList *)top;
}

