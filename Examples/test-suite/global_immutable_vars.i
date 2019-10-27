%module global_immutable_vars

// Test immutable and mutable global variables,
// see http://www.swig.org/Doc4.0/SWIGDocumentation.html#SWIG_readonly_variables

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
%}

