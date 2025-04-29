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
#line 33 "./CParse/parser.y"

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

  if (inclass && n) {
    cparse_normalize_void(n);
  }
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


#line 1646 "CParse/parser.c"

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
  YYSYMBOL_TYPE_RAW = 36,                  /* TYPE_RAW  */
  YYSYMBOL_TYPE_NON_ISO_INT8 = 37,         /* TYPE_NON_ISO_INT8  */
  YYSYMBOL_TYPE_NON_ISO_INT16 = 38,        /* TYPE_NON_ISO_INT16  */
  YYSYMBOL_TYPE_NON_ISO_INT32 = 39,        /* TYPE_NON_ISO_INT32  */
  YYSYMBOL_TYPE_NON_ISO_INT64 = 40,        /* TYPE_NON_ISO_INT64  */
  YYSYMBOL_LPAREN = 41,                    /* LPAREN  */
  YYSYMBOL_RPAREN = 42,                    /* RPAREN  */
  YYSYMBOL_COMMA = 43,                     /* COMMA  */
  YYSYMBOL_SEMI = 44,                      /* SEMI  */
  YYSYMBOL_EXTERN = 45,                    /* EXTERN  */
  YYSYMBOL_LBRACE = 46,                    /* LBRACE  */
  YYSYMBOL_RBRACE = 47,                    /* RBRACE  */
  YYSYMBOL_PERIOD = 48,                    /* PERIOD  */
  YYSYMBOL_ELLIPSIS = 49,                  /* ELLIPSIS  */
  YYSYMBOL_CONST_QUAL = 50,                /* CONST_QUAL  */
  YYSYMBOL_VOLATILE = 51,                  /* VOLATILE  */
  YYSYMBOL_REGISTER = 52,                  /* REGISTER  */
  YYSYMBOL_STRUCT = 53,                    /* STRUCT  */
  YYSYMBOL_UNION = 54,                     /* UNION  */
  YYSYMBOL_EQUAL = 55,                     /* EQUAL  */
  YYSYMBOL_SIZEOF = 56,                    /* SIZEOF  */
  YYSYMBOL_ALIGNOF = 57,                   /* ALIGNOF  */
  YYSYMBOL_MODULE = 58,                    /* MODULE  */
  YYSYMBOL_LBRACKET = 59,                  /* LBRACKET  */
  YYSYMBOL_RBRACKET = 60,                  /* RBRACKET  */
  YYSYMBOL_BEGINFILE = 61,                 /* BEGINFILE  */
  YYSYMBOL_ENDOFFILE = 62,                 /* ENDOFFILE  */
  YYSYMBOL_CONSTANT = 63,                  /* CONSTANT  */
  YYSYMBOL_RENAME = 64,                    /* RENAME  */
  YYSYMBOL_NAMEWARN = 65,                  /* NAMEWARN  */
  YYSYMBOL_EXTEND = 66,                    /* EXTEND  */
  YYSYMBOL_PRAGMA = 67,                    /* PRAGMA  */
  YYSYMBOL_FEATURE = 68,                   /* FEATURE  */
  YYSYMBOL_VARARGS = 69,                   /* VARARGS  */
  YYSYMBOL_ENUM = 70,                      /* ENUM  */
  YYSYMBOL_CLASS = 71,                     /* CLASS  */
  YYSYMBOL_TYPENAME = 72,                  /* TYPENAME  */
  YYSYMBOL_PRIVATE = 73,                   /* PRIVATE  */
  YYSYMBOL_PUBLIC = 74,                    /* PUBLIC  */
  YYSYMBOL_PROTECTED = 75,                 /* PROTECTED  */
  YYSYMBOL_COLON = 76,                     /* COLON  */
  YYSYMBOL_STATIC = 77,                    /* STATIC  */
  YYSYMBOL_VIRTUAL = 78,                   /* VIRTUAL  */
  YYSYMBOL_FRIEND = 79,                    /* FRIEND  */
  YYSYMBOL_THROW = 80,                     /* THROW  */
  YYSYMBOL_CATCH = 81,                     /* CATCH  */
  YYSYMBOL_EXPLICIT = 82,                  /* EXPLICIT  */
  YYSYMBOL_STATIC_ASSERT = 83,             /* STATIC_ASSERT  */
  YYSYMBOL_CONSTEXPR = 84,                 /* CONSTEXPR  */
  YYSYMBOL_THREAD_LOCAL = 85,              /* THREAD_LOCAL  */
  YYSYMBOL_DECLTYPE = 86,                  /* DECLTYPE  */
  YYSYMBOL_AUTO = 87,                      /* AUTO  */
  YYSYMBOL_NOEXCEPT = 88,                  /* NOEXCEPT  */
  YYSYMBOL_OVERRIDE = 89,                  /* OVERRIDE  */
  YYSYMBOL_FINAL = 90,                     /* FINAL  */
  YYSYMBOL_USING = 91,                     /* USING  */
  YYSYMBOL_NAMESPACE = 92,                 /* NAMESPACE  */
  YYSYMBOL_NATIVE = 93,                    /* NATIVE  */
  YYSYMBOL_INLINE = 94,                    /* INLINE  */
  YYSYMBOL_TYPEMAP = 95,                   /* TYPEMAP  */
  YYSYMBOL_ECHO = 96,                      /* ECHO  */
  YYSYMBOL_APPLY = 97,                     /* APPLY  */
  YYSYMBOL_CLEAR = 98,                     /* CLEAR  */
  YYSYMBOL_SWIGTEMPLATE = 99,              /* SWIGTEMPLATE  */
  YYSYMBOL_FRAGMENT = 100,                 /* FRAGMENT  */
  YYSYMBOL_WARN = 101,                     /* WARN  */
  YYSYMBOL_LESSTHAN = 102,                 /* LESSTHAN  */
  YYSYMBOL_GREATERTHAN = 103,              /* GREATERTHAN  */
  YYSYMBOL_DELETE_KW = 104,                /* DELETE_KW  */
  YYSYMBOL_DEFAULT = 105,                  /* DEFAULT  */
  YYSYMBOL_LESSTHANOREQUALTO = 106,        /* LESSTHANOREQUALTO  */
  YYSYMBOL_GREATERTHANOREQUALTO = 107,     /* GREATERTHANOREQUALTO  */
  YYSYMBOL_EQUALTO = 108,                  /* EQUALTO  */
  YYSYMBOL_NOTEQUALTO = 109,               /* NOTEQUALTO  */
  YYSYMBOL_LESSEQUALGREATER = 110,         /* LESSEQUALGREATER  */
  YYSYMBOL_ARROW = 111,                    /* ARROW  */
  YYSYMBOL_QUESTIONMARK = 112,             /* QUESTIONMARK  */
  YYSYMBOL_TYPES = 113,                    /* TYPES  */
  YYSYMBOL_PARMS = 114,                    /* PARMS  */
  YYSYMBOL_NONID = 115,                    /* NONID  */
  YYSYMBOL_DSTAR = 116,                    /* DSTAR  */
  YYSYMBOL_DCNOT = 117,                    /* DCNOT  */
  YYSYMBOL_TEMPLATE = 118,                 /* TEMPLATE  */
  YYSYMBOL_OPERATOR = 119,                 /* OPERATOR  */
  YYSYMBOL_CONVERSIONOPERATOR = 120,       /* CONVERSIONOPERATOR  */
  YYSYMBOL_PARSETYPE = 121,                /* PARSETYPE  */
  YYSYMBOL_PARSEPARM = 122,                /* PARSEPARM  */
  YYSYMBOL_PARSEPARMS = 123,               /* PARSEPARMS  */
  YYSYMBOL_DOXYGENSTRING = 124,            /* DOXYGENSTRING  */
  YYSYMBOL_DOXYGENPOSTSTRING = 125,        /* DOXYGENPOSTSTRING  */
  YYSYMBOL_CAST = 126,                     /* CAST  */
  YYSYMBOL_LOR = 127,                      /* LOR  */
  YYSYMBOL_LAND = 128,                     /* LAND  */
  YYSYMBOL_OR = 129,                       /* OR  */
  YYSYMBOL_XOR = 130,                      /* XOR  */
  YYSYMBOL_AND = 131,                      /* AND  */
  YYSYMBOL_LSHIFT = 132,                   /* LSHIFT  */
  YYSYMBOL_RSHIFT = 133,                   /* RSHIFT  */
  YYSYMBOL_PLUS = 134,                     /* PLUS  */
  YYSYMBOL_MINUS = 135,                    /* MINUS  */
  YYSYMBOL_STAR = 136,                     /* STAR  */
  YYSYMBOL_SLASH = 137,                    /* SLASH  */
  YYSYMBOL_MODULO = 138,                   /* MODULO  */
  YYSYMBOL_UMINUS = 139,                   /* UMINUS  */
  YYSYMBOL_NOT = 140,                      /* NOT  */
  YYSYMBOL_LNOT = 141,                     /* LNOT  */
  YYSYMBOL_DCOLON = 142,                   /* DCOLON  */
  YYSYMBOL_YYACCEPT = 143,                 /* $accept  */
  YYSYMBOL_program = 144,                  /* program  */
  YYSYMBOL_interface = 145,                /* interface  */
  YYSYMBOL_declaration = 146,              /* declaration  */
  YYSYMBOL_swig_directive = 147,           /* swig_directive  */
  YYSYMBOL_extend_directive = 148,         /* extend_directive  */
  YYSYMBOL_149_1 = 149,                    /* $@1  */
  YYSYMBOL_apply_directive = 150,          /* apply_directive  */
  YYSYMBOL_clear_directive = 151,          /* clear_directive  */
  YYSYMBOL_constant_directive = 152,       /* constant_directive  */
  YYSYMBOL_echo_directive = 153,           /* echo_directive  */
  YYSYMBOL_stringtype = 154,               /* stringtype  */
  YYSYMBOL_fname = 155,                    /* fname  */
  YYSYMBOL_fragment_directive = 156,       /* fragment_directive  */
  YYSYMBOL_include_directive = 157,        /* include_directive  */
  YYSYMBOL_158_2 = 158,                    /* @2  */
  YYSYMBOL_includetype = 159,              /* includetype  */
  YYSYMBOL_inline_directive = 160,         /* inline_directive  */
  YYSYMBOL_insert_directive = 161,         /* insert_directive  */
  YYSYMBOL_module_directive = 162,         /* module_directive  */
  YYSYMBOL_native_directive = 163,         /* native_directive  */
  YYSYMBOL_pragma_directive = 164,         /* pragma_directive  */
  YYSYMBOL_pragma_arg = 165,               /* pragma_arg  */
  YYSYMBOL_pragma_lang = 166,              /* pragma_lang  */
  YYSYMBOL_rename_directive = 167,         /* rename_directive  */
  YYSYMBOL_rename_namewarn = 168,          /* rename_namewarn  */
  YYSYMBOL_feature_directive = 169,        /* feature_directive  */
  YYSYMBOL_stringbracesemi = 170,          /* stringbracesemi  */
  YYSYMBOL_featattr = 171,                 /* featattr  */
  YYSYMBOL_varargs_directive = 172,        /* varargs_directive  */
  YYSYMBOL_varargs_parms = 173,            /* varargs_parms  */
  YYSYMBOL_typemap_directive = 174,        /* typemap_directive  */
  YYSYMBOL_typemap_type = 175,             /* typemap_type  */
  YYSYMBOL_tm_list = 176,                  /* tm_list  */
  YYSYMBOL_tm_list_builder = 177,          /* tm_list_builder  */
  YYSYMBOL_typemap_parm = 178,             /* typemap_parm  */
  YYSYMBOL_types_directive = 179,          /* types_directive  */
  YYSYMBOL_template_directive = 180,       /* template_directive  */
  YYSYMBOL_warn_directive = 181,           /* warn_directive  */
  YYSYMBOL_c_declaration = 182,            /* c_declaration  */
  YYSYMBOL_183_3 = 183,                    /* $@3  */
  YYSYMBOL_c_decl = 184,                   /* c_decl  */
  YYSYMBOL_c_decl_tail = 185,              /* c_decl_tail  */
  YYSYMBOL_initializer = 186,              /* initializer  */
  YYSYMBOL_cpp_alternate_rettype = 187,    /* cpp_alternate_rettype  */
  YYSYMBOL_cpp_lambda_decl = 188,          /* cpp_lambda_decl  */
  YYSYMBOL_lambda_introducer = 189,        /* lambda_introducer  */
  YYSYMBOL_lambda_template = 190,          /* lambda_template  */
  YYSYMBOL_lambda_body = 191,              /* lambda_body  */
  YYSYMBOL_lambda_tail = 192,              /* lambda_tail  */
  YYSYMBOL_193_4 = 193,                    /* $@4  */
  YYSYMBOL_c_enum_key = 194,               /* c_enum_key  */
  YYSYMBOL_c_enum_inherit = 195,           /* c_enum_inherit  */
  YYSYMBOL_c_enum_forward_decl = 196,      /* c_enum_forward_decl  */
  YYSYMBOL_c_enum_decl = 197,              /* c_enum_decl  */
  YYSYMBOL_c_constructor_decl = 198,       /* c_constructor_decl  */
  YYSYMBOL_cpp_declaration = 199,          /* cpp_declaration  */
  YYSYMBOL_cpp_class_decl = 200,           /* cpp_class_decl  */
  YYSYMBOL_201_5 = 201,                    /* @5  */
  YYSYMBOL_202_6 = 202,                    /* @6  */
  YYSYMBOL_cpp_opt_declarators = 203,      /* cpp_opt_declarators  */
  YYSYMBOL_cpp_forward_class_decl = 204,   /* cpp_forward_class_decl  */
  YYSYMBOL_cpp_template_decl = 205,        /* cpp_template_decl  */
  YYSYMBOL_206_7 = 206,                    /* $@7  */
  YYSYMBOL_cpp_template_possible = 207,    /* cpp_template_possible  */
  YYSYMBOL_template_parms = 208,           /* template_parms  */
  YYSYMBOL_template_parms_builder = 209,   /* template_parms_builder  */
  YYSYMBOL_templateparameter = 210,        /* templateparameter  */
  YYSYMBOL_cpp_using_decl = 211,           /* cpp_using_decl  */
  YYSYMBOL_cpp_namespace_decl = 212,       /* cpp_namespace_decl  */
  YYSYMBOL_213_8 = 213,                    /* @8  */
  YYSYMBOL_214_9 = 214,                    /* @9  */
  YYSYMBOL_cpp_members = 215,              /* cpp_members  */
  YYSYMBOL_cpp_members_builder = 216,      /* cpp_members_builder  */
  YYSYMBOL_cpp_member_no_dox = 217,        /* cpp_member_no_dox  */
  YYSYMBOL_cpp_member = 218,               /* cpp_member  */
  YYSYMBOL_219_10 = 219,                   /* $@10  */
  YYSYMBOL_cpp_constructor_decl = 220,     /* cpp_constructor_decl  */
  YYSYMBOL_cpp_destructor_decl = 221,      /* cpp_destructor_decl  */
  YYSYMBOL_cpp_conversion_operator = 222,  /* cpp_conversion_operator  */
  YYSYMBOL_cpp_catch_decl = 223,           /* cpp_catch_decl  */
  YYSYMBOL_cpp_static_assert = 224,        /* cpp_static_assert  */
  YYSYMBOL_cpp_protection_decl = 225,      /* cpp_protection_decl  */
  YYSYMBOL_cpp_swig_directive = 226,       /* cpp_swig_directive  */
  YYSYMBOL_cpp_vend = 227,                 /* cpp_vend  */
  YYSYMBOL_anonymous_bitfield = 228,       /* anonymous_bitfield  */
  YYSYMBOL_anon_bitfield_type = 229,       /* anon_bitfield_type  */
  YYSYMBOL_storage_class = 230,            /* storage_class  */
  YYSYMBOL_storage_class_list = 231,       /* storage_class_list  */
  YYSYMBOL_storage_class_raw = 232,        /* storage_class_raw  */
  YYSYMBOL_parms = 233,                    /* parms  */
  YYSYMBOL_rawparms = 234,                 /* rawparms  */
  YYSYMBOL_parm_no_dox = 235,              /* parm_no_dox  */
  YYSYMBOL_parm = 236,                     /* parm  */
  YYSYMBOL_valparms = 237,                 /* valparms  */
  YYSYMBOL_valparms_builder = 238,         /* valparms_builder  */
  YYSYMBOL_valparm = 239,                  /* valparm  */
  YYSYMBOL_def_args = 240,                 /* def_args  */
  YYSYMBOL_parameter_declarator = 241,     /* parameter_declarator  */
  YYSYMBOL_plain_declarator = 242,         /* plain_declarator  */
  YYSYMBOL_declarator = 243,               /* declarator  */
  YYSYMBOL_notso_direct_declarator = 244,  /* notso_direct_declarator  */
  YYSYMBOL_direct_declarator = 245,        /* direct_declarator  */
  YYSYMBOL_abstract_declarator = 246,      /* abstract_declarator  */
  YYSYMBOL_direct_abstract_declarator = 247, /* direct_abstract_declarator  */
  YYSYMBOL_pointer = 248,                  /* pointer  */
  YYSYMBOL_cv_ref_qualifier = 249,         /* cv_ref_qualifier  */
  YYSYMBOL_ref_qualifier = 250,            /* ref_qualifier  */
  YYSYMBOL_type_qualifier = 251,           /* type_qualifier  */
  YYSYMBOL_type_qualifier_raw = 252,       /* type_qualifier_raw  */
  YYSYMBOL_type = 253,                     /* type  */
  YYSYMBOL_rawtype = 254,                  /* rawtype  */
  YYSYMBOL_type_right = 255,               /* type_right  */
  YYSYMBOL_decltype = 256,                 /* decltype  */
  YYSYMBOL_257_11 = 257,                   /* @11  */
  YYSYMBOL_decltypeexpr = 258,             /* decltypeexpr  */
  YYSYMBOL_primitive_type = 259,           /* primitive_type  */
  YYSYMBOL_primitive_type_list = 260,      /* primitive_type_list  */
  YYSYMBOL_type_specifier = 261,           /* type_specifier  */
  YYSYMBOL_definetype = 262,               /* definetype  */
  YYSYMBOL_default_delete = 263,           /* default_delete  */
  YYSYMBOL_deleted_definition = 264,       /* deleted_definition  */
  YYSYMBOL_explicit_default = 265,         /* explicit_default  */
  YYSYMBOL_ename = 266,                    /* ename  */
  YYSYMBOL_constant_directives = 267,      /* constant_directives  */
  YYSYMBOL_optional_ignored_defines = 268, /* optional_ignored_defines  */
  YYSYMBOL_enumlist = 269,                 /* enumlist  */
  YYSYMBOL_enumlist_item = 270,            /* enumlist_item  */
  YYSYMBOL_edecl_with_dox = 271,           /* edecl_with_dox  */
  YYSYMBOL_edecl = 272,                    /* edecl  */
  YYSYMBOL_etype = 273,                    /* etype  */
  YYSYMBOL_expr = 274,                     /* expr  */
  YYSYMBOL_exprmem = 275,                  /* exprmem  */
  YYSYMBOL_exprsimple = 276,               /* exprsimple  */
  YYSYMBOL_valexpr = 277,                  /* valexpr  */
  YYSYMBOL_exprnum = 278,                  /* exprnum  */
  YYSYMBOL_exprcompound = 279,             /* exprcompound  */
  YYSYMBOL_variadic_opt = 280,             /* variadic_opt  */
  YYSYMBOL_inherit = 281,                  /* inherit  */
  YYSYMBOL_raw_inherit = 282,              /* raw_inherit  */
  YYSYMBOL_283_12 = 283,                   /* $@12  */
  YYSYMBOL_base_list = 284,                /* base_list  */
  YYSYMBOL_base_specifier = 285,           /* base_specifier  */
  YYSYMBOL_286_13 = 286,                   /* @13  */
  YYSYMBOL_287_14 = 287,                   /* @14  */
  YYSYMBOL_access_specifier = 288,         /* access_specifier  */
  YYSYMBOL_templcpptype = 289,             /* templcpptype  */
  YYSYMBOL_cpptype = 290,                  /* cpptype  */
  YYSYMBOL_classkey = 291,                 /* classkey  */
  YYSYMBOL_classkeyopt = 292,              /* classkeyopt  */
  YYSYMBOL_opt_virtual = 293,              /* opt_virtual  */
  YYSYMBOL_virt_specifier_seq = 294,       /* virt_specifier_seq  */
  YYSYMBOL_virt_specifier_seq_opt = 295,   /* virt_specifier_seq_opt  */
  YYSYMBOL_class_virt_specifier_opt = 296, /* class_virt_specifier_opt  */
  YYSYMBOL_exception_specification = 297,  /* exception_specification  */
  YYSYMBOL_qualifiers_exception_specification = 298, /* qualifiers_exception_specification  */
  YYSYMBOL_cpp_const = 299,                /* cpp_const  */
  YYSYMBOL_ctor_end = 300,                 /* ctor_end  */
  YYSYMBOL_ctor_initializer = 301,         /* ctor_initializer  */
  YYSYMBOL_mem_initializer_list = 302,     /* mem_initializer_list  */
  YYSYMBOL_mem_initializer = 303,          /* mem_initializer  */
  YYSYMBOL_less_valparms_greater = 304,    /* less_valparms_greater  */
  YYSYMBOL_identifier = 305,               /* identifier  */
  YYSYMBOL_idstring = 306,                 /* idstring  */
  YYSYMBOL_idstringopt = 307,              /* idstringopt  */
  YYSYMBOL_idcolon = 308,                  /* idcolon  */
  YYSYMBOL_idcolontail = 309,              /* idcolontail  */
  YYSYMBOL_idtemplate = 310,               /* idtemplate  */
  YYSYMBOL_idtemplatetemplate = 311,       /* idtemplatetemplate  */
  YYSYMBOL_idcolonnt = 312,                /* idcolonnt  */
  YYSYMBOL_idcolontailnt = 313,            /* idcolontailnt  */
  YYSYMBOL_string = 314,                   /* string  */
  YYSYMBOL_wstring = 315,                  /* wstring  */
  YYSYMBOL_stringbrace = 316,              /* stringbrace  */
  YYSYMBOL_options = 317,                  /* options  */
  YYSYMBOL_kwargs = 318,                   /* kwargs  */
  YYSYMBOL_kwargs_builder = 319,           /* kwargs_builder  */
  YYSYMBOL_stringnum = 320                 /* stringnum  */
};
typedef enum yysymbol_kind_t yysymbol_kind_t;


/* Second part of user prologue.  */
#line 1886 "./CParse/parser.y"


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


#line 2064 "CParse/parser.c"


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
#define YYFINAL  60
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   9403

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  143
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  178
/* YYNRULES -- Number of rules.  */
#define YYNRULES  639
/* YYNSTATES -- Number of states.  */
#define YYNSTATES  1162

/* YYMAXUTOK -- Last valid token kind.  */
#define YYMAXUTOK   397


/* YYTRANSLATE(TOKEN-NUM) -- Symbol number corresponding to TOKEN-NUM
   as returned by yylex, with out-of-bounds checking.  */
#define YYTRANSLATE(YYX) YY_CAST (yysymbol_kind_t, YYX)

