/* -------------------------------------------------------------------------
 * stdint.i
 * ------------------------------------------------------------------------- */
%{
#include <stdint.h>
%}

%include <fundamental.swg>

%fortran_intrinsic(int8_t,  integer, C_INT8_T)
%fortran_intrinsic(int16_t, integer, C_INT16_T)
%fortran_intrinsic(int32_t, integer, C_INT32_T)
%fortran_intrinsic(int64_t, integer, C_INT64_T)

%fortran_intrinsic(int_least8_t,  integer, C_INT_LEAST8_T)
%fortran_intrinsic(int_least16_t, integer, C_INT_LEAST16_T)
%fortran_intrinsic(int_least32_t, integer, C_INT_LEAST32_T)
%fortran_intrinsic(int_least64_t, integer, C_INT_LEAST64_T)

%fortran_intrinsic(int_fast8_t,  integer, C_INT_FAST8_T)
%fortran_intrinsic(int_fast16_t, integer, C_INT_FAST16_T)
%fortran_intrinsic(int_fast32_t, integer, C_INT_FAST32_T)
%fortran_intrinsic(int_fast64_t, integer, C_INT_FAST64_T)

%fortran_intrinsic(intmax_t, integer, C_INTMAX_T)
%fortran_intrinsic(intptr_t, integer, C_INTPTR_T)

