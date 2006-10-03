/* ----------------------------------------------------------------------------- 
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * swig.h
 *
 * Header file for the SWIG core.
 * ----------------------------------------------------------------------------- */

/* $Header$ */

#ifndef SWIGCORE_H_
#define SWIGCORE_H_

#ifndef MACSWIG
#include "swigconfig.h"
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "doh.h"

/* Status codes */

#define SWIG_OK         1
#define SWIG_ERROR      0
#define SWIG_NOWRAP     0

/* Short names for common data types */

typedef  DOH     String;
typedef  DOH     Hash;
typedef  DOH     List;
typedef  DOH     String_or_char;
typedef  DOH     File;
typedef  DOH     Parm;
typedef  DOH     ParmList;
typedef  DOH     Node;
typedef  DOH     Symtab;
typedef  DOH     Typetab;
typedef  DOH     SwigType;

/* --- Legacy DataType interface.  These type codes are provided solely 
       for backwards compatibility with older modules --- */

/* --- The ordering of type values is used to determine type-promotion 
       in the parser.  Do not change */

/* Numeric types */

#define   T_BOOL       1
#define   T_SCHAR      2
#define   T_UCHAR      3
#define   T_SHORT      4
#define   T_USHORT     5
#define   T_ENUM       6
#define   T_INT        7
#define   T_UINT       8
#define   T_LONG       9
#define   T_ULONG      10
#define   T_LONGLONG   11
#define   T_ULONGLONG  12
#define   T_FLOAT      20
#define   T_DOUBLE     21
#define   T_LONGDOUBLE 22
#define   T_FLTCPLX    23
#define   T_DBLCPLX    24
#define   T_NUMERIC    25

#define   T_COMPLEX    T_DBLCPLX

/* non-numeric */

#define   T_CHAR       29
#define   T_WCHAR      30
#define   T_USER       31
#define   T_VOID       32
#define   T_STRING     33
#define   T_POINTER    34
#define   T_REFERENCE  35
#define   T_ARRAY      36
#define   T_FUNCTION   37
#define   T_MPOINTER   38
#define   T_VARARGS    39
#define   T_SYMBOL     98
#define   T_ERROR      99

/* --- File interface --- */

extern List    *Swig_add_directory(const String_or_char *dirname);
extern void     Swig_push_directory(const String_or_char *dirname);
extern void     Swig_pop_directory();
extern String  *Swig_last_file();
extern List    *Swig_search_path();
extern FILE    *Swig_open(const String_or_char *name);
extern String  *Swig_read_file(FILE *f);
extern String  *Swig_include(const String_or_char *name);
extern String  *Swig_include_sys(const String_or_char *name);
extern int      Swig_insert_file(const String_or_char *name, File *outfile);
extern void     Swig_set_config_file(const String_or_char *filename);
extern String  *Swig_get_config_file(void);
extern void     Swig_set_push_dir(int dopush);
extern int      Swig_get_push_dir(void);
extern void     Swig_swiglib_set(const String_or_char *);
extern String  *Swig_swiglib_get();
extern void     Swig_register_filebyname(const String_or_char *filename, File *outfile);
extern File    *Swig_filebyname(const String_or_char *filename);
extern char    *Swig_file_suffix(const String_or_char *filename);
extern char    *Swig_file_basename(const String_or_char *filename);
extern char    *Swig_file_filename(const String_or_char *filename);
extern char    *Swig_file_dirname(const String_or_char *filename);

#if defined(MACSWIG)
#  define SWIG_FILE_DELIMETER  ":"
#elif defined(_WIN32)
#  define  SWIG_FILE_DELIMETER "\\"
#else
#  define  SWIG_FILE_DELIMETER "/"
#endif

/* --- Command line parsing --- */

extern void     Swig_init_args(int argc, char **argv);
extern void     Swig_mark_arg(int n);
extern int      Swig_check_marked(int n);
extern void     Swig_check_options(int check_input);
extern void     Swig_arg_error();

