%module fortran_enums

//%enumerator NativeEnum;
%noenumerator ExternEnum;

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
