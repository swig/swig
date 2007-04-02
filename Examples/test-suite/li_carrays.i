%module li_carrays

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) doubleArray; /* Ruby, wrong class name */

%include <carrays.i>

%array_functions(int,intArray);
%array_class(double, doubleArray);

%inline %{
typedef struct {
  int x;
  int y;
} XY;
typedef struct {
  int a;
  int b;
} AB;
%}

// Note that struct XY { ... }; gives compiler error for C when using %array_class or %array_functions, but is okay in C++
%array_class(XY, XYArray)
%array_functions(AB, ABArray)

