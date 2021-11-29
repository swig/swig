%module register_par

%{
struct swig_tree;
%}

%{
#if defined(__cplusplus)
#if __cplusplus >= 201703L
/*
Fix for languages that compile C tests as C++:
  error: ISO C++17 does not allow ‘register’ storage class specifier [-Werror=register]
*/
#define register
#endif
#endif
%}

// bug # 924413
%inline {
  void clear_tree_flags(register struct swig_tree *tp, register int i) {}
}
