var profiletest = require("profiletest");

a = new profiletest.A();

b = new profiletest.B();
// Directly calling fn is not possible in JavaScript where
// member methods require passing a this object (like C/C++)
fn = b.fn;
for (let i = 50000; i >= 0; i--) {
    a = fn.call(b, a);  // 1
    a = fn.call(b, a);  // 2
    a = fn.call(b, a);  // 3
    a = fn.call(b, a);  // 4
    a = fn.call(b, a);  // 5
    a = fn.call(b, a);  // 6
    a = fn.call(b, a);  // 7
    a = fn.call(b, a);  // 8
    a = fn.call(b, a);  // 9
    a = fn.call(b, a);  // 10
    a = fn.call(b, a);  // 1
    a = fn.call(b, a);  // 2
    a = fn.call(b, a);  // 3
    a = fn.call(b, a);  // 4
    a = fn.call(b, a);  // 5
    a = fn.call(b, a);  // 6
    a = fn.call(b, a);  // 7
    a = fn.call(b, a);  // 8
    a = fn.call(b, a);  // 9
    a = fn.call(b, a);  // 20
}
