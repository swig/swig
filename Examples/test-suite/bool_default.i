// [ 548272] Default arguments
%module bool_default

%inline %{

bool foo(bool x = true) {
   return !x;
}
%}
