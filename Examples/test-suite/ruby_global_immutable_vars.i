%module ruby_global_immutable_vars

// This copy of global_immutable_vars.i shall be compiled with the
// SWIG Ruby option "-globalmodule" in order to check the code path
// for registering global methods (in contrast to module methods).

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

