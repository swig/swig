%module napi_exports_file

// This test is specific to Node-API 
%nspace;

%inline %{
  void global_fn();
  class global_class {};
  int global_var;
%}

// SWIG does not support %inline inside namespace
// (thus the duplication)
namespace global_ns {
  int hidden;
};

%{
  namespace global_ns {
    int hidden;
  };
  void global_fn() {}
%}