/* --- Scanner Interface --- */

typedef struct SwigScanner SwigScanner;

extern SwigScanner *NewSwigScanner();
extern void         DelSwigScanner(SwigScanner *);
extern void         SwigScanner_clear(SwigScanner *);
extern void         SwigScanner_push(SwigScanner *, String *);
extern void         SwigScanner_pushtoken(SwigScanner *, int);
extern int          SwigScanner_token(SwigScanner *);
extern String      *SwigScanner_text(SwigScanner *);
extern void         SwigScanner_skip_line(SwigScanner *);
extern int          SwigScanner_skip_balanced(SwigScanner *, int startchar, int endchar);
extern void         SwigScanner_set_location(SwigScanner *, String *file, int line);
extern String      *SwigScanner_get_file(SwigScanner *);
extern int          SwigScanner_get_line(SwigScanner *);
extern void         SwigScanner_idstart(SwigScanner *, char *idchar);

#define   SWIG_MAXTOKENS          512
#define   SWIG_TOKEN_LPAREN        1  
#define   SWIG_TOKEN_RPAREN        2
#define   SWIG_TOKEN_SEMI          3
#define   SWIG_TOKEN_COMMA         4
#define   SWIG_TOKEN_STAR          5
#define   SWIG_TOKEN_LBRACE        6
#define   SWIG_TOKEN_RBRACE        7
#define   SWIG_TOKEN_EQUAL         8
#define   SWIG_TOKEN_EQUALTO       9
#define   SWIG_TOKEN_NOTEQUAL     10
#define   SWIG_TOKEN_PLUS         11
#define   SWIG_TOKEN_MINUS        12
#define   SWIG_TOKEN_AND          13
#define   SWIG_TOKEN_LAND         14
#define   SWIG_TOKEN_OR           15
#define   SWIG_TOKEN_LOR          16
#define   SWIG_TOKEN_XOR          17
#define   SWIG_TOKEN_LESSTHAN     18
#define   SWIG_TOKEN_GREATERTHAN  19
#define   SWIG_TOKEN_LTEQUAL      20
#define   SWIG_TOKEN_GTEQUAL      21
#define   SWIG_TOKEN_NOT          22
#define   SWIG_TOKEN_LNOT         23
#define   SWIG_TOKEN_LBRACKET     24
#define   SWIG_TOKEN_RBRACKET     25
#define   SWIG_TOKEN_SLASH        26
#define   SWIG_TOKEN_BACKSLASH    27
#define   SWIG_TOKEN_ENDLINE      28
#define   SWIG_TOKEN_STRING       29
#define   SWIG_TOKEN_POUND        30
#define   SWIG_TOKEN_PERCENT      31
#define   SWIG_TOKEN_COLON        32
#define   SWIG_TOKEN_DCOLON       33
#define   SWIG_TOKEN_LSHIFT       34
#define   SWIG_TOKEN_RSHIFT       35
#define   SWIG_TOKEN_ID           36
#define   SWIG_TOKEN_FLOAT        37
#define   SWIG_TOKEN_DOUBLE       38
#define   SWIG_TOKEN_INT          39
#define   SWIG_TOKEN_UINT         40
#define   SWIG_TOKEN_LONG         41
#define   SWIG_TOKEN_ULONG        42
#define   SWIG_TOKEN_CHAR         43
#define   SWIG_TOKEN_PERIOD       44
#define   SWIG_TOKEN_AT           45
#define   SWIG_TOKEN_DOLLAR       46
#define   SWIG_TOKEN_CODEBLOCK    47
#define   SWIG_TOKEN_RSTRING      48
#define   SWIG_TOKEN_LONGLONG     49
#define   SWIG_TOKEN_ULONGLONG    50
#define   SWIG_TOKEN_ILLEGAL      98
#define   SWIG_TOKEN_LAST         99 

/* --- Functions for manipulating the string-based type encoding --- */

