%module fortran_global_const

%fortranconst fortranconst_int_global;
%fortranconst fortranconst_float_global;
%constant int fortranconst_int_global = 4;
%constant float fortranconst_float_global = 1.23f;

// Neither of these is wrapped as native constants (disabled by default)
%constant int constant_int_global = 4;
%constant float constant_float_global = 1.23f;

%nofortranconst nofortranconst_int_global;
%nofortranconst nofortranconst_float_global;
%constant int nofortranconst_int_global = 4;
%constant float nofortranconst_float_global = 1.23f;

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

