/* File : example.i */
%module example

#pragma SWIG nowarn=SWIGWARN_TYPEMAP_SWIGTYPELEAK

/* Some global variable declarations */
%inline %{
    extern int              ivar;
    extern short            svar;
    extern long             lvar;
    extern unsigned int     uivar;
    extern unsigned short   usvar;
    extern unsigned long    ulvar;
    extern signed char      scvar;
    extern unsigned char    ucvar;
    extern char             cvar;
    extern float            fvar;
    extern double           dvar;
    extern char            *strvar;
    extern double          *Foo1;
    extern double          *Foo2;
%}


/* Some helper functions to make it easier to test */
%inline %{
extern void  print_vars();
%}

