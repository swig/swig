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

/* --- Super Strings --- */

extern DOH *NewSuperString(char *s, DOH *filename, int firstline);
extern int SuperString_check(DOH *s);

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
  DOHHash   *localh;
  DOHString *def;
  DOHString *locals;
  DOHString *code;
} SwigWrapper;

extern SwigWrapper *NewSwigWrapper();
extern void         DelSwigWrapper(SwigWrapper *w);
extern void         SwigWrapper_print(SwigWrapper *w, DOHFile *f);
extern int          SwigWrapper_add_local(SwigWrapper *w, DOHString_or_char *decl, DOHString_or_char *name);
extern int          SwigWrapper_check_local(SwigWrapper *w, DOHString_or_char *name);

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

extern void        Swig_map_add(DOHHash *ruleset, DOHString_or_char *rulename, DOHHash *parms, DOH *obj);
extern DOH        *Swig_map_match(DOHHash *ruleset, DOHString_or_char *rulename, DOHHash *parms, int *nmatch);

/* --- Misc --- */
extern char *Swig_copy_string(const char *c);
extern void  Swig_banner(DOHFile *f);

#endif




