// A module with a function that involves pointers to arrays 

%module arrayptr

%inline %{

void foo(int (*x)[10]) {

}
%}


