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

extern void  SWIG_add_directory(DOH *dirname);
extern void  SWIG_set_library(DOH *libname);
extern DOH  *SWIG_get_library();
extern DOH  *SWIG_last_file();
extern DOH  *SWIG_search_path();
extern FILE *SWIG_open(DOH *name);
extern DOH  *SWIG_read_file(FILE *f);
extern DOH  *SWIG_include(DOH *name);

#define  FILE_DELIMETER   "/"

/* --- Command line parsing --- */

extern void  SWIG_init_args(int argc, char **argv);
extern void  SWIG_mark_arg(int n);
extern void  SWIG_check_options();
extern void  SWIG_arg_error();


/* --- Scanner Interface --- */

typedef struct Scanner Scanner;
extern Scanner *NewScanner();
extern void     DelScanner(Scanner *);
extern void     Scanner_clear(Scanner *);
extern void     Scanner_push(Scanner *, DOH *);
extern void     Scanner_pushtoken(Scanner *, int);
extern int      Scanner_token(Scanner *);
extern DOH     *Scanner_text(Scanner *);
extern void     Scanner_skip_line(Scanner *);
extern int      Scanner_skip_balanced(Scanner *, int startchar, int endchar);
extern void     Scanner_set_location(Scanner *, DOH *file, int line);
extern DOH     *Scanner_get_file(Scanner *);
extern int      Scanner_get_line(Scanner *);

#define   MAXTOKENS          512
#define   TOKEN_LPAREN        1  
#define   TOKEN_RPAREN        2
#define   TOKEN_SEMI          3
#define   TOKEN_COMMA         4
#define   TOKEN_STAR          5
#define   TOKEN_LBRACE        6
#define   TOKEN_RBRACE        7
#define   TOKEN_EQUAL         8
#define   TOKEN_EQUALTO       9
#define   TOKEN_NOTEQUAL     10
#define   TOKEN_PLUS         11
#define   TOKEN_MINUS        12
#define   TOKEN_AND          13
#define   TOKEN_LAND         14
#define   TOKEN_OR           15
#define   TOKEN_LOR          16
#define   TOKEN_XOR          17
#define   TOKEN_LESSTHAN     18
#define   TOKEN_GREATERTHAN  19
#define   TOKEN_LTEQUAL      20
#define   TOKEN_GTEQUAL      21
#define   TOKEN_NOT          22
#define   TOKEN_LNOT         23
#define   TOKEN_LBRACKET     24
#define   TOKEN_RBRACKET     25
#define   TOKEN_SLASH        26
#define   TOKEN_BACKSLASH    27
#define   TOKEN_ENDLINE      28
#define   TOKEN_STRING       29
#define   TOKEN_POUND        30
#define   TOKEN_PERCENT      31
#define   TOKEN_COLON        32
#define   TOKEN_DCOLON       33
#define   TOKEN_LSHIFT       34
#define   TOKEN_RSHIFT       35
#define   TOKEN_ID           36
#define   TOKEN_FLOAT        37
#define   TOKEN_DOUBLE       38
#define   TOKEN_INT          39
#define   TOKEN_UINT         40
#define   TOKEN_LONG         41
#define   TOKEN_ULONG        42
#define   TOKEN_CHAR         43
#define   TOKEN_PERIOD       44
#define   TOKEN_AT           45
#define   TOKEN_DOLLAR       46
#define   TOKEN_CODEBLOCK    47
#define   TOKEN_ILLEGAL      98
#define   TOKEN_LAST         99 

/* --- Misc --- */

extern char *copy_string(const char *c);

#ifdef __cplusplus
}
#endif

#endif




