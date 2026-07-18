/* -----------------------------------------------------------------------------
 * arrays_rust.i
 *
 * Rust array typemap helpers modelled on the C# arrays library.
 * ----------------------------------------------------------------------------- */

#define RUST_ARRAYS(CTYPE, RUSTTYPE) \
%typemap(ctype) CTYPE INPUT[], CTYPE OUTPUT[], CTYPE INOUT[] "CTYPE *"; \
%typemap(imtype) CTYPE INPUT[], CTYPE OUTPUT[], CTYPE INOUT[] "*mut RUSTTYPE"; \
%typemap(rusttype) CTYPE INPUT[], CTYPE OUTPUT[], CTYPE INOUT[] "*mut RUSTTYPE"; \
%typemap(rustin) CTYPE INPUT[], CTYPE OUTPUT[], CTYPE INOUT[] "$rustinput"; \
%typemap(in) CTYPE INPUT[], CTYPE OUTPUT[], CTYPE INOUT[] %{ $1 = $input; %}

RUST_ARRAYS(int, c_int)
RUST_ARRAYS(unsigned int, c_uint)
RUST_ARRAYS(short, c_short)
RUST_ARRAYS(unsigned short, c_ushort)
RUST_ARRAYS(long, c_long)
RUST_ARRAYS(unsigned long, c_ulong)
RUST_ARRAYS(float, c_float)
RUST_ARRAYS(double, c_double)
