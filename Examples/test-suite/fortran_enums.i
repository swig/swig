%module fortran_enums

//%fortranconst NativeEnum;
%nofortranconst ExternEnum;

%inline %{
typedef enum {
  Alfa = 0,
  Bravo,
  Charlie
} NativeEnum;

typedef enum {
  Whiskey = 0,
  Tango,
  Foxtrot = 12345
} ExternEnum;

%}

