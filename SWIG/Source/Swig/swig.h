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

/* --- Legacy DataType interface.  This is being replaced --- */

#define    T_INT        1
#define    T_SHORT      2
#define    T_LONG       3
#define    T_UINT       4
#define    T_USHORT     5
#define    T_ULONG      6
#define    T_UCHAR      7
#define    T_SCHAR      8
#define    T_BOOL       9
#define    T_DOUBLE     10
#define    T_FLOAT      11
#define    T_CHAR       12
#define    T_USER       13
#define    T_VOID       14
#define    T_STRING     20
#define    T_POINTER    21
#define    T_REFERENCE  22
#define    T_ARRAY      23

#define    T_SYMBOL    98
#define    T_ERROR     99

#define MAX_NAME 96

typedef struct DataType {
  int         _type;            /* SWIG Type code */
  char        _name[MAX_NAME];  /* Name of type   */
  int         _is_pointer;       /* Is this a pointer */
  int         _implicit_ptr;    /* Implicit ptr */
  int         _is_reference;    /* A C++ reference type */
  int         _status;          /* Is this datatype read-only? */
  char        *_qualifier;      /* A qualifier string (ie. const). */
  char        *_arraystr;       /* String containing array part */
  int         _id;              /* type identifier (unique for every type). */
} DataType;

extern DataType *NewDataType(int type);
extern DataType *CopyDataType(DataType *type);
extern void      DelDataType(DataType *type);

int     DataType_type(DataType *t);
int     DataType_Gettypecode(DataType *t);
void    DataType_Settypecode(DataType *t, int type);
void    DataType_Setname(DataType *t, char *name);
char   *DataType_Getname(DataType *t);

/* -- New type interface -- */

extern char     *DataType_str(DataType *, DOHString_or_char *name);         /* Exact datatype           */
extern char     *DataType_lstr(DataType *, DOHString_or_char *name);        /* Assignable datatype      */
extern char     *DataType_rcaststr(DataType *, DOHString_or_char *name);    /* Cast from lstr to str    */
extern char     *DataType_lcaststr(DataType *, DOHString_or_char *name);    /* Cast from str to lstr    */
extern char     *DataType_manglestr(DataType *t);                           /* Mangled type name        */
extern DataType *DataType_ltype(DataType *);                                /* Create local type object */

void             DataType_add_reference(DataType *t);
int              DataType_is_reference(DataType *t);
int              DataType_is_pointer(DataType *t);
void             DataType_add_pointer(DataType *t);
void             DataType_del_pointer(DataType *t);

/* -- Old type interface. This is going away -- */

extern char     *DataType_qualifier(DataType *);
extern void      DataType_set_qualifier(DataType *, char *q);
extern char     *DataType_arraystr(DataType *);
extern void      DataType_set_arraystr(DataType *, char *a);

extern char     *DataType_mangle_default(DataType *t);                     /* Default name mangler */
extern void      DataType_primitive(DataType *);
extern void      DataType_set_mangle(char *(*m)(DataType *));
extern int       DataType_array_dimensions(DataType *);
extern char     *DataType_get_dimension(DataType *, int);

/* Typedef support */
extern int       DataType_typedef_add(DataType *, char *name, int mode);
extern void      DataType_typedef_resolve(DataType *, int level);
extern void      DataType_typedef_replace(DataType *);
extern int       DataType_is_typedef(char *name);
extern void      DataType_updatestatus(DataType *, int newstatus);
extern void      DataType_init_typedef();
extern void      DataType_merge_scope(DOHHash *h);
extern void      DataType_new_scope(DOHHash *h);
extern void     *DataType_collapse_scope(char *name);
extern void      DataType_remember(DataType *);
extern void      DataType_record_base(char *derived, char *base);
extern int       type_id;
extern void      emit_ptr_equivalence(DOHFile *tablef, DOHFile *initf);
extern void      emit_type_table(DOHFile *out);
extern void      typeeq_derived(char *n1, char *n2, char *cast);
extern void      typeeq_addtypedef(char *name, char *eqname, DataType *t);

#define STAT_REPLACETYPE   2

/* --- Parameters and Parameter Lists --- */

/* Parameters are really just hidden behind a DOH object.  The following
   interface will probably be simplified even further. */

typedef DOH Parm;

extern Parm       *NewParm(DataType *type, char *n);
extern Parm       *CopyParm(Parm *p);

typedef DOH   ParmList;

extern ParmList   *NewParmList();
extern ParmList   *CopyParmList(ParmList *);

extern int         ParmList_numarg(ParmList *);
extern char       *ParmList_str(ParmList *);
extern char       *ParmList_protostr(ParmList *);

/* --- File interface --- */

extern void        Swig_add_directory(const DOHString_or_char *dirname);
extern DOHString  *Swig_last_file();
extern DOHList    *Swig_search_path();
extern FILE       *Swig_open(const DOHString_or_char *name);
extern DOHString  *Swig_read_file(FILE *f);
extern DOHString  *Swig_include(const DOHString_or_char *name);
extern int         Swig_insert_file(const DOHString_or_char *name, DOHFile *outfile);
extern int         Swig_bytes_read();

