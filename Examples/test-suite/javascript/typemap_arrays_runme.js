var typemap_arrays = require("typemap_arrays");

if (typemap_arrays.sumA(null) != 60)
    throw "RuntimeError, Sum is wrong";

if (typemap_arrays.gridSize(null) != 12)
    throw "RuntimeError, Grid size is wrong";

if (typemap_arrays.rowSize(null) != 6)
    throw "RuntimeError, Row size is wrong";

