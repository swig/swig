/* This interface file tests whether whitespace in angle brackets
   effects the SWIG types. SF Bug #221917, reported by
   burchanb@cs.tamu.edu. */

%{
#include <vector>
%}

%typemap(in) vector<int> "/* Xyzzy! */";

%inline %{
void foo(vector<int > v) {}
%}
