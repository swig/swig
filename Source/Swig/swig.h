/* ----------------------------------------------------------------------------- 
 * swig.h
 *
 *     Header file for the SWIG core.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *             Dustin Mitchell (djmitche@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#ifndef _SWIGCORE_H
#define _SWIGCORE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>

#include "doh.h"

/* Short names for common data types */

typedef  DOH     String;
typedef  DOH     Hash;
typedef  DOH     List;
typedef  DOH     String_or_char;
typedef  DOH     File;

/* --- Legacy DataType interface.  These type codes are provided solely 
   for backwards compatibility with older modules --- */

#define   T_INT        1
#define   T_SHORT      2
#define   T_LONG       3
#define   T_UINT       4
#define   T_USHORT     5
#define   T_ULONG      6
#define   T_UCHAR      7
#define   T_SCHAR      8
#define   T_BOOL       9
#define   T_DOUBLE     10
#define   T_FLOAT      11
#define   T_CHAR       12
#define   T_USER       13
#define   T_VOID       14
#define   T_ENUM       15
#define   T_STRING     20
#define   T_POINTER    21
#define   T_REFERENCE  22
#define   T_ARRAY      23
#define   T_FUNCTION   24
#define   T_SYMBOL     98
#define   T_ERROR      99

/* --- File interface --- */

extern void     Swig_add_directory(const String_or_char *dirname);
extern String  *Swig_last_file();
extern List    *Swig_search_path();
extern FILE    *Swig_open(const String_or_char *name);
extern String  *Swig_read_file(FILE *f);
extern String  *Swig_include(const String_or_char *name);
extern int      Swig_insert_file(const String_or_char *name, File *outfile);
extern int      Swig_bytes_read();
extern void     Swig_register_filebyname(const String_or_char *name, File *outfile);
extern File    *Swig_filebyname(const String_or_char *name);
extern void     Swig_swiglib_set(const String_or_char *name);
extern String  *Swig_swiglib_get();

#define OUTFILE(x)   Swig_filebyname(x)

#ifdef MACSWIG
#define  SWIG_FILE_DELIMETER   ":"
#else
#define  SWIG_FILE_DELIMETER   "/"
#endif

/* --- Command line parsing --- */

extern void     Swig_init_args(int argc, char **argv);
extern void     Swig_mark_arg(int n);
extern int      Swig_check_marked(int n);
extern void     Swig_check_options();
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
#define   SWIG_TOKEN_ILLEGAL      98
#define   SWIG_TOKEN_LAST         99 

/* --- Functions for manipulating the string-based type encoding --- */
typedef DOH SwigType;

extern SwigType   *NewSwigType(int typecode);
extern void        SwigType_add_pointer(SwigType *t);
extern void        SwigType_del_pointer(SwigType *t);
extern void        SwigType_add_array(SwigType *t, String_or_char *size);
extern void        SwigType_add_reference(SwigType *t);
extern void        SwigType_add_qualifier(SwigType *t, String_or_char *qual);
extern void        SwigType_add_function(SwigType *t, List *parms);
extern List       *SwigType_split(SwigType *t);
extern String     *SwigType_pop(SwigType *t);
extern void        SwigType_push(SwigType *t, SwigType *s);
extern List       *SwigType_parmlist(SwigType *p);
extern String     *SwigType_parm(String *p);
extern String     *SwigType_str(SwigType *s, const String_or_char *id);
extern String     *SwigType_lstr(SwigType *s, const String_or_char *id);
extern String     *SwigType_rcaststr(SwigType *s, const String_or_char *id);
extern String     *SwigType_lcaststr(SwigType *s, const String_or_char *id);
extern String     *SwigType_manglestr(SwigType *t);
extern SwigType   *SwigType_ltype(SwigType *t);
extern int         SwigType_ispointer(SwigType *t);
extern int         SwigType_isreference(SwigType *t);
extern int         SwigType_isarray(SwigType *t);
extern int         SwigType_isfunction(SwigType *t);
extern int         SwigType_isqualifier(SwigType *t);
extern int         SwigType_isconst(SwigType *t);

extern String     *SwigType_base(SwigType *t);
extern String     *SwigType_prefix(SwigType *t);
extern void        SwigType_setbase(SwigType *t, String_or_char *name);

extern int         SwigType_typedef(SwigType *type, String_or_char *name);
extern void        SwigType_inherit(String *subclass, String *baseclass);
extern void        SwigType_new_scope();
extern void        SwigType_reset_scopes();
extern void        SwigType_set_scope_name(String_or_char *name);
extern void        SwigType_merge_scope(Hash *scope, String_or_char *prefix);
extern Hash       *SwigType_pop_scope();
extern SwigType   *SwigType_typedef_resolve(SwigType *t);
extern SwigType   *SwigType_typedef_resolve_all(SwigType *t);
extern int         SwigType_istypedef(SwigType *t);
extern int         SwigType_cmp(String_or_char *pat, SwigType *t);
extern int         SwigType_array_ndim(SwigType *t);
extern String     *SwigType_array_getdim(SwigType *t, int n);
extern void        SwigType_array_setdim(SwigType *t, int n, String_or_char *rep);
extern String     *SwigType_default(SwigType *t);
extern int         SwigType_type(SwigType *t);
extern void        SwigType_remember(SwigType *t);
extern void        SwigType_emit_type_table(File *f_headers, File *f_table);

