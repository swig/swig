// A complicated test of overloaded functions
%module overload_complicated

#ifndef SWIG_NO_OVERLOAD

%typemap(in, numinputs=0) int l { $1 = 4711; }

%inline %{

double foo(int, int, char *, int) {
   return 15;
}

double foo(int i, int j, double k = 17.4, int l = 18, char m = 'P') {
   return i + j + k + l + (int) m;
}

%}

#endif

