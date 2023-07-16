var cpp11_rvalue_reference = require("cpp11_rvalue_reference");

a = new cpp11_rvalue_reference.A();

/* await */(a.setAcopy(5));
if (/* await */(a.getAcopy()) != 5) {
    throw new Error("int A::getAcopy() value is " +
        /* await */(a.getAcopy()) + " should be 5");
}

ptr = /* await */(a.getAptr());

/* await */(a.setAptr(ptr));
if (/* await */(a.getAcopy()) != 5) {
    throw new Error("after A::setAptr(): int A::getAcopy() value is " +
        /* await */(a.getAcopy()) + " should be 5");
}

/* await */(a.setAref(ptr));
if (/* await */(a.getAcopy()) != 5) {
    throw new Error("after A::setAref(): int A::getAcopy() value is " +
        /* await */(a.getAcopy()) + " should be 5");
}

rvalueref = /* await */(a.getAmove());

/* await */(a.setAref(rvalueref));
if (/* await */(a.getAcopy()) != 5) {
    throw new Error("after A::setAmove(): int A::getAcopy() value is " +
        /* await */(a.getAcopy()) + " should be 5");
}
