/* -----------------------------------------------------------------------------
 * cmalloc.i
 *
 * Author(s):  David Beazley (beazley@cs.uchicago.edu)
 *
 * This library file contains macros that can be used to create objects using
 * the C malloc function.
 *
 * $Header$
 * ----------------------------------------------------------------------------- */

%{
#include <stdlib.h>
%}

%define %malloc(TYPE,...)
#if #__VA_ARGS__ != ""
%name(malloc_##__VA_ARGS__) TYPE *malloc(int nbytes = sizeof(TYPE));
#else
%name(malloc_##TYPE) TYPE *malloc(int nbytes = sizeof(TYPE));
#endif
%enddef

%define %calloc(TYPE,...)
#if #__VA_ARGS__ != ""
%name(calloc_##__VA_ARGS__) TYPE *calloc(int nobj = 1, int nbytes = sizeof(TYPE));
#else
%name(calloc_##TYPE) TYPE *calloc(int nobj = 1, int nbytes = sizeof(TYPE));
#endif
%enddef

%define %realloc(TYPE,...)
#if #__VA_ARGS__ != ""
%name(realloc_##__VA_ARGS__) TYPE *realloc(TYPE *ptr, int nbytes);
#else
%name(realloc_##TYPE)        TYPE *realloc(TYPE *ptr, int nbytes);
#endif
%enddef

%define %free(TYPE,...)
#if #__VA_ARGS__ != ""
%name(free_##__VA_ARGS__) void free(TYPE *ptr);
#else
%name(free_##TYPE)        void free(TYPE *ptr);
#endif
%enddef



