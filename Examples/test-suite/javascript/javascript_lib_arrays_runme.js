var javascript_lib_arrays = require("javascript_lib_arrays");

var arr = [1, 2, 3, 4, 5];

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

check(15, javascript_lib_arrays.sum1(arr, arr.length));
check(6, javascript_lib_arrays.sum2(arr));
check_array([1, 2, 3, 4], javascript_lib_arrays.data3)
