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

#ifndef _SWIGCPP_H
#define _SWIGCPP_H

#include "swigcore.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int   SWIG_expr(DOH *s, int *error);
extern char *SWIG_expr_error(void);
extern void  SWIG_expr_init();

extern DOH *SWIG_cpp_define(DOH *str, int swigmacro);
extern void SWIG_cpp_undef(DOH *name);
extern void SWIG_cpp_init();
extern DOH *SWIG_cpp_parse(DOH *s);
extern void SWIG_cpp_include_all(int);

#ifdef __cplusplus
}
#endif

#endif




