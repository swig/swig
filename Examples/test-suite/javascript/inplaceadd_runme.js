var inplaceadd = require("inplaceadd");
var a = new inplaceadd.A(7);

/* await */(a.addTo(5));
if (a.val != 12) {
    throw new Error(`a.val: ${a.val}`);
}

/* await */(a.subFrom(5));
/* @ts-ignore : Mutating arguments is accepted in C++ but it is considered an anti-pattern in JS/TS */
if (a.val != 7) {
    throw new Error(`a.val: ${a.val}`);
}

/* await */(a.mulTo(2));
if (a.val != 14) {
    throw new Error(`a.val: ${a.val}`);
}

/* await */(a.addTo(a));
if (a.val != 28) {
    throw new Error(`a.val: ${a.val}`);
}
