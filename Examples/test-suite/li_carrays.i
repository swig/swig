%module li_carrays

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) doubleArray; /* Ruby, wrong class name */

%include <carrays.i>

%array_functions(int,intArray);
%array_class(double, doubleArray);

