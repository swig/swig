%module extern_throws 
%inline %{
#include <exception>
extern int get() throw(std::exception);

%}

%{
int get() throw(std::exception) { return 0; }
%}

