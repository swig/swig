var static_const_member_2 = require("static_const_member_2");

function check(actual, expected) {
  if (actual !== expected) throw new Error(`got ${actual}, expected ${expected}`);
}

var c = new static_const_member_2.Test_int();
// TODO: instanceof works in Node-API and raw V8
if (typeof print === 'undefined') {
  check(c instanceof static_const_member_2.Test_int, true);

  // TODO: At the moment static const is fully correct only for Node API
  if (static_const_member_2.Test_int.prototype === 'undefined') {
    check(static_const_member_2.Test_int.forward_field, 1);
    check(static_const_member_2.Test_int.backward_field, 2);
    check(static_const_member_2.Test_int.cavity_flags, 3);
  }
} else {
  check(static_const_member_2.CavityPackFlags.forward_field, 1);
  check(static_const_member_2.CavityPackFlags.backward_field, 2);
  check(static_const_member_2.CavityPackFlags.cavity_flags, 3);
}

check(static_const_member_2.Test_int.current_profile, 4);
check(static_const_member_2.Test_int.RightIndex, 1);
check(static_const_member_2.Test_int.LeftIndex, 0);
check(static_const_member_2.Foo.BAZ.val, 2 * static_const_member_2.Foo.BAR.val);
