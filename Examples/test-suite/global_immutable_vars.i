%module global_immutable_vars

// Test immutable and mutable global variables,
// see https://www.swig.org/Doc4.0/SWIGDocumentation.html#SWIG_readonly_variables

%inline %{
  int default_mutable_var = 40;
%}

%immutable;
%feature("immutable", "0") specific_mutable_var;

%inline %{
  int global_immutable_var = 41;
  int specific_mutable_var = 42;
%}

%mutable;
%immutable specific_immutable_var;
%inline %{
  int global_mutable_var = 43;
  int specific_immutable_var = 44;

  int check_values(int default_mutable, int global_immutable, int specific_mutable, int global_mutable, int specific_immutable) {
    return
      default_mutable    == default_mutable_var &&
      global_immutable   == global_immutable_var &&
      specific_mutable   == specific_mutable_var &&
      global_mutable     == global_mutable_var &&
      specific_immutable == specific_immutable_var;
  }
%}

