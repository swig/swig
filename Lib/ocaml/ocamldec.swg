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

    SWIGSTATIC int
    SWIG_GetPtr(void *source, void **result, swig_type_info *type, swig_type_info *result_type);
    
    SWIGSTATIC void *
    SWIG_MustGetPtr (value v,  swig_type_info *type);
    
    static value _wrap_delete_void( value );
    
    static int enum_to_int( char *name, value v );
    static value int_to_enum( char *name, int v );

    static value caml_list_nth( value lst, int n );
    static value caml_list_append( value lst, value elt );
    static int caml_list_length( value lst );

    static value caml_val_char( char c );
    static value caml_val_uchar( unsigned char c );

    static value caml_val_short( short s );
    static value caml_val_ushort( unsigned short s );
    
    static value caml_val_int( int x );
    static value caml_val_uint( unsigned int x );

    static value caml_val_long( long x );
    static value caml_val_ulong( unsigned long x );

    static value caml_val_float( float f );
    static value caml_val_double( double d );

    static value caml_val_ptr( void *p, swig_type_info *descriptor );

    static value caml_val_string( char *str );
    static value caml_val_string_len( char *str, int len );

    static long caml_long_val( value v );
    static double caml_double_val( value v );

    static int caml_ptr_val_internal( value v, void **out,
				      swig_type_info *descriptor );
    static void *caml_ptr_val( value v, swig_type_info *descriptor );

    static char *caml_string_val( value v );

#ifdef __cplusplus
}

template < class T > class SWIG_OCAML_ARRAY_WRAPPER {
public:
  SWIG_OCAML_ARRAY_WRAPPER( T *t ) : t(t) { }
  SWIG_OCAML_ARRAY_WRAPPER( T &t ) : t(&t) { }
  SWIG_OCAML_ARRAY_WRAPPER( T t[] ) : t(&t[0]) { }
  T &operator[]( int n ) { return t[n]; }
  SWIG_OCAML_ARRAY_WRAPPER offset( int elts ) {
	return SWIG_OCAML_ARRAY_WRAPPER( t + elts );
  }
  T *operator & () { return t; }
  void own() { owned = true; }
  void disown() { owned = false; }
  ~SWIG_OCAML_ARRAY_WRAPPER() {
    if( owned ) delete t;
  }

private:
  T *t;
  int owned;
};
    
#endif

/* mzschemedec.swg ends here */
