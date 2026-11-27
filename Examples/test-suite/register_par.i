%module register_par

%{
struct Tree;
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
  void clear_tree_flags(register struct Tree *tp, register int i) {}
}
