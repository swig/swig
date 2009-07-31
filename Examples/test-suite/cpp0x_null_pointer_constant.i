/* This testcase checks whether Swig correctly treats the new nullptr_t
   constant introduced in C++0x.
*/

%module cpp0x_null_pointer_constant

%inline %{
#include <cstddef>

class A {
public:
        A() : _myA(std::nullptr) { }
        
        A *_myA;
};
%}