extern SwigType   *NewSwigType(int typecode);
extern SwigType    *SwigType_del_element(SwigType *t);
extern SwigType   *SwigType_add_pointer(SwigType *t);
extern SwigType   *SwigType_add_memberpointer(SwigType *t, const String_or_char *qual);
extern SwigType   *SwigType_del_pointer(SwigType *t);
extern SwigType   *SwigType_add_array(SwigType *t, const String_or_char *size);
extern SwigType   *SwigType_del_array(SwigType *t);
extern SwigType   *SwigType_pop_arrays(SwigType *t);
extern SwigType   *SwigType_add_reference(SwigType *t);
extern SwigType   *SwigType_del_reference(SwigType *t);
extern SwigType   *SwigType_add_qualifier(SwigType *t, const String_or_char *qual);
extern SwigType   *SwigType_del_qualifier(SwigType *t);
extern SwigType   *SwigType_add_function(SwigType *t, ParmList *parms);
extern SwigType   *SwigType_add_template(SwigType *t, ParmList *parms);
extern SwigType   *SwigType_pop_function(SwigType *t);
extern ParmList   *SwigType_function_parms(SwigType *t);
extern List       *SwigType_split(const SwigType *t);
extern String     *SwigType_pop(SwigType *t);
extern void        SwigType_push(SwigType *t, SwigType *s);
extern List       *SwigType_parmlist(const SwigType *p);
extern String     *SwigType_parm(String *p);
extern String     *SwigType_str(SwigType *s, const String_or_char *id);
extern String     *SwigType_lstr(SwigType *s, const String_or_char *id);
extern String     *SwigType_rcaststr(SwigType *s, const String_or_char *id);
extern String     *SwigType_lcaststr(SwigType *s, const String_or_char *id);
extern String     *SwigType_manglestr(SwigType *t);
extern SwigType   *SwigType_ltype(SwigType *t);
extern int         SwigType_ispointer(SwigType *t);
extern int         SwigType_ispointer_return(SwigType *t);
extern int         SwigType_ismemberpointer(SwigType *t);
extern int         SwigType_isreference(SwigType *t);
extern int         SwigType_isreference_return(SwigType *t);
extern int         SwigType_isarray(SwigType *t);
extern int         SwigType_isfunction(SwigType *t);
extern int         SwigType_isqualifier(SwigType *t);
extern int         SwigType_isconst(SwigType *t);
extern int         SwigType_issimple(SwigType *t);
extern int         SwigType_ismutable(SwigType *t);
extern int         SwigType_isvarargs(const SwigType *t);
extern int         SwigType_istemplate(const SwigType *t);
extern int         SwigType_isenum(SwigType *t);
extern int         SwigType_check_decl(SwigType *t, const String_or_char *decl);
extern SwigType   *SwigType_strip_qualifiers(SwigType *t);
extern String     *SwigType_base(const SwigType *t);
extern String     *SwigType_namestr(const SwigType *t);
extern String     *SwigType_templateprefix(const SwigType *t);
extern String     *SwigType_templatesuffix(const SwigType *t);
extern String     *SwigType_templateargs(const SwigType *t);
extern String     *SwigType_prefix(const SwigType *t);
extern int         SwigType_array_ndim(SwigType *t);
extern String     *SwigType_array_getdim(SwigType *t, int n);
extern void        SwigType_array_setdim(SwigType *t, int n, const String_or_char *rep);
extern SwigType   *SwigType_array_type(SwigType *t);
extern String     *SwigType_default(SwigType *t);
extern void        SwigType_typename_replace(SwigType *t, String *pat, String *rep);
extern SwigType   *SwigType_alttype(SwigType *t, int ltmap);

extern void     SwigType_template_defargs(Parm *parms, Parm *targs, Symtab *tscope, Symtab *tsdecl);
extern SwigType*  SwigType_template_deftype(const SwigType *type, Symtab *tscope);