/* --- Parameters and Parameter Lists --- */

/* Parameters are really just hidden behind a DOH object.  The following
   interface will probably be simplified even further. */

typedef DOH Parm;

extern Parm       *NewParm(SwigType *type, String_or_char *n);
extern Parm       *CopyParm(Parm *p);

typedef DOH   ParmList;

extern ParmList   *CopyParmList(ParmList *);
extern int         ParmList_len(ParmList *);
extern int         ParmList_numarg(ParmList *);
extern String     *ParmList_str(ParmList *);
extern String     *ParmList_protostr(ParmList *);

/* --- Parse tree support --- */

typedef struct {
   const char *name;
   int  (*action)(DOH *obj, void *clientdata);
} SwigRule;


#define SWIG_OK       1
#define SWIG_NORULE   0
#define SWIG_ERROR   -1

extern void Swig_add_rule(const String_or_char *, int (*action)(DOH *, void *));
extern void Swig_add_rules(SwigRule ruleset[]);
extern void Swig_clear_rules();
extern int  Swig_tag_check(DOH *obj, String_or_char *tagname);
extern int  Swig_emit(DOH *obj, void *clientdata);
extern int  Swig_emit_all(DOH *obj, void *clientdata);
extern void Swig_set_callback(DOH *obj, void (*cb)(void *clientdata), void *clientdata);
extern void (*Swig_set_trace(DOH *obj, void (*cb)(DOH *, DOH *), DOH *arg))(DOH *, DOH *);
extern void Swig_remove_trace(DOH *obj);
extern void Swig_node_cut(DOH *obj);
extern void Swig_node_insert(DOH *node, DOH *newnode);
extern void Swig_node_temporary(DOH *node);
extern void Swig_node_ignore(DOH *node);
extern int  Swig_count_nodes(DOH *node);

extern DOH *Swig_next(DOH *obj);
extern DOH *Swig_prev(DOH *obj);

/* Debugging of parse trees */
extern void Swig_debug_emit(int);
extern void Swig_dump_tags(DOH *obj, DOH *root);
extern void Swig_dump_tree(DOH *obj);
extern void Swig_dump_rules();

/* -- Wrapper function Object */

typedef DOH Wrapper;

extern Wrapper  *NewWrapper();
extern void      Wrapper_pretty_print(String *str, File *f);
extern int       Wrapper_add_local(Wrapper *w, const String_or_char *name, const String_or_char *decl);
extern int       Wrapper_add_localv(Wrapper *w, const String_or_char *name, ...);
extern int       Wrapper_check_local(Wrapper *w, const String_or_char *name);
extern char     *Wrapper_new_local(Wrapper *w, const String_or_char *name, const String_or_char *decl);
extern char     *Wrapper_new_localv(Wrapper *w, const String_or_char *name, ...);

/* --- Naming functions --- */

extern void     Swig_name_register(String_or_char *method, String_or_char *format);
extern String  *Swig_name_mangle(String_or_char *s);
extern String  *Swig_name_wrapper(String_or_char *fname);
extern String  *Swig_name_member(String_or_char *classname, String_or_char *mname);
extern String  *Swig_name_get(String_or_char *vname);
extern String  *Swig_name_set(String_or_char *vname);
extern String  *Swig_name_construct(String_or_char *classname);
extern String  *Swig_name_destroy(String_or_char *classname);

/* --- Mapping interface --- */

extern void       Swig_map_add(Hash *ruleset, Hash *parms, DOH *obj);
extern DOH       *Swig_map_match(Hash *ruleset, Hash *parms, int *nmatch);

/* --- Misc --- */
extern char      *Swig_copy_string(const char *c);
extern void       Swig_banner(File *f);
extern DOH       *Swig_temp_result(DOH *x);
extern String    *Swig_string_escape(String *s);
extern String    *Swig_string_mangle(String *s);
extern void       Swig_init();

