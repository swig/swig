/* This interface tests whether Swig supports the new "constexpr" keyword
   introduced by C++0x.
*/
%module cpp0x_constexpr

%inline %{
class TestClass {
public:
        constexpr int func() { return 10; }
};
%}