/* --- Type-system managment --- */
extern void        SwigType_typesystem_init();
extern int         SwigType_typedef(SwigType *type, String_or_char *name);
extern int         SwigType_typedef_class(String_or_char *name);
extern int         SwigType_typedef_using(String_or_char *qname);
extern void        SwigType_inherit(String *subclass, String *baseclass, String *cast);
extern int         SwigType_issubtype(SwigType *subtype, SwigType *basetype);
extern void        SwigType_scope_alias(String *aliasname, Typetab *t);
extern void        SwigType_using_scope(Typetab *t);
extern void        SwigType_new_scope(const String_or_char *name);
extern void        SwigType_inherit_scope(Typetab *scope);
extern Typetab    *SwigType_pop_scope();
extern Typetab    *SwigType_set_scope(Typetab *h);
extern void        SwigType_print_scope(Typetab *t);
extern SwigType   *SwigType_typedef_resolve(SwigType *t);
extern SwigType   *SwigType_typedef_resolve_all(SwigType *t);
extern SwigType   *SwigType_typedef_qualified(SwigType *t);
extern int         SwigType_istypedef(SwigType *t);
extern int         SwigType_isclass(SwigType *t);
extern void        SwigType_attach_symtab(Symtab *syms);
extern void        SwigType_remember(SwigType *t);
extern void        SwigType_remember_clientdata(SwigType *t, const String_or_char *clientdata);
extern void        SwigType_remember_mangleddata(String *mangled, const String_or_char *clientdata);
extern void      (*SwigType_remember_trace(void (*tf)(SwigType *, String *, String *)))(SwigType *, String *, String *);
extern void        SwigType_emit_type_table(File *f_headers, File *f_table);
extern int         SwigType_type(SwigType *t);

/* --- Symbol table module --- */

extern void     Swig_symbol_init();
extern void     Swig_symbol_setscopename(const String_or_char *name);
extern String   *Swig_symbol_getscopename();
extern String   *Swig_symbol_qualifiedscopename(Symtab *symtab);
extern Symtab   *Swig_symbol_newscope();
extern Symtab   *Swig_symbol_setscope(Symtab *);
extern Symtab   *Swig_symbol_getscope(const String_or_char *symname);
extern Symtab   *Swig_symbol_current();
extern Symtab   *Swig_symbol_popscope();
extern Node     *Swig_symbol_add(String_or_char *symname, Node *node);
extern void      Swig_symbol_cadd(String_or_char *symname, Node *node);
extern Node     *Swig_symbol_clookup(String_or_char *symname, Symtab *tab);
extern Node     *Swig_symbol_clookup_check(String_or_char *symname, Symtab *tab, int (*check)(Node *));
extern Symtab   *Swig_symbol_cscope(String_or_char *symname, Symtab *tab);
extern Node     *Swig_symbol_clookup_local(String_or_char *symname, Symtab *tab);
extern Node     *Swig_symbol_clookup_local_check(String_or_char *symname, Symtab *tab, int (*check)(Node *));
extern String   *Swig_symbol_qualified(Node *node);
extern Node     *Swig_symbol_isoverloaded(Node *node);
extern void      Swig_symbol_remove(Node *node);
extern void      Swig_symbol_alias(String_or_char *aliasname, Symtab *tab);
extern void      Swig_symbol_inherit(Symtab *tab);
extern SwigType *Swig_symbol_type_qualify(const SwigType *ty, Symtab *tab);
extern String   *Swig_symbol_string_qualify(String *s, Symtab *tab);
extern SwigType *Swig_symbol_typedef_reduce(SwigType *ty, Symtab *tab);

extern void     Swig_symbol_template_defargs(Parm *parms, Parm *targs, Symtab *tscope, Symtab *tsdecl);
extern SwigType *Swig_symbol_template_deftype(const SwigType *type, Symtab *tscope);
extern SwigType *Swig_symbol_template_param_eval(const SwigType *p, Symtab *symtab);

/* --- Parameters and Parameter Lists --- */

/* Parameters are really just hidden behind a DOH object.  The following
   interface will probably be simplified even further. */

