/****************************************************************************
 * Simplified Wrapper and Interface Generator  (SWIG)
 * 
 * Author : David Beazley
 *
 * Department of Computer Science        
 * University of Chicago
 * 1100 E 58th Street
 * Chicago, IL  60637
 * beazley@cs.uchicago.edu
 *
 * Please read the file LICENSE for the copyright and terms by which SWIG
 * can be used and distributed.
 ****************************************************************************/

#ifndef _PREPROCESSOR_H
#define _PREPROCESSOR_H

#include "swig.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int   Preprocessor_expr(DOH *s, int *error);
extern char *Preprocessor_expr_error(void);
extern DOH  *Preprocessor_define(DOH *str, int swigmacro);
extern void  Preprocessor_undef(DOH *name);
extern void  Preprocessor_init();
extern DOH  *Preprocessor_parse(DOH *s);
extern void  Preprocessor_include_all(int);

#ifdef __cplusplus
}
#endif

#endif




