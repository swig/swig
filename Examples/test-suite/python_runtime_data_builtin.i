// Test swig_runtime_data with and without -builtin

%module python_runtime_data_builtin

#if defined(SWIGPYTHON_BUILTIN)
%begin %{
#if defined(Py_LIMITED_API)
#undef Py_LIMITED_API // not yet supported by builtin
#endif
%}
#endif

%inline %{
#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}

%include std_vector.i

%template(vectord) std::vector<double>;
