var inplaceadd = require("inplaceadd");
a = new inplaceadd.A(7);

a.addTo(5);
if (a.val != 12) {
    throw new Error(`a.val: ${a.val}`);
}

a.subFrom(5);
if (a.val != 7) {
    throw new Error(`a.val: ${a.val}`);
}

a.mulTo(2);

if (a.val != 14) {
    throw new Error(`a.val: ${a.val}`);
}

a.addTo(a);
if (a.val != 28) {
    throw new Error(`a.val: ${a.val}`);
}
