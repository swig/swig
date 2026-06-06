var friends = require("friends");

a = new friends.A(2);

if (friends.get_val1(a) != 2) {
    throw new Error;
}
if (friends.get_val2(a) != 4) {
    throw new Error;
}
if (friends.get_val3(a) != 6) {
    throw new Error;
}

// nice overload working fine
if (friends.get_val1(1, 2, 3) != 1) {
    throw new Error;
}

b = new friends.B(3);

// David's case
if (friends.mix(a, b) != 5) {
    throw new Error;
}

di = new friends.D_i(2);
dd = new friends.D_d(3.3);

// incredible template overloading working just fine
if (friends.get_val1(di) != 2) {
    throw new Error;
}
if (friends.get_val1(dd) != 3.3) {
    throw new Error;
}

friends.set(di, 4);
friends.set(dd, 1.3);

if (friends.get_val1(di) != 4) {
    throw new Error;
}
if (friends.get_val1(dd) != 1.3) {
    throw new Error;
}

if (friends.chum_blah() != 1234) {
  throw new Error("failed");
}
if (friends.mate_blah() != 4321) {
  throw new Error("failed");
}
