#include <stdio.h>

#include "operator_overload/operator_overload_wrap.h"

#define assert(x,msg) if (!x) { printf("%d: %s\n", x, msg); SWIG_exit(0); }

int main() {
  Op_sanity_check();
  
  Op *op1 = new_Op_i(1), *op2 = new_Op_i(2), *op3 = copy_Op(op1);

  assert(Op_NotEqual(op1, op2), "neq failed");
  Op_PlusPlusPrefix(op3);  
  assert(Op_EqualEqual(op2, op3), "eqeq failed");
  assert(Op_GreaterThanEqual(op2, op1), "geq failed");
  Op_PlusEqual(op3, op1);
  assert(Op_LessThan(op1, op2) && Op_LessThan(op2, op3), "lt failed");
  assert(3 == *Op_IndexInto(op3, Op_IndexIntoConst(op2, Op_Functor_pOp(op1))), "[] or () failed");
  assert(5 == Op_Functor_pOp_i(op3, 2), "f(x) failed");
  
  delete_Op(op1);
  delete_Op(op2);
  delete_Op(op3);
  SWIG_exit(0);
}