#define  SWIG_FILE_DELIMETER   "/"

/* --- Command line parsing --- */

extern void  Swig_init_args(int argc, char **argv);
extern void  Swig_mark_arg(int n);
extern void  Swig_check_options();
extern void  Swig_arg_error();

/* --- Scanner Interface --- */

typedef struct SwigScanner SwigScanner;

extern SwigScanner *NewSwigScanner();
extern void         DelSwigScanner(SwigScanner *);
extern void         SwigScanner_clear(SwigScanner *);
extern void         SwigScanner_push(SwigScanner *, DOHString *);
extern void         SwigScanner_pushtoken(SwigScanner *, int);
extern int          SwigScanner_token(SwigScanner *);
extern DOHString   *SwigScanner_text(SwigScanner *);
extern void         SwigScanner_skip_line(SwigScanner *);
extern int          SwigScanner_skip_balanced(SwigScanner *, int startchar, int endchar);
extern void         SwigScanner_set_location(SwigScanner *, DOHString *file, int line);
extern DOHString   *SwigScanner_get_file(SwigScanner *);
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

extern void        SwigType_add_pointer(DOHString *t);
extern void        SwigType_add_array(DOHString *t, DOHString_or_char *size);
extern void        SwigType_add_reference(DOHString *t);
extern void        SwigType_add_qualifier(DOHString *t, DOHString_or_char *qual);
extern void        SwigType_add_function(DOHString *t, DOHList *parms);
extern DOHList    *SwigType_split(DOHString *t);
extern DOHString  *SwigType_pop(DOHString *t);
extern void        SwigType_push(DOHString *t, DOHString *s);
extern DOHList    *SwigType_parmlist(DOHString *p);
extern DOHString  *SwigType_parm(DOHString *p);
extern DOHString  *SwigType_cstr(DOHString *s, DOHString_or_char *id);
extern int         SwigType_ispointer(DOHString_or_char *t);
extern int         SwigType_isreference(DOHString_or_char *t);
extern int         SwigType_isarray(DOHString_or_char *t);
extern int         SwigType_isfunction(DOHString_or_char *t);
extern int         SwigType_isqualifier(DOHString_or_char *t);
extern DOHString  *SwigType_base(DOHString_or_char *t);
extern DOHString  *SwigType_prefix(DOHString_or_char *t);

extern int         SwigType_typedef(DOHString_or_char *type, DOHString_or_char *name);
extern void        SwigType_new_scope();
extern void        SwigType_reset_scopes();
extern void        SwigType_set_scope_name(DOHString_or_char *name);
extern void        SwigType_merge_scope(DOHHash *scope, DOHString_or_char *prefix);
extern DOHHash    *SwigType_pop_scope();
extern DOHString  *SwigType_typedef_resolve(DOHString_or_char *t);
extern int         SwigType_istypedef(DOHString_or_char *t);
extern int         SwigType_cmp(DOHString_or_char *pat, DOHString_or_char *t);
extern int         SwigType_array_ndim(DOHString_or_char *t);
extern DOHString  *SwigType_array_getdim(DOHString_or_char *t, int n);
extern void        SwigType_array_setdim(DOHString_or_char *t, int n, DOHString_or_char *rep);
extern DOHString  *SwigType_default(DOHString_or_char *t);

/* --- Parse tree support --- */

typedef struct {
   char *name;
   int  (*action)(DOH *obj, void *clientdata);
} SwigRule;

extern void Swig_dump_tags(DOH *obj, DOH *root);
extern void Swig_add_rule(DOHString_or_char *, int (*action)(DOH *, void *));
extern void Swig_add_rules(SwigRule ruleset[]);
extern void Swig_clear_rules();
extern int  Swig_emit(DOH *obj, void *clientdata);
extern void Swig_cut_node(DOH *obj);
extern DOH *Swig_next(DOH *obj);
extern DOH *Swig_prev(DOH *obj);

/* -- Wrapper function Object */

typedef struct {
  DataType  *_type;
  ParmList  *_parms;
  DOHString *_name;
  DOHHash   *localh;
  DOHString *def;
  DOHString *locals;
  DOHString *code;
} Wrapper;

extern Wrapper  *NewWrapper();
extern void      DelWrapper(Wrapper *w);
extern void      Wrapper_print(Wrapper *w, DOHFile *f);
extern int       Wrapper_add_local(Wrapper *w, const DOHString_or_char *name, const DOHString_or_char *decl);
extern int       Wrapper_add_localv(Wrapper *w, const DOHString_or_char *name, ...);
extern int       Wrapper_check_local(Wrapper *w, const DOHString_or_char *name);
extern char     *Wrapper_new_local(Wrapper *w, const DOHString_or_char *name, const DOHString_or_char *decl);
extern char     *Wrapper_new_localv(Wrapper *w, const DOHString_or_char *name, ...);
extern DataType *Wrapper_Gettype(Wrapper *w);
extern void      Wrapper_Settype(Wrapper *w, DataType *t);
extern ParmList *Wrapper_Getparms(Wrapper *w);
extern void      Wrapper_Setparms(Wrapper *w, ParmList *l);
extern char     *Wrapper_Getname(Wrapper *w);
extern void      Wrapper_Setname(Wrapper *w, DOHString_or_char *name);

