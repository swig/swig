// Test if SwigPyObject derived class can be weakrefed

%module python_weakref

%inline %{
struct TestStruct {
    int x;
};
int *get_int_ptr() { static int an_int = 0; return &an_int; }
%}
