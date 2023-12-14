var friends = require("friends");

var a = new friends.A(2);

if (/* await */(friends.get_val1(a)) != 2) {
    throw new Error;
}
if (/* await */(friends.get_val2(a)) != 4) {
    throw new Error;
}
if (/* await */(friends.get_val3(a)) != 6) {
    throw new Error;
}

// nice overload working fine
if (/* await */(friends.get_val1(1, 2, 3)) != 1) {
    throw new Error;
}

var b = new friends.B(3);

// David's case
if (/* await */(friends.mix(a, b)) != 5) {
    throw new Error;
}

var di = new friends.D_i(2);
var dd = new friends.D_d(3.3);

// incredible template overloading working just fine
if (/* await */(friends.get_val1(di)) != 2) {
    throw new Error;
}
if (/* await */(friends.get_val1(dd)) != 3.3) {
    throw new Error;
}

/* await */(friends.set(di, 4));
/* await */(friends.set(dd, 1.3));

if (/* await */(friends.get_val1(di)) != 4) {
    throw new Error;
}
if (/* await */(friends.get_val1(dd)) != 1.3) {
    throw new Error;
}