extern Parm       *NewParm(SwigType *type, const String_or_char *name);
extern Parm       *NewParmFromNode(SwigType *type, const String_or_char *name, Node *n);
extern Parm       *CopyParm(Parm *p);
extern ParmList   *CopyParmList(ParmList *);
extern int         ParmList_len(ParmList *);
extern int         ParmList_numarg(ParmList *);
extern int         ParmList_numrequired(ParmList *);
extern String     *ParmList_str(ParmList *);
extern String     *ParmList_str_defaultargs(ParmList *);
extern String     *ParmList_protostr(ParmList *);
extern int         ParmList_is_compactdefargs(ParmList *p);
extern int         ParmList_has_defaultargs(ParmList *p);
extern ParmList   *ParmList_copy_all_except_last_parm(ParmList *p);

/* --- Parse tree support --- */

/* DOM-like node access */
#include "swigkeys.h"
#define  nodeType(x)               Getattr(x,k_nodetype)
#define  parentNode(x)             Getattr(x,k_parentnode)
#define  previousSibling(x)        Getattr(x,k_previoussibling)
#define  nextSibling(x)            Getattr(x,k_nextsibling)
#define  firstChild(x)             Getattr(x,k_firstchild)
#define  lastChild(x)              Getattr(x,k_lastchild)
extern int checkAttribute(Node *obj, const String_or_char *name, const String_or_char *value);

/* Macros to set up the DOM tree (mostly used by the parser) */

#define  set_nodeType(x,v)         Setattr(x,"nodeType",v)
#define  set_parentNode(x,v)       Setattr(x,"parentNode",v)
#define  set_previousSibling(x,v)  Setattr(x,"previousSibling",v)
#define  set_nextSibling(x,v)      Setattr(x,"nextSibling",v)
#define  set_firstChild(x,v)       Setattr(x,"firstChild",v)
#define  set_lastChild(x,v)        Setattr(x,"lastChild",v)

extern void appendChild(Node *node, Node *child);
extern void preppendChild(Node *node, Node *child);
extern void deleteNode(Node *node);
extern Node *copyNode(Node *node);

extern void Swig_tag_nodes(Node *node, const String_or_char *attrname, DOH *value);

extern int  Swig_require(const char *ns, Node *node, ...);
extern int  Swig_save(const char *ns, Node *node,...);
extern void Swig_restore(Node *node);

/* Debugging of parse trees */
extern void Swig_print_tags(File *obj, Node *root);
extern void Swig_print_tree(Node *obj);
extern void Swig_print_node(Node *obj);

extern void Swig_print_xml(Node *obj, String* filename);

/* -- Wrapper function Object */

typedef struct {
  Hash      *localh;
  String    *def;
  String    *locals;
  String    *code;
} Wrapper;

extern Wrapper  *NewWrapper();
extern void      DelWrapper(Wrapper *w);
extern void      Wrapper_compact_print_mode_set(int flag);
extern void      Wrapper_pretty_print(String *str, File *f);
extern void      Wrapper_compact_print(String *str, File *f);
extern void      Wrapper_print(Wrapper *w, File *f);
extern int       Wrapper_add_local(Wrapper *w, const String_or_char *name, const String_or_char *decl);
extern int       Wrapper_add_localv(Wrapper *w, const String_or_char *name, ...);
extern int       Wrapper_check_local(Wrapper *w, const String_or_char *name);
extern char     *Wrapper_new_local(Wrapper *w, const String_or_char *name, const String_or_char *decl);
extern char     *Wrapper_new_localv(Wrapper *w, const String_or_char *name, ...);

/* --- Naming functions --- */

