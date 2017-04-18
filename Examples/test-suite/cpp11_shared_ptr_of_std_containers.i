%module cpp11_shared_ptr_of_std_containers

%{
#include <memory>
%}

%include <std_string.i>
%include <std_vector.i>
%include <std_shared_ptr.i>

%shared_ptr(std::vector<std::string>);

%template(StringVector) std::vector<std::string>;
