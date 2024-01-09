var static_const_member_2 = require("static_const_member_2");

function check(actual, expected) {
  if (actual !== expected) throw new Error(`got ${actual}, expected ${expected}`);
}

var c = new static_const_member_2.Test_int();
check(c instanceof static_const_member_2.Test_int, true);
check(static_const_member_2.Test_int.forward_field, 1);
check(static_const_member_2.Test_int.current_profile, 4);
check(static_const_member_2.Test_int.RightIndex, 1);
check(static_const_member_2.Test_int.backward_field, 2);
check(static_const_member_2.Test_int.LeftIndex, 0);
check(static_const_member_2.Test_int.cavity_flags, 3);
check(static_const_member_2.Foo.BAZ.val, 2 * static_const_member_2.Foo.BAR.val);
