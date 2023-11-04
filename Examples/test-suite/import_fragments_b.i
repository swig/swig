#if !defined(SWIGFORTRAN)
// Prevent target languages from generating module import statements in their proxy code - this test is not set up as true multiple modules
%module import_fragments_b
#endif

%fragment("ImportB", "header") %{
ImportB_this_will_not_compile;
%}

%fragment("ImportB");


