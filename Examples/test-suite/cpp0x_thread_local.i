/* This testcase checks whether Swig correctly parses the 'thread_local'
   keyword before the member type and name. */

%module cpp0x_thread_local

%inline %{
struct A {
   thread_local int val;
};
%}

