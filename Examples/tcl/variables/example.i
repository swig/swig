/* File : example.i */
%module example

/* Some global variable declarations */
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
extern int             *iptrvar;
extern char             name[256];

/* Some helper functions to make it easier to test */
extern void  print_vars();
extern int  *new_int(int value);

/* A read-only variable */

%readonly
extern int  status;
%readwrite



