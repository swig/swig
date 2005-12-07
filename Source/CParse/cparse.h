/* -----------------------------------------------------------------------------
 * cparse.h
 *
 *     SWIG parser module.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2003.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#ifndef CPARSE_H_
#define CPARSE_H_

#include "swig.h"
#include "swigwarn.h"

#ifdef __cplusplus
extern "C" {
#endif

/* cscanner.c */
extern char     *cparse_file;
extern int       cparse_line;
extern int       cparse_cplusplus;
extern int       cparse_start_line;

extern void      Swig_cparse_cplusplus(int);
extern void      scanner_file(File *);
extern void      scanner_next_token(int);
extern void      skip_balanced(int startchar, int endchar);
extern void      skip_decl(void);
extern void      scanner_check_typedef(void);
extern void      scanner_ignore_typedef(void);
extern void      scanner_last_id(int);
extern void      scanner_clear_rename(void);
extern void      start_inline(char *, int);
extern String   *scanner_ccode;
extern int       yylex();

/* parser.y */
extern SwigType *Swig_cparse_type(String *);
extern Node     *Swig_cparse(File *);
extern Hash     *Swig_cparse_namewarn();
extern Hash     *Swig_cparse_features();
extern void      SWIG_cparse_set_compact_default_args(int defargs);
extern int       SWIG_cparse_template_reduce(int treduce);

/* util.c */
extern void      Swig_cparse_replace_descriptor(String *s);
extern void      cparse_normalize_void(Node *);
extern int       need_protected(Node *n, int dirprot_mode);
extern Parm     *Swig_cparse_parm(String *s);
extern int       need_name_warning(Node *n);
extern int       need_redefined_warn(Node* a, Node* b, int InClass);


/* templ.c */
extern int       Swig_cparse_template_expand(Node *n, String *rname, ParmList *tparms, Symtab *tscope);
extern Node     *Swig_cparse_template_locate(String *name, ParmList *tparms, Symtab *tscope);
extern void      Swig_cparse_debug_templates(int);

#ifdef __cplusplus
}
#endif


#endif
