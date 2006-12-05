/* -----------------------------------------------------------------------------
 * See the LICENSE file for information on copyright, usage and redistribution
 * of SWIG, and the README file for authors - http://www.swig.org/release.html.
 *
 * cparse.h
 *
 * SWIG parser module.
 * ----------------------------------------------------------------------------- */

/* $Id$ */

#ifndef SWIG_CPARSE_H_
#define SWIG_CPARSE_H_

#include "swig.h"
#include "swigwarn.h"

#ifdef __cplusplus
extern "C" {
#endif

/* cscanner.c */
  extern char *cparse_file;
  extern int cparse_line;
  extern int cparse_cplusplus;
  extern int cparse_start_line;

  extern void Swig_cparse_cplusplus(int);
  extern void scanner_file(File *);
  extern void scanner_next_token(int);
  extern void skip_balanced(int startchar, int endchar);
  extern void skip_decl(void);
  extern void scanner_check_typedef(void);
  extern void scanner_ignore_typedef(void);
  extern void scanner_last_id(int);
  extern void scanner_clear_rename(void);
  extern void start_inline(char *, int);
  extern String *scanner_ccode;
  extern int yylex();

/* parser.y */
  extern SwigType *Swig_cparse_type(String *);
  extern Node *Swig_cparse(File *);
  extern Hash *Swig_cparse_features();
  extern void SWIG_cparse_set_compact_default_args(int defargs);
  extern int SWIG_cparse_template_reduce(int treduce);

/* util.c */
  extern void Swig_cparse_replace_descriptor(String *s);
  extern void cparse_normalize_void(Node *);
  extern Parm *Swig_cparse_parm(String *s);
  extern ParmList *Swig_cparse_parms(String *s);


/* templ.c */
  extern int Swig_cparse_template_expand(Node *n, String *rname, ParmList *tparms, Symtab *tscope);
  extern Node *Swig_cparse_template_locate(String *name, ParmList *tparms, Symtab *tscope);
  extern void Swig_cparse_debug_templates(int);

#ifdef __cplusplus
}
#endif
#define SWIG_WARN_NODE_BEGIN(Node) \
 { \
  String *wrnfilter = Node ? Getattr(Node,"feature:warnfilter") : 0; \
  if (wrnfilter) Swig_warnfilter(wrnfilter,1)
#define SWIG_WARN_NODE_END(Node) \
  if (wrnfilter) Swig_warnfilter(wrnfilter,0); \
 }
#endif
