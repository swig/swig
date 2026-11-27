%module cpp11_shared_ptr_container

#if defined(SWIGC) || defined(SWIGJAVA) || defined(SWIGCSHARP) || defined(SWIGPYTHON) || defined(SWIGD) || defined(SWIGOCTAVE) || defined(SWIGRUBY) || defined(SWIGR) || defined(SWIGLUA)
#define SHARED_PTR_WRAPPERS_IMPLEMENTED
#endif

#if defined(SHARED_PTR_WRAPPERS_IMPLEMENTED)
%include <std_string.i>
%include <std_vector.i>
%include <std_shared_ptr.i>
%shared_ptr(std::vector<std::string>)
%template(StringVector) std::vector<std::string>;
#endif

%inline %{
#include <string>
#include <vector>
#include <memory>
%}
