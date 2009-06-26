%module foo

%inline %{
class TestClass {
        constexpr int func() { return 10; }
};
%}

