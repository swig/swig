%module li_carrays

%warnfilter(801) doubleArray; /* Ruby, wrong class name */

%include "carrays.i"

%array_functions(int,intArray);
%array_class(double, doubleArray);

