/* Simple test to check SWIG's handling of return by value */

%module ret_by_value

%inline %{

typedef struct {
   int myInt;
   short myShort;
} test;

test get_test() {
    test myTest = {100, 200};
    return myTest;
}

%}
