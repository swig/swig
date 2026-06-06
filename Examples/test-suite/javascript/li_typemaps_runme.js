var li_typemaps = require("li_typemaps");

function check(a, b) {
  if (a !== b) {
    throw new Error("Not equal: " + a + " " + b)
  }
}

function check_array(a, b) {
  if (a.length != b.length)
    throw new Error("Array length mismatch " + a.length + " " + b.length)
  if (!a.every(function(element, index) { return element === b[index]; }))
    throw new Error("Arrays don't match a:" + a + " b:" + b)
}

// Check double INPUT typemaps
check(li_typemaps.in_double(22.22), 22.22)
check(li_typemaps.inr_double(22.22), 22.22)

// Check double OUTPUT typemaps
check_array(li_typemaps.out_double(22.22), [22.22])
check_array(li_typemaps.outr_double(22.22), [22.22])

// Check double INOUT typemaps
check_array(li_typemaps.inout_double(22.22), [22.22])
check_array(li_typemaps.inoutr_double(22.22), [22.22])

// check long long
check(li_typemaps.in_ulonglong(20), 20)
check(li_typemaps.inr_ulonglong(20), 20)
check_array(li_typemaps.out_ulonglong(20), [20])
check_array(li_typemaps.outr_ulonglong(20), [20])
check_array(li_typemaps.inout_ulonglong(20), [20])
check_array(li_typemaps.inoutr_ulonglong(20), [20])

// check bools
check(li_typemaps.in_bool(true), true)
check(li_typemaps.inr_bool(false), false)
check_array(li_typemaps.out_bool(true), [true])
check_array(li_typemaps.outr_bool(false), [false])
check_array(li_typemaps.inout_bool(true), [true])
check_array(li_typemaps.inoutr_bool(false), [false])

// the others
check_array(li_typemaps.inoutr_int2(1,2), [1, 2])

fi = li_typemaps.out_foo(10)
check(fi[0].a, 10)
check(fi[1], 20)
check(fi[2], 30)
