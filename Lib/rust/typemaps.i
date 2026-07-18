/* -----------------------------------------------------------------------------
 * typemaps.i
 *
 * Pointer and reference handling typemap library for Rust.
 * ----------------------------------------------------------------------------- */

%define RUST_INPUT_TYPEMAP(TYPE, CTYPE, RUSTTYPE, TYPECHECKPRECEDENCE)
%typemap(ctype, out="void *") TYPE *INPUT, TYPE &INPUT "CTYPE"
%typemap(imtype, out="*mut c_void") TYPE *INPUT, TYPE &INPUT "RUSTTYPE"
%typemap(rusttype, out="*mut c_void") TYPE *INPUT, TYPE &INPUT "RUSTTYPE"
%typemap(rustin) TYPE *INPUT, TYPE &INPUT "$rustinput"

%typemap(in) TYPE *INPUT, TYPE &INPUT
%{ $1 = ($1_ltype)&$input; %}

%typecheck(SWIG_TYPECHECK_##TYPECHECKPRECEDENCE) TYPE *INPUT, TYPE &INPUT ""
%enddef

%define RUST_OUTPUT_TYPEMAP(TYPE, CTYPE, RUSTTYPE, TYPECHECKPRECEDENCE)
%typemap(ctype, out="void *") TYPE *OUTPUT, TYPE &OUTPUT "CTYPE *"
%typemap(imtype, out="*mut c_void") TYPE *OUTPUT, TYPE &OUTPUT "*mut RUSTTYPE"
%typemap(rusttype, out="*mut c_void") TYPE *OUTPUT, TYPE &OUTPUT "*mut RUSTTYPE"
%typemap(rustin) TYPE *OUTPUT, TYPE &OUTPUT "$rustinput"

%typemap(in) TYPE *OUTPUT, TYPE &OUTPUT
%{ $1 = ($1_ltype)$input; %}

%typecheck(SWIG_TYPECHECK_##TYPECHECKPRECEDENCE) TYPE *OUTPUT, TYPE &OUTPUT ""
%enddef

%define RUST_INOUT_TYPEMAP(TYPE, CTYPE, RUSTTYPE, TYPECHECKPRECEDENCE)
%typemap(ctype, out="void *") TYPE *INOUT, TYPE &INOUT "CTYPE *"
%typemap(imtype, out="*mut c_void") TYPE *INOUT, TYPE &INOUT "*mut RUSTTYPE"
%typemap(rusttype, out="*mut c_void") TYPE *INOUT, TYPE &INOUT "*mut RUSTTYPE"
%typemap(rustin) TYPE *INOUT, TYPE &INOUT "$rustinput"

%typemap(in) TYPE *INOUT, TYPE &INOUT
%{ $1 = ($1_ltype)$input; %}

%typecheck(SWIG_TYPECHECK_##TYPECHECKPRECEDENCE) TYPE *INOUT, TYPE &INOUT ""
%enddef

RUST_INPUT_TYPEMAP(bool,               bool,               bool,        BOOL_PTR)
RUST_INPUT_TYPEMAP(signed char,        signed char,        c_schar,     INT8_PTR)
RUST_INPUT_TYPEMAP(unsigned char,      unsigned char,      c_uchar,     UINT8_PTR)
RUST_INPUT_TYPEMAP(short,              short,              c_short,     INT16_PTR)
RUST_INPUT_TYPEMAP(unsigned short,     unsigned short,     c_ushort,    UINT16_PTR)
RUST_INPUT_TYPEMAP(int,                int,                c_int,       INT32_PTR)
RUST_INPUT_TYPEMAP(unsigned int,       unsigned int,       c_uint,      UINT32_PTR)
RUST_INPUT_TYPEMAP(long,               long,               c_long,      INT64_PTR)
RUST_INPUT_TYPEMAP(unsigned long,      unsigned long,      c_ulong,     UINT64_PTR)
RUST_INPUT_TYPEMAP(long long,          long long,          c_longlong,  INT64_PTR)
RUST_INPUT_TYPEMAP(unsigned long long, unsigned long long, c_ulonglong, UINT64_PTR)
RUST_INPUT_TYPEMAP(float,              float,              c_float,     FLOAT_PTR)
RUST_INPUT_TYPEMAP(double,             double,             c_double,    DOUBLE_PTR)

RUST_OUTPUT_TYPEMAP(bool,               bool,               bool,        BOOL_PTR)
RUST_OUTPUT_TYPEMAP(signed char,        signed char,        c_schar,     INT8_PTR)
RUST_OUTPUT_TYPEMAP(unsigned char,      unsigned char,      c_uchar,     UINT8_PTR)
RUST_OUTPUT_TYPEMAP(short,              short,              c_short,     INT16_PTR)
RUST_OUTPUT_TYPEMAP(unsigned short,     unsigned short,     c_ushort,    UINT16_PTR)
RUST_OUTPUT_TYPEMAP(int,                int,                c_int,       INT32_PTR)
RUST_OUTPUT_TYPEMAP(unsigned int,       unsigned int,       c_uint,      UINT32_PTR)
RUST_OUTPUT_TYPEMAP(long,               long,               c_long,      INT64_PTR)
RUST_OUTPUT_TYPEMAP(unsigned long,      unsigned long,      c_ulong,     UINT64_PTR)
RUST_OUTPUT_TYPEMAP(long long,          long long,          c_longlong,  INT64_PTR)
RUST_OUTPUT_TYPEMAP(unsigned long long, unsigned long long, c_ulonglong, UINT64_PTR)
RUST_OUTPUT_TYPEMAP(float,              float,              c_float,     FLOAT_PTR)
RUST_OUTPUT_TYPEMAP(double,             double,             c_double,    DOUBLE_PTR)

RUST_INOUT_TYPEMAP(bool,               bool,               bool,        BOOL_PTR)
RUST_INOUT_TYPEMAP(signed char,        signed char,        c_schar,     INT8_PTR)
RUST_INOUT_TYPEMAP(unsigned char,      unsigned char,      c_uchar,     UINT8_PTR)
RUST_INOUT_TYPEMAP(short,              short,              c_short,     INT16_PTR)
RUST_INOUT_TYPEMAP(unsigned short,     unsigned short,     c_ushort,    UINT16_PTR)
RUST_INOUT_TYPEMAP(int,                int,                c_int,       INT32_PTR)
RUST_INOUT_TYPEMAP(unsigned int,       unsigned int,       c_uint,      UINT32_PTR)
RUST_INOUT_TYPEMAP(long,               long,               c_long,      INT64_PTR)
RUST_INOUT_TYPEMAP(unsigned long,      unsigned long,      c_ulong,     UINT64_PTR)
RUST_INOUT_TYPEMAP(long long,          long long,          c_longlong,  INT64_PTR)
RUST_INOUT_TYPEMAP(unsigned long long, unsigned long long, c_ulonglong, UINT64_PTR)
RUST_INOUT_TYPEMAP(float,              float,              c_float,     FLOAT_PTR)
RUST_INOUT_TYPEMAP(double,             double,             c_double,    DOUBLE_PTR)

#undef RUST_INPUT_TYPEMAP
#undef RUST_OUTPUT_TYPEMAP
#undef RUST_INOUT_TYPEMAP
