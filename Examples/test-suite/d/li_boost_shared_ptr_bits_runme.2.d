module li_boost_shared_ptr_runme_bits;

import std.exception;
import li_boost_shared_ptr_bits.li_boost_shared_ptr_bits;
import li_boost_shared_ptr_bits.HiddenDestructor;
import li_boost_shared_ptr_bits.IntHolder;
import li_boost_shared_ptr_bits.VectorIntHolder;

void main() {
  auto v = new VectorIntHolder();
  v ~= new IntHolder(11);
  v ~= new IntHolder(22);
  v ~= new IntHolder(33);
  enforce(sum(v) == 66, "sum is wrong");

  {
    scope hidden = HiddenDestructor.create();
  }
}
