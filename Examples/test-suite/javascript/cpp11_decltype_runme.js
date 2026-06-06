var cpp11_decltype = require("cpp11_decltype");

a = new cpp11_decltype.A;
a.i = 5;
if (a.i != 5) {
    throw new Error("Assignment to a.i failed.");
}

a.j = 10;
if (a.j != 10) {
    throw new Error("Assignment to a.j failed.");
}

b = a.get_number(5);
if (b != 10) {
    throw new Error("get_number(5) should return 10.");
}

b = a.get_number(6);
if (b != 0) {
    throw new Error("get_number(6) should return 0.");
}
