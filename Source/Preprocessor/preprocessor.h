/* -----------------------------------------------------------------------------
 * preprocessor.h
 *
 *     SWIG preprocessor module.
 *
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#ifndef PREPROCESSOR_H_
#define PREPROCESSOR_H_

#include "swigwarn.h"

#ifdef __cplusplus
extern "C" {
#endif
extern int     Preprocessor_expr(String *s, int *error);
extern char   *Preprocessor_expr_error(void);
extern Hash   *Preprocessor_define(const String_or_char *str, int swigmacro);
extern void    Preprocessor_undef(const String_or_char *name);
extern void    Preprocessor_init(void);
extern void    Preprocessor_delete(void);
extern String *Preprocessor_parse(String *s);
extern void    Preprocessor_include_all(int);
extern void    Preprocessor_import_all(int);
extern void    Preprocessor_ignore_missing(int);
extern void    Preprocessor_error_as_warning(int);
extern List   *Preprocessor_depend(void);
extern void    Preprocessor_expr_init(void);
extern void    Preprocessor_expr_delete(void);

#ifdef __cplusplus
}
#endif

#endif




