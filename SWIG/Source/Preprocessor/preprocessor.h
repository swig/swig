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

#ifndef _PREPROCESSOR_H
#define _PREPROCESSOR_H

#include "swig.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int   Preprocessor_expr(DOHString *s, int *error);
extern char *Preprocessor_expr_error(void);
extern DOH  *Preprocessor_define(DOHString_or_char *str, int swigmacro);
extern void  Preprocessor_undef(DOHString_or_char *name);
extern void  Preprocessor_init();
extern DOH  *Preprocessor_parse(DOHString *s);
extern void  Preprocessor_include_all(int);

#ifdef __cplusplus
}
#endif

#endif




