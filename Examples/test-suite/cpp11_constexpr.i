/* This interface tests whether SWIG supports the new "constexpr" keyword
   introduced by C++11.
*/
%module cpp11_constexpr

%inline %{
class TestClass {
public:
  constexpr int func() { return 10; }
};
%}

