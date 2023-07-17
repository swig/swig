var li_carrays = require("li_carrays");

var d = new li_carrays.doubleArray(10);

/* await */(d.setitem(0, 7));
/* await */(d.setitem(5, d.getitem(0) + 3));

if (/* await */(d.getitem(5)) + /* await */(d.getitem(0)) != 17) {
    throw new Error;
}

shorts = new li_carrays.shortArray(5);

sum = /* await */(li_carrays.sum_array(shorts));
if (sum != 0) {
    throw new Error("incorrect zero sum, got: " + sum.toString());
}

for (i = 0; i < 5; i++)
    /* await */(shorts.setitem(i, i));

sum = /* await */(li_carrays.sum_array(shorts));
if (sum != 0 + 1 + 2 + 3 + 4) {
    throw new Error("incorrect sum, got: " + sum.toString());
}