/* --- C Wrappers --- */
extern String    *Swig_clocal(SwigType *t, String_or_char *name, String_or_char *value);
extern SwigType  *Swig_clocal_type(SwigType *t);
extern String    *Swig_clocal_deref(SwigType *t, String_or_char *name);
extern String    *Swig_clocal_assign(SwigType *t, String_or_char *name);
extern String    *Swig_cparm_name(Parm *p, int i);
extern int        Swig_cargs(Wrapper *w, ParmList *l);
extern void       Swig_cresult(Wrapper *w, SwigType *t, String_or_char *name, String_or_char *decl);
extern void       Swig_cppresult(Wrapper *w, SwigType *t, String_or_char *name, String_or_char *decl);
extern String    *Swig_cfunction_call(String_or_char *name, ParmList *parms);
extern String    *Swig_cmethod_call(String_or_char *name, ParmList *parms);
extern String    *Swig_cconstructor_call(String_or_char *name);
extern String    *Swig_cppconstructor_call(String_or_char *name, ParmList *parms);
extern String    *Swig_cdestructor_call();
extern String    *Swig_cppdestructor_call();
extern String    *Swig_cmemberset_call(String_or_char *name, SwigType *t);
extern String    *Swig_cmemberget_call(String_or_char *name, SwigType *t);

extern Wrapper   *Swig_cfunction_wrapper(String_or_char *funcname,
                                         SwigType *rtype,
                                         ParmList *parms,
                                         String_or_char *code);

extern Wrapper   *Swig_cmethod_wrapper(String_or_char *classname,
				       String_or_char *methodname,
				       SwigType *rtype,
				       ParmList *parms,
				       String_or_char *code);

extern Wrapper   *Swig_cdestructor_wrapper(String_or_char *classname,
                                           String_or_char *code);

extern Wrapper   *Swig_cppdestructor_wrapper(String_or_char *classname,
					     String_or_char *code);

extern Wrapper   *Swig_cconstructor_wrapper(String_or_char *classname,
                                            ParmList *parms,
                                            String_or_char *code);

extern Wrapper   *Swig_cppconstructor_wrapper(String_or_char *classname,
					      ParmList *parms,
					      String_or_char *code);


extern Wrapper   *Swig_cmemberset_wrapper(String_or_char *classname,
                                          String_or_char *membername,
					  SwigType *type,
                                          String_or_char *code);

extern Wrapper   *Swig_cmemberget_wrapper(String_or_char *classname,
                                          String_or_char *membername,
					  SwigType *type,
                                          String_or_char *code);

extern Wrapper   *Swig_cvarset_wrapper(String_or_char *varname,
				       SwigType *type,
				       String_or_char *code);

extern Wrapper   *Swig_cvarget_wrapper(String_or_char *varname,
				       SwigType *type,
				       String_or_char *code);


/* --- Module loader and handler --- */

typedef struct Module Module;
extern void   Swig_register_module(const String_or_char *modname, const String_or_char *starttag,
				   int (*initfunc)(int, char **),
				   DOH *(*startfunc)(DOH *));

extern Module *Swig_load_module(const String_or_char *modname);
extern int     Swig_init_module(Module *m, int argc, char **argv);
extern DOH    *Swig_start_module(Module *m, DOH *obj);
extern DOH    *Swig_run_modules(DOH *node);

/* --- Legacy Typemap API (somewhat simplified) --- */

extern void   Swig_typemap_init();
extern void   Swig_typemap_register(char *op, SwigType *type, String_or_char *name, String_or_char *code, ParmList *locals);
extern void   Swig_typemap_copy(char *op, SwigType *stype, String_or_char *sname,
				SwigType *ttype, String_or_char *tname);
extern void   Swig_typemap_clear(char *op, SwigType *type, String_or_char *name);
extern void   Swig_typemap_apply(SwigType *tm_type, String_or_char *tmname, SwigType *type, String_or_char *pname);
extern void   Swig_typemap_clear_apply(SwigType *type, String_or_char *pname);
extern void   Swig_typemap_debug();
extern Hash  *Swig_typemap_search(char *op, SwigType *type, String_or_char *pname);
extern char  *Swig_typemap_lookup(char *op, SwigType *type, String_or_char *pname, String_or_char *source, String_or_char *target, Wrapper *f);
extern void   Swig_typemap_new_scope();
extern Hash  *Swig_typemap_pop_scope();

/* --- Legacy %except directive API --- */
extern void   Swig_except_register(String_or_char *code);
extern char  *Swig_except_lookup();
extern void   Swig_except_clear();

/* --- Attribute access macros --- */

#define Gettype(x)         Getattr(x,"type")
#define Getname(x)         Getattr(x,"name")
#define Getvalue(x)        Getattr(x,"value")
#define Getlname(x)        Getattr(x,"lname")
#define Getignore(x)       GetInt(x,"ignore")
#define Getparms(x)        Getattr(x,"parms")

#define Settype(x,v)       Setattr(x,"type",x)
#define Setname(x,v)       Setattr(x,"name",v)
#define Setlname(x,v)      Setattr(x,"lname",v)
#define Setvalue(x,v)      Setattr(x,"value", v)
#define Setignore(x,v)     SetInt(x,"ignore",v)

#define Getnext(x)         Getattr(x,"next")
#define Setnext(x,n)       Setattr(x,"next",n)
#define Getchild(x)        Getattr(x,"child")

extern int Swig_main(int argc, char *argv[]);

#endif





