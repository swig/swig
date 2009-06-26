/* This interface tests whether Swig supports the new "constexpr" keyword
   introduced by C++0x.
*/
%module foo

%inline %{
class TestClass {
        constexpr int func() { return 10; }
};
%}

