/* File : example.i */
%module example

/* Turn all data attributes into a pair of accessor functions.
   In this case, a data attribute foo is accessed using
   foo() and changed using set_foo().  The format strings
   in %attributefunc() can be used to precisely determine
   the format of the get/set functions */

%attributefunc(%s,set_%s)

%inline %{
class Vector {
public:
   double x,y,z;
};
%}
