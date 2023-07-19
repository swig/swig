var li_carrays_cpp = require("li_carrays_cpp");

var d = new li_carrays_cpp.doubleArray(10);

/* await */(d.setitem(0, 7));
/* await */(d.setitem(5, /* await */(d.getitem(0)) + 3));

if (/* await */(d.getitem(5)) + /* await */(d.getitem(0)) != 17) {
    throw new Error;
}

var shorts = new li_carrays_cpp.shortArray(5);

var sum = /* await */(li_carrays_cpp.sum_array(shorts));
if (sum != 0) {
    throw new Error("incorrect zero sum, got: " + sum.toString());
}

for (let i = 0; i < 5; i++)
    /* await */(shorts.setitem(i, i));

sum = /* await */(li_carrays_cpp.sum_array(shorts));
if (sum != 0 + 1 + 2 + 3 + 4) {
    throw new Error("incorrect sum, got: " + sum.toString());
}