extern void     Swig_name_register(const String_or_char *method, const String_or_char *format);
extern void     Swig_name_unregister(const String_or_char *method);
extern String  *Swig_name_mangle(const String_or_char *s);
extern String  *Swig_name_wrapper(const String_or_char *fname);
extern String  *Swig_name_member(const String_or_char *classname, const String_or_char *mname);
extern String  *Swig_name_get(const String_or_char *vname);
extern String  *Swig_name_set(const String_or_char *vname);
extern String  *Swig_name_construct(const String_or_char *classname);
extern String  *Swig_name_copyconstructor(const String_or_char *classname);
extern String  *Swig_name_destroy(const String_or_char *classname);
extern String  *Swig_name_disown(const String_or_char *classname);

extern void     Swig_naming_init();
extern void     Swig_name_namewarn_add(String *prefix, String *name, SwigType *decl, Hash *namewrn);
extern Hash    *Swig_name_namewarn_get(Node *n, String *prefix, String *name,SwigType *decl);
extern void     Swig_name_rename_add(String *prefix, String *name, SwigType *decl, Hash *namewrn, ParmList *declaratorparms);
extern void     Swig_name_inherit(String *base, String *derived);
extern int      Swig_need_protected(Node *n);
extern int      Swig_need_name_warning(Node *n);
extern int      Swig_need_redefined_warn(Node* a, Node* b, int InClass);

extern String  *Swig_name_make(Node *n, String *prefix, String *name, SwigType *decl, String *oldname);  
extern String  *Swig_name_warning(Node *n, String *prefix, String *name,SwigType *decl);

/* --- parameterized rename functions --- */

extern void      Swig_name_object_set(Hash *namehash, String_or_char *name, SwigType *decl, DOH *object);
extern DOH      *Swig_name_object_get(Hash *namehash, String_or_char *prefix, String_or_char *name, SwigType *decl);
extern void      Swig_name_object_inherit(Hash *namehash, String *base, String *derived);
extern void      Swig_features_get(Hash *features, String_or_char *prefix, String_or_char *name, SwigType *decl, Node *n);
extern void      Swig_feature_set(Hash *features, const String_or_char *name, SwigType *decl, const String_or_char *featurename, String *value, Hash *featureattribs);

/* --- Misc --- */
extern char      *Swig_copy_string(const char *c);
extern void       Swig_banner(File *f);
extern String    *Swig_string_escape(String *s);
extern String    *Swig_string_mangle(const String *s);
extern void       Swig_scopename_split(String *s, String **prefix, String **last);
extern String    *Swig_scopename_prefix(String *s);
extern String    *Swig_scopename_last(String *s);
extern String    *Swig_scopename_first(String *s);
extern String    *Swig_scopename_suffix(String *s);
extern int        Swig_scopename_check(String *s);
extern String    *Swig_string_lower(String *s);
extern String    *Swig_string_upper(String *s);
extern String    *Swig_string_title(String *s);

extern void       Swig_init();
extern void       Swig_warn(const char *filename, int line, const char *msg);

extern int        Swig_value_wrapper_mode(int mode);


#define WARNING(msg) Swig_warn(__FILE__,__LINE__,msg)

typedef enum { EMF_STANDARD, EMF_MICROSOFT } ErrorMessageFormat;

extern void       Swig_warning(int num, const String_or_char *filename, int line, const char *fmt, ...);
extern void       Swig_error(const String_or_char *filename, int line, const char *fmt, ...);
extern int        Swig_error_count(void);
extern void       Swig_error_silent(int s);
extern void       Swig_warnfilter(const String_or_char *wlist, int val);
extern void       Swig_warnall(void);
extern int        Swig_warn_count(void);
extern void       Swig_error_msg_format(ErrorMessageFormat format);

/* --- C Wrappers --- */
extern String    *Swig_cparm_name(Parm *p, int i);
extern String    *Swig_wrapped_var_type(SwigType *t, int varcref);
extern int        Swig_cargs(Wrapper *w, ParmList *l);
extern String    *Swig_cresult(SwigType *t, const String_or_char *name, const String_or_char *decl);

