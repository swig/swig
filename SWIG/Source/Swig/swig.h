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
 * Please read the file LICENSE for the copyright and terms by which Swig
 * can be used and distributed.
 ****************************************************************************/

#ifndef _SWIGCORE_H
#define _SWIGCORE_H

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "doh.h"

#ifdef __cplusplus
extern "C" {
#endif

/* --- File interface --- */

extern void  Swig_add_directory(DOH *dirname);
extern void  Swig_set_library(DOH *libname);
extern DOH  *Swig_get_library();
extern DOH  *Swig_last_file();
extern DOH  *Swig_search_path();
extern FILE *Swig_open(DOH *name);
extern DOH  *Swig_read_file(FILE *f);
extern DOH  *Swig_include(DOH *name);

#define  SWIG_FILE_DELIMETER   "/"

/* --- Command line parsing --- */

extern void  Swig_init_args(int argc, char **argv);
extern void  Swig_mark_arg(int n);
extern void  Swig_check_options();
extern void  Swig_arg_error();


/* --- Scanner Interface --- */

typedef struct SwigScanner SwigScanner;

extern SwigScanner *NewSwigScanner();
extern void     DelSwigScanner(SwigScanner *);
extern void     SwigScanner_clear(SwigScanner *);
extern void     SwigScanner_push(SwigScanner *, DOH *);
extern void     SwigScanner_pushtoken(SwigScanner *, int);
extern int      SwigScanner_token(SwigScanner *);
extern DOH     *SwigScanner_text(SwigScanner *);
extern void     SwigScanner_skip_line(SwigScanner *);
extern int      SwigScanner_skip_balanced(SwigScanner *, int startchar, int endchar);
extern void     SwigScanner_set_location(SwigScanner *, DOH *file, int line);
extern DOH     *SwigScanner_get_file(SwigScanner *);
extern int      SwigScanner_get_line(SwigScanner *);

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

/* --- Misc --- */

extern char *copy_string(const char *c);

#ifdef __cplusplus
}
#endif

#endif




