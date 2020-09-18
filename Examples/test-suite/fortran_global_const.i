%module fortran_global_const

// Wrap as 'parameters'
%fortranconst fortranconst_int_global;
%fortranconst fortranconst_float_global;
%constant int fortranconst_int_global = 4;
%constant float fortranconst_float_global = 1.23f;

// Wrap as externally-linked constants
%fortranbindc constant_int_global;
%fortranbindc constant_float_global;
%constant int constant_int_global = 4;
%constant float constant_float_global = 1.23f;

// Default wrapping: getters
%constant int nofortranconst_int_global = 4;
%constant float nofortranconst_float_global = 1.23f;

%fortranbindc MACRO_INT;
%fortranconstvalue(4) MACRO_HEX_INT;

%inline %{
#define MACRO_INT 4
const int extern_const_int = 4;
#define MACRO_HEX_INT 0x4
%}

/* Test enums and defaults */

%fortranconst NativeEnum;
%nofortranconst ExternEnum;

%inline %{
typedef enum {
  Alfa = 0,
  Bravo,
  Charlie
} NativeEnum;

typedef enum {
  Sierra = 1,
  Juliet
} DefaultEnum;

typedef enum {
  Whiskey = 0,
  Tango,
  Foxtrot = 12345
} ExternEnum;

%}

/* Test wrapping everything */
%fortranconst;
%nofortranconst NFCEnum;

%inline %{
typedef enum {
  FCSierra = 1,
  FCJuliet
} FCEnum;

typedef enum {
  NFCWhiskey = 0x123
} NFCEnum;

%}
