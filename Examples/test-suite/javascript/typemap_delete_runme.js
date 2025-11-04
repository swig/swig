var typemap_delete = require("typemap_delete");

var r = new typemap_delete.Rect(123);
if (r.val != 123)
    throw "RuntimeError";
