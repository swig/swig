#include "imports_a.h"

class B : public A 
{ 
 public: 
  B() {};
  
  void bye() {} ;

  virtual MemberEnum member_virtual_test(MemberEnum e) { return memberenum2; }
  virtual GlobalEnum global_virtual_test(GlobalEnum e) { return globalenum2; }
};

A::MemberEnum global_test(A::MemberEnum e) { return e; }

