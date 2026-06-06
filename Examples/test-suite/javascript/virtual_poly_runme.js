var virtual_poly = require("virtual_poly");

d = new virtual_poly.NDouble(3.5);
i = new virtual_poly.NInt(2);

//
// the copy methods return the right polymorphic types
//
dc = d.copy();
ic = i.copy();

if (d.get() != dc.get()) {
    throw new Error;
}

if (i.get() != ic.get()) {
    throw new Error;
}

virtual_poly.incr(ic);

if ((i.get() + 1) != ic.get()) {
    throw new Error;
}


dr = d.ref_this();
if (d.get() != dr.get()) {
    throw new Error;
}


//
// 'narrowing' also works
//
ddc = virtual_poly.NDouble.narrow(d.nnumber());
if (d.get() != ddc.get()) {
    throw new Error;
}

dic = virtual_poly.NInt.narrow(i.nnumber());
if (i.get() != dic.get()) {
    throw new Error;
}
