/* -*-c-*-
 * -----------------------------------------------------------------------
 * ocaml/ocamldec.swg
 * Copyright (C) 2000, 2001 Matthias Koeppe
 *
 * Ocaml runtime code -- declarations
 * ----------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
#define alloc caml_alloc
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/misc.h>
#undef alloc

#if defined(SWIG_NOINCLUDE)
#	define SWIGSTATIC
#elif defined(SWIG_GLOBAL)
#	define SWIGSTATIC
#else
#	define SWIGSTATIC static
#endif

#define __OCAML__SWIG__MAXVALUES 6

    SWIGSTATIC value
    SWIG_MakePtr(void *c_pointer, swig_type_info *type, char *delete_fn);
    
    SWIGSTATIC int
    SWIG_GetPtr(value v, void **result, swig_type_info *type);
    
    SWIGSTATIC void *
    SWIG_MustGetPtr (value v,  swig_type_info *type);
    
    static value _wrap_delete_void( value );
    
    static int enum_to_int( char *name, value v );
    static value int_to_enum( char *name, int v );
    
#ifdef __cplusplus
}
#endif

/* mzschemedec.swg ends here */
