// Test if SwigPyObject derived class can be weakrefed

%module python_weakref

%inline %{
struct TestStruct {
    int x;
};
%}
