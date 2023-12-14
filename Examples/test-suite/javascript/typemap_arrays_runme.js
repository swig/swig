var typemap_arrays = require("typemap_arrays");

if (/* await */(typemap_arrays.sumA(null)) != 60)
    throw "RuntimeError, Sum is wrong";

