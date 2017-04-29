%module ruby_rdata

%{

  class C {};

  int take_proc_or_cpp_obj_and_ret_1(VALUE obj) {
    return 1;
  }

  int take_proc_or_cpp_obj_and_ret_1(C c) {
    return 1;
  }

%}

class C {};

int take_proc_or_cpp_obj_and_ret_1(VALUE);
int take_proc_or_cpp_obj_and_ret_1(C);
