%module register_par

%{
struct swig_tree;
%}

// bug # 924413
%inline {
  void clear_tree_flags(register struct swig_tree *tp, register int i) {}
}
