%module global_ns_arg

%inline %{

typedef int Integer;

::Integer foo(::Integer x) {
   return x;
}

::Integer bar() {
   return 1;
}

%}