#if YYDEBUG
/* YYRLINE[YYN] -- Source line where rule number YYN was defined.  */
static const yytype_int16 yyrline[] =
{
       0,  1959,  1959,  1971,  1975,  1978,  1981,  1984,  1987,  1992,
    2001,  2006,  2015,  2020,  2021,  2022,  2023,  2024,  2033,  2049,
    2060,  2061,  2062,  2063,  2064,  2065,  2066,  2067,  2068,  2069,
    2070,  2071,  2072,  2073,  2074,  2075,  2076,  2077,  2078,  2085,
    2085,  2167,  2177,  2191,  2209,  2227,  2245,  2249,  2260,  2269,
    2282,  2289,  2293,  2304,  2314,  2329,  2342,  2342,  2403,  2404,
    2411,  2429,  2463,  2468,  2478,  2484,  2502,  2545,  2552,  2579,
    2585,  2592,  2593,  2596,  2597,  2604,  2650,  2696,  2707,  2710,
    2737,  2743,  2751,  2757,  2765,  2766,  2767,  2770,  2776,  2783,
    2819,  2820,  2854,  2873,  2883,  2898,  2920,  2925,  2928,  2939,
    2950,  2955,  2968,  2980,  3224,  3234,  3241,  3242,  3246,  3246,
    3279,  3285,  3295,  3307,  3314,  3397,  3445,  3510,  3552,  3569,
    3584,  3588,  3615,  3619,  3630,  3631,  3637,  3638,  3639,  3640,
    3644,  3645,  3646,  3650,  3654,  3659,  3664,  3675,  3681,  3687,
    3695,  3700,  3703,  3706,  3710,  3711,  3711,  3723,  3726,  3729,
    3738,  3741,  3748,  3771,  3800,  3898,  3955,  3956,  3957,  3958,
    3959,  3960,  3969,  3969,  4216,  4216,  4371,  4372,  4384,  4403,
    4403,  4607,  4613,  4619,  4625,  4631,  4632,  4633,  4634,  4637,
    4638,  4641,  4644,  4649,  4652,  4663,  4671,  4679,  4687,  4712,
    4723,  4733,  4764,  4764,  4822,  4822,  4844,  4871,  4874,  4879,
    4882,  4887,  4893,  4896,  4926,  4927,  4944,  4945,  4946,  4947,
    4948,  4949,  4950,  4951,  4952,  4953,  4954,  4955,  4956,  4957,
    4958,  4959,  4960,  4962,  4963,  4967,  4971,  4971,  4990,  5028,
    5069,  5090,  5113,  5137,  5162,  5187,  5195,  5202,  5209,  5217,
    5225,  5228,  5230,  5231,  5232,  5233,  5234,  5235,  5236,  5237,
    5240,  5244,  5249,  5256,  5259,  5260,  5261,  5262,  5264,  5270,
    5312,  5315,  5316,  5324,  5325,  5335,  5336,  5337,  5338,  5339,
    5340,  5341,  5348,  5360,  5361,  5365,  5370,  5376,  5383,  5390,
    5395,  5407,  5415,  5416,  5422,  5430,  5435,  5438,  5449,  5477,
    5487,  5490,  5498,  5504,  5510,  5516,  5522,  5530,  5553,  5570,
    5589,  5608,  5613,  5621,  5630,  5639,  5643,  5652,  5663,  5674,
    5686,  5696,  5710,  5719,  5729,  5739,  5749,  5761,  5773,  5786,
    5797,  5808,  5820,  5834,  5839,  5845,  5857,  5865,  5876,  5887,
    5898,  5917,  5923,  5936,  5944,  5951,  5958,  5969,  5981,  5992,
    6004,  6015,  6026,  6046,  6060,  6065,  6071,  6077,  6083,  6092,
    6101,  6102,  6111,  6120,  6126,  6132,  6137,  6143,  6151,  6162,
    6173,  6184,  6189,  6194,  6197,  6214,  6232,  6242,  6247,  6251,
    6256,  6263,  6266,  6271,  6278,  6282,  6288,  6292,  6298,  6299,
    6300,  6306,  6312,  6316,  6317,  6321,  6326,  6332,  6333,  6334,
    6335,  6336,  6338,  6341,  6344,  6347,  6347,  6364,  6367,  6380,
    6406,  6407,  6461,  6465,  6469,  6473,  6477,  6481,  6485,  6489,
    6493,  6497,  6501,  6505,  6509,  6513,  6519,  6520,  6523,  6524,
    6528,  6536,  6545,  6546,  6549,  6550,  6554,  6555,  6565,  6569,
    6574,  6580,  6590,  6601,  6612,  6617,  6622,  6623,  6629,  6637,
    6655,  6673,  6674,  6701,  6705,  6711,  6715,  6721,  6725,  6731,
    6735,  6744,  6745,  6746,  6752,  6758,  6764,  6776,  6784,  6792,
    6799,  6809,  6816,  6817,  6820,  6830,  6869,  6879,  6889,  6899,
    6910,  6921,  6942,  6965,  6966,  6967,  6968,  6969,  6970,  6971,
    6972,  6973,  6974,  6977,  6982,  6987,  6992,  6997,  7002,  7007,
    7012,  7017,  7022,  7027,  7032,  7037,  7042,  7051,  7062,  7067,
    7072,  7089,  7094,  7099,  7104,  7109,  7114,  7119,  7124,  7129,
    7134,  7139,  7144,  7149,  7154,  7163,  7173,  7178,  7183,  7189,
    7204,  7211,  7237,  7248,  7253,  7258,  7285,  7288,  7293,  7296,
    7296,  7297,  7300,  7317,  7326,  7326,  7345,  7345,  7364,  7365,
    7366,  7369,  7374,  7381,  7382,  7386,  7392,  7395,  7398,  7403,
    7404,  7407,  7408,  7411,  7414,  7417,  7420,  7425,  7426,  7431,
    7434,  7439,  7444,  7448,  7452,  7458,  7463,  7469,  7474,  7477,
    7484,  7485,  7490,  7500,  7510,  7516,  7522,  7528,  7542,  7543,
    7546,  7547,  7548,  7549,  7552,  7564,  7570,  7579,  7580,  7581,
    7584,  7585,  7586,  7589,  7590,  7593,  7597,  7601,  7604,  7607,
    7610,  7615,  7621,  7625,  7628,  7632,  7638,  7641,  7648,  7649,
    7657,  7661,  7665,  7668,  7671,  7674,  7680,  7684,  7687,  7691,
    7697,  7702,  7704,  7710,  7716,  7722,  7725,  7726,  7730,  7733,
    7746,  7750,  7755,  7762,  7771,  7776,  7783,  7788,  7797,  7798
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
  "TYPE_SIGNED", "TYPE_BOOL", "TYPE_COMPLEX", "TYPE_RAW",
  "TYPE_NON_ISO_INT8", "TYPE_NON_ISO_INT16", "TYPE_NON_ISO_INT32",
  "TYPE_NON_ISO_INT64", "LPAREN", "RPAREN", "COMMA", "SEMI", "EXTERN",
  "LBRACE", "RBRACE", "PERIOD", "ELLIPSIS", "CONST_QUAL", "VOLATILE",
  "REGISTER", "STRUCT", "UNION", "EQUAL", "SIZEOF", "ALIGNOF", "MODULE",
  "LBRACKET", "RBRACKET", "BEGINFILE", "ENDOFFILE", "CONSTANT", "RENAME",
  "NAMEWARN", "EXTEND", "PRAGMA", "FEATURE", "VARARGS", "ENUM", "CLASS",
  "TYPENAME", "PRIVATE", "PUBLIC", "PROTECTED", "COLON", "STATIC",
  "VIRTUAL", "FRIEND", "THROW", "CATCH", "EXPLICIT", "STATIC_ASSERT",
  "CONSTEXPR", "THREAD_LOCAL", "DECLTYPE", "AUTO", "NOEXCEPT", "OVERRIDE",
  "FINAL", "USING", "NAMESPACE", "NATIVE", "INLINE", "TYPEMAP", "ECHO",
  "APPLY", "CLEAR", "SWIGTEMPLATE", "FRAGMENT", "WARN", "LESSTHAN",
  "GREATERTHAN", "DELETE_KW", "DEFAULT", "LESSTHANOREQUALTO",
  "GREATERTHANOREQUALTO", "EQUALTO", "NOTEQUALTO", "LESSEQUALGREATER",
  "ARROW", "QUESTIONMARK", "TYPES", "PARMS", "NONID", "DSTAR", "DCNOT",
  "TEMPLATE", "OPERATOR", "CONVERSIONOPERATOR", "PARSETYPE", "PARSEPARM",
  "PARSEPARMS", "DOXYGENSTRING", "DOXYGENPOSTSTRING", "CAST", "LOR",
  "LAND", "OR", "XOR", "AND", "LSHIFT", "RSHIFT", "PLUS", "MINUS", "STAR",
  "SLASH", "MODULO", "UMINUS", "NOT", "LNOT", "DCOLON", "$accept",
  "program", "interface", "declaration", "swig_directive",
  "extend_directive", "$@1", "apply_directive", "clear_directive",
  "constant_directive", "echo_directive", "stringtype", "fname",
  "fragment_directive", "include_directive", "@2", "includetype",
  "inline_directive", "insert_directive", "module_directive",
  "native_directive", "pragma_directive", "pragma_arg", "pragma_lang",
  "rename_directive", "rename_namewarn", "feature_directive",
  "stringbracesemi", "featattr", "varargs_directive", "varargs_parms",
  "typemap_directive", "typemap_type", "tm_list", "tm_list_builder",
  "typemap_parm", "types_directive", "template_directive",
  "warn_directive", "c_declaration", "$@3", "c_decl", "c_decl_tail",
  "initializer", "cpp_alternate_rettype", "cpp_lambda_decl",
  "lambda_introducer", "lambda_template", "lambda_body", "lambda_tail",
  "$@4", "c_enum_key", "c_enum_inherit", "c_enum_forward_decl",
  "c_enum_decl", "c_constructor_decl", "cpp_declaration", "cpp_class_decl",
  "@5", "@6", "cpp_opt_declarators", "cpp_forward_class_decl",
  "cpp_template_decl", "$@7", "cpp_template_possible", "template_parms",
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

#define YYPACT_NINF (-1035)

#define yypact_value_is_default(Yyn) \
  ((Yyn) == YYPACT_NINF)

#define YYTABLE_NINF (-607)

#define yytable_value_is_error(Yyn) \
  0

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
static const yytype_int16 yypact[] =
{
     527,  7562,  7663,   271,    86,  7008, -1035, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,
   -1035,   297,    70,    70,    55, -1035, -1035,    63,     4,  8377,
     409, -1035,   217,  8587, -1035,   556,   850, -1035, -1035, -1035,
    1832, -1035,   409,     4, -1035,   247, -1035,   292, -1035,  8069,
   -1035,   113, -1035, -1035, -1035,   199, -1035, -1035,    54,   332,
    8235, -1035, -1035,   332,   347,   406,   414, -1035, -1035, -1035,
     441, -1035,   445, -1035, -1035,   146,   381,   466,   233,   493,
      76,  8447,  8447,   515,   526,   484,   531,  8657, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,   332,
   -1035, -1035, -1035, -1035, -1035, -1035,  1710, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035,  8517,   898, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035,   471,  2667, -1035, -1035,
   -1035, -1035, -1035,   850,  6642, -1035,  2531,  3211,    62,   321,
     593,   850,   409, -1035, -1035,   521,   340,   521,   470,  1639,
     500,   850, -1035, -1035, -1035,    68,   514, -1035, -1035,   545,
   -1035,    45, -1035,   834, -1035,  8849,   296,   834,   834,   195,
    6458,   573,    12,   449,    68,    68,   834,  7867,  8069, -1035,
     409,   409,   240, -1035,   153,   592,    68, -1035, -1035,   834,
   -1035,   625,  8069,   597,   218,   626,   629, -1035,   834,   484,
     625,  8069, -1035, -1035, -1035,   409,  7968,   409,   409, -1035,
   -1035,   409,   452,   484,  1982,    87,   163,   834,   477,  1200,
     560,  6458,   409,  6472,   404,   484, -1035,  2282,    68, -1035,
   -1035,   247,    69, -1035, -1035, -1035, -1035, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035,  6203,  9230,   647,   650,
    6203,  6203,  6203,  6203,  6203,  6203, -1035,   594,   652, -1035,
     663,  1141,  3314,   175, -1035,    98, -1035, -1035,   360,   536,
     850,  6755,  1439,  1439,   674,   678,  1650,   589, -1035, -1035,
   -1035,   665, -1035, -1035, -1035,  3314, -1035, -1035,  9166,   687,
    6755,  1184,   409,   481,   470, -1035, -1035,  1184,   481,   470,
   -1035,   850, -1035, -1035,  8069,  3347, -1035,  8069,  3483,  1184,
    1574,  1880,   850,   481,   470, -1035,   616,  1491, -1035, -1035,
     247,   735,  7764, -1035,   694, -1035, -1035,   697,   625,   409,
     409, -1035, -1035,   689,   726,   728, -1035, -1035, -1035,   267,
     521,   491,  2803, -1035, -1035, -1035, -1035,   409,   738,   731,
     745,   750,   739, -1035,   754,   765,   769, -1035,  8587, -1035,
     409, -1035,   776,   778, -1035,   783,  8447, -1035, -1035,   496,
   -1035, -1035,  8447, -1035,   784, -1035,   585,   369,   788,   486,
     734,   730,   800, -1035, -1035,   250,   805, -1035, -1035, -1035,
   -1035,   185,  1330,  1330,   333,   223,   729,   809,   282,  1184,
    1184,   819,  8069,  1184,  1547,  2016,   736,  1510,   969,    17,
     793,   386,  6868,   969, -1035,   818, -1035,   399,   625,   830,
   -1035,  2249,     4, -1035,   871,   873,  6612,   777,    69, -1035,
     841, -1035, -1035, -1035,  2256, -1035, -1035, -1035, -1035, -1035,
   -1035,  2667, -1035,  3619,  3755,  3891,  4027,  6203,  6203,  4163,
    4299,  4435,  4571,  4707,  4843,  4979,  5115,  5251,  5387,  5523,
    5659,   881,   885, -1035, -1035, -1035,   446,   446,  6874,   779,
     468, -1035,   506, -1035, -1035,   446,   446,   618,   787,   426,
   -1035, -1035,  8069,  6381,    36,   481, -1035,  8069,  5795,   481,
     847, -1035,  9199,   863, -1035,  9232,   481,  1184,   481,   470,
   -1035,  1184,   481,   470, -1035,   850,  6396,  1184,   861,  2152,
     481,   850, -1035, -1035,  8069, -1035,  8069,   220,   870, -1035,
   -1035,  1418, -1035,   834,   883,  8069,   888,   868, -1035,   410,
    2638,   894,  8069,  6458,   869, -1035, -1035,   218,  7121,   902,
   -1035,   898,  8447,   884,   908,  8069, -1035,   670,   914,   834,
    8069,   400, -1035, -1035,  7968,   872,  7968, -1035,  8069, -1035,
     426,  1207,  1066,    47, -1035,   922,  1184,  1184,  6503,   925,
      34,   879,   889, -1035, -1035,   767, -1035,    88, -1035, -1035,
   -1035,    23,  1874,  8919,   407,   928,   729,   173,   895, -1035,
   -1035, -1035,   903, -1035, -1035, -1035,   933,   943,  6203,  5931,
    2939,  3075,  6339,   216,  6067,    68, -1035, -1035,  1674, -1035,
    1674, -1035,  1173, -1035,  1173,  1013,  2639, -1035,  2795, -1035,
    3586, -1035,  3722, -1035,  2121, -1035,  2256, -1035,   857, -1035,
     857, -1035,   781, -1035,   781, -1035, -1035, -1035, -1035, -1035,
   -1035,   948,   955,   787,   850, -1035, -1035, -1035,   578,   961,
     962,   426,   966,   672,   787, -1035,   191,   967, -1035,  9265,
     969, -1035,    88, -1035,   481,   481,  1184,   963,  2490,   481,
     470,   481,  1184,  1184,   481, -1035, -1035, -1035, -1035,   625,
    8069,  7234, -1035, -1035,   369, -1035,   960, -1035,   983, -1035,
   -1035, -1035, -1035,   625,   971,   112,   984,  1605, -1035,   969,
   -1035,   988, -1035, -1035,  7347,  8587,   804,  8069, -1035,   991,
     896, -1035,   342,   937, -1035,  1000,   998, -1035, -1035, -1035,
    1005, -1035,   625, -1035,   944,   409,   808, -1035,  1009, -1035,
     426,   969,   339,  1184, -1035,  8069,  6203, -1035, -1035, -1035,
   -1035, -1035, -1035,  8989,  1008, -1035,   951,  1019, -1035, -1035,
    1001,  6569,  2010,  6203,   350, -1035, -1035,  1025, -1035,   878,
    2401,  1029, -1035, -1035,  3314,  1036,  2906,  6203,  6203,  8587,
    6203,  1037,  1039,  1042,  3042,  1043,  6203, -1035, -1035, -1035,
   -1035,  1045,  1047, -1035, -1035,   773, -1035, -1035, -1035, -1035,
     481,  1184,  1184,   481,   481,   481,  1049, -1035,  1418,    88,
    2401,  1418,   834,  1051, -1035,   969,  1050, -1035, -1035,  6458,
     145, -1035,  8447, -1035,  1053,    88,    84,    68,   319, -1035,
    2667,   314, -1035,  8069,   554,  1041,    54,  8753, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035,  8305, -1035,  7460,  1054, -1035,
    1063,  3178,   591, -1035, -1035,   258, -1035,  1001, -1035,    61,
    1061,    57,  8069,  2803,  1055,  1035, -1035,  1065,  3314, -1035,
    6458, -1035, -1035, -1035,   895, -1035, -1035, -1035,   409, -1035,
   -1035, -1035,  1070,  1046,  1059,  1060,  9038, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035,  1074,  8134,   992,
   -1035, -1035, -1035, -1035, -1035, -1035, -1035, -1035,  1376, -1035,
   -1035, -1035,  3314,  3314,  3314,  6203,  6203, -1035, -1035, -1035,
    3450, -1035, -1035, -1035,   481,   481, -1035, -1035, -1035,   521,
    1080,   625,   984,  6403,   400, -1035,  1093, -1035,  1095, -1035,
   -1035, -1035,   342, -1035, -1035,   342,  1040, -1035, -1035,  1098,
     575,  8587,  7968,  6458,  8587,  6525, -1035, -1035,   591, -1035,
   -1035,   239,  8069, -1035,   577, -1035,    68,  1001, -1035,  1087,
    6418,    22, -1035,  1109,  1112,  1120,   581,   409,   607, -1035,
     969, -1035,    70,   895, -1035, -1035, -1035, -1035, -1035,  6440,
    9122, -1035, -1035,  1089,  1090,  1094,    68,  1096,  1097,    49,
    2401,  3314,  3314,  1125, -1035, -1035, -1035,   969, -1035, -1035,
   -1035, -1035, -1035,  1127,  1133, -1035,   521,   218,  1075,    19,
     207,  6868, -1035,   350,  1137, -1035, -1035, -1035, -1035, -1035,
    6203, -1035,   969,  1001, -1035,  1001,   610, -1035,  1136,  1140,
    1139,   467, -1035, -1035,   239, -1035,   409,  2401, -1035, -1035,
     969,  1150,  6203, -1035,  1145, -1035,  1149, -1035, -1035, -1035,
    1151, -1035,  2146,  8069,  1156,  1158,    25,  1159, -1035,   969,
    1160, -1035,  3314,   239, -1035, -1035, -1035, -1035, -1035,   409,
   -1035, -1035, -1035,   350,    70,  1161,   239,  8069,  6723,  6440,
   -1035, -1035,  1165,  8069,  8069,  8069,  1170,  6569,    75, -1035,
     350,  1169, -1035, -1035, -1035,   350,  1177, -1035, -1035,   969,
    1182,  1192,  1194,  8069, -1035,  8587,   577, -1035, -1035, -1035,
     969, -1035,   547,   969,   969,   969,  1195,  1180, -1035, -1035,
   -1035, -1035,  2803, -1035, -1035, -1035,   969,   577,  1196, -1035,
   -1035, -1035
};

/* YYDEFACT[STATE-NUM] -- Default reduction number in state STATE-NUM.
   Performed when YYTABLE does not specify something else to do.  Zero
   means the default is an error.  */
static const yytype_int16 yydefact[] =
{
      12,     0,     0,     0,     0,     0,     4,   587,   402,   410,
     403,   404,   407,   408,   405,   406,   389,   409,   388,   411,
     391,   412,   413,   414,   415,   281,   378,   379,   380,   544,
     545,   147,   527,   527,     0,   588,   589,     0,   599,     0,
       0,   282,     0,     0,   376,   293,   383,   394,   387,   399,
     400,   543,     0,   606,   392,   597,     6,     0,     8,   279,
       1,    17,    62,    58,    59,     0,   266,    16,   263,   630,
       0,    78,    79,   630,    74,     0,     0,   265,   267,   268,
       0,   269,     0,   270,   271,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    10,    11,
       9,    13,    20,    21,    22,    23,    24,    25,    26,   630,
      27,    28,    29,    30,    31,    32,     0,    33,    34,    35,
      36,    37,    38,    14,   105,   110,   107,   106,    18,    15,
     156,   157,   158,   159,   160,   161,   113,     0,   259,   261,
     149,   148,   526,   541,   542,   395,     0,   285,   600,   283,
     390,     3,   377,   382,   279,   386,     0,     0,   599,   527,
     527,   370,     0,   296,   280,   293,   305,   293,   350,   527,
     331,   384,   401,   393,   607,     0,     0,   595,     5,     0,
     272,   273,    19,     0,   621,     0,   264,     0,     0,     0,
       0,   381,   606,   550,     0,     0,     0,   279,   279,   236,
       0,     0,     0,   194,   606,     0,     0,    60,    61,     0,
      48,    49,   279,     0,   301,     0,    96,    97,   594,     0,
     104,   279,   128,   127,   130,     0,   182,     0,     0,   136,
     126,     0,   131,     0,     0,     0,     0,     0,   305,     0,
     331,     0,   423,     0,   531,   263,   262,     0,     0,   601,
     608,   598,   587,   625,   455,   456,   473,   474,   475,   476,
     477,   478,   479,   480,   481,   482,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   288,     0,   284,   286,
     442,   381,     0,   452,   462,   441,   451,   463,   453,   454,
     385,   279,   527,   527,     0,     0,   527,   392,   292,   420,
     421,   290,   417,   418,   419,   416,   441,   361,     0,     0,
     279,   526,     0,   307,   352,   354,   323,   526,   306,   351,
     353,   369,   332,   294,   279,     0,   295,   279,     0,   526,
     527,   527,   368,   302,   345,   344,   323,   355,   605,   604,
     603,     0,   279,   275,   274,   591,   590,     0,   592,     0,
       0,   620,   108,   634,     0,   631,    66,    47,    46,     0,
     293,   305,     0,   547,   548,   546,   549,     0,     0,    70,
      88,     0,     0,    90,     0,     0,     0,   189,     0,    12,
       0,   192,     0,     0,    95,     0,     0,    99,   298,   305,
     299,    42,     0,   593,     0,    52,     0,    51,     0,     0,
       0,     0,   181,   183,   188,   543,     0,   129,   171,   133,
     132,     0,     0,     0,     0,   590,     0,     0,     0,     0,
       0,     0,   279,     0,     0,     0,   323,     0,   571,   331,
     151,   606,   279,   571,   529,     0,   528,   393,   264,     0,
     396,     0,     0,   596,     0,     0,     0,   462,     0,   457,
       0,   461,   458,   459,   471,   522,   521,   472,   523,   524,
     586,     0,   525,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   624,   623,   622,   527,   527,   527,   392,
       0,   331,     0,   366,   363,   527,   527,     0,   331,   355,
     291,   362,   279,   527,   392,   316,   324,   279,     0,   315,
       0,   340,     0,     0,   359,     0,   312,   526,   304,   349,
     347,   526,   303,   348,   346,   367,   357,     0,     0,     0,
     308,   356,   602,     7,   279,   276,   279,     0,     0,   173,
      12,     0,   629,     0,     0,   279,     0,     0,    73,     0,
       0,     0,     0,     0,     0,   190,   191,   301,     0,     0,
      12,   260,     0,   100,     0,   279,    98,     0,     0,     0,
       0,     0,   135,   134,   182,   169,     0,   185,   279,    56,
       0,     0,     0,     0,    75,     0,     0,     0,     0,     0,
     562,   553,   554,   375,   374,   567,   373,   371,   563,   568,
     570,     0,     0,     0,     0,     0,   392,   293,   552,   164,
     168,   559,   531,   398,   397,   609,   447,   443,   464,     0,
       0,     0,   370,     0,     0,     0,   287,   518,   500,   517,
     499,   513,   495,   514,   496,   519,     0,   512,   494,   511,
     493,   507,   489,   508,   490,   506,   488,   509,   491,   510,
     492,   501,   483,   502,   484,   503,   485,   504,   486,   505,
     487,   449,   445,     0,   355,   335,   334,   333,   357,     0,
       0,   356,     0,     0,   323,   325,   355,     0,   328,     0,
     342,   341,   364,   360,   314,   313,     0,     0,     0,   309,
     358,   317,     0,     0,   311,   278,   277,    64,    65,    63,
     279,     0,   636,   639,   638,   632,   635,    44,     0,    43,
      39,    72,    69,    71,     0,   638,    88,     0,    91,   571,
     235,     0,   195,   196,     0,     0,     0,   279,    41,     0,
       0,   614,   612,     0,    55,     0,     0,   628,    85,   627,
       0,   102,   626,    84,     0,     0,   260,   184,     0,    12,
       0,   571,     0,     0,   342,   279,     0,   565,   556,   555,
     569,   372,   117,     0,     0,   140,   142,     0,   150,   152,
     427,   571,     0,     0,     0,   124,   551,   530,   532,   534,
       0,     0,   448,   444,   465,     0,     0,     0,     0,   369,
       0,     0,     0,     0,     0,     0,     0,   450,   446,   336,
     338,     0,     0,   343,   326,     0,   330,   329,   297,   365,
     318,     0,     0,   310,   322,   321,     0,   109,     0,   342,
       0,     0,     0,     0,    82,   571,     0,   111,   193,     0,
     606,    93,     0,    92,     0,   342,     0,     0,     0,   610,
     285,     0,    50,   279,     0,     0,   263,     0,   175,   176,
     179,   178,   170,   177,   180,     0,   172,     0,     0,    77,
       0,     0,   558,   119,   141,     0,   118,   424,   426,   434,
       0,   428,   279,     0,   568,   579,   155,     0,   125,   123,
       0,   120,   122,   114,   552,   539,   538,   540,     0,   536,
     201,   222,     0,     0,     0,     0,   260,   247,   248,   241,
     249,   220,   216,   245,   240,   242,   243,   244,   246,   221,
     217,   218,   204,   211,   210,   214,   213,     0,   260,   223,
     202,   205,   206,   209,   215,   207,   208,   219,     0,   162,
     515,   497,   468,   467,   466,     0,     0,   516,   498,   460,
     520,   337,   339,   327,   320,   319,   174,   637,   633,   293,
       0,   638,    88,     0,     0,    89,     0,    67,     0,   101,
     300,   615,   613,   619,   618,   617,     0,    53,    54,     0,
     293,     0,   182,     0,     0,     0,    57,    76,   561,   566,
     557,   293,   279,   143,     0,   425,     0,   427,   436,   438,
       0,   427,   430,   429,     0,     0,     0,     0,     0,   115,
     571,   533,   527,   552,   226,   238,   237,   239,   224,     0,
     260,   203,   225,   389,   388,   391,     0,     0,   387,   392,
       0,   470,   469,     0,    40,    87,    83,   571,    80,    68,
      94,   611,   616,     0,     0,   187,   293,   301,     0,   331,
       0,   279,   564,     0,     0,   145,   144,   139,   437,   435,
       0,   153,   571,   427,   431,   427,     0,   576,     0,   578,
     580,     0,   572,   573,   293,   535,     0,     0,   166,   165,
     571,     0,     0,   212,     0,    45,     0,   103,    86,   186,
       0,   169,     0,   279,     0,     0,     0,     0,   116,   571,
       0,   439,   440,   293,   433,   432,   574,   575,   577,     0,
     582,   584,   585,     0,   527,     0,   293,   279,     0,     0,
      81,   112,     0,   279,   279,   279,     0,   571,     0,   146,
       0,   581,   121,   537,   227,     0,     0,   253,   163,   571,
       0,     0,     0,   279,   228,     0,     0,   154,   583,   167,
     571,   234,     0,   571,   571,   571,     0,     0,   137,   229,
     250,   252,     0,   232,   231,   230,   571,     0,     0,   233,
     138,   251
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int16 yypgoto[] =
{
   -1035, -1035,  -347, -1035, -1035, -1035, -1035,     5,    26,    37,
      40,  -497, -1035,    41,    42, -1035, -1035, -1035,    51, -1035,
   -1035,    52, -1035, -1035,    71, -1035,    78,  -667,  -664,    97,
   -1035,    99, -1035,  -333, -1035,   -63,   100,   103,   104,   105,
   -1035,   492,  -911,  -922,  -177, -1035, -1035, -1035, -1034,  -694,
   -1035,   -74, -1035, -1035, -1035, -1035, -1035,    16, -1035, -1035,
     130,    21,    24, -1035, -1035,  -552, -1035,   667,   110, -1035,
   -1035, -1035,  -769, -1035,  -835,   327, -1035,   501, -1035,   504,
     111, -1035, -1035, -1035,   -73, -1035, -1035,    10, -1035,  1108,
     -53, -1035,  1214,    18,   415, -1035,   796,    -5, -1035,  -540,
      32,  1144,   -36,   -31,   -62,   -27,  -620,   657,   -41,    27,
     -58,    -1,    -2,   -84, -1035, -1035,   -48,  1208, -1035,  -335,
    -152, -1035, -1035, -1035,   394,   275,  -865, -1035, -1035,   278,
   -1035,   887, -1035,   434,  -131,  -502, -1035,   -30,   653, -1035,
   -1035, -1035,   384, -1035, -1035, -1035,  -215,    -6, -1035, -1035,
     268,  -565, -1035, -1035,  -571,   595,  -334,   159, -1035, -1035,
     183,    -3,   980,  -115, -1035,   706,  -197,  -139,  1115, -1035,
    -870,  1033, -1035,   558,   254,  -179, -1035,  -507
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int16 yydefgoto[] =
{
       0,     4,     5,   100,   101,   102,   820,   897,   898,   899,
     900,   395,   396,   901,   902,   749,   109,   110,   903,   112,
     113,   904,   712,   195,   905,   116,   906,   741,   551,   907,
     372,   908,   383,   215,   216,   217,   909,   910,   911,   912,
     540,   124,   883,   774,   227,   125,   766,   865,   984,  1047,
    1090,    40,   604,   126,   127,   128,   129,   913,  1020,   780,
    1069,   914,   915,   746,   852,   401,   402,   403,   916,   134,
     560,   379,   917,   918,   919,   920,  1067,   921,   922,   923,
     924,   136,   925,   926,  1141,   927,  1017,   928,   138,   139,
     294,   180,    41,   181,   277,   278,   279,   775,   164,   387,
     388,   313,   238,   295,   168,   239,   595,   596,    43,    44,
     280,   191,    46,    47,   247,   440,    48,    49,    50,   301,
     345,   303,   304,   430,   868,   869,   870,   871,   987,   988,
    1091,   305,   283,   284,   306,   286,   287,   335,   435,   436,
     608,   777,   778,   888,  1003,   889,    51,    52,   366,   367,
     779,   598,   981,   612,   599,   600,  1142,   876,   998,  1059,
    1060,   174,    53,   353,   394,    54,   177,    55,   251,   733,
     839,   288,   289,   743,   188,   354,   355,   705
};

/* YYTABLE[YYPACT[STATE-NUM]] -- What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule whose
   number is the opposite.  If YYTABLE_NINF, syntax error.  */
static const yytype_int16 yytable[] =
{
      45,    45,   143,   144,   302,   171,   179,   250,   349,   166,
     103,   405,   190,   229,   167,   137,   285,   721,   169,    42,
      57,   130,   744,   228,   760,   757,   131,   546,   213,   132,
     384,   104,   558,   214,   214,   148,   338,   250,    45,   703,
     163,   153,   105,   716,   702,   106,   107,   108,   703,   230,
     824,   950,   823,   564,   443,   417,   111,   114,    45,  1043,
     184,  1008,   809,   242,     7,   309,  1115,   362,   347,   762,
     152,     7,   602,   356,  1082,   756,   115,   165,   675,   243,
     210,   370,   184,   117,  1136,    70,    60,     7,   342,   675,
       7,   231,  1031,  1073,   601,  1032,   145,   314,   319,   607,
     991,   229,   118,   393,   119,   120,   147,   334,   121,   122,
     123,   228,   290,  1157,   147,   133,   135,   444,   351,   142,
     321,   983,   421,   591,   592,  -258,  1054,   296,   418,   315,
     320,   244,  1088,   427,   763,   427,   419,   230,    26,    27,
      28,  -289,  1103,   532,   373,   374,   281,  1053,   237,     7,
      35,    36,   676,    45,   361,   148,  1116,    35,    36,   385,
     323,   332,   326,   753,   147,   276,     7,  -592,   398,   343,
     344,  1120,   185,    35,    36,  1008,    35,    36,   389,   350,
     445,   992,   993,   390,  1125,   986,  1135,   169,  1094,   957,
    1095,   351,  1122,   701,     7,   357,    45,    45,   152,   949,
     874,  -289,    37,   961,   418,   146,    38,   414,   380,  1137,
     302,    45,   420,   724,  1139,   960,   593,   151,   200,   594,
      45,     7,   360,   481,   697,    45,   184,   312,   772,   726,
     314,   319,   418,   182,   334,    35,    36,   207,   201,   358,
     183,    26,    27,    28,   404,   166,   579,   147,  1083,   773,
     167,  1074,    35,    36,   169,   147,   490,   492,   790,   154,
     497,    37,   315,   320,   488,    38,   698,   767,   519,   523,
       7,   510,    58,   428,   513,   433,   163,   157,    37,   208,
      35,    36,    38,   503,   377,     7,   482,  1028,  1025,   535,
      45,   525,   178,  -293,   156,   378,   531,   980,  1105,   982,
     520,   524,   351,   312,   983,   156,    37,    35,    36,    45,
      38,   948,    59,   165,   952,   773,   703,   152,   967,   703,
     557,   947,     7,    45,     7,   147,    45,   193,   214,   566,
     285,   312,   414,    37,   214,  1084,     7,   158,  1085,  -606,
    -606,    45,   352,   161,   791,   351,   159,   792,   152,   160,
     140,   879,   332,  -293,   161,   544,    35,    36,   162,   405,
     968,   405,   310,   233,   175,  -606,   351,   483,   141,   585,
     311,    35,    36,   187,   359,   351,   490,   492,   497,   605,
     157,   324,    37,   859,     7,   826,    38,   597,   194,   176,
     735,   582,   597,   880,   881,   412,   882,    37,   413,   325,
     577,    38,   857,   161,   737,   414,   184,     7,    35,    36,
      35,    36,     7,  1042,   711,   570,   184,   858,   161,   623,
    1038,    45,    35,    36,   314,   319,   334,   203,   706,     7,
    -422,    45,  -422,   519,   523,   714,    37,   875,   964,   615,
      38,   334,  1148,   610,   738,  -560,   739,   196,    37,   672,
     302,   769,   158,   770,   677,   197,   315,   320,   671,   837,
     281,   312,  -422,  1160,   690,   520,   524,   154,   670,   332,
      35,    36,   169,   162,     7,  -560,    26,    27,    28,   276,
     434,   695,   198,   696,   838,   157,   199,   291,   147,   611,
     184,   954,   708,    35,    36,   142,    37,  1080,    35,    36,
      38,    45,   363,   364,   214,   157,    45,   206,  1101,   422,
     665,   327,   729,  1102,   740,    35,    36,     7,   422,    37,
     365,   389,   507,    38,    37,   748,   390,   325,    38,   328,
     169,   669,   545,    45,   209,    45,   325,   565,   995,   750,
     508,    37,   484,   485,    45,   158,   874,   422,   666,   670,
     325,    45,   152,   169,   159,   325,   218,   160,   152,     7,
      35,    36,   161,   103,    45,   325,   162,   219,   137,    45,
     718,   725,   221,    45,   130,    45,   156,    45,     7,   131,
     409,   789,   132,   410,   104,   719,   862,   341,   736,   248,
     249,  1150,   404,  1151,   404,   105,     7,   154,   106,   107,
     108,   768,  1152,    35,    36,   155,   690,    29,    30,   111,
     114,   156,   669,   751,   572,   157,   337,   573,  1045,   291,
     302,  1046,   155,   531,   152,    32,    33,   568,   569,   115,
     156,   351,   248,   339,   310,   531,   117,   157,   381,   597,
     802,   597,   317,   386,   169,    35,    36,   816,     1,     2,
       3,  1062,   157,  1063,  1096,   118,  1097,   119,   120,   422,
     667,   121,   122,   123,    35,    36,  1064,   829,   133,   135,
     391,    37,   392,     7,   834,   158,   427,   325,   597,   229,
     591,   592,    35,    36,   159,   299,   300,   160,   452,   228,
      37,   453,   161,  1076,    38,   461,   162,   460,   152,    45,
     447,   451,   860,   801,   462,   499,   103,   714,    37,   285,
     597,   137,    38,   507,   804,   230,   493,   130,  1093,   802,
     494,   302,   131,   169,   500,   132,    45,   104,   502,   103,
     597,   508,   526,   312,   137,   533,  1106,   536,   105,   537,
     130,   106,   107,   108,   541,   131,   150,   767,   132,   825,
     104,   170,   111,   114,    45,  1118,   855,   405,   173,    35,
      36,   105,   849,   229,   106,   107,   108,   850,   542,   958,
     851,   543,   115,   228,   214,   111,   114,   152,   597,   117,
     548,   553,   801,   875,   597,   730,   549,   153,   550,   731,
     969,   202,   205,   552,   597,   115,   554,   975,   118,   230,
     119,   120,   117,   232,   121,   122,   123,   867,   737,   555,
     184,   133,   135,   556,   507,   943,   152,  1158,   561,   994,
     562,   118,   240,   119,   120,   563,   567,   121,   122,   123,
     571,    66,   508,   575,   133,   135,   574,     7,   970,   281,
     184,   231,    45,   576,  1058,   580,   578,   589,   831,   244,
     739,   581,   588,   846,   242,   590,   591,   592,   276,   832,
     297,   956,   103,   584,   609,   316,   316,   137,   322,   603,
     975,    45,   613,   130,   616,   336,   617,  1071,   131,   624,
    1018,   132,   625,   104,   661,    77,    78,    79,   662,   680,
      81,   232,    83,    84,   105,   664,   240,   106,   107,   108,
      26,    27,    28,   668,   867,   682,   375,   376,   111,   114,
     692,   700,  1000,  1037,   710,   720,  1040,   478,   479,   480,
     170,    66,   244,    35,    36,   727,   847,   707,   115,  1044,
     302,   399,   709,   406,   407,   117,   717,   408,   299,   300,
     416,   316,   316,   245,  1023,   426,   723,   429,   150,   240,
     437,   885,   886,   887,   118,   728,   119,   120,   734,   597,
     121,   122,   123,   745,   754,  1035,   755,   133,   135,   758,
     771,    45,  1065,   776,   782,    77,    78,    79,   759,   434,
      81,    45,    83,    84,   783,  1027,   597,   170,  1087,   797,
     404,   476,   477,   478,   479,   480,   798,   489,   491,   491,
     302,   389,   498,   799,   800,   428,   390,   433,   803,   806,
     169,   597,   811,  1086,   414,   818,   504,   316,   506,    26,
      27,    28,  1052,   316,   867,   819,   821,   822,   867,   597,
    1112,  1079,   827,   835,   282,   316,   316,   316,   836,   840,
      45,  1070,   841,   316,   308,   842,   843,   844,   597,   589,
     192,   856,   863,   864,  1126,   538,   539,   590,   591,   592,
    1130,  1131,  1132,   866,    70,   416,   204,  1149,   884,     7,
    1153,  1154,  1155,   547,  1123,   929,   597,  1147,   930,   935,
    1146,   936,    45,  1159,   937,   939,   559,   941,   597,   942,
     867,   946,   867,   953,   955,   959,   971,   593,   977,   597,
     594,   186,   597,   597,   597,   978,    45,   418,   990,   999,
     996,   997,    45,    45,    45,   597,  1004,  1012,   491,   491,
     491,  1009,  1005,   211,   583,   316,   316,  1024,   220,   316,
     316,   316,    45,   316,   441,  1006,  1007,  1029,   606,  1030,
    1034,  1070,  1050,  1033,     7,   474,   475,   476,   477,   478,
     479,   480,  1055,   446,  1056,    35,    36,   454,   455,   456,
     457,   458,   459,   346,  1057,  -256,  -255,   346,   346,  1075,
    -257,  1077,  1072,  -254,   368,   369,   346,  1078,  1081,  1089,
    1098,    37,   154,  1099,  -293,    38,   382,     7,  1100,   346,
     155,  1107,  1109,  1110,   663,  1111,   156,  1113,   346,  1114,
     157,  1117,   332,     7,  1119,   170,   312,  1129,  1124,   674,
       7,  1133,   512,   184,   415,   515,   348,   346,  1138,  1140,
     348,   348,   431,   316,  1143,   418,   983,   316,   442,   348,
      35,    36,   316,   316,  1144,   316,  1145,  1156,   848,  1128,
    1161,   418,   348,   747,  -293,  1011,   246,   853,   359,   423,
     854,   348,   397,   149,   761,   966,    37,   626,   172,   240,
     158,   985,  1049,   170,  1048,   781,   411,   348,  1001,   159,
     348,  1066,   160,    35,    36,   808,  1134,   161,   438,   463,
     464,   162,  1121,   467,   833,     0,   170,   240,   316,    35,
      36,   340,   316,   316,   316,     0,    35,    36,     0,    37,
       0,     0,     0,    38,   318,   474,   475,   476,   477,   478,
     479,   480,     0,   333,     0,    37,     0,     0,     0,    38,
       0,     0,    37,     0,   312,     0,   158,     0,   424,     0,
       0,   425,     0,     7,     0,   235,   332,     0,   236,     0,
     312,     0,     0,   161,     0,     0,     0,   162,   282,     0,
     628,   630,   632,   634,   635,   636,   638,   640,   642,   644,
     646,   648,   650,   652,   654,   656,   658,   660,     0,     0,
       0,   359,     0,     0,     0,     0,     0,   170,     0,     7,
     318,     0,   316,   333,     0,     0,     0,     0,     0,     0,
       0,     0,   316,     0,   316,   679,     0,     0,   316,   316,
       8,     9,    10,    11,    12,    13,    14,    15,  1013,    17,
    1014,    19,  1015,    21,    22,    23,    24,     0,     0,    35,
      36,     0,     0,   240,   184,     0,    26,    27,    28,    29,
      30,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,     0,     7,     0,     0,    37,    31,    32,    33,   158,
       0,   845,     0,     0,     0,   505,   170,     0,     0,   316,
       0,   509,    34,   241,     0,    35,    36,     0,     0,   232,
     162,     0,     0,   516,   518,   522,     0,     0,     0,     0,
     154,   530,     0,     0,     0,     0,     0,     0,   142,     0,
       0,    37,     0,     0,     7,    38,   974,     0,   157,     0,
       0,     0,     0,     0,     0,   784,   786,   640,   646,   656,
       0,   794,     0,     7,     0,     0,  1016,   316,   316,     0,
       0,     0,     0,   346,     0,     0,     0,     0,    35,    36,
     346,     0,   418,     0,     0,   240,     0,     0,     0,     0,
     527,    26,    27,    28,     0,     0,     0,   732,     0,   346,
       7,   418,     0,   232,    37,     0,     0,     0,   158,   527,
       0,     0,     0,   505,   509,     0,     0,   516,   518,   522,
     699,   530,     0,     0,   704,     0,   348,     7,     0,   162,
      35,    36,   713,   715,     0,     0,   240,     0,   418,     0,
       0,     0,     0,     0,  1002,     0,   586,     0,     0,    35,
      36,     0,   348,     0,   742,   795,    37,     0,     7,   737,
      38,   184,     0,     0,   752,   310,     0,     0,     0,   528,
       0,     0,   529,   517,     0,    37,     0,     0,     0,    38,
       0,   312,     0,   157,  1019,     0,    35,    36,   528,     0,
       0,   529,     7,   861,     0,     0,   359,   673,     0,   738,
     312,   739,     0,     7,     0,     0,     0,     0,     0,   240,
     878,   684,    37,    35,    36,   685,    38,     0,     0,     0,
     689,   691,     0,   694,   932,   933,  1036,   934,     0,  1039,
     310,   240,     0,   940,     0,     0,     0,   312,   329,    37,
       0,   154,     0,    38,    35,    36,   240,     0,   157,   142,
       0,     0,     0,  1061,     0,   830,     0,     0,     0,   157,
       0,     0,     0,     7,   312,   240,     0,     0,     0,   740,
      37,     0,     0,     0,   158,     0,   673,   282,    35,    36,
     684,   685,   689,   235,     0,     0,   236,     0,     0,    35,
      36,   161,     0,   170,     0,   162,     0,   606,     0,     0,
     742,   234,     0,     0,    37,     0,     0,     0,    38,   742,
       0,     0,     0,     0,     0,    37,     0,   330,     0,   158,
     331,     0,  1104,     0,     0,   332,     0,     0,   495,   312,
       0,   496,     0,     0,   467,     0,   332,     0,     0,     0,
     162,     0,     0,     0,     0,     0,     0,     0,     0,    35,
      36,     0,   346,     0,     0,  1061,   474,   475,   476,   477,
     478,   479,   480,     0,     0,   240,   962,   963,   965,     0,
     805,     0,  1021,  1022,     0,    37,     0,     0,     0,   158,
     810,     0,   813,     0,     0,     0,   814,   815,   235,     0,
       0,   236,     0,     0,     0,     0,   161,     0,     0,   989,
     162,   704,     0,     0,   951,   348,     8,     9,    10,    11,
      12,    13,    14,    15,     0,    17,     0,    19,     0,    21,
      22,    23,    24,     0,     0,   764,     0,   252,     0,   438,
     184,   253,     0,     7,     0,   254,   255,   256,   257,   258,
     259,   260,   261,   262,   263,   264,   265,   805,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,   266,     0,     0,     0,     0,
       0,   310,     0,     0,    26,    27,    28,    29,    30,   521,
     267,   268,     0,   765,     0,     0,     0,  1092,     0,   157,
       0,     0,     0,     0,    31,    32,    33,     0,     0,     0,
       0,     0,     0,     0,     0,   944,   945,     0,     0,  1108,
      34,     0,   269,    35,    36,     0,   989,     0,     0,    35,
      36,     0,     0,     0,     0,     0,     0,     0,   299,   300,
       0,     0,     0,     0,     0,     7,     0,   742,   184,    37,
       0,     0,     0,    38,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,   270,     0,     0,   271,   272,
     273,   877,     0,   252,   274,   275,   184,   253,     0,     7,
     312,   254,   255,   256,   257,   258,   259,   260,   261,   262,
     263,   264,   265,     0,     8,     9,    10,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    23,
      24,   266,     0,     0,     0,     0,   298,   418,     0,     0,
      26,    27,    28,    29,    30,   587,   267,   268,     0,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     0,
      31,    32,    33,     0,     0,     0,   299,   300,     0,     0,
       0,     0,     0,     0,     0,     0,    34,    37,   269,    35,
      36,    38,     0,     0,     0,    35,    36,     0,     0,     0,
     412,     0,     0,   413,   299,   300,     0,     0,   161,     0,
       0,     0,     0,     0,     0,    37,     0,     0,     0,    38,
       0,    37,     0,     0,     0,    38,     0,     0,     0,     0,
       0,   270,     0,     0,   271,   272,   273,   764,     0,   252,
     274,   275,   184,   253,     0,     7,   312,   254,   255,   256,
     257,   258,   259,   260,   261,   262,   263,   264,   265,     0,
       8,     9,    10,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    23,    24,   266,     0,     0,
       0,     0,     0,   418,     0,     0,    26,    27,    28,    29,
      30,   693,   267,   268,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    31,    32,    33,     0,
       0,     0,     0,     0,     0,     0,     0,   463,   464,   465,
     466,   467,    34,     0,   269,    35,    36,     0,     0,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     0,
     299,   300,   473,   474,   475,   476,   477,   478,   479,   480,
       0,    37,     0,     0,     0,    38,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,     0,   270,     0,     0,
     271,   272,   273,   439,     0,   252,   274,   275,   184,   253,
       0,   614,   312,   254,   255,   256,   257,   258,   259,   260,
     261,   262,   263,   264,   265,     0,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,   266,     0,     0,     0,     0,     0,     0,
       0,     0,    26,    27,    28,    29,    30,     0,   267,   268,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    31,    32,    33,   463,   464,   465,   466,   467,
       0,   468,   463,   464,   465,   466,   467,     0,    34,     0,
     269,    35,    36,     0,     0,     0,   469,   470,   471,   472,
     473,   474,   475,   476,   477,   478,   479,   480,   474,   475,
     476,   477,   478,   479,   480,     0,     0,    37,     0,     0,
       0,    38,   890,     0,  -260,    62,     0,     0,     0,    63,
      64,    65,     0,   270,     0,     0,   271,   272,   273,     0,
       0,     0,   274,   275,    66,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,     0,     0,     0,   891,    68,     0,  -199,     0,
       0,  -260,  -260,  -260,  -260,  -260,     0,     0,     0,     0,
       0,     0,     0,     0,    70,    71,    72,   892,    74,    75,
      76,  -260,  -260,  -260,   893,   894,   895,     0,    77,    78,
      79,     0,    80,    81,    82,    83,    84,  -260,  -260,     0,
    -260,  -260,    85,     7,     0,     0,    89,    90,    91,    92,
      93,    94,    95,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    96,     0,  -260,     0,     0,    97,
    -260,  -260,     0,     0,     0,   896,     0,     0,     0,     0,
       0,   418,     0,     0,   252,     0,     0,   184,   253,   812,
       0,  -260,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,   298,     0,    35,
      36,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,     0,    37,     0,     0,     0,    38,
       0,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
     312,     0,     0,     0,     0,   299,   300,     0,     0,     0,
       0,     7,     0,     0,   184,     0,    37,     0,     0,     0,
      38,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,   796,    25,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,    35,    36,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,   299,   300,     0,   463,   464,   465,   466,   467,
       0,   468,     0,    34,     0,   269,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,   469,   470,   471,   472,
     473,   474,   475,   476,   477,   478,   479,   480,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,    39,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,     0,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,     0,     0,     0,
       0,   463,   464,   465,   466,   467,     0,   299,   300,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,   470,   471,   472,   473,   474,   475,   476,
     477,   478,   479,   480,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,   931,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,   787,     0,     0,     0,     0,     0,     0,   639,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,   463,   464,   465,   466,   467,     0,   468,     0,
       0,     0,     0,     0,     0,    34,     0,   269,    35,    36,
       0,     0,     0,   469,   470,   471,   472,   473,   474,   475,
     476,   477,   478,   479,   480,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     270,     0,     0,   271,   272,   273,     0,     0,   252,   274,
     275,   184,   253,     0,   938,     0,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   263,   264,   265,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   266,   788,     0,     0,
       0,     0,     0,     0,   645,    26,    27,    28,    29,    30,
       0,   267,   268,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,   463,   464,
     465,   466,   467,     0,   468,     0,     0,     0,     0,     0,
       0,    34,     0,   269,    35,    36,     0,     0,     0,   469,
     470,   471,   472,   473,   474,   475,   476,   477,   478,   479,
     480,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,     0,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   270,     0,     0,   271,
     272,   273,     0,     0,   252,   274,   275,   184,   253,     0,
     979,     0,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,     0,     0,     0,
       0,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,   307,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,   463,   464,   465,   466,   467,     0,
     468,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,   469,   470,   471,   472,   473,
     474,   475,   476,   477,   478,   479,   480,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,     0,     0,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,   511,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
     463,   464,   465,   466,   467,     0,   468,     0,     0,     0,
       0,     0,     0,    34,     0,   269,    35,    36,     0,     0,
       0,   469,   470,   471,   472,   473,   474,   475,   476,   477,
     478,   479,   480,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,     0,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,   514,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,   463,   464,   465,   466,
     467,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,   469,   470,   471,
     472,   473,   474,   475,   476,   477,   478,   479,   480,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,     0,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,     0,     0,     0,     0,     0,     0,     0,   627,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,   463,   464,   465,   466,   467,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,   269,    35,    36,
       0,     0,     0,     0,     0,   471,   472,   473,   474,   475,
     476,   477,   478,   479,   480,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     270,     0,     0,   271,   272,   273,     0,     0,   252,   274,
     275,   184,   253,     0,     0,     0,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   263,   264,   265,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   266,     0,     0,     0,
       0,     0,     0,     0,   629,    26,    27,    28,    29,    30,
       0,   267,   268,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,   463,   464,
     465,   466,   467,     0,     0,     0,     0,     0,     0,     0,
       0,    34,     0,   269,    35,    36,     0,     0,     0,     0,
       0,     0,   472,   473,   474,   475,   476,   477,   478,   479,
     480,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,     0,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   270,     0,     0,   271,
     272,   273,     0,     0,   252,   274,   275,   184,   253,     0,
       0,     0,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,     0,     0,     0,
     631,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,     0,   633,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,   269,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,   637,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,     0,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,     0,     0,     0,     0,     0,     0,     0,   639,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,   269,    35,    36,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     270,     0,     0,   271,   272,   273,     0,     0,   252,   274,
     275,   184,   253,     0,     0,     0,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   263,   264,   265,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   266,     0,     0,     0,
       0,     0,     0,     0,   641,    26,    27,    28,    29,    30,
       0,   267,   268,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    34,     0,   269,    35,    36,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,     0,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   270,     0,     0,   271,
     272,   273,     0,     0,   252,   274,   275,   184,   253,     0,
       0,     0,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,     0,     0,     0,
     643,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,     0,   645,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,   269,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,   647,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,     0,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,     0,     0,     0,     0,     0,     0,     0,   649,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,   269,    35,    36,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     270,     0,     0,   271,   272,   273,     0,     0,   252,   274,
     275,   184,   253,     0,     0,     0,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   263,   264,   265,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   266,     0,     0,     0,
       0,     0,     0,     0,   651,    26,    27,    28,    29,    30,
       0,   267,   268,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    34,     0,   269,    35,    36,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,     0,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   270,     0,     0,   271,
     272,   273,     0,     0,   252,   274,   275,   184,   253,     0,
       0,     0,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,     0,     0,     0,
     653,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,     0,   655,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,   269,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,   657,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,     0,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,     0,     0,     0,     0,     0,     0,     0,   659,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,   269,    35,    36,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     270,     0,     0,   271,   272,   273,     0,     0,   252,   274,
     275,   184,   253,     0,     0,     0,   254,   255,   256,   257,
     258,   259,   260,   261,   262,   263,   264,   265,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   266,     0,     0,     0,
       0,     0,     0,     0,     0,    26,    27,    28,    29,    30,
       0,   267,   268,     0,     0,   678,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    34,     0,   269,    35,    36,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     0,     0,     0,    38,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   270,     0,     0,   271,
     272,   273,     0,     0,   252,   274,   275,   184,   253,     0,
       0,     0,   254,   255,   256,   257,   258,   259,   260,   261,
     262,   263,   264,   265,     0,     8,     9,    10,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      23,    24,   266,     0,     0,     0,     0,     0,     0,     0,
     785,    26,    27,    28,    29,    30,     0,   267,   268,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    31,    32,    33,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    34,     0,   269,
      35,    36,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,    37,     0,     0,     0,
      38,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   270,     0,     0,   271,   272,   273,     0,     0,
     252,   274,   275,   184,   253,     0,     0,     0,   254,   255,
     256,   257,   258,   259,   260,   261,   262,   263,   264,   265,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   266,     0,
       0,     0,     0,     0,     0,     0,   793,    26,    27,    28,
      29,    30,     0,   267,   268,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,   269,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   270,     0,
       0,   271,   272,   273,     0,     0,   252,   274,   275,   184,
     253,     0,     0,     0,   254,   255,   256,   257,   258,   259,
     260,   261,   262,   263,   264,   265,     0,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,   266,     0,     0,     0,     0,     0,
       0,     0,     0,    26,    27,    28,    29,    30,     0,   267,
     268,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,   269,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,   270,     0,     0,   271,   272,   273,
       0,     0,   252,   274,   275,   184,   253,     0,     0,     0,
     254,   255,   256,   257,   258,   259,   260,   261,   262,   263,
     264,   265,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
     266,     0,     0,     0,     7,     0,     0,     0,   655,    26,
      27,    28,    29,    30,     0,   267,   268,     0,     0,     7,
       0,     0,     0,     0,     0,     0,     7,     0,     0,    31,
      32,    33,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     7,   310,     0,     0,    34,     0,   269,    35,    36,
     142,     0,     0,     0,     0,     0,     0,   310,     0,     0,
     157,     0,     0,     7,   359,   686,     0,  1026,     0,     0,
       0,     0,     0,     0,    37,   157,     0,     0,    38,   359,
       0,     7,  1051,     0,     0,     0,     0,     0,     0,     0,
      35,    36,     0,   271,   272,     7,     0,     0,     0,   274,
     275,   359,     0,     0,  1068,    35,    36,     0,     0,     0,
       0,     0,    35,    36,     0,     0,    37,     0,     0,   359,
      38,     0,     0,     0,     0,     0,     7,    35,    36,   495,
       0,    37,   496,   432,     0,    38,     0,   332,    37,     0,
       0,   312,   158,     0,   687,     0,     0,   688,     7,    35,
      36,   235,     0,    37,   236,     0,   312,   158,     0,   161,
       0,     0,     0,   162,   418,     0,   235,    35,    36,   236,
       0,     0,   686,     0,   161,    37,     0,     0,   162,   158,
       0,    35,    36,     0,     0,     0,  1041,     0,   235,     0,
       0,   236,     0,    37,     0,     0,   161,   158,     0,     0,
     162,     0,     0,     0,     0,     0,   235,    37,     0,   236,
       0,   158,    35,    36,   161,     0,     0,     0,   162,     0,
     235,     0,     0,   236,     0,     0,     0,     0,   161,     0,
     872,     0,   162,     0,    35,    36,     0,     0,    37,    26,
      27,    28,    38,     0,   873,     0,     0,     0,     0,     0,
       0,   687,     0,     0,   688,     0,     0,     0,     0,     0,
      37,     0,     0,   312,   158,     7,     0,     0,     0,   589,
       0,     0,     0,   235,   618,     0,   236,   590,   591,   592,
       0,   161,     0,     0,     0,   162,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,   291,     0,     0,     0,     0,     0,     0,
       0,    25,    26,    27,    28,    29,    30,   593,     0,     0,
     594,   157,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    31,    32,    33,   619,     0,     0,   463,   464,
     465,   466,   467,     0,   468,     0,     0,     0,    34,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,   469,
     620,   471,   472,   621,   474,   475,   476,   477,   622,   479,
     480,     0,     0,     0,     0,     0,     0,    37,     7,     0,
       0,    38,     0,     0,     0,     0,    39,  1127,     0,     0,
     292,     0,     0,   293,     0,     0,     0,     0,   161,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,   291,     0,     0,     0,
       0,     0,     0,     0,    25,    26,    27,    28,    29,    30,
       0,     0,     0,     0,   157,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     0,   463,
     464,   465,   466,   467,     0,   468,     0,     0,     0,     0,
       0,    34,     0,     0,    35,    36,     0,     0,     0,     0,
     469,   470,   471,   472,   473,   474,   475,   476,   477,   478,
     479,   480,     0,     0,     0,     0,     0,     0,     0,     0,
      37,     7,     0,     0,    38,     0,     0,     7,     0,    39,
       0,     0,     0,   486,     0,     0,   487,     0,     0,     0,
       0,   161,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,     0,
       0,     0,     0,     0,     0,   291,     0,    25,    26,    27,
      28,    29,    30,   142,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   157,     0,     0,     0,     0,    31,    32,
      33,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    34,     0,     0,    35,    36,     0,
       0,     0,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,     0,    38,     0,    37,
       0,     0,    39,    38,     0,     0,   412,     0,     0,   413,
       0,     0,   495,     0,   161,   496,     0,     0,    -2,    61,
     332,  -260,    62,     0,     0,     0,    63,    64,    65,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    66,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,     0,
       0,     0,    67,    68,     0,     0,     0,     0,  -260,  -260,
    -260,  -260,  -260,     0,     0,     0,    69,     0,     0,     0,
       0,    70,    71,    72,    73,    74,    75,    76,  -260,  -260,
    -260,     0,     0,     0,     0,    77,    78,    79,     0,    80,
      81,    82,    83,    84,  -260,  -260,     0,  -260,  -260,    85,
      86,    87,    88,    89,    90,    91,    92,    93,    94,    95,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    96,    61,  -260,  -260,    62,    97,  -260,     0,    63,
      64,    65,    98,    99,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    66,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,     0,     0,     0,    67,    68,     0,   722,     0,
       0,  -260,  -260,  -260,  -260,  -260,     0,     0,     0,    69,
       0,     0,     0,     0,    70,    71,    72,    73,    74,    75,
      76,  -260,  -260,  -260,     0,     0,     0,     0,    77,    78,
      79,     0,    80,    81,    82,    83,    84,  -260,  -260,     0,
    -260,  -260,    85,    86,    87,    88,    89,    90,    91,    92,
      93,    94,    95,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    96,    61,  -260,  -260,    62,    97,
    -260,     0,    63,    64,    65,    98,    99,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    66,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,     0,     0,     0,    67,    68,
       0,   817,     0,     0,  -260,  -260,  -260,  -260,  -260,     0,
       0,     0,    69,     0,     0,     0,     0,    70,    71,    72,
      73,    74,    75,    76,  -260,  -260,  -260,     0,     0,     0,
       0,    77,    78,    79,     0,    80,    81,    82,    83,    84,
    -260,  -260,     0,  -260,  -260,    85,    86,    87,    88,    89,
      90,    91,    92,    93,    94,    95,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    96,    61,  -260,
    -260,    62,    97,  -260,     0,    63,    64,    65,    98,    99,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      66,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,     0,     0,
       0,    67,    68,     0,   828,     0,     0,  -260,  -260,  -260,
    -260,  -260,     0,     0,     0,    69,     0,     0,     0,     0,
      70,    71,    72,    73,    74,    75,    76,  -260,  -260,  -260,
       0,     0,     0,     0,    77,    78,    79,     0,    80,    81,
      82,    83,    84,  -260,  -260,     0,  -260,  -260,    85,    86,
      87,    88,    89,    90,    91,    92,    93,    94,    95,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      96,    61,  -260,  -260,    62,    97,  -260,     0,    63,    64,
      65,    98,    99,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    66,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,  -260,
    -260,     0,     0,     0,    67,    68,     0,     0,     0,     0,
    -260,  -260,  -260,  -260,  -260,     0,     0,     0,    69,     0,
       0,     0,   976,    70,    71,    72,    73,    74,    75,    76,
    -260,  -260,  -260,     0,     0,     0,     0,    77,    78,    79,
       0,    80,    81,    82,    83,    84,  -260,  -260,     0,  -260,
    -260,    85,    86,    87,    88,    89,    90,    91,    92,    93,
      94,    95,     0,     6,     0,     7,     0,     0,     0,     0,
       0,     0,     0,    96,     0,  -260,     0,     0,    97,  -260,
       0,     0,     0,     0,    98,    99,     8,     9,    10,    11,
      12,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    23,    24,     0,     0,     0,     0,     0,     0,     0,
       0,    25,    26,    27,    28,    29,    30,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    31,    32,    33,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    34,     0,
       0,    35,    36,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    56,     0,     7,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    37,     0,     0,
       0,    38,     0,     0,     0,     0,    39,     8,     9,    10,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    23,    24,     0,     0,     0,     0,     0,     0,
       0,     0,    25,    26,    27,    28,    29,    30,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,     0,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     7,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     0,     0,     0,     0,    39,     8,     9,
      10,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    23,    24,     0,     0,     0,     0,     0,
       0,     0,     0,    25,    26,    27,    28,    29,    30,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    31,    32,    33,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
      34,     0,     0,    35,    36,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,    37,
     371,     0,     0,    38,     0,     0,     0,     0,    39,   534,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,     0,     0,
       0,     0,     0,     0,     0,     0,    25,    26,    27,    28,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,     0,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     7,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     0,     0,     0,
       0,    39,     8,     9,    10,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,    23,    24,     0,
       0,     0,     0,     0,     0,     0,     0,    25,    26,    27,
      28,    29,    30,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    31,    32,
      33,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,    34,     0,     0,    35,    36,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    37,     0,     0,   400,    38,     0,     0,
       0,     0,    39,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
       0,     0,     0,     0,     0,     0,     0,     0,    25,    26,
      27,    28,    29,    30,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    62,    31,
      32,    33,    63,    64,    65,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,    66,    35,    36,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,   891,    68,
       0,  -197,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,     0,    39,     0,     0,     0,    70,    71,    72,
     892,    74,    75,    76,     0,     0,     0,   893,   894,   895,
       0,    77,    78,    79,     0,    80,    81,    82,    83,    84,
       0,     0,     0,     0,     0,    85,     0,     0,     0,    89,
      90,    91,    92,    93,    94,    95,   189,     0,     7,     0,
       0,     0,     0,     0,     0,     0,     0,    96,     0,     0,
       0,     0,    97,     0,     0,     0,     0,     0,  1010,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    26,    27,    28,    29,    30,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     7,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    34,     0,     0,    35,    36,     0,     0,     0,     8,
       9,    10,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    23,    24,     0,     0,     0,     0,
      37,     0,     0,     0,    38,    26,    27,    28,    29,    30,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    31,    32,    33,     0,     0,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    34,   973,     0,    35,    36,     0,     0,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,     0,     0,
      37,     0,     0,     0,    38,   974,    25,    26,    27,    28,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,     0,    35,    36,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,   212,     0,
       0,     0,    37,     0,     0,     0,    38,    26,    27,    28,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,     0,    35,    36,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,     0,     0,
       0,     0,    37,     0,     0,     0,    38,    26,    27,    28,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,   241,     0,    35,    36,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    23,    24,     0,     0,
       0,     0,    37,     0,     0,     0,    38,    26,    27,    28,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       7,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,     0,    35,    36,     0,     0,
       0,     8,     9,    10,    11,    12,    13,    14,    15,   222,
      17,   223,    19,   224,    21,    22,    23,    24,     0,     0,
       0,     0,    37,     0,     0,     0,    38,   225,     0,     0,
      29,    30,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,    31,    32,    33,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    34,     0,     0,    35,    36,     0,     0,
       0,     0,     0,     0,     0,     0,     7,     0,     0,   226,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,    37,     0,     0,     0,    38,     8,     9,    10,
      11,    12,    13,    14,    15,   222,    17,   223,    19,   224,
      21,    22,    23,    24,     0,     0,     0,     0,     0,     0,
       0,     0,     0,   225,     0,     0,    29,    30,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,    31,    32,    33,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    34,
       0,     0,    35,    36,     0,     0,     0,     0,     0,     0,
       0,     0,     7,     0,     0,   972,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,    37,     0,
       0,     0,    38,     8,     9,    10,    11,    12,    13,    14,
      15,   222,    17,   223,    19,   224,    21,    22,    23,    24,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   225,
       0,     0,    29,    30,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,     7,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,     0,    35,    36,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
       0,     0,     0,     0,    37,     0,     0,     0,    38,     0,
       0,     0,    29,    30,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
      32,    33,     7,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,     0,    35,    36,
       0,     0,     0,     8,     9,    10,    11,    12,    13,    14,
      15,   222,    17,   223,    19,   224,    21,    22,    23,    24,
       0,     0,     0,     0,    37,     0,     0,     0,    38,   225,
       0,     0,    62,     0,     0,     0,    63,    64,    65,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,    31,
       0,    66,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    34,     0,     0,    35,    36,
       0,     0,   891,    68,     0,  -200,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,    70,    71,    72,    37,    74,    75,    76,    38,     0,
       0,   893,   894,   895,     0,    77,    78,    79,     0,    80,
      81,    82,    83,    84,     0,     0,    62,     0,     0,    85,
      63,    64,    65,    89,    90,    91,    92,    93,    94,    95,
       0,     0,     0,     0,     0,    66,     0,     0,     0,     0,
       0,    96,     0,     0,     0,     0,    97,     0,     0,     0,
       0,     0,     0,     0,     0,     0,   891,    68,     0,  -198,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,    70,    71,    72,     0,    74,
      75,    76,     0,     0,     0,   893,   894,   895,     0,    77,
      78,    79,     0,    80,    81,    82,    83,    84,     0,     0,
       0,     0,     0,    85,     0,     0,     0,    89,    90,    91,
      92,    93,    94,    95,     0,     0,   501,     0,     0,     0,
       0,     0,     0,   448,     0,    96,   184,   253,     0,     0,
      97,   254,   255,   256,   257,   258,   259,   260,   261,   262,
     263,   264,   265,     0,     0,     0,     0,     0,     0,   681,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,   449,   463,   464,   465,   466,   467,     0,   468,   450,
       0,     0,     0,     0,     0,     0,   267,   268,     0,     0,
       0,     0,   683,   469,   470,   471,   472,   473,   474,   475,
     476,   477,   478,   479,   480,   463,   464,   465,   466,   467,
       0,   468,     0,     0,     0,     0,     0,     0,   269,     0,
       0,     0,     0,     0,     0,   807,   469,   470,   471,   472,
     473,   474,   475,   476,   477,   478,   479,   480,   463,   464,
     465,   466,   467,     0,   468,     0,     0,     0,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,   469,
     470,   471,   472,   473,   474,   475,   476,   477,   478,   479,
     480,   463,   464,   465,   466,   467,     0,   468,     0,     0,
       0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
       0,     0,   469,   470,   471,   472,   473,   474,   475,   476,
     477,   478,   479,   480
};

static const yytype_int16 yycheck[] =
{
       1,     2,    32,    33,   156,    46,    59,   146,   185,    45,
       5,   226,    70,    97,    45,     5,   147,   557,    45,     1,
       2,     5,   574,    97,   595,   590,     5,   362,    91,     5,
     209,     5,   379,    91,    92,    38,   175,   176,    39,   541,
      45,    43,     5,   550,   541,     5,     5,     5,   550,    97,
     717,   820,   716,   386,   251,   234,     5,     5,    59,   981,
       6,   896,   682,   137,     3,     3,    41,    55,   183,    46,
      43,     3,    55,   188,    55,    41,     5,    45,    42,   137,
       4,   196,     6,     5,  1118,    63,     0,     3,    43,    42,
       3,    97,   962,    44,   428,   965,    41,   159,   160,   433,
      43,   185,     5,   218,     5,     5,   102,   169,     5,     5,
       5,   185,   153,  1147,   102,     5,     5,    48,     6,    49,
     161,    46,   237,    89,    90,    76,   991,   154,    41,   159,
     160,   137,  1043,   116,   111,   116,    49,   185,    50,    51,
      52,    43,  1064,   340,   197,   198,   147,   125,   116,     3,
      89,    90,   116,   154,   190,   158,   131,    89,    90,   212,
     165,   136,   167,   116,   102,   147,     3,    55,   221,   124,
     125,  1093,   118,    89,    90,  1010,    89,    90,   214,   185,
     111,   124,   125,   214,  1106,   124,   111,   214,  1053,    44,
    1055,     6,  1103,   540,     3,     0,   197,   198,   171,   819,
     771,   103,   115,   119,    41,   142,   119,   234,    55,  1120,
     362,   212,    49,   560,  1125,   835,   128,     0,    72,   131,
     221,     3,   190,    48,     4,   226,     6,   140,    55,   562,
     292,   293,    41,   120,   296,    89,    90,     4,    92,    44,
      41,    50,    51,    52,   226,   281,    61,   102,    41,    76,
     281,  1020,    89,    90,   281,   102,   292,   293,    42,    41,
     296,   115,   292,   293,   291,   119,    46,   602,   330,   331,
       3,   324,     1,   241,   327,   243,   281,    59,   115,    46,
      89,    90,   119,   310,    44,     3,   111,   954,   952,   342,
     291,   332,     0,    43,    55,    55,   337,   862,  1067,    41,
     330,   331,     6,   140,    46,    55,   115,    89,    90,   310,
     119,   818,    41,   281,   821,    76,   818,   290,     4,   821,
     378,   818,     3,   324,     3,   102,   327,    73,   386,   392,
     461,   140,   359,   115,   392,   128,     3,   119,   131,   116,
     117,   342,    46,   136,   128,     6,   128,   131,   321,   131,
      53,     1,   136,   103,   136,   360,    89,    90,   140,   574,
      46,   576,    41,   109,   117,   142,     6,     7,    71,   422,
      49,    89,    90,    41,    41,     6,   412,   413,   414,   432,
      59,    41,   115,    44,     3,   719,   119,   428,    41,   142,
     569,   418,   433,    43,    44,   128,    46,   115,   131,    59,
     405,   119,   749,   136,     4,   432,     6,     3,    89,    90,
      89,    90,     3,   978,     4,    46,     6,   751,   136,   446,
     972,   422,    89,    90,   486,   487,   488,    46,   543,     3,
      44,   432,    46,   495,   496,   550,   115,   771,   119,   442,
     119,   503,  1136,    44,    44,    46,    46,    41,   115,   502,
     602,    44,   119,    46,   507,    41,   486,   487,   499,   117,
     461,   140,    76,  1157,   526,   495,   496,    41,   499,   136,
      89,    90,   499,   140,     3,    76,    50,    51,    52,   461,
      76,   534,    41,   536,   142,    59,    41,    41,   102,    90,
       6,   825,   545,    89,    90,    49,   115,  1037,    89,    90,
     119,   502,    53,    54,   562,    59,   507,    41,    41,    41,
      42,    41,   565,    46,   114,    89,    90,     3,    41,   115,
      71,   557,    41,   119,   115,   578,   557,    59,   119,    59,
     557,   499,    41,   534,    41,   536,    59,    41,   873,   580,
      59,   115,     6,     7,   545,   119,  1117,    41,    42,   580,
      59,   552,   525,   580,   128,    59,    41,   131,   531,     3,
      89,    90,   136,   558,   565,    59,   140,    41,   558,   570,
     552,   561,    41,   574,   558,   576,    55,   578,     3,   558,
     128,   622,   558,   131,   558,   553,   763,    42,   570,   118,
     119,    44,   574,    46,   576,   558,     3,    41,   558,   558,
     558,   603,    55,    89,    90,    49,   668,    53,    54,   558,
     558,    55,   580,   581,   128,    59,   116,   131,    41,    41,
     772,    44,    49,   664,   597,    71,    72,    42,    43,   558,
      55,     6,   118,   119,    41,   676,   558,    59,    46,   680,
     671,   682,    49,    46,   671,    89,    90,   700,   121,   122,
     123,    44,    59,    46,    44,   558,    46,   558,   558,    41,
      42,   558,   558,   558,    89,    90,  1000,   725,   558,   558,
      44,   115,    43,     3,   727,   119,   116,    59,   719,   763,
      89,    90,    89,    90,   128,   104,   105,   131,    41,   763,
     115,    41,   136,  1027,   119,    43,   140,   103,   671,   700,
     266,   267,   755,   671,    41,   116,   701,   822,   115,   840,
     751,   701,   119,    41,    42,   763,    42,   701,  1052,   750,
      42,   873,   701,   750,    59,   701,   727,   701,    41,   724,
     771,    59,   116,   140,   724,     0,  1070,    43,   701,    42,
     724,   701,   701,   701,    55,   724,    40,  1082,   724,   717,
     724,    45,   701,   701,   755,  1089,   746,   972,    52,    89,
      90,   724,   746,   847,   724,   724,   724,   746,    42,   832,
     746,    43,   701,   847,   832,   724,   724,   750,   819,   701,
      42,    42,   750,  1117,   825,   115,    55,   789,    43,   119,
     843,    85,    86,    43,   835,   724,    42,   855,   701,   847,
     701,   701,   724,    97,   701,   701,   701,   770,     4,    44,
       6,   701,   701,    44,    41,    42,   789,  1152,    42,   872,
      42,   724,   116,   724,   724,    42,    42,   724,   724,   724,
      42,    23,    59,   103,   724,   724,   102,     3,   844,   840,
       6,   847,   843,    43,   996,   116,    41,    80,    44,   855,
      46,    42,   116,    45,   928,    88,    89,    90,   840,    55,
     154,   829,   857,    44,    46,   159,   160,   857,   162,    76,
     928,   872,    42,   857,     3,   169,     3,  1016,   857,   102,
     928,   857,    41,   857,     3,    77,    78,    79,     3,    42,
      82,   185,    84,    85,   857,   116,   190,   857,   857,   857,
      50,    51,    52,   116,   867,    42,   200,   201,   857,   857,
      49,    41,   880,   971,    46,    46,   974,   136,   137,   138,
     214,    23,   928,    89,    90,    41,   118,    44,   857,   982,
    1082,   225,    44,   227,   228,   857,    42,   231,   104,   105,
     234,   235,   236,    45,   949,   239,    44,   241,   242,   243,
     244,    73,    74,    75,   857,    47,   857,   857,    44,  1000,
     857,   857,   857,    91,    42,   970,    41,   857,   857,    90,
      42,   972,  1002,    78,    41,    77,    78,    79,    89,    76,
      82,   982,    84,    85,    41,   953,  1027,   281,  1041,    41,
     972,   134,   135,   136,   137,   138,    41,   291,   292,   293,
    1152,  1037,   296,    42,    42,   973,  1037,   975,    42,    42,
    1037,  1052,    49,  1040,  1041,    55,   310,   311,   312,    50,
      51,    52,   990,   317,   987,    42,    55,    43,   991,  1070,
    1083,  1036,    44,    42,   147,   329,   330,   331,   142,   102,
    1041,  1009,    42,   337,   157,    47,    41,   103,  1089,    80,
      70,    42,    44,   102,  1107,   349,   350,    88,    89,    90,
    1113,  1114,  1115,    44,    63,   359,    86,  1140,    43,     3,
    1143,  1144,  1145,   367,  1104,    46,  1117,  1135,    42,    42,
    1133,    42,  1083,  1156,    42,    42,   380,    42,  1129,    42,
    1053,    42,  1055,    42,    44,    42,    55,   128,    44,  1140,
     131,    68,  1143,  1144,  1145,    42,  1107,    41,    47,    44,
      55,    76,  1113,  1114,  1115,  1156,    46,   125,   412,   413,
     414,    47,    76,    90,   418,   419,   420,    47,    95,   423,
     424,   425,  1133,   427,   247,    76,    76,    44,   432,    44,
      42,  1109,    55,   103,     3,   132,   133,   134,   135,   136,
     137,   138,    43,   266,    42,    89,    90,   270,   271,   272,
     273,   274,   275,   183,    44,    76,    76,   187,   188,    44,
      76,    44,    76,    76,   194,   195,   196,    44,   103,    42,
      44,   115,    41,    43,    43,   119,   206,     3,    49,   209,
      49,    41,    47,    44,   488,    44,    55,    41,   218,    41,
      59,    42,   136,     3,    44,   499,   140,    42,    47,   503,
       3,    41,   325,     6,   234,   328,   183,   237,    49,    42,
     187,   188,   242,   517,    42,    41,    46,   521,   248,   196,
      89,    90,   526,   527,    42,   529,    42,    42,   746,  1109,
      44,    41,   209,   576,   103,   918,   138,   746,    41,    49,
     746,   218,   219,    39,   597,   840,   115,   461,    50,   553,
     119,   867,   987,   557,   986,   612,   233,   234,   884,   128,
     237,  1003,   131,    89,    90,   680,  1117,   136,   245,   106,
     107,   140,  1099,   110,   726,    -1,   580,   581,   582,    89,
      90,   176,   586,   587,   588,    -1,    89,    90,    -1,   115,
      -1,    -1,    -1,   119,   160,   132,   133,   134,   135,   136,
     137,   138,    -1,   169,    -1,   115,    -1,    -1,    -1,   119,
      -1,    -1,   115,    -1,   140,    -1,   119,    -1,   128,    -1,
      -1,   131,    -1,     3,    -1,   128,   136,    -1,   131,    -1,
     140,    -1,    -1,   136,    -1,    -1,    -1,   140,   461,    -1,
     463,   464,   465,   466,   467,   468,   469,   470,   471,   472,
     473,   474,   475,   476,   477,   478,   479,   480,    -1,    -1,
      -1,    41,    -1,    -1,    -1,    -1,    -1,   671,    -1,     3,
     236,    -1,   676,   239,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   686,    -1,   688,   508,    -1,    -1,   692,   693,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    -1,    -1,    89,
      90,    -1,    -1,   717,     6,    -1,    50,    51,    52,    53,
      54,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,     3,    -1,    -1,   115,    70,    71,    72,   119,
      -1,   745,    -1,    -1,    -1,   311,   750,    -1,    -1,   753,
      -1,   317,    86,    87,    -1,    89,    90,    -1,    -1,   763,
     140,    -1,    -1,   329,   330,   331,    -1,    -1,    -1,    -1,
      41,   337,    -1,    -1,    -1,    -1,    -1,    -1,    49,    -1,
      -1,   115,    -1,    -1,     3,   119,   120,    -1,    59,    -1,
      -1,    -1,    -1,    -1,    -1,   618,   619,   620,   621,   622,
      -1,   624,    -1,     3,    -1,    -1,   140,   811,   812,    -1,
      -1,    -1,    -1,   543,    -1,    -1,    -1,    -1,    89,    90,
     550,    -1,    41,    -1,    -1,   829,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    -1,    -1,    -1,   567,    -1,   569,
       3,    41,    -1,   847,   115,    -1,    -1,    -1,   119,    49,
      -1,    -1,    -1,   419,   420,    -1,    -1,   423,   424,   425,
     537,   427,    -1,    -1,   541,    -1,   543,     3,    -1,   140,
      89,    90,   549,   550,    -1,    -1,   880,    -1,    41,    -1,
      -1,    -1,    -1,    -1,   888,    -1,    49,    -1,    -1,    89,
      90,    -1,   569,    -1,   571,   625,   115,    -1,     3,     4,
     119,     6,    -1,    -1,   581,    41,    -1,    -1,    -1,   128,
      -1,    -1,   131,    49,    -1,   115,    -1,    -1,    -1,   119,
      -1,   140,    -1,    59,   928,    -1,    89,    90,   128,    -1,
      -1,   131,     3,   756,    -1,    -1,    41,   503,    -1,    44,
     140,    46,    -1,     3,    -1,    -1,    -1,    -1,    -1,   953,
     773,   517,   115,    89,    90,   521,   119,    -1,    -1,    -1,
     526,   527,    -1,   529,   787,   788,   970,   790,    -1,   973,
      41,   975,    -1,   796,    -1,    -1,    -1,   140,    49,   115,
      -1,    41,    -1,   119,    89,    90,   990,    -1,    59,    49,
      -1,    -1,    -1,   997,    -1,   725,    -1,    -1,    -1,    59,
      -1,    -1,    -1,     3,   140,  1009,    -1,    -1,    -1,   114,
     115,    -1,    -1,    -1,   119,    -1,   582,   840,    89,    90,
     586,   587,   588,   128,    -1,    -1,   131,    -1,    -1,    89,
      90,   136,    -1,  1037,    -1,   140,    -1,  1041,    -1,    -1,
     717,    41,    -1,    -1,   115,    -1,    -1,    -1,   119,   726,
      -1,    -1,    -1,    -1,    -1,   115,    -1,   128,    -1,   119,
     131,    -1,  1066,    -1,    -1,   136,    -1,    -1,   128,   140,
      -1,   131,    -1,    -1,   110,    -1,   136,    -1,    -1,    -1,
     140,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    89,
      90,    -1,   822,    -1,    -1,  1099,   132,   133,   134,   135,
     136,   137,   138,    -1,    -1,  1109,   836,   837,   838,    -1,
     676,    -1,   935,   936,    -1,   115,    -1,    -1,    -1,   119,
     686,    -1,   688,    -1,    -1,    -1,   692,   693,   128,    -1,
      -1,   131,    -1,    -1,    -1,    -1,   136,    -1,    -1,   869,
     140,   818,    -1,    -1,   821,   822,    24,    25,    26,    27,
      28,    29,    30,    31,    -1,    33,    -1,    35,    -1,    37,
      38,    39,    40,    -1,    -1,     1,    -1,     3,    -1,   846,
       6,     7,    -1,     3,    -1,    11,    12,    13,    14,    15,
      16,    17,    18,    19,    20,    21,    22,   753,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,
      -1,    41,    -1,    -1,    50,    51,    52,    53,    54,    49,
      56,    57,    -1,    59,    -1,    -1,    -1,  1050,    -1,    59,
      -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,   811,   812,    -1,    -1,  1072,
      86,    -1,    88,    89,    90,    -1,   986,    -1,    -1,    89,
      90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   104,   105,
      -1,    -1,    -1,    -1,    -1,     3,    -1,   954,     6,   115,
      -1,    -1,    -1,   119,    -1,   115,    -1,    -1,    -1,   119,
      -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,
     136,     1,    -1,     3,   140,   141,     6,     7,    -1,     3,
     140,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    41,    -1,    -1,    -1,    -1,    46,    41,    -1,    -1,
      50,    51,    52,    53,    54,    49,    56,    57,    -1,    -1,
      -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      70,    71,    72,    -1,    -1,    -1,   104,   105,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    86,   115,    88,    89,
      90,   119,    -1,    -1,    -1,    89,    90,    -1,    -1,    -1,
     128,    -1,    -1,   131,   104,   105,    -1,    -1,   136,    -1,
      -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,
      -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,
      -1,   131,    -1,    -1,   134,   135,   136,     1,    -1,     3,
     140,   141,     6,     7,    -1,     3,   140,    11,    12,    13,
      14,    15,    16,    17,    18,    19,    20,    21,    22,    -1,
      24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
      34,    35,    36,    37,    38,    39,    40,    41,    -1,    -1,
      -1,    -1,    -1,    41,    -1,    -1,    50,    51,    52,    53,
      54,    49,    56,    57,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   106,   107,   108,
     109,   110,    86,    -1,    88,    89,    90,    -1,    -1,    -1,
      -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     104,   105,   131,   132,   133,   134,   135,   136,   137,   138,
      -1,   115,    -1,    -1,    -1,   119,    -1,   115,    -1,    -1,
      -1,   119,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,
     134,   135,   136,     1,    -1,     3,   140,   141,     6,     7,
      -1,    42,   140,    11,    12,    13,    14,    15,    16,    17,
      18,    19,    20,    21,    22,    -1,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    50,    51,    52,    53,    54,    -1,    56,    57,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    70,    71,    72,   106,   107,   108,   109,   110,
      -1,   112,   106,   107,   108,   109,   110,    -1,    86,    -1,
      88,    89,    90,    -1,    -1,    -1,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,   137,   138,   132,   133,
     134,   135,   136,   137,   138,    -1,    -1,   115,    -1,    -1,
      -1,   119,     1,    -1,     3,     4,    -1,    -1,    -1,     8,
       9,    10,    -1,   131,    -1,    -1,   134,   135,   136,    -1,
      -1,    -1,   140,   141,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    44,    45,    -1,    47,    -1,
      -1,    50,    51,    52,    53,    54,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    67,    68,
      69,    70,    71,    72,    73,    74,    75,    -1,    77,    78,
      79,    -1,    81,    82,    83,    84,    85,    86,    87,    -1,
      89,    90,    91,     3,    -1,    -1,    95,    96,    97,    98,
      99,   100,   101,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,    -1,   115,    -1,    -1,   118,
     119,   120,    -1,    -1,    -1,   124,    -1,    -1,    -1,    -1,
      -1,    41,    -1,    -1,     3,    -1,    -1,     6,     7,    49,
      -1,   140,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    46,    -1,    89,
      90,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,    -1,   115,    -1,    -1,    -1,   119,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     140,    -1,    -1,    -1,    -1,   104,   105,    -1,    -1,    -1,
      -1,     3,    -1,    -1,     6,    -1,   115,    -1,    -1,    -1,
     119,    13,    14,    15,    16,    17,    18,    19,    20,    21,
      22,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    76,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    89,    90,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,   104,   105,    -1,   106,   107,   108,   109,   110,
      -1,   112,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,   137,   138,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,   124,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   106,   107,   108,   109,   110,    -1,   104,   105,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    42,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    42,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,   106,   107,   108,   109,   110,    -1,   112,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    89,    90,
      -1,    -1,    -1,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    42,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    42,    -1,    -1,
      -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
      -1,    56,    57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,   106,   107,
     108,   109,   110,    -1,   112,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    89,    90,    -1,    -1,    -1,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      42,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    60,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,   106,   107,   108,   109,   110,    -1,
     112,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,   127,   128,   129,   130,   131,
     132,   133,   134,   135,   136,   137,   138,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    60,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
     106,   107,   108,   109,   110,    -1,   112,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,   127,   128,   129,   130,   131,   132,   133,   134,   135,
     136,   137,   138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    60,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,   106,   107,   108,   109,
     110,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,   127,   128,   129,
     130,   131,   132,   133,   134,   135,   136,   137,   138,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,   106,   107,   108,   109,   110,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    89,    90,
      -1,    -1,    -1,    -1,    -1,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
      -1,    56,    57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,   106,   107,
     108,   109,   110,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    89,    90,    -1,    -1,    -1,    -1,
      -1,    -1,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    89,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
      -1,    56,    57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    89,    90,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    89,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
      -1,    56,    57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    89,    90,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    88,    89,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     131,    -1,    -1,   134,   135,   136,    -1,    -1,     3,   140,
     141,     6,     7,    -1,    -1,    -1,    11,    12,    13,    14,
      15,    16,    17,    18,    19,    20,    21,    22,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    50,    51,    52,    53,    54,
      -1,    56,    57,    -1,    -1,    60,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    88,    89,    90,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,    -1,   134,
     135,   136,    -1,    -1,     3,   140,   141,     6,     7,    -1,
      -1,    -1,    11,    12,    13,    14,    15,    16,    17,    18,
      19,    20,    21,    22,    -1,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      49,    50,    51,    52,    53,    54,    -1,    56,    57,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    70,    71,    72,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,    88,
      89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,
     119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   131,    -1,    -1,   134,   135,   136,    -1,    -1,
       3,   140,   141,     6,     7,    -1,    -1,    -1,    11,    12,
      13,    14,    15,    16,    17,    18,    19,    20,    21,    22,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    54,    -1,    56,    57,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    88,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   131,    -1,
      -1,   134,   135,   136,    -1,    -1,     3,   140,   141,     6,
       7,    -1,    -1,    -1,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    -1,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    50,    51,    52,    53,    54,    -1,    56,
      57,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    88,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   131,    -1,    -1,   134,   135,   136,
      -1,    -1,     3,   140,   141,     6,     7,    -1,    -1,    -1,
      11,    12,    13,    14,    15,    16,    17,    18,    19,    20,
      21,    22,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      41,    -1,    -1,    -1,     3,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    56,    57,    -1,    -1,     3,
      -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,    70,
      71,    72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,     3,    41,    -1,    -1,    86,    -1,    88,    89,    90,
      49,    -1,    -1,    -1,    -1,    -1,    -1,    41,    -1,    -1,
      59,    -1,    -1,     3,    41,    49,    -1,    44,    -1,    -1,
      -1,    -1,    -1,    -1,   115,    59,    -1,    -1,   119,    41,
      -1,     3,    44,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      89,    90,    -1,   134,   135,     3,    -1,    -1,    -1,   140,
     141,    41,    -1,    -1,    44,    89,    90,    -1,    -1,    -1,
      -1,    -1,    89,    90,    -1,    -1,   115,    -1,    -1,    41,
     119,    -1,    -1,    -1,    -1,    -1,     3,    89,    90,   128,
      -1,   115,   131,    41,    -1,   119,    -1,   136,   115,    -1,
      -1,   140,   119,    -1,   128,    -1,    -1,   131,     3,    89,
      90,   128,    -1,   115,   131,    -1,   140,   119,    -1,   136,
      -1,    -1,    -1,   140,    41,    -1,   128,    89,    90,   131,
      -1,    -1,    49,    -1,   136,   115,    -1,    -1,   140,   119,
      -1,    89,    90,    -1,    -1,    -1,    41,    -1,   128,    -1,
      -1,   131,    -1,   115,    -1,    -1,   136,   119,    -1,    -1,
     140,    -1,    -1,    -1,    -1,    -1,   128,   115,    -1,   131,
      -1,   119,    89,    90,   136,    -1,    -1,    -1,   140,    -1,
     128,    -1,    -1,   131,    -1,    -1,    -1,    -1,   136,    -1,
      41,    -1,   140,    -1,    89,    90,    -1,    -1,   115,    50,
      51,    52,   119,    -1,    55,    -1,    -1,    -1,    -1,    -1,
      -1,   128,    -1,    -1,   131,    -1,    -1,    -1,    -1,    -1,
     115,    -1,    -1,   140,   119,     3,    -1,    -1,    -1,    80,
      -1,    -1,    -1,   128,    42,    -1,   131,    88,    89,    90,
      -1,   136,    -1,    -1,    -1,   140,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    41,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    49,    50,    51,    52,    53,    54,   128,    -1,    -1,
     131,    59,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    70,    71,    72,   103,    -1,    -1,   106,   107,
     108,   109,   110,    -1,   112,    -1,    -1,    -1,    86,    -1,
      -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    -1,    -1,    -1,    -1,    -1,    -1,   115,     3,    -1,
      -1,   119,    -1,    -1,    -1,    -1,   124,    44,    -1,    -1,
     128,    -1,    -1,   131,    -1,    -1,    -1,    -1,   136,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    41,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    49,    50,    51,    52,    53,    54,
      -1,    -1,    -1,    -1,    59,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,   106,
     107,   108,   109,   110,    -1,   112,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    -1,    89,    90,    -1,    -1,    -1,    -1,
     127,   128,   129,   130,   131,   132,   133,   134,   135,   136,
     137,   138,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     115,     3,    -1,    -1,   119,    -1,    -1,     3,    -1,   124,
      -1,    -1,    -1,   128,    -1,    -1,   131,    -1,    -1,    -1,
      -1,   136,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    41,    -1,    49,    50,    51,
      52,    53,    54,    49,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    59,    -1,    -1,    -1,    -1,    70,    71,
      72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,
      -1,    -1,    -1,    89,    90,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,   115,
      -1,    -1,   124,   119,    -1,    -1,   128,    -1,    -1,   131,
      -1,    -1,   128,    -1,   136,   131,    -1,    -1,     0,     1,
     136,     3,     4,    -1,    -1,    -1,     8,     9,    10,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    23,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    44,    45,    -1,    -1,    -1,    -1,    50,    51,
      52,    53,    54,    -1,    -1,    -1,    58,    -1,    -1,    -1,
      -1,    63,    64,    65,    66,    67,    68,    69,    70,    71,
      72,    -1,    -1,    -1,    -1,    77,    78,    79,    -1,    81,
      82,    83,    84,    85,    86,    87,    -1,    89,    90,    91,
      92,    93,    94,    95,    96,    97,    98,    99,   100,   101,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,   113,     1,   115,     3,     4,   118,   119,    -1,     8,
       9,    10,   124,   125,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    23,    24,    25,    26,    27,    28,
      29,    30,    31,    32,    33,    34,    35,    36,    37,    38,
      39,    40,    -1,    -1,    -1,    44,    45,    -1,    47,    -1,
      -1,    50,    51,    52,    53,    54,    -1,    -1,    -1,    58,
      -1,    -1,    -1,    -1,    63,    64,    65,    66,    67,    68,
      69,    70,    71,    72,    -1,    -1,    -1,    -1,    77,    78,
      79,    -1,    81,    82,    83,    84,    85,    86,    87,    -1,
      89,    90,    91,    92,    93,    94,    95,    96,    97,    98,
      99,   100,   101,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,   113,     1,   115,     3,     4,   118,
     119,    -1,     8,     9,    10,   124,   125,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    23,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    44,    45,
      -1,    47,    -1,    -1,    50,    51,    52,    53,    54,    -1,
      -1,    -1,    58,    -1,    -1,    -1,    -1,    63,    64,    65,
      66,    67,    68,    69,    70,    71,    72,    -1,    -1,    -1,
      -1,    77,    78,    79,    -1,    81,    82,    83,    84,    85,
      86,    87,    -1,    89,    90,    91,    92,    93,    94,    95,
      96,    97,    98,    99,   100,   101,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,     1,   115,
       3,     4,   118,   119,    -1,     8,     9,    10,   124,   125,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    44,    45,    -1,    47,    -1,    -1,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    58,    -1,    -1,    -1,    -1,
      63,    64,    65,    66,    67,    68,    69,    70,    71,    72,
      -1,    -1,    -1,    -1,    77,    78,    79,    -1,    81,    82,
      83,    84,    85,    86,    87,    -1,    89,    90,    91,    92,
      93,    94,    95,    96,    97,    98,    99,   100,   101,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
     113,     1,   115,     3,     4,   118,   119,    -1,     8,     9,
      10,   124,   125,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    23,    24,    25,    26,    27,    28,    29,
      30,    31,    32,    33,    34,    35,    36,    37,    38,    39,
      40,    -1,    -1,    -1,    44,    45,    -1,    -1,    -1,    -1,
      50,    51,    52,    53,    54,    -1,    -1,    -1,    58,    -1,
      -1,    -1,    62,    63,    64,    65,    66,    67,    68,    69,
      70,    71,    72,    -1,    -1,    -1,    -1,    77,    78,    79,
      -1,    81,    82,    83,    84,    85,    86,    87,    -1,    89,
      90,    91,    92,    93,    94,    95,    96,    97,    98,    99,
     100,   101,    -1,     1,    -1,     3,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   113,    -1,   115,    -1,    -1,   118,   119,
      -1,    -1,    -1,    -1,   124,   125,    24,    25,    26,    27,
      28,    29,    30,    31,    32,    33,    34,    35,    36,    37,
      38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    49,    50,    51,    52,    53,    54,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,    -1,
      -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,     1,    -1,     3,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,    -1,
      -1,   119,    -1,    -1,    -1,    -1,   124,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    49,    50,    51,    52,    53,    54,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    -1,    -1,    -1,    -1,   124,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    49,    50,    51,    52,    53,    54,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      86,    -1,    -1,    89,    90,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,
      13,    -1,    -1,   119,    -1,    -1,    -1,    -1,   124,   125,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    -1,    -1,    -1,
      -1,   124,    24,    25,    26,    27,    28,    29,    30,    31,
      32,    33,    34,    35,    36,    37,    38,    39,    40,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,    51,
      52,    53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,
      72,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,   115,    -1,    -1,   118,   119,    -1,    -1,
      -1,    -1,   124,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    49,    50,
      51,    52,    53,    54,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,     4,    70,
      71,    72,     8,     9,    10,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    23,    89,    90,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    44,    45,
      -1,    47,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    -1,   124,    -1,    -1,    -1,    63,    64,    65,
      66,    67,    68,    69,    -1,    -1,    -1,    73,    74,    75,
      -1,    77,    78,    79,    -1,    81,    82,    83,    84,    85,
      -1,    -1,    -1,    -1,    -1,    91,    -1,    -1,    -1,    95,
      96,    97,    98,    99,   100,   101,     1,    -1,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,   113,    -1,    -1,
      -1,    -1,   118,    -1,    -1,    -1,    -1,    -1,   124,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    50,    51,    52,    53,    54,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,     3,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    -1,    -1,    89,    90,    -1,    -1,    -1,    24,
      25,    26,    27,    28,    29,    30,    31,    32,    33,    34,
      35,    36,    37,    38,    39,    40,    -1,    -1,    -1,    -1,
     115,    -1,    -1,    -1,   119,    50,    51,    52,    53,    54,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    70,    71,    72,    -1,    -1,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    86,    87,    -1,    89,    90,    -1,    -1,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
     115,    -1,    -1,    -1,   119,   120,    49,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    41,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    87,    -1,    89,    90,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    50,    51,    52,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
       3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,    -1,
      -1,    24,    25,    26,    27,    28,    29,    30,    31,    32,
      33,    34,    35,    36,    37,    38,    39,    40,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    50,    -1,    -1,
      53,    54,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,    71,    72,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    86,    -1,    -1,    89,    90,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,     3,    -1,    -1,   102,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   115,    -1,    -1,    -1,   119,    24,    25,    26,
      27,    28,    29,    30,    31,    32,    33,    34,    35,    36,
      37,    38,    39,    40,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    50,    -1,    -1,    53,    54,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    70,    71,    72,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    86,
      -1,    -1,    89,    90,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,     3,    -1,    -1,   102,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   115,    -1,
      -1,    -1,   119,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    50,
      -1,    -1,    53,    54,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    89,    90,
      -1,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    -1,
      -1,    -1,    53,    54,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      71,    72,     3,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    89,    90,
      -1,    -1,    -1,    24,    25,    26,    27,    28,    29,    30,
      31,    32,    33,    34,    35,    36,    37,    38,    39,    40,
      -1,    -1,    -1,    -1,   115,    -1,    -1,    -1,   119,    50,
      -1,    -1,     4,    -1,    -1,    -1,     8,     9,    10,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    70,
      -1,    23,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    86,    -1,    -1,    89,    90,
      -1,    -1,    44,    45,    -1,    47,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    63,    64,    65,   115,    67,    68,    69,   119,    -1,
      -1,    73,    74,    75,    -1,    77,    78,    79,    -1,    81,
      82,    83,    84,    85,    -1,    -1,     4,    -1,    -1,    91,
       8,     9,    10,    95,    96,    97,    98,    99,   100,   101,
      -1,    -1,    -1,    -1,    -1,    23,    -1,    -1,    -1,    -1,
      -1,   113,    -1,    -1,    -1,    -1,   118,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    44,    45,    -1,    47,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    63,    64,    65,    -1,    67,
      68,    69,    -1,    -1,    -1,    73,    74,    75,    -1,    77,
      78,    79,    -1,    81,    82,    83,    84,    85,    -1,    -1,
      -1,    -1,    -1,    91,    -1,    -1,    -1,    95,    96,    97,
      98,    99,   100,   101,    -1,    -1,    60,    -1,    -1,    -1,
      -1,    -1,    -1,     3,    -1,   113,     6,     7,    -1,    -1,
     118,    11,    12,    13,    14,    15,    16,    17,    18,    19,
      20,    21,    22,    -1,    -1,    -1,    -1,    -1,    -1,    60,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    41,   106,   107,   108,   109,   110,    -1,   112,    49,
      -1,    -1,    -1,    -1,    -1,    -1,    56,    57,    -1,    -1,
      -1,    -1,    60,   127,   128,   129,   130,   131,   132,   133,
     134,   135,   136,   137,   138,   106,   107,   108,   109,   110,
      -1,   112,    -1,    -1,    -1,    -1,    -1,    -1,    88,    -1,
      -1,    -1,    -1,    -1,    -1,    60,   127,   128,   129,   130,
     131,   132,   133,   134,   135,   136,   137,   138,   106,   107,
     108,   109,   110,    -1,   112,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,   106,   107,   108,   109,   110,    -1,   112,    -1,    -1,
      -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,    -1,
      -1,    -1,   127,   128,   129,   130,   131,   132,   133,   134,
     135,   136,   137,   138
};

/* YYSTOS[STATE-NUM] -- The symbol kind of the accessing symbol of
   state STATE-NUM.  */
static const yytype_int16 yystos[] =
{
       0,   121,   122,   123,   144,   145,     1,     3,    24,    25,
      26,    27,    28,    29,    30,    31,    32,    33,    34,    35,
      36,    37,    38,    39,    40,    49,    50,    51,    52,    53,
      54,    70,    71,    72,    86,    89,    90,   115,   119,   124,
     194,   235,   236,   251,   252,   254,   255,   256,   259,   260,
     261,   289,   290,   305,   308,   310,     1,   236,     1,    41,
       0,     1,     4,     8,     9,    10,    23,    44,    45,    58,
      63,    64,    65,    66,    67,    68,    69,    77,    78,    79,
      81,    82,    83,    84,    85,    91,    92,    93,    94,    95,
      96,    97,    98,    99,   100,   101,   113,   118,   124,   125,
     146,   147,   148,   150,   151,   152,   153,   156,   157,   159,
     160,   161,   162,   163,   164,   167,   168,   169,   172,   174,
     179,   180,   181,   182,   184,   188,   196,   197,   198,   199,
     200,   204,   205,   211,   212,   223,   224,   230,   231,   232,
      53,    71,    49,   280,   280,    41,   142,   102,   304,   235,
     308,     0,   252,   255,    41,    49,    55,    59,   119,   128,
     131,   136,   140,   240,   241,   243,   245,   246,   247,   248,
     308,   251,   260,   308,   304,   117,   142,   309,     0,   233,
     234,   236,   120,    41,     6,   118,   314,    41,   317,     1,
     253,   254,   305,   317,    41,   166,    41,    41,    41,    41,
      72,    92,   308,    46,   305,   308,    41,     4,    46,    41,
       4,   314,    41,   178,   253,   176,   177,   178,    41,    41,
     314,    41,    32,    34,    36,    50,   102,   187,   194,   256,
     259,   290,   308,   317,    41,   128,   131,   243,   245,   248,
     308,    87,   194,   253,   290,    45,   232,   257,   118,   119,
     310,   311,     3,     7,    11,    12,    13,    14,    15,    16,
      17,    18,    19,    20,    21,    22,    41,    56,    57,    88,
     131,   134,   135,   136,   140,   141,   236,   237,   238,   239,
     253,   254,   274,   275,   276,   277,   278,   279,   314,   315,
     251,    41,   128,   131,   233,   246,   248,   308,    46,   104,
     105,   262,   263,   264,   265,   274,   277,    60,   274,     3,
      41,    49,   140,   244,   247,   280,   308,    49,   244,   247,
     280,   251,   308,   240,    41,    59,   240,    41,    59,    49,
     128,   131,   136,   244,   247,   280,   308,   116,   310,   119,
     311,    42,    43,   124,   125,   263,   305,   306,   314,   187,
     290,     6,    46,   306,   318,   319,   306,     0,    44,    41,
     243,   245,    55,    53,    54,    71,   291,   292,   305,   305,
     306,    13,   173,   233,   233,   308,   308,    44,    55,   214,
      55,    46,   305,   175,   318,   233,    46,   242,   243,   245,
     246,    44,    43,   306,   307,   154,   155,   314,   233,   308,
     118,   208,   209,   210,   236,   289,   308,   308,   308,   128,
     131,   314,   128,   131,   248,   305,   308,   318,    41,    49,
      49,   306,    41,    49,   128,   131,   308,   116,   243,   308,
     266,   305,    41,   243,    76,   281,   282,   308,   314,     1,
     258,   274,   305,   309,    48,   111,   274,   276,     3,    41,
      49,   276,    41,    41,   274,   274,   274,   274,   274,   274,
     103,    43,    41,   106,   107,   108,   109,   110,   112,   127,
     128,   129,   130,   131,   132,   133,   134,   135,   136,   137,
     138,    48,   111,     7,     6,     7,   128,   131,   248,   308,
     245,   308,   245,    42,    42,   128,   131,   245,   308,   116,
      59,    60,    41,   248,   308,   244,   308,    41,    59,   244,
     233,    60,   274,   233,    60,   274,   244,    49,   244,   247,
     280,    49,   244,   247,   280,   251,   116,    49,   128,   131,
     244,   251,   309,     0,   125,   233,    43,    42,   308,   308,
     183,    55,    42,    43,   240,    41,   262,   308,    42,    55,
      43,   171,    43,    42,    42,    44,    44,   253,   145,   308,
     213,    42,    42,    42,   176,    41,   178,    42,    42,    43,
      46,    42,   128,   131,   102,   103,    43,   240,    41,    61,
     116,    42,   248,   308,    44,   233,    49,    49,   116,    80,
      88,    89,    90,   128,   131,   249,   250,   251,   294,   297,
     298,   299,    55,    76,   195,   233,   308,   299,   283,    46,
      44,    90,   296,    42,    42,   304,     3,     3,    42,   103,
     128,   131,   136,   248,   102,    41,   239,    49,   274,    49,
     274,    49,   274,    49,   274,   274,   274,    49,   274,    49,
     274,    49,   274,    49,   274,    49,   274,    49,   274,    49,
     274,    49,   274,    49,   274,    49,   274,    49,   274,    49,
     274,     3,     3,   308,   116,    42,    42,    42,   116,   243,
     246,   251,   233,   244,   308,    42,   116,   233,    60,   274,
      42,    60,    42,    60,   244,   244,    49,   128,   131,   244,
     247,   244,    49,    49,   244,   233,   233,     4,    46,   314,
      41,   145,   154,   278,   314,   320,   306,    44,   233,    44,
      46,     4,   165,   314,   306,   314,   320,    42,   236,   243,
      46,   242,    47,    44,   145,   230,   176,    41,    47,   233,
     115,   119,   305,   312,    44,   318,   236,     4,    44,    46,
     114,   170,   314,   316,   208,    91,   206,   210,   233,   158,
     251,   243,   314,   116,    42,    41,    41,   294,    90,    89,
     297,   250,    46,   111,     1,    59,   189,   262,   255,    44,
      46,    42,    55,    76,   186,   240,    78,   284,   285,   293,
     202,   281,    41,    41,   274,    49,   274,    42,    42,   251,
      42,   128,   131,    49,   274,   305,    76,    41,    41,    42,
      42,   243,   246,    42,    42,   244,    42,    60,   298,   249,
     244,    49,    49,   244,   244,   244,   233,    47,    55,    42,
     149,    55,    43,   171,   170,   243,   299,    44,    47,   253,
     305,    44,    55,   316,   233,    42,   142,   117,   142,   313,
     102,    42,    47,    41,   103,   308,    45,   118,   184,   200,
     204,   205,   207,   220,   222,   230,    42,   145,   299,    44,
     233,   274,   187,    44,   102,   190,    44,   152,   267,   268,
     269,   270,    41,    55,   297,   299,   300,     1,   274,     1,
      43,    44,    46,   185,    43,    73,    74,    75,   286,   288,
       1,    44,    66,    73,    74,    75,   124,   150,   151,   152,
     153,   156,   157,   161,   164,   167,   169,   172,   174,   179,
     180,   181,   182,   200,   204,   205,   211,   215,   216,   217,
     218,   220,   221,   222,   223,   225,   226,   228,   230,    46,
      42,    42,   274,   274,   274,    42,    42,    42,    42,    42,
     274,    42,    42,    42,   244,   244,    42,   154,   320,   249,
     215,   314,   320,    42,   299,    44,   243,    44,   178,    42,
     249,   119,   305,   305,   119,   305,   237,     4,    46,   233,
     290,    55,   102,    87,   120,   253,    62,    44,    42,    42,
     294,   295,    41,    46,   191,   267,   124,   271,   272,   305,
      47,    43,   124,   125,   233,   262,    55,    76,   301,    44,
     243,   285,   308,   287,    46,    76,    76,    76,   217,    47,
     124,   218,   125,    32,    34,    36,   140,   229,   259,   308,
     201,   274,   274,   240,    47,   171,    44,   243,   170,    44,
      44,   313,   313,   103,    42,   240,   308,   253,   208,   308,
     253,    41,   294,   186,   233,    41,    44,   192,   272,   268,
      55,    44,   243,   125,   269,    43,    42,    44,   263,   302,
     303,   308,    44,    46,   299,   280,   293,   219,    44,   203,
     243,   310,    76,    44,   215,    44,   299,    44,    44,   240,
     242,   103,    55,    41,   128,   131,   248,   233,   185,    42,
     193,   273,   274,   299,   269,   269,    44,    46,    44,    43,
      49,    41,    46,   186,   308,   215,   299,    41,   274,    47,
      44,    44,   233,    41,    41,    41,   131,    42,   299,    44,
     186,   303,   185,   280,    47,   186,   233,    44,   203,    42,
     233,   233,   233,    41,   300,   111,   191,   185,    49,   185,
      42,   227,   299,    42,    42,    42,   233,   253,   192,   227,
      44,    46,    55,   227,   227,   227,    42,   191,   262,   227,
     192,    44
};

/* YYR1[RULE-NUM] -- Symbol kind of the left-hand side of rule RULE-NUM.  */
static const yytype_int16 yyr1[] =
{
       0,   143,   144,   144,   144,   144,   144,   144,   144,   145,
     145,   145,   145,   146,   146,   146,   146,   146,   146,   146,
     147,   147,   147,   147,   147,   147,   147,   147,   147,   147,
     147,   147,   147,   147,   147,   147,   147,   147,   147,   149,
     148,   150,   151,   152,   152,   152,   152,   152,   153,   153,
     154,   155,   155,   156,   156,   156,   158,   157,   159,   159,
     160,   160,   161,   161,   161,   161,   162,   163,   163,   164,
     164,   165,   165,   166,   166,   167,   167,   167,   168,   168,
     169,   169,   169,   169,   170,   170,   170,   171,   171,   172,
     173,   173,   174,   174,   174,   175,   176,   177,   177,   178,
     178,   178,   179,   180,   181,   182,   182,   182,   183,   182,
     182,   182,   182,   182,   184,   184,   184,   184,   184,   184,
     185,   185,   185,   185,   186,   186,   187,   187,   187,   187,
     187,   187,   187,   187,   187,   187,   187,   188,   188,   188,
     189,   190,   190,   191,   192,   193,   192,   194,   194,   194,
     195,   195,   196,   197,   197,   198,   199,   199,   199,   199,
     199,   199,   201,   200,   202,   200,   203,   203,   204,   206,
     205,   205,   205,   205,   205,   207,   207,   207,   207,   207,
     207,   208,   208,   209,   209,   210,   210,   210,   210,   211,
     211,   211,   213,   212,   214,   212,   212,   215,   215,   215,
     215,   215,   216,   216,   217,   217,   217,   217,   217,   217,
     217,   217,   217,   217,   217,   217,   217,   217,   217,   217,
     217,   217,   217,   218,   218,   218,   219,   218,   220,   221,
     222,   222,   222,   222,   222,   223,   224,   225,   225,   225,
     226,   226,   226,   226,   226,   226,   226,   226,   226,   226,
     227,   227,   227,   228,   229,   229,   229,   229,   229,   230,
     230,   231,   231,   232,   232,   232,   232,   232,   232,   232,
     232,   232,   233,   234,   234,   234,   234,   234,   234,   234,
     235,   235,   236,   236,   237,   237,   238,   238,   239,   239,
     240,   240,   240,   240,   241,   241,   241,   241,   242,   242,
     242,   242,   243,   243,   243,   243,   243,   243,   243,   243,
     243,   243,   243,   243,   243,   243,   243,   243,   243,   243,
     243,   243,   243,   244,   244,   244,   244,   244,   244,   244,
     244,   245,   245,   245,   245,   245,   245,   245,   245,   245,
     245,   245,   245,   245,   246,   246,   246,   246,   246,   246,
     246,   246,   246,   246,   246,   246,   246,   246,   246,   247,
     247,   247,   247,   247,   247,   247,   247,   248,   248,   248,
     248,   249,   249,   249,   250,   250,   251,   251,   252,   252,
     252,   253,   254,   254,   254,   254,   254,   255,   255,   255,
     255,   255,   255,   255,   255,   257,   256,   258,   258,   259,
     260,   260,   261,   261,   261,   261,   261,   261,   261,   261,
     261,   261,   261,   261,   261,   261,   262,   262,   263,   263,
     264,   265,   266,   266,   267,   267,   268,   268,   269,   269,
     269,   269,   269,   269,   269,   270,   271,   271,   272,   272,
     273,   274,   274,   275,   275,   275,   275,   275,   275,   275,
     275,   276,   276,   276,   276,   276,   276,   276,   276,   276,
     276,   276,   277,   277,   277,   277,   277,   277,   277,   277,
     277,   277,   277,   278,   278,   278,   278,   278,   278,   278,
     278,   278,   278,   279,   279,   279,   279,   279,   279,   279,
     279,   279,   279,   279,   279,   279,   279,   279,   279,   279,
     279,   279,   279,   279,   279,   279,   279,   279,   279,   279,
     279,   279,   279,   279,   279,   279,   279,   279,   279,   279,
     279,   279,   279,   279,   279,   279,   280,   280,   281,   283,
     282,   282,   284,   284,   286,   285,   287,   285,   288,   288,
     288,   289,   289,   290,   290,   290,   291,   291,   291,   292,
     292,   293,   293,   294,   294,   294,   294,   295,   295,   296,
     296,   297,   297,   297,   297,   297,   297,   298,   298,   298,
     299,   299,   300,   300,   300,   300,   300,   300,   301,   301,
     302,   302,   302,   302,   303,   303,   304,   305,   305,   305,
     306,   306,   306,   307,   307,   308,   308,   308,   308,   308,
     308,   308,   309,   309,   309,   309,   310,   310,   311,   311,
     312,   312,   312,   312,   312,   312,   313,   313,   313,   313,
     314,   314,   315,   315,   315,   315,   316,   316,   316,   317,
     317,   318,   319,   319,   319,   319,   319,   319,   320,   320
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
       1,     6,    10,     1,     6,     7,     9,     5,     6,     6,
       1,     5,     1,     1,     1,     2,     1,     1,     1,     2,
       1,     1,     2,     2,     3,     3,     1,    12,    14,     8,
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
       2,     4,     2,     5,     1,     1,     1,     1,     1,     1,
       0,     1,     2,     1,     2,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     2,     2,     3,     4,     4,     0,
       2,     1,     1,     2,     1,     0,     1,     3,     1,     1,
       2,     3,     2,     0,     2,     2,     1,     5,     1,     1,
       5,     0,     2,     3,     3,     1,     2,     2,     3,     4,
       5,     4,     3,     4,     4,     3,     3,     4,     5,     6,
       6,     5,     5,     1,     2,     3,     4,     5,     3,     4,
       4,     1,     2,     4,     4,     4,     5,     6,     5,     6,
       3,     4,     4,     5,     2,     2,     3,     3,     3,     3,
       1,     2,     2,     2,     2,     2,     3,     3,     4,     3,
       4,     2,     3,     3,     4,     5,     3,     3,     2,     2,
       1,     1,     2,     1,     1,     1,     1,     2,     1,     1,
       1,     1,     2,     1,     2,     3,     2,     1,     1,     1,
       2,     1,     1,     2,     1,     0,     4,     2,     2,     1,
       1,     2,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     0,     1,     2,     1,     0,     1,     2,
       2,     3,     4,     4,     1,     3,     1,     2,     1,     3,
       1,     1,     1,     3,     4,     3,     4,     3,     4,     3,
       4,     1,     1,     1,     1,     1,     1,     2,     2,     2,
       5,     2,     1,     1,     3,     4,     5,     5,     5,     6,
       6,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       1,     1,     1,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     3,     3,     5,     5,     3,
       3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
       3,     3,     3,     3,     3,     5,     5,     3,     3,     3,
       5,     2,     2,     2,     2,     2,     1,     0,     1,     0,
       3,     0,     1,     3,     0,     4,     0,     6,     1,     1,
       1,     2,     2,     1,     1,     1,     1,     1,     1,     1,
       0,     1,     0,     1,     1,     2,     2,     1,     0,     1,
       0,     4,     1,     1,     5,     2,     4,     1,     1,     2,
       1,     0,     3,     3,     4,     4,     3,     4,     2,     0,
       1,     3,     2,     4,     2,     2,     3,     1,     1,     1,
       1,     1,     1,     1,     0,     2,     4,     1,     3,     1,
       2,     3,     3,     2,     2,     2,     1,     2,     1,     3,
       2,     4,     1,     3,     1,     3,     3,     2,     2,     2,
       2,     1,     2,     2,     2,     1,     1,     1,     1,     3,
       0,     1,     3,     5,     1,     3,     3,     5,     1,     1
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
#line 1959 "./CParse/parser.y"
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
#line 5500 "CParse/parser.c"
    break;

  case 3: /* program: PARSETYPE parm END  */
#line 1971 "./CParse/parser.y"
                                    {
                 top = Copy(Getattr((yyvsp[-1].p),"type"));
		 Delete((yyvsp[-1].p));
               }
#line 5509 "CParse/parser.c"
    break;

  case 4: /* program: PARSETYPE error  */
#line 1975 "./CParse/parser.y"
                                 {
                 top = 0;
               }
#line 5517 "CParse/parser.c"
    break;

  case 5: /* program: PARSEPARM parm END  */
#line 1978 "./CParse/parser.y"
                                    {
                 top = (yyvsp[-1].p);
               }
#line 5525 "CParse/parser.c"
    break;

  case 6: /* program: PARSEPARM error  */
#line 1981 "./CParse/parser.y"
                                 {
                 top = 0;
               }
#line 5533 "CParse/parser.c"
    break;

  case 7: /* program: PARSEPARMS LPAREN parms RPAREN END  */
#line 1984 "./CParse/parser.y"
                                                    {
                 top = (yyvsp[-2].pl);
               }
#line 5541 "CParse/parser.c"
    break;

  case 8: /* program: PARSEPARMS error  */
#line 1987 "./CParse/parser.y"
                                  {
                 top = 0;
               }
#line 5549 "CParse/parser.c"
    break;

  case 9: /* interface: interface declaration  */
#line 1992 "./CParse/parser.y"
                                           {  
                   /* add declaration to end of linked list (the declaration isn't always a single declaration, sometimes it is a linked list itself) */
                   if (currentDeclComment != NULL) {
		     set_comment((yyvsp[0].node), currentDeclComment);
		     currentDeclComment = NULL;
                   }                                      
                   appendChild((yyvsp[-1].node),(yyvsp[0].node));
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5563 "CParse/parser.c"
    break;

  case 10: /* interface: interface DOXYGENSTRING  */
#line 2001 "./CParse/parser.y"
                                             {
		   Delete(currentDeclComment);
                   currentDeclComment = (yyvsp[0].str); 
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5573 "CParse/parser.c"
    break;

  case 11: /* interface: interface DOXYGENPOSTSTRING  */
#line 2006 "./CParse/parser.y"
                                                 {
                   Node *node = lastChild((yyvsp[-1].node));
                   if (node) {
                     set_comment(node, (yyvsp[0].str));
		   } else {
		     Delete((yyvsp[0].str));
		   }
                   (yyval.node) = (yyvsp[-1].node);
               }
#line 5587 "CParse/parser.c"
    break;

  case 12: /* interface: %empty  */
#line 2015 "./CParse/parser.y"
                        {
                   (yyval.node) = new_node("top");
               }
#line 5595 "CParse/parser.c"
    break;

  case 16: /* declaration: SEMI  */
#line 2023 "./CParse/parser.y"
                      { (yyval.node) = 0; }
#line 5601 "CParse/parser.c"
    break;

  case 17: /* declaration: error  */
#line 2024 "./CParse/parser.y"
                       {
		  if (cparse_unknown_directive) {
		      Swig_error(cparse_file, cparse_line, "Unknown directive '%s'.\n", cparse_unknown_directive);
		  } else {
		      Swig_error(cparse_file, cparse_line, "Syntax error in input(1).\n");
		  }
		  Exit(EXIT_FAILURE);
               }
#line 5614 "CParse/parser.c"
    break;

  case 18: /* declaration: c_constructor_decl  */
#line 2033 "./CParse/parser.y"
                                    { 
                  if ((yyval.node)) {
   		      add_symbols((yyval.node));
                  }
                  (yyval.node) = (yyvsp[0].node); 
	       }
#line 5625 "CParse/parser.c"
    break;

  case 19: /* declaration: error CONVERSIONOPERATOR  */
#line 2049 "./CParse/parser.y"
                                          {
                  (yyval.node) = 0;
		  Delete((yyvsp[0].str));
                  skip_decl();
               }
#line 5635 "CParse/parser.c"
    break;

  case 39: /* $@1: %empty  */
#line 2085 "./CParse/parser.y"
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
#line 5681 "CParse/parser.c"
    break;

  case 40: /* extend_directive: EXTEND options classkeyopt idcolon LBRACE $@1 cpp_members RBRACE  */
#line 2125 "./CParse/parser.y"
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
#line 5722 "CParse/parser.c"
    break;

  case 41: /* apply_directive: APPLY typemap_parm LBRACE tm_list RBRACE  */
#line 2167 "./CParse/parser.y"
                                                           {
                    (yyval.node) = new_node("apply");
                    Setattr((yyval.node),"pattern",Getattr((yyvsp[-3].p),"pattern"));
		    appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 5732 "CParse/parser.c"
    break;

  case 42: /* clear_directive: CLEAR tm_list SEMI  */
#line 2177 "./CParse/parser.y"
                                     {
		 (yyval.node) = new_node("clear");
		 appendChild((yyval.node),(yyvsp[-1].p));
               }
#line 5741 "CParse/parser.c"
    break;

  case 43: /* constant_directive: CONSTANT identifier EQUAL definetype SEMI  */
#line 2191 "./CParse/parser.y"
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
#line 5764 "CParse/parser.c"
    break;

  case 44: /* constant_directive: CONSTANT type declarator def_args SEMI  */
#line 2209 "./CParse/parser.y"
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
#line 5785 "CParse/parser.c"
    break;

  case 45: /* constant_directive: CONSTANT type direct_declarator LPAREN parms RPAREN cv_ref_qualifier def_args SEMI  */
#line 2227 "./CParse/parser.y"
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
#line 5808 "CParse/parser.c"
    break;

  case 46: /* constant_directive: CONSTANT error SEMI  */
#line 2245 "./CParse/parser.y"
                                     {
		 Swig_warning(WARN_PARSE_BAD_VALUE,cparse_file,cparse_line,"Bad constant value (ignored).\n");
		 (yyval.node) = 0;
	       }
#line 5817 "CParse/parser.c"
    break;

  case 47: /* constant_directive: CONSTANT error END  */
#line 2249 "./CParse/parser.y"
                                    {
		 Swig_error(cparse_file,cparse_line,"Missing semicolon (';') after %%constant.\n");
		 Exit(EXIT_FAILURE);
	       }
#line 5826 "CParse/parser.c"
    break;

  case 48: /* echo_directive: ECHO HBLOCK  */
#line 2260 "./CParse/parser.y"
                             {
		 char temp[64];
		 Replace((yyvsp[0].str),"$file",cparse_file, DOH_REPLACE_ANY);
		 sprintf(temp,"%d", cparse_line);
		 Replace((yyvsp[0].str),"$line",temp,DOH_REPLACE_ANY);
		 Printf(stderr,"%s\n", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
                 (yyval.node) = 0;
	       }
#line 5840 "CParse/parser.c"
    break;

  case 49: /* echo_directive: ECHO string  */
#line 2269 "./CParse/parser.y"
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
#line 5855 "CParse/parser.c"
    break;

  case 50: /* stringtype: string LBRACE parm RBRACE  */
#line 2282 "./CParse/parser.y"
                                          {		 
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[-3].str));
		 Setattr((yyval.node),"type",Getattr((yyvsp[-1].p),"type"));
               }
#line 5865 "CParse/parser.c"
    break;

  case 51: /* fname: string  */
#line 2289 "./CParse/parser.y"
                       {
                 (yyval.node) = NewHash();
                 Setattr((yyval.node),"value",(yyvsp[0].str));
              }
#line 5874 "CParse/parser.c"
    break;

  case 53: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN HBLOCK  */
#line 2304 "./CParse/parser.y"
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
#line 5889 "CParse/parser.c"
    break;

  case 54: /* fragment_directive: FRAGMENT LPAREN fname COMMA kwargs RPAREN LBRACE  */
#line 2314 "./CParse/parser.y"
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
#line 5909 "CParse/parser.c"
    break;

  case 55: /* fragment_directive: FRAGMENT LPAREN fname RPAREN SEMI  */
#line 2329 "./CParse/parser.y"
                                                     {
		   (yyval.node) = new_node("fragment");
		   Setattr((yyval.node),"value",Getattr((yyvsp[-2].node),"value"));
		   Setattr((yyval.node),"type",Getattr((yyvsp[-2].node),"type"));
		   Setattr((yyval.node),"emitonly","1");
		 }
#line 5920 "CParse/parser.c"
    break;

  case 56: /* @2: %empty  */
#line 2342 "./CParse/parser.y"
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
#line 5935 "CParse/parser.c"
    break;

  case 57: /* include_directive: includetype options string BEGINFILE @2 interface ENDOFFILE  */
#line 2351 "./CParse/parser.y"
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
#line 5990 "CParse/parser.c"
    break;

  case 58: /* includetype: INCLUDE  */
#line 2403 "./CParse/parser.y"
                         { (yyval.includetype) = INCLUDE_INCLUDE; }
#line 5996 "CParse/parser.c"
    break;

  case 59: /* includetype: IMPORT  */
#line 2404 "./CParse/parser.y"
                         { (yyval.includetype) = INCLUDE_IMPORT; ++import_mode;}
#line 6002 "CParse/parser.c"
    break;

  case 60: /* inline_directive: INLINE HBLOCK  */
#line 2411 "./CParse/parser.y"
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
#line 6025 "CParse/parser.c"
    break;

  case 61: /* inline_directive: INLINE LBRACE  */
#line 2429 "./CParse/parser.y"
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
#line 6052 "CParse/parser.c"
    break;

  case 62: /* insert_directive: HBLOCK  */
#line 2463 "./CParse/parser.y"
                          {
                 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 6062 "CParse/parser.c"
    break;

  case 63: /* insert_directive: INSERT LPAREN idstring RPAREN string  */
#line 2468 "./CParse/parser.y"
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
#line 6077 "CParse/parser.c"
    break;

  case 64: /* insert_directive: INSERT LPAREN idstring RPAREN HBLOCK  */
#line 2478 "./CParse/parser.y"
                                                      {
		 (yyval.node) = new_node("insert");
		 Setattr((yyval.node),"section",(yyvsp[-2].id));
		 Setattr((yyval.node),"code",(yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 6088 "CParse/parser.c"
    break;

  case 65: /* insert_directive: INSERT LPAREN idstring RPAREN LBRACE  */
#line 2484 "./CParse/parser.y"
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
#line 6104 "CParse/parser.c"
    break;

  case 66: /* module_directive: MODULE options idstring  */
#line 2502 "./CParse/parser.y"
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
#line 6145 "CParse/parser.c"
    break;

  case 67: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class identifier SEMI  */
#line 2545 "./CParse/parser.y"
                                                                                                  {
                 (yyval.node) = new_node("native");
		 Setattr((yyval.node),"name",(yyvsp[-4].id));
		 Setattr((yyval.node),"wrap:name",(yyvsp[-1].id));
		 Delete((yyvsp[-2].str));
	         add_symbols((yyval.node));
	       }
#line 6157 "CParse/parser.c"
    break;

  case 68: /* native_directive: NATIVE LPAREN identifier RPAREN storage_class type declarator SEMI  */
#line 2552 "./CParse/parser.y"
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
#line 6180 "CParse/parser.c"
    break;

  case 69: /* pragma_directive: PRAGMA pragma_lang identifier EQUAL pragma_arg  */
#line 2579 "./CParse/parser.y"
                                                                  {
                 (yyval.node) = new_node("pragma");
		 Setattr((yyval.node),"lang",(yyvsp[-3].id));
		 Setattr((yyval.node),"name",(yyvsp[-2].id));
		 Setattr((yyval.node),"value",(yyvsp[0].str));
	       }
#line 6191 "CParse/parser.c"
    break;

  case 70: /* pragma_directive: PRAGMA pragma_lang identifier  */
#line 2585 "./CParse/parser.y"
                                              {
		(yyval.node) = new_node("pragma");
		Setattr((yyval.node),"lang",(yyvsp[-1].id));
		Setattr((yyval.node),"name",(yyvsp[0].id));
	      }
#line 6201 "CParse/parser.c"
    break;

  case 73: /* pragma_lang: LPAREN identifier RPAREN  */
#line 2596 "./CParse/parser.y"
                                         { (yyval.id) = (yyvsp[-1].id); }
#line 6207 "CParse/parser.c"
    break;

  case 74: /* pragma_lang: %empty  */
#line 2597 "./CParse/parser.y"
                       { (yyval.id) = "swig"; }
#line 6213 "CParse/parser.c"
    break;

  case 75: /* rename_directive: rename_namewarn declarator idstring SEMI  */
#line 2604 "./CParse/parser.y"
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
#line 6264 "CParse/parser.c"
    break;

  case 76: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN declarator cpp_const SEMI  */
#line 2650 "./CParse/parser.y"
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
#line 6315 "CParse/parser.c"
    break;

  case 77: /* rename_directive: rename_namewarn LPAREN kwargs RPAREN string SEMI  */
#line 2696 "./CParse/parser.y"
                                                                 {
		if ((yyvsp[-5].intvalue)) {
		  Swig_name_rename_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node),0);
		} else {
		  Swig_name_namewarn_add(Namespaceprefix,(yyvsp[-1].str),0,(yyvsp[-3].node));
		}
		(yyval.node) = 0;
		scanner_clear_rename();
              }
#line 6329 "CParse/parser.c"
    break;

  case 78: /* rename_namewarn: RENAME  */
#line 2707 "./CParse/parser.y"
                         {
		    (yyval.intvalue) = 1;
                }
#line 6337 "CParse/parser.c"
    break;

  case 79: /* rename_namewarn: NAMEWARN  */
#line 2710 "./CParse/parser.y"
                           {
                    (yyval.intvalue) = 0;
                }
#line 6345 "CParse/parser.c"
    break;

  case 80: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN declarator cpp_const stringbracesemi  */
#line 2737 "./CParse/parser.y"
                                                                                                 {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-5].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6356 "CParse/parser.c"
    break;

  case 81: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN declarator cpp_const SEMI  */
#line 2743 "./CParse/parser.y"
                                                                                                      {
                    String *val = Len((yyvsp[-5].str)) ? (yyvsp[-5].str) : 0;
                    new_feature((yyvsp[-7].id), val, (yyvsp[-4].node), (yyvsp[-2].decl).id, (yyvsp[-2].decl).type, (yyvsp[-2].decl).parms, (yyvsp[-1].dtype).qualifier);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6367 "CParse/parser.c"
    break;

  case 82: /* feature_directive: FEATURE LPAREN idstring featattr RPAREN stringbracesemi  */
#line 2751 "./CParse/parser.y"
                                                                            {
                    String *val = (yyvsp[0].str) ? NewString((yyvsp[0].str)) : NewString("1");
                    new_feature((yyvsp[-3].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6378 "CParse/parser.c"
    break;

  case 83: /* feature_directive: FEATURE LPAREN idstring COMMA stringnum featattr RPAREN SEMI  */
#line 2757 "./CParse/parser.y"
                                                                                 {
                    String *val = Len((yyvsp[-3].str)) ? (yyvsp[-3].str) : 0;
                    new_feature((yyvsp[-5].id), val, (yyvsp[-2].node), 0, 0, 0, 0);
                    (yyval.node) = 0;
                    scanner_clear_rename();
                  }
#line 6389 "CParse/parser.c"
    break;

  case 85: /* stringbracesemi: SEMI  */
#line 2766 "./CParse/parser.y"
                       { (yyval.str) = 0; }
#line 6395 "CParse/parser.c"
    break;

  case 86: /* stringbracesemi: PARMS LPAREN parms RPAREN SEMI  */
#line 2767 "./CParse/parser.y"
                                                 { (yyval.str) = (yyvsp[-2].pl); }
#line 6401 "CParse/parser.c"
    break;

  case 87: /* featattr: COMMA idstring EQUAL stringnum featattr  */
#line 2770 "./CParse/parser.y"
                                                              {
		  (yyval.node) = NewHash();
		  Setattr((yyval.node),"name",(yyvsp[-3].id));
		  Setattr((yyval.node),"value",(yyvsp[-1].str));
		  if ((yyvsp[0].node)) set_nextSibling((yyval.node), (yyvsp[0].node));
		}
#line 6412 "CParse/parser.c"
    break;

  case 88: /* featattr: %empty  */
#line 2776 "./CParse/parser.y"
                         {
		  (yyval.node) = 0;
		}
#line 6420 "CParse/parser.c"
    break;

  case 89: /* varargs_directive: VARARGS LPAREN varargs_parms RPAREN declarator cpp_const SEMI  */
#line 2783 "./CParse/parser.y"
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
#line 6460 "CParse/parser.c"
    break;

  case 91: /* varargs_parms: NUM_INT COMMA parm  */
#line 2820 "./CParse/parser.y"
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
#line 6489 "CParse/parser.c"
    break;

  case 92: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list stringbrace  */
#line 2854 "./CParse/parser.y"
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
#line 6513 "CParse/parser.c"
    break;

  case 93: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list SEMI  */
#line 2873 "./CParse/parser.y"
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
#line 6528 "CParse/parser.c"
    break;

  case 94: /* typemap_directive: TYPEMAP LPAREN typemap_type RPAREN tm_list EQUAL typemap_parm SEMI  */
#line 2883 "./CParse/parser.y"
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
#line 6544 "CParse/parser.c"
    break;

  case 95: /* typemap_type: kwargs  */
#line 2898 "./CParse/parser.y"
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
#line 6569 "CParse/parser.c"
    break;

  case 96: /* tm_list: tm_list_builder  */
#line 2920 "./CParse/parser.y"
                                 {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
	       }
#line 6577 "CParse/parser.c"
    break;

  case 97: /* tm_list_builder: typemap_parm  */
#line 2925 "./CParse/parser.y"
                              {
                 (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6585 "CParse/parser.c"
    break;

  case 98: /* tm_list_builder: tm_list_builder COMMA typemap_parm  */
#line 2928 "./CParse/parser.y"
                                                        {
		 // Build a linked list in the order specified, but avoiding
		 // a right recursion rule because "Right recursion uses up
		 // space on the Bison stack in proportion to the number of
		 // elements in the sequence".
		 set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		 (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		 (yyval.pbuilder).last = (yyvsp[0].p);
	       }
#line 6599 "CParse/parser.c"
    break;

  case 99: /* typemap_parm: type plain_declarator  */
#line 2939 "./CParse/parser.y"
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
#line 6615 "CParse/parser.c"
    break;

  case 100: /* typemap_parm: LPAREN parms RPAREN  */
#line 2950 "./CParse/parser.y"
                                     {
                  (yyval.p) = new_node("typemapitem");
		  Setattr((yyval.p),"pattern",(yyvsp[-1].pl));
		  /*		  Setattr($$,"multitype",$parms); */
               }
#line 6625 "CParse/parser.c"
    break;

  case 101: /* typemap_parm: LPAREN parms RPAREN LPAREN parms RPAREN  */
#line 2955 "./CParse/parser.y"
                                                                      {
		 (yyval.p) = new_node("typemapitem");
		 Setattr((yyval.p),"pattern", (yyvsp[-4].pl));
		 /*                 Setattr($$,"multitype",$in); */
		 Setattr((yyval.p),"parms",(yyvsp[-1].pl));
               }
#line 6636 "CParse/parser.c"
    break;

  case 102: /* types_directive: TYPES LPAREN parms RPAREN stringbracesemi  */
#line 2968 "./CParse/parser.y"
                                                            {
                   (yyval.node) = new_node("types");
		   Setattr((yyval.node),"parms",(yyvsp[-2].pl));
                   if ((yyvsp[0].str))
		     Setattr((yyval.node),"convcode",NewString((yyvsp[0].str)));
               }
#line 6647 "CParse/parser.c"
    break;

  case 103: /* template_directive: SWIGTEMPLATE LPAREN idstringopt RPAREN idcolonnt LESSTHAN valparms GREATERTHAN SEMI  */
#line 2980 "./CParse/parser.y"
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
#line 6890 "CParse/parser.c"
    break;

  case 104: /* warn_directive: WARN string  */
#line 3224 "./CParse/parser.y"
                             {
		  Swig_warning(0,cparse_file, cparse_line,"%s\n", (yyvsp[0].str));
		  (yyval.node) = 0;
               }
#line 6899 "CParse/parser.c"
    break;

  case 105: /* c_declaration: c_decl  */
#line 3234 "./CParse/parser.y"
                         {
                    (yyval.node) = (yyvsp[0].node); 
                    if ((yyval.node)) {
   		      add_symbols((yyval.node));
                      default_arguments((yyval.node));
   	            }
                }
#line 6911 "CParse/parser.c"
    break;

  case 108: /* $@3: %empty  */
#line 3246 "./CParse/parser.y"
                                       {
		  if (Strcmp((yyvsp[-1].str),"C") == 0) {
		    cparse_externc = 1;
		  }
		}
#line 6921 "CParse/parser.c"
    break;

  case 109: /* c_declaration: EXTERN string LBRACE $@3 interface RBRACE  */
#line 3250 "./CParse/parser.y"
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
#line 6955 "CParse/parser.c"
    break;

  case 110: /* c_declaration: cpp_lambda_decl  */
#line 3279 "./CParse/parser.y"
                                  {
		  (yyval.node) = (yyvsp[0].node);
		  SWIG_WARN_NODE_BEGIN((yyval.node));
		  Swig_warning(WARN_CPP11_LAMBDA, cparse_file, cparse_line, "Lambda expressions and closures are not fully supported yet.\n");
		  SWIG_WARN_NODE_END((yyval.node));
		}
#line 6966 "CParse/parser.c"
    break;

  case 111: /* c_declaration: USING idcolon EQUAL type plain_declarator SEMI  */
#line 3285 "./CParse/parser.y"
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
#line 6981 "CParse/parser.c"
    break;

  case 112: /* c_declaration: TEMPLATE LESSTHAN template_parms GREATERTHAN USING idcolon EQUAL type plain_declarator SEMI  */
#line 3295 "./CParse/parser.y"
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
#line 6998 "CParse/parser.c"
    break;

  case 114: /* c_decl: storage_class type declarator cpp_const initializer c_decl_tail  */
#line 3314 "./CParse/parser.y"
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
#line 7086 "CParse/parser.c"
    break;

  case 115: /* c_decl: storage_class type declarator cpp_const EQUAL error SEMI  */
#line 3397 "./CParse/parser.y"
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
#line 7137 "CParse/parser.c"
    break;

  case 116: /* c_decl: storage_class AUTO declarator cpp_const ARROW cpp_alternate_rettype virt_specifier_seq_opt initializer c_decl_tail  */
#line 3445 "./CParse/parser.y"
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
#line 7200 "CParse/parser.c"
    break;

  case 117: /* c_decl: storage_class AUTO declarator cpp_const LBRACE  */
#line 3510 "./CParse/parser.y"
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
#line 7246 "CParse/parser.c"
    break;

  case 118: /* c_decl: storage_class AUTO idcolon EQUAL definetype SEMI  */
#line 3552 "./CParse/parser.y"
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
#line 7267 "CParse/parser.c"
    break;

  case 119: /* c_decl: storage_class AUTO idcolon EQUAL error SEMI  */
#line 3569 "./CParse/parser.y"
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
#line 7283 "CParse/parser.c"
    break;

  case 120: /* c_decl_tail: SEMI  */
#line 3584 "./CParse/parser.y"
                      { 
                   (yyval.node) = 0;
                   Clear(scanner_ccode); 
               }
#line 7292 "CParse/parser.c"
    break;

  case 121: /* c_decl_tail: COMMA declarator cpp_const initializer c_decl_tail  */
#line 3588 "./CParse/parser.y"
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
#line 7324 "CParse/parser.c"
    break;

  case 122: /* c_decl_tail: LBRACE  */
#line 3615 "./CParse/parser.y"
                        { 
                   if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                   (yyval.node) = 0;
               }
#line 7333 "CParse/parser.c"
    break;

  case 123: /* c_decl_tail: error  */
#line 3619 "./CParse/parser.y"
                       {
		   (yyval.node) = 0;
		   if (yychar == RPAREN) {
		       Swig_error(cparse_file, cparse_line, "Unexpected closing parenthesis (')').\n");
		   } else {
		       Swig_error(cparse_file, cparse_line, "Syntax error - possibly a missing semicolon (';').\n");
		   }
		   Exit(EXIT_FAILURE);
               }
#line 7347 "CParse/parser.c"
    break;

  case 125: /* initializer: COLON expr  */
#line 3631 "./CParse/parser.y"
                           {
		(yyval.dtype) = default_dtype;
		(yyval.dtype).bitfield = (yyvsp[0].dtype).val;
	      }
#line 7356 "CParse/parser.c"
    break;

  case 129: /* cpp_alternate_rettype: c_enum_key idcolon  */
#line 3640 "./CParse/parser.y"
                                   {
		(yyval.type) = (yyvsp[0].str);
		Insert((yyval.type), 0, "enum ");
	      }
#line 7365 "CParse/parser.c"
    break;

  case 131: /* cpp_alternate_rettype: idcolon  */
#line 3645 "./CParse/parser.y"
                        { (yyval.type) = (yyvsp[0].str); }
#line 7371 "CParse/parser.c"
    break;

  case 132: /* cpp_alternate_rettype: idcolon AND  */
#line 3646 "./CParse/parser.y"
                            {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_reference((yyval.type));
              }
#line 7380 "CParse/parser.c"
    break;

  case 133: /* cpp_alternate_rettype: idcolon LAND  */
#line 3650 "./CParse/parser.y"
                             {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 7389 "CParse/parser.c"
    break;

  case 134: /* cpp_alternate_rettype: CONST_QUAL idcolon AND  */
#line 3654 "./CParse/parser.y"
                                       {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_reference((yyval.type));
              }
#line 7399 "CParse/parser.c"
    break;

  case 135: /* cpp_alternate_rettype: CONST_QUAL idcolon LAND  */
#line 3659 "./CParse/parser.y"
                                        {
                (yyval.type) = (yyvsp[-1].str);
                SwigType_add_qualifier((yyval.type), "const");
                SwigType_add_rvalue_reference((yyval.type));
              }
#line 7409 "CParse/parser.c"
    break;

  case 137: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template LPAREN parms RPAREN cpp_const lambda_body lambda_tail  */
#line 3675 "./CParse/parser.y"
                                                                                                                                           {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-9].str));
		  Delete((yyvsp[-11].str));
		  add_symbols((yyval.node));
	        }
#line 7420 "CParse/parser.c"
    break;

  case 138: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template LPAREN parms RPAREN cpp_const ARROW type lambda_body lambda_tail  */
#line 3681 "./CParse/parser.y"
                                                                                                                                                      {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-11].str));
		  Delete((yyvsp[-13].str));
		  add_symbols((yyval.node));
		}
#line 7431 "CParse/parser.c"
    break;

  case 139: /* cpp_lambda_decl: storage_class AUTO idcolon EQUAL lambda_introducer lambda_template lambda_body lambda_tail  */
#line 3687 "./CParse/parser.y"
                                                                                                             {
		  (yyval.node) = new_node("lambda");
		  Setattr((yyval.node),"name",(yyvsp[-5].str));
		  Delete((yyvsp[-7].str));
		  add_symbols((yyval.node));
		}
#line 7442 "CParse/parser.c"
    break;

  case 140: /* lambda_introducer: LBRACKET  */
#line 3695 "./CParse/parser.y"
                             {
		  if (skip_balanced('[',']') < 0) Exit(EXIT_FAILURE);
	        }
#line 7450 "CParse/parser.c"
    break;

  case 141: /* lambda_template: LESSTHAN  */
#line 3700 "./CParse/parser.y"
                           {
		  if (skip_balanced('<','>') < 0) Exit(EXIT_FAILURE);
		}
#line 7458 "CParse/parser.c"
    break;

  case 143: /* lambda_body: LBRACE  */
#line 3706 "./CParse/parser.y"
                     {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		}
#line 7466 "CParse/parser.c"
    break;

  case 145: /* $@4: %empty  */
#line 3711 "./CParse/parser.y"
                         {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		}
#line 7474 "CParse/parser.c"
    break;

  case 146: /* lambda_tail: LPAREN $@4 SEMI  */
#line 3713 "./CParse/parser.y"
                       {
		}
#line 7481 "CParse/parser.c"
    break;

  case 147: /* c_enum_key: ENUM  */
#line 3723 "./CParse/parser.y"
                  {
		   (yyval.id) = "enum";
	      }
#line 7489 "CParse/parser.c"
    break;

  case 148: /* c_enum_key: ENUM CLASS  */
#line 3726 "./CParse/parser.y"
                           {
		   (yyval.id) = "enum class";
	      }
#line 7497 "CParse/parser.c"
    break;

  case 149: /* c_enum_key: ENUM STRUCT  */
#line 3729 "./CParse/parser.y"
                            {
		   (yyval.id) = "enum struct";
	      }
#line 7505 "CParse/parser.c"
    break;

  case 150: /* c_enum_inherit: COLON type_right  */
#line 3738 "./CParse/parser.y"
                                  {
                   (yyval.type) = (yyvsp[0].type);
              }
#line 7513 "CParse/parser.c"
    break;

  case 151: /* c_enum_inherit: %empty  */
#line 3741 "./CParse/parser.y"
                       { (yyval.type) = 0; }
#line 7519 "CParse/parser.c"
    break;

  case 152: /* c_enum_forward_decl: storage_class c_enum_key ename c_enum_inherit SEMI  */
#line 3748 "./CParse/parser.y"
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
#line 7539 "CParse/parser.c"
    break;

  case 153: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE SEMI  */
#line 3771 "./CParse/parser.y"
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
#line 7573 "CParse/parser.c"
    break;

  case 154: /* c_enum_decl: storage_class c_enum_key ename c_enum_inherit LBRACE enumlist RBRACE declarator cpp_const initializer c_decl_tail  */
#line 3800 "./CParse/parser.y"
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
#line 7674 "CParse/parser.c"
    break;

  case 155: /* c_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 3898 "./CParse/parser.y"
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
#line 7730 "CParse/parser.c"
    break;

  case 162: /* @5: %empty  */
#line 3969 "./CParse/parser.y"
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
#line 7828 "CParse/parser.c"
    break;

  case 163: /* cpp_class_decl: storage_class cpptype idcolon class_virt_specifier_opt inherit LBRACE @5 cpp_members RBRACE cpp_opt_declarators  */
#line 4061 "./CParse/parser.y"
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
#line 7985 "CParse/parser.c"
    break;

  case 164: /* @6: %empty  */
#line 4216 "./CParse/parser.y"
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
#line 8033 "CParse/parser.c"
    break;

  case 165: /* cpp_class_decl: storage_class cpptype inherit LBRACE @6 cpp_members RBRACE cpp_opt_declarators  */
#line 4258 "./CParse/parser.y"
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
#line 8149 "CParse/parser.c"
    break;

  case 166: /* cpp_opt_declarators: SEMI  */
#line 4371 "./CParse/parser.y"
                            { (yyval.node) = 0; }
#line 8155 "CParse/parser.c"
    break;

  case 167: /* cpp_opt_declarators: declarator cpp_const initializer c_decl_tail  */
#line 4372 "./CParse/parser.y"
                                                                    {
                        (yyval.node) = new_node("cdecl");
                        Setattr((yyval.node),"name",(yyvsp[-3].decl).id);
                        Setattr((yyval.node),"decl",(yyvsp[-3].decl).type);
                        Setattr((yyval.node),"parms",(yyvsp[-3].decl).parms);
			set_nextSibling((yyval.node), (yyvsp[0].node));
                    }
#line 8167 "CParse/parser.c"
    break;

  case 168: /* cpp_forward_class_decl: storage_class cpptype idcolon SEMI  */
#line 4384 "./CParse/parser.y"
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
#line 8185 "CParse/parser.c"
    break;

  case 169: /* $@7: %empty  */
#line 4403 "./CParse/parser.y"
                                                                 { 
		    if (currentOuterClass)
		      Setattr(currentOuterClass, "template_parameters", template_parameters);
		    template_parameters = (yyvsp[-1].tparms); 
		    parsing_template_declaration = 1;
		  }
#line 8196 "CParse/parser.c"
    break;

  case 170: /* cpp_template_decl: TEMPLATE LESSTHAN template_parms GREATERTHAN $@7 cpp_template_possible  */
#line 4408 "./CParse/parser.y"
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
#line 8398 "CParse/parser.c"
    break;

  case 171: /* cpp_template_decl: TEMPLATE cpptype idcolon  */
#line 4607 "./CParse/parser.y"
                                           {
		  Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8407 "CParse/parser.c"
    break;

  case 172: /* cpp_template_decl: TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN  */
#line 4613 "./CParse/parser.y"
                                                                             {
			Swig_warning(WARN_PARSE_EXPLICIT_TEMPLATE, cparse_file, cparse_line, "Explicit template instantiation ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8416 "CParse/parser.c"
    break;

  case 173: /* cpp_template_decl: EXTERN TEMPLATE cpptype idcolon  */
#line 4619 "./CParse/parser.y"
                                                  {
		  Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
                }
#line 8425 "CParse/parser.c"
    break;

  case 174: /* cpp_template_decl: EXTERN TEMPLATE cpp_alternate_rettype idcolon LPAREN parms RPAREN  */
#line 4625 "./CParse/parser.y"
                                                                                    {
			Swig_warning(WARN_PARSE_EXTERN_TEMPLATE, cparse_file, cparse_line, "Extern template ignored.\n");
                  (yyval.node) = 0; 
		}
#line 8434 "CParse/parser.c"
    break;

  case 178: /* cpp_template_possible: cpp_template_decl  */
#line 4634 "./CParse/parser.y"
                                    {
		  (yyval.node) = 0;
                }
#line 8442 "CParse/parser.c"
    break;

  case 181: /* template_parms: template_parms_builder  */
#line 4641 "./CParse/parser.y"
                                        {
		 (yyval.tparms) = (yyvsp[0].pbuilder).parms;
	       }
#line 8450 "CParse/parser.c"
    break;

  case 182: /* template_parms: %empty  */
#line 4644 "./CParse/parser.y"
                        {
		 (yyval.tparms) = 0;
	       }
#line 8458 "CParse/parser.c"
    break;

  case 183: /* template_parms_builder: templateparameter  */
#line 4649 "./CParse/parser.y"
                                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 8466 "CParse/parser.c"
    break;

  case 184: /* template_parms_builder: template_parms_builder COMMA templateparameter  */
#line 4652 "./CParse/parser.y"
                                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 8480 "CParse/parser.c"
    break;

  case 185: /* templateparameter: templcpptype def_args  */
#line 4663 "./CParse/parser.y"
                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo((yyvsp[-1].type), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		    if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
		  }
#line 8493 "CParse/parser.c"
    break;

  case 186: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype idcolon def_args  */
#line 4671 "./CParse/parser.y"
                                                                                          {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s %s", ParmList_str_defaultargs((yyvsp[-4].tparms)), (yyvsp[-2].type), (yyvsp[-1].str)), (yyvsp[-1].str));
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 8506 "CParse/parser.c"
    break;

  case 187: /* templateparameter: TEMPLATE LESSTHAN template_parms GREATERTHAN cpptype def_args  */
#line 4679 "./CParse/parser.y"
                                                                                  {
		    (yyval.p) = NewParmWithoutFileLineInfo(NewStringf("template< %s > %s", ParmList_str_defaultargs((yyvsp[-3].tparms)), (yyvsp[-1].type)), 0);
		    Setfile((yyval.p), cparse_file);
		    Setline((yyval.p), cparse_line);
		    if ((yyvsp[0].dtype).val) {
		      Setattr((yyval.p), "value", (yyvsp[0].dtype).val);
		    }
		  }
#line 8519 "CParse/parser.c"
    break;

  case 188: /* templateparameter: parm  */
#line 4687 "./CParse/parser.y"
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
#line 8545 "CParse/parser.c"
    break;

  case 189: /* cpp_using_decl: USING idcolon SEMI  */
#line 4712 "./CParse/parser.y"
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
#line 8561 "CParse/parser.c"
    break;

  case 190: /* cpp_using_decl: USING TYPENAME idcolon SEMI  */
#line 4723 "./CParse/parser.y"
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
#line 8576 "CParse/parser.c"
    break;

  case 191: /* cpp_using_decl: USING NAMESPACE idcolon SEMI  */
#line 4733 "./CParse/parser.y"
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
#line 8610 "CParse/parser.c"
    break;

  case 192: /* @8: %empty  */
#line 4764 "./CParse/parser.y"
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
#line 8659 "CParse/parser.c"
    break;

  case 193: /* cpp_namespace_decl: NAMESPACE idcolon LBRACE @8 interface RBRACE  */
#line 4807 "./CParse/parser.y"
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
#line 8679 "CParse/parser.c"
    break;

  case 194: /* @9: %empty  */
#line 4822 "./CParse/parser.y"
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
#line 8697 "CParse/parser.c"
    break;

  case 195: /* cpp_namespace_decl: NAMESPACE LBRACE @9 interface RBRACE  */
#line 4834 "./CParse/parser.y"
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
#line 8712 "CParse/parser.c"
    break;

  case 196: /* cpp_namespace_decl: NAMESPACE identifier EQUAL idcolon SEMI  */
#line 4844 "./CParse/parser.y"
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
#line 8742 "CParse/parser.c"
    break;

  case 197: /* cpp_members: cpp_members_builder  */
#line 4871 "./CParse/parser.y"
                                  {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 8750 "CParse/parser.c"
    break;

  case 198: /* cpp_members: cpp_members_builder DOXYGENSTRING  */
#line 4874 "./CParse/parser.y"
                                                   {
		 /* Quietly ignore misplaced doxygen string after a member, like Doxygen does */
		 (yyval.node) = (yyvsp[-1].nodebuilder).node;
		 Delete((yyvsp[0].str));
	       }
#line 8760 "CParse/parser.c"
    break;

  case 199: /* cpp_members: %empty  */
#line 4879 "./CParse/parser.y"
                        {
		 (yyval.node) = 0;
	       }
#line 8768 "CParse/parser.c"
    break;

  case 200: /* cpp_members: DOXYGENSTRING  */
#line 4882 "./CParse/parser.y"
                               {
		 /* Quietly ignore misplaced doxygen string in empty class, like Doxygen does */
		 (yyval.node) = 0;
		 Delete((yyvsp[0].str));
	       }
#line 8778 "CParse/parser.c"
    break;

  case 201: /* cpp_members: error  */
#line 4887 "./CParse/parser.y"
                       {
		 Swig_error(cparse_file, cparse_line, "Syntax error in input(3).\n");
		 Exit(EXIT_FAILURE);
	       }
#line 8787 "CParse/parser.c"
    break;

  case 202: /* cpp_members_builder: cpp_member  */
#line 4893 "./CParse/parser.y"
                                 {
	     (yyval.nodebuilder).node = (yyval.nodebuilder).last = (yyvsp[0].node);
	   }
#line 8795 "CParse/parser.c"
    break;

  case 203: /* cpp_members_builder: cpp_members_builder cpp_member  */
#line 4896 "./CParse/parser.y"
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
#line 8822 "CParse/parser.c"
    break;

  case 205: /* cpp_member_no_dox: cpp_constructor_decl  */
#line 4927 "./CParse/parser.y"
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
#line 8844 "CParse/parser.c"
    break;

  case 212: /* cpp_member_no_dox: storage_class idcolon SEMI  */
#line 4950 "./CParse/parser.y"
                                          { (yyval.node) = 0; Delete((yyvsp[-2].str)); }
#line 8850 "CParse/parser.c"
    break;

  case 219: /* cpp_member_no_dox: anonymous_bitfield  */
#line 4957 "./CParse/parser.y"
                                  { (yyval.node) = 0; }
#line 8856 "CParse/parser.c"
    break;

  case 222: /* cpp_member_no_dox: SEMI  */
#line 4960 "./CParse/parser.y"
                    { (yyval.node) = 0; }
#line 8862 "CParse/parser.c"
    break;

  case 224: /* cpp_member: DOXYGENSTRING cpp_member_no_dox  */
#line 4963 "./CParse/parser.y"
                                               {
	         (yyval.node) = (yyvsp[0].node);
		 set_comment((yyvsp[0].node), (yyvsp[-1].str));
	     }
#line 8871 "CParse/parser.c"
    break;

  case 225: /* cpp_member: cpp_member_no_dox DOXYGENPOSTSTRING  */
#line 4967 "./CParse/parser.y"
                                                   {
	         (yyval.node) = (yyvsp[-1].node);
		 set_comment((yyvsp[-1].node), (yyvsp[0].str));
	     }
#line 8880 "CParse/parser.c"
    break;

  case 226: /* $@10: %empty  */
#line 4971 "./CParse/parser.y"
                             {
	       extendmode = 1;
	       if (cplus_mode != CPLUS_PUBLIC) {
		 Swig_error(cparse_file,cparse_line,"%%extend can only be used in a public section\n");
	       }
	     }
#line 8891 "CParse/parser.c"
    break;

  case 227: /* cpp_member: EXTEND LBRACE $@10 cpp_members RBRACE  */
#line 4976 "./CParse/parser.y"
                                  {
	       extendmode = 0;
	       (yyval.node) = new_node("extend");
	       mark_nodes_as_extend((yyvsp[-1].node));
	       appendChild((yyval.node), (yyvsp[-1].node));
	     }
#line 8902 "CParse/parser.c"
    break;

  case 228: /* cpp_constructor_decl: storage_class type LPAREN parms RPAREN ctor_end  */
#line 4990 "./CParse/parser.y"
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
#line 8941 "CParse/parser.c"
    break;

  case 229: /* cpp_destructor_decl: storage_class NOT idtemplate LPAREN parms RPAREN cpp_vend  */
#line 5028 "./CParse/parser.y"
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
#line 8983 "CParse/parser.c"
    break;

  case 230: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer LPAREN parms RPAREN cpp_vend  */
#line 5069 "./CParse/parser.y"
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
#line 9009 "CParse/parser.c"
    break;

  case 231: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type AND LPAREN parms RPAREN cpp_vend  */
#line 5090 "./CParse/parser.y"
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
#line 9037 "CParse/parser.c"
    break;

  case 232: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LAND LPAREN parms RPAREN cpp_vend  */
#line 5113 "./CParse/parser.y"
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
#line 9065 "CParse/parser.c"
    break;

  case 233: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type pointer AND LPAREN parms RPAREN cpp_vend  */
#line 5137 "./CParse/parser.y"
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
#line 9094 "CParse/parser.c"
    break;

  case 234: /* cpp_conversion_operator: storage_class CONVERSIONOPERATOR type LPAREN parms RPAREN cpp_vend  */
#line 5162 "./CParse/parser.y"
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
#line 9120 "CParse/parser.c"
    break;

  case 235: /* cpp_catch_decl: CATCH LPAREN parms RPAREN LBRACE  */
#line 5187 "./CParse/parser.y"
                                                  {
                 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                 (yyval.node) = 0;
               }
#line 9129 "CParse/parser.c"
    break;

  case 236: /* cpp_static_assert: STATIC_ASSERT LPAREN  */
#line 5195 "./CParse/parser.y"
                                         {
                if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
                (yyval.node) = 0;
              }
#line 9138 "CParse/parser.c"
    break;

  case 237: /* cpp_protection_decl: PUBLIC COLON  */
#line 5202 "./CParse/parser.y"
                                   { 
                (yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","public");
                cplus_mode = CPLUS_PUBLIC;
              }
#line 9148 "CParse/parser.c"
    break;

  case 238: /* cpp_protection_decl: PRIVATE COLON  */
#line 5209 "./CParse/parser.y"
                              { 
                (yyval.node) = new_node("access");
                Setattr((yyval.node),"kind","private");
		cplus_mode = CPLUS_PRIVATE;
	      }
#line 9158 "CParse/parser.c"
    break;

  case 239: /* cpp_protection_decl: PROTECTED COLON  */
#line 5217 "./CParse/parser.y"
                                { 
		(yyval.node) = new_node("access");
		Setattr((yyval.node),"kind","protected");
		cplus_mode = CPLUS_PROTECTED;
	      }
#line 9168 "CParse/parser.c"
    break;

  case 250: /* cpp_vend: cpp_const SEMI  */
#line 5240 "./CParse/parser.y"
                                { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 9177 "CParse/parser.c"
    break;

  case 251: /* cpp_vend: cpp_const EQUAL definetype SEMI  */
#line 5244 "./CParse/parser.y"
                                                 { 
                     Clear(scanner_ccode);
                     (yyval.dtype) = (yyvsp[-3].dtype);
                     (yyval.dtype).val = (yyvsp[-1].dtype).val;
               }
#line 9187 "CParse/parser.c"
    break;

  case 252: /* cpp_vend: cpp_const LBRACE  */
#line 5249 "./CParse/parser.y"
                                  { 
                     if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
                     (yyval.dtype) = (yyvsp[-1].dtype);
               }
#line 9196 "CParse/parser.c"
    break;

  case 253: /* anonymous_bitfield: storage_class anon_bitfield_type COLON expr SEMI  */
#line 5256 "./CParse/parser.y"
                                                                       { Delete((yyvsp[-4].str)); }
#line 9202 "CParse/parser.c"
    break;

  case 258: /* anon_bitfield_type: idcolon  */
#line 5264 "./CParse/parser.y"
                         { (yyval.type) = (yyvsp[0].str); }
#line 9208 "CParse/parser.c"
    break;

  case 259: /* storage_class: storage_class_list  */
#line 5270 "./CParse/parser.y"
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
#line 9255 "CParse/parser.c"
    break;

  case 260: /* storage_class: %empty  */
#line 5312 "./CParse/parser.y"
                        { (yyval.str) = 0; }
#line 9261 "CParse/parser.c"
    break;

  case 262: /* storage_class_list: storage_class_list storage_class_raw  */
#line 5316 "./CParse/parser.y"
                                                          {
		  if ((yyvsp[-1].intvalue) & (yyvsp[0].intvalue)) {
		    Swig_error(cparse_file, cparse_line, "Repeated storage class or type specifier '%s'\n", storage_class_string((yyvsp[0].intvalue)));
		  }
		  (yyval.intvalue) = (yyvsp[-1].intvalue) | (yyvsp[0].intvalue);
	       }
#line 9272 "CParse/parser.c"
    break;

  case 263: /* storage_class_raw: EXTERN  */
#line 5324 "./CParse/parser.y"
                            { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXTERN; }
#line 9278 "CParse/parser.c"
    break;

  case 264: /* storage_class_raw: EXTERN string  */
#line 5325 "./CParse/parser.y"
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
#line 9293 "CParse/parser.c"
    break;

  case 265: /* storage_class_raw: STATIC  */
#line 5335 "./CParse/parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_STATIC; }
#line 9299 "CParse/parser.c"
    break;

  case 266: /* storage_class_raw: TYPEDEF  */
#line 5336 "./CParse/parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_TYPEDEF; }
#line 9305 "CParse/parser.c"
    break;

  case 267: /* storage_class_raw: VIRTUAL  */
#line 5337 "./CParse/parser.y"
                         { (yyval.intvalue) = SWIG_STORAGE_CLASS_VIRTUAL; }
#line 9311 "CParse/parser.c"
    break;

  case 268: /* storage_class_raw: FRIEND  */
#line 5338 "./CParse/parser.y"
                        { (yyval.intvalue) = SWIG_STORAGE_CLASS_FRIEND; }
#line 9317 "CParse/parser.c"
    break;

  case 269: /* storage_class_raw: EXPLICIT  */
#line 5339 "./CParse/parser.y"
                          { (yyval.intvalue) = SWIG_STORAGE_CLASS_EXPLICIT; }
#line 9323 "CParse/parser.c"
    break;

  case 270: /* storage_class_raw: CONSTEXPR  */
#line 5340 "./CParse/parser.y"
                           { (yyval.intvalue) = SWIG_STORAGE_CLASS_CONSTEXPR; }
#line 9329 "CParse/parser.c"
    break;

  case 271: /* storage_class_raw: THREAD_LOCAL  */
#line 5341 "./CParse/parser.y"
                              { (yyval.intvalue) = SWIG_STORAGE_CLASS_THREAD_LOCAL; }
#line 9335 "CParse/parser.c"
    break;

  case 272: /* parms: rawparms  */
#line 5348 "./CParse/parser.y"
                          {
                 Parm *p;
		 (yyval.pl) = (yyvsp[0].pl);
		 p = (yyvsp[0].pl);
                 while (p) {
		   Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   p = nextSibling(p);
                 }
               }
#line 9349 "CParse/parser.c"
    break;

  case 273: /* rawparms: parm  */
#line 5360 "./CParse/parser.y"
                       { (yyval.pl) = (yyvsp[0].p); }
#line 9355 "CParse/parser.c"
    break;

  case 274: /* rawparms: parm DOXYGENPOSTSTRING  */
#line 5361 "./CParse/parser.y"
                                         {
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 9364 "CParse/parser.c"
    break;

  case 275: /* rawparms: parm DOXYGENSTRING  */
#line 5365 "./CParse/parser.y"
                                     {
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].p), (yyvsp[0].str));
		  (yyval.pl) = (yyvsp[-1].p);
		}
#line 9374 "CParse/parser.c"
    break;

  case 276: /* rawparms: parm COMMA parms  */
#line 5370 "./CParse/parser.y"
                                   {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-2].p), (yyvsp[0].pl));
		  }
		  (yyval.pl) = (yyvsp[-2].p);
		}
#line 9385 "CParse/parser.c"
    break;

  case 277: /* rawparms: parm DOXYGENPOSTSTRING COMMA parms  */
#line 5376 "./CParse/parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-2].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 9397 "CParse/parser.c"
    break;

  case 278: /* rawparms: parm COMMA DOXYGENPOSTSTRING parms  */
#line 5383 "./CParse/parser.y"
                                                     {
		  if ((yyvsp[0].pl)) {
		    set_nextSibling((yyvsp[-3].p), (yyvsp[0].pl));
		  }
		  set_comment((yyvsp[-3].p), (yyvsp[-1].str));
		  (yyval.pl) = (yyvsp[-3].p);
		}
#line 9409 "CParse/parser.c"
    break;

  case 279: /* rawparms: %empty  */
#line 5390 "./CParse/parser.y"
                         {
		  (yyval.pl) = 0;
		}
#line 9417 "CParse/parser.c"
    break;

  case 280: /* parm_no_dox: rawtype parameter_declarator  */
#line 5395 "./CParse/parser.y"
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
#line 9434 "CParse/parser.c"
    break;

  case 281: /* parm_no_dox: ELLIPSIS  */
#line 5407 "./CParse/parser.y"
                           {
		  SwigType *t = NewString("v(...)");
		  (yyval.p) = NewParmWithoutFileLineInfo(t, 0);
		  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		}
#line 9445 "CParse/parser.c"
    break;

  case 283: /* parm: DOXYGENSTRING parm_no_dox  */
#line 5416 "./CParse/parser.y"
                                            {
		  (yyval.p) = (yyvsp[0].p);
		  set_comment((yyvsp[0].p), (yyvsp[-1].str));
		}
#line 9454 "CParse/parser.c"
    break;

  case 284: /* valparms: valparms_builder  */
#line 5422 "./CParse/parser.y"
                            {
		 (yyval.p) = (yyvsp[0].pbuilder).parms;
                 for (Parm *p = (yyval.p); p; p = nextSibling(p)) {
		   if (Getattr(p,"type")) {
		     Replace(Getattr(p,"type"),"typename ", "", DOH_REPLACE_ANY);
		   }
                 }
	       }
#line 9467 "CParse/parser.c"
    break;

  case 285: /* valparms: %empty  */
#line 5430 "./CParse/parser.y"
                        {
		 (yyval.p) = 0;
	       }
#line 9475 "CParse/parser.c"
    break;

  case 286: /* valparms_builder: valparm  */
#line 5435 "./CParse/parser.y"
                           {
		    (yyval.pbuilder).parms = (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9483 "CParse/parser.c"
    break;

  case 287: /* valparms_builder: valparms_builder COMMA valparm  */
#line 5438 "./CParse/parser.y"
                                                       {
		    // Build a linked list in the order specified, but avoiding
		    // a right recursion rule because "Right recursion uses up
		    // space on the Bison stack in proportion to the number of
		    // elements in the sequence".
		    set_nextSibling((yyvsp[-2].pbuilder).last, (yyvsp[0].p));
		    (yyval.pbuilder).parms = (yyvsp[-2].pbuilder).parms;
		    (yyval.pbuilder).last = (yyvsp[0].p);
		  }
#line 9497 "CParse/parser.c"
    break;

  case 288: /* valparm: parm  */
#line 5449 "./CParse/parser.y"
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
#line 9530 "CParse/parser.c"
    break;

  case 289: /* valparm: valexpr  */
#line 5477 "./CParse/parser.y"
                         {
                  (yyval.p) = NewParmWithoutFileLineInfo(0,0);
                  Setfile((yyval.p),cparse_file);
		  Setline((yyval.p),cparse_line);
		  Setattr((yyval.p),"value",(yyvsp[0].dtype).val);
		  if ((yyvsp[0].dtype).stringval) Setattr((yyval.p), "stringval", (yyvsp[0].dtype).stringval);
		  if ((yyvsp[0].dtype).numval) Setattr((yyval.p), "numval", (yyvsp[0].dtype).numval);
               }
#line 9543 "CParse/parser.c"
    break;

  case 290: /* def_args: EQUAL definetype  */
#line 5487 "./CParse/parser.y"
                                  { 
                 (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 9551 "CParse/parser.c"
    break;

  case 291: /* def_args: EQUAL definetype LBRACKET  */
#line 5490 "./CParse/parser.y"
                                           {
		 if (skip_balanced('[', ']') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).type = T_UNKNOWN;
		 (yyval.dtype).val = (yyvsp[-1].dtype).val;
		 Append((yyval.dtype).val, scanner_ccode);
		 Clear(scanner_ccode);
               }
#line 9564 "CParse/parser.c"
    break;

  case 292: /* def_args: EQUAL LBRACE  */
#line 5498 "./CParse/parser.y"
                              {
		 if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewString(scanner_ccode);
		 (yyval.dtype).type = T_UNKNOWN;
	       }
#line 9575 "CParse/parser.c"
    break;

  case 293: /* def_args: %empty  */
#line 5504 "./CParse/parser.y"
                        {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).type = T_UNKNOWN;
               }
#line 9584 "CParse/parser.c"
    break;

  case 294: /* parameter_declarator: declarator def_args  */
#line 5510 "./CParse/parser.y"
                                           {
                 (yyval.decl) = (yyvsp[-1].decl);
		 (yyval.decl).defarg = (yyvsp[0].dtype).val;
		 (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
		 (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9595 "CParse/parser.c"
    break;

  case 295: /* parameter_declarator: abstract_declarator def_args  */
#line 5516 "./CParse/parser.y"
                                           {
	      (yyval.decl) = (yyvsp[-1].decl);
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9606 "CParse/parser.c"
    break;

  case 296: /* parameter_declarator: def_args  */
#line 5522 "./CParse/parser.y"
                       {
	      (yyval.decl) = default_decl;
	      (yyval.decl).defarg = (yyvsp[0].dtype).val;
	      (yyval.decl).stringdefarg = (yyvsp[0].dtype).stringval;
	      (yyval.decl).numdefarg = (yyvsp[0].dtype).numval;
            }
#line 9617 "CParse/parser.c"
    break;

  case 297: /* parameter_declarator: direct_declarator LPAREN parms RPAREN qualifiers_exception_specification  */
#line 5530 "./CParse/parser.y"
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
#line 9643 "CParse/parser.c"
    break;

  case 298: /* plain_declarator: declarator  */
#line 5553 "./CParse/parser.y"
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
#line 9665 "CParse/parser.c"
    break;

  case 299: /* plain_declarator: abstract_declarator  */
#line 5570 "./CParse/parser.y"
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
#line 9687 "CParse/parser.c"
    break;

  case 300: /* plain_declarator: direct_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 5589 "./CParse/parser.y"
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
#line 9711 "CParse/parser.c"
    break;

  case 301: /* plain_declarator: %empty  */
#line 5608 "./CParse/parser.y"
                     {
	      (yyval.decl) = default_decl;
	    }
#line 9719 "CParse/parser.c"
    break;

  case 302: /* declarator: pointer notso_direct_declarator  */
#line 5613 "./CParse/parser.y"
                                              {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-1].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-1].type);
           }
#line 9732 "CParse/parser.c"
    break;

  case 303: /* declarator: pointer AND notso_direct_declarator  */
#line 5621 "./CParse/parser.y"
                                                 {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 9746 "CParse/parser.c"
    break;

  case 304: /* declarator: pointer LAND notso_direct_declarator  */
#line 5630 "./CParse/parser.y"
                                                  {
              (yyval.decl) = (yyvsp[0].decl);
	      SwigType_add_rvalue_reference((yyvsp[-2].type));
              if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
           }
#line 9760 "CParse/parser.c"
    break;

  case 305: /* declarator: direct_declarator  */
#line 5639 "./CParse/parser.y"
                               {
              (yyval.decl) = (yyvsp[0].decl);
	      if (!(yyval.decl).type) (yyval.decl).type = NewStringEmpty();
           }
#line 9769 "CParse/parser.c"
    break;

  case 306: /* declarator: AND notso_direct_declarator  */
#line 5643 "./CParse/parser.y"
                                         {
	     (yyval.decl) = (yyvsp[0].decl);
	     (yyval.decl).type = NewStringEmpty();
	     SwigType_add_reference((yyval.decl).type);
	     if ((yyvsp[0].decl).type) {
	       SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
	       Delete((yyvsp[0].decl).type);
	     }
           }
#line 9783 "CParse/parser.c"
    break;

  case 307: /* declarator: LAND notso_direct_declarator  */
#line 5652 "./CParse/parser.y"
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
#line 9799 "CParse/parser.c"
    break;

  case 308: /* declarator: idcolon DSTAR notso_direct_declarator  */
#line 5663 "./CParse/parser.y"
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
#line 9815 "CParse/parser.c"
    break;

  case 309: /* declarator: pointer idcolon DSTAR notso_direct_declarator  */
#line 5674 "./CParse/parser.y"
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
#line 9832 "CParse/parser.c"
    break;

  case 310: /* declarator: pointer idcolon DSTAR AND notso_direct_declarator  */
#line 5686 "./CParse/parser.y"
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
#line 9847 "CParse/parser.c"
    break;

  case 311: /* declarator: idcolon DSTAR AND notso_direct_declarator  */
#line 5696 "./CParse/parser.y"
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
#line 9863 "CParse/parser.c"
    break;

  case 312: /* declarator: pointer ELLIPSIS notso_direct_declarator  */
#line 5710 "./CParse/parser.y"
                                                       {
              (yyval.decl) = (yyvsp[0].decl);
	      if ((yyval.decl).type) {
		SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		Delete((yyval.decl).type);
	      }
	      (yyval.decl).type = (yyvsp[-2].type);
	      SwigType_add_variadic((yyval.decl).type);
           }
#line 9877 "CParse/parser.c"
    break;

  case 313: /* declarator: pointer AND ELLIPSIS notso_direct_declarator  */
#line 5719 "./CParse/parser.y"
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
#line 9892 "CParse/parser.c"
    break;

  case 314: /* declarator: pointer LAND ELLIPSIS notso_direct_declarator  */
#line 5729 "./CParse/parser.y"
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
#line 9907 "CParse/parser.c"
    break;

  case 315: /* declarator: AND ELLIPSIS notso_direct_declarator  */
#line 5739 "./CParse/parser.y"
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
#line 9922 "CParse/parser.c"
    break;

  case 316: /* declarator: LAND ELLIPSIS notso_direct_declarator  */
#line 5749 "./CParse/parser.y"
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
#line 9939 "CParse/parser.c"
    break;

  case 317: /* declarator: idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 5761 "./CParse/parser.y"
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
#line 9956 "CParse/parser.c"
    break;

  case 318: /* declarator: pointer idcolon DSTAR ELLIPSIS notso_direct_declarator  */
#line 5773 "./CParse/parser.y"
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
#line 9974 "CParse/parser.c"
    break;

  case 319: /* declarator: pointer idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 5786 "./CParse/parser.y"
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
#line 9990 "CParse/parser.c"
    break;

  case 320: /* declarator: pointer idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 5797 "./CParse/parser.y"
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
#line 10006 "CParse/parser.c"
    break;

  case 321: /* declarator: idcolon DSTAR AND ELLIPSIS notso_direct_declarator  */
#line 5808 "./CParse/parser.y"
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
#line 10023 "CParse/parser.c"
    break;

  case 322: /* declarator: idcolon DSTAR LAND ELLIPSIS notso_direct_declarator  */
#line 5820 "./CParse/parser.y"
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
#line 10040 "CParse/parser.c"
    break;

  case 323: /* notso_direct_declarator: idcolon  */
#line 5834 "./CParse/parser.y"
                                  {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 10050 "CParse/parser.c"
    break;

  case 324: /* notso_direct_declarator: NOT idcolon  */
#line 5839 "./CParse/parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 10059 "CParse/parser.c"
    break;

  case 325: /* notso_direct_declarator: LPAREN idcolon RPAREN  */
#line 5845 "./CParse/parser.y"
                                         {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char((yyvsp[-1].str));
                  }
#line 10068 "CParse/parser.c"
    break;

  case 326: /* notso_direct_declarator: LPAREN pointer notso_direct_declarator RPAREN  */
#line 5857 "./CParse/parser.y"
                                                                      {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10081 "CParse/parser.c"
    break;

  case 327: /* notso_direct_declarator: LPAREN idcolon DSTAR notso_direct_declarator RPAREN  */
#line 5865 "./CParse/parser.y"
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
#line 10097 "CParse/parser.c"
    break;

  case 328: /* notso_direct_declarator: notso_direct_declarator LBRACKET RBRACKET  */
#line 5876 "./CParse/parser.y"
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
#line 10113 "CParse/parser.c"
    break;

  case 329: /* notso_direct_declarator: notso_direct_declarator LBRACKET expr RBRACKET  */
#line 5887 "./CParse/parser.y"
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
#line 10129 "CParse/parser.c"
    break;

  case 330: /* notso_direct_declarator: notso_direct_declarator LPAREN parms RPAREN  */
#line 5898 "./CParse/parser.y"
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
#line 10151 "CParse/parser.c"
    break;

  case 331: /* direct_declarator: idcolon  */
#line 5917 "./CParse/parser.y"
                            {
                /* Note: This is non-standard C.  Template declarator is allowed to follow an identifier */
		 (yyval.decl) = default_decl;
                 (yyval.decl).id = Char((yyvsp[0].str));
                  }
#line 10161 "CParse/parser.c"
    break;

  case 332: /* direct_declarator: NOT idcolon  */
#line 5923 "./CParse/parser.y"
                                {
		  (yyval.decl) = default_decl;
                  (yyval.decl).id = Char(NewStringf("~%s",(yyvsp[0].str)));
                  }
#line 10170 "CParse/parser.c"
    break;

  case 333: /* direct_declarator: LPAREN pointer direct_declarator RPAREN  */
#line 5936 "./CParse/parser.y"
                                                                {
		    (yyval.decl) = (yyvsp[-1].decl);
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10183 "CParse/parser.c"
    break;

  case 334: /* direct_declarator: LPAREN AND direct_declarator RPAREN  */
#line 5944 "./CParse/parser.y"
                                                            {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_reference((yyval.decl).type);
                  }
#line 10195 "CParse/parser.c"
    break;

  case 335: /* direct_declarator: LPAREN LAND direct_declarator RPAREN  */
#line 5951 "./CParse/parser.y"
                                                             {
                    (yyval.decl) = (yyvsp[-1].decl);
		    if (!(yyval.decl).type) {
		      (yyval.decl).type = NewStringEmpty();
		    }
		    SwigType_add_rvalue_reference((yyval.decl).type);
                  }
#line 10207 "CParse/parser.c"
    break;

  case 336: /* direct_declarator: LPAREN idcolon DSTAR declarator RPAREN  */
#line 5958 "./CParse/parser.y"
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
#line 10223 "CParse/parser.c"
    break;

  case 337: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier declarator RPAREN  */
#line 5969 "./CParse/parser.y"
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
#line 10240 "CParse/parser.c"
    break;

  case 338: /* direct_declarator: LPAREN idcolon DSTAR abstract_declarator RPAREN  */
#line 5981 "./CParse/parser.y"
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
#line 10256 "CParse/parser.c"
    break;

  case 339: /* direct_declarator: LPAREN idcolon DSTAR type_qualifier abstract_declarator RPAREN  */
#line 5992 "./CParse/parser.y"
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
#line 10273 "CParse/parser.c"
    break;

  case 340: /* direct_declarator: direct_declarator LBRACKET RBRACKET  */
#line 6004 "./CParse/parser.y"
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
#line 10289 "CParse/parser.c"
    break;

  case 341: /* direct_declarator: direct_declarator LBRACKET expr RBRACKET  */
#line 6015 "./CParse/parser.y"
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
#line 10305 "CParse/parser.c"
    break;

  case 342: /* direct_declarator: direct_declarator LPAREN parms RPAREN  */
#line 6026 "./CParse/parser.y"
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
#line 10327 "CParse/parser.c"
    break;

  case 343: /* direct_declarator: OPERATOR ID LPAREN parms RPAREN  */
#line 6046 "./CParse/parser.y"
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
#line 10344 "CParse/parser.c"
    break;

  case 344: /* abstract_declarator: pointer variadic_opt  */
#line 6060 "./CParse/parser.y"
                                           {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-1].type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10354 "CParse/parser.c"
    break;

  case 345: /* abstract_declarator: pointer direct_abstract_declarator  */
#line 6065 "./CParse/parser.y"
                                                       { 
                     (yyval.decl) = (yyvsp[0].decl);
                     SwigType_push((yyvsp[-1].type),(yyvsp[0].decl).type);
		     (yyval.decl).type = (yyvsp[-1].type);
		     Delete((yyvsp[0].decl).type);
                  }
#line 10365 "CParse/parser.c"
    break;

  case 346: /* abstract_declarator: pointer AND variadic_opt  */
#line 6071 "./CParse/parser.y"
                                             {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 10376 "CParse/parser.c"
    break;

  case 347: /* abstract_declarator: pointer LAND variadic_opt  */
#line 6077 "./CParse/parser.y"
                                              {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
		  }
#line 10387 "CParse/parser.c"
    break;

  case 348: /* abstract_declarator: pointer AND direct_abstract_declarator  */
#line 6083 "./CParse/parser.y"
                                                           {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10401 "CParse/parser.c"
    break;

  case 349: /* abstract_declarator: pointer LAND direct_abstract_declarator  */
#line 6092 "./CParse/parser.y"
                                                            {
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_rvalue_reference((yyvsp[-2].type));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-2].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-2].type);
                  }
#line 10415 "CParse/parser.c"
    break;

  case 351: /* abstract_declarator: AND direct_abstract_declarator  */
#line 6102 "./CParse/parser.y"
                                                   {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 10429 "CParse/parser.c"
    break;

  case 352: /* abstract_declarator: LAND direct_abstract_declarator  */
#line 6111 "./CParse/parser.y"
                                                    {
		    (yyval.decl) = (yyvsp[0].decl);
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].decl).type) {
		      SwigType_push((yyval.decl).type,(yyvsp[0].decl).type);
		      Delete((yyvsp[0].decl).type);
		    }
                  }
#line 10443 "CParse/parser.c"
    break;

  case 353: /* abstract_declarator: AND variadic_opt  */
#line 6120 "./CParse/parser.y"
                                     {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10454 "CParse/parser.c"
    break;

  case 354: /* abstract_declarator: LAND variadic_opt  */
#line 6126 "./CParse/parser.y"
                                      {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_rvalue_reference((yyval.decl).type);
		    if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.decl).type);
                  }
#line 10465 "CParse/parser.c"
    break;

  case 355: /* abstract_declarator: idcolon DSTAR  */
#line 6132 "./CParse/parser.y"
                                  { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_memberpointer((yyval.decl).type,(yyvsp[-1].str));
      	          }
#line 10475 "CParse/parser.c"
    break;

  case 356: /* abstract_declarator: idcolon DSTAR type_qualifier  */
#line 6137 "./CParse/parser.y"
                                                 {
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_memberpointer((yyval.decl).type, (yyvsp[-2].str));
		    SwigType_push((yyval.decl).type, (yyvsp[0].str));
		  }
#line 10486 "CParse/parser.c"
    break;

  case 357: /* abstract_declarator: pointer idcolon DSTAR  */
#line 6143 "./CParse/parser.y"
                                          { 
		    (yyval.decl) = default_decl;
		    SwigType *t = NewStringEmpty();
                    (yyval.decl).type = (yyvsp[-2].type);
		    SwigType_add_memberpointer(t,(yyvsp[-1].str));
		    SwigType_push((yyval.decl).type,t);
		    Delete(t);
                  }
#line 10499 "CParse/parser.c"
    break;

  case 358: /* abstract_declarator: pointer idcolon DSTAR direct_abstract_declarator  */
#line 6151 "./CParse/parser.y"
                                                                     { 
		    (yyval.decl) = (yyvsp[0].decl);
		    SwigType_add_memberpointer((yyvsp[-3].type),(yyvsp[-2].str));
		    if ((yyval.decl).type) {
		      SwigType_push((yyvsp[-3].type),(yyval.decl).type);
		      Delete((yyval.decl).type);
		    }
		    (yyval.decl).type = (yyvsp[-3].type);
                  }
#line 10513 "CParse/parser.c"
    break;

  case 359: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET RBRACKET  */
#line 6162 "./CParse/parser.y"
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
#line 10529 "CParse/parser.c"
    break;

  case 360: /* direct_abstract_declarator: direct_abstract_declarator LBRACKET expr RBRACKET  */
#line 6173 "./CParse/parser.y"
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
#line 10545 "CParse/parser.c"
    break;

  case 361: /* direct_abstract_declarator: LBRACKET RBRACKET  */
#line 6184 "./CParse/parser.y"
                                      { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,"");
                  }
#line 10555 "CParse/parser.c"
    break;

  case 362: /* direct_abstract_declarator: LBRACKET expr RBRACKET  */
#line 6189 "./CParse/parser.y"
                                           { 
		    (yyval.decl) = default_decl;
		    (yyval.decl).type = NewStringEmpty();
		    SwigType_add_array((yyval.decl).type,(yyvsp[-1].dtype).val);
		  }
#line 10565 "CParse/parser.c"
    break;

  case 363: /* direct_abstract_declarator: LPAREN abstract_declarator RPAREN  */
#line 6194 "./CParse/parser.y"
                                                      {
                    (yyval.decl) = (yyvsp[-1].decl);
		  }
#line 10573 "CParse/parser.c"
    break;

  case 364: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN  */
#line 6197 "./CParse/parser.y"
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
#line 10595 "CParse/parser.c"
    break;

  case 365: /* direct_abstract_declarator: direct_abstract_declarator LPAREN parms RPAREN cv_ref_qualifier  */
#line 6214 "./CParse/parser.y"
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
#line 10618 "CParse/parser.c"
    break;

  case 366: /* direct_abstract_declarator: LPAREN parms RPAREN  */
#line 6232 "./CParse/parser.y"
                                        {
		    (yyval.decl) = default_decl;
                    (yyval.decl).type = NewStringEmpty();
                    SwigType_add_function((yyval.decl).type,(yyvsp[-1].pl));
		    (yyval.decl).parms = (yyvsp[-1].pl);
		    (yyval.decl).have_parms = 1;
                  }
#line 10630 "CParse/parser.c"
    break;

  case 367: /* pointer: pointer STAR type_qualifier  */
#line 6242 "./CParse/parser.y"
                                             {
	     (yyval.type) = (yyvsp[-2].type);
             SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 10640 "CParse/parser.c"
    break;

  case 368: /* pointer: pointer STAR  */
#line 6247 "./CParse/parser.y"
                              {
	     (yyval.type) = (yyvsp[-1].type);
	     SwigType_add_pointer((yyval.type));
	   }
#line 10649 "CParse/parser.c"
    break;

  case 369: /* pointer: STAR type_qualifier  */
#line 6251 "./CParse/parser.y"
                                 {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
	     SwigType_push((yyval.type),(yyvsp[0].str));
           }
#line 10659 "CParse/parser.c"
    break;

  case 370: /* pointer: STAR  */
#line 6256 "./CParse/parser.y"
                  {
	     (yyval.type) = NewStringEmpty();
	     SwigType_add_pointer((yyval.type));
           }
#line 10668 "CParse/parser.c"
    break;

  case 371: /* cv_ref_qualifier: type_qualifier  */
#line 6263 "./CParse/parser.y"
                                  {
		  (yyval.dtype).qualifier = (yyvsp[0].str);
	       }
#line 10676 "CParse/parser.c"
    break;

  case 372: /* cv_ref_qualifier: type_qualifier ref_qualifier  */
#line 6266 "./CParse/parser.y"
                                              {
		  (yyval.dtype).qualifier = (yyvsp[-1].str);
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 10686 "CParse/parser.c"
    break;

  case 373: /* cv_ref_qualifier: ref_qualifier  */
#line 6271 "./CParse/parser.y"
                               {
		  (yyval.dtype).qualifier = NewStringEmpty();
		  (yyval.dtype).refqualifier = (yyvsp[0].str);
		  SwigType_push((yyval.dtype).qualifier, (yyvsp[0].str));
	       }
#line 10696 "CParse/parser.c"
    break;

  case 374: /* ref_qualifier: AND  */
#line 6278 "./CParse/parser.y"
                    {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_reference((yyval.str));
	       }
#line 10705 "CParse/parser.c"
    break;

  case 375: /* ref_qualifier: LAND  */
#line 6282 "./CParse/parser.y"
                      {
	          (yyval.str) = NewStringEmpty();
	          SwigType_add_rvalue_reference((yyval.str));
	       }
#line 10714 "CParse/parser.c"
    break;

  case 376: /* type_qualifier: type_qualifier_raw  */
#line 6288 "./CParse/parser.y"
                                    {
	          (yyval.str) = NewStringEmpty();
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 10723 "CParse/parser.c"
    break;

  case 377: /* type_qualifier: type_qualifier type_qualifier_raw  */
#line 6292 "./CParse/parser.y"
                                                       {
		  (yyval.str) = (yyvsp[-1].str);
	          if ((yyvsp[0].id)) SwigType_add_qualifier((yyval.str),(yyvsp[0].id));
               }
#line 10732 "CParse/parser.c"
    break;

  case 378: /* type_qualifier_raw: CONST_QUAL  */
#line 6298 "./CParse/parser.y"
                                 { (yyval.id) = "const"; }
#line 10738 "CParse/parser.c"
    break;

  case 379: /* type_qualifier_raw: VOLATILE  */
#line 6299 "./CParse/parser.y"
                               { (yyval.id) = "volatile"; }
#line 10744 "CParse/parser.c"
    break;

  case 380: /* type_qualifier_raw: REGISTER  */
#line 6300 "./CParse/parser.y"
                               { (yyval.id) = 0; }
#line 10750 "CParse/parser.c"
    break;

  case 381: /* type: rawtype  */
#line 6306 "./CParse/parser.y"
                                    {
                   (yyval.type) = (yyvsp[0].type);
                   Replace((yyval.type),"typename ","", DOH_REPLACE_ANY);
                }
#line 10759 "CParse/parser.c"
    break;

  case 382: /* rawtype: type_qualifier type_right  */
#line 6312 "./CParse/parser.y"
                                           {
                   (yyval.type) = (yyvsp[0].type);
	           SwigType_push((yyval.type),(yyvsp[-1].str));
               }
#line 10768 "CParse/parser.c"
    break;

  case 384: /* rawtype: type_right type_qualifier  */
#line 6317 "./CParse/parser.y"
                                           {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	       }
#line 10777 "CParse/parser.c"
    break;

  case 385: /* rawtype: type_qualifier type_right type_qualifier  */
#line 6321 "./CParse/parser.y"
                                                                                            {
		  (yyval.type) = (yyvsp[-1].type);
	          SwigType_push((yyval.type),(yyvsp[0].str));
	          SwigType_push((yyval.type),(yyvsp[-2].str));
	       }
#line 10787 "CParse/parser.c"
    break;

  case 386: /* rawtype: rawtype ELLIPSIS  */
#line 6326 "./CParse/parser.y"
                                      {
		  (yyval.type) = (yyvsp[-1].type);
		  SwigType_add_variadic((yyval.type));
	       }
#line 10796 "CParse/parser.c"
    break;

  case 390: /* type_right: c_enum_key idcolon  */
#line 6335 "./CParse/parser.y"
                                    { (yyval.type) = NewStringf("enum %s", (yyvsp[0].str)); }
#line 10802 "CParse/parser.c"
    break;

  case 392: /* type_right: idcolon  */
#line 6338 "./CParse/parser.y"
                                   {
		  (yyval.type) = (yyvsp[0].str);
               }
#line 10810 "CParse/parser.c"
    break;

  case 393: /* type_right: cpptype idcolon  */
#line 6341 "./CParse/parser.y"
                                           {
		 (yyval.type) = NewStringf("%s %s", (yyvsp[-1].type), (yyvsp[0].str));
               }
#line 10818 "CParse/parser.c"
    break;

  case 395: /* @11: %empty  */
#line 6347 "./CParse/parser.y"
                                      {
		 (yyval.str) = get_raw_text_balanced('(', ')');
	       }
#line 10826 "CParse/parser.c"
    break;

  case 396: /* decltype: DECLTYPE LPAREN @11 decltypeexpr  */
#line 6349 "./CParse/parser.y"
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
#line 10844 "CParse/parser.c"
    break;

  case 397: /* decltypeexpr: expr RPAREN  */
#line 6364 "./CParse/parser.y"
                             {
		 (yyval.type) = deduce_type(&(yyvsp[-1].dtype));
	       }
#line 10852 "CParse/parser.c"
    break;

  case 398: /* decltypeexpr: error RPAREN  */
#line 6367 "./CParse/parser.y"
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
#line 10868 "CParse/parser.c"
    break;

  case 399: /* primitive_type: primitive_type_list  */
#line 6380 "./CParse/parser.y"
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
#line 10897 "CParse/parser.c"
    break;

  case 401: /* primitive_type_list: type_specifier primitive_type_list  */
#line 6407 "./CParse/parser.y"
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
#line 10953 "CParse/parser.c"
    break;

  case 402: /* type_specifier: TYPE_INT  */
#line 6461 "./CParse/parser.y"
                          { 
		    (yyval.ptype).type = NewString("int");
                    (yyval.ptype).us = 0;
               }
#line 10962 "CParse/parser.c"
    break;

  case 403: /* type_specifier: TYPE_SHORT  */
#line 6465 "./CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("short");
                    (yyval.ptype).us = 0;
                }
#line 10971 "CParse/parser.c"
    break;

  case 404: /* type_specifier: TYPE_LONG  */
#line 6469 "./CParse/parser.y"
                           { 
                    (yyval.ptype).type = NewString("long");
                    (yyval.ptype).us = 0;
                }
#line 10980 "CParse/parser.c"
    break;

  case 405: /* type_specifier: TYPE_CHAR  */
#line 6473 "./CParse/parser.y"
                           { 
                    (yyval.ptype).type = NewString("char");
                    (yyval.ptype).us = 0;
                }
#line 10989 "CParse/parser.c"
    break;

  case 406: /* type_specifier: TYPE_WCHAR  */
#line 6477 "./CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("wchar_t");
                    (yyval.ptype).us = 0;
                }
#line 10998 "CParse/parser.c"
    break;

  case 407: /* type_specifier: TYPE_FLOAT  */
#line 6481 "./CParse/parser.y"
                            { 
                    (yyval.ptype).type = NewString("float");
                    (yyval.ptype).us = 0;
                }
#line 11007 "CParse/parser.c"
    break;

  case 408: /* type_specifier: TYPE_DOUBLE  */
#line 6485 "./CParse/parser.y"
                             { 
                    (yyval.ptype).type = NewString("double");
                    (yyval.ptype).us = 0;
                }
#line 11016 "CParse/parser.c"
    break;

  case 409: /* type_specifier: TYPE_SIGNED  */
#line 6489 "./CParse/parser.y"
                             { 
                    (yyval.ptype).us = NewString("signed");
                    (yyval.ptype).type = 0;
                }
#line 11025 "CParse/parser.c"
    break;

  case 410: /* type_specifier: TYPE_UNSIGNED  */
#line 6493 "./CParse/parser.y"
                               { 
                    (yyval.ptype).us = NewString("unsigned");
                    (yyval.ptype).type = 0;
                }
#line 11034 "CParse/parser.c"
    break;

  case 411: /* type_specifier: TYPE_COMPLEX  */
#line 6497 "./CParse/parser.y"
                              { 
                    (yyval.ptype).type = NewString("_Complex");
                    (yyval.ptype).us = 0;
                }
#line 11043 "CParse/parser.c"
    break;

  case 412: /* type_specifier: TYPE_NON_ISO_INT8  */
#line 6501 "./CParse/parser.y"
                                   { 
                    (yyval.ptype).type = NewString("__int8");
                    (yyval.ptype).us = 0;
                }
#line 11052 "CParse/parser.c"
    break;

  case 413: /* type_specifier: TYPE_NON_ISO_INT16  */
#line 6505 "./CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int16");
                    (yyval.ptype).us = 0;
                }
#line 11061 "CParse/parser.c"
    break;

  case 414: /* type_specifier: TYPE_NON_ISO_INT32  */
#line 6509 "./CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int32");
                    (yyval.ptype).us = 0;
                }
#line 11070 "CParse/parser.c"
    break;

  case 415: /* type_specifier: TYPE_NON_ISO_INT64  */
#line 6513 "./CParse/parser.y"
                                    { 
                    (yyval.ptype).type = NewString("__int64");
                    (yyval.ptype).us = 0;
                }
#line 11079 "CParse/parser.c"
    break;

  case 420: /* deleted_definition: DELETE_KW  */
#line 6528 "./CParse/parser.y"
                               {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("delete");
		  (yyval.dtype).type = T_STRING;
		}
#line 11089 "CParse/parser.c"
    break;

  case 421: /* explicit_default: DEFAULT  */
#line 6536 "./CParse/parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewString("default");
		  (yyval.dtype).type = T_STRING;
		}
#line 11099 "CParse/parser.c"
    break;

  case 423: /* ename: %empty  */
#line 6546 "./CParse/parser.y"
                         { (yyval.id) = 0; }
#line 11105 "CParse/parser.c"
    break;

  case 428: /* enumlist: enumlist_item  */
#line 6565 "./CParse/parser.y"
                                {
		  Setattr((yyvsp[0].node),"_last",(yyvsp[0].node));
		  (yyval.node) = (yyvsp[0].node);
		}
#line 11114 "CParse/parser.c"
    break;

  case 429: /* enumlist: enumlist_item DOXYGENPOSTSTRING  */
#line 6569 "./CParse/parser.y"
                                                  {
		  Setattr((yyvsp[-1].node),"_last",(yyvsp[-1].node));
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11124 "CParse/parser.c"
    break;

  case 430: /* enumlist: enumlist_item DOXYGENSTRING  */
#line 6574 "./CParse/parser.y"
                                              {
		  Setattr((yyvsp[-1].node), "_last", (yyvsp[-1].node));
		  /* Misplaced doxygen string, attach it to previous parameter, like Doxygen does */
		  set_comment((yyvsp[-1].node), (yyvsp[0].str));
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11135 "CParse/parser.c"
    break;

  case 431: /* enumlist: enumlist_item COMMA enumlist  */
#line 6580 "./CParse/parser.y"
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
#line 11150 "CParse/parser.c"
    break;

  case 432: /* enumlist: enumlist_item DOXYGENPOSTSTRING COMMA enumlist  */
#line 6590 "./CParse/parser.y"
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
#line 11166 "CParse/parser.c"
    break;

  case 433: /* enumlist: enumlist_item COMMA DOXYGENPOSTSTRING enumlist  */
#line 6601 "./CParse/parser.y"
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
#line 11182 "CParse/parser.c"
    break;

  case 434: /* enumlist: optional_ignored_defines  */
#line 6612 "./CParse/parser.y"
                                           {
		  (yyval.node) = 0;
		}
#line 11190 "CParse/parser.c"
    break;

  case 435: /* enumlist_item: optional_ignored_defines edecl_with_dox optional_ignored_defines  */
#line 6617 "./CParse/parser.y"
                                                                                   {
		  (yyval.node) = (yyvsp[-1].node);
		}
#line 11198 "CParse/parser.c"
    break;

  case 437: /* edecl_with_dox: DOXYGENSTRING edecl  */
#line 6623 "./CParse/parser.y"
                                      {
		  (yyval.node) = (yyvsp[0].node);
		  set_comment((yyvsp[0].node), (yyvsp[-1].str));
		}
#line 11207 "CParse/parser.c"
    break;

  case 438: /* edecl: identifier  */
#line 6629 "./CParse/parser.y"
                             {
		   SwigType *type = NewSwigType(T_INT);
		   (yyval.node) = new_node("enumitem");
		   Setattr((yyval.node),"name",(yyvsp[0].id));
		   Setattr((yyval.node),"type",type);
		   SetFlag((yyval.node),"feature:immutable");
		   Delete(type);
		 }
#line 11220 "CParse/parser.c"
    break;

  case 439: /* edecl: identifier EQUAL etype  */
#line 6637 "./CParse/parser.y"
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
#line 11241 "CParse/parser.c"
    break;

  case 440: /* etype: expr  */
#line 6655 "./CParse/parser.y"
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
#line 11260 "CParse/parser.c"
    break;

  case 442: /* expr: type  */
#line 6674 "./CParse/parser.y"
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
#line 11289 "CParse/parser.c"
    break;

  case 443: /* exprmem: ID ARROW ID  */
#line 6701 "./CParse/parser.y"
                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s->%s", (yyvsp[-2].id), (yyvsp[0].id));
	       }
#line 11298 "CParse/parser.c"
    break;

  case 444: /* exprmem: ID ARROW ID LPAREN  */
#line 6705 "./CParse/parser.y"
                                              {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s->%s%s", (yyvsp[-3].id), (yyvsp[-1].id), scanner_ccode);
		 Clear(scanner_ccode);
	       }
#line 11309 "CParse/parser.c"
    break;

  case 445: /* exprmem: exprmem ARROW ID  */
#line 6711 "./CParse/parser.y"
                                      {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, "->%s", (yyvsp[0].id));
	       }
#line 11318 "CParse/parser.c"
    break;

  case 446: /* exprmem: exprmem ARROW ID LPAREN  */
#line 6715 "./CParse/parser.y"
                                             {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = (yyvsp[-3].dtype);
		 Printf((yyval.dtype).val, "->%s%s", (yyvsp[-1].id), scanner_ccode);
		 Clear(scanner_ccode);
	       }
#line 11329 "CParse/parser.c"
    break;

  case 447: /* exprmem: ID PERIOD ID  */
#line 6721 "./CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s.%s", (yyvsp[-2].id), (yyvsp[0].id));
	       }
#line 11338 "CParse/parser.c"
    break;

  case 448: /* exprmem: ID PERIOD ID LPAREN  */
#line 6725 "./CParse/parser.y"
                                               {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s.%s%s", (yyvsp[-3].id), (yyvsp[-1].id), scanner_ccode);
		 Clear(scanner_ccode);
	       }
#line 11349 "CParse/parser.c"
    break;

  case 449: /* exprmem: exprmem PERIOD ID  */
#line 6731 "./CParse/parser.y"
                                       {
		 (yyval.dtype) = (yyvsp[-2].dtype);
		 Printf((yyval.dtype).val, ".%s", (yyvsp[0].id));
	       }
#line 11358 "CParse/parser.c"
    break;

  case 450: /* exprmem: exprmem PERIOD ID LPAREN  */
#line 6735 "./CParse/parser.y"
                                              {
		 if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		 (yyval.dtype) = (yyvsp[-3].dtype);
		 Printf((yyval.dtype).val, ".%s%s", (yyvsp[-1].id), scanner_ccode);
		 Clear(scanner_ccode);
	       }
#line 11369 "CParse/parser.c"
    break;

  case 453: /* exprsimple: string  */
#line 6746 "./CParse/parser.y"
                        {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_STRING;
	       }
#line 11380 "CParse/parser.c"
    break;

  case 454: /* exprsimple: wstring  */
#line 6752 "./CParse/parser.y"
                         {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L\"%(escape)s\"", (yyvsp[0].str));
		  (yyval.dtype).type = T_WSTRING;
	       }
#line 11391 "CParse/parser.c"
    break;

  case 455: /* exprsimple: CHARCONST  */
#line 6758 "./CParse/parser.y"
                           {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("'%(escape)s'", (yyvsp[0].str));
		  (yyval.dtype).type = T_CHAR;
	       }
#line 11402 "CParse/parser.c"
    break;

  case 456: /* exprsimple: WCHARCONST  */
#line 6764 "./CParse/parser.y"
                            {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).stringval = (yyvsp[0].str);
		  (yyval.dtype).val = NewStringf("L'%(escape)s'", (yyvsp[0].str));
		  (yyval.dtype).type = T_WCHAR;
	       }
#line 11413 "CParse/parser.c"
    break;

  case 457: /* exprsimple: SIZEOF LPAREN  */
#line 6776 "./CParse/parser.y"
                               {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof%s", scanner_ccode);
		  Clear(scanner_ccode);
		  (yyval.dtype).type = T_ULONG;
               }
#line 11425 "CParse/parser.c"
    break;

  case 458: /* exprsimple: ALIGNOF LPAREN  */
#line 6784 "./CParse/parser.y"
                                {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("alignof%s", scanner_ccode);
		  Clear(scanner_ccode);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 11437 "CParse/parser.c"
    break;

  case 459: /* exprsimple: NOEXCEPT LPAREN  */
#line 6792 "./CParse/parser.y"
                                 {
		  if (skip_balanced('(', ')') < 0) Exit(EXIT_FAILURE);
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("noexcept%s", scanner_ccode);
		  Clear(scanner_ccode);
		  (yyval.dtype).type = T_BOOL;
	       }
#line 11449 "CParse/parser.c"
    break;

  case 460: /* exprsimple: SIZEOF ELLIPSIS LPAREN identifier RPAREN  */
#line 6799 "./CParse/parser.y"
                                                          {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof...(%s)", (yyvsp[-1].id));
		  (yyval.dtype).type = T_ULONG;
               }
#line 11459 "CParse/parser.c"
    break;

  case 461: /* exprsimple: SIZEOF exprsimple  */
#line 6809 "./CParse/parser.y"
                                       {
		  (yyval.dtype) = default_dtype;
		  (yyval.dtype).val = NewStringf("sizeof(%s)", (yyvsp[0].dtype).val);
		  (yyval.dtype).type = T_ULONG;
	       }
#line 11469 "CParse/parser.c"
    break;

  case 464: /* valexpr: LPAREN expr RPAREN  */
#line 6820 "./CParse/parser.y"
                                                {
	            (yyval.dtype) = default_dtype;
		    (yyval.dtype).val = NewStringf("(%s)",(yyvsp[-1].dtype).val);
		    (yyval.dtype).stringval = Copy((yyvsp[-1].dtype).stringval);
		    (yyval.dtype).numval = Copy((yyvsp[-1].dtype).numval);
		    (yyval.dtype).type = (yyvsp[-1].dtype).type;
	       }
#line 11481 "CParse/parser.c"
    break;

  case 465: /* valexpr: LPAREN expr RPAREN expr  */
#line 6830 "./CParse/parser.y"
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
#line 11525 "CParse/parser.c"
    break;

  case 466: /* valexpr: LPAREN expr pointer RPAREN expr  */
#line 6869 "./CParse/parser.y"
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
#line 11540 "CParse/parser.c"
    break;

  case 467: /* valexpr: LPAREN expr AND RPAREN expr  */
#line 6879 "./CParse/parser.y"
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
#line 11555 "CParse/parser.c"
    break;

  case 468: /* valexpr: LPAREN expr LAND RPAREN expr  */
#line 6889 "./CParse/parser.y"
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
#line 11570 "CParse/parser.c"
    break;

  case 469: /* valexpr: LPAREN expr pointer AND RPAREN expr  */
#line 6899 "./CParse/parser.y"
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
#line 11586 "CParse/parser.c"
    break;

  case 470: /* valexpr: LPAREN expr pointer LAND RPAREN expr  */
#line 6910 "./CParse/parser.y"
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
#line 11602 "CParse/parser.c"
    break;

  case 471: /* valexpr: AND expr  */
#line 6921 "./CParse/parser.y"
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
#line 11628 "CParse/parser.c"
    break;

  case 472: /* valexpr: STAR expr  */
#line 6942 "./CParse/parser.y"
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
#line 11654 "CParse/parser.c"
    break;

  case 483: /* exprcompound: expr PLUS expr  */
#line 6977 "./CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s+%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11664 "CParse/parser.c"
    break;

  case 484: /* exprcompound: expr MINUS expr  */
#line 6982 "./CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s-%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11674 "CParse/parser.c"
    break;

  case 485: /* exprcompound: expr STAR expr  */
#line 6987 "./CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11684 "CParse/parser.c"
    break;

  case 486: /* exprcompound: expr SLASH expr  */
#line 6992 "./CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11694 "CParse/parser.c"
    break;

  case 487: /* exprcompound: expr MODULO expr  */
#line 6997 "./CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11704 "CParse/parser.c"
    break;

  case 488: /* exprcompound: expr AND expr  */
#line 7002 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11714 "CParse/parser.c"
    break;

  case 489: /* exprcompound: expr OR expr  */
#line 7007 "./CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11724 "CParse/parser.c"
    break;

  case 490: /* exprcompound: expr XOR expr  */
#line 7012 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type,(yyvsp[0].dtype).type);
	       }
#line 11734 "CParse/parser.c"
    break;

  case 491: /* exprcompound: expr LSHIFT expr  */
#line 7017 "./CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11744 "CParse/parser.c"
    break;

  case 492: /* exprcompound: expr RSHIFT expr  */
#line 7022 "./CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11754 "CParse/parser.c"
    break;

  case 493: /* exprcompound: expr LAND expr  */
#line 7027 "./CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11764 "CParse/parser.c"
    break;

  case 494: /* exprcompound: expr LOR expr  */
#line 7032 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11774 "CParse/parser.c"
    break;

  case 495: /* exprcompound: expr EQUALTO expr  */
#line 7037 "./CParse/parser.y"
                                             {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11784 "CParse/parser.c"
    break;

  case 496: /* exprcompound: expr NOTEQUALTO expr  */
#line 7042 "./CParse/parser.y"
                                                {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=%s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11794 "CParse/parser.c"
    break;

  case 497: /* exprcompound: LPAREN expr GREATERTHAN expr RPAREN  */
#line 7051 "./CParse/parser.y"
                                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11804 "CParse/parser.c"
    break;

  case 498: /* exprcompound: LPAREN exprsimple LESSTHAN expr RPAREN  */
#line 7062 "./CParse/parser.y"
                                                                  {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val, (yyvsp[-1].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11814 "CParse/parser.c"
    break;

  case 499: /* exprcompound: expr GREATERTHANOREQUALTO expr  */
#line 7067 "./CParse/parser.y"
                                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11824 "CParse/parser.c"
    break;

  case 500: /* exprcompound: expr LESSTHANOREQUALTO expr  */
#line 7072 "./CParse/parser.y"
                                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= %s", (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11834 "CParse/parser.c"
    break;

  case 501: /* exprcompound: expr PLUS ELLIPSIS  */
#line 7089 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s+...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11844 "CParse/parser.c"
    break;

  case 502: /* exprcompound: expr MINUS ELLIPSIS  */
#line 7094 "./CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s-...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11854 "CParse/parser.c"
    break;

  case 503: /* exprcompound: expr STAR ELLIPSIS  */
#line 7099 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s*...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11864 "CParse/parser.c"
    break;

  case 504: /* exprcompound: expr SLASH ELLIPSIS  */
#line 7104 "./CParse/parser.y"
                                          {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s/...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11874 "CParse/parser.c"
    break;

  case 505: /* exprcompound: expr MODULO ELLIPSIS  */
#line 7109 "./CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s%%...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11884 "CParse/parser.c"
    break;

  case 506: /* exprcompound: expr AND ELLIPSIS  */
#line 7114 "./CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11894 "CParse/parser.c"
    break;

  case 507: /* exprcompound: expr OR ELLIPSIS  */
#line 7119 "./CParse/parser.y"
                                       {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s|...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11904 "CParse/parser.c"
    break;

  case 508: /* exprcompound: expr XOR ELLIPSIS  */
#line 7124 "./CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s^...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11914 "CParse/parser.c"
    break;

  case 509: /* exprcompound: expr LSHIFT ELLIPSIS  */
#line 7129 "./CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s << ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11924 "CParse/parser.c"
    break;

  case 510: /* exprcompound: expr RSHIFT ELLIPSIS  */
#line 7134 "./CParse/parser.y"
                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >> ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[-2].dtype).type);
	       }
#line 11934 "CParse/parser.c"
    break;

  case 511: /* exprcompound: expr LAND ELLIPSIS  */
#line 7139 "./CParse/parser.y"
                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s&&...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11944 "CParse/parser.c"
    break;

  case 512: /* exprcompound: expr LOR ELLIPSIS  */
#line 7144 "./CParse/parser.y"
                                        {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s||...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11954 "CParse/parser.c"
    break;

  case 513: /* exprcompound: expr EQUALTO ELLIPSIS  */
#line 7149 "./CParse/parser.y"
                                            {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s==...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11964 "CParse/parser.c"
    break;

  case 514: /* exprcompound: expr NOTEQUALTO ELLIPSIS  */
#line 7154 "./CParse/parser.y"
                                               {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s!=...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11974 "CParse/parser.c"
    break;

  case 515: /* exprcompound: LPAREN expr GREATERTHAN ELLIPSIS RPAREN  */
#line 7163 "./CParse/parser.y"
                                                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s > ...)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11984 "CParse/parser.c"
    break;

  case 516: /* exprcompound: LPAREN exprsimple LESSTHAN ELLIPSIS RPAREN  */
#line 7173 "./CParse/parser.y"
                                                                 {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("(%s < %s)", (yyvsp[-3].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 11994 "CParse/parser.c"
    break;

  case 517: /* exprcompound: expr GREATERTHANOREQUALTO ELLIPSIS  */
#line 7178 "./CParse/parser.y"
                                                         {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s >= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12004 "CParse/parser.c"
    break;

  case 518: /* exprcompound: expr LESSTHANOREQUALTO ELLIPSIS  */
#line 7183 "./CParse/parser.y"
                                                      {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s <= ...", (yyvsp[-2].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12014 "CParse/parser.c"
    break;

  case 519: /* exprcompound: expr LESSEQUALGREATER expr  */
#line 7189 "./CParse/parser.y"
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
#line 12034 "CParse/parser.c"
    break;

  case 520: /* exprcompound: expr QUESTIONMARK expr COLON expr  */
#line 7204 "./CParse/parser.y"
                                                                                           {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("%s?%s:%s", (yyvsp[-4].dtype).val, (yyvsp[-2].dtype).val, (yyvsp[0].dtype).val);
		 /* This may not be exactly right, but is probably good enough
		  * for the purposes of parsing constant expressions. */
		 (yyval.dtype).type = promote((yyvsp[-2].dtype).type, (yyvsp[0].dtype).type);
	       }
#line 12046 "CParse/parser.c"
    break;

  case 521: /* exprcompound: MINUS expr  */
#line 7211 "./CParse/parser.y"
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
#line 12077 "CParse/parser.c"
    break;

  case 522: /* exprcompound: PLUS expr  */
#line 7237 "./CParse/parser.y"
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
#line 12093 "CParse/parser.c"
    break;

  case 523: /* exprcompound: NOT expr  */
#line 7248 "./CParse/parser.y"
                              {
		 (yyval.dtype) = default_dtype;
		 (yyval.dtype).val = NewStringf("~%s",(yyvsp[0].dtype).val);
		 (yyval.dtype).type = promote_type((yyvsp[0].dtype).type);
	       }
#line 12103 "CParse/parser.c"
    break;

  case 524: /* exprcompound: LNOT expr  */
#line 7253 "./CParse/parser.y"
                               {
		 (yyval.dtype) = default_dtype;
                 (yyval.dtype).val = NewStringf("!%s", (yyvsp[0].dtype).val);
		 (yyval.dtype).type = cparse_cplusplus ? T_BOOL : T_INT;
	       }
#line 12113 "CParse/parser.c"
    break;

  case 525: /* exprcompound: type LPAREN  */
#line 7258 "./CParse/parser.y"
                             {
		 (yyval.dtype) = default_dtype;
		 String *qty;
		 if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		 qty = Swig_symbol_type_qualify((yyvsp[-1].type),0);
		 if (SwigType_istemplate(qty)) {
		   String *nstr = SwigType_namestr(qty);
		   Delete(qty);
		   qty = nstr;
		 }
		 (yyval.dtype).val = NewStringf("%s%s",qty,scanner_ccode);
		 Clear(scanner_ccode);
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
		 Delete(qty);
               }
#line 12143 "CParse/parser.c"
    break;

  case 526: /* variadic_opt: ELLIPSIS  */
#line 7285 "./CParse/parser.y"
                         {
		(yyval.intvalue) = 1;
	      }
#line 12151 "CParse/parser.c"
    break;

  case 527: /* variadic_opt: %empty  */
#line 7288 "./CParse/parser.y"
                       {
	        (yyval.intvalue) = 0;
	      }
#line 12159 "CParse/parser.c"
    break;

  case 529: /* $@12: %empty  */
#line 7296 "./CParse/parser.y"
                        { inherit_list = 1; }
#line 12165 "CParse/parser.c"
    break;

  case 530: /* raw_inherit: COLON $@12 base_list  */
#line 7296 "./CParse/parser.y"
                                                        { (yyval.bases) = (yyvsp[0].bases); inherit_list = 0; }
#line 12171 "CParse/parser.c"
    break;

  case 531: /* raw_inherit: %empty  */
#line 7297 "./CParse/parser.y"
                         { (yyval.bases) = 0; }
#line 12177 "CParse/parser.c"
    break;

  case 532: /* base_list: base_specifier  */
#line 7300 "./CParse/parser.y"
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
#line 12198 "CParse/parser.c"
    break;

  case 533: /* base_list: base_list COMMA base_specifier  */
#line 7317 "./CParse/parser.y"
                                                    {
		   Hash *list = (yyvsp[-2].bases);
		   Node *base = (yyvsp[0].node);
		   Node *name = Getattr(base,"name");
		   Append(Getattr(list,Getattr(base,"access")),name);
                   (yyval.bases) = list;
               }
#line 12210 "CParse/parser.c"
    break;

  case 534: /* @13: %empty  */
#line 7326 "./CParse/parser.y"
                                       {
		 (yyval.intvalue) = cparse_line;
	       }
#line 12218 "CParse/parser.c"
    break;

  case 535: /* base_specifier: opt_virtual @13 idcolon variadic_opt  */
#line 7328 "./CParse/parser.y"
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
#line 12240 "CParse/parser.c"
    break;

  case 536: /* @14: %empty  */
#line 7345 "./CParse/parser.y"
                                                        {
		 (yyval.intvalue) = cparse_line;
	       }
#line 12248 "CParse/parser.c"
    break;

  case 537: /* base_specifier: opt_virtual access_specifier @14 opt_virtual idcolon variadic_opt  */
#line 7347 "./CParse/parser.y"
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
#line 12268 "CParse/parser.c"
    break;

  case 538: /* access_specifier: PUBLIC  */
#line 7364 "./CParse/parser.y"
                           { (yyval.id) = "public"; }
#line 12274 "CParse/parser.c"
    break;

  case 539: /* access_specifier: PRIVATE  */
#line 7365 "./CParse/parser.y"
                         { (yyval.id) = "private"; }
#line 12280 "CParse/parser.c"
    break;

  case 540: /* access_specifier: PROTECTED  */
#line 7366 "./CParse/parser.y"
                           { (yyval.id) = "protected"; }
#line 12286 "CParse/parser.c"
    break;

  case 541: /* templcpptype: CLASS variadic_opt  */
#line 7369 "./CParse/parser.y"
                                    {
                   (yyval.type) = NewString("class");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 12296 "CParse/parser.c"
    break;

  case 542: /* templcpptype: TYPENAME variadic_opt  */
#line 7374 "./CParse/parser.y"
                                       {
                   (yyval.type) = NewString("typename");
		   if (!inherit_list) last_cpptype = (yyval.type);
		   if ((yyvsp[0].intvalue)) SwigType_add_variadic((yyval.type));
               }
#line 12306 "CParse/parser.c"
    break;

  case 544: /* cpptype: STRUCT  */
#line 7382 "./CParse/parser.y"
                        {
                   (yyval.type) = NewString("struct");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 12315 "CParse/parser.c"
    break;

  case 545: /* cpptype: UNION  */
#line 7386 "./CParse/parser.y"
                       {
                   (yyval.type) = NewString("union");
		   if (!inherit_list) last_cpptype = (yyval.type);
               }
#line 12324 "CParse/parser.c"
    break;

  case 546: /* classkey: CLASS  */
#line 7392 "./CParse/parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("class");
               }
#line 12332 "CParse/parser.c"
    break;

  case 547: /* classkey: STRUCT  */
#line 7395 "./CParse/parser.y"
                        {
		   if (!inherit_list) last_cpptype = NewString("struct");
               }
#line 12340 "CParse/parser.c"
    break;

  case 548: /* classkey: UNION  */
#line 7398 "./CParse/parser.y"
                       {
		   if (!inherit_list) last_cpptype = NewString("union");
               }
#line 12348 "CParse/parser.c"
    break;

  case 553: /* virt_specifier_seq: OVERRIDE  */
#line 7411 "./CParse/parser.y"
                              {
                   (yyval.str) = 0;
	       }
#line 12356 "CParse/parser.c"
    break;

  case 554: /* virt_specifier_seq: FINAL  */
#line 7414 "./CParse/parser.y"
                       {
                   (yyval.str) = NewString("1");
	       }
#line 12364 "CParse/parser.c"
    break;

  case 555: /* virt_specifier_seq: FINAL OVERRIDE  */
#line 7417 "./CParse/parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 12372 "CParse/parser.c"
    break;

  case 556: /* virt_specifier_seq: OVERRIDE FINAL  */
#line 7420 "./CParse/parser.y"
                                {
                   (yyval.str) = NewString("1");
	       }
#line 12380 "CParse/parser.c"
    break;

  case 558: /* virt_specifier_seq_opt: %empty  */
#line 7426 "./CParse/parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 12388 "CParse/parser.c"
    break;

  case 559: /* class_virt_specifier_opt: FINAL  */
#line 7431 "./CParse/parser.y"
                                 {
                   (yyval.str) = NewString("1");
               }
#line 12396 "CParse/parser.c"
    break;

  case 560: /* class_virt_specifier_opt: %empty  */
#line 7434 "./CParse/parser.y"
                        {
                   (yyval.str) = 0;
               }
#line 12404 "CParse/parser.c"
    break;

  case 561: /* exception_specification: THROW LPAREN parms RPAREN  */
#line 7439 "./CParse/parser.y"
                                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-1].pl);
                    (yyval.dtype).throwf = NewString("1");
	       }
#line 12414 "CParse/parser.c"
    break;

  case 562: /* exception_specification: NOEXCEPT  */
#line 7444 "./CParse/parser.y"
                          {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
	       }
#line 12423 "CParse/parser.c"
    break;

  case 563: /* exception_specification: virt_specifier_seq  */
#line 7448 "./CParse/parser.y"
                                    {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12432 "CParse/parser.c"
    break;

  case 564: /* exception_specification: THROW LPAREN parms RPAREN virt_specifier_seq  */
#line 7452 "./CParse/parser.y"
                                                              {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).throws = (yyvsp[-2].pl);
                    (yyval.dtype).throwf = NewString("1");
                    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12443 "CParse/parser.c"
    break;

  case 565: /* exception_specification: NOEXCEPT virt_specifier_seq  */
#line 7458 "./CParse/parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = NewString("true");
		    (yyval.dtype).final = (yyvsp[0].str);
	       }
#line 12453 "CParse/parser.c"
    break;

  case 566: /* exception_specification: NOEXCEPT LPAREN expr RPAREN  */
#line 7463 "./CParse/parser.y"
                                             {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).nexcept = (yyvsp[-1].dtype).val;
	       }
#line 12462 "CParse/parser.c"
    break;

  case 567: /* qualifiers_exception_specification: cv_ref_qualifier  */
#line 7469 "./CParse/parser.y"
                                                      {
		    (yyval.dtype) = default_dtype;
                    (yyval.dtype).qualifier = (yyvsp[0].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[0].dtype).refqualifier;
               }
#line 12472 "CParse/parser.c"
    break;

  case 568: /* qualifiers_exception_specification: exception_specification  */
#line 7474 "./CParse/parser.y"
                                         {
		    (yyval.dtype) = (yyvsp[0].dtype);
               }
#line 12480 "CParse/parser.c"
    break;

  case 569: /* qualifiers_exception_specification: cv_ref_qualifier exception_specification  */
#line 7477 "./CParse/parser.y"
                                                          {
		    (yyval.dtype) = (yyvsp[0].dtype);
                    (yyval.dtype).qualifier = (yyvsp[-1].dtype).qualifier;
                    (yyval.dtype).refqualifier = (yyvsp[-1].dtype).refqualifier;
               }
#line 12490 "CParse/parser.c"
    break;

  case 571: /* cpp_const: %empty  */
#line 7485 "./CParse/parser.y"
                        {
                 (yyval.dtype) = default_dtype;
               }
#line 12498 "CParse/parser.c"
    break;

  case 572: /* ctor_end: cpp_const ctor_initializer SEMI  */
#line 7490 "./CParse/parser.y"
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
#line 12513 "CParse/parser.c"
    break;

  case 573: /* ctor_end: cpp_const ctor_initializer LBRACE  */
#line 7500 "./CParse/parser.y"
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
#line 12528 "CParse/parser.c"
    break;

  case 574: /* ctor_end: LPAREN parms RPAREN SEMI  */
#line 7510 "./CParse/parser.y"
                                          { 
                    Clear(scanner_ccode); 
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 12539 "CParse/parser.c"
    break;

  case 575: /* ctor_end: LPAREN parms RPAREN LBRACE  */
#line 7516 "./CParse/parser.y"
                                            {
                    if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		    (yyval.decl) = default_decl;
                    (yyval.decl).parms = (yyvsp[-2].pl); 
                    (yyval.decl).have_parms = 1; 
               }
#line 12550 "CParse/parser.c"
    break;

  case 576: /* ctor_end: EQUAL definetype SEMI  */
#line 7522 "./CParse/parser.y"
                                       { 
		    (yyval.decl) = default_decl;
                    (yyval.decl).defarg = (yyvsp[-1].dtype).val; 
		    (yyval.decl).stringdefarg = (yyvsp[-1].dtype).stringval;
		    (yyval.decl).numdefarg = (yyvsp[-1].dtype).numval;
               }
#line 12561 "CParse/parser.c"
    break;

  case 577: /* ctor_end: exception_specification EQUAL default_delete SEMI  */
#line 7528 "./CParse/parser.y"
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
#line 12578 "CParse/parser.c"
    break;

  case 584: /* mem_initializer: idcolon LPAREN  */
#line 7552 "./CParse/parser.y"
                                 {
		  if (skip_balanced('(',')') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 12587 "CParse/parser.c"
    break;

  case 585: /* mem_initializer: idcolon LBRACE  */
#line 7564 "./CParse/parser.y"
                                 {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  Clear(scanner_ccode);
		}
#line 12596 "CParse/parser.c"
    break;

  case 586: /* less_valparms_greater: LESSTHAN valparms GREATERTHAN  */
#line 7570 "./CParse/parser.y"
                                                      {
                     String *s = NewStringEmpty();
                     SwigType_add_template(s,(yyvsp[-1].p));
		     (yyval.str) = s;
		     scanner_last_id(1);
                }
#line 12607 "CParse/parser.c"
    break;

  case 588: /* identifier: OVERRIDE  */
#line 7580 "./CParse/parser.y"
                          { (yyval.id) = Swig_copy_string("override"); }
#line 12613 "CParse/parser.c"
    break;

  case 589: /* identifier: FINAL  */
#line 7581 "./CParse/parser.y"
                       { (yyval.id) = Swig_copy_string("final"); }
#line 12619 "CParse/parser.c"
    break;

  case 591: /* idstring: default_delete  */
#line 7585 "./CParse/parser.y"
                                { (yyval.id) = Char((yyvsp[0].dtype).val); }
#line 12625 "CParse/parser.c"
    break;

  case 592: /* idstring: string  */
#line 7586 "./CParse/parser.y"
                        { (yyval.id) = Char((yyvsp[0].str)); }
#line 12631 "CParse/parser.c"
    break;

  case 594: /* idstringopt: %empty  */
#line 7590 "./CParse/parser.y"
                        { (yyval.id) = 0; }
#line 12637 "CParse/parser.c"
    break;

  case 595: /* idcolon: idtemplate idcolontail  */
#line 7593 "./CParse/parser.y"
                                        { 
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 12646 "CParse/parser.c"
    break;

  case 596: /* idcolon: NONID DCOLON idtemplatetemplate idcolontail  */
#line 7597 "./CParse/parser.y"
                                                             {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 12655 "CParse/parser.c"
    break;

  case 597: /* idcolon: idtemplate  */
#line 7601 "./CParse/parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].str));
   	       }
#line 12663 "CParse/parser.c"
    break;

  case 598: /* idcolon: NONID DCOLON idtemplatetemplate  */
#line 7604 "./CParse/parser.y"
                                                 {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 12671 "CParse/parser.c"
    break;

  case 599: /* idcolon: OPERATOR  */
#line 7607 "./CParse/parser.y"
                                    {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 12679 "CParse/parser.c"
    break;

  case 600: /* idcolon: OPERATOR less_valparms_greater  */
#line 7610 "./CParse/parser.y"
                                                {
		 (yyval.str) = (yyvsp[-1].str);
		 Append((yyval.str), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
	       }
#line 12689 "CParse/parser.c"
    break;

  case 601: /* idcolon: NONID DCOLON OPERATOR  */
#line 7615 "./CParse/parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 12698 "CParse/parser.c"
    break;

  case 602: /* idcolontail: DCOLON idtemplatetemplate idcolontail  */
#line 7621 "./CParse/parser.y"
                                                           {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].str),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 12707 "CParse/parser.c"
    break;

  case 603: /* idcolontail: DCOLON idtemplatetemplate  */
#line 7625 "./CParse/parser.y"
                                           {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].str));
               }
#line 12715 "CParse/parser.c"
    break;

  case 604: /* idcolontail: DCOLON OPERATOR  */
#line 7628 "./CParse/parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 12724 "CParse/parser.c"
    break;

  case 605: /* idcolontail: DCNOT idtemplate  */
#line 7632 "./CParse/parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].str));
               }
#line 12732 "CParse/parser.c"
    break;

  case 606: /* idtemplate: identifier  */
#line 7638 "./CParse/parser.y"
                           {
		(yyval.str) = NewString((yyvsp[0].id));
	      }
#line 12740 "CParse/parser.c"
    break;

  case 607: /* idtemplate: identifier less_valparms_greater  */
#line 7641 "./CParse/parser.y"
                                                 {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 12750 "CParse/parser.c"
    break;

  case 609: /* idtemplatetemplate: TEMPLATE identifier less_valparms_greater  */
#line 7649 "./CParse/parser.y"
                                                          {
		(yyval.str) = NewString((yyvsp[-1].id));
		Append((yyval.str), (yyvsp[0].str));
		Delete((yyvsp[0].str));
	      }
#line 12760 "CParse/parser.c"
    break;

  case 610: /* idcolonnt: identifier idcolontailnt  */
#line 7657 "./CParse/parser.y"
                                         {
		 (yyval.str) = NewStringf("%s%s", (yyvsp[-1].id), (yyvsp[0].str));
		 Delete((yyvsp[0].str));
               }
#line 12769 "CParse/parser.c"
    break;

  case 611: /* idcolonnt: NONID DCOLON identifier idcolontailnt  */
#line 7661 "./CParse/parser.y"
                                                       {
		 (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
                 Delete((yyvsp[0].str));
               }
#line 12778 "CParse/parser.c"
    break;

  case 612: /* idcolonnt: identifier  */
#line 7665 "./CParse/parser.y"
                            {
		 (yyval.str) = NewString((yyvsp[0].id));
   	       }
#line 12786 "CParse/parser.c"
    break;

  case 613: /* idcolonnt: NONID DCOLON identifier  */
#line 7668 "./CParse/parser.y"
                                         {
		 (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 12794 "CParse/parser.c"
    break;

  case 614: /* idcolonnt: OPERATOR  */
#line 7671 "./CParse/parser.y"
                          {
		 (yyval.str) = (yyvsp[0].str);
	       }
#line 12802 "CParse/parser.c"
    break;

  case 615: /* idcolonnt: NONID DCOLON OPERATOR  */
#line 7674 "./CParse/parser.y"
                                       {
		 (yyval.str) = (yyvsp[0].str);
		 Insert((yyval.str), 0, "::");
               }
#line 12811 "CParse/parser.c"
    break;

  case 616: /* idcolontailnt: DCOLON identifier idcolontailnt  */
#line 7680 "./CParse/parser.y"
                                                      {
                   (yyval.str) = NewStringf("::%s%s",(yyvsp[-1].id),(yyvsp[0].str));
		   Delete((yyvsp[0].str));
               }
#line 12820 "CParse/parser.c"
    break;

  case 617: /* idcolontailnt: DCOLON identifier  */
#line 7684 "./CParse/parser.y"
                                   {
                   (yyval.str) = NewStringf("::%s",(yyvsp[0].id));
               }
#line 12828 "CParse/parser.c"
    break;

  case 618: /* idcolontailnt: DCOLON OPERATOR  */
#line 7687 "./CParse/parser.y"
                                 {
		   (yyval.str) = (yyvsp[0].str);
		   Insert((yyval.str), 0, "::");
               }
#line 12837 "CParse/parser.c"
    break;

  case 619: /* idcolontailnt: DCNOT identifier  */
#line 7691 "./CParse/parser.y"
                                  {
		 (yyval.str) = NewStringf("::~%s",(yyvsp[0].id));
               }
#line 12845 "CParse/parser.c"
    break;

  case 620: /* string: string STRING  */
#line 7697 "./CParse/parser.y"
                                   { 
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12855 "CParse/parser.c"
    break;

  case 622: /* wstring: wstring WSTRING  */
#line 7704 "./CParse/parser.y"
                                     {
		   // Concatenated wide strings: L"str1" L"str2"
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12866 "CParse/parser.c"
    break;

  case 623: /* wstring: wstring STRING  */
#line 7710 "./CParse/parser.y"
                                    {
		   // Concatenated wide string and normal string literal: L"str1" "str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12877 "CParse/parser.c"
    break;

  case 624: /* wstring: string WSTRING  */
#line 7716 "./CParse/parser.y"
                                    {
		   // Concatenated normal string and wide string literal: "str1" L"str2" (C++11).
		   (yyval.str) = (yyvsp[-1].str);
		   Append((yyval.str), (yyvsp[0].str));
		   Delete((yyvsp[0].str));
	       }
#line 12888 "CParse/parser.c"
    break;

  case 627: /* stringbrace: LBRACE  */
#line 7726 "./CParse/parser.y"
                        {
		  if (skip_balanced('{','}') < 0) Exit(EXIT_FAILURE);
		  (yyval.str) = NewString(scanner_ccode);
               }
#line 12897 "CParse/parser.c"
    break;

  case 629: /* options: LPAREN kwargs RPAREN  */
#line 7733 "./CParse/parser.y"
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
#line 12915 "CParse/parser.c"
    break;

  case 630: /* options: %empty  */
#line 7746 "./CParse/parser.y"
                        { (yyval.node) = 0; }
#line 12921 "CParse/parser.c"
    break;

  case 631: /* kwargs: kwargs_builder  */
#line 7750 "./CParse/parser.y"
                                {
		 (yyval.node) = (yyvsp[0].nodebuilder).node;
	       }
#line 12929 "CParse/parser.c"
    break;

  case 632: /* kwargs_builder: idstring EQUAL stringnum  */
#line 7755 "./CParse/parser.y"
                                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 12941 "CParse/parser.c"
    break;

  case 633: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringnum  */
#line 7762 "./CParse/parser.y"
                                                                   {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[-2].id));
		 Setattr(n, "value", (yyvsp[0].str));
		 Delete((yyvsp[0].str));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 12955 "CParse/parser.c"
    break;

  case 634: /* kwargs_builder: idstring  */
#line 7771 "./CParse/parser.y"
                          {
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 12965 "CParse/parser.c"
    break;

  case 635: /* kwargs_builder: kwargs_builder COMMA idstring  */
#line 7776 "./CParse/parser.y"
                                                   {
		 (yyval.nodebuilder) = (yyvsp[-2].nodebuilder);
		 Node *n = NewHash();
		 Setattr(n, "name", (yyvsp[0].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 12977 "CParse/parser.c"
    break;

  case 636: /* kwargs_builder: idstring EQUAL stringtype  */
#line 7783 "./CParse/parser.y"
                                           {
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 (yyval.nodebuilder).node = (yyval.nodebuilder).last = n;
	       }
#line 12987 "CParse/parser.c"
    break;

  case 637: /* kwargs_builder: kwargs_builder COMMA idstring EQUAL stringtype  */
#line 7788 "./CParse/parser.y"
                                                                    {
		 (yyval.nodebuilder) = (yyvsp[-4].nodebuilder);
		 Node *n = (yyvsp[0].node);
		 Setattr(n, "name", (yyvsp[-2].id));
		 set_nextSibling((yyval.nodebuilder).last, n);
		 (yyval.nodebuilder).last = n;
	       }
#line 12999 "CParse/parser.c"
    break;

  case 639: /* stringnum: exprnum  */
#line 7798 "./CParse/parser.y"
                         {
		 (yyval.str) = (yyvsp[0].dtype).val;
               }
#line 13007 "CParse/parser.c"
    break;


#line 13011 "CParse/parser.c"

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

#line 7803 "./CParse/parser.y"


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

