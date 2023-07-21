var virtual_poly = require("virtual_poly");

var d = new virtual_poly.NDouble(3.5);
var i = new virtual_poly.NInt(2);

//
// the copy methods return the right polymorphic types
//
var dc = /* await */(d.copy());
var ic = /* await */(i.copy());

if (/* await */(d.get()) != /* await */(dc.get())) {
    throw new Error;
}

if (/* await */(i.get()) != /* await */(ic.get())) {
    throw new Error;
}

/* await */(virtual_poly.incr(ic));

if ((/* await */(i.get()) + 1) != /* await */(ic.get())) {
    throw new Error;
}


var dr = /* await */(d.ref_this());
if (/* await */(d.get()) != /* await */(dr.get())) {
    throw new Error;
}


//
// 'narrowing' also works
//
var ddc = /* await */(virtual_poly.NDouble.narrow(/* await */(d.nnumber())));
if (/* await */(d.get()) != /* await */(ddc.get())) {
    throw new Error;
}

var dic = /* await */(virtual_poly.NInt.narrow(/* await */(i.nnumber())));
if (/* await */(i.get()) != /* await */(dic.get())) {
    throw new Error;
}
