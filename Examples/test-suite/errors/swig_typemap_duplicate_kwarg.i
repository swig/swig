%module xxx

typedef int myint;

%typemap(in, some_kw=1, some_kw=0) myint
{$typemap(in,int)}

%typemap(out, some_kw=1, some_kw=0) myint
{$typemap(in,int)}

%typemap(check, some_kw=1, some_kw=0) myint
{}

%inline %{
myint identity(myint i) { return i; }
%}
