/* -------------------------------------------------------------------------
 * stdint.i
 * ------------------------------------------------------------------------- */
%include <fundamental.swg>
%include <../stdint.i>

FORT_FUND_TYPEMAP(int8_t,  "integer(C_INT8_T)")
FORT_FUND_TYPEMAP(int16_t, "integer(C_INT16_T)")
FORT_FUND_TYPEMAP(int32_t, "integer(C_INT32_T)")
FORT_FUND_TYPEMAP(int64_t, "integer(C_INT64_T)")

FORT_FUND_TYPEMAP(int_least8_t,  "integer(C_INT_LEAST8_T)")
FORT_FUND_TYPEMAP(int_least16_t, "integer(C_INT_LEAST16_T)")
FORT_FUND_TYPEMAP(int_least32_t, "integer(C_INT_LEAST32_T)")
FORT_FUND_TYPEMAP(int_least64_t, "integer(C_INT_LEAST64_T)")

FORT_FUND_TYPEMAP(int_fast8_t,  "integer(C_INT_FAST8_T)")
FORT_FUND_TYPEMAP(int_fast16_t, "integer(C_INT_FAST16_T)")
FORT_FUND_TYPEMAP(int_fast32_t, "integer(C_INT_FAST32_T)")
FORT_FUND_TYPEMAP(int_fast64_t, "integer(C_INT_FAST64_T)")

FORT_FUND_TYPEMAP(intmax_t, "integer(C_INTMAX_T)")
FORT_FUND_TYPEMAP(intptr_t, "integer(C_INTPTR_T)")
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
