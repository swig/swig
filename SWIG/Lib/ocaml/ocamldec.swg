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
#define SWIGEXT extern "C"
SWIGEXT {
#else
#define SWIGEXT 
#endif
#define alloc caml_alloc
#define value caml_value_t
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/misc.h>
#undef alloc
#define CAML_VALUE value

#if defined(SWIG_NOINCLUDE)
#	define SWIGSTATIC
#elif defined(SWIG_GLOBAL)
#	define SWIGSTATIC
#else
#	define SWIGSTATIC static
#endif

#define __OCAML__SWIG__MAXVALUES 6

    SWIGSTATIC int
    SWIG_GetPtr(void *source, void **result, swig_type_info *type, swig_type_info *result_type);
    
    SWIGSTATIC void *
    SWIG_MustGetPtr (CAML_VALUE v,  swig_type_info *type);
    
    static CAML_VALUE _wrap_delete_void( CAML_VALUE );
    
    static int enum_to_int( char *name, CAML_VALUE v );
    static CAML_VALUE int_to_enum( char *name, int v );

    static CAML_VALUE caml_list_nth( CAML_VALUE lst, int n );
    static CAML_VALUE caml_list_append( CAML_VALUE lst, CAML_VALUE elt );
    static int caml_list_length( CAML_VALUE lst );
    static CAML_VALUE caml_array_new( int n );
    static void caml_array_set( CAML_VALUE arr, int n, CAML_VALUE item );
    static CAML_VALUE caml_array_nth( CAML_VALUE arr, int n );
    static int caml_array_length( CAML_VALUE arr );

    static CAML_VALUE caml_val_char( char c );
    static CAML_VALUE caml_val_uchar( unsigned char c );

    static CAML_VALUE caml_val_short( short s );
    static CAML_VALUE caml_val_ushort( unsigned short s );
    
    static CAML_VALUE caml_val_int( int x );
    static CAML_VALUE caml_val_uint( unsigned int x );

    static CAML_VALUE caml_val_long( long x );
    static CAML_VALUE caml_val_ulong( unsigned long x );

    static CAML_VALUE caml_val_float( float f );
    static CAML_VALUE caml_val_double( double d );

    static CAML_VALUE caml_val_ptr( void *p, swig_type_info *descriptor );

    static CAML_VALUE caml_val_string( const char *str );
    static CAML_VALUE caml_val_string_len( const char *str, int len );

    static long caml_long_val( CAML_VALUE v );
    static double caml_double_val( CAML_VALUE v );

    static int caml_ptr_val_internal( CAML_VALUE v, void **out,
				      swig_type_info *descriptor );
    static void *caml_ptr_val( CAML_VALUE v, swig_type_info *descriptor );

    static char *caml_string_val( CAML_VALUE v );

#ifdef __cplusplus
}
#endif

/* mzschemedec.swg ends here */
