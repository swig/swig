%module wrapmacro

/* Testing techniques  for wrapping macros *


/* Here, some macros to wrap */
%{
#define guint16 int  
#define GUINT16_SWAP_LE_BE_CONSTANT(val) ((guint16) ( \
    (guint16) ((guint16) (val) >> 8) |  \
    (guint16) ((guint16) (val) << 8)))

#define max(a,b) ((a) > (b) ? (a) : (b))

%}

/* Here, the auxiliar macro to wrap a macro */
%define %wrapmacro(type, name, lparams, lnames)
%rename(SWIGMACRO_##name) name;
%inline %{
type SWIGMACRO_##name(lparams) {
  return name(lnames);
}
%}
%enddef
#define PLIST(...) __VA_ARGS__



/* Here, wrapping the macros */
%wrapmacro(guint16, GUINT16_SWAP_LE_BE_CONSTANT, guint16 val, val);
%wrapmacro(int, max, PLIST(int a, int b), PLIST(a, b));
%wrapmacro(double, max, PLIST(double a, double b), PLIST(a, b));


/*

Maybe in the future, a swig directive will do this easier:

#define max(a,b) ((a) > (b) ? (a) : (b))

%wrapmacro double max(long a, double b); // target name is 'max'
%wrapmacro(max_i) int max(int a, int b); // changes target name to 'max_i'.


*/

