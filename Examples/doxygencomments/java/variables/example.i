/* File : example.i */
%module example
%{
#include "example.h"
%}

/* Some global variable declarations */
%inline %{
extern int              ivar; /*!< Description of ivar */
extern short            svar; /*!< Description of svar */
extern long             lvar; /*!< Description of lvar */
extern unsigned int     uivar; /*!< Description of uivar */
extern unsigned short   usvar; /*!< Description of usvar */
extern unsigned long    ulvar; /*!< Description of ulvar */
extern signed char      scvar; /*!< Description of scvar */
extern unsigned char    ucvar; /*!< Description of ucvar */
extern char             cvar; /*!< Description of cvar */
extern float            fvar; /*!< Description of fvar */
extern double           dvar; /*!< Description of dvar */
extern char            *strvar; /*!< Description of strvar */
extern const char       cstrvar[]; /*!< Description of cstrvar */
extern int             *iptrvar;  /*!< Description of iptrvar */
extern char             name[256];  /*!< Description of name */

extern Point           *ptptr;  /*!< Description of ptrptr */
extern Point            pt;  /*!< Description of pt */
%}


/* Some read-only variables */

%immutable;

%inline %{
extern int  status;
extern char path[256];
%}

%mutable;

/* Some helper functions to make it easier to test */
%inline %{
/*! this function prints variables
 \author someone */
extern void  print_vars();
extern int  *new_int(int value);  /*!< Description of new_int
				   \param value the value
				   \return a new int */
/*! Description of new_point
  \param x the value x
  \param y the value y
 \return a new point */
extern Point *new_Point(int x, int y);
extern char  *Point_print(Point *p);
extern void  pt_print();
%}

