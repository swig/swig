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

#ifdef __cplusplus
extern "C" {
#endif

/* --- File interface --- */

extern void  Swig_add_directory(DOH *dirname);
extern DOH  *Swig_last_file();
extern DOH  *Swig_search_path();
extern FILE *Swig_open(DOH *name);
extern DOH  *Swig_read_file(FILE *f);
extern DOH  *Swig_include(DOH *name);

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
extern void     SwigScanner_idstart(SwigScanner *, char *idchar);

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

/* --- Simplified string-based type system */

extern void  SwigType_add_pointer(DOH *t);
extern void  SwigType_add_array(DOH *t, DOH *size);
extern void  SwigType_add_reference(DOH *t);
extern void  SwigType_add_qualifier(DOH *t, DOH *qual);
extern void  SwigType_add_function(DOH *t, DOH *parms);
extern DOH  *SwigType_split(DOH *t);
extern DOH  *SwigType_pop(DOH *t);
extern void  SwigType_push(DOH *t, DOH *s);
extern DOH  *SwigType_split_parms(DOH *p);
extern DOH  *SwigType_split_struct(DOH *s);
extern DOH  *SwigType_cstr(DOH *s, DOH *id);
extern int   SwigType_ispointer(DOH *t);
extern int   SwigType_isreference(DOH *t);
extern int   SwigType_isarray(DOH *t);
extern int   SwigType_isfunction(DOH *t);
extern int   SwigType_isstruct(DOH *t);
extern int   SwigType_isqualifier(DOH *t);
extern DOH  *SwigType_base(DOH *t);

/* --- NEW Type system --- */

  /* <DB> Names do not follow coding conventions </DB> */
#ifdef BOGUS_NAMES
   /* constructors */
DOH *Swig_Type_NewInt(int width, int is_const, int is_volatile, 
		      int is_signed, int is_unsigned);
DOH *Swig_Type_NewFloat(int width, int exp_width, int is_const,
			int is_volatile);
DOH *Swig_Type_NewVoid();
DOH *Swig_Type_NewChar(int width, int is_const, int is_volatile);
DOH *Swig_Type_NewName(DOH *name, int is_const, int is_volatile);
DOH *Swig_Type_NewEnum(DOH *name, DOH *body, 
		       int is_const, int is_volatile);
DOH *Swig_Type_NewStruct(DOH *name, DOH *body, 
			 int is_const, int is_volatile);
DOH *Swig_Type_NewUnion(DOH *name, DOH *body,
			int is_const, int is_volatile);
DOH *Swig_Type_NewArray(DOH *size, DOH *parent);
DOH *Swig_Type_NewFunction(DOH *parameters, DOH *parent);
DOH *Swig_Type_NewPointer(int is_const, int is_volatile, DOH *parent);

   /* use the sequence methods on a type to step linearly down through
      the sequence of constructors.  That is, Getitem(t, 2) is t
      without its outermost two constructors:

      t = Pointer(Pointer(Array(Int())))
      Getitem(t,2) = Array(Int()) */

   /* accessors -- return information about the outermost
      constructor. */
int Swig_Type_GetType(DOH *t);
DOH *Swig_Type_GetName(DOH *t);
DOH *Swig_Type_GetAttributes(DOH *t);
int Swig_Type_GetWidth(DOH *t);
int Swig_Type_GetExpWidth(DOH *t);
int Swig_Type_GetConst(DOH *t);
int Swig_Type_GetVolatile(DOH *t);
int Swig_Type_GetSigned(DOH *t);
int Swig_Type_GetUnsigned(DOH *t);

   /* Type constants (returned from Swig_Type_GetType) */

  /* <DB> These constants don't follow naming convention </DB> */
#define Swig_Type_Int 0
#define Swig_Type_Float 1
#define Swig_Type_Void 2
#define Swig_Type_Char 3
#define Swig_Type_Name 4
#define Swig_Type_Enum 5
#define Swig_Type_Struct 6
#define Swig_Type_Union 7
#define Swig_Type_Array 8
#define Swig_Type_Function 9
#define Swig_Type_Pointer 10

/* --- OLD Type system --- */

#endif

/* --- Misc --- */
extern char *Swig_copy_string(const char *c);

#ifdef __cplusplus
}
#endif

#endif




