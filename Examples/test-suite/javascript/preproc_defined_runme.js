var preproc_defined = require("preproc_defined");

if (/* await */(preproc_defined.call_checking()) != 1) {
    throw new Error;
}

var d = new preproc_defined.Defined();
d.defined = 10;

/* await */(preproc_defined.thing(10));
/* await */(preproc_defined.stuff(10));
/* await */(preproc_defined.bumpf(10));

if (preproc_defined.a != 2) {
    throw new Error;
}

if (preproc_defined.b != 42) {
    throw new Error;
}

if (preproc_defined.z != 8) {
    throw new Error;
}
