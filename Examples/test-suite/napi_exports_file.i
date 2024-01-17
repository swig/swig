%module napi_exports_file

// This test is specific to Node-API 
%nspace;

%inline %{
  void global_fn();
  class global_class {};
  int global_var;
  const int global_const = 1;
%}

// SWIG does not support %inline inside namespace
// (thus the duplication)
namespace global_ns {
  int hidden_var;
  class hidden_class;
  const int hidden_const;
};

%{
  namespace global_ns {
    int hidden_var;
    class hidden_class {};
    const int hidden_const = 2;
  };
  void global_fn() {}
%}