extern String    *Swig_cfunction_call(String_or_char *name, ParmList *parms);
extern String    *Swig_cconstructor_call(String_or_char *name);
extern String    *Swig_cppconstructor_call(String_or_char *name, ParmList *parms);
extern String    *Swig_unref_call(Node *n);
extern String    *Swig_ref_call(Node *n, const String* lname);
extern String    *Swig_cdestructor_call(Node *n);
extern String    *Swig_cppdestructor_call(Node *n);
extern String    *Swig_cmemberset_call(String_or_char *name, SwigType *type, String_or_char *self, int varcref);
extern String    *Swig_cmemberget_call(const String_or_char *name, SwigType *t, String_or_char *self, int varcref);

extern String    *Swig_extension_code(const String *function_name,
ParmList *parms, SwigType* return_type, const String *code, int cplusplus);
extern int        Swig_add_extension_code(Node *n, const String *function_name, ParmList *parms, SwigType* return_type, const String *code, int cplusplus);

/* --- Transformations --- */

extern int        Swig_MethodToFunction(Node *n, String *classname, int flags, SwigType *director_type, int is_director);
extern int        Swig_ConstructorToFunction(Node *n, String *classname, 
					     String *none_comparison,
					     String *director_ctor,
					     int cplus, int flags);
extern int        Swig_DestructorToFunction(Node *n, String *classname, int cplus, int flags);
extern int        Swig_MembersetToFunction(Node *n, String *classname, int flags);
extern int        Swig_MembergetToFunction(Node *n, String *classname, int flags);
extern int        Swig_VargetToFunction(Node *n, int flags);
extern int        Swig_VarsetToFunction(Node *n, int flags);

#define  CWRAP_EXTEND             0x01
#define  CWRAP_SMART_POINTER      0x02
#define  CWRAP_NATURAL_VAR        0x04
#define  CWRAP_DIRECTOR_ONE_CALL  0x08
#define  CWRAP_DIRECTOR_TWO_CALLS 0x10

/* --- Director Helpers --- */
extern Node      *Swig_methodclass(Node *n);
extern int        Swig_directorclass(Node *n);
extern Node      *Swig_directormap(Node *n, String *type);

/* --- Legacy Typemap API (somewhat simplified, ha!) --- */

extern     void   Swig_typemap_init();
extern     void   Swig_typemap_register(const String_or_char *op, ParmList *pattern, String_or_char *code, ParmList *locals, ParmList *kwargs);
extern     int    Swig_typemap_copy(const String_or_char *op, ParmList *srcpattern, ParmList *pattern);
extern     void   Swig_typemap_clear(const String_or_char *op, ParmList *pattern);
extern     int    Swig_typemap_apply(ParmList *srcpat, ParmList *destpat);
extern     void   Swig_typemap_clear_apply(ParmList *pattern);
extern     void   Swig_typemap_debug();

extern Hash  *Swig_typemap_search(const String_or_char *op, SwigType *type, const String_or_char *pname, SwigType **matchtype);
extern Hash  *Swig_typemap_search_multi(const String_or_char *op, ParmList *parms, int *nmatch);
extern String *Swig_typemap_lookup(const String_or_char *op, SwigType *type, String_or_char *pname, String_or_char *lname,
				  String_or_char *source, String_or_char *target, Wrapper *f);

extern String *Swig_typemap_lookup_new(const String_or_char *op, Node *n, const String_or_char *lname, Wrapper *f);
extern void Swig_typemap_attach_kwargs(Hash *tm, const String_or_char *op, Parm *p);
extern void   Swig_typemap_new_scope();
extern Hash  *Swig_typemap_pop_scope();

extern void   Swig_typemap_attach_parms(const String_or_char *op, ParmList *parms, Wrapper *f);

/* --- Code fragment support --- */

extern  void  Swig_fragment_register(Node* fragment);
extern  void  Swig_fragment_emit(String *name);

/* hacks defined in C++ ! */
extern  int  Swig_director_mode();
extern void  Wrapper_director_mode_set(int);


/* -- template init -- */
extern void SwigType_template_init();


#ifdef __cplusplus
}
#endif

#endif

