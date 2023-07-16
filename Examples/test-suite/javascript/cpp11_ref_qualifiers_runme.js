var cpp11_ref_qualifiers = require("cpp11_ref_qualifiers");

h = new cpp11_ref_qualifiers.Host();

// Basic testing
/* await */(h.h1());
/* await */(h.h2());
/* await */(h.h6());
/* await */(h.h7());

/* await */(h.h());

// %feature testing
f = new cpp11_ref_qualifiers.Features();
if (/* await */(f.F1()) != "F1") {
    throw new Error("Fail");
}
if (/* await */(f.F2()) != "F2") {
    throw new Error("Fail");
}
if (/* await */(f.F3()) != "F3") {
    throw new Error("Fail");
}

if (/* await */(f.C1(0)) != "C1") {
    throw new Error("Fail");
}
if (/* await */(f.C2(0)) != "C2") {
    throw new Error("Fail");
}
if (/* await */(f.C3(0)) != "C3") {
    throw new Error("Fail");
}

// %rename testing
r = new cpp11_ref_qualifiers.Renames();
/* await */(r.RR1());
/* await */(r.RR2());
/* await */(r.RR3());

/* await */(r.SS1(0));
/* await */(r.SS2(0));
/* await */(r.SS3(0));

// Conversion operators
co = new cpp11_ref_qualifiers.ConversionOperators();
s = /* await */(co.StringConvertCopy());
s = /* await */(co.StringConvertMove());

co2 = new cpp11_ref_qualifiers.ConversionOperators2();
s = /* await */(co2.StringConvertMove());
