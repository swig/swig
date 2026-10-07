%module xxx

// C++23 explicit object parameters that C++ does not allow.

struct S {
  static int stat(this S& self);
  virtual int virt(this S& self);
  int cv_qualified(this S& self) const;
  int ref_qualified(this S& self) &;
  int default_arg(this S& self = S());
  int missing_parm(this);
  int not_first(int a, this S& self);
  int not_first_of_three(int a, int b, this S& self);
};

int not_a_member(this S& self);
auto not_a_member_deduced(this auto&& self) -> int;
