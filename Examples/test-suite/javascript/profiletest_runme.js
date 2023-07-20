var profiletest = require("profiletest");

a = new profiletest.A();

b = new profiletest.B();
// Directly calling fn is not possible in JavaScript where
// member methods require passing a this object (like C/C++)
fn = b.fn;
for (let i = 50000; i >= 0; i--) {
    a = /* await */(fn.call(b, a));  // 1
    a = /* await */(fn.call(b, a));  // 2
    a = /* await */(fn.call(b, a));  // 3
    a = /* await */(fn.call(b, a));  // 4
    a = /* await */(fn.call(b, a));  // 5
    a = /* await */(fn.call(b, a));  // 6
    a = /* await */(fn.call(b, a));  // 7
    a = /* await */(fn.call(b, a));  // 8
    a = /* await */(fn.call(b, a));  // 9
    a = /* await */(fn.call(b, a));  // 10
    a = /* await */(fn.call(b, a));  // 1
    a = /* await */(fn.call(b, a));  // 2
    a = /* await */(fn.call(b, a));  // 3
    a = /* await */(fn.call(b, a));  // 4
    a = /* await */(fn.call(b, a));  // 5
    a = /* await */(fn.call(b, a));  // 6
    a = /* await */(fn.call(b, a));  // 7
    a = /* await */(fn.call(b, a));  // 8
    a = /* await */(fn.call(b, a));  // 9
    a = /* await */(fn.call(b, a));  // 20
}
