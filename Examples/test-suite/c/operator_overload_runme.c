#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#include "operator_overload/operator_overload_wrap.h"

int main() {
  operator_overload_Op_sanity_check();
  
  operator_overload_Op *op1 = operator_overload_Op_new_i(1), *op2 = operator_overload_Op_new_i(2), *op3 = operator_overload_Op_copy(op1);

  assert(operator_overload_Op_NotEqual(op1, op2));
  operator_overload_Op_PlusPlusPrefix(op3);
  assert(operator_overload_Op_EqualEqual(op2, op3));
  assert(operator_overload_Op_GreaterThanEqual(op2, op1));
  operator_overload_Op_PlusEqual(op3, op1);
  assert(operator_overload_Op_LessThan(op1, op2) && operator_overload_Op_LessThan(op2, op3));
  assert(3 == *operator_overload_Op_IndexInto(op3, operator_overload_Op_IndexIntoConst(op2, operator_overload_Op_Functor(op1))));
  assert(5 == operator_overload_Op_Functor_i(op3, 2));
  
  operator_overload_Op_delete(op1);
  operator_overload_Op_delete(op2);
  operator_overload_Op_delete(op3);
  exit(0);
}
