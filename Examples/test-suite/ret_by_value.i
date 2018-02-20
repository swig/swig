/* Simple test to check SWIG's handling of return by value */

%module ret_by_value

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) test; /* Ruby, wrong class name */

#ifdef SWIGFORTRAN
// Treat the struct as a native fortran struct rather than as a class with
// getters/setters.
%fortran_bindc_struct(test);
#endif

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
