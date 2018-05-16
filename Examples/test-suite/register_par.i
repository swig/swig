%module register_par

%{
struct tree;
%}

// bug # 924413
%inline {
  void clear_tree_flags(register struct tree *tp, register int i) {}
}