/* --- Naming functions --- */

extern void        Swig_name_register(DOHString_or_char *method, DOHString_or_char *format);
extern char       *Swig_name_mangle(DOHString_or_char *s);
extern char       *Swig_name_wrapper(DOHString_or_char *fname);
extern char       *Swig_name_member(DOHString_or_char *classname, DOHString_or_char *mname);
extern char       *Swig_name_get(DOHString_or_char *vname);
extern char       *Swig_name_set(DOHString_or_char *vname);
extern char       *Swig_name_construct(DOHString_or_char *classname);
extern char       *Swig_name_destroy(DOHString_or_char *classname);

/* --- Mapping interface --- */

extern void        Swig_map_add(DOHHash *ruleset, DOHHash *parms, DOH *obj);
extern DOH        *Swig_map_match(DOHHash *ruleset, DOHHash *parms, int *nmatch);

/* --- Misc --- */
extern char *Swig_copy_string(const char *c);
extern void  Swig_banner(DOHFile *f);

/* --- C Wrappers --- */
extern char      *Swig_clocal(DataType *t, DOHString_or_char *name, DOHString_or_char *value);
extern DataType  *Swig_clocal_type(DataType *t);
extern char      *Swig_clocal_deref(DataType *t, DOHString_or_char *name);
extern char      *Swig_clocal_assign(DataType *t, DOHString_or_char *name);
extern char      *Swig_cparm_name(Parm *p, int i);
extern int        Swig_cargs(Wrapper *w, ParmList *l);
extern void       Swig_cresult(Wrapper *w, DataType *t, DOHString_or_char *name, DOHString_or_char *decl);
extern void       Swig_cppresult(Wrapper *w, DataType *t, DOHString_or_char *name, DOHString_or_char *decl);
extern char      *Swig_cfunction_call(DOHString_or_char *name, ParmList *parms);
extern char      *Swig_cmethod_call(DOHString_or_char *name, ParmList *parms);
extern char      *Swig_cconstructor_call(DOHString_or_char *name);
extern char      *Swig_cppconstructor_call(DOHString_or_char *name, ParmList *parms);
extern char      *Swig_cdestructor_call();
extern char      *Swig_cppdestructor_call();
extern char      *Swig_cmemberset_call(DOHString_or_char *name, DataType *t);
extern char      *Swig_cmemberget_call(DOHString_or_char *name, DataType *t);

extern Wrapper   *Swig_cfunction_wrapper(DOHString_or_char *funcname,
                                         DataType *rtype,
                                         ParmList *parms,
                                         DOHString_or_char *code);

extern Wrapper   *Swig_cmethod_wrapper(DOHString_or_char *classname,
				       DOHString_or_char *methodname,
				       DataType *rtype,
				       ParmList *parms,
				       DOHString_or_char *code);

extern Wrapper   *Swig_cdestructor_wrapper(DOHString_or_char *classname,
                                           DOHString_or_char *code);

extern Wrapper   *Swig_cppdestructor_wrapper(DOHString_or_char *classname,
					     DOHString_or_char *code);

extern Wrapper   *Swig_cconstructor_wrapper(DOHString_or_char *classname,
                                            ParmList *parms,
                                            DOHString_or_char *code);

extern Wrapper   *Swig_cppconstructor_wrapper(DOHString_or_char *classname,
					      ParmList *parms,
					      DOHString_or_char *code);


extern Wrapper   *Swig_cmemberset_wrapper(DOHString_or_char *classname,
                                          DOHString_or_char *membername,
					  DataType *type,
                                          DOHString_or_char *code);

extern Wrapper   *Swig_cmemberget_wrapper(DOHString_or_char *classname,
                                          DOHString_or_char *membername,
					  DataType *type,
                                          DOHString_or_char *code);

extern Wrapper   *Swig_cvarset_wrapper(DOHString_or_char *varname,
				       DataType *type,
				       DOHString_or_char *code);

extern Wrapper   *Swig_cvarget_wrapper(DOHString_or_char *varname,
				       DataType *type,
				       DOHString_or_char *code);


/* --- Attribute access macros --- */

#define Gettype(x)         ((DataType *) GetVoid(x,"type"))
#define Getname(x)         GetChar(x,"name")
#define Getvalue(x)        GetChar(x,"value")
#define Getlname(x)        GetChar(x,"lname")
#define Getignore(x)       GetInt(x,"ignore")

#define Settype(x,v)       Setattr(x,"type",NewVoid(CopyDataType(v), (void (*)(void *)) DelDataType));
#define Setname(x,v)       SetChar(x,"name",Char(v))
#define Setlname(x,v)      SetChar(x,"lname",Char(v))
#define Setvalue(x,v)      SetChar(x,"value", Char(v))
#define Setignore(x,v)     SetInt(x,"ignore",v)

#define Getnext(x)         Getattr(x,"next")
#define Setnext(x,n)       Setattr(x,"next",n)

#endif





