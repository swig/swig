enum GlobalEnum { globalenum1=1, globalenum2 };

GlobalEnum global_test(GlobalEnum e) { return e; }

class A { 
 public: 
  A() {}
  
  void hello() {}

  enum MemberEnum { memberenum1=10, memberenum2 };
  virtual MemberEnum member_virtual_test(MemberEnum e) { return e; }
  virtual GlobalEnum global_virtual_test(GlobalEnum e) { return e; }
}; 

