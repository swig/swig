/* ----------------------------------------------------------------------------- 
 * lparse.h
 *
 *     Lame tag-based parsed based on the SWIG1.1 parser.
 * 
 * Author(s) : David Beazley (beazley@cs.uchicago.edu)
 *
 * Copyright (C) 1999-2000.  The University of Chicago
 * See the file LICENSE for information on usage and redistribution.	
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

#ifndef _LPARSE_H
#define _LPARSE_H

#include "swig.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void  LParse_push(DOH *);
extern DOH  *LParse_skip_balanced(int, int);
extern void  LParse_skip_semi();
extern void  LParse_skip_decl();
extern DOH  *LParse_parse(DOH *str);
extern DOH  *LParse_file();
extern int   LParse_line();
extern void  LParse_set_location(DOH *file, int line);
extern void  LParse_error(DOH *file, int line, char *fmt, ...);
extern void  LParse_macro_location(DOH *name, DOH *file, int line);
extern int   LParse_cplusplus(int i);
extern int   LParse_objc(int i);

#define    LPARSE_T_INT       1
#define    LPARSE_T_SHORT     2
#define    LPARSE_T_LONG      3
#define    LPARSE_T_UINT      4
#define    LPARSE_T_USHORT    5
#define    LPARSE_T_ULONG     6
#define    LPARSE_T_UCHAR     7
#define    LPARSE_T_SCHAR     8
#define    LPARSE_T_BOOL      9
#define    LPARSE_T_DOUBLE    10
#define    LPARSE_T_FLOAT     11
#define    LPARSE_T_CHAR      12
#define    LPARSE_T_USER      13
#define    LPARSE_T_VOID      14
#define    LPARSE_T_ENUM      50
#define    LPARSE_T_STRING    51
#define    LPARSE_T_VARARGS   52
#define    LPARSE_T_FUNCTION  53
#define    LPARSE_T_SYMBOL    98
#define    LPARSE_T_ERROR     99

#ifdef __cplusplus
}
#endif

#endif





