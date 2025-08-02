/* -----------------------------------------------------------------------------
 * ocamlrundec.swg
 *
 * Ocaml runtime code -- declarations
 * ----------------------------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef __cplusplus
#define SWIGEXT extern "C"
SWIGEXT {
#else
#define SWIGEXT 
#endif
#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/callback.h>
#include <caml/fail.h>
#include <caml/misc.h>

#if defined(CAMLassert)
/* Both this macro and version.h were introduced in version 4.02.0 */
#include <caml/version.h>
#else
#define OCAML_VERSION 0 /* Unknown, but < 40200 */
#endif

#define caml_array_set swig_caml_array_set

#define SWIG_NewPointerObj(p,type,flags) caml_val_ptr(p,type)
#define SWIG_GetModule(clientdata) SWIG_Ocaml_GetModule(clientdata)
#define SWIG_SetModule(clientdata, pointer) SWIG_Ocaml_SetModule(pointer)

typedef enum {
  SWIG_OCamlArithmeticException,
  SWIG_OCamlDirectorPureVirtual,
  SWIG_OCamlOutOfMemoryError,
  SWIG_OCamlOverflowException,
  SWIG_OCamlIllegalArgumentException,
  SWIG_OCamlIndexOutOfBoundsException,
  SWIG_OCamlRuntimeException,
  SWIG_OCamlSystemException,
  SWIG_OCamlNullReferenceException,
  SWIG_OCamlUnknownError
} SWIG_OCamlExceptionCodes;

SWIGINTERN void SWIG_OCamlThrowException(SWIG_OCamlExceptionCodes code, const char *msg) {
  CAMLparam0();
  CAMLlocal1(str);

  switch (code) {
  case SWIG_OCamlIllegalArgumentException:
  case SWIG_OCamlNullReferenceException:
    caml_invalid_argument(msg);
    break;
  case SWIG_OCamlSystemException:
    str = caml_copy_string(msg);
    caml_raise_sys_error(str);
    break;
  case SWIG_OCamlArithmeticException:
  case SWIG_OCamlIndexOutOfBoundsException:
  case SWIG_OCamlOutOfMemoryError:
  case SWIG_OCamlOverflowException:
  case SWIG_OCamlRuntimeException:
  case SWIG_OCamlUnknownError:
  default:
    caml_failwith(msg);
    break;
  }
  CAMLreturn0;
}

#define SWIG_contract_assert(expr, msg) do { if(!(expr)) {SWIG_OCamlThrowException(SWIG_OCamlRuntimeException, msg);} } while (0)

    SWIGINTERN int
    SWIG_GetPtr(void *source, void **result, swig_type_info *type, swig_type_info *result_type);

    SWIGINTERN value caml_list_nth( value lst, int n );
    SWIGINTERN value caml_list_append( value lst, value elt );
    SWIGINTERN int caml_list_length( value lst );
    SWIGINTERN value caml_array_new( int n );
    SWIGINTERN void caml_array_set( value arr, int n, value item );
    SWIGINTERN value caml_array_nth( value arr, int n );
    SWIGINTERN int caml_array_len( value arr );

    SWIGINTERN value caml_val_char( char c );
    SWIGINTERN value caml_val_uchar( unsigned char c );

    SWIGINTERN value caml_val_short( short s );
    SWIGINTERN value caml_val_ushort( unsigned short s );
    
    SWIGINTERN value caml_val_int( int x );
    SWIGINTERN value caml_val_uint( unsigned int x );

    SWIGINTERN value caml_val_long( long x );
    SWIGINTERN value caml_val_ulong( unsigned long x );

    SWIGINTERN value caml_val_float( float f );
    SWIGINTERN value caml_val_double( double d );

    SWIGINTERN value caml_val_ptr( void *p, swig_type_info *descriptor );

    SWIGINTERN value caml_val_string( const char *str );
    SWIGINTERN value caml_val_string_len( const char *str, int len );

    SWIGINTERN long caml_long_val( value v );
    SWIGINTERN double caml_double_val( value v );

    SWIGINTERN int caml_ptr_val_internal( value v, void **out,
				      swig_type_info *descriptor );
    SWIGINTERN void *caml_ptr_val( value v, swig_type_info *descriptor );

    SWIGINTERN char *caml_string_val( value v );
    SWIGINTERN int caml_string_len( value v );

#ifdef __cplusplus
}
#endif
