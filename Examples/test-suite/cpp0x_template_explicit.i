/* This unit tests whether Swig correctly parses the code and makes wrappers
   for the new C++0x extern templates (explicit template instantiation without
   using the translation unit).
*/
%module cpp0x_template_explicit

%inline %{
#include <vector>

class A {
public:
        int member;
        int memberFunction() { return 100; }
};

template class std::vector<A>;
extern template class std::vector<A>;

template class std::vector<A*>;
extern template class std::vector<A*>;
%}

